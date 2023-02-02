trigger SummitEventsLeadTrigger on Lead (after update) {


    Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
    if (!SummitEventsSettings.Turn_off_Lead_Trigger__c) {
        if (Trigger.isAfter && Trigger.isUpdate) {
            SummitEventsAfterLeadConversion.afterUpdate(Trigger.new);
        }
    }
}