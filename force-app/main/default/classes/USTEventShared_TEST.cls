// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 6/12/2018.

@isTest
public with sharing class USTEventShared_TEST {

    /**

    Data Facotry Methods:

    createTestEvent(String recType, String testEventName, String audience, Boolean includeAppt, Boolean includeAddQuestions)
        - Returns Event Instance
    createContact(String firstName, String preferredFirst, String lastName, String Email, String Zip, String Phone, String DOB, String ClassYear)
        - Returns contact
    createUserByContactId(Id cId)
        - Returns user
    createEventRegistration(UST_Event_Instance__c evtI, String firstName, String lastName, String Email, String Zip, String DOB, String ClassYear)
        - Returns Event Registration
    createEventRegistrionObj(String firstName, String preferredFirst, String lastName, String Email, String Zip, String Phone, String DOB, String ClassYear)
        -Returns Event Registration Object
    createTestTransactionEmail(Id evtId, String status)
        -Returns UST_Event_Email__c

     **/

    @isTest static void testBlankEvent() {
        Test.startTest();
        //Making bad cookies for exceptions
        String eventForCookie = '{"blah":"blah"}';
        USTEventShared USTShared = new USTEventShared();
        USTEventRegisterController registerCtrl = new USTEventRegisterController();
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        USTShared.getUSTEventInfo();
        registerCtrl = new USTEventRegisterController();
        PageReference pageRef = Page.USTEventCancelReview;
        Test.setCurrentPage(pageRef);
        registerCtrl.checkEventDetails();
        registerCtrl.checkEventDetails();
        Test.stopTest();
    }

    @isTest static void testMatchingUDAR() {
        //Insert a test event
        Contact evtCon = TestUSTEventSharedDataFactory.createContact('MatchFirst', 'Match', 'MatchLast', 'match@valleyhill.net', '55555', '(555) 555-5555', '1971-03-22', '2012');
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('UDAR', 'Test Event', '', true, true);

        Test.startTest();
        //Add instance ID to register page
        PageReference pageRef = Page.USTEventRegister;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        USTEventRegisterController registerCtrl = new USTEventRegisterController();

        //Blank registraiton
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('', '', '', '', '', '', '', '2002');
        registerCtrl.saveContactRegistration();

        //Create a new contact
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('TestFirst', 'Test', 'TestLast', 'test@valleyhill.net', '55418', '(555) 444-4444', '1989-03-22', '2002');
        registerCtrl.saveContactRegistration();

        //Hard test on LAST NAME, EMAIL, CLASS
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('TestFirst', 'Test', 'MatchLast', 'match@valleyhill.net', '55418', '(555) 444-4444', '1989-03-22', '2012');
        registerCtrl.saveContactRegistration();

        ///Hard test on LAST NAME, FIRST NAME, EMAIL
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('MatchFirst', 'Match', 'MatchLast', 'match@valleyhill.net', '55418', '(555) 444-4444', '1989-03-22', '2002');
        registerCtrl.saveContactRegistration();

        //Hard test on LAST NAME, CLASS, FIRST NAME, PHONE
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('MatchFirst', 'Test', 'MatchLast', 'test@valleyhill.net', '55418', '(555) 555-5555', '1989-03-22', '2012');
        registerCtrl.saveContactRegistration();

        //Soft Match on Last Name
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('TestFirst', 'Test', 'MatchLast', 'test@valleyhill.net', '55418', '(555) 444-4444', '1989-03-22', '2002');
        registerCtrl.saveContactRegistration();

        //Soft Match LAST NAME, PHONE and CLASS
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('TestFirst', 'Test', 'MatchLast', 'test@valleyhill.net', '55418', '(555) 555-5555', '1989-03-22', '2012');
        registerCtrl.saveContactRegistration();

        Test.stopTest();
    }

    @isTest static void testNoMatchGraduate() {
        //Insert a test event
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Graduate', 'Test Event', '', true, true);
        Test.startTest();
        //Add instance ID to register page
        PageReference pageRef = Page.USTEventRegister;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        USTEventRegisterController registerCtrl = new USTEventRegisterController();
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('Graduate', 'Test', 'Master', 'graduate@valleyhill.net', '55555', '(555) 555-5555', '1989-03-22', '2014');
        registerCtrl.saveContactRegistration();

        //Run same registration again for reg Id match
        registerCtrl.saveContactRegistration();

        Test.stopTest();
    }


    @isTest static void testMatchingUndergraduate() {
        //Insert a test event
        Contact evtCon = TestUSTEventSharedDataFactory.createContact('MatchFirst', 'Match', 'MatchLast', 'match@valleyhill.net', '55555', '(555) 555-5555', '1971-03-22', '2012');
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Test Event', 'High School Senior', true, true);

        Test.startTest();
        //Add instance ID to register page
        PageReference pageRef = Page.USTEventRegister;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        ApexPages.currentPage().getParameters().put('audience', 'High School Senior');
        USTEventRegisterController registerCtrl = new USTEventRegisterController();

        //Blank registraiton
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('', '', '', '', '', '', '', '2002');
        registerCtrl.saveContactRegistration();

        //No Match create a new contact
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('TestFirst', 'Test', 'TestLast', 'test@valleyhill.net', '55418', '(555) 444-4444', '1989-03-22', '2002');
        registerCtrl.saveContactRegistration();

        // Hard Match on Last Name Email
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('TestFirst', 'Test', 'MatchLast', 'match@valleyhill.net', '55418', '(555) 444-4444', '1989-03-22', '2002');
        registerCtrl.saveContactRegistration();

        //Hard Match on First 3 letters of first name / preferred first name, last name, and birthdate
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('MatchFirst', 'Match', 'MatchLast', 'match@valleyhill.net', '55418', '(555) 444-4444', '1971-03-22', '2002');
        registerCtrl.saveContactRegistration();

        //Soft Match with Last Name, First Name, Zip
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('MatchFirst', 'Test', 'MatchLast', 'test@valleyhill.net', '55555', '(555) 444-4444', '1989-03-22', '2002');
        registerCtrl.saveContactRegistration();

        //Soft Match found with email
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('TestFirst', 'Test', 'TestLast', 'match@valleyhill.net', '55418', '(555) 444-4444', '1989-03-22', '2002');
        registerCtrl.saveContactRegistration();

        //Run same registration again for reg Id match
        PageReference newpg = registerCtrl.saveContactRegistration();
        Test.setCurrentPage(newpg);

        pageRef = Page.USTEventRegister;
        Test.setCurrentPage(pageRef);
        registerCtrl.saveContactRegistration();


        Test.stopTest();
    }

    @isTest static void testRegPicklists() {
        USTEventRegisterController registerCtrl = new USTEventRegisterController();
        registerCtrl.getSexDD();
        registerCtrl.GetStateDD();
        registerCtrl.getTimeFrame();
        registerCtrl.getParentStatus();
        registerCtrl.getApplicantTypeDD();
        registerCtrl.getRelationshipDD();
        registerCtrl.getProgramsAvailable();

    }

    @isTest static void testRegAlreadyExists() {
        //Insert a test event
        Contact evtCon = TestUSTEventSharedDataFactory.createContact('MatchFirst', 'Match', 'MatchLast', 'match@valleyhill.net', '55555', '(555) 555-5555', '1971-03-22', '2012');
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Test Event', 'High School Senior', false, false);
        UST_Event_Registration__c evtReg = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'MatchFirst', 'MatchLast', 'match@valleyhill.net', '55555', '1971-03-22', '2012', null);

        Test.startTest();
        USTEventShared USTShared = new USTEventShared();
        String eventForCookie = '{"audience":"High School Senior","instanceID":"' + evtInst.Id + '","evtRegId":"' + evtReg.Id + '","evtId":"' + evtInst.Event__c + '"}';
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        USTEventRegisterController registerCtrl = new USTEventRegisterController();

        PageReference pr = registerCtrl.setParentInfo('This');

        eventForCookie = '{"audience":"High School Senior","instanceID":"' + evtInst.Id + '","evtRegId":"COMING","evtId":"' + evtInst.Event__c + '"}';
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        registerCtrl = new USTEventRegisterController();
        registerCtrl.newEvtReg = TestUSTEventSharedDataFactory.createEventRegistrationObj('MatchFirst', 'Match', 'MatchLast', 'match@valleyhill.net', '55555', '(555) 555-5555', '1971-03-22', '2012');
        registerCtrl.saveContactRegistration();


        registerCtrl.saveContactRegistration();
        Test.stopTest();
    }


    @isTest static void testSubmit() {
        Contact evtCon = TestUSTEventSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Test Event', '', true, true);
        UST_Event_Registration__c evtReg = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        Test.startTest();
        PageReference pageRef = Page.USTEventSubmit;
        Test.setCurrentPage(pageRef);
        USTEventShared USTShared = new USTEventShared();
        String eventForCookie = '{"audience":"Transfer","instanceID":"' + evtInst.Id + '","evtRegId":"' + evtReg.Id + '","evtId":"' + evtInst.Event__c + '"}';
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        //ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        USTEventSubmitController submitCtrl = new USTEventSubmitController();
        PageReference checkEvt = submitCtrl.checkEventDetails();
        PageReference prevPage = submitCtrl.previousPage();
        submitCtrl.submitRegistration();
    }

    @isTest static void testRegWithOptions() {
        Contact evtCon = TestUSTEventSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Test Event', '', true, true);
        UST_Event_Registration__c evtReg = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        Test.startTest();
        USTEventRegistrationOptionsController optionsCtrl = new USTEventRegistrationOptionsController();
        USTEventShared USTShared = new USTEventShared();
        String eventForCookie = '{"audience":"Transfer","instanceID":"' + evtInst.Id + '","evtRegId":"' + evtReg.Id + '","evtId":"' + evtInst.Event__c + '"}';
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        optionsCtrl = new USTEventRegistrationOptionsController();

        optionsCtrl.checkEventDetails();
        optionsCtrl.previousPage();

        optionsCtrl.incomingApptJSon = '[]';
        optionsCtrl.saveOptions();

        //[{"apptId":"a010m000003EibeAAC","apptCatagory":"","apptType":"","apptText":"","apptTitle":"Multi colored socks for everyone"},{"apptId":"a010m000003EibUAAS","apptCatagory":"","apptType":"","apptText":"","apptTitle":"Red Socks Only"}]

        List<UST_Event_Appointment_Type__c> newApptTypes = [SELECT Id, Title__c FROM UST_Event_Appointment_Type__c WHERE UST_Event__c = :evtInst.Event__c];
        String jsonAppts = '[';
        for (UST_Event_Appointment_Type__c at : newApptTypes) {
            jsonAppts += '{"apptId":"' + at.Id + '","apptCatagory":"","apptType":"","apptText":"","apptTitle":"' + at.Title__c + '"},';
        }
        jsonAppts = jsonAppts.removeEnd(',');
        jsonAppts += ']';
        optionsCtrl.incomingApptJSon = jsonAppts;
        optionsCtrl.saveOptions();

        //run constructor again to simulate page load after save
        evtReg.UG_Event_Appointments__r.add(new UST_Event_Appointments__c(Client_Created_Appointment__c = true));
        optionsCtrl = new USTEventRegistrationOptionsController();
        Test.stopTest();
    }

    @isTest static void testRegCancel() {
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Test Event', '', true, true);
        UST_Event_Registration__c evtReg = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        Test.startTest();
        PageReference pageRef = Page.USTEventCancelReview;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('regId', evtReg.Id);
        USTEventCancelReviewController cancelReviewCtrl = new USTEventCancelReviewController();
        cancelReviewCtrl.cancelRegistration();
        Test.stopTest();
    }

    @isTest static void testRegConfirmationPage() {
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Test Event', '', true, true);
        UST_Event_Registration__c evtReg = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        Test.startTest();
        USTEventShared USTShared = new USTEventShared();
        //{"audience":"High School Senior","instanceID":"a320m000000A5fOAAS","evtRegId":"a350m0000008q63AAA","evtId":"a330m0000001SOrAAM"}
        String eventForCookie = '{"audience":"","instanceID":"' + evtInst.Id + '","evtRegId":"' + evtReg.Id + '","evtId":"' + evtInst.Event__c + '"}';
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        USTEventConfirmationController confirmCtrl = new USTEventConfirmationController();
        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
        confirmCtrl.checkEventDetails();
        Test.stopTest();
    }

    @isTest static void testParkingPass() {
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Test Event', '', true, true);
        UST_Event_Registration__c evtReg = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        evtReg.Status__c = 'Requested';
        update evtReg;

        Test.startTest();
        USTEventParkingPassController parkingCtrl = new USTEventParkingPassController();
        ApexPages.currentPage().getParameters().put('regId', evtReg.Id);
        parkingCtrl = new USTEventParkingPassController();

        evtReg.Date__c = evtInst.Start_Date_Time__c.date().addDays(-1);
        upsert evtReg;
        parkingCtrl = new USTEventParkingPassController();
        Test.stopTest();
    }

    @isTest static void testEventFeed() {
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Test Event', 'Alumni', true, true);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/usteventfeed';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');

        //Test audience dd request
        req.params.put('feedType', 'audienceDD');
        RestContext.request = req;
        RestContext.response = res;
        USTEventFeed.getUSTEventFeed();

        //Test sex dd request
        req.params.remove('feedType');
        req.params.put('feedType', 'sexDD');
        RestContext.request = req;
        USTEventFeed.getUSTEventFeed();

        //test filter minus dates
        req.params.remove('feedType');
        req.params.put('feedType', 'eventList');
        RestContext.request = req;
        USTEventFeed.getUSTEventFeed();

        //test filter minus dates
        req.params.remove('feedType');
        req.params.put('feedType', 'eventList');
        req.params.put('eventId', evtInst.Id);
        req.params.put('sponsor', 'Big Business');
        req.params.put('longdesc', 'true');
        RestContext.request = req;
        USTEventFeed.getUSTEventFeed();
        req.params.put('eventId', 'WRONG!');
        RestContext.request = req;
        USTEventFeed.getUSTEventFeed();

        //test filter with start date
        req.params.put('viewStart', String.valueOf(Datetime.now().addMonths(-1)));
        RestContext.request = req;
        USTEventFeed.getUSTEventFeed();

        //test filter with end date
        req.params.put('viewEnd', String.valueOf(Datetime.now().addMonths(1)));
        req.params.put('audience', 'Alumni');
        RestContext.request = req;
        USTEventFeed.getUSTEventFeed();

        //test filter
        req.params.put('filter', 'OCB');
        RestContext.request = req;
        USTEventFeed.getUSTEventFeed();

        //test filter
        req.params.put('rectype', 'UDAR');
        req.params.put('callback', 'UDAR');
        RestContext.request = req;
        USTEventFeed.getUSTEventFeed();
        Test.stopTest();

    }

