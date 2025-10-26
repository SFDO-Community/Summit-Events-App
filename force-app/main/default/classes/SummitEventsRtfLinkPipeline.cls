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
    
    private Map<Id,ContentDistribution> cvIdToCDMap;
    private List<SummitEventWrapper> sewList;
    private List<Id> idList;
    private String executionStage;
    
    public SummitEventsRtfLinkPipeline(Map<Id,SObject> newmap) {
        this.cvIdToCDMap = new Map<Id,ContentDistribution>();
        this.sewList = new List<SummitEventWrapper>();
        this.idList = new List<Id>(newmap.keySet());
        newmap = null; // prayer to GC gods; likely superstition
    }

    public void run() {
        this.executionStage = 'run';
        try {
            filter();
            scan();
            prepare();
            create();
            push();
        } catch(Exception e) {
            System.debug('Pipeline failed at stage ' + this.executionStage + ': ' + e.getMessage());
        }
    }

    /**
     * Cheap first-pass filter to select and wrap Summit_Events__c records
     * that have RTF fields with links to ContentVersion records.
     */
    private void filter() {

        this.executionStage = 'filter';

        List<Summit_Events__c> seList = new List<Summit_Events__c>();
        List<String> fields = new List<String>();
        String query = '';

        for(String f : RICHTEXT_FIELDS) {
            fields.add(namespace + f);
        }
	    
        String fieldList = String.join(fields, ', ');
        query = 'SELECT Name, ' + fieldList + ' FROM ' + namespace + 'Summit_Events__c WHERE Id IN :idList';
        seList = Database.query(query);
        // this.idList.clear();

        for(Summit_Events__c se : seList) {
            SummitEventWrapper sew = new SummitEventWrapper();
            for (String s : RICHTEXT_FIELDS) {
                String fieldName = namespace + s;
                String fieldVal = (String) se?.get(fieldName);
                if(!String.isBlank(fieldVal) && fieldVal.contains('<img src=') && fieldVal.contains('versionId=068')) {
                    sew.fieldsWithLinks.add(fieldName);
                }
            }
            if(!sew.fieldsWithLinks.isEmpty()) {
                sew.event = se;
                this.sewList.add(sew);
                // this.idList.add(se.Id);
            }
        } 
    }

    /**
     * scan through wrapped events and find all the ContentVersion Ids.
     * Pattern and Matcher would have less cognitive overhead, but they
     * come attached to significant time complexity, so we're going to
     * roll our own manual string ops. Even without direct access to char
     * arrays, this should still be O(n). 
     */
    private void scan() {
        
        this.executionStage = 'scan';

        for (SummitEventWrapper sew : sewList) {
            Map<String, List<SummitFieldItem>> tempMap = new Map<String, List<SummitFieldItem>>();
        
            for (String field : sew.fieldsWithLinks) {
                String html = (String) sew.event.get(field);
                List<SummitFieldItem> items = new List<SummitFieldItem>();
            
                Integer pos = 0;
                while (true) {
                    // Find the next <img src="...">
                    Integer tagStart = html.indexOf('<img', pos);
                    if (tagStart == -1) break;
                
                    Integer srcStart = html.indexOf('src="', tagStart);
                    if (srcStart == -1) break;
                
                    srcStart += 5; // past src="
                    Integer srcEnd = html.indexOf('"', srcStart);
                    if (srcEnd == -1) break;
                
                    String url = html.substring(srcStart, srcEnd);
                    pos = srcEnd + 1;
                
                    // Look for versionId
                    Integer idIdx = url.indexOf('versionId=068');
                    if (idIdx == -1) continue;
                
                    Integer idStart = idIdx + 'versionId='.length();
                    Integer i = idStart;
                    while (i < url.length() && 
                           'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'.indexOf(url.substring(i, i + 1)) != -1) {
                        i++;
                    }
                
                    String possibleId = url.substring(idStart, i);
                    if (possibleId.startsWith('068')) {
                        SummitFieldItem sfi = new SummitFieldItem();
                        sfi.cvId = (Id) possibleId;
                        sfi.url = url;
                        items.add(sfi);
                    }
                }
            
                if (!items.isEmpty()) {
                    tempMap.put(field, items);
                }
            }
            sew.fieldsToLinkMap = tempMap;
        }
    }
    
    /**
     * Prepare the pipeline for execution; populate some final values
     * we'll need for execution.
     */
    private void prepare() {

        this.executionStage = 'prepare';

        Set<Id> cvIdSet = new Set<Id>();
        for(SummitEventWrapper sew : sewList) {
            for(String field : sew.fieldsToLinkMap.keySet()) {
                for(SummitFieldItem sfi : sew.fieldsToLinkMap.get(field)) {
                    cvIdSet.add(sfi.cvId);
                }
            }
        }

        List<ContentDistribution> cdList = [
            SELECT Id,
                   DistributionPublicUrl,
                   Name,
                   ContentVersionId
            FROM   ContentDistribution
            WHERE  ContentVersionId IN :cvIdSet
        ];

        for(ContentDistribution cd : cdList) {
            this.cvIdToCDMap.put(cd.ContentVersionId, cd);
        }
    }

    /**
     * Create ContentDistribution records for any ContentVersion records
     * that are not already linked to a ContentDistribution record.
     */
    private void create() {

        this.executionStage = 'create';

        List<ContentDistribution> cdInsertList = new List<ContentDistribution>();
        
        for(SummitEventWrapper sew : sewList) {
            for(String field : sew.fieldsToLinkMap.keySet()) {
                Integer i = 0;
                for(SummitFieldItem sfi : sew.fieldsToLinkMap.get(field)) {
                    if(!cvIdToCDMap.containsKey(sfi.cvId)) {
                        ContentDistribution cd = new ContentDistribution();
                        cd.ContentVersionId = sfi.cvId;
                        cd.Name = sew.event.Name + ' - ' + field + i++;
                        cdInsertList.add(cd);
                    }
                }
            }
        }

        if(!cdInsertList.isEmpty()) {
            insert cdInsertList;

            List<ContentDistribution> refreshed = [
                SELECT Id, 
                       DistributionPublicUrl,
                       Name, 
                       ContentVersionId  
                FROM   ContentDistribution 
                WHERE  Id IN :cdInsertList
            ];

            for(ContentDistribution cd : refreshed) {
                cvIdToCDMap.put(cd.ContentVersionId, cd);
            }
        }
    }

    /**
     * Replace all URLs in the RTF fields with the corresponding ContentDistribution
     * record's DistributionPublicUrl, and update the Summit_Events__c record.
     */
    private void push() { 

        this.executionStage = 'push';

        for(SummitEventWrapper sew : sewList) {
            Summit_Events__c se = new Summit_Events__c();
            se.Id = sew.event.Id;
            for(String field : sew.fieldsWithLinks) {
                String rtf = (String) sew.event.get(field);
                for(SummitFieldItem sfi : sew.fieldsToLinkMap.get(field)) {
                    rtf = rtf.replace(sfi.url, cvIdToCDMap.get(sfi.cvId).DistributionPublicUrl);
                }
                se.put(field,rtf);
            }
            update se; // DML in loop; intentional workaround for potentially enormous record heap size
        }
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
        Id cvId;
        private SummitFieldItem() {}
    }
}