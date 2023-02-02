/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/1/2023.
 */


trigger SummitEventsAppointmentTrigger on Summit_Events_Appointments__c (after insert, after update, after delete, after undelete) {

    Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
    if (!SummitEventsSettings.Turn_off_Appointment_Trigger__c) {
        if (Trigger.isAfter) {
            SummitEventsAppointmentTriggerHandler.generateItineraries(Trigger.new, Trigger.old);
        }
    }

}