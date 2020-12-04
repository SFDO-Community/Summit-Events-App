// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 11/12/2018.


public with sharing class SummitEventsAddToCalendarController {


    public SummitEventsShared SEShared = new SummitEventsShared();

    public String DTStart { get; set; }

    public String TIMEZONE2 { get; set; }

    public String DTEnd { get; set; }

    public String DTStamp { get; set; }

    public String SUMMARY { get; set; }

    public String LOCATION { get; set; }

    public String DESCRIPTION { get; set; }

    public String UUID { get; set; }

    public String DTStartStandard { get; set; }
    public String DTStartDaylight { get; set; }

    public List<daylightSavings> daylightSavingsTimes { get; set; }

    public SummitEventsAddToCalendarController() {
        DTStart = DTEnd = DTStamp = SUMMARY = LOCATION = DESCRIPTION = TIMEZONE2 = DTStartStandard = DTStartDaylight = '';
        UUID = NewGuid().replace('-', '') + 'Summit';
        String URLInstanceID = ApexPages.currentPage().getParameters().get('instanceID');
        if (!String.isBlank(URLInstanceID)) {

            Summit_Events_Instance__c eventInformation = getEventInformation(URLInstanceID);

            if (eventInformation != null) {
                DTStart = SEShared.convertDateToDatetime(eventInformation.Instance_Start_Date__c, eventInformation.Instance_Start_Time__c, eventInformation.Instance_Time_Zone__c).format('yyyyMMdd\'T\'HHmmss\'Z\'');
                DTEnd = SEShared.convertDateToDatetime(eventInformation.Instance_End_Date__c, eventInformation.Instance_End_Time__c, eventInformation.Instance_Time_Zone__c).format('yyyyMMdd\'T\'HHmmss\'Z\'');
                TIMEZONE2 = SEShared.getTimeZonePick(eventInformation.Instance_Time_Zone__c);

                daylightSavingsTimes = getDayLightSavings(TIMEZONE2, eventInformation.Instance_Start_Date__c.year(), eventInformation.Instance_End_Date__c.year());
                System.debug(JSON.serializePretty(daylightSavingsTimes));

                TimeZone tz = TimeZone.getTimeZone(TIMEZONE2);
                Integer offset = tz.getOffset(Datetime.now());
                DTStamp = Datetime.now().addMinutes(offset / 1000 / 60).format('yyyyMMdd\'T\'HHmmss\'Z\'');

                // String timeZoneNameShort = getTimeZoneDisplay(tz, true);

                Datetime startDateDate = Datetime.newInstanceGmt(
                        eventInformation.Instance_Start_Date__c.year(),
                        eventInformation.Instance_Start_Date__c.month(),
                        eventInformation.Instance_Start_Date__c.day(),
                        eventInformation.Instance_Start_Time__c.hour(),
                        eventInformation.Instance_Start_Time__c.minute(),
                        eventInformation.Instance_Start_Time__c.second());
                //Integer eventStartOffset = tz.getOffset(startDateDate);
                DTStart = startDateDate.format('yyyyMMdd\'T\'HHmmss');

                Datetime endDateDate = Datetime.newInstanceGmt(
                        eventInformation.Instance_End_Date__c.year(),
                        eventInformation.Instance_End_Date__c.month(),
                        eventInformation.Instance_End_Date__c.day(),
                        eventInformation.Instance_End_Time__c.hour(),
                        eventInformation.Instance_End_Time__c.minute(),
                        eventInformation.Instance_End_Time__c.second());
                //Integer eventStartOffset = tz.getOffset(startDateDate);
                DTEnd = endDateDate.format('yyyyMMdd\'T\'HHmmss');

                //Integer eventEndOffset = tz.getOffset(eventInformation.Instance_Start_Date__c);

                SUMMARY = getEventTitle(eventInformation);

                String locationAddress = getEventAddress(eventInformation);
                String locationLink = getEventLocationLink(eventInformation);
                String locationTitle = getLocationTitle(eventInformation);
                LOCATION = 'LOCATION';
                if (String.isNotBlank(locationLink)) {
                    LOCATION += ';ALTREP="' + locationLink + '":';
                } else {
                    LOCATION += ':';
                }
                if (String.isNotBlank(locationTitle)) {
                    LOCATION += locationTitle;
                }
                if (String.isNotBlank(locationTitle) && String.isNotBlank(locationAddress)) {
                    LOCATION += ' - ';
                }
                if (String.isNotBlank(locationAddress)) {
                    LOCATION += locationAddress;
                }

                //Create DESCRIPTION information
                DESCRIPTION = getEventDescription(eventInformation);
            }
        }
    }

    public String getEventTitle(Summit_Events_Instance__c eventInformation) {
        String eventTitle = eventInformation.Event_Name__c;
        if (!String.isBlank(eventInformation.Instance_Title__c)) {
            eventTitle += eventInformation.Event_Name__c + ' - ' + eventInformation.Instance_Title__c;
        }
        return eventTitle;
    }

    public String getEventDescription(Summit_Events_Instance__c eventInformation) {
        //Create DESCRIPTION information
        String fullDescription = '';
        //Title of event
        String title = getEventTitle(eventInformation);
        if (String.isNotBlank(title)) {
            fullDescription = title + '\\n\\n';
        }
        //Location title
        String locationTitle = getLocationTitle(eventInformation);
        if (String.isNotBlank(locationTitle)) {
            fullDescription += locationTitle + '\\n';
        }
        //Location address
        String locationAddress = getEventAddress(eventInformation);
        if (String.isNotBlank(locationAddress)) {
            fullDescription += locationAddress + '\\n';
        }
        //Location link
        String locationLink = getEventLocationLink(eventInformation);
        if (String.isNotBlank(locationLink)) {
            fullDescription += locationLink + '\\n';
        }

        if (String.isNotBlank(eventInformation.Instance_Short_Description__c)) {
            fullDescription += '\\n' + eventInformation.Instance_Short_Description__c;
        } else if (String.isNotBlank(eventInformation.Instance_Short_Description__c)) {
            fullDescription += '\\n' +  eventInformation.Event__r.Event_description__c;
        }
        if (String.isBlank(fullDescription)) {
            return '';
        }
        return fullDescription;
    }

    public String getEventAddress(Summit_Events_Instance__c eventInformation) {
        String locationAddress = eventInformation.Event__r.Location_Address__c;
        if (!String.isBlank(eventInformation.Location_Address_Override__c)) {
            locationAddress = eventInformation.Location_Address_Override__c;
        }
        if (String.isNotBlank(eventInformation.Building_Override__c) || String.isNotBlank(eventInformation.Event__r.Building__c)) {
            locationAddress += ' - ';
            if (String.isNotBlank(eventInformation.Building_Override__c)) {
                locationAddress += eventInformation.Building_Override__c;
            } else {
                locationAddress += eventInformation.Event__r.Building__c;
            }
        }
        if (String.isBlank(locationAddress)) {
            return '';
        }
        return locationAddress;
    }

    public String getLocationTitle(Summit_Events_Instance__c eventInformation) {
        String locationTitle = eventInformation.Event__r.Location_Title__c;
        if (!String.isBlank(eventInformation.Location_Title_Override__c)) {
            locationTitle = eventInformation.Event__r.Location_Title__c;
        }
        if (String.isBlank(locationTitle)) {
            return '';
        }
        return locationTitle;
    }

    public String getEventLocationLink(Summit_Events_Instance__c eventInformation) {
        String locationLink = eventInformation.Event__r.Location_Map_Link__c;
        if (!String.isBlank(eventInformation.Location_Map_Link_Override__c)) {
            locationLink = eventInformation.Location_Map_Link_Override__c;
        }
        if (!String.isBlank(eventInformation.Virtual_Meeting_Link__c)) {
            locationLink = eventInformation.Virtual_Meeting_Link__c;
        }
        if (String.isBlank(locationLink)) {
            return '';
        }
        return locationLink;
    }

    public Summit_Events_Instance__c getEventInformation(Id eventId) {
        List<Summit_Events_Instance__c> eventInstanceList = [
                SELECT Id, Event_Name__c, Instance_Title__c, Instance_Start_Date__c, Instance_End_Date__c, Instance_Start_Time__c,
                        Instance_End_Time__c, Instance_Time_Zone__c, Instance_Short_Description__c, Event__r.Event_Short_Listing_Description__c,
                        Virtual_Meeting_Link__c, Event__r.Location_Title__c, Event__r.Location_Address__c, Event__r.Location_Map_Link__c,
                        Location_Title_Override__c, Location_Address_Override__c, Location_Map_Link_Override__c, Building_Override__c,
                        Event__r.Building__c, Event__r.Event_description__c
                FROM Summit_Events_Instance__c
                WHERE Id = :eventId
        ];

        if (eventInstanceList.size() > 0) {
            return eventInstanceList[0];
        }
        return null;
    }

    public static String NewGuid() {
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        String guid = h.substring(0, 8) + '-' + h.substring(8, 12) + '-' + h.substring(12, 16) + '-' + h.substring(16, 20) + '-' + h.substring(20);
        return guid;
    }

    public PageReference calendarType() {
        String URLInstanceID = ApexPages.currentPage().getParameters().get('instanceID');
        PageReference linkPage = null;
        String urlCalendarLink = '';
        if (!String.isBlank(URLInstanceID)) {
            Summit_Events_Instance__c eventInformation = getEventInformation(URLInstanceID);
            String type = '';
            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('type'))) {
                type = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('type'));
            }
            if (type.equalsIgnoreCase('google')) {
                //Google documentation: https://github.com/InteractionDesignFoundation/add-event-to-calendar-docs/blob/master/services/google.md
                //http://www.google.com/calendar/event?action=TEMPLATE&text=[event-title]&dates=[start-custom format='Ymd\\THi00\\Z']/[end-custom format='Ymd\\THi00\\Z']&details=[description]&location=[location]&trp=false&sprop=&sprop=name:" target="_blank" rel="nofollow
                urlCalendarLink = 'http://www.google.com/calendar/event';
                //Default template
                urlCalendarLink += '?action=TEMPLATE';
                //Title of event
                urlCalendarLink += '&text=' + EncodingUtil.urlEncode(getEventTitle(eventInformation), 'UTF-8');
                //Start and end dates in GMT dates=20201231T193000Z/20201231T223000Z
                urlCalendarLink += '&dates=[START_DATEZ/END_DATEZ]';
                //Timezone ctz=America/New_York
                urlCalendarLink += '&ctz=America/New_York';
                //Location - Google readable address
                urlCalendarLink += '&location=[location]';
                //Url of source of the event
                urlCalendarLink += '&sprop=[event_source_url]';
                //description of event
                urlCalendarLink += '&details=' + EncodingUtil.urlEncode(getEventDescription(eventInformation), 'UTF-8');
                linkPage = new PageReference(urlCalendarLink);
                linkPage.setRedirect(true);
                return linkPage;
            } else if (type.equalsIgnoreCase('yahoo')) {
                //Yahoo documentation: https://github.com/InteractionDesignFoundation/add-event-to-calendar-docs/blob/master/services/yahoo.md
                //https://calendar.yahoo.com/?v=60&st=st20201231T193000&DUR=0200&desc=With%20clowns%20and%20stuff&in_loc=North%20Pole
                urlCalendarLink = 'https://calendar.yahoo.com?v=60';
                //Start time
                urlCalendarLink += '&st=st' + eventInformation.Event__r.Name;
                //End time
                urlCalendarLink += '&et=et' + eventInformation.Event__r.Name;
                //Duration
                urlCalendarLink += '&DUR=' + eventInformation.Event__r.Name;
                //Description
                urlCalendarLink += '&desc=' + EncodingUtil.urlEncode(getEventDescription(eventInformation), 'UTF-8');
                //location title
                urlCalendarLink += '&in_loc=' + EncodingUtil.urlEncode(getLocationTitle(eventInformation), 'UTF-8');
                //Street address
                urlCalendarLink += '&in_st=' + eventInformation.Event__r.Name;
                //City/State/Zip = Atlanta, GA, 30307
                urlCalendarLink += '&in_csz=' + eventInformation.Event__r.Name;
                //Unique Id
                urlCalendarLink += '&uid=' + eventInformation.Event__r.Name;
                linkPage = new PageReference(urlCalendarLink);
                linkPage.setRedirect(true);
                return linkPage;
            } else if (type.equalsIgnoreCase('ical') || type.equalsIgnoreCase('apple')) {
                //Use standard .ics file
                return null;
            } else if (type.equalsIgnoreCase('outlook') || type.equalsIgnoreCase('windows')) {
                //Use standard .ics file
                return null;
            }
        }
        //Use standard .ics file
        return null;
    }

    public class daylightSavingsYears {
        Integer year { get; set; }
        List<daylightSavings> data { get; set; }

    }

    public class daylightSavings {
        Integer year { get; set; }
        Boolean isDaylightSavings { get; set; }
        String DTStart { get; set; }
        Datetime DTStartDate { get; set; }
        String TZOffsetFrom { get; set; }
        String TZOffsetTo { get; set; }
        String TZName { get; set; }
    }


    public static List<daylightSavings> getDayLightSavings(String timezoneString, Integer eventStartYear, Integer eventEndYear) {
        List<daylightSavingsYears> dlsYears = new List<daylightSavingsYears>();
        List<daylightSavings> dlsList = new List<daylightSavings>();
        TimeZone tz = TimeZone.getTimeZone(timezoneString);
        String timeZoneNameShort = getTimeZoneDisplay(tz, true);
        Integer startYear = eventStartYear;
        Integer endYear = eventEndYear;
        Integer oldMonthOffset = 0;
        Integer oldDayOffset = 0;
        Integer oldHourOffset = 0;
        for (Integer y = startYear; y <= endYear; y++) {
            daylightSavingsYears dlsYear = new daylightSavingsYears();
            dlsYear.year = y;
            //looping through months detecting offset changes, then days, then hours
            for (Integer m = 1; m <= 12; m++) {
                Datetime currentYear = Datetime.newInstanceGmt(y, m, 1, 0, 0, 0);
                Integer monthOffset = tz.getOffset(currentYear) / 1000 / 60 ;
                if (oldMonthOffset != 0 && oldMonthOffset != monthOffset) {
                    for (Integer d = 0; d <= Date.daysInMonth(currentYear.year(), currentYear.month()); d++) {
                        //new instance is -1  month behind current because the change was detected after the fact (repeats with day and hour)
                        currentYear = Datetime.newInstanceGmt(y, m - 1, d, 0, 0, 0);
                        Integer dayOffset = tz.getOffset(currentYear);
                        if (oldDayOffset != 0 && dayOffset != oldDayOffset) {
                            for (Integer h = 1; h <= 24; h++) {
                                currentYear = Datetime.newInstanceGmt(y, m - 1, d - 1, h, 0, 0);
                                Integer hourOffset = tz.getOffset(currentYear);
                                if (oldHourOffset != 0 && hourOffset != oldHourOffset) {
                                    daylightSavings daylightSavingItem = new daylightSavings();
                                    currentYear = Datetime.newInstanceGmt(y, m - 1, d - 1, h - 1, 0, 0);
                                    Integer finalOffset = tz.getOffset(currentYear) / 1000 / 60 ;
                                    currentYear.addMinutes(finalOffset);
                                    //add an hour because we started at 0
                                    daylightSavingItem.year = currentYear.year();
                                    daylightSavingItem.DTStartDate = currentYear;
                                    daylightSavingItem.DTStart = currentYear.addMinutes(finalOffset).addHours(1).formatGmt('YYYYMMdd\'T\'hhmmss');
                                    daylightSavingItem.isDaylightSavings = true;
                                    String offsetString = String.valueOf(finalOffset / 60);
                                    Boolean negativeOffset = false;
                                    if (offsetString.startsWith('-')) {
                                        negativeOffset = true;
                                        offsetString = offsetString.substring(1, offsetString.length());
                                    }
                                    offsetString = offsetString.leftPad(2, '0');
                                    offsetString = offsetString.rightPad(4, '0');
                                    if (negativeOffset) {
                                        offsetString = '-' + offsetString;
                                    }
                                    daylightSavingItem.TZOffsetTo = offsetString;
                                    daylightSavingItem.TZOffsetFrom = offsetString;
                                    daylightSavingItem.TZName = timeZoneNameShort;
                                    //dlsYear.data.add(daylightSavingItem);
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
            dlsYears.add(dlsYear);
        }
        return dlsList;
    }

    public static String getTimeZoneDisplay(TimeZone tz, Boolean shortDisplay) {
        String displayName = '';
        if (tz != null) {
            displayName = tz.getDisplayName();
            //remove all parenthesis items
            displayName = displayName.replaceAll('(\\(([^\\)]+)\\))', '');
            displayName = displayName.trim();
        }
        if (shortDisplay) {
            String[] displayNameWordList = displayName.split(' ');
            String shortDisplayOut = '';
            for (String word : displayNameWordList) {
                shortDisplayOut += word.substring(0, 1);
            }
            return shortDisplayOut;
        }
        return displayName;
    }
}

//http://dev-stthomas.cs65.force.comusteventaddtocalendar?instanceID=a320m0000001I34