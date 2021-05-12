trigger SummitEventsInstanceTrigger on Summit_Events_Instance__c (after insert) {
  SummitEventsInstance.addSubscription(trigger.new);
}