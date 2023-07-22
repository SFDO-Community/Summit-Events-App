/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 8/18/2021.
 */


@IsTest
private class SummitEventsRegisterGuests_TEST {
    @IsTest
    static void noData() {
        Test.startTest();
        PageReference pageRef = Page.SummitEventsRegisterGuests;
        pageRef.getParameters().put('adminopen', 'true');
        Test.setCurrentPage(pageRef);

        SummitEventsRegisterGuestsController guestController = new SummitEventsRegisterGuestsController();
        System.assertEquals(JSON.serialize(guestController.eventInformation), '{"registrationId":null,"instanceId":null,"eventId":null,"dt":null,"audience":null}');
    }

    @IsTest
    static void guestsWithEventDefined() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        //Test question with empty map_to_field defined.
        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'Text Area', 'Guest');

        SummitEventsShared seaShared = new SummitEventsShared();

        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace + '__';
        }


        System.runAs(testUser) {
            Test.startTest();

            PageReference pageRef = Page.SummitEventsRegisterGuests;
            Test.setCurrentPage(pageRef);

            SummitEventsRegisterGuestsController guestController = new SummitEventsRegisterGuestsController();

            //Page check returns the first page of Summit Events because cookie with event/registration data was not found and decrypted
            PageReference pageCheck = guestController.checkEventDetails();
            System.assertEquals(pageCheck.getUrl(), 'https://google.com/' + namespace + 'SummitEvents');

            Datetime nowTime = Datetime.now();
            SummitEventsShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);

            guestController = new SummitEventsRegisterGuestsController();

            //page check returns null if event cookie is in place and valid
            pageCheck = guestController.checkEventDetails();
            System.assertEquals(pageCheck, null);

            //Correct encrypted cooke information decrypted
            System.assertEquals(JSON.serialize(guestController.eventInformation), '{"registrationId":"' + seaTestRegistration.Id + '","instanceId":"' + seaTestInstances[1].Id + '","eventId":"' + seaTestInstances[1].Event__c + '","dt":"' + String.valueOf(nowTime) + '","audience":"Transfer"}');

            //Create question answer JSON object
            List<SummitEventsRegisterGuestsController.questionGuestData> guestsQuestions = new List<SummitEventsRegisterGuestsController.questionGuestData>();
            SummitEventsRegisterGuestsController.questionGuestData guestAnswer = new SummitEventsRegisterGuestsController.questionGuestData();
            List<SummitEventsRegisterGuestsController.questionData> questionsDataList = new List<SummitEventsRegisterGuestsController.questionData>();

            SummitEventsRegisterGuestsController.questionData questionData = new SummitEventsRegisterGuestsController.questionData();
            questionData.id = SummitEventsShared.encryptString(testQuestions[0].Id);
            questionData.value = 'TEST';
            questionData.question = testQuestions[0].Question_Label__c;
            questionsDataList.add(questionData);

            guestAnswer.guestId = SummitEventsTestSharedDataFactory.getUUID();
            guestAnswer.questions = questionsDataList;
            guestsQuestions.add(guestAnswer);

            guestController.guestJSON = JSON.serialize(guestsQuestions);

            guestController.saveGuests();

            //Saved JSON should be same as that generated above
            Summit_Events_Registration__c newSEARegistration = [SELECT Id, Guest_JSON__c FROM Summit_Events_Registration__c WHERE Id = :seaTestRegistration.Id];
            System.assertEquals(JSON.serialize(guestsQuestions), newSEARegistration.Guest_JSON__c);

            //Retrieved in controller JSON should be the same as that generated above
            guestController = new SummitEventsRegisterGuestsController();
            System.assertEquals(guestController.guestJSON, JSON.serialize(guestsQuestions));

            Test.stopTest();
        }
    }

    @IsTest
    static void guestsWithHiddenQuestions() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        //Test question with empty map_to_field defined.
        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'Text Area', 'Guest');
        List<Summit_Events_Question__c> testQuestions2 = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'picklist', 'Guest');
        testQuestions2[0].Is_Visible__c = false;
        update testQuestions2;

        SummitEventsShared seaShared = new SummitEventsShared();

        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace + '__';
        }

        System.runAs(testUser) {
            Test.startTest();

            PageReference pageRef = Page.SummitEventsRegisterGuests;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);

            SummitEventsRegisterGuestsController guestController = new SummitEventsRegisterGuestsController();


            //Page check returns the first page of Summit Events because cookie with event/registration data was not found and decrypted
            PageReference pageCheck = guestController.checkEventDetails();
            //Namespace defined so url should include it
            System.assertEquals(pageCheck.getUrl(), 'https://google.com/' + namespace + 'SummitEvents');

            Datetime nowTime = Datetime.now();
            SummitEventsShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);

            guestController = new SummitEventsRegisterGuestsController();

            //page check returns null if event cookie is in place and valid
            pageCheck = guestController.checkEventDetails();
            System.assertEquals(pageCheck, null);

            System.assertEquals(guestController.previousPage().getUrl(), '/apex/' + namespace + 'summiteventsregister?adminopen=true');

            //Correct encrypted cooke information decrypted
            System.assertEquals(JSON.serialize(guestController.eventInformation), '{"registrationId":"' + seaTestRegistration.Id + '","instanceId":"' + seaTestInstances[1].Id + '","eventId":"' + seaTestInstances[1].Event__c + '","dt":"' + String.valueOf(nowTime) + '","audience":"Transfer"}');

            //Create question answer JSON object
            List<SummitEventsRegisterGuestsController.questionGuestData> guestsQuestions = new List<SummitEventsRegisterGuestsController.questionGuestData>();
            SummitEventsRegisterGuestsController.questionGuestData guestAnswer = new SummitEventsRegisterGuestsController.questionGuestData();
            List<SummitEventsRegisterGuestsController.questionData> questionsDataList = new List<SummitEventsRegisterGuestsController.questionData>();

            SummitEventsRegisterGuestsController.questionData questionData = new SummitEventsRegisterGuestsController.questionData();
            questionData.id = SummitEventsShared.encryptString(testQuestions[0].Id);
            questionData.value = 'TEST';
            questionData.question = testQuestions[0].Question_Label__c;
            questionsDataList.add(questionData);

            guestAnswer.guestId = SummitEventsTestSharedDataFactory.getUUID();
            guestAnswer.questions = questionsDataList;
            guestsQuestions.add(guestAnswer);

            guestController.guestJSON = JSON.serialize(guestsQuestions);

            guestController.saveGuests();

            //Saved JSON should be same as that generated above
            Summit_Events_Registration__c newSEARegistration = [SELECT Id, Guest_JSON__c FROM Summit_Events_Registration__c WHERE Id = :seaTestRegistration.Id];
            //Hidden questions will not appear on page, but on save will be recorded in Guest_JSON__c field.
            System.assertNotEquals(JSON.serialize(guestsQuestions), newSEARegistration.Guest_JSON__c);

            //Retrieved in controller JSON should be the same as that generated above
            guestController = new SummitEventsRegisterGuestsController();
            System.assertEquals(guestController.guestJSON, JSON.serialize(guestsQuestions));

            Test.stopTest();
        }
    }

    @IsTest
    static void guestsWithMappingError() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        //Test question with empty map_to_field defined.
        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace + '__';
        }

        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'Text Area', 'Guest');
        testQuestions.addAll(SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'Text Area', 'Guest'));
        testQuestions[0].Map_to_Field__c = 'NOT_A_FIELD__c';
        testQuestions[1].Map_to_Field__c = namespace + 'Total_Confirmed_Appointments__c';
        update testQuestions;

        System.runAs(testUser) {
            Test.startTest();

            PageReference pageRef = Page.SummitEventsRegisterGuests;
            Test.setCurrentPage(pageRef);

            Datetime nowTime = Datetime.now();
            SummitEventsShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);

            SummitEventsRegisterGuestsController guestController = new SummitEventsRegisterGuestsController();

            //Deserialize the question JSON from the page so we can check for errors
            List<SummitEventsRegisterGuestsController.question> guestQuestions = (List<SummitEventsRegisterGuestsController.question>) JSON.deserialize(guestController.guestQuestionJSON, List<SummitEventsRegisterGuestsController.question>.class);
            System.assertEquals(guestQuestions[0].setupError, 'Field NOT_A_FIELD__c may not exist. ');
            System.assertEquals(guestQuestions[1].setupError, 'Field ' + namespace + 'Total_Confirmed_Appointments__c is not writable. ');

            //Correct encrypted cooke information decrypted
            System.assertEquals(JSON.serialize(guestController.eventInformation), '{"registrationId":"' + seaTestRegistration.Id + '","instanceId":"' + seaTestInstances[1].Id + '","eventId":"' + seaTestInstances[1].Event__c + '","dt":"' + String.valueOf(nowTime) + '","audience":"Transfer"}');


            Test.stopTest();
        }
    }

    @IsTest
    static void testQuestionWithExistingPicklist() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        //Test question with empty map_to_field defined.
        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'Text Area', 'Guest');
        testQuestions.addAll(SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'Text Area', 'Guest'));

        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace + '__';
        }

        testQuestions[0].Existing_Picklist_Values__c = 'Registrant_State_Global__c';
        testQuestions[0].Map_to_Field__c = namespace + 'Registrant_State_Global__c';
        testQuestions[0].Picklist_Values__c = '';
        update testQuestions;

        System.runAs(testUser) {
            Test.startTest();

            PageReference pageRef = Page.SummitEventsRegisterGuests;
            Test.setCurrentPage(pageRef);

            Datetime nowTime = Datetime.now();
            SummitEventsShared.createEncryptedCookieWithNow('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, nowTime);

            SummitEventsRegisterGuestsController guestController = new SummitEventsRegisterGuestsController();

            //Deserialize the question JSON from the page so we can check for errors
            List<SummitEventsRegisterGuestsController.question> guestQuestions = (List<SummitEventsRegisterGuestsController.question>) JSON.deserialize(guestController.guestQuestionJSON, List<SummitEventsRegisterGuestsController.question>.class);

            System.assert(guestQuestions[0].picklist.size() > 0);

            Test.stopTest();
        }
    }
}