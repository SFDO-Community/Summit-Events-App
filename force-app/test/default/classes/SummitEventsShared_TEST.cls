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
    static void getRegistrationByIdHandlesUnusableIds() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        String missingRegistrationId = SummitEventsTestSharedDataFactory.getFakeId(Summit_Events_Registration__c.SObjectType);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        System.runAs(testUser) {
            Test.startTest();
            //Cookie values can be blank, mangled or point at a deleted record; none of these should throw
            System.assertEquals(null, SummitEventsReadShared.getRegistrationById(''));
            System.assertEquals(null, SummitEventsReadShared.getRegistrationById(null));
            System.assertEquals(null, SummitEventsReadShared.getRegistrationById('not-an-id'));
            System.assertEquals(null, SummitEventsReadShared.getRegistrationById(missingRegistrationId));
            System.assertEquals(seaTestRegistration.Id, SummitEventsReadShared.getRegistrationById(seaTestRegistration.Id).Id);
            Test.stopTest();
        }
    }
}