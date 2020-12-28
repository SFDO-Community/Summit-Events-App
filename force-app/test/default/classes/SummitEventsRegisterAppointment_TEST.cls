// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsRegisterAppointment_TEST {
    @IsTest static void testRegWithOptions() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Test Event', '', true, true, '');
        Summit_Events_Registration__c evtReg = SummitEventsTestSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        Test.startTest();
        SummitEventsRegisterAppointmentCtlr optionsCtrl = new SummitEventsRegisterAppointmentCtlr();

        SummitEventsShared SEShared = new SummitEventsShared();
        SEShared.createEncryptedCookie('Transfer',evtInst.Id,evtInst.Event__c, evtReg.Id);

        optionsCtrl = new SummitEventsRegisterAppointmentCtlr();

        //optionsCtrl.checkEventDetails();
        optionsCtrl.previousPage();

        optionsCtrl.incomingAppointmentJSON = '[]';
        optionsCtrl.saveOptions();

        //[{"apptId":"a010m000003EibeAAC","apptCategory":"","apptType":"","apptText":"","apptTitle":"Multi colored socks for everyone"},{"apptId":"a010m000003EibUAAS","apptCategory":"","apptType":"","apptText":"","apptTitle":"Red Socks Only"}]

        List<Summit_Events_Appointment_Type__c> newApptTypes = [SELECT Id, Title__c FROM Summit_Events_Appointment_Type__c WHERE Summit_Events__c = :evtInst.Event__c];
        String jsonAppts = '[';
        for (Summit_Events_Appointment_Type__c at : newApptTypes) {
            jsonAppts += '{"apptId":"' + at.Id + '","apptCategory":"","apptType":"","apptText":"","apptTitle":"' + at.Title__c + '"},';
        }
        jsonAppts = jsonAppts.removeEnd(',');
        jsonAppts += ']';
        optionsCtrl.incomingAppointmentJSON = jsonAppts;
        optionsCtrl.saveOptions();

        //run constructor again to simulate page load after save
        evtReg.UG_Event_Appointments__r.add(new Summit_Events_Appointments__c(Client_Created_Appointment__c = true));
        optionsCtrl = new SummitEventsRegisterAppointmentCtlr();
        Test.stopTest();
    }
}