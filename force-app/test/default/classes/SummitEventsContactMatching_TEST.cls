// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Matthew Hubert on 1/5/2021.

@IsTest
public class SummitEventsContactMatching_TEST {
    @IsTest
    static void SummitEventsContactMatching1() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Record', 'test@example.com', '55555', '1971-03-22', '2012', null);
        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);
        seaTestEvent.Contact_Matching_Rules__c = 'Use Salesforce Duplicate Rule';
        seaTestEvent.Contact_Creation_Duplicate_Rule__c = 'Standard Contact Duplicate Rule';
        seaTestEvent.Custom_Metadata_Contact_Matching_Method__c = 'Admissions';
        update seaTestEvent;

        Test.startTest();
        seaTestRegistration.Status__c = 'Registered';
        seaTestRegistration.Registrant_Preferred_First_Name__c = 'Big T';
        update seaTestRegistration;

        seaTestRegistration.Contact__c = null;
        seaTestRegistration.Registrant_Date_of_Birth__c = System.today();
        update seaTestRegistration;

        seaTestRegistration.Contact__c = null;
        seaTestRegistration.Registrant_First_Name__c = 'Tester';
        update seaTestRegistration;

        seaTestRegistration.Contact__c = null;
        seaTestRegistration.Registrant_Phone__c = '1234567890';
        update seaTestRegistration;

        System.assert(String.isBlank(seaTestRegistration.Contact__c));

        Test.stopTest();
    }

    @IsTest
    static void SummitEventsContactMatching2() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Record', 'test@example.com', '55555', '1971-03-22', '2012', null);
        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);
        seaTestEvent.Contact_Matching_Rules__c = 'Use Salesforce Duplicate Rule';
        seaTestEvent.Contact_Creation_Duplicate_Rule__c = 'Standard Contact Duplicate Rule';
        seaTestEvent.Custom_Metadata_Contact_Matching_Method__c = 'Admissions';
        seaTestEvent.Contact_Matching_Multiple_Match_Behavior__c = 'Skip matching';
        update seaTestEvent;

        Test.startTest();
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;

        Contact c1 = new Contact(FirstName = 'Test', LastName = 'Record', Email = 'test@example.com');
        insert c1;

        Contact c2 = new Contact(FirstName = 'Test', LastName = 'Record', Email = 'test@example.com');
        Database.insert(c2, dml);
        seaTestRegistration.Registrant_Preferred_First_Name__c = 'Big T';
        update seaTestRegistration;

        Summit_Events_Registration__c registration = [SELECT Id, Contact__c FROM Summit_Events_Registration__c WHERE Id = :seaTestRegistration.Id];
        System.assert(String.isBlank(registration.Contact__c));

        seaTestEvent.Contact_Matching_Multiple_Match_Behavior__c = 'Match with most recently modified';
        update seaTestEvent;

        update seaTestRegistration;
        registration = [SELECT Id, Contact__c FROM Summit_Events_Registration__c WHERE Id = :registration.Id];
        System.assert(String.isNotBlank(registration.Contact__c));
        Test.stopTest();
    }
}