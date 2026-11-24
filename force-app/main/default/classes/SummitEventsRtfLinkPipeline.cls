/**
 * Makes images embedded in public-facing rich text fields publicly viewable by guest users and
 * email recipients without granting them access to the records. Supported objects and fields are
 * listed in RICHTEXT_FIELDS_BY_OBJECT: events, appointment types (shown on the appointments page)
 * and emails (sent to registrants). Each has a trigger that calls {@link SummitEventsLinkHandler}.
 *
 * Two kinds of embedded images are handled:
 * 1. ContentVersion links (versionId=068...), e.g. pasted from a Files preview.
 *    These are converted synchronously.
 * 2. Rich text editor uploads (/servlet/rtaImage?...refid=0EM...). Their bytes are only
 *    reachable through the REST API, which needs a callout, so they are handled in
 *    {@link SummitEventsRtaImageQueueable}. An upload already stored as a file on the record
 *    (see reuseStoredImages()) is converted at once from that file instead.
 *
 * Either way the image ends up as a ContentVersion with a ContentDistribution, and the
 * img src is rewritten to the distribution's ContentDownloadUrl. (DistributionPublicUrl is
 * an HTML viewer page and cannot be used as an image source.)
 *
 * Runs as the user who saved the record, in user mode. Guests never touch this code: the
 * registration data model is master-detail all the way down, so guests cannot be given record
 * access to events (or their appointment types), and email recipients have no access at all,
 * which is exactly why images must be made public instead.
 *
 * Security and Code Analyzer notes
 * - with sharing, and every query and DML statement is USER_MODE. The editor needs read access to
 *   the rich text fields and to any file they link, plus file create and public-link access. The
 *   Summit_Events_Admin permission set grants the record and field access. Create Public Links is a
 *   user permission, which a packaged permission set cannot carry, so each org grants it itself (dev
 *   orgs get the unpackaged Summit_Events_Dev_Public_Links). If they lack any of it the operation
 *   fails closed, the field is left unchanged and the editor is notified. The single exception is notificationTypeId(), a system-mode lookup of
 *   our own notification type's Id so failures can be reported to ordinary editors.
 * - Failures are reported to the editor with an in-app notification of fixed, translatable
 *   messages (Custom Labels). Raw exception text is never shown or sent.
 * - A ContentVersion link is only converted when the editor can read that file (checked in
 *   prepare()) and it is an image. This stops an editor publishing a private or non-image file by
 *   pasting its Id into an img tag.
 * - filter() only reads and rewrites rich text fields the user can update.
 * - Only allowlisted image content types are ever stored and made public.
 * - ApexSOQLInjection was a false positive on the dynamic query in filter(): the only concatenated
 *   parts are the object name from the schema and field names from the RICHTEXT_FIELDS_BY_OBJECT
 *   allowlist (plus the namespace prefix), and record Ids are passed as a bind variable.
 * - ApexSuggestUsingNamedCred is intentionally suppressed in fetchImage(), and no Remote Site
 *   Setting is required for its callout; see the note there.
 */
