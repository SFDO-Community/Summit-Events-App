trigger SummitEventsRegistrationTrigger on Summit_Events_Registration__c (before insert, before update, after insert, after update) {
    /* Caused issues, reason unknown
    if (Trigger.isBefore && Trigger.isInsert) {
        SummitEventsContactMatching SECM = new SummitEventsContactMatching();
        SECM.matchContacts(Trigger.new);
    } 
    if (Trigger.isBefore && Trigger.isUpdate) {
        SummitEventsContactMatching.matchContacts(Trigger.new);
    }
*/
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        SummitEventsRegistration.handleIsAfterInsertOrUpdateTrigger(Trigger.new, Trigger.isUpdate ? Trigger.oldMap : null);
    }
}