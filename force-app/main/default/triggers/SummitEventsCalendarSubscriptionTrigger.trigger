trigger SummitEventsCalendarSubscriptionTrigger on Summit_Events_Calendar_Subscription__c (before insert, before update) {
  SummitEventsCalendarSubscription.checkUniqueSubscription(trigger.new);
}