// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsSubmit_TEST {

    @IsTest static void testSubmit() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        Test.startTest();
        PageReference pageRef = Page.SummitEventsSubmit;
        pageRef.getParameters().put('adminopen', 'true');
        Test.setCurrentPage(pageRef);

        SummitEventsShared SEShared = new SummitEventsShared();
        SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);

        //ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances.Id);
        SummitEventsSubmitController submitCtrl = new SummitEventsSubmitController();
        System.assertEquals(submitCtrl.checkEventDetails(), null);
        System.assertEquals(submitCtrl.previousPage().getUrl(), '/apex/summiteventsregister?adminopen=true');
        System.assertEquals(submitCtrl.submitRegistration().getUrl(), '/apex/summiteventsconfirmation?adminopen=true');
        Test.stopTest();
    }

    @IsTest static void testSubmitWithAppointments() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        List<Summit_Events_Appointment_Type__c> testAppointmentTypes = SummitEventsTestSharedDataFactory.createAppointmentTypes(seaTestInstances[1].Event__c);
        List<Summit_Events_Appointments__c> testAppointments = new List<Summit_Events_Appointments__c>();
        for (Summit_Events_Appointment_Type__c appointmentType : testAppointmentTypes) {
            Summit_Events_Appointments__c appointment = new Summit_Events_Appointments__c();
            appointment.Event_Registration__c = seaTestRegistration.Id;
            testAppointments.add(appointment);
        }
        insert testAppointments;

        Test.startTest();
        PageReference pageRef = Page.SummitEventsSubmit;
        Test.setCurrentPage(pageRef);
        SummitEventsShared SEShared = new SummitEventsShared();
        SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);

        //ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances.Id);
        SummitEventsSubmitController submitCtrl = new SummitEventsSubmitController();
        System.assertEquals(submitCtrl.previousPage().getUrl(), '/apex/summiteventsregisterappointments');
        System.assertEquals(submitCtrl.submitRegistration().getUrl(), '/apex/summiteventsconfirmation');
        Test.stopTest();

    }


    @IsTest static void testSubmitWithFees() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        List<Summit_Events_Fee_Allocation__c> testFeeAllocations = SummitEventsTestSharedDataFactory.AddFeesToEvent(seaTestInstances[1].Event__c);
        SummitEventsTestSharedDataFactory.AddDonationsToEvents(seaTestInstances[1].Event__c, testFeeAllocations);
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        //Get all the variations of user input to make a appointment type for each
        List<String> feeTypes = new List<String>();
        Schema.DescribeFieldResult fieldResult = Summit_events_Fee__c.Event_Fee_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            feeTypes .add(pickListVal.getLabel());
        }

        List<Summit_Events_Fee__c> testFees = new List<Summit_Events_Fee__c>();
        for (String feeType : feeTypes) {
            Summit_Events_Fee__c fee = new Summit_Events_Fee__c();
            fee.Event_Fee_type__c = feeType;
            fee.Event_Registration__c = seaTestRegistration.Id;
            fee.Event_Fee__c = 10.00;
            fee.Description__c = feeType + ' Fee';
            testFees.add(fee);
        }
        insert testFees;

        Test.startTest();
        PageReference pageRef = Page.SummitEventsSubmit;
        Test.setCurrentPage(pageRef);
        SummitEventsShared SEShared = new SummitEventsShared();
        SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);

        //ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances.Id);
        SummitEventsSubmitController submitCtrl = new SummitEventsSubmitController();
        System.assertEquals(submitCtrl.previousPage().getUrl(), '/apex/summiteventsdonation');
        System.assertEquals(submitCtrl.submitRegistration().getUrl(), '/apex/summiteventsconfirmation');
        Test.stopTest();

    }

}