/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 8/18/2021.
 */


@IsTest
private class SummitEventsAdditionalQuestions_TEST {
    @IsTest
    static void noDataController() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
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
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        System.runAs(testUser) {
            Test.startTest();

            PageReference pageRef = Page.SummitEventsAdditionalQuestions;
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
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, '', 'Registrant and Guest');
        SummitEventsNamespace.plainNamespace = 'summit';

        System.runAs(testUser) {
            Test.startTest();

            PageReference pageRef = Page.SummitEventsAdditionalQuestions;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);

            SummitEventsShared SEShared = new SummitEventsShared();
            Datetime nowTime = Datetime.now();
            SEShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);

            SummitEventsAdditionalQuestionsCtlr questionController = new SummitEventsAdditionalQuestionsCtlr();

            //Previous page should be the first page. adminopen=true should be maintained from url parameter.
            PageReference previousPage = questionController.previousPage();
            System.assertEquals(previousPage.getUrl(), '/apex/summiteventsregister?adminopen=true');

            System.assertEquals(JSON.serialize(questionController.eventInformation), '{"registrationId":"' + seaTestRegistration.Id + '","instanceId":"' + seaTestInstances[1].Id + '","eventId":"' + seaTestInstances[1].Event__c + '","dt":"' + String.valueOf(nowTime) + '","audience":"Transfer"}');
            //All questions types represented here (if number of types increases this will have to be adjusted)
            System.assertEquals(questionController.additionalQuestions.size(), 8);

            Test.stopTest();
        }
    }

    @IsTest
    static void testLookupQuestion() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Look', 'Up', 'lookup@valleyhill.net', '55418', '1971-03-22', '2012', null);

        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace + '__';
        }

        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'lookup', 'Registrant and Guest');
        testQuestions[0].Lookup_Where_Clause__c = ' WHERE ' + namespace + ' Registrant_First_Name__c != null ';
        update testQuestions;

        System.runAs(testUser) {
            Test.startTest();

            PageReference pageRef = Page.SummitEventsAdditionalQuestions;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);


            SummitEventsShared SEShared = new SummitEventsShared();
            Datetime nowTime = Datetime.now();
            SEShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);

            SummitEventsAdditionalQuestionsCtlr questionController = new SummitEventsAdditionalQuestionsCtlr();

            //Checking that the cookie returns the correct information
            System.assertEquals(JSON.serialize(questionController.eventInformation), '{"registrationId":"' + seaTestRegistration.Id + '","instanceId":"' + seaTestInstances[1].Id + '","eventId":"' + seaTestInstances[1].Event__c + '","dt":"' + String.valueOf(nowTime) + '","audience":"Transfer"}');

            //Only 1 lookup questions requested so additional question query and wrapper should be 1
            System.assertEquals(questionController.additionalQuestions.size(), 1);
            System.assertEquals(questionController.questionWrapper.size(), 1);

            //Search for something we know doesn't exist
            List<SummitEventsAdditionalQuestionsCtlr.queryReturn> queryReturns = SummitEventsAdditionalQuestionsCtlr.lookupSearch(questionController.questionWrapper[0].lookup, 'NoWayYouAreFindingThis');
            System.assertEquals(queryReturns.size(), 0);

            //Search for the registration that was added in the data above

            queryReturns = SummitEventsAdditionalQuestionsCtlr.lookupSearch(questionController.questionWrapper[0].lookup, 'Look');
            System.assertEquals(queryReturns.size(), 1);

            questionController.submitAdditionalQuestions();

            testQuestions[0].Map_to_Field__c = namespace + 'Registrant_First_Name__c';
            update testQuestions;
            questionController = new SummitEventsAdditionalQuestionsCtlr();
            System.assertEquals(questionController.questionWrapper[0].setupError, 'Question setup issue(s): Map To Field: Field registrant_first_name__c is not the required field type reference. ');

            Test.stopTest();
        }
    }

    @IsTest
    static void testMapToFieldError() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        //Test question with empty map_to_field defined.
        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'Text Area', 'Registrant and Guest');
        List<Summit_Events_Question__c> testQuestions2 = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'Text Area', 'Registrant and Guest');
        testQuestions[0].Map_to_Field__c = '';
        update testQuestions;

        System.runAs(testUser) {
            Test.startTest();

            String namespace = SummitEventsNamespace.getNamespace();
            if (String.isNotBlank(namespace)) {
                namespace = namespace + '__';
            }

            PageReference pageRef = Page.SummitEventsAdditionalQuestions;
            Test.setCurrentPage(pageRef);

            SummitEventsShared SEShared = new SummitEventsShared();
            Datetime nowTime = Datetime.now();
            SEShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);

            SummitEventsAdditionalQuestionsCtlr questionController = new SummitEventsAdditionalQuestionsCtlr();
            System.assertEquals(questionController.questionWrapper[0].setupError, 'Question setup issue(s): Map to field is not entered. ');

            //Test question with field that doesn't exist for map_to_field__c
            testQuestions[0].Map_to_Field__c = 'BogusField';
            testQuestions[0].Lookup_Secondary_Input_Link_Text__c = 'Secondary Link Text';
            testQuestions[0].Lookup_No_Results_Label__c = 'Nope. Nothing...';
            update testQuestions;
            questionController = new SummitEventsAdditionalQuestionsCtlr();
            System.assertEquals(questionController.questionWrapper[0].setupError, 'Question setup issue(s): Map to field: Field bogusfield may not exist. ');

            //Test question with sane map_to_field__c as another question in the event
            testQuestions[0].Map_to_Field__c = testQuestions2[0].Map_to_Field__c;
            testQuestions[0].Lookup_Secondary_Input_Link_Text__c = 'Secondary Link Text';
            testQuestions[0].Lookup_No_Results_Label__c = 'Nope. Nothing...';
            update testQuestions;
            questionController = new SummitEventsAdditionalQuestionsCtlr();
            System.assertEquals(questionController.additionalQuestions.size(), 2);
            System.assertEquals(questionController.questionWrapper[1].setupError, 'Question setup issue(s): You have 2 questions mapped to the same field: ' + testQuestions2[0].Map_to_Field__c.toLowerCase() + '. ');

            Test.stopTest();
        }
    }

    @IsTest
    static void testLookUpFieldError() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        //Test question with empty map_to_field defined.
        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'lookup', 'Registrant and Guest');
        //List<Summit_Events_Question__c> testQuestions2 = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'lookup', 'Registrant and Guest');
        testQuestions[0].Lookup_Object__c = '';
        update testQuestions;

        System.runAs(testUser) {
            Test.startTest();

            String namespace = SummitEventsNamespace.getNamespace();
            if (String.isNotBlank(namespace)) {
                namespace = namespace + '__';
            }

            PageReference pageRef = Page.SummitEventsAdditionalQuestions;
            Test.setCurrentPage(pageRef);

            SummitEventsShared SEShared = new SummitEventsShared();
            Datetime nowTime = Datetime.now();
            SEShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);

            SummitEventsAdditionalQuestionsCtlr questionController = new SummitEventsAdditionalQuestionsCtlr();
            System.assertEquals(questionController.questionWrapper[0].setupError.trim(), 'Question setup issue(s): Look up field:  may not exist or is inaccessible. Look up field:  may not exist or is inaccessible.');

            testQuestions[0].Lookup_Object__c = 'Blah';
            testQuestions[0].Lookup_Fields__c = 'Blah';
            update testQuestions;
            questionController = new SummitEventsAdditionalQuestionsCtlr();
            System.assertEquals(questionController.questionWrapper[0].setupError.trim(), 'Question setup issue(s): Lookup Object: blah may not exist or is inaccessible. Look up field: blah may not exist or is inaccessible.');

            Test.stopTest();
        }
    }

    @IsTest
    static void testExistingPicklist() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        //Test question with empty map_to_field defined.
        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'picklist', 'Registrant and Guest');

        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace + '__';
        }

        testQuestions[0].Existing_Picklist_Values__c = namespace + 'Registrant_State_Global__c';
        testQuestions[0].Map_to_Field__c = namespace + 'Registrant_State_Global__c';
        testQuestions[0].Picklist_Values__c = '';
        update testQuestions;

        System.runAs(testUser) {
            Test.startTest();

            PageReference pageRef = Page.SummitEventsAdditionalQuestions;
            Test.setCurrentPage(pageRef);

            SummitEventsShared SEShared = new SummitEventsShared();
            Datetime nowTime = Datetime.now();
            SEShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);

            SummitEventsAdditionalQuestionsCtlr questionController = new SummitEventsAdditionalQuestionsCtlr();

            System.assert(questionController.questionWrapper[0].picklist.size() > 0);

            Test.stopTest();
        }
    }
}