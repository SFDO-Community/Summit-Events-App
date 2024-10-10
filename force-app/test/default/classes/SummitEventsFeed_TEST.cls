// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsFeed_TEST {
    @IsTest static void testEventFeed() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        List<SummitEventsFeed.eventItem> eventsList = new List<SummitEventsFeed.eventItem>();
        System.runAs(testUser) {

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/summiteventfeed';
            req.httpMethod = 'GET';
            req.addHeader('Content-Type', 'application/json');

            //Test audience dd request
            req.params.put('feedType', 'audienceDD');
            List<String> audience = SummitEventsTestSharedDataFactory.getPicklistItems('Summit_Events__c', 'Audience__c');
            RestContext.request = req;
            RestContext.response = res;

            Test.startTest();
            SummitEventsFeed.getSummitEventsFeed();
            //Get end of audience list because default is to not show "No Audience" first in list
            System.assert(res.responseBody.toString().contains(audience[audience.size() - 1]));
            //Test sex dd request
            req.params.remove('feedType');
            req.params.put('feedType', 'sexDD');
            List<String> genderDD = SummitEventsTestSharedDataFactory.getPicklistItems('Summit_Events_Registration__c', 'Registrant_Gender__c');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            System.assert(res.responseBody.toString().contains(genderDD[0]));

            //test parameterKey
            req.params.remove('feedType');
            req.params.put('feedType', 'parameterKey');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            //System.assert(res.responseBody.toString().contains('Male'));

            //test filter minus dates
            req.params.remove('feedType');
            req.params.put('feedType', 'eventList');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            System.assert(res.responseBody.toString().contains('Test Event - Test Event Session -1'), 'Returned instance list validated with one of the instance  titles');

            //test full feed for event instance and sponsor if there is value is sponsor
            req.params.remove('feedType');
            req.params.put('feedType', 'eventList');
            req.params.put('eventId', seaTestInstances[1].Event__c);
            List<String> sponsor = SummitEventsTestSharedDataFactory.getPicklistItems('Summit_Events__c', 'Event_Sponsor__c');
            if (sponsor.size() > 0) {
                Summit_Events__c eventUpdate = [SELECT Id FROM Summit_Events__c WHERE Id = :seaTestInstances[0].Event__c];
                eventUpdate.Event_Sponsor__c = sponsor[0];
                req.params.put('sponsor', sponsor[0]);
                update eventUpdate;
            }
            req.params.put('longdesc', 'true');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            eventsList = (List<SummitEventsFeed.eventItem>) JSON.deserialize(res.responseBody.toString(), List<SummitEventsFeed.eventItem>.class);
            System.assertEquals(eventsList.size(), seaTestInstances.size(), 'When event id is in the parameter with no filters all instances should be present.');
            if (sponsor.size() > 0) {
                System.assertEquals(eventsList[0].sponsors, sponsor[0], 'Applied and filtered event sponsor should be present in returned instance data/');
                req.params.remove('sponsor');
            }

            //Test if a non-event id is passed through
            req.params.remove('eventId');
            req.params.put('eventId', 'WRONG!');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();

            System.assert(res.responseBody.toString().contains('[]'), 'Event list should be empty if eventId is not an id');

            //test filter with start date
            req.params.remove('eventId');
            req.params.put('viewStart', String.valueOf(Date.today().addDays(10)));
            req.params.put('viewEnd', String.valueOf(Date.today().addDays(10)));
            req.params.put('hideClosed', 'true');

            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            eventsList = (List<SummitEventsFeed.eventItem>) JSON.deserialize(res.responseBody.toString(), List<SummitEventsFeed.eventItem>.class);
            System.assertEquals(eventsList.size(), 1, 'Only one instance fits the viewStart and viewEnd dates passed for one day.');

            //test filter
            req.params.remove('viewStart');
            req.params.remove('viewEnd');
            req.params.put('filter', 'OCB');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            System.assert(res.responseBody.toString().contains('[]'), 'No events target the filter so this should be empty');

            //test filter

            Summit_Events__c eventUpdate = [SELECT Id, Program_Filter__c FROM Summit_Events__c WHERE Id = :seaTestInstances[0].Event__c];
            eventUpdate.Program_Filter__c = 'OCB,BCY';
            update eventUpdate;

            //Select all instances that have a  start date and time in the future
            Time rightNow = Time.newInstance(System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());

            // Verify the count of active instances
            String instanceStartDate = Datetime.now().addDays(-30).format('yyyy-MM-dd') ;
            string instanceEndDate = Datetime.now().addDays(+30).format('yyyy-MM-dd');
            String activeInstanceQuery = 'SELECT COUNT() ';
            activeInstanceQuery += 'FROM Summit_Events_Instance__c ';
            activeInstanceQuery += 'WHERE Event__r.Event_Status__c = \'Active\' ';
            activeInstanceQuery += 'AND Active_Status__c = \'Active\' ';
            activeInstanceQuery += 'AND Event__r.Private_Event__c = FALSE ';
            activeInstanceQuery += 'AND Private_Instance__c = FALSE ';
            activeInstanceQuery += 'AND Event__r.Audience__c EXCLUDES (\'No Audience\') ';
            activeInstanceQuery += 'AND (Current_Available_Capacity__c > 0 OR Capacity__c = NULL) ';
            activeInstanceQuery += 'AND Instance_Start_Date__c >= ' + instanceStartDate + ' ';
            activeInstanceQuery += 'AND Instance_Start_Date__c <= ' + instanceEndDate + ' ';
            activeInstanceQuery += 'AND ((Event__r.Program_Filter__c LIKE \'%OCB%\') OR (Event__r.Program_Filter_2__c LIKE \'%OCB%\') OR (Event__r.Program_Filter_3__c LIKE \'%OCB%\') OR (Event__r.Location_Title__c LIKE \'%OCB%\') OR (Event__r.Location_Address__c LIKE \'%OCB%\') OR (Event__r.Location_Type__c LIKE \'%OCB%\') OR (Event__r.Building__c LIKE \'%OCB%\') OR (Event__r.Program_Filter__c LIKE \'%BCY%\') OR (Event__r.Program_Filter_2__c LIKE \'%BCY%\') OR (Event__r.Program_Filter_3__c LIKE \'%BCY%\') OR (Event__r.Location_Title__c LIKE \'%BCY%\') OR (Event__r.Location_Address__c LIKE \'%BCY%\') OR (Event__r.Location_Type__c LIKE \'%BCY%\') OR (Event__r.Building__c LIKE \'%BCY%\'))';
            Integer activeInstances = Database.countQuery(activeInstanceQuery);

            // Apply the same filter criteria to the request parameters
            req.params.put('viewStart', String.valueOf(Date.today().addDays(-30)));
            req.params.put('viewEnd', String.valueOf(Date.today().addDays(+30)));
            req.params.put('filter', 'OCB,BCY');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();

            eventsList = (List<SummitEventsFeed.eventItem>) JSON.deserialize(res.responseBody.toString(), List<SummitEventsFeed.eventItem>.class);
            Integer eventListSize = eventsList.size();

            // When test is run at cerain times of the day the past event Session -1 may not be present in the list
            activeInstances -= 1;
            for (SummitEventsFeed.eventItem event : eventsList) {
                if (event.title == 'Test Event - Test Event Session -1') {
                    activeInstances += 1;
                }
            }

            // Update the assertion to reflect the correct expected value
            System.assertEquals(eventListSize, activeInstances, 'All ' + activeInstances + ' instance have program related to them.');


            req.params.put('program', 'OCB');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();
            eventsList = (List<SummitEventsFeed.eventItem>) JSON.deserialize(res.responseBody.toString(), List<SummitEventsFeed.eventItem>.class);
            System.assertEquals(eventListSize, activeInstances, 'All ' + activeInstances + ' instance have program related to them.');

            //test filter
            req.params.put('rectype', 'UDAR');
            req.params.put('callback', 'UDAR');
            RestContext.request = req;
            RestContext.response = res;
            SummitEventsFeed.getSummitEventsFeed();

            System.assert(res.responseBody.toString().startsWith('UDAR(['));
            Test.stopTest();

        }
    }

    @IsTest static void testEventFeedOverrides() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        seaTestInstances[2].Alternate_Registration_URL_Override__c = 'https://testingAnOverride.com';
        seaTestInstances[2].Location_Address_Override__c = 'New location override';
        seaTestInstances[2].Location_Map_Link_Override__c = 'Map link override';
        seaTestInstances[2].Feed_Registration_Button_Text_Override__c = 'New button override';
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
            Test.startTest();
            System.assert(res.responseBody.toString().contains('testingAnOverride.com'));
            System.assert(res.responseBody.toString().contains('New location override'));
            System.assert(res.responseBody.toString().contains('Map link override'));
            System.assert(res.responseBody.toString().contains('New button override'));
            Test.stopTest();
        }
    }
}