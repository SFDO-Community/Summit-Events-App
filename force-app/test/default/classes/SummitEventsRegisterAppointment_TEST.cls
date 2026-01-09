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
        Summit_Events_Appointment_Type__c limitedAppointType = testAppointmentTypes[0];
        limitedAppointType.Appointment_Registrations_Limit__c = 1;
        limitedAppointType.Enforce_Registrations_Limit__c = true;
        update limitedAppointType;

        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        System.runAs(testUser) {
            Test.startTest();

            String namespace = SummitEventsNamespace.StrTokenNSPrefix('');

            PageReference pageRef = Page.SummitEventsRegisterAppointments;
            Test.setCurrentPage(pageRef);

            SummitEventsRegisterAppointmentCtlr optionsCtrl = new SummitEventsRegisterAppointmentCtlr();

            //Check event with no id should return home link to site
            PageReference checkPage = optionsCtrl.checkEventDetails();
            System.assertEquals(checkPage.getUrl(), 'https://google.com/' + namespace + 'SummitEvents');

            SummitEventsShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, true);
            optionsCtrl = new SummitEventsRegisterAppointmentCtlr();

            //Check event details should return null because event
            checkPage = optionsCtrl.checkEventDetails();
            System.assertEquals(checkPage, null);

            //previous page should be registration page
            System.assertEquals(optionsCtrl.previousPage().getUrl(), '/apex/' + namespace + 'summiteventsregister');

            pageRef.getParameters().put('adminopen', 'true');
            optionsCtrl = new SummitEventsRegisterAppointmentCtlr();
            //previous page should be registration page with included admin open added to URL above
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
            System.assertEquals(optionsCtrl.appointments.size(), 4);
            Test.stopTest();
        }
    }
}