public with sharing class SummitEventsRtfLinkPipeline {

    // The rich text fields whose images the public sees, by object (names without namespace). Inelegant,
    // but schema introspection can't differentiate RTF from regular text fields. Only list fields that
    // are shown to guests or sent to registrants: converting a field makes its images public.
    private static final Map<String,Set<String>> RICHTEXT_FIELDS_BY_OBJECT = new Map<String,Set<String>>{
        'Summit_Events__c' => new Set<String>{
            'Event_Full_Text__c', 'Event_Confirmation_Description__c',
            'Event_Additional_Questions_Description__c',
            'Event_Appointment_Description__c', 'Event_Footer__c',
            'Event_Submit_Description__c', 'Event_Cancel_Review_Description__c',
            'Event_Payment_Due_Description__c', 'Event_Payment_Received_Description__c',
            'Event_description__c', 'Donation_Description__c',
            'Guest_Registration_Description__c'
        },
        // Shown to guests on the appointments page
        'Summit_Events_Appointment_Type__c' => new Set<String>{ 'Description__c' },
        // Sent to registrants as the email body
        'Summit_Events_Email__c' => new Set<String>{ 'Email_Content__c' }
    };

    private static final String namespace = SummitEventsNamespace.StrTokenNSPrefix('');
    private static final String NOTIFICATION_TYPE = 'Summit_Events_Image_Publishing';
    // ContentVersion URL shapes we recognize: ...?versionId=068... and .../version/download/068...
    private static final String CV_MARKER = 'versionId=068';
    private static final String CV_DOWNLOAD_MARKER = '/version/download/068';
    private static final String RTA_MARKER = 'refid=0EM';
    // Keep in step with this class's API version
    private static final String REST_VERSION = 'v68.0';
    private static final String ALPHANUMERICS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

    // Keep each async job well inside callout, heap and CPU limits; leftovers are chained
    private static final Integer MAX_RTA_IMAGES_PER_JOB = 20;
    private static final Integer MAX_RTA_BYTES_PER_JOB = 4000000;

    // Only these content types are ever made public
    private static final Map<String,String> IMAGE_EXTENSIONS = new Map<String,String>{
        'image/jpeg' => 'jpg',
        'image/jpg' => 'jpg',
        'image/png' => 'png',
        'image/gif' => 'gif',
        'image/webp' => 'webp',
        'image/bmp' => 'bmp'
    };
    
    @TestVisible
    private static List<SObject> recordOverrides;

    // Records this transaction is already converting. push() updates the record, which fires the
    // trigger again; without this guard the nested run would queue a second job for the same images
    // and both jobs would store duplicate files.
    private static Set<Id> recordsInProgress = new Set<Id>();

    // File extensions we are willing to publish
    private static final Set<String> IMAGE_FILE_EXTENSIONS = new Set<String>{
        'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'
    };

    private Map<Id,ContentDistribution> cvIdToCDMap;
    private Set<Id> publishableCvIds = new Set<Id>();
    private String recordFieldList = '';
    // Fixed, translatable messages for the person who saved the record; never raw exception text
    private Set<String> problems = new Set<String>();
    private List<RecordWrapper> wrappedRecordList;
    private List<Id> idList;
    private String executionStage;
    private Boolean hasDeferredImages = false;
    private Integer rtaImagesPublished = 0;
    // The object of the records being converted; null when there are none
    private Schema.DescribeSObjectResult objectDescribe;

    /**
     * @param newMap Trigger.newMap of a supported object (see RICHTEXT_FIELDS_BY_OBJECT)
     */
    public SummitEventsRtfLinkPipeline(Map<Id,SObject> newMap) {
        this(new List<Id>(newMap.keySet()));
    }

    /**
     * @param recordIds records of one supported object (see RICHTEXT_FIELDS_BY_OBJECT)
     */
    public SummitEventsRtfLinkPipeline(List<Id> recordIds) {
        this.cvIdToCDMap = new Map<Id,ContentDistribution>();
        this.wrappedRecordList = new List<RecordWrapper>();
        this.idList = recordIds;
        if(recordIds != null && !recordIds.isEmpty()) {
            this.objectDescribe = recordIds[0].getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED);
        }
    }

    /**
     * Trigger-time entry point. Converts ContentVersion links now and hands any
     * rich text editor uploads to a Queueable.
     */
    public void run() {
        this.executionStage = 'run';
        if(!claimRecords()) {
            return;
        }
        try {
            filter();
            scan();
            reuseStoredImages();
            prepare();
            create();
            push();
            enqueueRtaImages();
        } catch(Exception e) {
            this.problems.add(Label.SummitEventsImageNotifFailed);
        } finally {
            releaseRecords();
        }
        notifyProblems();
    }

    /**
     * Async entry point, called from {@link SummitEventsRtaImageQueueable}. Fetches
     * rich text editor images, stores them as files, and rewrites the fields.
     * @return true when more images remain and this job published at least one, so another
     *         job should be chained. A job that published nothing would only fetch the same
     *         images again and store duplicate files, so it never chains.
     */
    public Boolean runAsync() {
        this.executionStage = 'runAsync';
        if(!claimRecords()) {
            return false;
        }
        Boolean hasMore = false;
        try {
            filter();
            scan();
            reuseStoredImages();
            fetch();
            prepare();
            create();
            push();
            hasMore = this.hasDeferredImages && this.rtaImagesPublished > 0;
        } catch(Exception e) {
            this.problems.add(Label.SummitEventsImageNotifFailed);
        } finally {
            releaseRecords();
        }
        notifyProblems();
        return hasMore;
    }

    /**
     * Drop records this transaction is already converting and mark the rest as in progress.
     * @return true when at least one record is left to convert
     */
    private Boolean claimRecords() {
        List<Id> unclaimedIds = new List<Id>();
        for(Id recordId : this.idList) {
            if(!recordsInProgress.contains(recordId)) {
                unclaimedIds.add(recordId);
            }
        }
        this.idList = unclaimedIds;
        recordsInProgress.addAll(unclaimedIds);
        return !unclaimedIds.isEmpty();
    }

    private void releaseRecords() {
        recordsInProgress.removeAll(this.idList);
    }

    /**
     * Cheap first-pass filter to select and wrap records that have rich text
     * fields with embedded images we can convert.
     */
    @TestVisible
    private void filter() {

        this.executionStage = 'filter';

        List<SObject> freshRecordList = new List<SObject>();
        List<String> fields = new List<String>();
        String query = '';

        Set<String> richTextFields = this.objectDescribe == null
            ? null
            : RICHTEXT_FIELDS_BY_OBJECT.get(this.objectDescribe.getLocalName());
        if(richTextFields == null) {
            // Not an object whose images are published; leave everything alone
            return;
        }

        Map<String,SObjectField> fieldMap = this.objectDescribe.fields.getMap();

        for(String field : richTextFields) {

            Boolean isUpdateable = fieldMap.get(namespace + field).getDescribe().isUpdateable();

            if(isUpdateable) {
                fields.add(namespace + field);
            }
        }

        if(fields.isEmpty()) {
            // The user cannot update any of the rich text fields, so there is nothing we may rewrite.
            // wrappedRecordList stays empty, which makes every later stage a no-op.
            return;
        }

        // Safe dynamic SOQL: the object name comes from the schema, field names come from the
        // RICHTEXT_FIELDS_BY_OBJECT allowlist (plus the package namespace) and the Ids are bound
        // below. No user-controlled text reaches the query string.
        String fieldList = String.join(fields, ', ');
        this.recordFieldList = fieldList;
        query = 'SELECT Name, ' + fieldList + ' FROM ' + this.objectDescribe.getName() + ' WHERE Id IN :idList';
        if(recordOverrides == null) {
            Map<String,Object> binds = new Map<String,Object>{ 'idList' => idList };
            freshRecordList = Database.queryWithBinds(query, binds, System.AccessLevel.USER_MODE);
        } else {
            // Test seam: the platform strips rtaImage tags it cannot tie to a real upload, so tests
            // cannot save realistic rich text and supply it here instead
            Set<Id> requestedIds = new Set<Id>(idList);
            for(SObject stagedRecord : recordOverrides) {
                if(requestedIds.contains(stagedRecord.Id)) {
                    freshRecordList.add(stagedRecord);
                }
            }
        }

        for(SObject freshRecord : freshRecordList) {
            RecordWrapper wrappedRecord = new RecordWrapper();
            for (String field : fields) {
                String fieldVal = (String) freshRecord?.get(field);
                if(!String.isBlank(fieldVal) && fieldVal.contains('<img') 
                    && (fieldVal.contains(CV_MARKER) || fieldVal.contains(CV_DOWNLOAD_MARKER) || fieldVal.contains(RTA_MARKER))) {
                    wrappedRecord.fieldsWithLinks.add(field);
                }
            }
            if(!wrappedRecord.fieldsWithLinks.isEmpty()) {
                wrappedRecord.record = freshRecord;
                this.wrappedRecordList.add(wrappedRecord);
            }
        } 
    }

    /**
     * Scan through wrapped records and find every convertible image: either a
     * ContentVersion Id or a rich text editor image reference (0EM...).
     * Pattern and Matcher would have less cognitive overhead, but they
     * come attached to significant time complexity, so we're going to
     * roll our own manual string ops. Even without direct access to char
     * arrays, this should still be O(n). 
     */
    @TestVisible
    private void scan() {
        
        this.executionStage = 'scan';

        for (RecordWrapper wrappedRecord : wrappedRecordList) {
            Map<String, List<SummitFieldItem>> tempMap = new Map<String, List<SummitFieldItem>>();
        
            for (String field : wrappedRecord.fieldsWithLinks) {
                String html = (String) wrappedRecord.record.get(field);
                List<SummitFieldItem> items = new List<SummitFieldItem>();
            
                Integer pos = 0;
                while (true) {
                    // Find the next <img src="...">
                    Integer tagStart = html.indexOf('<img', pos);
                    if (tagStart == -1) {
                        break;
                    }
                
                    Integer srcStart = html.indexOf('src="', tagStart);
                    if (srcStart == -1) {
                        break;
                    }
                
                    srcStart += 5; // past src="
                    Integer srcEnd = html.indexOf('"', srcStart);
                    if (srcEnd == -1) {
                        break;
                    }
                
                    String url = html.substring(srcStart, srcEnd);
                    pos = srcEnd + 1;

                    SummitFieldItem sfi = toFieldItem(url);
                    if (sfi != null) {
                        items.add(sfi);
                    }
                }
            
                if (!items.isEmpty()) {
                    tempMap.put(field, items);
                }
            }
            wrappedRecord.fieldsToLinkMap = tempMap;
        }
    }

    /**
     * Point rich text editor images at the file an earlier job already stored for them, so they
     * are converted without fetching them again. A save from a record page opened before that job
     * rewrote the field (Lightning's "Choose values to keep" dialog, keeping your value) puts the
     * original upload URLs back; without this, every such save would store the images again.
     * Only files we stored on these records are considered: first published to the record and
     * named refId.extension by fetch().
     */
    @TestVisible
    private void reuseStoredImages() {

        this.executionStage = 'reuseStoredImages';

        Set<Id> recordIds = new Set<Id>();
        Set<String> storedNames = new Set<String>();
        for(RecordWrapper wrappedRecord : wrappedRecordList) {
            for(List<SummitFieldItem> items : wrappedRecord.fieldsToLinkMap.values()) {
                for(SummitFieldItem sfi : items) {
                    if(sfi.refId != null && sfi.cvId == null) {
                        recordIds.add(wrappedRecord.record.Id);
                        for(String extension : IMAGE_EXTENSIONS.values()) {
                            storedNames.add(sfi.refId + '.' + extension);
                        }
                    }
                }
            }
        }

        if(storedNames.isEmpty()) {
            return;
        }

        // Oldest first, so repeated runs always settle on the same file
        Map<String,Id> cvIdByRefId = new Map<String,Id>();
        for(ContentVersion cv : [
            SELECT Id,
                   PathOnClient
            FROM   ContentVersion
            WHERE  FirstPublishLocationId IN :recordIds
            AND    PathOnClient IN :storedNames
            AND    IsLatest = true
            WITH   USER_MODE
            ORDER BY CreatedDate
        ]) {
            String refId = cv.PathOnClient.substringBeforeLast('.');
            if(!cvIdByRefId.containsKey(refId)) {
                cvIdByRefId.put(refId, cv.Id);
            }
        }

        for(RecordWrapper wrappedRecord : wrappedRecordList) {
            for(List<SummitFieldItem> items : wrappedRecord.fieldsToLinkMap.values()) {
                for(SummitFieldItem sfi : items) {
                    if(sfi.refId != null && sfi.cvId == null && cvIdByRefId.containsKey(sfi.refId)) {
                        sfi.cvId = cvIdByRefId.get(sfi.refId);
                    }
                }
            }
        }
    }

    /**
     * Fetch rich text editor images through the REST API and store each as a file
     * owned by its record. This is the only stage that makes callouts, so it must run
     * in an async context, and all callouts must finish before any DML.
     */
    @TestVisible
    private void fetch() {

        this.executionStage = 'fetch';

        Map<String,FetchedImage> imageByRefId = new Map<String,FetchedImage>();
        Set<String> attempted = new Set<String>();
        Integer totalBytes = 0;

        for(RecordWrapper wrappedRecord : wrappedRecordList) {
            for(String field : wrappedRecord.fieldsToLinkMap.keySet()) {
                for(SummitFieldItem sfi : wrappedRecord.fieldsToLinkMap.get(field)) {
                    // cvId is already set when reuseStoredImages() found a stored file
                    if(sfi.refId == null || sfi.cvId != null || attempted.contains(sfi.refId)) {
                        continue;
                    }
                    if(attempted.size() >= MAX_RTA_IMAGES_PER_JOB || totalBytes >= MAX_RTA_BYTES_PER_JOB
                        || Limits.getCallouts() >= Limits.getLimitCallouts()) {
                        this.hasDeferredImages = true;
                        continue;
                    }
                    attempted.add(sfi.refId);
                    FetchedImage image = fetchImage(wrappedRecord.record, field, sfi.refId);
                    if(image != null) {
                        imageByRefId.put(sfi.refId, image);
                        totalBytes += image.body.size();
                    }
                }
            }
        }

        if(imageByRefId.isEmpty()) {
            return;
        }

        List<String> refIds = new List<String>(imageByRefId.keySet());
        List<ContentVersion> versionList = new List<ContentVersion>();
        for(String refId : refIds) {
            FetchedImage image = imageByRefId.get(refId);
            versionList.add(new ContentVersion(
                Title = (image.recordName + ' - ' + refId).left(240),
                PathOnClient = refId + '.' + image.extension,
                VersionData = image.body,
                FirstPublishLocationId = image.recordId,
                IsMajorVersion = true
            ));
        }
        Database.insert(versionList, true, System.AccessLevel.USER_MODE);

        Map<String,Id> cvIdByRefId = new Map<String,Id>();
        for(Integer i = 0; i < refIds.size(); i++) {
            cvIdByRefId.put(refIds[i], versionList[i].Id);
        }

        // From here on the image is just another ContentVersion link
        for(RecordWrapper wrappedRecord : wrappedRecordList) {
            for(List<SummitFieldItem> items : wrappedRecord.fieldsToLinkMap.values()) {
                for(SummitFieldItem sfi : items) {
                    if(sfi.refId != null && cvIdByRefId.containsKey(sfi.refId)) {
                        sfi.cvId = cvIdByRefId.get(sfi.refId);
                    }
                }
            }
        }
    }
    
    /**
     * Prepare the pipeline for execution; populate some final values
     * we'll need for execution.
     */
    @TestVisible
    private void prepare() {

        this.executionStage = 'prepare';

        Set<Id> cvIdSet = new Set<Id>();
        for(RecordWrapper wrappedRecord : wrappedRecordList) {
            for(String field : wrappedRecord.fieldsToLinkMap.keySet()) {
                for(SummitFieldItem sfi : wrappedRecord.fieldsToLinkMap.get(field)) {
                    if(sfi.cvId != null) {
                        cvIdSet.add(sfi.cvId);
                    }
                }
            }
        }

        if(cvIdSet.isEmpty()) {
            return;
        }

        // Only files this user can read (USER_MODE hides the rest) and that are images may be
        // published. Anything else is left exactly as the editor wrote it.
        for(ContentVersion cv : [
            SELECT Id,
                   FileExtension
            FROM   ContentVersion
            WHERE  Id IN :cvIdSet
            WITH   USER_MODE
        ]) {
            if(cv.FileExtension != null && IMAGE_FILE_EXTENSIONS.contains(cv.FileExtension.toLowerCase())) {
                this.publishableCvIds.add(cv.Id);
            }
        }

        if(this.publishableCvIds.size() < cvIdSet.size()) {
            this.problems.add(Label.SummitEventsImageNotifFile);
        }

        if(this.publishableCvIds.isEmpty()) {
            return;
        }

        List<ContentDistribution> cdList = [
            SELECT Id,
                   ContentDownloadUrl,
                   Name,
                   ContentVersionId,
                   PreferencesAllowOriginalDownload,
                   PreferencesPasswordRequired,
                   PreferencesExpires
            FROM   ContentDistribution
            WHERE  ContentVersionId IN :this.publishableCvIds
            WITH   USER_MODE
        ];

        // Reuse an existing link only if a guest can actually load the image from it. Links that have
        // expired, need a password or block downloads are ignored, never edited, and create() adds a
        // suitable link next to them. A file can have several links but normally only one per user,
        // so that can fail when the unusable link is the editor's own (see create()).
        for(ContentDistribution cd : cdList) {
            Boolean usable = cd.PreferencesAllowOriginalDownload
                && !cd.PreferencesPasswordRequired
                && !cd.PreferencesExpires;
            if(usable) {
                this.cvIdToCDMap.put(cd.ContentVersionId, cd);
            }
        }
    }

    /**
     * Create ContentDistribution records for any ContentVersion records
     * that do not already have a usable ContentDistribution record.
     */
    @TestVisible
    private void create() {

        this.executionStage = 'create';

        List<ContentDistribution> cdInsertList = new List<ContentDistribution>();
        Set<Id> visited = new Set<Id>();
        
        for(RecordWrapper wrappedRecord : wrappedRecordList) {
            for(String field : wrappedRecord.fieldsToLinkMap.keySet()) {
                Integer i = 0;
                for(SummitFieldItem sfi : wrappedRecord.fieldsToLinkMap.get(field)) {
                    if(publishableCvIds.contains(sfi.cvId) && !cvIdToCDMap.containsKey(sfi.cvId) && !visited.contains(sfi.cvId)) {
                        ContentDistribution cd = new ContentDistribution();
                        cd.ContentVersionId = sfi.cvId;
                        cd.Name = ((String) wrappedRecord.record.get('Name') + ' - ' + field + i++).left(100); // Name max is 100
                        // Set every preference explicitly so behavior does not depend on org defaults.
                        // Notify-on-visit defaults to on, and every guest view of a public page or email
                        // would email whoever created the link.
                        cd.PreferencesNotifyOnVisit = false;
                        cd.PreferencesAllowViewInBrowser = true;
                        cd.PreferencesAllowOriginalDownload = true; // needed for the direct ContentDownloadUrl
                        cd.PreferencesPasswordRequired = false;
                        cd.PreferencesExpires = false;
                        cdInsertList.add(cd);
                        visited.add(sfi.cvId);
                    }
                }
            }
        }

        if(!cdInsertList.isEmpty()) {
            // Partial success: one image that cannot be published must not stop the others
            List<Database.SaveResult> results = Database.insert(cdInsertList, false, System.AccessLevel.USER_MODE);
            List<Id> createdIds = new List<Id>();
            for(Database.SaveResult result : results) {
                if(result.isSuccess()) {
                    createdIds.add(result.getId());
                } else if(isDuplicateLink(result)) {
                    // The editor already has a link to this file and it cannot serve the image. We
                    // never change an existing link's restrictions, so the image is left as written.
                    this.problems.add(Label.SummitEventsImageNotifBlocked);
                } else {
                    this.problems.add(Label.SummitEventsImageNotifFailed);
                }
            }

            if(!createdIds.isEmpty()) {
                List<ContentDistribution> refreshed = [
                    SELECT Id, 
                           ContentDownloadUrl,
                           Name, 
                           ContentVersionId  
                    FROM   ContentDistribution 
                    WHERE  Id IN :createdIds
                    WITH   USER_MODE
                ];

                for(ContentDistribution cd : refreshed) {
                    cvIdToCDMap.put(cd.ContentVersionId, cd);
                }
            }
        }
    }

    // A user normally gets only one link per file; a second insert fails with DUPLICATE_VALUE.
    // The platform does not enforce this every time (seen in parallel test runs); when it lets the
    // insert through, the image simply uses the new usable link.
    private static Boolean isDuplicateLink(Database.SaveResult result) {
        for(Database.Error error : result.getErrors()) {
            if(error.getStatusCode() == StatusCode.DUPLICATE_VALUE) {
                return true;
            }
        }
        return false;
    }

    /**
     * Replace all converted URLs in the RTF fields with the corresponding ContentDistribution
     * record's ContentDownloadUrl (the direct file URL; DistributionPublicUrl is an HTML viewer
     * page that cannot be used in an img tag), and update the record.
     */
    @TestVisible
    private void push() { 

        this.executionStage = 'push';

        if(cvIdToCDMap.isEmpty()) {
            return;
        }

        List<SObject> updateList = new List<SObject>();

        // The text we scanned can be seconds old (the async job makes callouts in between), so
        // never write it back. Lock the records and apply each replacement to the current field
        // value instead, which keeps anything the editor changed in the meantime.
        Map<Id,SObject> currentById = lockCurrentRecords();
        Integer rtaImagesReplaced = 0;

        for(RecordWrapper wrappedRecord : wrappedRecordList) {
            SObject current = currentById.get(wrappedRecord.record.Id);
            if(current == null) {
                continue; // deleted while we were working
            }
            // Trigger records are immutable, so update a new in-memory record with the same Id
            SObject tempRecord = this.objectDescribe.getSObjectType().newSObject(current.Id);
            Boolean changed = false;
            for(String field : wrappedRecord.fieldsWithLinks) {
                String rtf = (String) current.get(field);
                if(rtf == null) {
                    continue;
                }
                String original = rtf;
                for(SummitFieldItem sfi : wrappedRecord.fieldsToLinkMap.get(field) ?? new List<SummitFieldItem>()) {
                    ContentDistribution cd = sfi.cvId == null ? null : cvIdToCDMap.get(sfi.cvId);
                    if(cd != null) {
                        String replaced = rtf.replace(sfi.url, cd.ContentDownloadUrl);
                        if(sfi.refId != null && replaced != rtf) {
                            rtaImagesReplaced++;
                        }
                        rtf = replaced;
                    }
                }
                if(rtf != original) {
                    tempRecord.put(field,rtf);
                    // Keep our copy in step with the save. Under the test seam it is the staged
                    // record, so a nested trigger run reads what was saved, as it would from the database.
                    current.put(field, rtf);
                    changed = true;
                }
            }
            if(changed) {
                updateList.add(tempRecord);
            }
        }

        if(!updateList.isEmpty()) {
            this.executionStage = 'push.DML';
            Database.update(updateList, true, System.AccessLevel.USER_MODE);
            // Only counted once saved: all-or-none, so reaching here means every replacement persisted
            this.rtaImagesPublished = rtaImagesReplaced;
        }
     }

    /**
     * Re-read the records we are about to update and lock them until this transaction ends, so
     * nobody can change them between this read and our write.
     */
    private Map<Id,SObject> lockCurrentRecords() {

        Map<Id,SObject> recordsById = new Map<Id,SObject>();
        List<Id> recordIds = new List<Id>();
        for(RecordWrapper wrappedRecord : wrappedRecordList) {
            recordIds.add(wrappedRecord.record.Id);
        }

        if(recordOverrides != null) {
            // Test seam: staged field contents are not in the database, so use them as they are
            for(RecordWrapper wrappedRecord : wrappedRecordList) {
                recordsById.put(wrappedRecord.record.Id, wrappedRecord.record);
            }
            return recordsById;
        }

        if(!recordIds.isEmpty()) {
            // Same allowlisted field list and bound Ids as filter(); nothing user-controlled is concatenated
            String query = 'SELECT Name, ' + this.recordFieldList + ' FROM ' + this.objectDescribe.getName()
                + ' WHERE Id IN :recordIds FOR UPDATE';
            Map<String,Object> binds = new Map<String,Object>{ 'recordIds' => recordIds };
            for(SObject record : Database.queryWithBinds(query, binds, System.AccessLevel.USER_MODE)) {
                recordsById.put(record.Id, record);
            }
        }
        return recordsById;
    }

    /**
     * Queue one async job for every record that still has rich text editor images
     * waiting to be converted. Never enqueues from inside a Queueable, so the update
     * made by the job cannot start another job.
     */
    private void enqueueRtaImages() {

        this.executionStage = 'enqueue';

        if(System.isQueueable() || Limits.getQueueableJobs() >= Limits.getLimitQueueableJobs()) {
            return;
        }

        Set<Id> pendingRecordIds = new Set<Id>();
        for(RecordWrapper wrappedRecord : wrappedRecordList) {
            for(List<SummitFieldItem> items : wrappedRecord.fieldsToLinkMap.values()) {
                for(SummitFieldItem sfi : items) {
                    if(sfi.refId != null && sfi.cvId == null) {
                        pendingRecordIds.add(wrappedRecord.record.Id);
                    }
                }
            }
        }

        if(!pendingRecordIds.isEmpty()) {
            System.enqueueJob(new SummitEventsRtaImageQueueable(new List<Id>(pendingRecordIds)));
        }
    }

    private void notifyProblems() {
        if(!this.problems.isEmpty() && this.idList != null && !this.idList.isEmpty()) {
            notifyUser(this.idList[0], this.problems);
        }
    }

    /**
     * Tell the user who saved the record that something was not published, with an in-app
     * (bell) notification that opens the record. Best effort: failing to notify must never
     * stop a record from saving, and only fixed messages are sent, never exception text.
     * @param targetId the record the notification should open
     * @param messages short, user-safe messages
     */
    public static void notifyUser(Id targetId, Set<String> messages) {
        if(messages == null || messages.isEmpty()) {
            return;
        }
        try {
            Id typeId = notificationTypeId();
            if(typeId == null) {
                return;
            }
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setNotificationTypeId(typeId);
            notification.setTitle(Label.SummitEventsImageNotifTitle);
            notification.setBody(String.join(new List<String>(messages), ' ').left(750));
            notification.setTargetId(targetId);
            notification.send(new Set<String>{ UserInfo.getUserId() });
        } catch(Exception e) {
            System.debug(LoggingLevel.WARN, 'Summit Events could not send a notification: ' + e.getTypeName());
        }
    }

    // The one deliberate use of system mode in this class: ordinary editors cannot query
    // CustomNotificationType, and without its Id they would never hear about a failure. This only
    // looks up the Id of our own fixed notification type by DeveloperName; no record data is read.
    // DeveloperName is only unique within a namespace, so match ours: the package namespace when
    // installed (a subscriber may have a type with the same name), none when deployed unmanaged.
    @TestVisible
    private static Id notificationTypeId() {
        String namespacePrefix = String.isBlank(SummitEventsNamespace.getNamespace()) ? null : SummitEventsNamespace.getNamespace();
        List<CustomNotificationType> types = [
            SELECT Id
            FROM   CustomNotificationType
            WHERE  DeveloperName = :NOTIFICATION_TYPE
            AND    NamespacePrefix = :namespacePrefix
            WITH   SYSTEM_MODE
            LIMIT  1
        ];
        return types.isEmpty() ? null : types[0].Id;
    }

    /**
     * Download one rich text editor image via the REST API using the running user's session.
     * @return the image, or null if it could not be fetched or is not an allowed image type
     */
    private FetchedImage fetchImage(SObject record, String field, String refId) {

        HttpRequest request = new HttpRequest();
        request.setEndpoint(
            URL.getOrgDomainUrl().toExternalForm()
            + '/services/data/' + REST_VERSION
            + '/sobjects/' + this.objectDescribe.getName() + '/' + record.Id
            + '/richTextImageFields/' + field + '/' + refId
        );
        request.setMethod('GET');
        // Code Analyzer ApexSuggestUsingNamedCred is a false positive here. This calls the org's own
        // REST API as the user who saved the record, so the running user's session is the right
        // credential and it works with no per-org setup. A Named Credential would need an
        // External Credential, a Connected App/OAuth flow and a permission set assigned in every
        // subscriber org, and it would run as a fixed identity instead of the editing user.
        // The session ID is only ever sent to this org's own My Domain URL built above.
        // No Remote Site Setting is needed either: the Apex URL class docs say a URL from
        // getOrgDomainUrl() can call the org's own Salesforce APIs without one, so subscribers
        // have nothing to set up. Verified in a scratch org with no remote site for its domain.
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId()); // NOPMD
        request.setTimeout(60000);

        HttpResponse response;
        try {
            response = new Http().send(request);
        } catch(CalloutException e) {
            this.problems.add(Label.SummitEventsImageNotifFetch);
            return null;
        }

        if(response.getStatusCode() != 200) {
            this.problems.add(Label.SummitEventsImageNotifFetch);
            return null;
        }

        String contentType = (response.getHeader('Content-Type') ?? '').substringBefore(';').trim().toLowerCase();
        Blob body = response.getBodyAsBlob();
        if(!IMAGE_EXTENSIONS.containsKey(contentType) || body == null || body.size() == 0) {
            this.problems.add(Label.SummitEventsImageNotifFetch);
            return null;
        }

        FetchedImage image = new FetchedImage();
        image.recordId = record.Id;
        image.recordName = (String) record.get('Name');
        image.extension = IMAGE_EXTENSIONS.get(contentType);
        image.body = body;
        return image;
    }

    /**
     * Turn an img src into a field item, or null if it is not an image we can convert.
     */
    private static SummitFieldItem toFieldItem(String url) {

        String cvId = extractId(url, 'versionId=', '068') ?? extractId(url, '/version/download/', '068');
        if(cvId != null && (cvId.length() == 15 || cvId.length() == 18)) {
            SummitFieldItem sfi = new SummitFieldItem();
            sfi.url = url;
            sfi.cvId = (Id) cvId;
            return sfi;
        }

        if(url.contains('rtaImage')) {
            String refId = extractId(url, 'refid=', '0EM');
            if(refId != null && (refId.length() == 15 || refId.length() == 18)) {
                SummitFieldItem sfi = new SummitFieldItem();
                sfi.url = url;
                sfi.refId = refId;
                return sfi;
            }
        }
        return null;
    }

    /**
     * Read the alphanumeric run that follows lead + prefix in a URL, for example
     * versionId=068xxxx (lead 'versionId=') or /version/download/068xxxx.
     */
    private static String extractId(String url, String lead, String prefix) {

        Integer leadIdx = url.indexOf(lead + prefix);
        if (leadIdx == -1) {
            return null;
        }

        Integer idStart = leadIdx + lead.length();
        Integer i = idStart;
        while (i < url.length() && ALPHANUMERICS.indexOf(url.substring(i, i + 1)) != -1) {
            i++;
        }
        return url.substring(idStart, i);
    }

    // Simple wrapper to aggregate relevant values we'll use
    private class RecordWrapper {
        SObject record;
        Set<String> fieldsWithLinks;
        Map<String,List<SummitFieldItem>> fieldsToLinkMap;

        private RecordWrapper() { 
            this.fieldsWithLinks = new Set<String>(); 
            this.fieldsToLinkMap = new Map<String,List<SummitFieldItem>>();
        }
    }

    private class SummitFieldItem {
        String url;
        Id cvId;      // set for ContentVersion links, or once an RTE image has been stored as a file
        String refId; // set for rich text editor images (0EM...) until they are stored
        private SummitFieldItem() {}
    }

    private class FetchedImage {
        Id recordId;
        String recordName;
        String extension;
        Blob body;
    }
}
