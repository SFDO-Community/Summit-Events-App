// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.

public without sharing class SummitEventsTriggerHandler {

    // Runs every Html-type (Rich Text Area) field on the incoming records through the sanitizeRichText
    // denylist filter before save, so guest-facing pages can keep escape="false" and preserve staff
    // formatting while still blocking script/iframe/event-handler/javascript: payloads regardless of
    // write path (standard UI editor, Data Loader, REST/SOAP/Tooling API).
    // Hardcoded rather than describe-detected: Schema.DescribeFieldResult has no supported way to
    // distinguish a Rich Text (Html) field from a plain Long Text Area at runtime - both describe as
    // DisplayType.TEXTAREA. Keep this list in sync with any new Html field added to Summit_Events__c.
    private static final List<String> RICH_TEXT_FIELD_NAMES = new List<String>{
            'Donation_Description__c', 'Event_Footer__c', 'Event_Payment_Due_Description__c',
            'Event_Submit_Description__c', 'Event_Additional_Questions_Description__c', 'Event_description__c',
            'Event_Appointment_Description__c', 'Event_Cancel_Review_Description__c', 'Event_Confirmation_Description__c',
            'Event_Full_Text__c', 'Event_Payment_Received_Description__c', 'Guest_Registration_Description__c'
    };

    public static void sanitizeRichTextFields(List<Summit_Events__c> newList) {
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Summit_Events__c.fields.getMap();
        for (Summit_Events__c evt : newList) {
            for (String fieldName : RICH_TEXT_FIELD_NAMES) {
                if (fieldMap.containsKey(fieldName)) {
                    Object fieldValue = evt.get(fieldName);
                    if (fieldValue instanceof String) {
                        evt.put(fieldName, SummitEventsShared.sanitizeRichText((String) fieldValue));
                    }
                }
            }
        }
    }

}
