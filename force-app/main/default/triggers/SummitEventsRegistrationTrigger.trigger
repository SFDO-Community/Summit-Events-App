trigger SummitEventsRegistrationTrigger on Summit_Events_Registration__c (before insert, before update, after insert, after update) {
    /* Caused issues, reason unknown
    if (Trigger.isBefore && Trigger.isInsert) {
        SummitEventsContactMatching SECM = new SummitEventsContactMatching();
        SECM.matchContacts(Trigger.new);
    } */
    if (Trigger.isBefore && Trigger.isUpdate) {
        SummitEventsContactMatching.matchContacts(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        SummitEventsRegistration.run(Trigger.new, Trigger.old);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        SummitEventsRegistration.run(Trigger.new, Trigger.old);
    }
}