//    @isTest static void testUSTEventShared() {
//        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Test Event', '', true, true);
//        UST_Event_Registration__c evtReg = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012');
//
//        Test.startTest();
//        USTEventShared USTShared = new USTEventShared();
//        String eventForCookie = '{"audience":"Transfer","instanceID":"' + evtInst.Id + '","evtRegId":"' + evtReg.Id + '","evtId":"' + evtInst.Event__c + '"}';
//        USTShared.createEncryptedCookie(eventForCookie, 'USTEvent');
//        ApexPages.currentPage().getParameters().put('instanceID', '000000000000000');
//        USTShared.getUSTEventInfo();
//        Test.stopTest();
//    }

    @isTest static void testLetterheadLookup() {
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Test Event', '', true, true);
        UST_Event_Registration__c evtReg = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        UST_Event_Email__c testEvtEmail = TestUSTEventSharedDataFactory.createTestTransactionEmail(evtInst, 'Requested', '');

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testEvtEmail);
        USTEventLetterheadLookupExtension emailController = new USTEventLetterheadLookupExtension(sc);
        emailController.getOrgWideEmail();
        emailController.getLetterheads();

        //Create fake brandTemplate since SF won't let you insert one
        BrandTemplate fakeBrandTemplate = new BrandTemplate(
                Id = TestUSTEventSharedDataFactory.getFakeId(BrandTemplate.SObjectType),
                Name = 'Test',
                value = '<body class="setupTab" ><style background-color="#FFFFFF" bEditID="b1st1" bLabel="body" ></style><center ><table cellpadding="0" width="500" cellspacing="0" id="topTable" height="450" ><tr valign="top" ><td ><style background-color="#FFFFFF" bEditID="r1st1" bLabel="header" vertical-align="top" height="5" text-align="left" ></style><img border="0" bEditID="r1sp1" bLabel="headerImage" id="r1sp1"><![CDATA[/servlet/servlet.ImageServer?id=0150m000000AN8V&oid=00D0m000000Cra6]]></img></td></tr><tr valign="top" ><td ><style background-color="#6600CC" bEditID="r2st1" bLabel="accent1" height="5" ></style><![CDATA[]]></td></tr><tr valign="top" ><td styleInsert="1" height="300" ><style background-color="#FFFFFF" bEditID="r3st1" color="#000000" bLabel="main" font-size="12pt" font-family="arial" ></style><![CDATA[]]></td></tr><tr valign="top" ><td ><style background-color="#6600CC" bEditID="r4st1" bLabel="accent2" height="5" ></style><![CDATA[]]></td></tr><tr valign="top" ><td ><style background-color="#FFFFFF" bEditID="r5st1" bLabel="footer" vertical-align="top" height="125" text-align="left" ></style><img border="0" bEditID="r5sp1" bLabel="footerImage" id="r5sp1"><![CDATA[/servlet/servlet.ImageServer?id=0150m000000AN8U&oid=00D0m000000Cra6]]></img></td></tr><tr valign="top" ><td ><style background-color="#FFFFFF" bEditID="r6st1" bLabel="accent3" height="5" ></style><![CDATA[]]></td></tr></table></center></body>'
        );
        emailController.brandTemplates = new Map<Id, BrandTemplate>();
        emailController.brandTemplates.put(fakeBrandTemplate.Id, fakeBrandTemplate);
        emailController.USTEvt.Letterhead_Id__c = fakeBrandTemplate.Id;


        OrgWideEmailAddress fakeOrgWideEmailAddress = new OrgWideEmailAddress (
                Id = TestUSTEventSharedDataFactory.getFakeId(OrgWideEmailAddress.SObjectType),
                Address = 'thad+owe@valleyhill.net',
                DisplayName = 'Test'
        );
        emailController.oweList = new Map<Id, OrgWideEmailAddress>();
        emailController.oweList.put(fakeOrgWideEmailAddress.Id, fakeOrgWideEmailAddress);
        emailController.USTEvt.Org_Email_Id__c = fakeOrgWideEmailAddress.Id;
        emailController.save();
        Test.stopTest();
    }

    @isTest static void testUSTEventTriggers() {

        // first retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();

        // Create our trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('USTEventAppointmentItinerary_TDTM', 'UST_Event_Appointments__c', 'AfterInsert;AfterUpdate;AfterDelete;AfterUndelete', 2.00));
        tokens.add(new hed.TDTM_Global_API.TdtmToken('USTEventRegistration_TDTM', 'UST_Event_Registration__c', 'AfterInsert;AfterUpdate', 2.00));
        tokens.add(new hed.TDTM_Global_API.TdtmToken('USTEventAppointmentSports_TDTM', 'UST_Event_Appointments__c', 'AfterInsert;', 2.00));

        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);


        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Test Event', '', true, true);
        UST_Event_Email__c testEvtEmail = TestUSTEventSharedDataFactory.createTestTransactionEmail(evtInst, 'Started', '');
        UST_Event_Email__c testEvtEmail2 = TestUSTEventSharedDataFactory.createTestTransactionEmail(evtInst, 'Requested', '');
        UST_Event_Email__c testEvtEmail3 = TestUSTEventSharedDataFactory.createTestTransactionEmail(evtInst, 'Requested', 'On Hold');

        //Email must be added before registration is created
        Contact evtCon = TestUSTEventSharedDataFactory.createContact('MatchFirst', 'Match', 'MatchLast', 'match@valleyhill.net', '55555', '(555) 555-5555', '1971-03-22', '2012');
        UST_Event_Registration__c evtReg = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', evtCon.Id);
        //Contact evtContact = TestUSTEventSharedDataFactory.createContact('TestFirst', 'T', 'TestLast', 'test@valleyhill.net','55418', '', '1971-03-22', '2012');
        //evtReg.Contact__c = evtContact.Id;
        upsert evtReg;

        //UST_Event_Appointments__c addingAppointment = new UST_Event_Appointments__c(Event_Registration__c = testRegistration, Appointment_Type__c);
        Test.startTest();

        List<UST_Event_Email__c> em = [SELECT Id, Action_Status__c, Org_Email_Id__c, Email_Subject__c, Event__c FROM UST_Event_Email__c];

        System.debug('TEST EMAILS FOUND: ' + JSON.serializePretty(em));

        List<UST_Event_Appointments__c> updateRegAppt = [SELECT Id FROM UST_Event_Appointments__c WHERE Event_Registration__c = :evtReg.Id];
        List<UST_Event_Host__c> testHosts = [SELECT Id FROM UST_Event_Host__c WHERE Event_Instance__c = :evtInst.Id];
        System.Debug('HOSTS FOUND :' + testHosts.size());
        List<UST_Event_Appointments__c> dataApptAdd = new List<UST_Event_Appointments__c>();
        dataApptAdd.add(
                new UST_Event_Appointments__c(
                        Id = updateRegAppt[0].Id,
                        Appointment_Status__c = 'Confirmed',
                        Faculty_Staff_Member__c = 'Big Top',
                        Event_Host__c = testHosts[0].Id,
                        Appointment_Time__c = Time.newInstance(14, 30, 0, 0)
                )
        );
        dataApptAdd.add(
                new UST_Event_Appointments__c(
                        Id = updateRegAppt[1].Id,
                        Appointment_Status__c = 'Confirmed',
                        Faculty_Staff_Member__c = 'Big Top',
                        Appointment_Time__c = Time.newInstance(16, 30, 0, 0)
                )
        );
        update dataApptAdd;

        // Update appointment status to requested to fire first trigger email with appointments added above.
        evtReg.Status__c = 'Requested';
        update evtReg;

        // Update appointment status to requested and substatus to On Hold to fire email defined with substatus.
        evtReg.Status__c = 'Requested';
        evtReg.Substatus__c = 'On Hold';
        update evtReg;

        // Triggers foot on campus look up
        evtReg.Status__c = 'Confirmed';
        evtReg.Substatus__c = 'Attended';
        update evtReg;

        TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst2', 'TestLast2', 'test2@valleyhill.net', '55412', '1971-02-22', '2022', null);

        Test.stopTest();
    }

    @isTest static void testUSTApptConfirmTriggerOvernight() {

        // first retrieve default EDA trigger handlers
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getTdtmConfig();

        // Create our trigger handler using the constructor
        tokens.add(new hed.TDTM_Global_API.TdtmToken('USTEventAppointmentItinerary_TDTM', 'UST_Event_Appointments__c', 'AfterInsert;AfterUpdate;AfterDelete;AfterUndelete', 2.00));
        tokens.add(new hed.TDTM_Global_API.TdtmToken('USTEventRegistration_TDTM', 'UST_Event_Registration__c', 'AfterInsert;AfterUpdate', 2.00));

        // Pass trigger handler config to set method for this test run
        hed.TDTM_Global_API.setTdtmConfig(tokens);

        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Overnight Event', '', true, true);
        UST_Event_Registration__c evtReg = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        //UST_Event_Appointments__c addingAppointment = new UST_Event_Appointments__c(Event_Registration__c = testRegistration, Appointment_Type__c);
        Test.startTest();
        List<UST_Event_Appointments__c> dataApptAdd = new List<UST_Event_Appointments__c>();
        List<UST_Event_Appointments__c> updateRegAppt = [SELECT Id FROM UST_Event_Appointments__c WHERE Event_Registration__c = :evtReg.Id];
        List<UST_Event_Host__c> testHosts = [SELECT Id FROM UST_Event_Host__c WHERE Event_Instance__c = :evtInst.Id];

        dataApptAdd.add(
                new UST_Event_Appointments__c(
                        Id = updateRegAppt[0].Id,
                        Appointment_Status__c = 'Confirmed',
                        Faculty_Staff_Member__c = 'Big Top',
                        Event_Host__c = testHosts[0].Id,
                        Appointment_Time__c = Time.newInstance(14, 30, 0, 0)
                )
        );
        dataApptAdd.add(
                new UST_Event_Appointments__c(
                        Id = updateRegAppt[1].Id,
                        Appointment_Status__c = 'Confirmed',
                        Room__c = 'TEST ROOM',
                        Faculty_Staff_Member__c = 'Big Top',
                        Appointment_Time__c = Time.newInstance(16, 30, 0, 0)
                )
        );
        update dataApptAdd;
        Test.stopTest();
    }

    //Test the add to calendar page
    @isTest static void testUSTAddToCalendar() {
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Overnight Event', '', true, true);

        Test.startTest();
        ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        USTEventAddToCalendarController add2Cal = new USTEventAddToCalendarController();
        Test.stopTest();
    }


    //Test the add to calendar page
    @isTest static void testUSTHostAssignment() {
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Overnight Event', '', true, true);
        UST_Event_Registration__c evtReg = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        Test.startTest();
        // ApexPages.currentPage().getParameters().put('instanceID', testInstance.Id);
        List<UST_Event_Appointments__c> updateRegAppt = [SELECT Id, Event_Registration__r.Event_Instance__r.Id, Event_Host__c FROM UST_Event_Appointments__c WHERE Event_Registration__c = :evtReg.Id];
        ApexPages.StandardController sc = new ApexPages.StandardController(updateRegAppt[0]);
        USTEventHostAssignmentExtension hostController = new USTEventHostAssignmentExtension(sc);
        hostController.getRecordTypes();
        hostController.getListHost();
        hostController.assignHost();

        List<UST_Event_Host__c> testHosts = [SELECT Id FROM UST_Event_Host__c WHERE Event_Instance__c = :evtInst.Id];
        //Assign a host from test data
        hostController.hostId = testHosts[0].Id;
        hostController.hostAction = 'assign';
        hostController.assignHost();
        //Get list with already assigned host
        hostController.getListHost();

        //Unassign current host
        hostController.hostId = testHosts[0].Id;
        hostController.hostAction = 'unassign';
        hostController.assignHost();

        //Assign a host with capacity reached
        hostController.hostId = testHosts[1].Id;
        hostController.hostAction = 'assign';
        hostController.assignHost();

        Test.stopTest();
    }

    //Test the add to calendar page
    @isTest static void testUSTProgramFinder() {
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Test Event', '', true, true);
        //creatTestPrograms();
        Test.startTest();
        // ApexPages.currentPage().getParameters().put('instanceID', testInstance.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(new UST_Event__c());
        USTEventProgramLookupExtension progLookupController = new USTEventProgramLookupExtension(sc);
//        progLookupController.getPrograms();
//        progLookupController.save();
//        progLookupController.getPrograms();
        Test.stopTest();
    }

    //Test itinerary printout
    @isTest static void testItineraryPrint() {
        UST_Event_Instance__c evtInst = TestUSTEventSharedDataFactory.createTestEvent('Undergraduate', 'Overnight Event', '', true, true);
        UST_Event_Registration__c evtReg = TestUSTEventSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);


        Test.startTest();

        // ApexPages.currentPage().getParameters().put('instanceID', testInstance.Id);
        List<UST_Event_Appointments__c> updateRegAppt = [SELECT Id, Event_Registration__r.Event_Instance__r.Id, Event_Host__c FROM UST_Event_Appointments__c WHERE Event_Registration__c = :evtReg.Id];
        ApexPages.StandardController sc = new ApexPages.StandardController(updateRegAppt[0]);
        USTEventHostAssignmentExtension hostController = new USTEventHostAssignmentExtension(sc);
        hostController.getRecordTypes();
        hostController.getListHost();
        hostController.assignHost();

        List<UST_Event_Host__c> testHosts = [SELECT Id FROM UST_Event_Host__c WHERE Event_Instance__c = :evtInst.Id];
        //Assign a host from test data
        hostController.hostId = testHosts[0].Id;
        hostController.hostAction = 'assign';
        hostController.assignHost();
        //Get list with already assigned host
        hostController.getListHost();

        //Unassign current host
        hostController.hostId = testHosts[0].Id;
        hostController.hostAction = 'unassign';
        hostController.assignHost();

        //Assign a host with capacity reached
        hostController.hostId = testHosts[1].Id;
        hostController.hostAction = 'assign';
        hostController.assignHost();

        List<UST_Event_Appointments__c> dataApptAdd = new List<UST_Event_Appointments__c>();
        dataApptAdd.add(
                new UST_Event_Appointments__c(
                        Id = updateRegAppt[0].Id,
                        Appointment_Status__c = 'Confirmed',
                        Faculty_Staff_Member__c = 'Big Top',
                        Event_Host__c = testHosts[0].Id,
                        Appointment_Time__c = Time.newInstance(14, 30, 0, 0)
                )
        );
        dataApptAdd.add(
                new UST_Event_Appointments__c(
                        Id = updateRegAppt[1].Id,
                        Appointment_Status__c = 'Confirmed',
                        Room__c = 'TEST ROOM',
                        Faculty_Staff_Member__c = 'Big Top',
                        Appointment_Time__c = Time.newInstance(16, 30, 0, 0)
                )
        );
        update dataApptAdd;


        ApexPages.StandardController sc2 = new ApexPages.StandardController(evtInst);
        USTEventPrintItinerariesExtension itPrint = new USTEventPrintItinerariesExtension(sc2);
        itPrint.getChooseRender();
        itPrint.getIsItWord();
        itPrint.generateDoc();
        itPrint.generatePDF();

        itPrint = new USTEventPrintItinerariesExtension(sc2);
        itPrint.docName = 'admissOvernight';
        ApexPages.currentPage().getParameters().put('docType', 'word');
        itPrint.getChooseRender();
        itPrint.getIsItWord();
        itPrint.generateDoc();
        itPrint.generatePDF();
        //itPrint = new USTEventPrintItinerariesExtension(sc);
        Test.stopTest();
    }


}