/**
 * Sanitizes staff-authored Rich Text fields on the event definition record before save.
 * See SummitEventsTriggerHandler.sanitizeRichTextFields for details.
 */

trigger SummitEventsTrigger on Summit_Events__c (before insert, before update) {

    SummitEventsTriggerHandler.sanitizeRichTextFields(Trigger.new);

}
