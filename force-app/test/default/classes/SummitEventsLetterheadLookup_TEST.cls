// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
public with sharing class SummitEventsLetterheadLookup_TEST {
    @IsTest static void testLetterheadLookup() {
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Test Event', '', true, true, '');
        SummitEventsTestSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        Summit_Events_Email__c testEvtEmail = SummitEventsTestSharedDataFactory.createTestTransactionEmail(evtInst, 'Registered', '');

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testEvtEmail);
        SummitEventsLetterheadLookupExtension emailController = new SummitEventsLetterheadLookupExtension(sc);
        emailController.getOrgWideEmail();
        emailController.getLetterheads();

        //Create fake brandTemplate since SF won't let you insert one
        BrandTemplate fakeBrandTemplate = new BrandTemplate(
                Id = SummitEventsTestSharedDataFactory.getFakeId(BrandTemplate.SObjectType),
                Name = 'Test',
                Value = '<body class="setupTab" ><style background-color="#FFFFFF" bEditID="b1st1" bLabel="body" ></style><center ><table cellpadding="0" width="500" cellspacing="0" id="topTable" height="450" ><tr valign="top" ><td ><style background-color="#FFFFFF" bEditID="r1st1" bLabel="header" vertical-align="top" height="5" text-align="left" ></style><img border="0" bEditID="r1sp1" bLabel="headerImage" id="r1sp1"><![CDATA[/servlet/servlet.ImageServer?id=0150m000000AN8V&oid=00D0m000000Cra6]]></img></td></tr><tr valign="top" ><td ><style background-color="#6600CC" bEditID="r2st1" bLabel="accent1" height="5" ></style><![CDATA[]]></td></tr><tr valign="top" ><td styleInsert="1" height="300" ><style background-color="#FFFFFF" bEditID="r3st1" color="#000000" bLabel="main" font-size="12pt" font-family="arial" ></style><![CDATA[]]></td></tr><tr valign="top" ><td ><style background-color="#6600CC" bEditID="r4st1" bLabel="accent2" height="5" ></style><![CDATA[]]></td></tr><tr valign="top" ><td ><style background-color="#FFFFFF" bEditID="r5st1" bLabel="footer" vertical-align="top" height="125" text-align="left" ></style><img border="0" bEditID="r5sp1" bLabel="footerImage" id="r5sp1"><![CDATA[/servlet/servlet.ImageServer?id=0150m000000AN8U&oid=00D0m000000Cra6]]></img></td></tr><tr valign="top" ><td ><style background-color="#FFFFFF" bEditID="r6st1" bLabel="accent3" height="5" ></style><![CDATA[]]></td></tr></table></center></body>'
        );
        emailController.brandTemplates = new Map<Id, BrandTemplate>();
        emailController.brandTemplates.put(fakeBrandTemplate.Id, fakeBrandTemplate);
        emailController.SummitEvt.Letterhead_Id__c = fakeBrandTemplate.Id;


        OrgWideEmailAddress fakeOrgWideEmailAddress = new OrgWideEmailAddress (
                Id = SummitEventsTestSharedDataFactory.getFakeId(OrgWideEmailAddress.SObjectType),
                Address = 'thad+owe@valleyhill.net',
                DisplayName = 'Test'
        );
        emailController.oweList = new Map<Id, OrgWideEmailAddress>();
        emailController.oweList.put(fakeOrgWideEmailAddress.Id, fakeOrgWideEmailAddress);
        emailController.SummitEvt.Org_Email_Id__c = fakeOrgWideEmailAddress.Id;
        emailController.save();
        Test.stopTest();
    }
}