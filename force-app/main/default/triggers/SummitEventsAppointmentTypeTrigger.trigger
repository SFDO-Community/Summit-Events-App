trigger SummitEventsAppointmentTypeTrigger on Summit_Events_Appointment_Type__c (after insert, after update) {
    Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
    if (!SummitEventsSettings.Turn_off_Appointment_Type_Trigger__c && SummitEventsSettings.Opt_Into_Link_Automation__c) {
        SummitEventsLinkHandler.run(Trigger.newMap);
    }
}