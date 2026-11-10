/**
 * Makes images embedded in Summit_Events__c rich text fields publicly viewable by
 * guest users without granting guests access to event records.
 *
 * Two kinds of embedded images are handled:
 * 1. ContentVersion links (versionId=068...), e.g. pasted from a Files preview.
 *    These are converted synchronously.
 * 2. Rich text editor uploads (/servlet/rtaImage?...refid=0EM...). Their bytes are only
 *    reachable through the REST API, which needs a callout, so they are handled in
 *    {@link SummitEventsRtaImageQueueable}.
 *
 * Either way the image ends up as a ContentVersion with a ContentDistribution, and the
 * img src is rewritten to the distribution's ContentDownloadUrl. (DistributionPublicUrl is
 * an HTML viewer page and cannot be used as an image source.)
 *
 * Runs as the user who saved the event, in user mode. Guests never touch this code: the
 * registration data model is master-detail all the way down, so guests cannot be given record
 * access to events, which is exactly why images must be made public instead.
 *
 * Security and Code Analyzer notes
 * - with sharing, and every query and DML statement is USER_MODE. The editor needs read access to
 *   the event fields and to any file they link, plus file create and public-link access (see the
 *   Summit_Events_Admin permission set). If they lack any of it the operation fails closed and the
 *   field is left unchanged. The single exception is notificationTypeId(), a system-mode lookup of
 *   our own notification type's Id so failures can be reported to ordinary editors.
 * - Failures are reported to the editor with an in-app notification of fixed, translatable
 *   messages (Custom Labels). Raw exception text is never shown or sent.
 * - A ContentVersion link is only converted when the editor can read that file (checked in
 *   prepare()) and it is an image. This stops an editor publishing a private or non-image file by
 *   pasting its Id into an img tag.
 * - filter() only reads and rewrites rich text fields the user can update.
 * - Only allowlisted image content types are ever stored and made public.
 * - ApexSOQLInjection was a false positive on the dynamic query in filter(): the only concatenated
 *   parts are the namespace prefix and field names from the RICHTEXT_FIELDS allowlist, and record
 *   Ids are passed as a bind variable.
 * - ApexSuggestUsingNamedCred is intentionally suppressed in fetchImage(); see the note there.
 */
