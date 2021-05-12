public with sharing class SummitEventsInstance {
    public static void addSubscription(List<Summit_Events_Instance__c> new_instances) {
        for(Summit_Events_Instance__c my_instance : new_instances) {
            String user_id = UserInfo.getUserId();
            String subscription_instance = my_instance.Id;
            Summit_Events_Settings__c custom_settings = Summit_Events_Settings__c.getInstance(user_id);
            
            if(custom_settings.Automatically_Subscribe_Calendar__c) {
                Summit_Events_Calendar_Subscription__c my_subscription = new Summit_Events_Calendar_Subscription__c(Calendar_Subscriber__c = user_id, Summit_Events_Instance__c = subscription_instance);
                insert my_subscription;
            }
        }
    }
}
