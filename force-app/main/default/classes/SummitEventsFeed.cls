// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 8/09/2018.

@RestResource(UrlMapping='/summiteventsfeed/*')

global with sharing class SummitEventsFeed {

    private static String feedType { get; set; }
    private static Id recTypeId { get; set; }
    private static String namespace { get; set; }

    public class eventItem {
        public String ID { get; set; }
        public String title { get; set; }
        public String title_event { get; set; }
        public String title_instance { get; set; }
        public String instanceDesc { get; set; }
        public String description { get; set; }
        public String longDesc { get; set; }
        public Datetime endDate { get; set; }
        public Datetime start { get; set; }
        public String timezone { get; set; }
        public String eventUrl { get; set; }
        public Boolean eventClosed { get; set; }
        public String className { get; set; }
        public String locationTitle { get; set; }
        public String locationType { get; set; }
        public String locationAddress { get; set; }
        public String locationMapLink { get; set; }
        public String locationBuilding { get; set; }
        public String feedButtonText { get; set; }
        public String sponsors { get; set; }
        public Integer capacityTotal { get; set; }
        public Integer capacityRemaining { get; set; }
        public Boolean excludeSearchTag { get; set; }
    }

    @HttpGet
    global static void getSummitEventsFeed() {
        feedType = RestContext.request.params.get('feedType');
        String recType = RestContext.request.params.get('rectype');

        //Get namespace if packaged
        namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace + '__';
        }

        if (String.isNotBlank(recType)) {
            List<RecordType> recTypeList = [
                    SELECT Id, Name
                    FROM RecordType
                    WHERE SobjectType = :namespace + 'Summit_Event__c'
                    AND Name = :recType
            ];
            if (recTypeList.size() > 0) {
                recTypeId = recTypeList[0].Id;
            }
        }
        RestResponse res = RestContext.response;
        res.addHeader('Access-Control-Max-Age', '86400');
        res.addHeader('Access-Control-Allow-Credentials', 'Server,range,hdntl,hdnts');
        res.addHeader('Access-Control-Expose-Headers', 'Server,range,hdntl,hdnts');
        res.addHeader('Access-Control-Allow-Headers', 'origin,range,hdntl,hdnts');
        res.addHeader('Access-Control-Allow-Origin', '*');
        res.addHeader('Access-Control-Allow-Methods', 'GET');

        String callback = RestContext.request.params.get('callback');
        String serializedJSON = '';

        if (String.isBlank(callback)) {
            res.addHeader('Content-Type', 'application/json');
            callback = '';
        } else {
            res.addHeader('Content-Type', 'application/javascript');
        }

        if (String.isNotBlank(feedType)) {
            if (feedType.equalsIgnoreCase('audienceDD')) {
                serializedJSON = JSON.serialize(getAudienceDD(Summit_Events__c.Audience__c.getDescribe()));
            } else if (feedType.equalsIgnoreCase('sexDD')) {
                serializedJSON = JSON.serialize(getAudienceDD(Summit_Events_Registration__c.Registrant_Gender__c.getDescribe()));
            } else if (feedType.equalsIgnoreCase('eventList')) {
                serializedJSON = JSON.serialize(getEventList());
                serializedJSON = serializedJSON.replace('"endDate":', '"end":');
            } else if (feedType.equalsIgnoreCase('parameterKey')) {
                serializedJSON = JSON.serialize(getOptions());
            }
        }
        if (String.isNotBlank(callback)) {
            serializedJSON = callback + '(' + serializedJSON + ')';
        }
        res.responseBody = Blob.valueOf(serializedJSON);
    }


    private static List<eventItem> getEventList() {

        //Check if account is accessible
        Boolean accountIsAccessible = false;
        if (Schema.SObjectType.Account.isAccessible()) {
            accountIsAccessible = true;
        }

        List<eventItem> EventList = new List<eventItem>();
        RestRequest req = RestContext.request;
        String eventQuery = '';
        eventQuery += ' SELECT Id, Event__r.Name, Event__r.Event_Name__c, Event__r.Event_Status__c, Active_Status__c, Instance_Title__c, Instance_Short_Description__c, Event__r.Program_Filter__c, Event__r.Alternate_Registration_URL__c, ';
        eventQuery += ' Event__r.Location_Title__c, Event__r.Location_Type__c, Event__r.Location_Address__c, Event__r.Location_Map_Link__c, Event__r.Building__c, Event__r.Event_description__c, Event__r.Community_Base_URL__c, ';
        eventQuery += ' Building_Override__c, Alternate_Registration_URL_Override__c, Location_Address_Override__c, Location_Map_Link_Override__c, Location_Title_Override__c, Location_Type_Override__c,  ';
        eventQuery += ' Event__r.Event_Short_Listing_Description__c, Event__r.Audience__c, Event__r.Close_Event_Days_Before__c, Event__r.Event_Sponsor__c, ';
        eventQuery += ' Event__r.Feed_Registration_Button_Text__c, Feed_Registration_Button_Text_Override__c, Capacity__c, Current_Available_Capacity__c, Private_Instance__c, Event__r.Private_Event__c, ';
        eventQuery += ' Instance_Start_Date__c, Instance_End_Date__c, Instance_Start_Time__c, Instance_End_Time__c, Instance_Time_Zone__c, Registration_Close_Date__c, Registration_Close_Time__c   ';
        if (accountIsAccessible) {
            eventQuery += ' , Event__r.Account__r.Name ';
        }
        eventQuery += ' FROM Summit_Events_Instance__c ';
        eventQuery += ' WHERE ';
        eventQuery += ' Event__r.Event_Status__c = \'Active\' ';
        eventQuery += ' AND Active_Status__c = \'Active\' ';
        eventQuery += ' AND Event__r.Private_Event__c = false ';
        eventQuery += ' AND Private_Instance__c = false ';
        eventQuery += ' AND Event__r.Audience__c EXCLUDES (\'No Audience\') ';

        Boolean hideClosed = false;
        if (String.isNotBlank(req.params.get('hideClosed'))) {
            hideClosed = false;
            try {
                hideClosed = Boolean.valueOf(req.params.get('hideClosed'));
            } catch (Exception e) {
            }
        }
        if (hideClosed) {
            eventQuery += ' AND (Current_Available_Capacity__c > 0 OR Capacity__c = null) ';
        }
        // build and sanitize the where statement that have variables

        // get start and end view times convert string to datetime then convert back into string to sanitize
        Datetime viewStart = null;
        Datetime viewEnd = null;
        ///.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String formattedViewStart;
        String formattedViewEnd;
        if (String.isNotBlank(req.params.get('viewStart'))) {
            viewStart = Date.valueOf(String.escapeSingleQuotes(req.params.get('viewStart')));
        }
        //if fullcalendar in use start is passed. start being protected variable
        if (String.isNotBlank(req.params.get('start'))) {
            viewStart = Date.valueOf(req.params.get('start'));
        } else if (viewStart == null) {
            viewStart = Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).addMonths(-1);
        }

        if (String.isNotBlank(req.params.get('viewEnd'))) {
            viewEnd = Date.valueOf(String.escapeSingleQuotes(req.params.get('viewEnd')));
        }
        //if fullcalendar in use end is passed. end being protected variable
        if (String.isNotBlank(req.params.get('end'))) {
            viewEnd = Date.valueOf(req.params.get('end'));
        } else if (viewEnd == null) {
            viewEnd = Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).addMonths(1);

        }

        formattedViewStart = viewStart.format('yyyy-MM-dd');
        formattedViewEnd = viewEnd.format('yyyy-MM-dd');
        eventQuery += ' AND Instance_Start_Date__c >= ' + formattedViewStart + ' ';
        eventQuery += ' AND Instance_Start_Date__c <= ' + formattedViewEnd + ' ';

        //get event based on event id
        String eventId = req.params.get('eventId');
        Id evtId = null;
        try {
            evtId = (Id) eventId;
            eventId = String.valueOf(evtId);
        } catch (Exception e) {
            eventId = null;
        }
        if (String.isNotBlank(eventId)) {
            eventQuery += ' AND Event__r.id = \'' + eventId + '\' ';
        }
        //If the eventId doesn't translate to an id and is present return no instances
        if (String.isNotBlank(req.params.get('eventId')) && String.isBlank(eventId)) {
            return EventList;
        }

        //get event based on audience (can be comma seperated)
        String audience = req.params.get('audience');
        if (audience != 'all' && !String.isBlank(audience)) {
            List<String> audienceList = new List<String>();
            audienceList = audience.split(',');
            for (String aud : audienceList) {
                audience = '\'' + String.escapeSingleQuotes(aud) + '\',';
            }
            audience = audience.removeEnd(',');
            eventQuery += ' AND Event__r.Audience__c INCLUDES (' + audience + ') ';
        }

        //Sponsor filter (can be comma seperated)
        String sponsor = req.params.get('sponsor');
        if (!String.isBlank(sponsor)) {
            List<String> sponsorList = new List<String>();
            sponsorList = sponsor.split(',');
            for (String spon : sponsorList) {
                sponsor = '\'' + String.escapeSingleQuotes(spon) + '\',';
            }
            sponsor = sponsor.removeEnd(',');
            eventQuery += ' AND Event__r.Event_Sponsor__c INCLUDES (' + sponsor + ') ';
        }

        //Display on filter (can be comma separated)
        String displayOn = req.params.get('displayon');
        if (String.isNotBlank(displayOn)) {
            eventQuery += ' AND Event__r.Filter_Where_To_Display__c INCLUDES (' + sanitizeIncludeList(displayOn) + ') ';
        }

        //Category filter (can be comma separated)
        String category = req.params.get('category');
        if (String.isNotBlank(category)) {
            eventQuery += ' AND Event__r.Filter_Category__c INCLUDES (' + sanitizeIncludeList(category) + ') ';
        }

        //Event Type filter. Only accepts one.
        String eventType = req.params.get('type');
        if (String.isNotBlank(eventType)) {
            eventQuery += ' AND Event__r.Event_Type__c = \'' + String.escapeSingleQuotes(eventType) + '\' ';
        }

        //Program filter (can be comma separated)
        String program = req.params.get('program');
        if (String.isNotBlank(program)) {
            String programFields = 'Event__r.Program_Filter__c,Event__r.Program_Filter_2__c,Event__r.Program_Filter_3__c';
            eventQuery += ' AND (' + sanitizeOrLikeList(program, programFields) + ') ';
        }

        //School filter (can be comma separated)
        String school = req.params.get('school');
        if (String.isNotBlank(school) && accountIsAccessible) {
            eventQuery += ' AND (' + sanitizeOrLikeList(school, 'Event__r.Account__r.Name') + ') ';
        }

        //School filter (can be comma separated)
        String accountName = req.params.get('account');
        if (String.isNotBlank(accountName) && accountIsAccessible) {
            eventQuery += ' AND (' + sanitizeOrLikeList(accountName, 'Event__r.Account__r.Name') + ') ';
        }

        //Building filter (can be comma separated)
        String building = req.params.get('building');
        if (String.isNotBlank(building)) {
            eventQuery += ' AND (' + sanitizeOrLikeList(building, 'Event__r.Building__c') + ') ';
        }

        //Building filter (can be comma separated)
        String locationType = req.params.get('locationtype');
        if (String.isNotBlank(locationType)) {
            eventQuery += ' AND ((' + sanitizeOrLikeList(locationType, 'Event__r.Location_Type__c') + ') ';
            eventQuery += ' OR (' + sanitizeOrLikeList(locationType, 'Location_Type_Override__c') + ')) ';
        }

        //get filter with like soql concatinated program,location, school, location address, location type
        String filter = req.params.get('filter');
        if (String.isNotBlank(filter)) {
            String filterFields = 'Event__r.Program_Filter__c,Event__r.Program_Filter_2__c,Event__r.Program_Filter_3__c,Event__r.Location_Title__c,Event__r.Location_Address__c,Event__r.Location_Type__c,Event__r.Building__c';
            eventQuery += ' AND (' + sanitizeOrLikeList(filter, filterFields) + ') ';
        }

        if (String.isNotBlank(recTypeId)) {
            eventQuery += ' AND Event__r.RecordType.Id = \'' + String.valueOf(recTypeId) + '\' ';
        }

        String incomingShowLongDesc = req.params.get('longdesc');
        Boolean showLongDescription = false;
        if (incomingShowLongDesc != null) {
            if (incomingShowLongDesc.toLowerCase() == '1' || incomingShowLongDesc.toLowerCase() == 'true') {
                showLongDescription = true;
            }
        }

        eventQuery += ' WITH SECURITY_ENFORCED ';
        eventQuery += ' ORDER BY Instance_Start_Date__c, Instance_Start_Time__c ';

        List<Summit_Events_Instance__c> EventInstanceList = Database.query(eventQuery);

        Datetime regDateOpenDate = null;
        for (Summit_Events_Instance__c eventInstance : EventInstanceList) {
            regDateOpenDate = Datetime.now().addDays(-1);
            if (eventInstance.Event__r.Close_Event_Days_Before__c != null && eventInstance.Event__r.Close_Event_Days_Before__c != 0) {
                regDateOpenDate = SummitEventsShared.adjustForTimeZone(Datetime.now(), eventInstance.Instance_Time_Zone__c);
                regDateOpenDate = regDateOpenDate.addDays((Integer.valueOf(eventInstance.Event__r.Close_Event_Days_Before__c) + 1));
            }
            eventItem evt = new eventItem();
            evt.ID = eventInstance.Id;

            if (eventInstance.Event__r.Event_Name__c != null) {
                evt.title = SummitEventsShared.removeHTMLandEscape(eventInstance.Event__r.Event_Name__c, true);
                evt.title_event = SummitEventsShared.removeHTMLandEscape(eventInstance.Event__r.Event_Name__c, true);
            } else {
                evt.title = SummitEventsShared.removeHTMLandEscape(eventInstance.Event__r.Name, true);
                evt.title_event = SummitEventsShared.removeHTMLandEscape(eventInstance.Event__r.Name, true);
            }

            if (String.isNotBlank(eventInstance.Instance_Title__c)) {
                evt.title += ' - ' + SummitEventsShared.removeHTMLandEscape(eventInstance.Instance_Title__c, true);
                evt.title_instance = SummitEventsShared.removeHTMLandEscape(eventInstance.Instance_Title__c, true);
            }

            if (String.isNotBlank(eventInstance.Instance_Short_Description__c)) {
                evt.instanceDesc = SummitEventsShared.removeHTMLandEscape(eventInstance.Instance_Short_Description__c, true);
            } else {
                evt.instanceDesc = '';
            }

            evt.excludeSearchTag = false;

//            if (eventInstance.Event__r.Exclude_Search_Engine_Tag__c || eventInstance.Exclude_Search_Engine_Tag_Override__c) {
//                evt.excludeSearchTag = true;
//            }

            if (String.isNotBlank(eventInstance.Feed_Registration_Button_Text_Override__c)) {
                evt.feedButtonText = SummitEventsShared.removeHTMLandEscape(eventInstance.Feed_Registration_Button_Text_Override__c, true);
            } else if (String.isNotBlank(eventInstance.Event__r.Feed_Registration_Button_Text__c)) {
                evt.feedButtonText = SummitEventsShared.removeHTMLandEscape(eventInstance.Event__r.Feed_Registration_Button_Text__c, true);
            } else {
                evt.feedButtonText = 'Register';
            }

            if (String.isNotBlank(eventInstance.Instance_Time_Zone__c)) {
                evt.timezone = eventInstance.Instance_Time_Zone__c;
            }

            if (String.isNotBlank(eventInstance.Location_Type_Override__c)) {
                evt.locationType = SummitEventsShared.removeHTMLandEscape(eventInstance.Location_Type_Override__c, true);
            } else if (String.isNotBlank(eventInstance.Event__r.Location_Type__c)) {
                evt.locationType = eventInstance.Event__r.Location_Type__c;
            } else {
                evt.locationType = '';
            }

            if (String.isNotBlank(eventInstance.Event__r.Event_Sponsor__c)) {
                evt.sponsors = eventInstance.Event__r.Event_Sponsor__c;
            } else {
                evt.sponsors = '';
            }

            if (String.isNotBlank(eventInstance.Event__r.Building__c)) {
                evt.locationBuilding = eventInstance.Event__r.Building__c;
            } else {
                evt.locationBuilding = '';
            }

            if (String.isNotBlank(eventInstance.Event__r.Event_Short_Listing_Description__c)) {
                evt.description = SummitEventsShared.removeHTMLandEscape(eventInstance.Event__r.Event_Short_Listing_Description__c, true);
            } else {
                evt.description = '';
            }

            if (showLongDescription) {
                evt.longDesc = eventInstance.Event__r.Event_description__c;
            } else {
                evt.longDesc = '';
            }

            if (Integer.valueOf(eventInstance.Capacity__c) != null) {
                evt.capacityTotal = Integer.valueOf(eventInstance.Capacity__c);
            } else {
                evt.capacityTotal = 0;
            }

            if (Integer.valueOf(eventInstance.Current_Available_Capacity__c) != null) {
                evt.capacityRemaining = Integer.valueOf(eventInstance.Current_Available_Capacity__c);
            } else {
                evt.capacityRemaining = 0;
            }

            if (eventInstance.Instance_Start_Date__c != null) {
                evt.start = SummitEventsShared.convertDateToDatetime(eventInstance.Instance_Start_Date__c, eventInstance.Instance_Start_Time__c, '');

            }
            if (eventInstance.Instance_End_Date__c != null) {
                evt.endDate = SummitEventsShared.convertDateToDatetime(eventInstance.Instance_End_Date__c, eventInstance.Instance_End_Time__c, '');
            }

            if (String.isNotBlank(eventInstance.Event__r.Location_Title__c) || String.isNotBlank(eventInstance.Location_Title_Override__c)) {
                if (String.isNotBlank(eventInstance.Location_Title_Override__c)) {
                    evt.locationTitle = SummitEventsShared.removeHTMLandEscape(eventInstance.Location_Title_Override__c, true);
                } else {
                    evt.locationTitle = SummitEventsShared.removeHTMLandEscape(eventInstance.Event__r.Location_Title__c, true);
                }
            } else {
                evt.locationTitle = '';
            }

            if (String.isNotBlank(eventInstance.Event__r.Location_Address__c) || !String.isBlank(eventInstance.Location_Address_Override__c)) {
                if (String.isNotBlank(eventInstance.Location_Address_Override__c)) {
                    evt.locationAddress = SummitEventsShared.removeHTMLandEscape(eventInstance.Location_Address_Override__c, true);
                } else {
                    evt.locationAddress = SummitEventsShared.removeHTMLandEscape(eventInstance.Event__r.Location_Address__c, true);
                }
            } else {
                evt.locationAddress = '';
            }

            if (String.isNotBlank(eventInstance.Event__r.Location_Map_Link__c) || String.isNotBlank(eventInstance.Location_Map_Link_Override__c)) {
                if (!String.isBlank(eventInstance.Location_Map_Link_Override__c)) {
                    evt.locationMapLink = SummitEventsShared.removeHTMLandEscape(eventInstance.Location_Map_Link_Override__c, false);
                } else {
                    evt.locationMapLink = SummitEventsShared.removeHTMLandEscape(eventInstance.Event__r.Location_Map_Link__c, false);
                }
            } else {
                evt.locationMapLink = '';
            }

            if (SummitEventsShared.isEventClosed(eventInstance)) {
                evt.eventClosed = true;
                evt.eventUrl = 'javascript:;';
                evt.className = 'eventClosed';
                if (!hideClosed) {
                    EventList.add(evt);
                }
            } else {
                evt.eventClosed = false;
                if (!String.isBlank(eventInstance.Event__r.Alternate_Registration_URL__c) || !String.isBlank(eventInstance.Alternate_Registration_URL_Override__c)) {
                    if (!String.isBlank(eventInstance.Alternate_Registration_URL_Override__c)) {
                        evt.eventUrl = SummitEventsShared.removeHTMLandEscape(eventInstance.Alternate_Registration_URL_Override__c, false);
                    } else {
                        evt.eventUrl = SummitEventsShared.removeHTMLandEscape(eventInstance.Event__r.Alternate_Registration_URL__c, false);
                    }

                } else {
                    evt.eventUrl = eventInstance.Event__r.Community_Base_URL__c + namespace + 'SummitEventsRegister?instanceID=' + eventInstance.Id;
                }
                evt.className = 'eventOpened';
                EventList.add(evt);
            }
        }
        return EventList;
    }

    private static String sanitizeIncludeList(String listIn) {
        String listOut = '';
        if (String.isNotBlank(listIn)) {
            List<String> listInList = new List<String>();
            listInList = listIn.split(',');
            for (String listItem : listInList) {
                listOut += '\'' + String.escapeSingleQuotes(listItem.trim()) + '\',';
            }
            listOut = listOut.removeEnd(',');

            return listOut;
        }
        return '';
    }

    private static String sanitizeOrLikeList(String items, String fieldsToCompare) {
        if (String.isNotBlank(items) && String.isNotBlank(fieldsToCompare)) {
            String queryOut = '';
            List<String> itemList = items.split(',');
            List<String> fieldList = fieldsToCompare.split(',');
            for (String item : itemList) {
                for (String field : fieldList) {
                    queryOut += ' ( ' + field + ' LIKE \'%' + String.escapeSingleQuotes(item.trim()) + '%\' ) OR ';
                }
            }
            queryOut = queryOut.removeEnd(' OR ');
            return queryOut;
        }
        return '';
    }

    private static Map<String, String> getAudienceDD(Schema.DescribeFieldResult fieldResult) {
        Map<String, String> fieldMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            if (!f.getLabel().equalsIgnoreCase('No Audience')) {
                fieldMap.put(f.getLabel(), f.getValue());
            }
        }
        return fieldMap;
    }

    private static List<String> getObjectItemList(Schema.DescribeFieldResult fieldResult) {
        List<String> fieldMap = new List<String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            fieldMap.add(f.getValue());
        }
        return fieldMap;
    }

    private class optionList {
        String parameter;
        String description;
        List<String> options;
    }

    private static List<optionList> getOptions() {
        List<optionList> allOptions = new List<optionList>();

        //FeedType
        allOptions.add(makeOption('feedType', new List<String>{
                'audienceDD', 'sexDD', 'eventList', 'parameterKey'
        }, 'Must be included to get any feed (&feedType= one of these items)'));

        //Record Types
        List<RecordType> recTypeList = [SELECT Id, Name FROM RecordType WHERE SobjectType = :namespace + 'Summit_Events__c'];
        List<String> recTypeNames = new List<String>();
        for (RecordType rt : recTypeList) {
            recTypeNames.add(rt.Name);
        }

        allOptions.add(makeOption('rectype', recTypeNames, 'filters on salesforce record type (&rectype= one of these items)'));

        //View start
        allOptions.add(makeOption('viewStart', new List<String>{
                Datetime.now().addMonths(-1).format()
        }, 'The date scope of the feed start. Defaults to current month -1. (&viewStart=)'));

        //View end
        allOptions.add(makeOption('viewEnd', new List<String>{
                Datetime.now().addMonths(1).format()
        }, 'The date scope of the feed end. Defaults to current month +1. (&viewEnd=)'));

        //eventId
        allOptions.add(makeOption('eventId', new List<String>{
        }, 'Shows only the instances under the event umbrella (&eventId= Salesforce Id for the event)'));

        //audience
        allOptions.add(makeOption('audience', (List<String>) getAudienceDD(Summit_Events__c.Audience__c.getDescribe()).values(), 'Filters on audiences (&audience= single or coma separated list of these items)'));

        //Event type
        allOptions.add(makeOption('type', getObjectItemList(Summit_Events__c.Event_Type__c.getDescribe()), 'Filters on event type (&type= single item only)'));

        //sponsor
        allOptions.add(makeOption('sponsor', getObjectItemList(Summit_Events__c.Event_Sponsor__c.getDescribe()), 'Filters on sponsor (&sponsor= single or coma separated list of these items)'));

        //displayon
        allOptions.add(makeOption('displayon', getObjectItemList(Summit_Events__c.Filter_Where_To_Display__c.getDescribe()), 'Filters on where in the digital world you want to display events(&displayon= single or coma separated list of these items)'));

        //category
        allOptions.add(makeOption('category', getObjectItemList(Summit_Events__c.Filter_Category__c.getDescribe()), 'Filters category picklist events (&category= single or coma separated list of these items)'));

        //longdesc
        allOptions.add(makeOption('longdesc', new List<String>{
                'true', 'false', '0', '1'
        }, 'If set to 1 or true will show the long description of the event'));

        //filter
        allOptions.add(makeOption('filter', new List<String>{
                'Program_Filter', 'Location_Title', 'Location_Address', 'Building'
        }, 'Searches all the fields listed in options as a like statement allowing for a broader search of location information. (&filter= single or coma separated list of these items)'));

        //filter-Location
        allOptions.add(makeOption('account', new List<String>{
        }, 'Filter events on the name of an account associated to the event via the account lookup field.'));

        //locationtype
        allOptions.add(makeOption('locationtype',getObjectItemList(Summit_Events__c.Location_Type__c.getDescribe()), 'Filter events on the location type set on the event or the override on an instance of the event.'));
        //filter-Building
        allOptions.add(makeOption('building', getObjectItemList(Summit_Events__c.Building__c.getDescribe()), 'Filter searches with a like statement all of these items. (&building= single or coma separated list of these items)'));

        //filter-School name
        //allOptions.add(makeOption('filter+school', CRUDtoDo.getSchools(), 'Filter searches with a like statement all of these items. (&filter= single or coma separated list of these items)'));
        return allOptions;
    }

    private static optionList makeOption(String options, List<String> items, String description) {
        optionList newOption = new optionList();
        newOption.parameter = options;
        newOption.description = description;
        newOption.options = items;
        return newOption;
    }
}