// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsHostAssignment_TEST {
    @IsTest static void testSEHostAssignment() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c evtReg = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        Test.startTest();
        // ApexPages.currentPage().getParameters().put('instanceID', testInstance.Id);
        List<Summit_Events_Appointments__c> updateRegistrationAppointments = [SELECT Id, Event_Registration__r.Event_Instance__r.Id, Event_Host__c FROM Summit_Events_Appointments__c WHERE Event_Registration__c = :evtReg.Id];
        ApexPages.StandardController sc = new ApexPages.StandardController(updateRegistrationAppointments[0]);
        SummitEventsHostAssignmentExtension hostController = new SummitEventsHostAssignmentExtension(sc);
        hostController.getRecordTypes();
        hostController.getListHost();
        hostController.assignHost();

        List<Summit_Events_Host__c> testHosts = [SELECT Id FROM Summit_Events_Host__c WHERE Event_Instance__c = :seaTestInstances[1].Id];
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
}