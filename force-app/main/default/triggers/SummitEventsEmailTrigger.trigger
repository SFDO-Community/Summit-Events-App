trigger SummitEventsEmailTrigger on Summit_Events_Email__c (after insert, after update) {
    Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
    if (!SummitEventsSettings.Turn_off_Email_Trigger__c && SummitEventsSettings.Convert_images_to_public_access__c) {
        SummitEventsLinkHandler.run(Trigger.newMap);
    }
}