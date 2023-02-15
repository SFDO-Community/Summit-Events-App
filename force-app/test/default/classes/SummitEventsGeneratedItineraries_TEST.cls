/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/15/2023.
 */


@IsTest
private class SummitEventsGeneratedItineraries_TEST {

    @IsTest
    static void testBehavior() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Tester', 'test@test.net', '55555', '1971-03-22', '2012', null);
        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);

        seaTestRegistration.Generated_Requested_Appointments__c = 'TEST REQUESTED';
        seaTestRegistration.Generated_Itinerary__c = 'TEST CONFIRMED';
        update seaTestRegistration;

        ApexPages.StandardController sc = new ApexPages.StandardController(seaTestRegistration);
        SummitEventsGeneratedItinerariesExt itineraryExt = new SummitEventsGeneratedItinerariesExt(sc);

        Test.startTest();
        System.assertEquals(itineraryExt.generatedItinerary, 'TEST CONFIRMED');
        System.assertEquals(itineraryExt.requestedItinerary, 'TEST REQUESTED');
        Test.stopTest();
    }
}