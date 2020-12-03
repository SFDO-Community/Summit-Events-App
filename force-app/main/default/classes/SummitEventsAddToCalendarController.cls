// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 11/12/2018.


public with sharing class SummitEventsAddToCalendarController {

    public Summit_Events_Instance__c evtInfo { get; set; }

    public SummitEventsShared SEShared = new SummitEventsShared();

    public String DTStart { get; set; }

    public String TIMEZONE { get; set; }

    public String DTEnd { get; set; }

    public String DTStamp { get; set; }

    public String SUMMARY { get; set; }

    public String LOCATION { get; set; }

    public String DESCRIPTION { get; set; }

    public String UUID { get; set; }

    public String DTStartStandard { get; set; }
    public String DTStartDaylight { get; set; }

    public class daylightSavings{
        //BEGIN:STANDARD
        //DTSTART:20201101T090000
        //TZOFFSETFROM:-0700
        //TZOFFSETTO:-0800
        //TZNAME:PST

        //BEGIN:DAYLIGHT
        //DTSTART:20200308T100000
        //TZOFFSETFROM:-0800
        //        TZOFFSETTO:-0700
        //        TZNAME:PDT
         //       END:DAYLIGHT
    }

    public SummitEventsAddToCalendarController() {
        DTStart = DTEnd = DTStamp = SUMMARY = LOCATION = DESCRIPTION = TIMEZONE = DTStartStandard =  DTStartDaylight = '';
        UUID = NewGuid();
        String URLInstanceID = ApexPages.currentPage().getParameters().get('instanceID');
        if (!String.isBlank(URLInstanceID)) {

            List<Summit_Events_Instance__c> eventInstanceList = [
                    SELECT Id, Event_Name__c, Instance_Title__c, Instance_Start_Date__c, Instance_End_Date__c, Instance_Start_Time__c, Instance_End_Time__c, Instance_Time_Zone__c, Instance_Short_Description__c, Event__r.Event_Short_Listing_Description__c, Virtual_Meeting_Link__c, Event__r.Location_Title__c, Event__r.Location_Address__c, Event__r.Location_Map_Link__c, Location_Title_Override__c, Location_Address_Override__c, Location_Map_Link_Override__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :URLInstanceID
            ];

            if (eventInstanceList.size() > 0) {
                evtInfo = eventInstanceList[0];
            }

            if (evtInfo != null) {
                DTStart = SEShared.convertDateToDatetime(evtInfo.Instance_Start_Date__c, evtInfo.Instance_Start_Time__c, evtInfo.Instance_Time_Zone__c).format('yyyyMMdd\'T\'HHmmss\'Z\'');
                DTEnd = SEShared.convertDateToDatetime(evtInfo.Instance_End_Date__c, evtInfo.Instance_End_Time__c, evtInfo.Instance_Time_Zone__c).format('yyyyMMdd\'T\'HHmmss\'Z\'');
                DTStamp = Datetime.now().format('yyyyMMdd\'T\'HHmmss\'Z\'');
                TIMEZONE = SEShared.getTimeZonePick(evtInfo.Instance_Time_Zone__c);

                Map<String, String> daylightSavingsTimes = getDayLightSavings(TIMEZONE);
                String eventStartYear = String.valueOf(evtInfo.Instance_Start_Date__c.year());
                String eventEndYear = String.valueOf(evtInfo.Instance_End_Date__c.year());
                for (String key : daylightSavingsTimes.keySet()) {
                    if(key.startsWith(eventStartYear)) {
                        DTStartStandard= key;
                    }
                }


                SUMMARY = evtInfo.Event_Name__c;
                if (!String.isBlank(evtInfo.Instance_Title__c)) {
                    SUMMARY += evtInfo.Event_Name__c + ' - ' + evtInfo.Instance_Title__c;
                }

                LOCATION = evtInfo.Event__r.Location_Title__c;
                if (!String.isBlank(evtInfo.Location_Title_Override__c)) {
                    LOCATION = evtInfo.Location_Title_Override__c;
                }

                DESCRIPTION = evtInfo.Event__r.Event_Short_Listing_Description__c;
                if (!String.isBlank(evtInfo.Instance_Short_Description__c)) {
                    DESCRIPTION += '\\n' + '\\n' + evtInfo.Instance_Short_Description__c + '\\n';
                }
                if (!String.isBlank(evtInfo.Virtual_Meeting_Link__c)) {
                    DESCRIPTION += '\\n' + 'Meeting Link - ' + evtInfo.Virtual_Meeting_Link__c + '\\n';
                }
                if (!String.isBlank(evtInfo.Event__r.Location_Address__c)) {
                    DESCRIPTION += '\\n' + 'Location Information:' + '\\n' + evtInfo.Event__r.Location_Address__c + '\\n' + evtInfo.Event__r.Location_Map_Link__c + '\\n';
                }
                if (!String.isBlank(evtInfo.Location_Title_Override__c)) {
                    DESCRIPTION += '\\n' + 'Location Information:' + '\\n' + evtInfo.Location_Title_Override__c + '\\n' + evtInfo.Location_Map_Link_Override__c + '\\n';

                }
            }
        }
    }

    private static String kHexChars = '0123456789abcdef';
    public static String NewGuid() {

        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i = 0; i < 16; i++) {

            if (i == 4 || i == 6 || i == 8 || i == 10) {
                returnValue += '-';
            }

            nextByte = (Math.round(Math.random() * 255) - 128) & 255;

            if (i == 6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i == 8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }

    public static String getCharAtIndex(String str, Integer index) {
        if (str == null) {
            return null;
        }
        if (str.length() <= 0) {
            return str;
        }
        if (index == str.length()) {
            return null;
        }
        return str.substring(index, index + 1);
    }

    public PageReference calendarType() {
        return null;
    }

    public class daylightSavings{
        //BEGIN:STANDARD
        //DTSTART:20201101T090000
        //TZOFFSETFROM:-0700
        //TZOFFSETTO:-0800
        //TZNAME:PST

        //BEGIN:DAYLIGHT
        //DTSTART:20200308T100000
        //TZOFFSETFROM:-0800
        //        TZOFFSETTO:-0700
        //        TZNAME:PDT
        //       END:DAYLIGHT
    }


    public static Map<String, String> getDayLightSavings(String timezoneString,Integer eventStartYear, Integer eventEndYear) {
        Map<String, String> dayChange = new Map<String, String>();
        Timezone tz = Timezone.getTimeZone(timezoneString);
        Integer startYear = eventStartYear - 1;
        Integer endYear = eventEndYear + 1;
        Integer oldMonthOffset = 0;
        Integer oldDayOffset = 0;
        Integer oldHourOffset = 0;
        for (Integer y = startYear; y <= endYear; y++) {
            //looping through months detecting offset changes, then days, then hours
            for (Integer m = 1; m <= 12; m++) {
                DateTime currentYear = DateTime.newInstanceGmt(y, m, 1, 0, 0, 0);
                Integer monthOffset = tz.getOffset(currentYear) / 1000 / 60 ;
                if (oldMonthOffset != 0 && oldMonthOffset != monthOffset) {
                    for (Integer d = 0; d <= Date.daysInMonth(currentYear.year(), currentYear.month()); d++) {
                        //new instance is -1  month behind current because the change was detected after the fact (repeats with day and hour)
                        currentYear = DateTime.newInstanceGmt(y, m - 1, d, 0, 0, 0);
                        Integer dayOffSet = tz.getOffset(currentYear);
                        if (oldDayOffset != 0 && dayOffSet != oldDayOffset) {
                            for (Integer h = 1; h <= 24; h++) {
                                currentYear = DateTime.newInstanceGmt(y, m - 1, d - 1, h, 0, 0);
                                Integer hourOffset = tz.getOffset(currentYear);
                                if (oldHourOffset != 0 && hourOffset != oldHourOffset) {
                                    currentYear = DateTime.newInstanceGmt(y, m - 1, d - 1, h - 1, 0, 0);
                                    Integer finalOffset = tz.getOffset(currentYear) / 1000 / 60 ;
                                    currentYear.addMinutes(finalOffset);
                                    //add an hour because we started at 0
                                    String theDate = currentYear.addMinutes(finalOffset).addHours(1).formatGMT('YYYYMMdd\'T\'hhmmss');
                                    String offsetString = String.valueOf(finalOffset/60);
                                    boolean negativeOffset = false;
                                    if (offsetString.startsWith('-')) {
                                        negativeOffset = true;
                                        offsetString = offsetString.substring(1, offsetString.length());
                                    }
                                    offsetString = offsetString.leftPad(2, '0');
                                    offsetString = offsetString.rightPad(4,'0');
                                    if (negativeOffset) {
                                        offsetString = '-' + offsetString;
                                    }
                                    dayChange.put(theDate, offsetString);
                                }
                                oldHourOffset = hourOffset;
                            }
                        }
                        oldDayOffset = dayOffset;
                    }
                    oldDayOffset = monthOffset;
                }
                oldMonthOffset = monthOffset;
            }
        }
        if (dayChange.size() > 1) {
            System.debug('Has daylight savings');
        }
        return dayChange;
    }

}

//http://dev-stthomas.cs65.force.comusteventaddtocalendar?instanceID=a320m0000001I34