// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsConfirmation_TEST {
    @IsTest static void testRegConfirmationPage() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c evtReg = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsConfirmation;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);
            SummitEventsShared SEShared = new SummitEventsShared();
            SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, evtReg.Id);
            SummitEventsConfirmationController confirmCtrl = new SummitEventsConfirmationController();
            confirmCtrl.eventIsClosed = false;
            confirmCtrl.checkEventDetails();
            Summit_Events_Registration__c checkRegistrationStatus = [
                    SELECT Id, Status__c
                    FROM
                            Summit_Events_Registration__c
                    WHERE Id = :evtReg.Id
            ];
            System.assertEquals(checkRegistrationStatus.Status__c, 'Registered');
            Test.stopTest();
        }
    }

    @IsTest static void testConfirmationWithGuests() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        seaTestInstances[1].Instance_Title__c = '';
        update seaTestInstances;

        //Test question with empty map_to_field defined.
        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'Text Area', 'Guest');
        testQuestions.addAll(SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'picklist', 'Guest'));

        //Create question answer JSON object
        List<SummitEventsRegisterGuestsController.questionGuestData> guestsQuestions = new List<SummitEventsRegisterGuestsController.questionGuestData>();
        SummitEventsRegisterGuestsController.questionGuestData guestAnswer = new SummitEventsRegisterGuestsController.questionGuestData();
        List<SummitEventsRegisterGuestsController.questionData> questionsDataList = new List<SummitEventsRegisterGuestsController.questionData>();

        questionsDataList.add(SummitEventsTestSharedDataFactory.createQuestionData(testQuestions[0].Id, 'TEST 0', testQuestions[0].Question_Label__c));
        questionsDataList.add(SummitEventsTestSharedDataFactory.createQuestionData(testQuestions[0].Id, 'TEST 10', testQuestions[0].Question_Label__c));

        guestAnswer.guestId = SummitEventsTestSharedDataFactory.getUUID();
        guestAnswer.questions = questionsDataList;
        guestsQuestions.add(guestAnswer);

        seaTestRegistration.Guest_JSON__c = JSON.serialize(guestsQuestions);

        update seaTestRegistration;

        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsConfirmation;
            pageRef.getParameters().put('adminopen', '1');
            Test.setCurrentPage(pageRef);
            SummitEventsShared SEShared = new SummitEventsShared();
            SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);
            SummitEventsConfirmationController confirmCtrl = new SummitEventsConfirmationController();
            confirmCtrl.checkEventDetails();
            Summit_Events_Registration__c checkRegistrationStatus = [
                    SELECT Id, Status__c
                    FROM
                            Summit_Events_Registration__c
                    WHERE Id = :seaTestRegistration.Id
            ];
            System.assertEquals(checkRegistrationStatus.Status__c, 'Registered');
            Test.stopTest();
        }
    }

    @IsTest static void testAdminOpen() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsConfirmation;

            Test.setCurrentPage(pageRef);
            SummitEventsShared SEShared = new SummitEventsShared();
            SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);
            SummitEventsConfirmationController confirmCtrl = new SummitEventsConfirmationController();
            confirmCtrl.checkEventDetails();
            Summit_Events_Registration__c checkRegistrationStatus = [
                    SELECT Id, Status__c
                    FROM
                            Summit_Events_Registration__c
                    WHERE Id = :seaTestRegistration.Id
            ];
            System.assertEquals(checkRegistrationStatus.Status__c, 'Registered');
            Test.stopTest();
        }
    }

    @IsTest static void testMapToError() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        seaTestInstances[1].Instance_Title__c = '';
        update seaTestInstances;

        //Test question with empty map_to_field defined.
        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEventWithMapTo(seaTestInstances[1].Event__c, 'Text Area', 'Guest', 'Question Text 0', 'DOES_NOT_EXIST__C');
        testQuestions.addAll(SummitEventsTestSharedDataFactory.addQuestionsToEventWithMapTo(seaTestInstances[1].Event__c, 'picklist', 'Guest', 'Question Text 1', 'Add_Info_Answer_1__c'));

        //Create question answer JSON object
        List<SummitEventsRegisterGuestsController.questionGuestData> guestsQuestions = new List<SummitEventsRegisterGuestsController.questionGuestData>();
        SummitEventsRegisterGuestsController.questionGuestData guestAnswer = new SummitEventsRegisterGuestsController.questionGuestData();
        List<SummitEventsRegisterGuestsController.questionData> questionsDataList = new List<SummitEventsRegisterGuestsController.questionData>();

        questionsDataList.add(SummitEventsTestSharedDataFactory.createQuestionData(testQuestions[0].Id, 'TEST 0', testQuestions[0].Question_Label__c));
        questionsDataList.add(SummitEventsTestSharedDataFactory.createQuestionData(testQuestions[1].Id, 'TEST 1', testQuestions[1].Question_Label__c));

        guestAnswer.guestId = SummitEventsTestSharedDataFactory.getUUID();
        guestAnswer.questions = questionsDataList;
        guestsQuestions.add(guestAnswer);

        seaTestRegistration.Guest_JSON__c = JSON.serialize(guestsQuestions);

        update seaTestRegistration;

        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsConfirmation;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);
            SummitEventsShared SEShared = new SummitEventsShared();
            SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);
            SummitEventsConfirmationController confirmCtrl = new SummitEventsConfirmationController();

            confirmCtrl.checkEventDetails();

            List<String> pageMessages = new List<String>();
            ApexPages.Message[] currentMessages = ApexPages.getMessages();
            for (ApexPages.Message message : currentMessages) {
                if (message.getSeverity() == ApexPages.Severity.WARNING) {
                    pageMessages.add(message.getSummary());
                }
            }
            System.assertEquals(pageMessages[0], 'Hosted Record: Insufficient Access to field for question: Question Text 0');

            Summit_Events_Registration__c checkRegistrationStatus = [
                    SELECT Id, Status__c
                    FROM
                            Summit_Events_Registration__c
                    WHERE Id = :seaTestRegistration.Id
            ];
            System.assertEquals(checkRegistrationStatus.Status__c, 'Registered');
            Test.stopTest();
        }
    }

    @IsTest static void tesWithPayment() {

        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        List<Summit_Events_Fee_Allocation__c> testAllocations =  SummitEventsTestSharedDataFactory.AddFeesToEvent(seaTestInstances[1].Event__c);
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        Summit_Events__c getEventFees = [
                SELECT Id, Event_Fee__c, Event_Fee_Allocation__c, Event_Fee_Additional__c, Event_Fee_Additional_Allocation__c
                FROM Summit_Events__c
                WHERE Id = :seaTestInstances[1].Event__c
        ];

        // Add payment record
        Summit_Events_Payment__c testPayment = new Summit_Events_Payment__c();
        testPayment.Event_Registration__c = seaTestRegistration.Id;
        testPayment.Payment_Amount__c = getEventFees.Event_Fee__c + getEventFees.Event_Fee_Additional__c;
        insert testPayment;

        //Add fees to registration
        List<Summit_Events_Fee__c> testFees = new List<Summit_Events_Fee__c>();
        Summit_Events_Fee__c testFee = new Summit_Events_Fee__c();
        testFee.Event_Registration__c= seaTestRegistration.Id;
        testFee.Event_Fee_Allocation__c = getEventFees.Event_Fee_Allocation__c;
        testFee.Event_Fee__c = getEventFees.Event_Fee__c;
        testFee.Summit_Events_Payment__c = testPayment.Id;
        testFee.Event_Fee_Type__c = 'Event';
        testFees.add(testFee);
        testFee = new Summit_Events_Fee__c();
        testFee.Event_Registration__c= seaTestRegistration.Id;
        testFee.Event_Fee_Allocation__c = getEventFees.Event_Fee_Additional_Allocation__c;
        testFee.Event_Fee__c = getEventFees.Event_Fee_Additional__c;
        testFee.Summit_Events_Payment__c = testPayment.Id;
        testFee.Event_Fee_Type__c = 'Event';
        testFees.add(testFee);
        insert testFees;

        System.runAs(testUser) {

            PageReference pageRef = Page.SummitEventsConfirmation;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);
            SummitEventsShared SEShared = new SummitEventsShared();
            SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);
            SummitEventsConfirmationController confirmCtrl = new SummitEventsConfirmationController();

            confirmCtrl.checkEventDetails();

            List<String> pageMessages = new List<String>();
            ApexPages.Message[] currentMessages = ApexPages.getMessages();
            for (ApexPages.Message message : currentMessages) {
                if (message.getSeverity() == ApexPages.Severity.WARNING) {
                    pageMessages.add(message.getSummary());
                }
            }
            Test.startTest();
            System.assert(confirmCtrl.paymentReceived);
            Summit_Events_Registration__c checkRegistrationStatus = [
                    SELECT Id, Status__c
                    FROM
                            Summit_Events_Registration__c
                    WHERE Id = :seaTestRegistration.Id
            ];
            System.assertEquals(checkRegistrationStatus.Status__c, 'Registered');
            Test.stopTest();
        }
    }

    @IsTest static void testWithAdditionalQuestions() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        seaTestInstances[1].Instance_Title__c = '';
        update seaTestInstances;

        //Test question with empty map_to_field defined.
        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEventWithMapTo(seaTestInstances[1].Event__c, 'date', 'Guest', 'Question Text 1', 'Answer_1_Numeric__c');
        testQuestions.addAll(SummitEventsTestSharedDataFactory.addQuestionsToEventWithMapTo(seaTestInstances[1].Event__c, 'date', 'Guest', 'Question Text 2', 'Registrant_Date_of_Birth__c'));
        testQuestions.addAll(SummitEventsTestSharedDataFactory.addQuestionsToEventWithMapTo(seaTestInstances[1].Event__c, 'email', 'Guest', 'Question Text 3', 'Registrant_Email__c'));
        testQuestions.addAll(SummitEventsTestSharedDataFactory.addQuestionsToEventWithMapTo(seaTestInstances[1].Event__c, 'phone', 'Guest', 'Question Text 4', 'Registrant_Mobile_Phone__c'));
        testQuestions.addAll(SummitEventsTestSharedDataFactory.addQuestionsToEventWithMapTo(seaTestInstances[1].Event__c, 'Textbox', 'Guest', 'Question Text 5', 'Add_Info_Answer_1__c'));

        //Create question answer JSON object
        List<SummitEventsRegisterGuestsController.questionGuestData> guestsQuestions = new List<SummitEventsRegisterGuestsController.questionGuestData>();
        SummitEventsRegisterGuestsController.questionGuestData guestAnswer = new SummitEventsRegisterGuestsController.questionGuestData();
        List<SummitEventsRegisterGuestsController.questionData> questionsDataList = new List<SummitEventsRegisterGuestsController.questionData>();

        questionsDataList.add(SummitEventsTestSharedDataFactory.createQuestionData(testQuestions[0].Id, 'TEST 0', testQuestions[0].Question_Label__c));
        questionsDataList.add(SummitEventsTestSharedDataFactory.createQuestionData(testQuestions[1].Id, 'TEST 1', testQuestions[1].Question_Label__c));
        questionsDataList.add(SummitEventsTestSharedDataFactory.createQuestionData(testQuestions[2].Id, 'TEST 2', testQuestions[2].Question_Label__c));
        questionsDataList.add(SummitEventsTestSharedDataFactory.createQuestionData(testQuestions[3].Id, '12341234123412341234123412341234123412341234', testQuestions[3].Question_Label__c));
        questionsDataList.add(SummitEventsTestSharedDataFactory.createQuestionData('NOT AN ID', 'TEST NO ID', testQuestions[4].Question_Label__c));

        guestAnswer.guestId = SummitEventsTestSharedDataFactory.getUUID();
        guestAnswer.questions = questionsDataList;
        guestsQuestions.add(guestAnswer);

        seaTestRegistration.Guest_JSON__c = JSON.serialize(guestsQuestions);

        update seaTestRegistration;

        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsConfirmation;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);
            SummitEventsShared SEShared = new SummitEventsShared();
            SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);
            SummitEventsConfirmationController confirmCtrl = new SummitEventsConfirmationController();

            confirmCtrl.checkEventDetails();

            List<String> pageMessages = new List<String>();
            ApexPages.Message[] currentMessages = ApexPages.getMessages();
            for (ApexPages.Message message : currentMessages) {
                if (message.getSeverity() == ApexPages.Severity.WARNING) {
                    pageMessages.add(message.getSummary());
                }
            }
            //System.assertEquals(pageMessages[0], 'Hosted Record: Insufficient Access to field for question: Question 0');
            System.assert(pageMessages.contains('Hosted Record: Could not covert response (double) on question \"Question Text 1\"'), true);
            System.assert(pageMessages.contains('Hosted Record: Could not covert response (date) on question \"Question Text 2\"'), true);
            System.assert(pageMessages.contains('Invalid question Id detected.'), true);

            Summit_Events_Registration__c checkRegistrationStatus = [
                    SELECT Id, Status__c
                    FROM
                            Summit_Events_Registration__c
                    WHERE Id = :seaTestRegistration.Id
            ];
            System.assertEquals(checkRegistrationStatus.Status__c, 'Started');
            Test.stopTest();
        }
    }

}