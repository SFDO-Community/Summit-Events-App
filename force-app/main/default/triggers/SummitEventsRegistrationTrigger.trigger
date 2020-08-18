trigger SummitEventsRegistrationTrigger on Summit_Events_Registration__c (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert){
        SummitEventsRegistration.run(Trigger.new, Trigger.old);
    }
    if (Trigger.isAfter && Trigger.isUpdate){
        SummitEventsRegistration.run(Trigger.new, Trigger.old);
    }
}