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
            Database.upsert(SummitEventsSettings, true, System.AccessLevel.SYSTEM_MODE);
            submitCtrl = new SummitEventsController();
            if (String.isNotBlank(namespace)) {
                System.assertEquals(submitCtrl.feedURL, 'https://google.com/services/apexrest/' + namespace + '/summiteventsfeed');
            } else {
                System.assertEquals(submitCtrl.feedURL, 'https://google.com/services/apexrest/summiteventsfeed');
            }

            Test.stopTest();
        }
    }

    @IsTest
    static void testJavascriptUrlFieldsAreRejectedByValidationRule() {
        Test.startTest();
        try {
            insert new Summit_Events__c(
                    Name = 'VR Test Event',
                    Event_Name__c = 'VR Test Event',
                    Start_Date__c = Date.today(),
                    End_Date__c = Date.today().addDays(1),
                    Event_Home_Link_URL__c = 'javascript:alert(1)'
            );
            System.assert(false, 'Insert should have been blocked by the Event_Home_Link_URL_Must_Be_HTTP validation rule.');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('Event Home Link URL must start with http'));
        }
        Test.stopTest();
    }

    @IsTest
    static void testHttpUrlFieldsAreAllowedByValidationRule() {
        Test.startTest();
        Summit_Events__c newEvent = new Summit_Events__c(
                Name = 'VR Test Event 2',
                Event_Name__c = 'VR Test Event 2',
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addDays(1),
                Event_Home_Link_URL__c = 'https://example.com',
                Location_Map_Link__c = 'http://example.com/map'
        );
        insert newEvent;
        System.assertNotEquals(null, newEvent.Id);
        Test.stopTest();
    }

    @IsTest
    static void testRichTextFieldsAreSanitizedOnSave() {
        Test.startTest();
        Summit_Events__c newEvent = new Summit_Events__c(
                Name = 'Sanitize Test Event',
                Event_Name__c = 'Sanitize Test Event',
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addDays(1),
                Event_Full_Text__c = '<b>Welcome</b><script>alert(1)</script>',
                Event_Footer__c = '<p onclick="bad()">Footer</p>'
        );
        insert newEvent;

        Summit_Events__c savedEvent = [SELECT Event_Full_Text__c, Event_Footer__c FROM Summit_Events__c WHERE Id = :newEvent.Id];
        System.assert(savedEvent.Event_Full_Text__c.contains('<b>Welcome</b>'), 'Normal formatting should be preserved.');
        System.assert(!savedEvent.Event_Full_Text__c.containsIgnoreCase('<script'), 'Script tags should be stripped on save.');
        System.assert(!savedEvent.Event_Footer__c.containsIgnoreCase('onclick='), 'Inline event handlers should be stripped on save.');
        Test.stopTest();
    }
}