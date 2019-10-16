// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 8/09/2018.

@RestResource(urlMapping='/usteventfeed/*')

global with sharing class USTEventFeed {

    private static String feedType { get; set; }
    private static USTEventShared USTShared = new USTEventShared();
    private static Id recTypeId { get; set; }

    private Class eventItem {
        public String ID { get; set; }
        public String title { get; set; }
        public String instanceDesc { get; set; }
        public String description { get; set; }
        public String longDesc { get; set; }
        public Datetime endDate { get; set; }
        public DateTime start { get; set; }
        public String eventUrl { get; set; }
        public Boolean eventClosed { get; set; }
        public String className { get; set; }
        public String locationTitle { get; set; } 
        public String locationType { get; set; }
        public String locationAddress { get; set; }
        public String locationMapLink { get; set; }
        public String locationBuilding { get; set; }
        public String feedButtonText { get; set; }
        public String sponsors {get;set;}
        public Integer capacityTotal {get;set;}
        public Integer capacityRemaining {get;set;}
    }

    @HttpGet
    global static void getUSTEventFeed() {
        feedType = RestContext.request.params.get('feedType');
        String recType = RestContext.request.params.get('rectype');

        if (!String.isBlank(recType)) {
            List<RecordType> recTypeList = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'UST_Event__c' AND Name = :recType];
            if (recTypeList.size() > 0) {
                recTypeId = recTypeList[0].Id;
            }
        }
        RestResponse res = RestContext.response;
        String callback = RestContext.request.params.get('callback');
        String serializedJSON = '';

        if (String.isBlank(callback)) {
            res.addHeader('Content-Type', 'application/json');
            callback = '';
        } else {
            res.addHeader('Content-Type', 'application/javascript');
        }


        if (feedType == 'audienceDD') {
            serializedJSON = JSON.serialize(getAudienceDD(UST_Event__c.Audience__c.getDescribe()));
        } else if (feedType == 'sexDD') {
            serializedJSON = JSON.serialize(getAudienceDD(Contact.hed__Gender__c.getDescribe()));
        } else if (feedType == 'eventList') {
            serializedJSON = JSON.serialize(getEventList());
            serializedJSON = serializedJSON.replace('"endDate":', '"end":');
        }
        if (!String.isBlank(callback)) {
            serializedJSON = callback + '(' + serializedJSON + ')';
        }
        res.responseBody = Blob.valueOf(serializedJSON);
    }


    private static List<eventItem> getEventList() {
        List<eventItem> EventList = new List<eventItem>();
        RestRequest req = RestContext.request;
        String eventQuery = '';
        /*eventQuery += ' SELECT Id, Event__r.Name, Event__r.Event_Name__c, Event__r.Event_Status__c, Active_Status__c, Instance_Title__c, Instance_Short_Description__c, Event__r.Program_Filter__c, Event__r.Alternate_Registration_URL__c, ';
        eventQuery += ' Event__r.Location_Title__c, Event__r.Location_Type__c, Event__r.Location_Address__c, Event__r.Location_Map_Link__c, Event__r.Building__c, Event__r.Event_description__c, Event__r.Community_Base_URL__c, ';
        eventQuery += ' Building_Override__c, Alternate_Registration_URL_Override__c, Location_Address_Override__c, Location_Map_Link_Override__c, Location_Title_Override__c, Location_Type_Override__c,  ';
        eventQuery += ' Event__r.Event_Short_Listing_Description__c, Event__r.Audience__c, Event__r.Close_Event_Days_Before__c, Start_Date_Time__c, End_Date_Time__c, Event__r.School__r.Name, Event__r.Event_Sponsor__c, ';
        eventQuery += ' Event__r.Feed_Registration_Button_Text__c, Feed_Registration_Button_Text_Override__c ';
        eventQuery += ' FROM UST_Event_Instance__c ';
        eventQuery += ' WHERE ';
        eventQuery += ' Event__R.Event_Status__c = \'Active\' ';
        eventQuery += ' AND Active_Status__c = \'Active\' ';
        eventQuery += ' AND (Current_Available_Capacity__c > 0 OR Capacity__c = null) ';
        eventQuery += ' AND Event__r.Audience__c EXCLUDES (\'No Audience\') ';*/

        eventQuery += ' SELECT Id, Event__r.Name, Event__r.Event_Name__c, Event__r.Event_Status__c, Active_Status__c, Instance_Title__c, Instance_Short_Description__c, Event__r.Program_Filter__c, Event__r.Alternate_Registration_URL__c, ';
        eventQuery += ' Event__r.Location_Title__c, Event__r.Location_Type__c, Event__r.Location_Address__c, Event__r.Location_Map_Link__c, Event__r.Building__c, Event__r.Event_description__c, Event__r.Community_Base_URL__c, ';
        eventQuery += ' Building_Override__c, Alternate_Registration_URL_Override__c, Location_Address_Override__c, Location_Map_Link_Override__c, Location_Title_Override__c, Location_Type_Override__c,  ';
        eventQuery += ' Event__r.Event_Short_Listing_Description__c, Event__r.Audience__c, Event__r.Close_Event_Days_Before__c, Start_Date_Time__c, End_Date_Time__c, Event__r.Event_Sponsor__c, ';
        eventQuery += ' Event__r.Feed_Registration_Button_Text__c, Feed_Registration_Button_Text_Override__c, Capacity__c, Current_Available_Capacity__c ';
        eventQuery += ' FROM UST_Event_Instance__c ';
        eventQuery += ' WHERE ';
        eventQuery += ' Event__R.Event_Status__c = \'Active\' ';
        eventQuery += ' AND Active_Status__c = \'Active\' ';
        eventQuery += ' AND (Current_Available_Capacity__c > 0 OR Capacity__c = null) ';
        eventQuery += ' AND Event__r.Audience__c EXCLUDES (\'No Audience\') ';

        // build and sanitize the where statement that have variables

        // get start and end view times convert string to datetime then convert back into string to sanitize
        DateTime viewStart = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).addMonths(-1);
        DateTime viewEnd = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).addMonths(1);
        ///.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String formattedViewStart;
        String formattedViewEnd;

        if (!String.isBlank(req.params.get('viewStart'))) {
            String viewStartString = req.params.get('viewStart').trim();
            if (!viewStartString.containsIgnoreCase(' ')) {
                viewStartString = viewStartString + ' 00:00:00';
            }
            viewStart = DateTime.valueOf(viewStartString);
        }
        if (!String.isBlank(req.params.get('viewEnd'))) {
            String viewEndString = req.params.get('viewEnd').trim();
            if (!viewEndString.containsIgnoreCase(' ')) {
                viewEndString = viewEndString + ' 23:59:59';
            }
            viewEnd = DateTime.valueOf(req.params.get('viewEnd'));
        }
        formattedViewStart = viewStart.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        formattedViewEnd = viewEnd.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        eventQuery += ' AND Start_Date_Time__c >= ' + formattedViewStart + ' ';
        eventQuery += ' AND Start_Date_Time__c <= ' + formattedViewEnd + ' ';

        //build and sanitize

        //get event based on event id
        String eventId = req.params.get('eventId');
        Id evtId = null;
        try {
            evtId = (Id) eventId;
            eventId = String.valueOf(evtId);
        } catch (Exception e) {
            eventId = null;
        }
        if (!String.isBlank(eventId)) {
            eventQuery += ' AND Event__r.id = \'' + eventId + '\' ';
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

        //get filter with like soql concatinated program,location, school, location address, location type
        String filter = req.params.get('filter');
        if (!String.isBlank(filter)) {
            eventQuery += ' AND  (';
            List<String> filterList = filter.split(',');
            for (String f : filterList) {
                eventQuery += ' Event__r.Program_Filter__c LIKE \'%' + f + '%\' OR ';
                eventQuery += ' Event__r.Location_Title__c LIKE \'%' + f + '%\' OR ';
                eventQuery += ' Event__r.Location_Address__c LIKE \'%' + f + '%\' OR ';
                eventQuery += ' Event__r.Building__c LIKE \'%' + f + '%\' OR ';
//                eventQuery += ' Event__r.School__r.Name LIKE \'%' + f + '%\' OR ';
            }
            eventQuery = eventQuery.removeEnd('OR ');
            eventQuery += ' ) ';
        }

        if (!String.isBlank(recTypeId)) {
            eventQuery += ' AND Event__r.RecordType.Id = \'' + String.valueOf(recTypeId) + '\' ';
        }

        String incomingShowLongDesc = req.params.get('longdesc');
        Boolean showLongDescription = false;
        if (incomingShowLongDesc != null) {
            if (incomingShowLongDesc.toLowerCase() == '1' || incomingShowLongDesc.toLowerCase() == 'true') {
                showLongDescription = true;
            }
        }

        List<UST_Event_Instance__c> EventInstance = database.query(eventQuery);

        DateTime regDateOpenDate = null;
        for (UST_Event_Instance__c es : EventInstance) {
            regDateOpenDate = Datetime.now().addDays(-1);
            if (es.Event__r.Close_Event_Days_Before__c != null && es.Event__r.Close_Event_Days_Before__c != 0) {
                regDateOpenDate = USTShared.adjustForCenteralTime(Datetime.now());
                regDateOpenDate = regDateOpenDate.addDays((Integer.valueOf(es.Event__r.Close_Event_Days_Before__c) + 1));
            }
            eventItem evt = new eventItem();
            evt.ID = es.Id;
            if (es.Event__r.Event_Name__c != null) {
                evt.title = es.Event__r.Event_Name__c;
            } else {
                evt.title = es.Event__r.Name;
            }

            if (es.Instance_Title__c != null) {
                evt.title += ' - ' + es.Instance_Title__c;
            }

            if (!String.isBlank(es.Instance_Short_Description__c)) {
                evt.instanceDesc = es.Instance_Short_Description__c;
            } else {
                evt.instanceDesc = '';
            }

            if (!String.isBlank(es.Feed_Registration_Button_Text_Override__c)) {
                evt.FeedButtonText = es.Feed_Registration_Button_Text_Override__c;
            } else if (!String.isBlank(es.Event__r.Feed_Registration_Button_Text__c)) {
                evt.FeedButtonText = es.Event__r.Feed_Registration_Button_Text__c;
            } else {
                evt.FeedButtonText = 'Register';
            }

            if (!String.isBlank(es.Location_Type_Override__c)) {
                evt.locationType = es.Location_Type_Override__c;
            } else if (!String.isBlank(es.Event__r.Location_Type__c)) {
                evt.locationType = es.Event__r.Location_Type__c;
            } else {
                evt.locationType = '';
            }

            if (!String.isBlank(es.Event__r.Event_Sponsor__c)) {
                evt.sponsors = es.Event__r.Event_Sponsor__c;
            } else {
                evt.sponsors = '';
            }

            if (!String.isBlank(es.Event__r.Building__c)) {
                evt.locationBuilding = es.Event__r.Building__c;
            } else {
                evt.locationBuilding = '';
            }

            if (!String.isBlank(es.Event__r.Event_Short_Listing_Description__c)) {
                evt.description = es.Event__r.Event_Short_Listing_Description__c;
            } else {
                evt.description = '';
            }

            if (showLongDescription) {
                evt.longDesc = es.Event__r.Event_description__c;
            } else {
                evt.longDesc = '';
            }

            if (Integer.valueOf(es.Capacity__c) != null) {
                evt.capacityTotal = Integer.valueOf(es.Capacity__c);
            } else {
                evt.capacityTotal = 0;
            }

            if (Integer.valueOf(es.Current_Available_Capacity__c) != null) {
                evt.capacityRemaining = Integer.valueOf(es.Current_Available_Capacity__c);
            } else {
                evt.capacityRemaining = 0;
            }

            if (es.Start_Date_Time__c != null) {
                evt.start = USTShared.adjustForCenteralTime(es.Start_Date_Time__c);
            }
            if (es.End_Date_Time__c != null) {
                evt.endDate = USTShared.adjustForCenteralTime(es.End_Date_Time__c);
            }

            if (!String.isBlank(es.Event__r.Location_Title__c) || !String.isBlank(es.Location_Title_Override__c)) {
                if (!String.isBlank(es.Location_Title_Override__c)) {
                    evt.locationTitle = es.Location_Title_Override__c;
                } else {
                    evt.locationTitle = es.Event__r.Location_Title__c;
                }
            } else {
                evt.locationTitle = '';
            }

            if (!String.isBlank(es.Event__r.Location_Address__c) || !String.isBlank(es.Location_Address_Override__c)) {
                if (!String.isBlank(es.Location_Address_Override__c)) {
                    evt.locationAddress = es.Location_Address_Override__c;
                } else {
                    evt.locationAddress = es.Event__r.Location_Address__c;
                }
            } else {
                evt.locationAddress = '';
            }

            if (!String.isBlank(es.Event__r.Location_Map_Link__c) || !String.isBlank(es.Location_Map_Link_Override__c)) {
                if (!String.isBlank(es.Location_Map_Link_Override__c)) {
                    evt.locationMapLink = es.Location_Map_Link_Override__c;
                } else {
                    evt.locationMapLink = es.Event__r.Location_Map_Link__c;
                }
            } else {
                evt.locationMapLink = '';
            }

            if (evt.start < regDateOpenDate) {
                evt.eventClosed = true;
                evt.eventUrl = 'javascript:void(0);';
                evt.className = 'eventClosed';
            } else {
                evt.eventClosed = false;
                if (!String.isBlank(es.Event__r.Alternate_Registration_URL__c) || !String.isBlank(es.Alternate_Registration_URL_Override__c)) {
                    if (!String.isBlank(es.Alternate_Registration_URL_Override__c)) {
                        evt.eventUrl = es.Alternate_Registration_URL_Override__c;
                    } else {
                        evt.eventUrl = es.Event__r.Alternate_Registration_URL__c;
                    }

                } else {
                    evt.eventUrl = es.Event__r.Community_Base_URL__c + 'USTEventRegister?instanceID=' + es.Id;
                }
                evt.className = 'eventOpened';
            }

            EventList.add(evt);
        }
        return EventList;
    }

    private static Map<String, String> getAudienceDD(Schema.DescribeFieldResult fieldResult) {
        Map<String, String> fieldMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            fieldMap.put(f.getLabel(), f.getValue());
        }
        return fieldMap;
    }

}