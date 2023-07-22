// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
public with sharing class SummitEventsLetterheadLookup_TEST {
    @IsTest static void testLetterheadLookup() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events__c testEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);
        SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        Summit_Events_Email__c testEvtEmail = SummitEventsTestSharedDataFactory.createTestTransactionEmail(seaTestInstances[1], 'Registered', '');

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testEvtEmail);
        SummitEventsLetterheadLookupExtension emailController = new SummitEventsLetterheadLookupExtension(sc);
        emailController.getOrgWideEmail();
        List<SelectOption> templateList = emailController.getLetterheads();
        System.assertEquals(templateList[1].getLabel(), 'SummitEvents Test Letterhead');

        List<Summit_Events_Email__c> testPreSelectionEmail = [SELECT Id, Name, Org_Email_Id__c, Letterhead_Id__c, Letterhead_Name__c FROM Summit_Events_Email__c WHERE Event__c = :testEvent.Id];
        System.assertEquals(testPreSelectionEmail[0].Letterhead_Name__c, null);
        System.assertEquals(testPreSelectionEmail[0].Letterhead_Id__c, null);

        //Create fake brandTemplate since SF won't let you insert one
        BrandTemplate fakeBrandTemplate = new BrandTemplate(
                Id = SummitEventsTestSharedDataFactory.getFakeId(BrandTemplate.SObjectType),
                Name = 'Test',
                Value = '<body class="setupTab" ><style background-color="#FFFFFF" bEditID="b1st1" bLabel="body" ></style><center ><table cellpadding="0" width="500" cellspacing="0" id="topTable" height="450" ><tr valign="top" ><td ><style background-color="#FFFFFF" bEditID="r1st1" bLabel="header" vertical-align="top" height="5" text-align="left" ></style><img border="0" bEditID="r1sp1" bLabel="headerImage" id="r1sp1"><![CDATA[/servlet/servlet.ImageServer?id=0150m000000AN8V&oid=00D0m000000Cra6]]></img></td></tr><tr valign="top" ><td ><style background-color="#6600CC" bEditID="r2st1" bLabel="accent1" height="5" ></style><![CDATA[]]></td></tr><tr valign="top" ><td styleInsert="1" height="300" ><style background-color="#FFFFFF" bEditID="r3st1" color="#000000" bLabel="main" font-size="12pt" font-family="arial" ></style><![CDATA[]]></td></tr><tr valign="top" ><td ><style background-color="#6600CC" bEditID="r4st1" bLabel="accent2" height="5" ></style><![CDATA[]]></td></tr><tr valign="top" ><td ><style background-color="#FFFFFF" bEditID="r5st1" bLabel="footer" vertical-align="top" height="125" text-align="left" ></style><img border="0" bEditID="r5sp1" bLabel="footerImage" id="r5sp1"><![CDATA[/servlet/servlet.ImageServer?id=0150m000000AN8U&oid=00D0m000000Cra6]]></img></td></tr><tr valign="top" ><td ><style background-color="#FFFFFF" bEditID="r6st1" bLabel="accent3" height="5" ></style><![CDATA[]]></td></tr></table></center></body>'
        );
        emailController.brandTemplates = new Map<Id, BrandTemplate>();
        emailController.brandTemplates.put(fakeBrandTemplate.Id, fakeBrandTemplate);
        emailController.summitEventsEmail.Letterhead_Id__c = fakeBrandTemplate.Id;


        OrgWideEmailAddress fakeOrgWideEmailAddress = new OrgWideEmailAddress (
                Id = SummitEventsTestSharedDataFactory.getFakeId(OrgWideEmailAddress.SObjectType),
                Address = 'thad+owe@valleyhill.net',
                DisplayName = 'Test'
        );
        emailController.oweList = new Map<Id, OrgWideEmailAddress>();
        emailController.oweList.put(fakeOrgWideEmailAddress.Id, fakeOrgWideEmailAddress);
        emailController.summitEventsEmail.Org_Email_Id__c = fakeOrgWideEmailAddress.Id;

        emailController.save();
        List<Summit_Events_Email__c> testSummitEventsEmail = [SELECT Id, Name, Letterhead__c, Letterhead_Id__c, Org_Email_Id__c FROM Summit_Events_Email__c WHERE Event__c = :testEvent.Id];
        System.assertNotEquals(testSummitEventsEmail[0].Org_Email_Id__c, null);
        System.assertNotEquals(testSummitEventsEmail[0].Letterhead_Id__c, null);
        Test.stopTest();
    }
}