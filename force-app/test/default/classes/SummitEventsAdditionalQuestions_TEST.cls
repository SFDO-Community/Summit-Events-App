/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 8/18/2021.
 */


@IsTest
private class SummitEventsAdditionalQuestions_TEST {
    @IsTest
    static void noDataController() {
        Test.startTest();
        SummitEventsAdditionalQuestionsCtlr questionController = new SummitEventsAdditionalQuestionsCtlr();
        System.assertEquals(JSON.serialize(questionController.eventInformation), '{"registrationId":null,"instanceId":null,"eventId":null,"dt":null,"audience":null}');
        Test.stopTest();
    }

    @IsTest
    static void eventWithDataNoQuestions() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsAdditionalQuestions;
            Test.setCurrentPage(pageRef);
            SummitEventsAdditionalQuestionsCtlr questionController = new SummitEventsAdditionalQuestionsCtlr();
            System.assertEquals(JSON.serialize(questionController.eventInformation), '{"registrationId":null,"instanceId":null,"eventId":null,"dt":null,"audience":null}');
            Test.stopTest();
        }
    }
}