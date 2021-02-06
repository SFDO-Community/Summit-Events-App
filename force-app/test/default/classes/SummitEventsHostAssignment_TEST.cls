// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsHostAssignment_TEST {
    @IsTest static void testSEHostAssignment() {
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
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Admin');
        System.runAs(testUser) {
            Test.startTest();
            // ApexPages.currentPage().getParameters().put('instanceID', testInstance.Id);
            List<Summit_Events_Appointments__c> updateRegistrationAppointments = [SELECT Id, Event_Registration__r.Event_Instance__r.Id, Event_Host__c FROM Summit_Events_Appointments__c WHERE Event_Registration__c = :seaTestRegistration.Id];
            ApexPages.StandardController sc = new ApexPages.StandardController(updateRegistrationAppointments[0]);
            SummitEventsHostAssignmentExtension hostController = new SummitEventsHostAssignmentExtension(sc);
            hostController.getRecordTypes();
            hostController.getListHost();
            hostController.assignHost();

            testHosts = [SELECT Id FROM Summit_Events_Host__c WHERE Event_Instance__c = :seaTestInstances[1].Id];
            //Assign a host from test data
            hostController.hostId = testHosts[0].Id;
            hostController.hostAction = 'assign';
            hostController.assignHost();
            Summit_Events_Host__c testAssignedHost = [SELECT Id, Assigned__c FROM Summit_Events_Host__c WHERE Id = :testHosts[0].Id];
            System.assertEquals(testAssignedHost.Assigned__c, 1);
            //Get list with already assigned host
            hostController.getListHost();

            //Unassign current host
            hostController.hostId = testHosts[0].Id;
            hostController.hostAction = 'unassign';
            hostController.assignHost();
            testAssignedHost = [SELECT Id, Assigned__c FROM Summit_Events_Host__c WHERE Id = :testHosts[0].Id];
            System.assertEquals(testAssignedHost.Assigned__c, 0);

            //Assign a host with capacity reached
            hostController.hostId = testHosts[1].Id;
            hostController.hostAction = 'assign';
            hostController.assignHost();
            testAssignedHost = [SELECT Id, Assigned__c FROM Summit_Events_Host__c WHERE Id = :testHosts[1].Id];
            System.assertEquals(testAssignedHost.Assigned__c, 10);

            Test.stopTest();
        }
    }
}