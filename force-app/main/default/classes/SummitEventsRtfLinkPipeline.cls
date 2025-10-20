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
    
    Map<Id,ContentDistribution> cvIdToCDMap;
    Map<Id,ContentDistribution> cdIdMap;
    private List<SummitEventWrapper> sewList;
    private List<Id> idList;
    List<ContentDistribution> refreshed;
    private String executionStage;
    
    public SummitEventsRtfLinkPipeline(Map<Id,SObject> newmap) {
        this.idList = new List<Id>(newmap.keySet());
        newmap = null;
    }

    public void run() {
        try {
            filter();
            scan();
            
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
        ContentVersion cv;
        ContentDistribution cd;
        private SummitFieldItem() {}
    }
}