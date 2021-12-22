// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsRegisterAppointment_TEST {
    @IsTest static void testRegWithOptions() {

        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        List<Summit_Events_Appointment_Type__c> testAppointmentTypes = SummitEventsTestSharedDataFactory.createAppointmentTypes(seaTestInstances[1].Event__c);

        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        System.runAs(testUser) {
            Test.startTest();

            String namespace = SummitEventsNamespace.getNamespace();
            if (String.isNotBlank(namespace)) {
                namespace = namespace + '__';
            }

            PageReference pageRef = Page.SummitEventsRegisterAppointments;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);

            SummitEventsRegisterAppointmentCtlr optionsCtrl = new SummitEventsRegisterAppointmentCtlr();
            SummitEventsShared SEShared = new SummitEventsShared();
            SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);
            optionsCtrl = new SummitEventsRegisterAppointmentCtlr();

            //optionsCtrl.checkEventDetails();
            pageRef.getParameters().remove('adminopen');
            pageRef.getParameters().put('adminopen', 'true');
            System.assertEquals(optionsCtrl.previousPage().getUrl(), '/apex/' + namespace + 'summiteventsregister?adminopen=true');

            List<Summit_Events_Appointments__c> testAppointments = [SELECT Id, Event_Registration__c FROM Summit_Events_Appointments__c WHERE Event_Registration__c = :seaTestRegistration.Id];
            System.assertEquals(testAppointments.size(), 0);

            optionsCtrl.incomingAppointmentJSON = '[]';
            optionsCtrl.saveOptions();

            String jsonAppointments = '[';
            for (Summit_Events_Appointment_Type__c at : testAppointmentTypes) {
                jsonAppointments += '{';
                jsonAppointments += '"appId":"' + at.Id + '",';
                jsonAppointments += '"appCategory":"' + at.Appointment_Category__c + '",';
                jsonAppointments += '"appType":"' + at.Appointment_Type__c + '",';
                jsonAppointments += '"appText":"",';
                jsonAppointments += '"appTitle":"' + at.Title__c + '"';
                jsonAppointments += '},';
            }
            jsonAppointments = jsonAppointments.removeEnd(',');
            jsonAppointments += ']';
            optionsCtrl.incomingAppointmentJSON = jsonAppointments;
            optionsCtrl.saveOptions();

            testAppointments = [SELECT Id, Event_Registration__c FROM Summit_Events_Appointments__c WHERE Event_Registration__c = :seaTestRegistration.Id];
            System.assertEquals(testAppointments.size(), 5);

            //run constructor again to simulate page load after save
            seaTestRegistration.UG_Event_Appointments__r.add(new Summit_Events_Appointments__c(Client_Created_Appointment__c = true));
            optionsCtrl = new SummitEventsRegisterAppointmentCtlr();
            Test.stopTest();
        }
    }
}