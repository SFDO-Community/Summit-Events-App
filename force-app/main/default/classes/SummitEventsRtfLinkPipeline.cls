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
        this.idList = new List<Id>(newmap.keySet());
        newmap = null;
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

    private void filter() {

        this.executionStage = 'filter';
        this.sewList = new List<SummitEventWrapper>();

        List<Summit_Events__c> seList = new List<Summit_Events__c>();
        List<String> fields = new List<String>();
        String query = '';

        for(String f : RICHTEXT_FIELDS) {
            fields.add(namespace + f);
        }
	    
        String fieldList = String.join(fields, ', ');
        query = 'SELECT ' + fieldList + ' FROM ' + namespace + 'Summit_Events__c WHERE Id IN :this.idList';
        seList = Database.query(query);
        // this.idList.clear();

        for(Summit_Events__c se : seList) {
            SummitEventWrapper sew = new SummitEventWrapper();
            for (String s : RICHTEXT_FIELDS) {
                String fieldName = namespace + s;
                String fieldVal = (String) se?.get(fieldName);
                if(!String.isBlank(fieldVal) && fieldVal.contains('<img src=') && fieldVal.contains('/sfc/servlet.shepherd/version/download/')) {
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

    private void scan() {
        
        this.executionStage = 'scan';

        for(SummitEventWrapper sew : sewList) {
            Map<String, List<SummitFieldItem>> tempMap = new Map<String, List<SummitFieldItem>>();

            for(String field : sew.fieldsWithLinks) {
                String rtf = (String) sew.event.get(field);
                List<SummitFieldItem> itemList = new List<SummitFieldItem>();

                Integer searchStart = 0;
                while (true) {
                    Integer imgStart = rtf.indexOf('<img src=', searchStart);
                    if (imgStart == -1) {
                        break;
                    }

                    Integer urlStart = imgStart + '<img src="'.length();
                    Integer urlEnd = rtf.indexOf('"', urlStart);
                    if (urlEnd == -1) {
                        break;
                    }

                    String url = rtf.substring(urlStart, urlEnd);
                    SummitFieldItem sfi = new SummitFieldItem();

                    Integer pathIdx = url.indexOf('/sfc/servlet.shepherd/version/download/');
                    if (pathIdx != -1) {
                        Integer idStart = pathIdx + '/sfc/servlet.shepherd/version/download/'.length();

                        Integer i = idStart;
                        while (i < url.length()) {
                            String ch = url.substring(i, i + 1);
                            if ('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'.indexOf(ch) == -1) {
                                break;
                            }
                            i++;
                        }
                        
                        String possibleId = url.substring(idStart, i);

                        // 068 is the prefix for ContentVersion; stable and unlikely to change
                        if (possibleId.startsWith('068')) { 
                            try {
                                sfi.cvId = (Id) possibleId;
                            } catch (Exception e) {
                                System.debug(e.getMessage());
                            }
                        }
                    }
                    
                    sfi.url = url;
                    itemList.add(sfi);

                    searchStart = urlEnd + 1;
                }

                if(!itemList.isEmpty()) {
                    tempMap.put(field, itemList);
                }
            }
            sew.fieldsToLinkMap = tempMap;
        }
    }
    
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

        this.cvIdToCDMap = new Map<Id,ContentDistribution>();

        for(ContentDistribution cd : cdList) {
            this.cvIdToCDMap.put(cd.ContentVersionId, cd);
        }
    }

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