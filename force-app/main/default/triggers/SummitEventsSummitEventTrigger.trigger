trigger SummitEventsSummitEventTrigger on Summit_Events__c (before insert, before update, after insert, after update) {
    Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
    if (!SummitEventsSettings.Turn_off_Summit_Events_Trigger__c) {
        if (SummitEventsSettings.Convert_images_to_public_access__c) {
            if (Trigger.isInsert && Trigger.isAfter) {
                SummitEventsLinkHandler.run(Trigger.newMap);
            }
            if (Trigger.isUpdate && Trigger.isAfter) {
                SummitEventsLinkHandler.run(Trigger.newMap);
            }
        }
    }
}