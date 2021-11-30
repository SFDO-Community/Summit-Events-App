/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 8/18/2021.
 */


@IsTest
private class SummitEventsAdditionalQuestions_TEST {
    @IsTest
    static void noDataController() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        System.runAs(testUser) {
            Test.startTest();

            PageReference pageRef = Page.SummitEventsAdditionalQuestions;
            Test.setCurrentPage(pageRef);
            SummitEventsAdditionalQuestionsCtlr questionController = new SummitEventsAdditionalQuestionsCtlr();

            //No cookie present so page redirects to root of Summit Events and event info is null
            PageReference eventPage = questionController.checkEventDetails();
            System.assertEquals(eventPage.getUrl(), 'https://google.com/SummitEvents');
            System.assertEquals(JSON.serialize(questionController.eventInformation), '{"registrationId":null,"instanceId":null,"eventId":null,"dt":null,"audience":null}');

            Test.stopTest();
        }
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
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);

            SummitEventsShared SEShared = new SummitEventsShared();
            Datetime nowTime = Datetime.now();
            SEShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);

            SummitEventsAdditionalQuestionsCtlr questionController = new SummitEventsAdditionalQuestionsCtlr();
            //Page stays where it is because cookie present
            PageReference eventPage = questionController.checkEventDetails();
            System.assertEquals(eventPage, null);

            //Correct encrypted cooke information decrypted
            System.assertEquals(JSON.serialize(questionController.eventInformation), '{"registrationId":"' + seaTestRegistration.Id + '","instanceId":"' + seaTestInstances[1].Id + '","eventId":"' + seaTestInstances[1].Event__c + '","dt":"' + String.valueOf(nowTime) + '","audience":"Transfer"}');

            //No questions were set up for this page
            System.assertEquals(questionController.additionalQuestions.size(), 0);

            Test.stopTest();
        }
    }

    @IsTest
    static void eventWithDataQuestions() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, '', 'Registrant and Guest');


        System.runAs(testUser) {
            Test.startTest();

            PageReference pageRef = Page.SummitEventsAdditionalQuestions;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);

            SummitEventsShared SEShared = new SummitEventsShared();
            Datetime nowTime = Datetime.now();
            SEShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);

            SummitEventsAdditionalQuestionsCtlr questionController = new SummitEventsAdditionalQuestionsCtlr();

            System.assertEquals(JSON.serialize(questionController.eventInformation), '{"registrationId":"' + seaTestRegistration.Id + '","instanceId":"' + seaTestInstances[1].Id + '","eventId":"' + seaTestInstances[1].Event__c + '","dt":"' + String.valueOf(nowTime) + '","audience":"Transfer"}');
            //All questions types represented here (if number of types increases this will have to be adjusted)
            System.assertEquals(questionController.additionalQuestions.size(), 24);

            System.debug(questionController.questionWrapper.size());

            Test.stopTest();
        }
    }

    @IsTest
    static void testLookupQuestion() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'lookup', 'Registrant and Guest');


        System.runAs(testUser) {
            Test.startTest();

            PageReference pageRef = Page.SummitEventsAdditionalQuestions;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);

            SummitEventsShared SEShared = new SummitEventsShared();
            Datetime nowTime = Datetime.now();
            SEShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);

            SummitEventsAdditionalQuestionsCtlr questionController = new SummitEventsAdditionalQuestionsCtlr();

            System.assertEquals(JSON.serialize(questionController.eventInformation), '{"registrationId":"' + seaTestRegistration.Id + '","instanceId":"' + seaTestInstances[1].Id + '","eventId":"' + seaTestInstances[1].Event__c + '","dt":"' + String.valueOf(nowTime) + '","audience":"Transfer"}');

            //Only 3 lookup questions requested
            System.assertEquals(questionController.additionalQuestions.size(), 3);

            System.debug(questionController.questionWrapper);

            SummitEventsAdditionalQuestionsCtlr.lookupSearch(questionController.questionWrapper[0].lookup, 'Test');

            Test.stopTest();
        }
    }
}