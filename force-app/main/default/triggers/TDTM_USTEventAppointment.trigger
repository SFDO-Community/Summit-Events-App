/**
 * Created by dahl3702 on 4/30/2019.
 */

trigger TDTM_USTEventAppointment on UST_Event_Appointments__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    hed.TDTM_Global_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.UST_Event_Appointments__c);
}