public with sharing class SummitEventsRtfLinkPipeline {

    // Inelegant, but schema introspection can't differentiate RTF from regular text fields
    private static final Set<String> RICHTEXT_FIELDS = new Set<String>{
        'Event_Full_Text__c', 'Event_Confirmation_Description__c',
        'Event_Additional_Questions_Description__c', 
        'Event_Appointment_Description__c', 'Event_Footer__c', 
        'Event_Submit_Description__c', 'Event_Cancel_Review_Description__c',
        'Event_Payment_Due_Description__c', 'Event_Payment_Received_Description__c',
        'Event_description__c', 'Donation_Description__c', 
        'Guest_Registration_Description__c'
    };

    private static final String namespace = SummitEventsNamespace.StrTokenNSPrefix('');
    private static final String NOTIFICATION_TYPE = 'Summit_Events_Image_Publishing';
    private static final String CV_MARKER = 'versionId=068';
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
    private static List<Summit_Events__c> eventOverrides;

    // File extensions we are willing to publish
    private static final Set<String> IMAGE_FILE_EXTENSIONS = new Set<String>{
        'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'
    };

    private Map<Id,ContentDistribution> cvIdToCDMap;
    private Set<Id> publishableCvIds = new Set<Id>();
    // Fixed, translatable messages for the person who saved the event; never raw exception text
    private Set<String> problems = new Set<String>();
    private List<SummitEventWrapper> wrappedEventList;
    private List<Id> idList;
    private String executionStage;
    private Boolean hasDeferredImages = false;
    private Integer filesCreated = 0;
    
    public SummitEventsRtfLinkPipeline(Map<Id,Summit_Events__c> newMap) {
        this(new List<Id>(newMap.keySet()));
    }

    public SummitEventsRtfLinkPipeline(List<Id> eventIds) {
        this.cvIdToCDMap = new Map<Id,ContentDistribution>();
        this.wrappedEventList = new List<SummitEventWrapper>();
        this.idList = eventIds;
    }

    /**
     * Trigger-time entry point. Converts ContentVersion links now and hands any
     * rich text editor uploads to a Queueable.
     */
    public void run() {
        this.executionStage = 'run';
        try {
            filter();
            scan();
            prepare();
            create();
            push();
            enqueueRtaImages();
        } catch(Exception e) {
            this.problems.add(Label.SummitEventsImageNotifFailed);
        }
        notifyProblems();
    }

    /**
     * Async entry point, called from {@link SummitEventsRtaImageQueueable}. Fetches
     * rich text editor images, stores them as files, and rewrites the fields.
     * @return true when more images remain and another job should be chained
     */
    public Boolean runAsync() {
        this.executionStage = 'runAsync';
        Boolean hasMore = false;
        try {
            filter();
            scan();
            fetch();
            prepare();
            create();
            push();
            hasMore = this.hasDeferredImages && this.filesCreated > 0;
        } catch(Exception e) {
            this.problems.add(Label.SummitEventsImageNotifFailed);
        }
        notifyProblems();
        return hasMore;
    }

    /**
     * Cheap first-pass filter to select and wrap Summit_Events__c records
     * that have RTF fields with embedded images we can convert.
     */
    @TestVisible
    private void filter() {

        this.executionStage = 'filter';

        List<Summit_Events__c> freshEventList = new List<Summit_Events__c>();
        List<String> fields = new List<String>();
        String query = '';

        Summit_Events__c schemaObject = new Summit_Events__c();
        Map<String,SObjectField> fieldMap = 
            schemaObject
                .getSObjectType()
                .getDescribe()
                .fields
                .getMap();

        for(String field : RICHTEXT_FIELDS) {

            Boolean isUpdateable = fieldMap.get(namespace + field).getDescribe().isUpdateable();
            
            if(isUpdateable) {
                fields.add(namespace + field);
            }
        }

        if(fields.isEmpty()) {
            // The user cannot update any of the rich text fields, so there is nothing we may rewrite.
            // wrappedEventList stays empty, which makes every later stage a no-op.
            return;
        }

        // Safe dynamic SOQL: field names come from the RICHTEXT_FIELDS allowlist (plus the package
        // namespace) and the Ids are bound below. No user-controlled text reaches the query string.
        String fieldList = String.join(fields, ', ');
        query = 'SELECT Name, ' + fieldList + ' FROM ' + namespace + 'Summit_Events__c WHERE Id IN :idList';
        if(eventOverrides == null) {
            Map<String,Object> binds = new Map<String,Object>{ 'idList' => idList };
            freshEventList = Database.queryWithBinds(query, binds, System.AccessLevel.USER_MODE);
        } else {
            // Test seam: the platform strips rtaImage tags it cannot tie to a real upload, so tests
            // cannot save realistic rich text and supply it here instead
            Set<Id> requestedIds = new Set<Id>(idList);
            for(Summit_Events__c stagedEvent : eventOverrides) {
                if(requestedIds.contains(stagedEvent.Id)) {
                    freshEventList.add(stagedEvent);
                }
            }
        }

        for(Summit_Events__c freshEvent : freshEventList) {
            SummitEventWrapper wrappedEvent = new SummitEventWrapper();
            for (String field : fields) {
                String fieldVal = (String) freshEvent?.get(field);
                if(!String.isBlank(fieldVal) && fieldVal.contains('<img') 
                    && (fieldVal.contains(CV_MARKER) || fieldVal.contains(RTA_MARKER))) {
                    wrappedEvent.fieldsWithLinks.add(field);
                }
            }
            if(!wrappedEvent.fieldsWithLinks.isEmpty()) {
                wrappedEvent.event = freshEvent;
                this.wrappedEventList.add(wrappedEvent);
            }
        } 
    }

    /**
     * Scan through wrapped events and find every convertible image: either a
     * ContentVersion Id or a rich text editor image reference (0EM...).
     * Pattern and Matcher would have less cognitive overhead, but they
     * come attached to significant time complexity, so we're going to
     * roll our own manual string ops. Even without direct access to char
     * arrays, this should still be O(n). 
     */
    @TestVisible
    private void scan() {
        
        this.executionStage = 'scan';

        for (SummitEventWrapper wrappedEvent : wrappedEventList) {
            Map<String, List<SummitFieldItem>> tempMap = new Map<String, List<SummitFieldItem>>();
        
            for (String field : wrappedEvent.fieldsWithLinks) {
                String html = (String) wrappedEvent.event.get(field);
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
            wrappedEvent.fieldsToLinkMap = tempMap;
        }
    }

    /**
     * Fetch rich text editor images through the REST API and store each as a file
     * owned by its event. This is the only stage that makes callouts, so it must run
     * in an async context, and all callouts must finish before any DML.
     */
    @TestVisible
    private void fetch() {

        this.executionStage = 'fetch';

        Map<String,FetchedImage> imageByRefId = new Map<String,FetchedImage>();
        Set<String> attempted = new Set<String>();
        Integer totalBytes = 0;

        for(SummitEventWrapper wrappedEvent : wrappedEventList) {
            for(String field : wrappedEvent.fieldsToLinkMap.keySet()) {
                for(SummitFieldItem sfi : wrappedEvent.fieldsToLinkMap.get(field)) {
                    if(sfi.refId == null || attempted.contains(sfi.refId)) {
                        continue;
                    }
                    if(attempted.size() >= MAX_RTA_IMAGES_PER_JOB || totalBytes >= MAX_RTA_BYTES_PER_JOB
                        || Limits.getCallouts() >= Limits.getLimitCallouts()) {
                        this.hasDeferredImages = true;
                        continue;
                    }
                    attempted.add(sfi.refId);
                    FetchedImage image = fetchImage(wrappedEvent.event, field, sfi.refId);
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
                Title = (image.eventName + ' - ' + refId).left(240),
                PathOnClient = refId + '.' + image.extension,
                VersionData = image.body,
                FirstPublishLocationId = image.eventId,
                IsMajorVersion = true
            ));
        }
        Database.insert(versionList, true, System.AccessLevel.USER_MODE);
        this.filesCreated = versionList.size();

        Map<String,Id> cvIdByRefId = new Map<String,Id>();
        for(Integer i = 0; i < refIds.size(); i++) {
            cvIdByRefId.put(refIds[i], versionList[i].Id);
        }

        // From here on the image is just another ContentVersion link
        for(SummitEventWrapper wrappedEvent : wrappedEventList) {
            for(List<SummitFieldItem> items : wrappedEvent.fieldsToLinkMap.values()) {
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
        for(SummitEventWrapper wrappedEvent : wrappedEventList) {
            for(String field : wrappedEvent.fieldsToLinkMap.keySet()) {
                for(SummitFieldItem sfi : wrappedEvent.fieldsToLinkMap.get(field)) {
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
                   ContentVersionId
            FROM   ContentDistribution
            WHERE  ContentVersionId IN :this.publishableCvIds
            WITH   USER_MODE
        ];

        for(ContentDistribution cd : cdList) {
            this.cvIdToCDMap.put(cd.ContentVersionId, cd);
        }
    }

    /**
     * Create ContentDistribution records for any ContentVersion records
     * that are not already linked to a ContentDistribution record.
     */
    @TestVisible
    private void create() {

        this.executionStage = 'create';

        List<ContentDistribution> cdInsertList = new List<ContentDistribution>();
        Set<Id> visited = new Set<Id>();
        
        for(SummitEventWrapper wrappedEvent : wrappedEventList) {
            for(String field : wrappedEvent.fieldsToLinkMap.keySet()) {
                Integer i = 0;
                for(SummitFieldItem sfi : wrappedEvent.fieldsToLinkMap.get(field)) {
                    if(publishableCvIds.contains(sfi.cvId) && !cvIdToCDMap.containsKey(sfi.cvId) && !visited.contains(sfi.cvId)) {
                        ContentDistribution cd = new ContentDistribution();
                        cd.ContentVersionId = sfi.cvId;
                        cd.Name = (wrappedEvent.event.Name + ' - ' + field + i++).left(100); // Name max is 100
                        cdInsertList.add(cd);
                        visited.add(sfi.cvId);
                    }
                }
            }
        }

        if(!cdInsertList.isEmpty()) {
            Database.insert(cdInsertList, true, System.AccessLevel.USER_MODE);

            List<ContentDistribution> refreshed = [
                SELECT Id, 
                       ContentDownloadUrl,
                       Name, 
                       ContentVersionId  
                FROM   ContentDistribution 
                WHERE  Id IN :cdInsertList
                WITH   USER_MODE
            ];

            for(ContentDistribution cd : refreshed) {
                cvIdToCDMap.put(cd.ContentVersionId, cd);
            }
        }
    }

    /**
     * Replace all converted URLs in the RTF fields with the corresponding ContentDistribution
     * record's ContentDownloadUrl (the direct file URL; DistributionPublicUrl is an HTML viewer
     * page that cannot be used in an img tag), and update the Summit_Events__c record.
     */
    @TestVisible
    private void push() { 

        this.executionStage = 'push';

        List<Summit_Events__c> updateList = new List<Summit_Events__c>();

        for(SummitEventWrapper wrappedEvent : wrappedEventList) {
            Summit_Events__c tempEvent = new Summit_Events__c();
            tempEvent.Id = wrappedEvent.event.Id; // trigger records are immutable, we must create new records
            Boolean changed = false;
            for(String field : wrappedEvent.fieldsWithLinks) {
                String rtf = (String) wrappedEvent.event.get(field);
                String original = rtf;
                for(SummitFieldItem sfi : wrappedEvent.fieldsToLinkMap.get(field) ?? new List<SummitFieldItem>()) {
                    ContentDistribution cd = sfi.cvId == null ? null : cvIdToCDMap.get(sfi.cvId);
                    if(cd != null) {
                        rtf = rtf.replace(sfi.url, cd.ContentDownloadUrl);
                    }
                }
                if(rtf != original) {
                    tempEvent.put(field,rtf);
                    changed = true;
                }
            }
            if(changed) {
                updateList.add(tempEvent);
            }
        }

        if(!updateList.isEmpty()) {
            this.executionStage = 'push.DML';
            Database.update(updateList, true, System.AccessLevel.USER_MODE);
        }
     }

    /**
     * Queue one async job for every event that still has rich text editor images
     * waiting to be converted. Never enqueues from inside a Queueable, so the update
     * made by the job cannot start another job.
     */
    private void enqueueRtaImages() {

        this.executionStage = 'enqueue';

        if(System.isQueueable() || Limits.getQueueableJobs() >= Limits.getLimitQueueableJobs()) {
            return;
        }

        Set<Id> pendingEventIds = new Set<Id>();
        for(SummitEventWrapper wrappedEvent : wrappedEventList) {
            for(List<SummitFieldItem> items : wrappedEvent.fieldsToLinkMap.values()) {
                for(SummitFieldItem sfi : items) {
                    if(sfi.refId != null && sfi.cvId == null) {
                        pendingEventIds.add(wrappedEvent.event.Id);
                    }
                }
            }
        }

        if(!pendingEventIds.isEmpty()) {
            System.enqueueJob(new SummitEventsRtaImageQueueable(new List<Id>(pendingEventIds)));
        }
    }

    private void notifyProblems() {
        if(!this.problems.isEmpty() && this.idList != null && !this.idList.isEmpty()) {
            notifyUser(this.idList[0], this.problems);
        }
    }

    /**
     * Tell the user who saved the event that something was not published, with an in-app
     * (bell) notification that opens the event. Best effort: failing to notify must never
     * stop an event from saving, and only fixed messages are sent, never exception text.
     * @param targetId the event the notification should open
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
    @TestVisible
    private static Id notificationTypeId() {
        List<CustomNotificationType> types = [
            SELECT Id
            FROM   CustomNotificationType
            WHERE  DeveloperName = :NOTIFICATION_TYPE
            WITH   SYSTEM_MODE
            LIMIT  1
        ];
        return types.isEmpty() ? null : types[0].Id;
    }

    /**
     * Download one rich text editor image via the REST API using the running user's session.
     * @return the image, or null if it could not be fetched or is not an allowed image type
     */
    private FetchedImage fetchImage(Summit_Events__c event, String field, String refId) {

        HttpRequest request = new HttpRequest();
        request.setEndpoint(
            URL.getOrgDomainUrl().toExternalForm()
            + '/services/data/' + REST_VERSION
            + '/sobjects/' + namespace + 'Summit_Events__c/' + event.Id
            + '/richTextImageFields/' + field + '/' + refId
        );
        request.setMethod('GET');
        // Code Analyzer ApexSuggestUsingNamedCred is a false positive here. This calls the org's own
        // REST API as the user who saved the record, so the running user's session is the right
        // credential and it works with no per-org setup. A Named Credential would need an
        // External Credential, a Connected App/OAuth flow and a permission set assigned in every
        // subscriber org, and it would run as a fixed identity instead of the editing user.
        // The session ID is only ever sent to this org's own My Domain URL built above.
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
        image.eventId = event.Id;
        image.eventName = event.Name;
        image.extension = IMAGE_EXTENSIONS.get(contentType);
        image.body = body;
        return image;
    }

    /**
     * Turn an img src into a field item, or null if it is not an image we can convert.
     */
    private static SummitFieldItem toFieldItem(String url) {

        String cvId = extractId(url, 'versionId', '068');
        if(cvId != null && (cvId.length() == 15 || cvId.length() == 18)) {
            SummitFieldItem sfi = new SummitFieldItem();
            sfi.url = url;
            sfi.cvId = (Id) cvId;
            return sfi;
        }

        if(url.contains('rtaImage')) {
            String refId = extractId(url, 'refid', '0EM');
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
     * Read the alphanumeric run following key=prefix in a URL, e.g. versionId=068xxxx.
     */
    private static String extractId(String url, String key, String prefix) {

        Integer keyIdx = url.indexOf(key + '=' + prefix);
        if (keyIdx == -1) {
            return null;
        }

        Integer idStart = keyIdx + key.length() + 1;
        Integer i = idStart;
        while (i < url.length() && ALPHANUMERICS.indexOf(url.substring(i, i + 1)) != -1) {
            i++;
        }
        return url.substring(idStart, i);
    }

    // Simple wrapper to aggregate relevant values we'll use
    private class SummitEventWrapper {
        Summit_Events__c event;
        Set<String> fieldsWithLinks;
        Map<String,List<SummitFieldItem>> fieldsToLinkMap;

        private SummitEventWrapper() { 
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
        Id eventId;
        String eventName;
        String extension;
        Blob body;
    }
}
