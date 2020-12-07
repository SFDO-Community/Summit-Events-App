// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 12/6/2020.

@IsTest
private class SummitEventsAddToCalendar_TEST {
    @IsTest
    static void testIcsFileGeneration() {
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Overnight Event', '', true, true, '');
        Test.startTest();
        ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        new SummitEventsAddToCalendarController();
        Test.stopTest();
    }

    @IsTest
    static void testGoogleCalendarLink() {
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Overnight Event', '', true, true, '');
        Test.startTest();
        ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        ApexPages.currentPage().getParameters().put('type', 'google');
        SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
        calendarController.calendarType();
        Test.stopTest();
    }

    @IsTest
    static void testYahooCalendarLink() {
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Overnight Event', '', true, true, '');
        Test.startTest();
        ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        ApexPages.currentPage().getParameters().put('type', 'yahoo');
        SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
        calendarController.calendarType();
        Test.stopTest();
    }

    @IsTest
    static void testICalIcs() {
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Overnight Event', '', true, true, '');
        Test.startTest();
        ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        ApexPages.currentPage().getParameters().put('type', 'ical');
        SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
        calendarController.calendarType();
        Test.stopTest();
    }

    @IsTest
    static void testOutlookIcs() {
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Overnight Event', '', true, true, '');
        Test.startTest();
        ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        ApexPages.currentPage().getParameters().put('type', 'outlook');
        SummitEventsAddToCalendarController calendarController = new SummitEventsAddToCalendarController();
        calendarController.calendarType();
        Test.stopTest();
    }
}