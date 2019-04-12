/**
 * Created by dahl3702 on 10/8/2018.
 */

trigger USTEventRegistrationTrigger on UST_Event_Registration__c (after insert, after update, after delete, after undelete) {
    TriggerHandlerDispatcher.dispatch(USTEventRegistrationTriggerHandler.Factory.class);
}