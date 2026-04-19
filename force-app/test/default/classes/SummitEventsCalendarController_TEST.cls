// Copyright (c) 2026, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found in the LICENSE file in this repository.

@IsTest
public class SummitEventsCalendarController_TEST {

    @TestSetup
    static void makeData() {
        SummitEventsTestSharedDataFactory.createTestEvent();
    }

    // -------------------------------------------------------------------------
    // getAudienceOptions
    // -------------------------------------------------------------------------

    @IsTest
    static void testGetAudienceOptionsReturnsList() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            List<SummitEventsCalendarController.AudienceOption> options =
                SummitEventsCalendarController.getAudienceOptions();
            Test.stopTest();
            // Result may be empty if no picklist values exist in the scratch org,
            // but the method must not throw and must return a non-null list.
            System.assertNotEquals(null, options, 'getAudienceOptions should return a non-null list');
        }
    }

    // -------------------------------------------------------------------------
    // getCalendarEvents - null / empty filters
    // -------------------------------------------------------------------------

    @IsTest
    static void testGetCalendarEventsNullFilters() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            List<SummitEventsCalendarController.CalendarEventItem> events =
                SummitEventsCalendarController.getCalendarEvents(null);
            Test.stopTest();
            System.assertNotEquals(null, events, 'Result should not be null for null filters');
            System.assert(events.size() > 0, 'Should return at least one event from test data');
        }
    }

    @IsTest
    static void testGetCalendarEventsEmptyFilters() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            SummitEventsCalendarController.CalendarFilters filters =
                new SummitEventsCalendarController.CalendarFilters();
            Test.startTest();
            List<SummitEventsCalendarController.CalendarEventItem> events =
                SummitEventsCalendarController.getCalendarEvents(filters);
            Test.stopTest();
            System.assertNotEquals(null, events, 'Result should not be null for empty filters');
            System.assert(events.size() > 0, 'Should return at least one event from test data');
        }
    }

    // -------------------------------------------------------------------------
    // getCalendarEvents - date window
    // -------------------------------------------------------------------------

    @IsTest
    static void testGetCalendarEventsWithDateWindow() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            SummitEventsCalendarController.CalendarFilters filters =
                new SummitEventsCalendarController.CalendarFilters();
            filters.viewStart = String.valueOf(Date.today().addDays(-10));
            filters.viewEnd   = String.valueOf(Date.today().addDays(30));

            Test.startTest();
            List<SummitEventsCalendarController.CalendarEventItem> events =
                SummitEventsCalendarController.getCalendarEvents(filters);
            Test.stopTest();

            System.assertNotEquals(null, events, 'Result should not be null');
            System.assert(events.size() > 0, 'Events within the date window should be returned');
            for (SummitEventsCalendarController.CalendarEventItem eventItem : events) {
                System.assertNotEquals(null, eventItem.instanceId, 'Each event should have an instanceId');
                System.assertNotEquals(null, eventItem.title, 'Each event should have a title');
            }
        }
    }

    @IsTest
    static void testGetCalendarEventsWithFutureDateWindowReturnsEmpty() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            SummitEventsCalendarController.CalendarFilters filters =
                new SummitEventsCalendarController.CalendarFilters();
            // Set the window entirely in the past, well before test data
            filters.viewStart = String.valueOf(Date.today().addYears(-10));
            filters.viewEnd   = String.valueOf(Date.today().addYears(-10).addDays(1));

            Test.startTest();
            List<SummitEventsCalendarController.CalendarEventItem> events =
                SummitEventsCalendarController.getCalendarEvents(filters);
            Test.stopTest();

            System.assertEquals(0, events.size(), 'Should return no events outside test data window');
        }
    }

    @IsTest
    static void testGetCalendarEventsWithInvalidDateStrings() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            SummitEventsCalendarController.CalendarFilters filters =
                new SummitEventsCalendarController.CalendarFilters();
            filters.viewStart = 'not-a-date';
            filters.viewEnd   = 'also-not-a-date';

            Test.startTest();
            // Invalid date strings are caught internally; method should not throw.
            List<SummitEventsCalendarController.CalendarEventItem> events =
                SummitEventsCalendarController.getCalendarEvents(filters);
            Test.stopTest();

            System.assertNotEquals(null, events, 'Should return non-null list even with invalid dates');
        }
    }

    // -------------------------------------------------------------------------
    // getCalendarEvents - hideClosed filter
    // -------------------------------------------------------------------------

    @IsTest
    static void testGetCalendarEventsHideClosedFalse() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            SummitEventsCalendarController.CalendarFilters filters =
                new SummitEventsCalendarController.CalendarFilters();
            filters.hideClosed = false;
            filters.viewStart  = String.valueOf(Date.today().addDays(-10));
            filters.viewEnd    = String.valueOf(Date.today().addDays(30));

            Test.startTest();
            List<SummitEventsCalendarController.CalendarEventItem> events =
                SummitEventsCalendarController.getCalendarEvents(filters);
            Test.stopTest();

            System.assertNotEquals(null, events, 'Result should not be null');
        }
    }

    @IsTest
    static void testGetCalendarEventsHideClosedTrue() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            SummitEventsCalendarController.CalendarFilters filters =
                new SummitEventsCalendarController.CalendarFilters();
            filters.hideClosed = true;
            filters.viewStart  = String.valueOf(Date.today().addDays(-10));
            filters.viewEnd    = String.valueOf(Date.today().addDays(30));

            Test.startTest();
            List<SummitEventsCalendarController.CalendarEventItem> events =
                SummitEventsCalendarController.getCalendarEvents(filters);
            Test.stopTest();

            System.assertNotEquals(null, events, 'Result should not be null with hideClosed=true');
        }
    }

    // -------------------------------------------------------------------------
    // getCalendarEvents - audience filter
    // -------------------------------------------------------------------------

    @IsTest
    static void testGetCalendarEventsAudienceFilterAll() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            SummitEventsCalendarController.CalendarFilters filters =
                new SummitEventsCalendarController.CalendarFilters();
            filters.audience  = 'all';
            filters.viewStart = String.valueOf(Date.today().addDays(-10));
            filters.viewEnd   = String.valueOf(Date.today().addDays(30));

            Test.startTest();
            List<SummitEventsCalendarController.CalendarEventItem> events =
                SummitEventsCalendarController.getCalendarEvents(filters);
            Test.stopTest();

            // 'all' is skipped by the audience filter — should behave like no audience filter.
            System.assertNotEquals(null, events, 'Result should not be null');
        }
    }

    @IsTest
    static void testGetCalendarEventsAudienceFilterNonMatching() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            SummitEventsCalendarController.CalendarFilters filters =
                new SummitEventsCalendarController.CalendarFilters();
            // Use an audience value that won't match the test data (no Audience__c set).
            filters.audience  = 'Prospective Student';
            filters.viewStart = String.valueOf(Date.today().addDays(-10));
            filters.viewEnd   = String.valueOf(Date.today().addDays(30));

            Test.startTest();
            List<SummitEventsCalendarController.CalendarEventItem> events =
                SummitEventsCalendarController.getCalendarEvents(filters);
            Test.stopTest();

            // Test events have no Audience__c value set, so INCLUDES filter returns nothing.
            System.assertNotEquals(null, events, 'Result should not be null');
        }
    }

    // -------------------------------------------------------------------------
    // getCalendarEvents - other optional filters (smoke tests)
    // -------------------------------------------------------------------------

    @IsTest
    static void testGetCalendarEventsOptionalFilters() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            SummitEventsCalendarController.CalendarFilters filters =
                new SummitEventsCalendarController.CalendarFilters();
            filters.viewStart    = String.valueOf(Date.today().addDays(-10));
            filters.viewEnd      = String.valueOf(Date.today().addDays(30));
            filters.sponsor      = 'TestSponsor';
            filters.displayOn    = 'Web';
            filters.category     = 'TestCategory';
            filters.eventType    = 'TestType';
            filters.program      = 'TestProgram';
            filters.building     = 'TestBuilding';
            filters.locationType = 'Virtual';

            Test.startTest();
            // None of the optional filter values match test data; method must not throw.
            List<SummitEventsCalendarController.CalendarEventItem> events =
                SummitEventsCalendarController.getCalendarEvents(filters);
            Test.stopTest();

            System.assertNotEquals(null, events, 'Result should not be null with optional filters');
        }
    }

    @IsTest
    static void testGetCalendarEventsRecordTypeFilter() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            SummitEventsCalendarController.CalendarFilters filters =
                new SummitEventsCalendarController.CalendarFilters();
            filters.viewStart  = String.valueOf(Date.today().addDays(-10));
            filters.viewEnd    = String.valueOf(Date.today().addDays(30));
            // Use a record type name that likely does not exist in the scratch org.
            filters.recordType = 'Nonexistent Record Type';

            Test.startTest();
            List<SummitEventsCalendarController.CalendarEventItem> events =
                SummitEventsCalendarController.getCalendarEvents(filters);
            Test.stopTest();

            // When the record type name is not found in the org, the filter clause is skipped
            // and all events in the date window are returned. The method must not throw.
            System.assertNotEquals(null, events, 'Result should not be null for unmatched record type');
        }
    }

    // -------------------------------------------------------------------------
    // CalendarEventItem field population smoke test
    // -------------------------------------------------------------------------

    @IsTest
    static void testCalendarEventItemFieldsPopulated() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            SummitEventsCalendarController.CalendarFilters filters =
                new SummitEventsCalendarController.CalendarFilters();
            filters.viewStart = String.valueOf(Date.today().addDays(-10));
            filters.viewEnd   = String.valueOf(Date.today().addDays(30));

            Test.startTest();
            List<SummitEventsCalendarController.CalendarEventItem> events =
                SummitEventsCalendarController.getCalendarEvents(filters);
            Test.stopTest();

            System.assert(events.size() > 0, 'Need at least one result to validate fields');

            SummitEventsCalendarController.CalendarEventItem firstEvent = events[0];
            System.assertNotEquals(null, firstEvent.instanceId,    'instanceId must be populated');
            System.assertNotEquals(null, firstEvent.title,         'title must be populated');
            System.assertNotEquals(null, firstEvent.startDatetime, 'startDatetime must be populated');
            System.assertNotEquals(null, firstEvent.cssClass,      'cssClass must be populated');
        }
    }
}

