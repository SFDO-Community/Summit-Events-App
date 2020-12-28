// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsRegister_TEST {
    @IsTest static void testRegPicklists() {
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Test Event', '', true, true, 'One registration per instance');

        Test.startTest();
        //Add instance ID to register page
        PageReference pageRef = Page.SummitEventsRegister;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        SummitEventsRegisterController registerController = new SummitEventsRegisterController();
        registerController.getSexDD();
        registerController.getStateDD();
        registerController.getCountryDD();
        registerController.getTimeFrame();
        registerController.getThirdPartyStatus();
        registerController.getApplicantTypeDD();
        registerController.getRelationshipDD();
        Test.stopTest();
    }

    @IsTest static void testEventWithEmailRestrictions() {
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Test Event', '', true, true, 'One registration per instance');

        Test.startTest();
        //Add instance ID to register page
        PageReference pageRef = Page.SummitEventsRegister;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        SummitEventsRegisterController registerCtrl = new SummitEventsRegisterController();
        registerCtrl.eventRegistration = SummitEventsTestSharedDataFactory.createEventRegistrationObj('TestFirst', 'Test', 'TestLast', 'test@valleyhill.net', '55418', '(555) 444-4444', '1989-03-22', '2002');
        registerCtrl.saveContactRegistration();
//        UST_Event_Registration__c evtReg2 = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        registerCtrl.saveContactRegistration();
        registerCtrl.eventRegistration.Registrant_Email__c = 'test2@valleyhill.net';
        registerCtrl.eventRegistration.Registrant_Date_of_Birth__c = Date.valueOf('1989-03-22');
        registerCtrl.saveContactRegistration();
        Test.stopTest();
    }

    @IsTest static void testRegAlreadyExists() {
        //Insert a test event
        SummitEventsTestSharedDataFactory.createContact('MatchFirst', 'Match', 'MatchLast', 'match@valleyhill.net', '55555', '(555) 555-5555', '1971-03-22', '2012');
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Test Event', 'High School Senior', false, false, '');
        Summit_Events_Registration__c evtReg = SummitEventsTestSharedDataFactory.createEventRegistration(evtInst, 'MatchFirst', 'MatchLast', 'match@valleyhill.net', '55555', '1971-03-22', '2012', null);

        Test.startTest();
        SummitEventsShared SEShared = new SummitEventsShared();
        SEShared.createEncryptedCookie('High School Senior',evtInst.Id,evtInst.Event__c, evtReg.Id);

        SummitEventsRegisterController registerCtrl = new SummitEventsRegisterController();
        SEShared.createEncryptedCookie('High School Senior',evtInst.Id,evtInst.Event__c, '');

        registerCtrl = new SummitEventsRegisterController();
        registerCtrl.eventRegistration = SummitEventsTestSharedDataFactory.createEventRegistrationObj('MatchFirst', 'Match', 'MatchLast', 'match@valleyhill.net', '55555', '(555) 555-5555', '1971-03-22', '2012');
        registerCtrl.saveContactRegistration();


        registerCtrl.saveContactRegistration();
        Test.stopTest();
    }
}