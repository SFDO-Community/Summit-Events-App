// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
public class SummitEventsRegistration_TEST {
    @IsTest
    public static void TestSummitEventsRegistration() {

        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Tester', 'test@test.net', '55555', '1971-03-22', '2012', null);
        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);

        Test.startTest();
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

        seaTestRegistration.Status__c = 'Registered';
        update seaTestRegistration;

        seaTestRegistration.Substatus__c = 'In Progress';
        update seaTestRegistration;

        List<Task> emailTasks = [
                SELECT Id, Subject
                FROM Task
                WHERE WhatId = :seaTestRegistration.Id
                AND Type = 'Email'
                AND Status = 'Completed'
                AND Priority = 'Low'
                AND WhoId = :seaTestRegistration.Contact__c
        ];

        //Two tasks should have been created when both status emails were sent
        System.assertEquals(emailTasks.size(), 2);
        Test.stopTest();
    }
}