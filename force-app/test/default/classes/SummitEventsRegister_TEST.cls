// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsRegister_TEST {
    @IsTest static void testRegPicklists() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            //Add instance ID to register page
            PageReference pageRef = Page.SummitEventsRegister;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[1].Id);
            ApexPages.currentPage().getParameters().put('adminopen', 'true');
            SummitEventsRegisterController registerController = new SummitEventsRegisterController();
            System.assert(registerController.getSexDD().size() > 0);
            System.assert(registerController.getStateDD().size() > 0);
            System.assert(registerController.getCountryDD().size() > 0);
            System.assert(registerController.getTimeFrame().size() > 0);
            System.assert(registerController.getThirdPartyStatus().size() > 0);
            System.assert(registerController.getApplicantTypeDD().size() > 0);
            System.assert(registerController.getRelationshipDD().size() > 0);
            System.assert(registerController.getPronounDD().size() > 0);
            System.assertEquals(registerController.checkEventDetails(), null);
            registerController.eventRegistration.Registrant_First_Name__c = 'Test';
            registerController.eventRegistration.Registrant_Last_Name__c = 'Tester';
            registerController.eventRegistration.Registrant_Email__c = 'test@test.com';
            registerController.saveContactRegistration();
            List<Summit_Events_Registration__c> registrations = [
                    SELECT Id, Name, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c
                    FROM Summit_Events_Registration__c
                    WHERE Registrant_Email__c = 'test@test.com'
                    AND Registrant_First_Name__c = 'Test'
                    AND Registrant_Last_Name__c = 'Tester'
            ];
            System.assertEquals(registrations.size(), 1);
            Test.stopTest();
        }
    }

    @IsTest static void testEventWithEmailRestrictionsOnInstance() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Tester', 'test@test.net', '55555', '1971-03-22', '2012', null);
        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);
        seaTestEvent.Registration_Email_Restriction__c = 'One registration per instance';
        update seaTestEvent;
        seaTestRegistration.Status__c = 'Registered';
        update seaTestRegistration;
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsRegister;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[1].Id);
            ApexPages.currentPage().getParameters().put('audience', 'Transfer');
            SummitEventsRegisterController registerController = new SummitEventsRegisterController();
            registerController.eventRegistration.Registrant_First_Name__c = 'Test';
            registerController.eventRegistration.Registrant_Last_Name__c = 'Tester';
            registerController.eventRegistration.Registrant_Email__c = 'test@test.net';
            registerController.saveContactRegistration();
            List<Summit_Events_Registration__c> registrations = [
                    SELECT Id, Name, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c
                    FROM Summit_Events_Registration__c
            ];
            //There should be only one registration, the first one inserted as data. The second should have been restricted and not allowed through
            System.assertEquals(registrations.size(), 1);
            Test.stopTest();
        }
    }

    @IsTest static void testEventWithAppointments() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);
        List<Summit_Events_Appointment_Type__c> testAppointmentTypes = SummitEventsTestSharedDataFactory.createAppointmentTypes(seaTestInstances[1].Event__c);
        update testAppointmentTypes;
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsRegister;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[1].Id);
            SummitEventsRegisterController registerController = new SummitEventsRegisterController();
            registerController.eventRegistration.Registrant_First_Name__c = 'Test';
            registerController.eventRegistration.Registrant_Last_Name__c = 'Tester';
            registerController.eventRegistration.Registrant_Email__c = 'test@test.net';
            registerController.saveContactRegistration();
            List<Summit_Events_Registration__c> registrations = [
                    SELECT Id, Name, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c
                    FROM Summit_Events_Registration__c
            ];
            //There should be only one registration, the first one inserted as data. The second should have been restricted and not allowed through
            System.assertEquals(registrations.size(), 1);
            Test.stopTest();
        }
    }

    @IsTest static void testEventWithAdditionalQuestions() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events__c testEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);
        //Get all the variations of question input and add them to the event
        List<String> addQuestionTypes = new List<String>();
        Schema.DescribeFieldResult fieldResult = Summit_Events__c.Add_Info_Question_Type_1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            addQuestionTypes.add(pickListVal.getLabel());
        }
        for (Integer x = 1; x < 6; x++) {
            if (x < addQuestionTypes.size()) {
                testEvent.put('Add_Info_Question_Type_' + 1 + '__c', addQuestionTypes[x - 1]);
                testEvent.put('Add_Info_Question_Text_' + 1 + '__c', 'Question #' + x);
                if (addQuestionTypes[x].containsIgnoreCase('pick-list')) {
                    testEvent.put('Add_Info_Question_Pick_List_' + 1 + '__c', 'Red\nGreen\nYellow\nBlue');
                }
            }
        }
        testEvent.Ask_Phone__c = 'Ask with type require';
        testEvent.Ask_Third_Party_Registrant__c = 'Other';
        testEvent.Ask_Pronoun__c = 'Ask';
        testEvent.Ask_Gender__c = 'Ask';
        testEvent.Ask_Phone__c = 'Ask with type';

        update testEvent;
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsRegister;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[1].Id);
            SummitEventsRegisterController registerController = new SummitEventsRegisterController();
            registerController.eventRegistration.Registrant_First_Name__c = 'Test';
            registerController.phoneType = 'mobile';
            registerController.eventRegistration.Registrant_Mobile_Phone__c = '(555)555-5555';
            registerController.eventRegistration.Registrant_Last_Name__c = 'Tester';
            registerController.eventRegistration.Registrant_Email__c = 'test@test.net';
            registerController.eventRegistration.Add_Info_Answer_1__c = 'Test Answer';
            registerController.saveContactRegistration();
            List<Summit_Events_Registration__c> registrations = [
                    SELECT Id, Name, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c
                    FROM Summit_Events_Registration__c
                    WHERE Registrant_Mobile_Phone__c = '(555)555-5555'
                    AND Registrant_First_Name__c = 'Test'
            ];
            //There should be only one registration, the first one inserted as data. The second should have been restricted and not allowed through
            System.assertEquals(registrations.size(), 1);
            Test.stopTest();
        }
    }

    @IsTest static void testEventWithEmailRestrictionsOnEvent() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Tester', 'test@test.net', '55555', '1971-03-22', '2012', null);
        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);
        seaTestEvent.Registration_Email_Restriction__c = 'One registration per event';
        //remove location data to test it not showing
        seaTestEvent.Location_Title__c = '';
        seaTestEvent.Location_Address__c = '';
        seaTestEvent.Location_Map_Link__c = '';
        //Add optional donation page
        seaTestEvent.Display_Optional_Donation__c = true;
        update seaTestEvent;
        seaTestRegistration.Status__c = 'Registered';
        update seaTestRegistration;
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsRegister;
            Test.setCurrentPage(pageRef);
            //Try to register on different instance
            ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[2].Id);
            ApexPages.currentPage().getParameters().put('audience', 'High School Senior');
            SummitEventsRegisterController registerController = new SummitEventsRegisterController();
            registerController.eventRegistration.Registrant_First_Name__c = 'Test';
            registerController.eventRegistration.Registrant_Last_Name__c = 'Tester';
            registerController.eventRegistration.Registrant_Email__c = 'test@test.net';
            registerController.saveContactRegistration();
            List<Summit_Events_Registration__c> registrations = [
                    SELECT Id, Name, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c
                    FROM Summit_Events_Registration__c
            ];
            //There should be only one registration, the first one inserted as data. The second should have been restricted and not allowed through
            System.assertEquals(registrations.size(), 1);
            Test.stopTest();
        }
    }

    @IsTest static void testWithRegistrationStarted() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Tester', 'test@test.net', '55555', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsRegister;
            Test.setCurrentPage(pageRef);
            //Try to register on different instance
            SummitEventsShared SEShared = new SummitEventsShared();
            SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);
            SummitEventsRegisterController registerController = new SummitEventsRegisterController();
            //Change current registration information
            registerController.eventRegistration.Registrant_First_Name__c = 'Test2';
            registerController.eventRegistration.Registrant_Last_Name__c = 'Tester2';
            registerController.eventRegistration.Registrant_Email__c = 'test2@test.net';
            registerController.saveContactRegistration();
            List<Summit_Events_Registration__c> registrations = [
                    SELECT Id, Name, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c
                    FROM Summit_Events_Registration__c
                    WHERE Registrant_First_Name__c = 'Test'
                    AND Registrant_Last_Name__c = 'Tester'
                    AND Registrant_Email__c = 'test@test.net'
            ];
            //Original registration details have changed so old data should not exist.
            System.assertEquals(registrations.size(), 0);

            registrations = [
                    SELECT Id, Name, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c
                    FROM Summit_Events_Registration__c
                    WHERE Registrant_First_Name__c = 'Test2'
                    AND Registrant_Last_Name__c = 'Tester2'
                    AND Registrant_Email__c = 'test2@test.net'
            ];
            //Original registration details have changed so new data should have replaced it.
            System.assertEquals(registrations.size(), 1);

            Test.stopTest();
        }
    }

    @IsTest static void testWithEventWithFees() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        List<Summit_Events_Fee_Allocation__c> seaTestFeeAllocations = SummitEventsTestSharedDataFactory.AddFeesToEvent(seaTestInstances[1].Event__c);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsRegister;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[1].Id);
            //Try to register on different instance
            SummitEventsRegisterController registerController = new SummitEventsRegisterController();
            //Change current registration information
            registerController.eventRegistration.Registrant_First_Name__c = 'Test';
            registerController.eventRegistration.Registrant_Last_Name__c = 'Tester';
            registerController.eventRegistration.Registrant_Email__c = 'test@test.net';
            registerController.saveContactRegistration();
            List<Summit_Events_Fee__c> fees = [
                    SELECT Id, Event_Fee_Allocation__c, Event_Registration__c
                    FROM Summit_Events_Fee__c
                    WHERE Event_Registration__c = :registerController.eventRegistration.Id
            ];
            //Fees records should have been added.
            System.assertEquals(fees.size(), 2);
            //Add a fee amount to cause deletion
            Summit_events_Fee__c strayTestFee = new Summit_Events_Fee__c(
                    Event_Registration__c = registerController.eventRegistration.Id,
                    Event_Fee__c = 10,
                    Event_Fee_Allocation__c = seaTestFeeAllocations[5].Id,
                    Event_Fee_Type__c = 'Event Fee'
            );
            insert strayTestFee;
            registerController.saveContactRegistration();
            fees = [
                    SELECT Id, Event_Fee_Allocation__c, Event_Registration__c
                    FROM Summit_Events_Fee__c
                    WHERE Event_Registration__c = :registerController.eventRegistration.Id
            ];
            //Extra added fee should be deleted and two should remain
            System.assertEquals(fees.size(), 2);
            Test.stopTest();
        }
    }

    @IsTest static void testWithEventWithFeesLocationOverride() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        List<Summit_Events_Fee_Allocation__c> seaTestFeeAllocations = SummitEventsTestSharedDataFactory.AddFeesToEvent(seaTestInstances[1].Event__c);
        seaTestInstances[1].Event_Fee_Additional_Override__c = 777.00;
        seaTestInstances[1].Event_Fee_Override__c = 777.00;
        seaTestInstances[1].Event_Fee_Additional_Allocation_Override__c = seaTestFeeAllocations[2].Id;
        seaTestInstances[1].Event_Fee_Allocation_Override__c = seaTestFeeAllocations[3].Id;
        seaTestInstances[1].Location_Title_Override__c = 'New Title';
        seaTestInstances[1].Location_Address_Override__c = 'New Address';
        seaTestInstances[1].Location_Map_Link_Override__c = 'New Map Link';
        update seaTestInstances[1];
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsRegister;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[1].Id);
            //Try to register on different instance
            SummitEventsRegisterController registerController = new SummitEventsRegisterController();
            //Change current registration information
            registerController.eventRegistration.Registrant_First_Name__c = 'Test';
            registerController.eventRegistration.Registrant_Last_Name__c = 'Tester';
            registerController.eventRegistration.Registrant_Email__c = 'test@test.net';
            registerController.saveContactRegistration();
            List<Summit_Events_Fee__c> fees = [
                    SELECT Id, Event_Fee_Allocation__c, Event_Registration__c, Event_Fee__c
                    FROM Summit_Events_Fee__c
                    WHERE Event_Registration__c = :registerController.eventRegistration.Id
            ];
            //Fees records should have been added.
            System.assertEquals(fees[0].Event_Fee__c, 777.00);

            registerController.saveContactRegistration();
            Test.stopTest();
        }
    }

}