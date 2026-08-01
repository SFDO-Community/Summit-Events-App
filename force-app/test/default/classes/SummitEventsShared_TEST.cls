// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 6/12/2018.

@IsTest
public with sharing class SummitEventsShared_TEST {

    @IsTest
    static void testDepreciation() {

        Boolean depreciated = true;
        System.assertEquals(depreciated, true);
    }

    @IsTest
    static void testGetSafeUrlAllowsHttpAndHttps() {
        System.assertEquals('https://example.com/map', SummitEventsShared.getSafeUrl('https://example.com/map'));
        System.assertEquals('http://example.com/map', SummitEventsShared.getSafeUrl('http://example.com/map'));
        System.assertEquals('HTTPS://EXAMPLE.COM/MAP', SummitEventsShared.getSafeUrl('HTTPS://EXAMPLE.COM/MAP'));
    }

    @IsTest
    static void testGetSafeUrlBlocksUnsafeSchemes() {
        System.assertEquals('', SummitEventsShared.getSafeUrl('javascript:alert(document.cookie)'));
        System.assertEquals('', SummitEventsShared.getSafeUrl('data:text/html,<script>alert(1)</script>'));
        System.assertEquals('', SummitEventsShared.getSafeUrl(''));
        System.assertEquals('', SummitEventsShared.getSafeUrl(null));
    }

    @IsTest
    static void testSanitizeRichTextStripsDangerousConstructsButKeepsFormatting() {
        String malicious = '<b>Welcome</b><script>alert(1)</script><iframe src="javascript:alert(2)"></iframe><a href="javascript:alert(3)">link</a><img src="x" onerror="alert(4)"/>';
        String sanitized = SummitEventsShared.sanitizeRichText(malicious);

        System.assert(sanitized.contains('<b>Welcome</b>'), 'Normal formatting should be preserved.');
        System.assert(!sanitized.containsIgnoreCase('<script'), 'Script tags should be stripped.');
        System.assert(!sanitized.containsIgnoreCase('<iframe'), 'Iframe tags should be stripped.');
        System.assert(!sanitized.containsIgnoreCase('javascript:'), 'javascript: URIs should be neutralized.');
        System.assert(!sanitized.containsIgnoreCase('onerror='), 'Inline event handlers should be stripped.');
    }

    @IsTest
    static void testAdminOpenSecretAutoGeneratesWhenBlank() {
        //Establishes Community_Base_URL__c/Cookie_Encryption_Key__c, which checkForEvent depends on.
        SummitEventsTestSharedDataFactory.createTestEvent();

        //createTestEvent pre-populates Admin_Open_Secret__c (see its comment for why), so clear it back
        //to blank here since this test specifically exercises the auto-generate-when-blank behavior.
        Summit_Events_Settings__c seaSettings = Summit_Events_Settings__c.getOrgDefaults();
        seaSettings.Admin_Open_Secret__c = null;
        upsert seaSettings;
        System.assert(String.isBlank(seaSettings.Admin_Open_Secret__c), 'Secret should start blank before checkForEvent runs.');

        Test.startTest();
        PageReference pageRef = Page.SummitEventsRegister;
        Test.setCurrentPage(pageRef);
        SummitEventsShared.checkForEvent('register');
        Test.stopTest();

        Summit_Events_Settings__c refreshedSettings = Summit_Events_Settings__c.getOrgDefaults();
        System.assertNotEquals(null, refreshedSettings.Admin_Open_Secret__c);
        System.assert(String.isNotBlank(refreshedSettings.Admin_Open_Secret__c), 'A secret should be auto-generated on first use.');
    }

    @IsTest
    static void testAdminOpenSecretBypassesClosureWhenMatching() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        //Update via a minimal sObject (Id + changed field only) rather than the factory-returned
        //instance, which still carries Event__c (the Master-Detail field) as populated from insert -
        //resending it on update is unnecessary and has been observed to intermittently fail post-deploy
        //in fresh orgs.
        update new Summit_Events_Instance__c(Id = seaTestInstances[1].Id, Active_Status__c = 'Closed');

        Summit_Events_Settings__c seaSettings = Summit_Events_Settings__c.getOrgDefaults();
        seaSettings.Admin_Open_Secret__c = 'correct-secret-value';
        upsert seaSettings;

        Summit_Events_Instance__c freshInstance = [SELECT Id, Active_Status__c, Current_Available_Capacity__c, Registration_Close_Date__c, Registration_Close_Time__c, Instance_Time_Zone__c FROM Summit_Events_Instance__c WHERE Id = :seaTestInstances[1].Id];

        Test.startTest();
        PageReference pageRef = Page.SummitEventsRegister;
        pageRef.getParameters().put('adminopen', 'correct-secret-value');
        Test.setCurrentPage(pageRef);

        System.assertEquals(false, SummitEventsShared.isEventClosed(freshInstance, 'Active'), 'Matching secret should reopen a closed instance.');

        pageRef.getParameters().put('adminopen', 'wrong-guess');
        Test.setCurrentPage(pageRef);
        System.assertEquals(true, SummitEventsShared.isEventClosed(freshInstance, 'Active'), 'A non-matching adminopen value should not bypass closure.');
        Test.stopTest();
    }

    @IsTest
    static void testSanitizeRichTextHandlesBlankAndBulk() {
        System.assertEquals(null, SummitEventsShared.sanitizeRichText(null));
        System.assertEquals('', SummitEventsShared.sanitizeRichText(''));

        List<String> bulkValues = new List<String>{
                '<p>Fine 1</p>', '<script>bad()</script><p>Fine 2</p>', '<p onclick="bad()">Fine 3</p>'
        };
        for (String value : bulkValues) {
            String sanitized = SummitEventsShared.sanitizeRichText(value);
            System.assert(!sanitized.containsIgnoreCase('<script'));
            System.assert(!sanitized.containsIgnoreCase('onclick='));
        }
    }
}