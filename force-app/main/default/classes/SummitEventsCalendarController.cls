// Copyright (c) 2026, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found in the LICENSE file in this repository.

public without sharing class SummitEventsCalendarController {

    /**
     * Holds the filter criteria passed from the LWC calendar component.
     */
    public class CalendarFilters {
        @AuraEnabled public String audience { get; set; }
        @AuraEnabled public String recordType { get; set; }
        @AuraEnabled public String displayOn { get; set; }
        @AuraEnabled public String category { get; set; }
        @AuraEnabled public String eventType { get; set; }
        @AuraEnabled public String program { get; set; }
        @AuraEnabled public String sponsor { get; set; }
        @AuraEnabled public String building { get; set; }
        @AuraEnabled public String locationType { get; set; }
        @AuraEnabled public Boolean hideClosed { get; set; }
        @AuraEnabled public String viewStart { get; set; }
        @AuraEnabled public String viewEnd { get; set; }
    }

    /**
     * Represents a single event instance formatted for FullCalendar consumption.
     */
    public class CalendarEventItem {
        @AuraEnabled public String instanceId { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String titleEvent { get; set; }
        @AuraEnabled public String titleInstance { get; set; }
        @AuraEnabled public String instanceDescription { get; set; }
        @AuraEnabled public String shortDescription { get; set; }
        @AuraEnabled public String startDatetime { get; set; }
        @AuraEnabled public String endDatetime { get; set; }
        @AuraEnabled public String timezone { get; set; }
        @AuraEnabled public Boolean eventClosed { get; set; }
        @AuraEnabled public String cssClass { get; set; }
        @AuraEnabled public String locationTitle { get; set; }
        @AuraEnabled public String locationType { get; set; }
        @AuraEnabled public String locationAddress { get; set; }
        @AuraEnabled public String locationMapLink { get; set; }
        @AuraEnabled public String locationBuilding { get; set; }
        @AuraEnabled public String registerButtonText { get; set; }
        @AuraEnabled public String alternateRegistrationUrl { get; set; }
        @AuraEnabled public Integer capacityTotal { get; set; }
        @AuraEnabled public Integer capacityRemaining { get; set; }
    }

    /**
     * Represents an option in the audience dropdown.
     */
    public class AudienceOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        public AudienceOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    /**
     * Returns the list of active Audience picklist values for the audience dropdown,
     * excluding the "No Audience" sentinel value.
     *
     * @return List of AudienceOption label/value pairs
     */
    @AuraEnabled(Cacheable=true)
    public static List<AudienceOption> getAudienceOptions() {
        List<AudienceOption> options = new List<AudienceOption>();
        List<Schema.PicklistEntry> picklistEntries =
            Summit_Events__c.Audience__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            if (entry.isActive() && !entry.getLabel().equalsIgnoreCase('No Audience')) {
                options.add(new AudienceOption(entry.getLabel(), entry.getValue()));
            }
        }
        return options;
    }

    /**
     * Returns calendar event items matching the supplied filters and date window.
     * All filter parameters are optional — omitting them returns all active public events
     * within the date window.
     *
     * @param filters CalendarFilters object with optional filter criteria
     * @return List of CalendarEventItem records formatted for FullCalendar
     */
    @AuraEnabled
    public static List<CalendarEventItem> getCalendarEvents(CalendarFilters filters) {
        List<CalendarEventItem> calendarEvents = new List<CalendarEventItem>();

        Boolean accountIsAccessible = Schema.SObjectType.Account.isAccessible();

        // Build base query
        String eventQuery = 'SELECT Id, Event__r.Name, Event__r.Event_Name__c, Event__r.Event_Status__c,';
        eventQuery += ' Active_Status__c, Instance_Title__c, Instance_Short_Description__c,';
        eventQuery += ' Event__r.Program_Filter__c, Event__r.Program_Filter_2__c, Event__r.Program_Filter_3__c,';
        eventQuery += ' Event__r.Alternate_Registration_URL__c, Event__r.Location_Title__c,';
        eventQuery += ' Event__r.Location_Type__c, Event__r.Location_Address__c,';
        eventQuery += ' Event__r.Location_Map_Link__c, Event__r.Building__c,';
        eventQuery += ' Event__r.Event_Short_Listing_Description__c, Event__r.Audience__c,';
        eventQuery += ' Event__r.Close_Event_Days_Before__c, Event__r.Event_Sponsor__c,';
        eventQuery += ' Event__r.Feed_Registration_Button_Text__c,';
        eventQuery += ' Feed_Registration_Button_Text_Override__c,';
        eventQuery += ' Capacity__c, Current_Available_Capacity__c,';
        eventQuery += ' Private_Instance__c, Event__r.Private_Event__c,';
        eventQuery += ' Building_Override__c, Alternate_Registration_URL_Override__c,';
        eventQuery += ' Location_Address_Override__c, Location_Map_Link_Override__c,';
        eventQuery += ' Location_Title_Override__c, Location_Type_Override__c,';
        eventQuery += ' Instance_Start_Date__c, Instance_End_Date__c,';
        eventQuery += ' Instance_Start_Time__c, Instance_End_Time__c,';
        eventQuery += ' Instance_Time_Zone__c, Registration_Close_Date__c,';
        eventQuery += ' Registration_Close_Time__c';
        if (accountIsAccessible) {
            eventQuery += ', Event__r.Account__r.Name';
        }
        eventQuery += ' FROM Summit_Events_Instance__c';
        eventQuery += ' WHERE Event__r.Event_Status__c = \'Active\'';
        eventQuery += ' AND Active_Status__c = \'Active\'';
        eventQuery += ' AND Event__r.Private_Event__c = false';
        eventQuery += ' AND Private_Instance__c = false';
        eventQuery += ' AND (Event__r.Audience__c = null OR Event__r.Audience__c EXCLUDES (\'No Audience\'))';

        // Date window
        Date windowStart;
        Date windowEnd;
        if (filters != null && String.isNotBlank(filters.viewStart)) {
            try {
                windowStart = Date.valueOf(filters.viewStart);
            } catch (Exception ignored) {}
        }
        if (filters != null && String.isNotBlank(filters.viewEnd)) {
            try {
                windowEnd = Date.valueOf(filters.viewEnd);
            } catch (Exception ignored) {}
        }
        if (windowStart == null) {
            windowStart = Date.today().addMonths(-1);
        }
        if (windowEnd == null) {
            windowEnd = Date.today().addMonths(3);
        }
        // Use bind variables for dates to avoid injection and formatting issues
        eventQuery += ' AND Instance_Start_Date__c >= :windowStart';
        eventQuery += ' AND Instance_Start_Date__c <= :windowEnd';

        // hideClosed filter
        if (filters != null && filters.hideClosed == true) {
            eventQuery += ' AND (Current_Available_Capacity__c > 0 OR Capacity__c = null)';
        }

        // Audience filter (comma-separated multi-value)
        if (filters != null && String.isNotBlank(filters.audience) && filters.audience != 'all') {
            String sanitizedAudience = buildIncludeList(filters.audience);
            if (String.isNotBlank(sanitizedAudience)) {
                eventQuery += ' AND Event__r.Audience__c INCLUDES (' + sanitizedAudience + ')';
            }
        }

        // Sponsor filter
        if (filters != null && String.isNotBlank(filters.sponsor)) {
            String sanitizedSponsor = buildIncludeList(filters.sponsor);
            if (String.isNotBlank(sanitizedSponsor)) {
                eventQuery += ' AND Event__r.Event_Sponsor__c INCLUDES (' + sanitizedSponsor + ')';
            }
        }

        // Display on filter
        if (filters != null && String.isNotBlank(filters.displayOn)) {
            String sanitizedDisplayOn = buildIncludeList(filters.displayOn);
            if (String.isNotBlank(sanitizedDisplayOn)) {
                eventQuery += ' AND Event__r.Filter_Where_To_Display__c INCLUDES (' + sanitizedDisplayOn + ')';
            }
        }

        // Category filter
        if (filters != null && String.isNotBlank(filters.category)) {
            String sanitizedCategory = buildIncludeList(filters.category);
            if (String.isNotBlank(sanitizedCategory)) {
                eventQuery += ' AND Event__r.Filter_Category__c INCLUDES (' + sanitizedCategory + ')';
            }
        }

        // Event type filter (single value)
        if (filters != null && String.isNotBlank(filters.eventType)) {
            eventQuery += ' AND Event__r.Event_Type__c = \'' + String.escapeSingleQuotes(filters.eventType) + '\'';
        }

        // Program filter
        if (filters != null && String.isNotBlank(filters.program)) {
            String programFields = 'Event__r.Program_Filter__c,Event__r.Program_Filter_2__c,Event__r.Program_Filter_3__c';
            eventQuery += ' AND (' + buildOrLikeClause(filters.program, programFields) + ')';
        }

        // Building filter
        if (filters != null && String.isNotBlank(filters.building)) {
            eventQuery += ' AND (' + buildOrLikeClause(filters.building, 'Event__r.Building__c') + ')';
        }

        // Location type filter
        if (filters != null && String.isNotBlank(filters.locationType)) {
            eventQuery += ' AND ((' + buildOrLikeClause(filters.locationType, 'Event__r.Location_Type__c') + ')';
            eventQuery += ' OR (' + buildOrLikeClause(filters.locationType, 'Location_Type_Override__c') + '))';
        }

        // Record type filter
        if (filters != null && String.isNotBlank(filters.recordType)) {
            List<RecordType> matchingRecordTypes = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Summit_Events__c'
                AND Name = :filters.recordType
                LIMIT 1
            ];
            if (!matchingRecordTypes.isEmpty()) {
                Id recordTypeId = matchingRecordTypes[0].Id;
                eventQuery += ' AND Event__r.RecordType.Id = \'' + String.valueOf(recordTypeId) + '\'';
            }
        }

        eventQuery += ' ORDER BY Instance_Start_Date__c, Instance_Start_Time__c';

        List<Summit_Events_Instance__c> instanceList = Database.query(eventQuery);

        for (Summit_Events_Instance__c instance : instanceList) {
            CalendarEventItem calendarEvent = new CalendarEventItem();
            calendarEvent.instanceId = instance.Id;
            calendarEvent.eventClosed = false;

            // Title
            String eventName = String.isNotBlank(instance.Event__r.Event_Name__c)
                ? SummitEventsShared.removeHTMLandEscape(instance.Event__r.Event_Name__c, true)
                : SummitEventsShared.removeHTMLandEscape(instance.Event__r.Name, true);
            calendarEvent.titleEvent = eventName;
            calendarEvent.title = eventName;
            if (String.isNotBlank(instance.Instance_Title__c)) {
                calendarEvent.titleInstance = SummitEventsShared.removeHTMLandEscape(instance.Instance_Title__c, true);
                calendarEvent.title += ' - ' + calendarEvent.titleInstance;
            }

            // Instance description
            calendarEvent.instanceDescription = String.isNotBlank(instance.Instance_Short_Description__c)
                ? SummitEventsShared.removeHTMLandEscape(instance.Instance_Short_Description__c, true)
                : '';

            // Short description
            calendarEvent.shortDescription = String.isNotBlank(instance.Event__r.Event_Short_Listing_Description__c)
                ? SummitEventsShared.removeHTMLandEscape(instance.Event__r.Event_Short_Listing_Description__c, true)
                : '';

            // Dates
            if (instance.Instance_Start_Date__c != null) {
                Datetime startDatetime = SummitEventsShared.convertDateToDatetime(
                    instance.Instance_Start_Date__c, instance.Instance_Start_Time__c, '');
                calendarEvent.startDatetime = startDatetime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            }
            if (instance.Instance_End_Date__c != null) {
                Datetime endDatetime = SummitEventsShared.convertDateToDatetime(
                    instance.Instance_End_Date__c, instance.Instance_End_Time__c, '');
                calendarEvent.endDatetime = endDatetime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            }

            calendarEvent.timezone = instance.Instance_Time_Zone__c;

            // Register button text
            if (String.isNotBlank(instance.Feed_Registration_Button_Text_Override__c)) {
                calendarEvent.registerButtonText = SummitEventsShared.removeHTMLandEscape(
                    instance.Feed_Registration_Button_Text_Override__c, true);
            } else if (String.isNotBlank(instance.Event__r.Feed_Registration_Button_Text__c)) {
                calendarEvent.registerButtonText = SummitEventsShared.removeHTMLandEscape(
                    instance.Event__r.Feed_Registration_Button_Text__c, true);
            } else {
                calendarEvent.registerButtonText = 'Register';
            }

            // Location title
            if (String.isNotBlank(instance.Location_Title_Override__c)) {
                calendarEvent.locationTitle = SummitEventsShared.removeHTMLandEscape(
                    instance.Location_Title_Override__c, true);
            } else {
                calendarEvent.locationTitle = String.isNotBlank(instance.Event__r.Location_Title__c)
                    ? SummitEventsShared.removeHTMLandEscape(instance.Event__r.Location_Title__c, true)
                    : '';
            }

            // Location type
            if (String.isNotBlank(instance.Location_Type_Override__c)) {
                calendarEvent.locationType = SummitEventsShared.removeHTMLandEscape(
                    instance.Location_Type_Override__c, true);
            } else {
                calendarEvent.locationType = String.isNotBlank(instance.Event__r.Location_Type__c)
                    ? instance.Event__r.Location_Type__c
                    : '';
            }

            // Location address
            if (String.isNotBlank(instance.Location_Address_Override__c)) {
                calendarEvent.locationAddress = SummitEventsShared.removeHTMLandEscape(
                    instance.Location_Address_Override__c, true);
            } else {
                calendarEvent.locationAddress = String.isNotBlank(instance.Event__r.Location_Address__c)
                    ? SummitEventsShared.removeHTMLandEscape(instance.Event__r.Location_Address__c, true)
                    : '';
            }

            // Location map link
            if (String.isNotBlank(instance.Location_Map_Link_Override__c)) {
                calendarEvent.locationMapLink = SummitEventsShared.removeHTMLandEscape(
                    instance.Location_Map_Link_Override__c, false);
            } else {
                calendarEvent.locationMapLink = String.isNotBlank(instance.Event__r.Location_Map_Link__c)
                    ? SummitEventsShared.removeHTMLandEscape(instance.Event__r.Location_Map_Link__c, false)
                    : '';
            }

            calendarEvent.locationBuilding = String.isNotBlank(instance.Event__r.Building__c)
                ? instance.Event__r.Building__c
                : '';

            // Capacity
            calendarEvent.capacityTotal = instance.Capacity__c != null
                ? Integer.valueOf(instance.Capacity__c)
                : 0;
            calendarEvent.capacityRemaining = instance.Current_Available_Capacity__c != null
                ? Integer.valueOf(instance.Current_Available_Capacity__c)
                : 0;

            // Alternate registration URL or closed state
            if (SummitEventsShared.isEventClosed(instance, instance.Event__r.Event_Status__c)) {
                calendarEvent.eventClosed = true;
                calendarEvent.cssClass = 'sea-event-closed';
            } else {
                calendarEvent.cssClass = 'sea-event-open';
                if (String.isNotBlank(instance.Alternate_Registration_URL_Override__c)) {
                    calendarEvent.alternateRegistrationUrl = SummitEventsShared.removeHTMLandEscape(
                        instance.Alternate_Registration_URL_Override__c, false);
                } else if (String.isNotBlank(instance.Event__r.Alternate_Registration_URL__c)) {
                    calendarEvent.alternateRegistrationUrl = SummitEventsShared.removeHTMLandEscape(
                        instance.Event__r.Alternate_Registration_URL__c, false);
                }
            }

            calendarEvents.add(calendarEvent);
        }

        return calendarEvents;
    }

    /**
     * Builds a safe SOQL INCLUDES list from a comma-separated input string.
     *
     * @param items Comma-separated string of values to include
     * @return Formatted SOQL INCLUDES clause content
     */
    private static String buildIncludeList(String items) {
        if (String.isBlank(items)) {
            return '';
        }
        String result = '';
        for (String item : items.split(',')) {
            result += '\'' + String.escapeSingleQuotes(item.trim()) + '\',';
        }
        return result.removeEnd(',');
    }

    /**
     * Builds a safe SOQL OR LIKE clause for multi-field text searching.
     *
     * @param items Comma-separated search terms
     * @param fieldsCsv Comma-separated field API names to search against
     * @return SOQL OR LIKE clause string
     */
    private static String buildOrLikeClause(String items, String fieldsCsv) {
        if (String.isBlank(items) || String.isBlank(fieldsCsv)) {
            return '1=1';
        }
        String clause = '';
        List<String> itemList = items.split(',');
        List<String> fieldList = fieldsCsv.split(',');
        for (String item : itemList) {
            for (String field : fieldList) {
                clause += ' (' + field + ' LIKE \'%' + String.escapeSingleQuotes(item.trim()) + '%\') OR';
            }
        }
        return clause.removeEnd(' OR');
    }
}

