// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsFeed_TEST {
    @IsTest static void testEventFeed() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();

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

        //Test sex dd request
        req.params.remove('feedType');
        req.params.put('feedType', 'sexDD');
        RestContext.request = req;
        SummitEventsFeed.getSummitEventsFeed();

        //test filter minus dates
        req.params.remove('feedType');
        req.params.put('feedType', 'eventList');
        RestContext.request = req;
        SummitEventsFeed.getSummitEventsFeed();

        //test filter minus dates
        req.params.remove('feedType');
        req.params.put('feedType', 'eventList');
        req.params.put('eventId', seaTestInstances[1].Id);
        req.params.put('sponsor', 'Big Business');
        req.params.put('longdesc', 'true');
        RestContext.request = req;
        SummitEventsFeed.getSummitEventsFeed();
        req.params.put('eventId', 'WRONG!');
        RestContext.request = req;
        SummitEventsFeed.getSummitEventsFeed();

        //test filter with start date
        req.params.put('viewStart', String.valueOf(Datetime.now().addMonths(-1)));
        RestContext.request = req;
        SummitEventsFeed.getSummitEventsFeed();

        //test filter with end date
        req.params.put('viewEnd', String.valueOf(Datetime.now().addMonths(1)));
        req.params.put('audience', 'Alumni');
        RestContext.request = req;
        SummitEventsFeed.getSummitEventsFeed();

        //test filter
        req.params.put('filter', 'OCB');
        RestContext.request = req;
        SummitEventsFeed.getSummitEventsFeed();

        //test filter
        req.params.put('rectype', 'UDAR');
        req.params.put('callback', 'UDAR');
        RestContext.request = req;
        SummitEventsFeed.getSummitEventsFeed();
        Test.stopTest();

    }
}