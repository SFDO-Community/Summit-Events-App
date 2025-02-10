trigger SummitEventsRegistrationTrigger on Summit_Events_Registration__c (before insert, before update, after insert, after update) {

    Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
    if (!SummitEventsSettings.Turn_off_Registration_Trigger__c) {

        // isBefore isUpdate because SEA pages immediately update on next page and asynchronous matching can't keep up
        if (Trigger.isBefore && Trigger.isInsert || Trigger.isBefore && Trigger.isUpdate) {
            SummitEventsContactMatching.matchReg(Trigger.new, Trigger.old);
        }

        if (Trigger.isAfter && Trigger.isInsert) {
            SummitEventsRegistration.run(Trigger.new, Trigger.old);
        }
        if (Trigger.isAfter && Trigger.isUpdate) {
            SummitEventsRegistration.run(Trigger.new, Trigger.old);
        }
    }
}