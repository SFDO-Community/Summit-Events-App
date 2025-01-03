trigger SummitEventsRegistrationTrigger on Summit_Events_Registration__c (before insert, before update, after insert, after update) {
    /* Caused issues, reason unknown
    if (Trigger.isBefore && Trigger.isInsert) {
        SummitEventsContactMatching SECM = new SummitEventsContactMatching();
        SECM.matchContacts(Trigger.new);
    } */
    Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
    if (!SummitEventsSettings.Turn_off_Registration_Trigger__c) {
        if (Trigger.isBefore) {
            if (Trigger.isUpdate || Trigger.isInsert) {
                SummitEventsContactMatching.matchContacts(Trigger.new);
            }
        }

        if (Trigger.isAfter && Trigger.isInsert) {
            SummitEventsRegistration.run(Trigger.new, Trigger.old);
        }
        if (Trigger.isAfter && Trigger.isUpdate) {
            SummitEventsRegistration.run(Trigger.new, Trigger.old);
        }
    }
}