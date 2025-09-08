@isTest
public with sharing class SummitEventsMapController_TEST {
    @isTest
	public static void getSummitEventsRegistrants_givenRegistrant_shouldReturnRegistrant() {
		SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@example.net', '55418', '(555) 555-5555', '1971-03-22');
		List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@example.net', '55418', '1971-03-22', '2012', null);
		seaTestRegistration.Registrant_City__c = 'Example';
		seaTestRegistration.Registrant_State__c = 'KS';
		update seaTestRegistration;

		Test.startTest();
		List<Summit_Events_Registration__c> registrants = SummitEventsMapController.getSummitEventsRegistrants(seaTestInstances[1].Id);
		Test.stopTest();
		
		Assert.areEqual(1, registrants.size(), 'There should be one registrant returned');
	}
}