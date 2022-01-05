// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsFeed_TEST {
    @IsTest static void testEventFeed() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/summiteventfeed';
            req.httpMethod = 'GET';
            req.addHeader('Content-Type', 'application/json');

            //Test audience dd request
            req.params.put('feedType', 'audienceDD');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            System.assert(res.responseBody.toString().contains('General Public'));

            //Test sex dd request
            req.params.remove('feedType');
            req.params.put('feedType', 'sexDD');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            System.assert(res.responseBody.toString().contains('Male'));

            //test filter minus dates
            req.params.remove('feedType');
            req.params.put('feedType', 'eventList');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            System.assert(res.responseBody.toString().contains('Test Event - Test Event Session -1'));

            //test filter minus dates
            req.params.remove('feedType');
            req.params.put('feedType', 'eventList');
            req.params.put('eventId', seaTestInstances[1].Id);
            req.params.put('sponsor', 'Big Business');
            req.params.put('longdesc', 'true');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            System.assert(res.responseBody.toString().contains('[]'));
            req.params.put('eventId', 'WRONG!');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            System.assert(res.responseBody.toString().contains('[]'));

            //test filter with start date
            req.params.put('viewStart', String.valueOf(Datetime.now().addMonths(-1)));
            req.params.put('hideClosed', 'true');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            System.assert(res.responseBody.toString().contains('[]'));

            //test filter with end date
            req.params.put('viewEnd', String.valueOf(Datetime.now().addMonths(1)));
            req.params.put('audience', 'Alumni');
            req.params.put('hideClosed', 'notRight');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            System.assert(res.responseBody.toString().contains('[]'));

            //test filter
            req.params.put('filter', 'OCB');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            System.assert(res.responseBody.toString().contains('[]'));

            //test filter
            req.params.put('rectype', 'UDAR');
            req.params.put('callback', 'UDAR');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            System.assert(res.responseBody.toString().contains('UDAR([])'));
            Test.stopTest();

        }
    }

    @IsTest static void testEventFeedOverrides() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        seaTestInstances[1].Alternate_Registration_URL_Override__c = 'http://testingAnOverride.com';
        seaTestInstances[1].Location_Address_Override__c = 'New location override';
        seaTestInstances[1].Location_Map_Link_Override__c = 'Map link override';
        seaTestInstances[1].Feed_Registration_Button_Text_Override__c = 'New button override';
        update seaTestInstances;

        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            //test instance override
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/summiteventfeed';
            req.httpMethod = 'GET';
            req.addHeader('Content-Type', 'application/json');
            req.params.put('feedType', 'eventList');
            req.params.put('hideClosed', 'blah');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();

            System.assert(res.responseBody.toString().contains('testingAnOverride.com'));
            System.assert(res.responseBody.toString().contains('New location override'));
            System.assert(res.responseBody.toString().contains('Map link override'));
            System.assert(res.responseBody.toString().contains('New button override'));
        }
    }
}