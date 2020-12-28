// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 12/6/2020.

@IsTest
public class SummitEventsAddToCalendar_TEST {
    @IsTest
    static void testIcsFileGeneration() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Test.startTest();
        ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[1].Id);
        new SummitEventsAddToCalendarController();
        Test.stopTest();
    }

    @IsTest
    static void testGoogleCalendarLink() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Test.startTest();
        ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[1].Id);
        ApexPages.currentPage().getParameters().put('type', 'google');
        SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
        calendarController.calendarType();
        Test.stopTest();
    }

    @IsTest
    static void testYahooCalendarLink() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Test.startTest();
        ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[1].Id);
        ApexPages.currentPage().getParameters().put('type', 'yahoo');
        SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
        calendarController.calendarType();
        Test.stopTest();
    }

    @IsTest
    static void testICalIcs() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Test.startTest();
        ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[1].Id);
        ApexPages.currentPage().getParameters().put('type', 'ical');
        SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
        calendarController.calendarType();
        Test.stopTest();
    }

    @IsTest
    static void testOutlookIcs() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Test.startTest();
        ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[1].Id);
        ApexPages.currentPage().getParameters().put('type', 'outlook');
        SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
        calendarController.calendarType();
        Test.stopTest();
    }

    @IsTest
    static void testOutlookWeb() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Test.startTest();
        ApexPages.currentPage().getParameters().put('instanceID', seaTestInstances[1].Id);
        ApexPages.currentPage().getParameters().put('type', 'outlookweb');
        SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
        calendarController.calendarType();
        Test.stopTest();
    }


}