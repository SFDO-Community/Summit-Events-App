/**
 * Created by dahl3702 on 4/29/2019.
 */

trigger TDTM_USTEventRegistration on UST_Event_Registration__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    hed.TDTM_Global_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.UST_Event_Registration__c);
}