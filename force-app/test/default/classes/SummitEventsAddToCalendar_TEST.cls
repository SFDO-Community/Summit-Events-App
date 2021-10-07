// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 12/6/2020.

@IsTest
public class SummitEventsAddToCalendar_TEST {
    @IsTest
    static void testIcsFileGeneration() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsAddToCalendar;
            pageRef.getParameters().put('instanceID', seaTestInstances[1].Id);
            Test.setCurrentPage(pageRef);
            SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
            String startString = calendarController.formattedGmtVersionOfDate(seaTestInstances[1].Instance_Start_Date__c, seaTestInstances[1].Instance_Start_Time__c);
            System.assertEquals(calendarController.DTStart, startString);
            Test.stopTest();
        }
    }

    @IsTest
    static void testForNullReturns() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
            System.assertEquals(calendarController.calendarType(), null);
            System.assertEquals(SummitEventsAddToCalendarController.getTimeZoneDisplay(null, false), '');
            Test.stopTest();
        }
    }

    @IsTest
    static void testGoogleCalendarLink() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsAddToCalendar;
            pageRef.getParameters().put('instanceID', seaTestInstances[1].Id);
            pageRef.getParameters().put('type', 'google');
            Test.setCurrentPage(pageRef);

            SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
            String startDate = calendarController.DTStart;
            String endDate = calendarController.DTEnd;
            String comparePageReference = 'https://www.google.com/calendar/event?action=TEMPLATE&ctz=America%2FChicago&dates=' + startDate + '%2F' + endDate + '&details=&location=123+Electric+Ave.&sprop=%5Bevent_source_url%5DMap+Link+1&text=Test+Event+-+Test+Event+Session+0';
            system.assertEquals(calendarController.calendarType().getUrl(), comparePageReference);
            Test.stopTest();
        }
    }

    @IsTest
    static void testYahooCalendarLink() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsAddToCalendar;
            pageRef.getParameters().put('instanceID', seaTestInstances[1].Id);
            pageRef.getParameters().put('type', 'yahoo');
            Test.setCurrentPage(pageRef);
            SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
            String startDate = calendarController.DTStart;
            String endDate = calendarController.DTEnd;
            String testCalendarURL = 'https://calendar.yahoo.com?desc=&et=' + endDate + '&in_csz=America%2FChicago&in_loc=A+location&in_st=123+Electric+Ave.&st=' + startDate + '&title=Test+Event+-+Test+Event+Session+0&v=60';
            system.assertEquals(calendarController.calendarType().getUrl(), testCalendarURL);
            Test.stopTest();
        }
    }

    @IsTest
    static void testICalIcs() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsAddToCalendar;
            pageRef.getParameters().put('instanceID', seaTestInstances[1].Id);
            pageRef.getParameters().put('type', 'ical');
            Test.setCurrentPage(pageRef);
            SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
            System.assertEquals(calendarController.calendarType(), null);
            Test.stopTest();
        }
    }

    @IsTest
    static void testOutlookIcs() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsAddToCalendar;
            pageRef.getParameters().put('instanceID', seaTestInstances[1].Id);
            pageRef.getParameters().put('type', 'outlook');
            Test.setCurrentPage(pageRef);
            SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
            System.assertEquals(calendarController.calendarType(), null);
            Test.stopTest();
        }
    }

    @IsTest
    static void testOutlookWeb() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsAddToCalendar;
            pageRef.getParameters().put('instanceID', seaTestInstances[1].Id);
            pageRef.getParameters().put('type', 'outlookweb');
            Test.setCurrentPage(pageRef);
            SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();

            SummitEventsShared SEShared = new SummitEventsShared();
            String timezoneString = SEShared.getTimeZonePick(seaTestInstances[1].Instance_Time_Zone__c);
            TimeZone tz = TimeZone.getTimeZone(timezoneString);
            Date startD = seaTestInstances[1].Instance_Start_Date__c;
            Time startT = seaTestInstances[1].Instance_Start_Time__c;
            Date endD = seaTestInstances[1].Instance_End_Date__c;
            Time endT = seaTestInstances[1].Instance_End_Time__c;
            Datetime startDateTime = Datetime.newInstanceGmt(startD.year(), startD.month(), startD.day(), startT.hour(), startT.minute(), startT.second());
            Datetime endDateTime = Datetime.newInstanceGmt(endD.year(), endD.month(), endD.day(), endT.hour(), endT.minute(), endT.second());
            startDateTime = startDateTime.addSeconds(-(tz.getOffset(startDateTime) / 1000));
            endDateTime = endDateTime.addSeconds(-(tz.getOffset(endDateTime) / 1000));
            String formattedStartDate = EncodingUtil.urlEncode(startDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:SS') + 'Z', 'UTF-8');
            String formattedEndDate = EncodingUtil.urlEncode(endDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:SS') + 'Z', 'UTF-8');

            String testCalendarURL = 'https://outlook.office.com/calendar/0/deeplink/compose?body=&enddt=' + formattedEndDate + '&location=A+location%2C++123+Electric+Ave.&path=%2Fcalendar%2Faction%2Fcompose&startdt=' + formattedStartDate + '&subject=Test+Event+-+Test+Event+Session+0';
            System.assertEquals(calendarController.calendarType().getUrl(), testCalendarURL);
            Test.stopTest();
        }
    }

}