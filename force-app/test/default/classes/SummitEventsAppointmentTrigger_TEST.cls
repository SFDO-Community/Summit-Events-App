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
        updateEvent.Itinerary_Label_1__c = 'TEST LABEL 1';
        updateEvent.Itinerary_Item_1__c = 'Appointment_Title__c';
        updateEvent.Itinerary_Label_2__c = 'TEST LABEL 1';
        updateEvent.Itinerary_Item_2__c = 'Description__c';
        update updateEvent;

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
            System.assertEquals('<b>TEST TITLE 2</b><br/>TEST Description<br/><br/>', affectedEvent.Generated_Requested_Appointments__c);
            System.assertEquals('<b>TEST TITLE 2</b><br/>TEST Description', affectedEvent.Generated_Itinerary__c);
        }
    }
}