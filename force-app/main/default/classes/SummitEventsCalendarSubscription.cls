public class SummitEventsCalendarSubscription {

    public static void checkUniqueSubscription(List<Summit_Events_Calendar_Subscription__c> new_subs) {
        for(Summit_Events_Calendar_Subscription__c sub : new_subs) {
            List<Summit_Events_Calendar_Subscription__c> existing_subs = [SELECT id FROM Summit_Events_Calendar_Subscription__c WHERE Summit_Events_Instance__c = :sub.Summit_Events_Instance__c AND Calendar_Subscriber__c = :sub.Calendar_Subscriber__c];
            
            if(!existing_subs.isEmpty()) {
                sub.addError('Duplicate subscription');
            }
        }
    }
}