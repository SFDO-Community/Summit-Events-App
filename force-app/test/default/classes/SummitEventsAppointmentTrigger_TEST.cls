/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/7/2023.
 */


@IsTest
private class SummitEventsAppointmentTrigger_TEST {
    @IsTest
    static void testRequestedAppointment() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        List<Summit_Events_Appointment_Type__c> testAppointmentTypes = SummitEventsTestSharedDataFactory.createAppointmentTypes(seaTestInstances[1].Event__c);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        //Create an appointment
        Summit_Events_Appointments__c newAppointment = new Summit_Events_Appointments__c();
        newAppointment.Event_Registration__c = seaTestRegistration.Id;
        newAppointment.Event_Appointment_Type__c = testAppointmentTypes[0].Id;
        newAppointment.Appointment_Status__c = 'Requested';
        newAppointment.Appointment_Title__c = 'TEST TITLE';
        insert newAppointment;
        Summit_Events_Registration__c affectedEvent = [SELECT Id, Generated_Requested_Appointments__c FROM Summit_Events_Registration__c WHERE Id = :seaTestRegistration.Id];

        System.runAs(testUser) {
            System.assertEquals('<b>TEST TITLE</b>', affectedEvent.Generated_Requested_Appointments__c);
        }
    }

    @IsTest
    static void testConfirmedAppointment() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        List<Summit_Events_Appointment_Type__c> testAppointmentTypes = SummitEventsTestSharedDataFactory.createAppointmentTypes(seaTestInstances[1].Event__c);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        //Create an appointment
        Summit_Events_Appointments__c newAppointment = new Summit_Events_Appointments__c();
        newAppointment.Event_Registration__c = seaTestRegistration.Id;
        newAppointment.Event_Appointment_Type__c = testAppointmentTypes[0].Id;
        newAppointment.Appointment_Status__c = 'Confirmed';
        newAppointment.Description__c = 'TEST Description';
        newAppointment.Appointment_Title__c = 'TEST TITLE 2';
        insert newAppointment;
        Summit_Events_Registration__c affectedEvent = [SELECT Id, Generated_Requested_Appointments__c, Generated_Itinerary__c FROM Summit_Events_Registration__c WHERE Id = :seaTestRegistration.Id];

        System.runAs(testUser) {
            System.assertEquals('<b>TEST TITLE 2</b><br/>TEST Description', affectedEvent.Generated_Requested_Appointments__c);
            System.assertEquals(null, affectedEvent.Generated_Itinerary__c, 'Itinerary not set up in event so none created');
        }
    }

    @IsTest
    static void testConfirmedAppointmentWithSetup() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        List<Summit_Events_Appointment_Type__c> testAppointmentTypes = SummitEventsTestSharedDataFactory.createAppointmentTypes(seaTestInstances[1].Event__c);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        //Set up appointments on event
        Summit_Events__c updateEvent = new Summit_Events__c(Id = seaTestInstances[0].Event__c);
        updateEvent.Itinerary_Display_Options__c = 'Labels as headers';
        updateEvent.Itinerary_Label_1__c = 'TEST TITLE LABEL';
        updateEvent.Itinerary_Item_1__c = 'Appointment_Title__c';
        updateEvent.Itinerary_Label_2__c = 'TEST DESCRIPTION LABEL';
        updateEvent.Itinerary_Item_2__c = 'Description__c';
        update updateEvent;

        //Create an appointment
        List<Summit_Events_Appointments__c> testListAppointments = new List<Summit_Events_Appointments__c>();
        for (Integer x = 0; x < 6; x++) {
            Summit_Events_Appointments__c newAppointment = new Summit_Events_Appointments__c();
            newAppointment.Event_Registration__c = seaTestRegistration.Id;
            newAppointment.Event_Appointment_Type__c = testAppointmentTypes[0].Id;
            if (Math.mod(x, 2) == 0) {
                newAppointment.Appointment_Status__c = 'Confirmed';
            } else {
                newAppointment.Appointment_Status__c = 'Requested';
            }
            newAppointment.Description__c = 'TEST Description ' + x;
            newAppointment.Appointment_Title__c = 'TEST TITLE ' + x;
            testListAppointments.add(newAppointment);
        }
        insert testListAppointments;

        Summit_Events_Registration__c affectedEvent = [SELECT Id, Generated_Requested_Appointments__c, Generated_Itinerary__c FROM Summit_Events_Registration__c WHERE Id = :seaTestRegistration.Id];

        System.runAs(testUser) {
            System.assertEquals('<b>TEST TITLE 0</b><br/>TEST Description 0<br/><br/><b>TEST TITLE 1</b><br/>TEST Description 1<br/><br/><b>TEST TITLE 2</b><br/>TEST Description 2<br/><br/><b>TEST TITLE 3</b><br/>TEST Description 3<br/><br/><b>TEST TITLE 4</b><br/>TEST Description 4<br/><br/><b>TEST TITLE 5</b><br/>TEST Description 5', affectedEvent.Generated_Requested_Appointments__c);
            System.assertEquals('<b>TEST TITLE LABEL</b><br/>TEST TITLE 0<br/><b>TEST DESCRIPTION LABEL</b><br/>TEST Description 0<br/><br/><b>TEST TITLE LABEL</b><br/>TEST TITLE 2<br/><b>TEST DESCRIPTION LABEL</b><br/>TEST Description 2<br/><br/><b>TEST TITLE LABEL</b><br/>TEST TITLE 4<br/><b>TEST DESCRIPTION LABEL</b><br/>TEST Description 4', affectedEvent.Generated_Itinerary__c);
        }
    }
}