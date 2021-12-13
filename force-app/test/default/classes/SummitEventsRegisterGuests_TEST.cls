/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 8/18/2021.
 */


@IsTest
private class SummitEventsRegisterGuests_TEST {
    @IsTest
    static void noData() {
        Test.startTest();
        SummitEventsRegisterGuestsController guestController = new SummitEventsRegisterGuestsController();
        System.assertEquals(JSON.serialize(guestController.eventInformation), '{"registrationId":null,"instanceId":null,"eventId":null,"dt":null,"audience":null}');
        Test.stopTest();
    }

    @IsTest
    static void guestsWithEventDefined() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        //Test question with empty map_to_field defined.
        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'Text Area', 'Guest');
        System.runAs(testUser) {
            Test.startTest();
            String namespace = SummitEventsNamespace.getNamespace();
            if (String.isNotBlank(namespace)) {
                namespace = namespace + '__';
            }

            PageReference pageRef = Page.SummitEventsRegisterGuests;
            Test.setCurrentPage(pageRef);

            SummitEventsShared SEShared = new SummitEventsShared();
            Datetime nowTime = Datetime.now();
            SEShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);


            SummitEventsRegisterGuestsController guestController = new SummitEventsRegisterGuestsController();
            //Correct encrypted cooke information decrypted
            System.assertEquals(JSON.serialize(guestController.eventInformation), '{"registrationId":"' + seaTestRegistration.Id + '","instanceId":"' + seaTestInstances[1].Id + '","eventId":"' + seaTestInstances[1].Event__c + '","dt":"' + String.valueOf(nowTime) + '","audience":"Transfer"}');

            Test.stopTest();
        }
    }
}