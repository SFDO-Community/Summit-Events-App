trigger SummitEventsLeadTrigger on Lead (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        SummitEventsAfterLeadConversion.afterUpdate(Trigger.new);
    }
}