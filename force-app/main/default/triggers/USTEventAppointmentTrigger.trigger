/**
 * Created by dahl3702 on 9/28/2018.
 */

trigger USTEventAppointmentTrigger on UST_Event_Appointments__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerDispatcher.dispatch(USTEventAppointmentTriggerHandler.Factory.class);
}