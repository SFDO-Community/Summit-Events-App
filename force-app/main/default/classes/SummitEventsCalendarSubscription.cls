public class SummitEventsCalendarSubscription {

    public static void checkUniqueSubscription(List<Summit_Events_Calendar_Subscription__c> newSubs) {
        for(Summit_Events_Calendar_Subscription__c sub : newSubs) {
            List<Summit_Events_Calendar_Subscription__c> existing_subs = [SELECT id FROM Summit_Events_Calendar_Subscription__c WHERE Summit_Events_Instance__c = :sub.Summit_Events_Instance__c AND Calendar_Subscriber__c = :sub.Calendar_Subscriber__c];
            
            if(existing_subs.size() > 0) {
                sub.addError('Duplicate subscription');
            }
        }
    }
}
