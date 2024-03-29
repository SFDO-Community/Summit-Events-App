// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEvents_TEST {
    @IsTest
    static void testBehavior() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEvents;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);

            SummitEventsController submitCtrl = new SummitEventsController();
            String namespace = SummitEventsNamespace.getNamespace();
            if (String.isNotBlank(namespace)) {
                System.assertEquals(submitCtrl.feedURL, 'https://google.com/services/apexrest/' + namespace + '/summiteventsfeed');
            } else {
                System.assertEquals(submitCtrl.feedURL, 'https://google.com/services/apexrest/summiteventsfeed');
            }

            Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
            //no trailing slash
            SummitEventsSettings.Community_Base_URL__c = 'https://google.com';
            upsert SummitEventsSettings;
            submitCtrl = new SummitEventsController();
            if (String.isNotBlank(namespace)) {
                System.assertEquals(submitCtrl.feedURL, 'https://google.com/services/apexrest/' + namespace + '/summiteventsfeed');
            } else {
                System.assertEquals(submitCtrl.feedURL, 'https://google.com/services/apexrest/summiteventsfeed');
            }

            Test.stopTest();
        }
    }
}