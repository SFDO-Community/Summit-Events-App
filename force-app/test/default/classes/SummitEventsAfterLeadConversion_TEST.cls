@isTest
public class SummitEventsAfterLeadConversion_TEST {
    @isTest
    static void testLeadConversion() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);
        seaTestEvent.Contact_Matching_No_Match_Behavior__c = null;
        seaTestEvent.Lead_Matching_Rules__c = 'Use Salesforce Duplicate Rule';
        seaTestEvent.Lead_Creation_Duplicate_Rule__c = 'Standard Lead Duplicate Rule';
        seaTestEvent.Lead_Matching_No_Match_Behavior__c = 'Create Lead';
        seaTestEvent.Lead_Matching_Multiple_Match_Behavior__c = 'Match with most recently modified';
        seaTestEvent.Custom_Metadata_Lead_Matching_Method__c = 'Red';
        update seaTestEvent;

        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Record', 'test@example.com', '55555', '1971-03-22', '2012', null);
        seaTestRegistration.Status__c = 'Registered';
        seaTestRegistration.Registrant_Preferred_First_Name__c = 'Big T';
        update seaTestRegistration;

        Lead testLead = [SELECT Id FROM Lead];

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.id);
        lc.setConvertedStatus('Closed - Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
    }
}