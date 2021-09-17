public class SummitEventsAfterLeadConversion {
    public static void afterUpdate(List<Lead> newLeads){
        updateEventsOnConvert(newLeads);
    }
    
    static void updateEventsOnConvert(List<Lead> newLeads){
        List<Lead> converted = new List<Lead>();
        for (Lead l : newLeads){
            if (l.isConverted)
                converted.add(l);
        }
        
        if (!converted.isEmpty()){
            List<Summit_Events_Registration__c> registrations = [SELECT Id, Lead__c, Matching_Log__c
                                                                 FROM Summit_Events_Registration__c
                                                                 WHERE Lead__c IN :converted AND Contact__c = NULL];
            Map<Id, Lead> leadMap = new Map<Id, Lead>(converted);
            
            for (Summit_Events_Registration__c reg : registrations){
                reg.Contact__c = leadMap.get(reg.Lead__c).ConvertedContactId;
                reg.Matching_Log__c += '<hr>Lead converted to Contact - ' + System.now();
            }
            
            update registrations;
        }
    }
}