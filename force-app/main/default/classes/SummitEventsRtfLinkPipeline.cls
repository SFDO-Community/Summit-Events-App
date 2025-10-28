public without sharing class SummitEventsRtfLinkPipeline {
    
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
    private List<SummitEventWrapper> wrappedEventList;
    private List<Id> idList;
    private String executionStage;
    
    public SummitEventsRtfLinkPipeline(Map<Id,Summit_Events__c> newMap) {
        this.cvIdToCDMap = new Map<Id,ContentDistribution>();
        this.wrappedEventList = new List<SummitEventWrapper>();
        this.idList = new List<Id>(newMap.keySet());
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
    @TestVisible
    private void filter() {

        this.executionStage = 'filter';

        List<Summit_Events__c> freshEventList = new List<Summit_Events__c>();
        List<String> fields = new List<String>();
        String query = '';

        for(String field : RICHTEXT_FIELDS) {
            fields.add(namespace + field);
        }
	    
        String fieldList = String.join(fields, ', ');
        query = 'SELECT Name, ' + fieldList + ' FROM ' + namespace + 'Summit_Events__c WHERE Id IN :idList';
        freshEventList = Database.query(query);

        for(Summit_Events__c freshEvent : freshEventList) {
            SummitEventWrapper wrappedEvent = new SummitEventWrapper();
            for (String field : fields) {
                String fieldVal = (String) freshEvent?.get(field);
                if(!String.isBlank(fieldVal) && fieldVal.contains('<img src=') && fieldVal.contains('versionId=068')) {
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
     * Scan through wrapped events and find all the ContentVersion Ids.
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
                    if (tagStart == -1) 
                        break;
                
                    Integer srcStart = html.indexOf('src="', tagStart);
                    if (srcStart == -1) 
                        break;
                
                    srcStart += 5; // past src="
                    Integer srcEnd = html.indexOf('"', srcStart);
                    if (srcEnd == -1) 
                        break;
                
                    String url = html.substring(srcStart, srcEnd);
                    pos = srcEnd + 1;
                
                    // Look for versionId
                    Integer idIdx = url.indexOf('versionId=068');
                    if (idIdx == -1) 
                        continue;
                
                    Integer idStart = idIdx + 'versionId='.length();
                    Integer i = idStart;
                    String alphaNumerics = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
                    while (i < url.length() && alphaNumerics.indexOf(url.substring(i, i + 1)) != -1)
                        i++;
                
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
            wrappedEvent.fieldsToLinkMap = tempMap;
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
    @TestVisible
    private void create() {

        this.executionStage = 'create';

        List<ContentDistribution> cdInsertList = new List<ContentDistribution>();
        Set<Id> visited = new Set<Id>();
        
        for(SummitEventWrapper wrappedEvent : wrappedEventList) {
            for(String field : wrappedEvent.fieldsToLinkMap.keySet()) {
                Integer i = 0;
                for(SummitFieldItem sfi : wrappedEvent.fieldsToLinkMap.get(field)) {
                    if(!cvIdToCDMap.containsKey(sfi.cvId) && !visited.contains(sfi.cvId)) {
                        ContentDistribution cd = new ContentDistribution();
                        cd.ContentVersionId = sfi.cvId;
                        cd.Name = wrappedEvent.event.Name + ' - ' + field + i++;
                        cdInsertList.add(cd);
                        visited.add(sfi.cvId);
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
    @TestVisible
    private void push() { 

        this.executionStage = 'push';

        List<Summit_Events__c> updateList = new List<Summit_Events__c>();

        for(SummitEventWrapper wrappedEvent : wrappedEventList) {
            Summit_Events__c tempEvent = new Summit_Events__c();
            tempEvent.Id = wrappedEvent.event.Id; // trigger records are immutable, we must create new records
            for(String field : wrappedEvent.fieldsWithLinks) {
                String rtf = (String) wrappedEvent.event.get(field);
                for(SummitFieldItem sfi : wrappedEvent.fieldsToLinkMap.get(field)) {
                    rtf = rtf.replace(sfi.url, cvIdToCDMap.get(sfi.cvId).DistributionPublicUrl);
                }
                tempEvent.put(field,rtf);
            }
            updateList.add(tempEvent);
        }

        if(!updateList.isEmpty()) {
            this.executionStage = 'push.DML';
            update updateList;
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