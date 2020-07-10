// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 11/12/2018.

public with sharing class SummitEventsAddToCalendarController {

    public Summit_Events_Instance__c evtInfo { get; set; }
    public SummitEventsShared SEShared = new SummitEventsShared();
    public String DTSTART { get; set; }
    public String TIMEZONE { get; set; }
    public String DTEND { get; set; }
    public String DTSTAMP { get; set; }
    public String SUMMARY { get; set; }
    public String DESCRIPTION { get; set; }
    public String UUID { get; set; }

    public SummitEventsAddToCalendarController() {
        DTSTART = '';
        DTEND = '';
        DTSTAMP = '';
        SUMMARY = '';
        DESCRIPTION = '';
        TIMEZONE = '';
        UUID = NewGuid();
        String URLinstanceID = ApexPages.currentPage().getParameters().get('instanceID');
        if (!String.isBlank(URLinstanceID)) {

            List<Summit_Events_Instance__c> eventInstanceList = [
                    SELECT Id, Event_Name__c, Instance_Title__c, Instance_Start_Date__c, Instance_End_Date__c,
                            Instance_Start_Time__c, Instance_End_Time__c, Instance_Time_Zone__c,
                            Instance_Short_Description__c, Event__r.Event_Short_Listing_Description__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :URLinstanceID
            ];

            if (eventInstanceList.size() > 0) {
                evtInfo = eventInstanceList[0];
            }

            if (evtInfo != null) {
                TIMEZONE = SEShared.getTimeZonePick(evtInfo.Instance_Time_Zone__c);
                DTSTART = dateStamp(evtInfo.Instance_Start_Date__c, evtInfo.Instance_Start_Time__c);
                DTEND = dateStamp(evtInfo.Instance_End_Date__c, evtInfo.Instance_End_Time__c);
                DTSTAMP = Datetime.now().format('yyyyMMdd\'T\'HHmmss\'Z\'');
                SUMMARY = evtInfo.Event_Name__c;
                if (!String.isBlank(evtInfo.Instance_Title__c)) {
                    SUMMARY += evtInfo.Event_Name__c + ' - ' + evtInfo.Instance_Title__c;
                }

                DESCRIPTION = evtInfo.Event_Name__c;
                if (!String.isBlank(evtInfo.Instance_Title__c)) {
                    DESCRIPTION += ' - ' + evtInfo.Instance_Title__c;
                }
                DESCRIPTION += '\n' + evtInfo.Event__r.Event_Short_Listing_Description__c;
                DESCRIPTION += '\n' + evtInfo.Instance_Short_Description__c;
            }
        }
    }

    public String dateStamp(Date dateIn, Time timeIn) {
        //20130802T103400
        String stampOut = '';
        if (dateIn != null) {
            stampOut += SEShared.convertDateToDatetime(dateIn, null).format('yyyyMMdd');
        }
        if (timeIn != null) {
            stampOut += 'T' + SEShared.formatTime(timeIn, true) + '00';
        }
        SEShared.convertDateToDatetime(dateIn, null).format('yyyyMMdd\'T\'HHmmss\'Z\'');
        return stampOut;
    }

    private static String kHexChars = '0123456789abcdef';

    public static String NewGuid() {

        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i = 0; i < 16; i++) {

            if (i == 4 || i == 6 || i == 8 || i == 10)
                returnValue += '-';

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
        if (str == null) return null;
        if (str.length() <= 0) return str;
        if (index == str.length()) return null;
        return str.substring(index, index + 1);
    }
}


//http://dev-stthomas.cs65.force.comusteventaddtocalendar?instanceID=a320m0000001I34