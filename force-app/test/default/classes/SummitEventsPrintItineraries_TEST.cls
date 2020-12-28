// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsPrintItineraries_TEST {
    @IsTest static void testItineraryPrint() {
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Overnight Event', '', true, true, '');
        Summit_Events_Registration__c evtReg = SummitEventsTestSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        Test.startTest();

        // ApexPages.currentPage().getParameters().put('instanceID', testInstance.Id);
        List<Summit_Events_Appointments__c> updateRegAppt = [SELECT Id, Event_Registration__r.Event_Instance__r.Id, Event_Host__c FROM Summit_Events_Appointments__c WHERE Event_Registration__c = :evtReg.Id];
        ApexPages.StandardController sc = new ApexPages.StandardController(updateRegAppt[0]);
        SummitEventsHostAssignmentExtension hostController = new SummitEventsHostAssignmentExtension(sc);
        hostController.getRecordTypes();
        hostController.getListHost();
        hostController.assignHost();

        List<Summit_Events_Host__c> testHosts = [SELECT Id FROM Summit_Events_Host__c WHERE Event_Instance__c = :evtInst.Id];
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

        List<Summit_Events_Appointments__c> dataApptAdd = new List<Summit_Events_Appointments__c>();
        dataApptAdd.add(
                new Summit_Events_Appointments__c(
                        Id = updateRegAppt[0].Id,
                        Appointment_Status__c = 'Confirmed',
                        Faculty_Staff_Member__c = 'Big Top',
                        Event_Host__c = testHosts[0].Id,
                        Appointment_Time__c = Time.newInstance(14, 30, 0, 0)
                )
        );
        dataApptAdd.add(
                new Summit_Events_Appointments__c(
                        Id = updateRegAppt[1].Id,
                        Appointment_Status__c = 'Confirmed',
                        Room__c = 'TEST ROOM',
                        Faculty_Staff_Member__c = 'Big Top',
                        Appointment_Time__c = Time.newInstance(16, 30, 0, 0)
                )
        );
        update dataApptAdd;


        ApexPages.StandardController sc2 = new ApexPages.StandardController(evtInst);
        SummitEventsPrintItinerariesExtension itPrint = new SummitEventsPrintItinerariesExtension(sc2);
        itPrint.getChooseRender();
        itPrint.getIsItWord();
        itPrint.generateDoc();
        itPrint.generatePDF();

        itPrint = new SummitEventsPrintItinerariesExtension(sc2);
        itPrint.docName = 'admissOvernight';
        ApexPages.currentPage().getParameters().put('docType', 'word');
        itPrint.getChooseRender();
        itPrint.getIsItWord();
        itPrint.generateDoc();
        itPrint.generatePDF();
        //itPrint = new SummitEventsPrintItinerariesExtension(sc);
        Test.stopTest();
    }
}