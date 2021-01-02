// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsRegisterAppointment_TEST {
    @IsTest static void testRegWithOptions() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        List<Summit_Events_Appointment_Type__c> testAppointmentTypes = SummitEventsTestSharedDataFactory.createAppointmentTypes(seaTestInstances[1].Event__c);
//        List<Summit_Events_Appointments__c> testAppointments = new List<Summit_Events_Appointments__c>();
//        for (Summit_Events_Appointment_Type__c appointmentType : testAppointmentTypes) {
//            Summit_Events_Appointments__c appointment = new Summit_Events_Appointments__c();
//            appointment.Event_Registration__c = seaTestRegistration.Id;
//            testAppointments.add(appointment);
//        }
//        insert testAppointments;

        Test.startTest();
        SummitEventsRegisterAppointmentCtlr optionsCtrl = new SummitEventsRegisterAppointmentCtlr();

        SummitEventsShared SEShared = new SummitEventsShared();
        SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);

        optionsCtrl = new SummitEventsRegisterAppointmentCtlr();

        //optionsCtrl.checkEventDetails();
        optionsCtrl.previousPage();

        optionsCtrl.incomingAppointmentJSON = '[]';
        optionsCtrl.saveOptions();

        String jsonAppointments = '[';
        for (Summit_Events_Appointment_Type__c at : testAppointmentTypes) {
            jsonAppointments += '{"apptId":"' + at.Id + '","apptCategory":"","apptType":"","apptText":"","apptTitle":"' + at.Title__c + '"},';
        }
        jsonAppointments = jsonAppointments.removeEnd(',');
        jsonAppointments += ']';
        optionsCtrl.incomingAppointmentJSON = jsonAppointments;
        optionsCtrl.saveOptions();

        //run constructor again to simulate page load after save
        seaTestRegistration.UG_Event_Appointments__r.add(new Summit_Events_Appointments__c(Client_Created_Appointment__c = true));
        optionsCtrl = new SummitEventsRegisterAppointmentCtlr();
        Test.stopTest();
    }
}