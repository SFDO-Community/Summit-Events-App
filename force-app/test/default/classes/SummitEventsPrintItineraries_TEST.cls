// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsPrintItineraries_TEST {
    @IsTest static void testItineraryPrint() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        List<Summit_Events_Host__c> testHosts = SummitEventsTestSharedDataFactory.createHosts(seaTestInstances[1].Id);
        List<Summit_Events_Appointment_Type__c> testAppointmentTypes = SummitEventsTestSharedDataFactory.createAppointmentTypes(seaTestInstances[1].Event__c);
        List<Summit_Events_Appointments__c> testAppointments = new List<Summit_Events_Appointments__c>();

        for (Summit_Events_Appointment_Type__c appointmentType : testAppointmentTypes) {
            Summit_Events_Appointments__c appointment = new Summit_Events_Appointments__c();
            appointment.Event_Registration__c = seaTestRegistration.Id;
            testAppointments.add(appointment);
        }
        insert testAppointments;

        Test.startTest();

        // ApexPages.currentPage().getParameters().put('instanceID', testInstance.Id);
        List<Summit_Events_Appointments__c> updateRegistrationAppointments = [SELECT Id, Event_Registration__r.Event_Instance__r.Id, Event_Host__c FROM Summit_Events_Appointments__c WHERE Event_Registration__c = :seaTestRegistration.Id];
        ApexPages.StandardController sc = new ApexPages.StandardController(updateRegistrationAppointments[0]);
        SummitEventsHostAssignmentExtension hostController = new SummitEventsHostAssignmentExtension(sc);
        hostController.getRecordTypes();
        hostController.getListHost();
        hostController.assignHost();

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

        List<Summit_Events_Appointments__c> dataAppointmentAdd = new List<Summit_Events_Appointments__c>();
        dataAppointmentAdd.add(
                new Summit_Events_Appointments__c(
                        Id = updateRegistrationAppointments[0].Id,
                        Appointment_Status__c = 'Confirmed',
                        Faculty_Staff_Member__c = 'Big Top',
                        Event_Host__c = testHosts[0].Id,
                        Appointment_Time__c = Time.newInstance(14, 30, 0, 0)
                )
        );
        dataAppointmentAdd.add(
                new Summit_Events_Appointments__c(
                        Id = updateRegistrationAppointments[1].Id,
                        Appointment_Status__c = 'Confirmed',
                        Room__c = 'TEST ROOM',
                        Faculty_Staff_Member__c = 'Big Top',
                        Appointment_Time__c = Time.newInstance(16, 30, 0, 0)
                )
        );
        update dataAppointmentAdd;


        ApexPages.StandardController sc2 = new ApexPages.StandardController(seaTestInstances[1]);
        SummitEventsPrintItinerariesExtension itPrint = new SummitEventsPrintItinerariesExtension(sc2);
        System.assertEquals(itPrint.getChooseRender(), null);
        System.assertEquals(itPrint.getIsItWord(), null);
        System.assertEquals(itPrint.generateDoc().getUrl(), null);
        System.assertEquals(itPrint.generatePDF().getUrl(), null);

        itPrint = new SummitEventsPrintItinerariesExtension(sc2);
        itPrint.docName = 'admissOvernight';

        ApexPages.currentPage().getParameters().put('docType', 'word');
        System.assertEquals(itPrint.getChooseRender(), null);
        String testStartDate = String.valueOf(seaTestInstances[1].Instance_Start_Date__c);
        testStartDate = testStartDate.replace(' 00:00:00','');
        System.assertEquals(itPrint.getIsItWord(), 'application/msword#Test_Event_'+ testStartDate + '.doc');

        ApexPages.currentPage().getParameters().put('docName', 'testingDocument');
        itPrint = new SummitEventsPrintItinerariesExtension(sc2);
        System.assertEquals(itPrint.getIsItWord(), 'application/msword#Test_Event_'+ testStartDate + '.doc');

        ApexPages.currentPage().getParameters().remove('docType');
        ApexPages.currentPage().getParameters().put('docType', 'pdf');
        System.assertEquals(itPrint.getChooseRender(), 'pdf');
        System.assertEquals(itPrint.generatePDF().getUrl(), null);

        Test.stopTest();
    }
}