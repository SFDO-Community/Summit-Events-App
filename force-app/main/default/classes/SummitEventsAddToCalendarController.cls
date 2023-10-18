// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 11/12/2018.

public with sharing class SummitEventsAddToCalendarController {

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
    public String VTIMEZONE { get; set; }

    public SummitEventsAddToCalendarController() {
        DTStart = DTEnd = DTStamp = SUMMARY = LOCATION = DESCRIPTION = TIMEZONE2 = DTStartStandard = DTStartDaylight = '';
        UUID = NewGuid().replace('-', '') + 'Summit';

        //Strongly type instanceID parameter to Id to prevent URL tampering
        Id URLInstanceID = null;
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('instanceID'))) {
            try {
                URLInstanceID = (Id) String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('instanceID'));
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

        if (URLInstanceID != null) {
            Summit_Events_Instance__c eventInformation = getEventInformation(URLInstanceID);

            if (eventInformation != null) {
                DTStart = SummitEventsShared.convertDateToDatetime(eventInformation.Instance_Start_Date__c, eventInformation.Instance_Start_Time__c, eventInformation.Instance_Time_Zone__c).format('yyyyMMdd\'T\'HHmmss\'Z\'');
                DTEnd = SummitEventsShared.convertDateToDatetime(eventInformation.Instance_End_Date__c, eventInformation.Instance_End_Time__c, eventInformation.Instance_Time_Zone__c).format('yyyyMMdd\'T\'HHmmss\'Z\'');
                TIMEZONE2 = SummitEventsShared.getTimeZonePick(eventInformation.Instance_Time_Zone__c);

                VTIMEZONE = getDayLightSavings(TIMEZONE2, eventInformation.Instance_Start_Date__c.year(), eventInformation.Instance_End_Date__c.year());

                TimeZone tz = TimeZone.getTimeZone(TIMEZONE2);
                Integer offset = tz.getOffset(Datetime.now());
                DTStamp = Datetime.now().addMinutes(offset / 1000 / 60).format('yyyyMMdd\'T\'HHmmss\'Z\'');

                // String timeZoneNameShort = getTimeZoneDisplay(tz, true);
                DTStart = formattedGmtVersionOfDate(eventInformation.Instance_Start_Date__c, eventInformation.Instance_Start_Time__c);
                DTEnd = formattedGmtVersionOfDate(eventInformation.Instance_End_Date__c, eventInformation.Instance_End_Time__c);

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

    public String formattedGmtVersionOfDate(Date aDate, Time aTime) {
        String formattedString = '';
        Datetime newDateTime = Datetime.newInstanceGmt(aDate.year(), aDate.month(), aDate.day(), aTime.hour(), aTime.minute(), aTime.second());
        formattedString = newDateTime.formatGmt('yyyyMMdd\'T\'HHmmss');
        return formattedString;
    }

    public String getEventTitle(Summit_Events_Instance__c eventInformation) {
        String eventTitle = eventInformation.Event_Name__c;
        if (String.isNotBlank(eventInformation.Instance_Title__c)) {
            eventTitle += ' - ' + eventInformation.Instance_Title__c;
        }
        return eventTitle.escapeHtml4();
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
        } else if (String.isNotBlank(eventInformation.Event__r.Event_Short_Listing_Description__c)) {
            fullDescription += '\\n' + eventInformation.Event__r.Event_Short_Listing_Description__c;
        } else {
            fullDescription = '';
        }
        return fullDescription;
    }

    public String getEventAddress(Summit_Events_Instance__c eventInformation) {
        String locationAddress = eventInformation.Event__r.Location_Address__c;
        if (String.isNotBlank(eventInformation.Location_Address_Override__c)) {
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
        if (String.isNotBlank(eventInformation.Location_Title_Override__c)) {
            locationTitle = eventInformation.Event__r.Location_Title__c;
        }
        if (String.isBlank(locationTitle)) {
            return '';
        }
        return locationTitle.escapeHtml4();
    }

    public String getEventLocationLink(Summit_Events_Instance__c eventInformation) {
        String locationLink = eventInformation.Event__r.Location_Map_Link__c;
        if (String.isNotBlank(eventInformation.Location_Map_Link_Override__c)) {
            locationLink = eventInformation.Location_Map_Link_Override__c;
        }
        if (String.isNotBlank(eventInformation.Virtual_Meeting_Link__c)) {
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
                WITH SECURITY_ENFORCED
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

        //Strongly type instanceID parameter to Id to prevent URL tampering
        Id URLInstanceID = null;
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('instanceID'))) {
            try {
                URLInstanceID = (Id) String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('instanceID'));
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

        PageReference linkPage = null;
        String urlCalendarLink = '';
        if (URLInstanceID != null) {
            Summit_Events_Instance__c eventInformation = getEventInformation(URLInstanceID);
            String type = '';
            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('type'))) {
                type = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('type'));
                DTStart = formattedGmtVersionOfDate(eventInformation.Instance_Start_Date__c, eventInformation.Instance_Start_Time__c);
                DTEnd = formattedGmtVersionOfDate(eventInformation.Instance_End_Date__c, eventInformation.Instance_End_Time__c);
                if (type.equalsIgnoreCase('google')) {
                    //Google documentation: https://github.com/InteractionDesignFoundation/add-event-to-calendar-docs/blob/master/services/google.md
                    //https://www.google.com/calendar/event?action=TEMPLATE&text=[event-title]&dates=[start-custom format='Ymd\\THi00\\Z']/[end-custom format='Ymd\\THi00\\Z']&details=[description]&location=[location]&trp=false&sprop=&sprop=name:" target="_blank" rel="nofollow
                    urlCalendarLink = 'https://www.google.com/calendar/event';
                    //Default template
                    urlCalendarLink += '?action=TEMPLATE';
                    //Title of event
                    urlCalendarLink += '&text=' + EncodingUtil.urlEncode(getEventTitle(eventInformation), 'UTF-8');
                    //Start and end dates in GMT dates=20201231T193000Z/20201231T223000Z
                    urlCalendarLink += '&dates=';
                    urlCalendarLink += formattedGmtVersionOfDate(eventInformation.Instance_Start_Date__c, eventInformation.Instance_Start_Time__c);
                    urlCalendarLink += '/';
                    urlCalendarLink += formattedGmtVersionOfDate(eventInformation.Instance_End_Date__c, eventInformation.Instance_End_Time__c);
                    //Timezone ctz=America/New_York
                    urlCalendarLink += '&ctz=' + SummitEventsShared.getTimeZonePick(eventInformation.Instance_Time_Zone__c);
                    //Location - Google readable address
                    urlCalendarLink += '&location=' + EncodingUtil.urlEncode(getEventAddress(eventInformation), 'UTF-8');
                    //Url of source of the event
                    urlCalendarLink += '&sprop=[event_source_url]' + EncodingUtil.urlEncode(getEventLocationLink(eventInformation), 'UTF-8');
                    //description of event
                    urlCalendarLink += '&details=' + EncodingUtil.urlEncode(getEventDescription(eventInformation).replace('\\n', '<br/>'), 'UTF-8');
                    linkPage = new PageReference(urlCalendarLink);
                    linkPage.setRedirect(true);
                    return linkPage;
                } else if (type.equalsIgnoreCase('yahoo')) {
                    //Yahoo documentation: https://github.com/InteractionDesignFoundation/add-event-to-calendar-docs/blob/master/services/yahoo.md
                    //https://calendar.yahoo.com/?v=60&st=st20201231T193000&DUR=0200&desc=With%20clowns%20and%20stuff&in_loc=North%20Pole
                    urlCalendarLink = 'https://calendar.yahoo.com?v=60';
                    //Title
                    urlCalendarLink += '&title=' + EncodingUtil.urlEncode(getEventTitle(eventInformation), 'UTF-8');
                    //Start time
                    urlCalendarLink += '&st=' + formattedGmtVersionOfDate(eventInformation.Instance_Start_Date__c, eventInformation.Instance_Start_Time__c);
                    //End time
                    urlCalendarLink += '&et=' + formattedGmtVersionOfDate(eventInformation.Instance_End_Date__c, eventInformation.Instance_End_Time__c);
                    //Description
                    urlCalendarLink += '&desc=' + EncodingUtil.urlEncode(getEventDescription(eventInformation).replace('\\n', '\n'), 'UTF-8');
                    //location title
                    urlCalendarLink += '&in_loc=' + EncodingUtil.urlEncode(getLocationTitle(eventInformation), 'UTF-8');
                    //Street address
                    urlCalendarLink += '&in_st=' + EncodingUtil.urlEncode(getEventAddress(eventInformation), 'UTF-8');
                    //City/State/Zip = Atlanta, GA, 30307
                    urlCalendarLink += '&in_csz=' + SummitEventsShared.getTimeZonePick(eventInformation.Instance_Time_Zone__c);
                    //Unique Id
                    //urlCalendarLink += '&uid=' + NewGuid();
                    linkPage = new PageReference(urlCalendarLink);
                    linkPage.setRedirect(true);
                    return linkPage;
                } else if (type.equalsIgnoreCase('outlookweb')) {
                    //outlook web link docs: https://interactiondesignfoundation.github.io/add-event-to-calendar-docs/services/outlook-web.html
                    urlCalendarLink = 'https://outlook.office.com/calendar/0/deeplink/compose';
                    //compose action
                    urlCalendarLink += '?path=/calendar/action/compose';
                    //subject
                    urlCalendarLink += '&subject=' + EncodingUtil.urlEncode(getEventTitle(eventInformation), 'UTF-8');
                    //Body
                    urlCalendarLink += '&body=' + EncodingUtil.urlEncode(getEventDescription(eventInformation).replace('\\n', '<br/>'), 'UTF-8');
                    //locaiton
                    urlCalendarLink += '&location=' + EncodingUtil.urlEncode(getLocationTitle(eventInformation) + ',  ' + getEventAddress(eventInformation), 'UTF-8');

                    //Start date in zurich gmt time (YYYY-MM-DDTHH:mm:SSZ) or date (YYYY-MM-DD, for all-day events)
                    String timezoneString = SummitEventsShared.getTimeZonePick(eventInformation.Instance_Time_Zone__c);
                    TimeZone tz = TimeZone.getTimeZone(timezoneString);
                    Date startD = eventInformation.Instance_Start_Date__c;
                    Time startT = eventInformation.Instance_Start_Time__c;
                    Date endD = eventInformation.Instance_End_Date__c;
                    Time endT = eventInformation.Instance_End_Time__c;
                    Datetime startDateTime = Datetime.newInstanceGmt(startD.year(), startD.month(), startD.day(), startT.hour(), startT.minute(), startT.second());
                    Datetime endDateTime = Datetime.newInstanceGmt(endD.year(), endD.month(), endD.day(), endT.hour(), endT.minute(), endT.second());
                    startDateTime = startDateTime.addSeconds(-(tz.getOffset(startDateTime) / 1000));
                    endDateTime = endDateTime.addSeconds(-(tz.getOffset(endDateTime) / 1000));
                    String formattedStartDate = startDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:SS') + 'Z';
                    String formattedEndDate = endDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:SS') + 'Z';
                    urlCalendarLink += '&startdt=' + formattedStartDate;

                    // End date in zurich gmt time (YYYY-MM-DDTHH:mm:SSZ) or date (YYYY-MM-DD, for all-day events)
                    urlCalendarLink += '&enddt=' + formattedEndDate;

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
        String DTStartDate { get; set; }
        String TZOffsetFrom { get; set; }
        String TZOffsetTo { get; set; }
        String TZName { get; set; }
    }


    public static String getDayLightSavings(String timezoneString, Integer eventStartYear, Integer eventEndYear) {
        List<daylightSavingsYears> dlsYears = new List<daylightSavingsYears>();
        List<daylightSavings> dlsList = new List<daylightSavings>();
        TimeZone tz = TimeZone.getTimeZone(timezoneString);
        String timeZoneNameShort = '';
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
                                    daylightSavings dlsItem = new daylightSavings();
                                    currentYear = Datetime.newInstanceGmt(y, m - 1, d - 1, h - 1, 0, 0);
                                    Integer finalOffset = tz.getOffset(currentYear) / 1000 / 60 ;
                                    timeZoneNameShort = getTimeZoneDisplay(tz, true);
                                    currentYear.addMinutes(finalOffset);
                                    //add an hour because we started at 0
                                    dlsItem.year = currentYear.year();
                                    dlsItem.DTStartDate = currentYear.formatGmt('YYYYMMdd\'T\'hhmmss');
                                    dlsItem.DTStart = currentYear.addMinutes(finalOffset).addHours(1).formatGmt('YYYYMMdd\'T\'hhmmss');
                                    dlsItem.isDaylightSavings = false;
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
                                    dlsItem.TZOffsetTo = offsetString;
                                    dlsItem.TZOffsetFrom = offsetString;
                                    dlsItem.TZName = currentYear.addDays(1).format('z', timezoneString);

                                    dlsList.add(dlsItem);
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
            // dlsYear[y].data = (List<daylightSavings>)dlsList;
            dlsYear.data = dlsList;
            dlsYears.add(dlsYear);
        }

        //loop through and organize data by timezone
        for (daylightSavingsYears dlsYearItem : dlsYears) {
            if (dlsYearItem.data.size() == 2) {
                Integer dataZeroOffset = Integer.valueOf(dlsYearItem.data[0].TZOffsetTo.replace('-', ''));
                Integer dataOneOffset = Integer.valueOf(dlsYearItem.data[1].TZOffsetTo.replace('-', ''));
                if (dataZeroOffset < dataOneOffset) {
                    //dataZeroOffset is standard time (its a lower time difference)
                    dlsYearItem.data[0].isDaylightSavings = false;
                    dlsYearItem.data[1].isDaylightSavings = true;

                } else {
                    //dataZeroOffset is daylight savings time (its a lower time difference)
                    dlsYearItem.data[0].isDaylightSavings = true;
                    dlsYearItem.data[1].isDaylightSavings = false;
                }
                dlsYearItem.data[0].TZOffsetTo = dlsYearItem.data[1].TZOffsetFrom;
                dlsYearItem.data[1].TZOffsetTo = dlsYearItem.data[0].TZOffsetFrom;
            }
        }

        String VTimezone = '\n' + 'BEGIN:VTIMEZONE' + '\n';
        VTimezone += 'TZID:' + timezoneString + '\n';
        for (daylightSavingsYears dlsYearItem : dlsYears) {
            for (daylightSavings dslItem : dlsYearItem.data) {
                if (dslItem.isDaylightSavings) {
                    VTimezone += 'BEGIN:DAYLIGHT' + '\n';
                } else {
                    VTimezone += 'BEGIN:STANDARD' + '\n';
                }
                VTimezone += 'DTSTART:' + dslItem.DTStart + '\n';
                VTimezone += 'TZOFFSETFROM:' + dslItem.TZOffsetFrom + '\n';
                VTimezone += 'TZOFFSETTO:' + dslItem.TZOffsetTo + '\n';
                VTimezone += 'TZNAME:' + dslItem.TZName + '\n';
                if (dslItem.isDaylightSavings) {
                    VTimezone += 'END:DAYLIGHT' + '\n';
                } else {
                    VTimezone += 'END:STANDARD' + '\n';
                }
            }
        }

        VTimezone += 'END:VTIMEZONE';

        return VTimezone;
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