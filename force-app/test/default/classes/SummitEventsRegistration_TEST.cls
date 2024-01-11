// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
public class SummitEventsRegistration_TEST {
    @IsTest
    public static void TestSummitEventsRegistration() {

        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Tester', 'test@test.net', '55555', '1971-03-22', '2012', null);

        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);

        Summit_Events_Email__c email1 = new Summit_Events_Email__c();
        email1.Event__c = seaTestInstances[1].Event__c;
        email1.Action_Status__c = 'Registered';
        email1.Email_Content__c = 'Sample text here';
        email1.Letterhead_HTML__c = 'Letterhead goes here<br/>[[DONT_DELETE_CONTENT_HERE]]';
        email1.BCC_Email__c = 'bcc@example.com';

        insert email1;
        Summit_Events_Email__c email2 = new Summit_Events_Email__c();
        email2.Event__c = seaTestInstances[1].Event__c;
        email2.Action_Status__c = 'Registered';
        email2.Action_Sub_status__c = 'In Progress';
        email2.Email_Content__c = 'Sample text here {!Registrant_Last_Name__c} {!Add_To_Calendar_Link__c}';
        email2.Letterhead_HTML__c = 'Letterhead goes here<br/>[[DONT_DELETE_CONTENT_HERE]]';
        email2.BCC_Email__c = 'bcc@example.com';
        insert email2;

        Test.startTest();
        seaTestRegistration.Status__c = 'Registered';
        update seaTestRegistration;

        seaTestRegistration.Substatus__c = 'In Progress';
        update seaTestRegistration;

        List<Task> emailTasks = [
                SELECT Id, Subject, Description
                FROM Task
                WHERE WhatId = :seaTestRegistration.Id
                AND Type = 'Email'
                AND Status = 'Completed'
                AND Priority = 'Low'
                AND WhoId = :seaTestRegistration.Contact__c
        ];

        System.debug(JSON.serialize(emailTasks));
        //Two tasks should have been created when both status emails were sent
        System.assertEquals(emailTasks.size(), 2);
        Test.stopTest();
    }

    @IsTest
    public static void TestSummitEventsMultiRegistration() {

        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();

        List<Summit_Events_Registration__c> seaRegistrations = new List<Summit_Events_Registration__c>();

        for (Integer x = 0; x < 5; x++) {
            Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test' + x, 'Tester' + x, 'test+' + x + '@test.net', '55555', '1971-03-22', '2012', null);
            seaRegistrations.add(seaTestRegistration);
        }

        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);

        Summit_Events_Email__c email1 = new Summit_Events_Email__c();
        email1.Event__c = seaTestInstances[1].Event__c;
        email1.Action_Status__c = 'Registered';
        email1.Email_Content__c = 'Sample text here';
        email1.Letterhead_HTML__c = 'Letterhead goes here<br/>[[DONT_DELETE_CONTENT_HERE]]';
        email1.BCC_Email__c = 'bcc@example.com';
        insert email1;

        Test.startTest();
        List<Id> contactIds = new List<Id>();
        List<Id> registrationIds = new List<Id>();
        for (Summit_Events_Registration__c seaRegistration : seaRegistrations) {
            seaRegistration.Status__c = 'Registered';
            contactIds.add(seaRegistration.Contact__c);
            registrationIds.add(seaRegistration.Id);
        }
        update seaRegistrations;

        List<Task> emailTasks = [
                SELECT Id, Subject, Description
                FROM Task
                WHERE WhatId IN :registrationIds
                AND Type = 'Email'
                AND Status = 'Completed'
                AND Priority = 'Low'
                AND WhoId IN :contactIds
        ];
        System.assertEquals(emailTasks.size(), 5);
        Test.stopTest();
    }
}