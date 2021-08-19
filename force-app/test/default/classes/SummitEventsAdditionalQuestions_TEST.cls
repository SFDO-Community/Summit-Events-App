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

    static void eventWithDataNoQuestions() {
        Test.startTest();
        SummitEventsAdditionalQuestionsCtlr questionController = new SummitEventsAdditionalQuestionsCtlr();
        System.assertEquals(JSON.serialize(questionController.eventInformation), '{"registrationId":null,"instanceId":null,"eventId":null,"dt":null,"audience":null}');
        Test.stopTest();
    }
}