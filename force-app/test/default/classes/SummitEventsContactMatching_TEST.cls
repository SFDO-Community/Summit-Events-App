// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Matthew Hubert on 1/5/2021.

@IsTest
public class SummitEventsContactMatching_TEST {

    // Mock class within the test class
    public class SummitEventsFindDuplicatesMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"duplicateResults":[{"duplicateRule":"Standard_Contact_Duplicate_Rule","matchResults":[{"matchRecords":[{"record":{"Id":"0031t00000XXXXXXAA1","Name":"Test Record"}}]}]}]}]');
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void setup() {

        //Add contacts for testing
        List<Contact> testContacts = new List<Contact>();
        testContacts.add(new Contact(FirstName = 'Test', LastName = 'Record', Email = 'test@example.com'));
        //testContacts.add(new Contact(FirstName = 'Test', LastName = 'Record', Email = 'test@example.com'));
        insert testContacts;

        //Add leads for testing
        List<Lead> testLeads = new List<Lead>();
        testLeads.add(new Lead(FirstName = 'Test', LastName = 'Record', Email = 'test@example.com', Company = 'Big T Record'));
        insert testLeads;

        //Add accounts for testing
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name = 'Big T Record'));
        insert testAccounts;

        // Create a list to hold custom metadata records
        SummitEventsContactMatching.mappedMatchingMethods = new Map<String, List<Summit_Events_Contact_Matching_Mapping__mdt>>();
        String namespace = SummitEventsNamespace.StrTokenNSPrefix('');
        List<Summit_Events_Contact_Matching_Mapping__mdt> cmmList = new List<Summit_Events_Contact_Matching_Mapping__mdt>();
        List<Summit_Events_Contact_Matching_Mapping__mdt> cmmList2 = new List<Summit_Events_Contact_Matching_Mapping__mdt>();
        // Create a custom metadata record
        Summit_Events_Contact_Matching_Mapping__mdt cmm = new Summit_Events_Contact_Matching_Mapping__mdt(
                DeveloperName = 'Title_Test',
                MasterLabel = 'Title Test',
                Source_Type__c = 'Field',
                Source_Object__c = namespace + 'Summit_Events_Registration__c',
                Source_Value__c = namespace + 'Registrant_Last_Name__c',
                Contact_Field_API_Name__c = 'Title',
                Contact_Matching_Method__c = 'Admissions'
        );
        // Add the custom metadata record to the list
        cmmList.add(cmm);
        // Insert the custom metadata records
        SummitEventsContactMatching.mappedMatchingMethods.put(cmm.Contact_Matching_Method__c, cmmList);
        Summit_Events_Contact_Matching_Mapping__mdt cmm2 = new Summit_Events_Contact_Matching_Mapping__mdt(
                DeveloperName = 'Title_Test',
                MasterLabel = 'Title Test',
                Source_Type__c = 'Field',
                Source_Object__c = namespace + 'Summit_Events_Registration__c',
                Source_Value__c = namespace + 'Registrant_Last_Name__c',
                Contact_Field_API_Name__c = 'Title',
                Contact_Matching_Method__c = 'Red'
        );
        cmmList2.add(cmm2);
        SummitEventsContactMatching.mappedMatchingMethods.put(cmm2.Contact_Matching_Method__c, cmmList2);

    }

    @IsTest
    static void SummitEventsContactMatching1() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Record', 'test@example.com', '55555', '1971-03-22', '2012', null);

        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);
        seaTestEvent.Contact_Matching_Rules__c = 'Use Salesforce Duplicate Rule';
        seaTestEvent.Contact_Creation_Duplicate_Rule__c = 'Standard Contact Duplicate Rule';
        seaTestEvent.Custom_Metadata_Contact_Matching_Method__c = 'Admissions';
        seaTestEvent.Contact_Matching_No_Match_Behavior__c = 'Create Contact';
        seaTestEvent.Contact_Matching_Multiple_Match_Behavior__c = 'Match with most recently modified';
        update seaTestEvent;

        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Admin');

        SummitEventsContactMatching.mappedMatchingMethods = new Map<String, List<Summit_Events_Contact_Matching_Mapping__mdt>>();
        List<Summit_Events_Contact_Matching_Mapping__mdt> cmmList = new List<Summit_Events_Contact_Matching_Mapping__mdt>();
        String namespace = SummitEventsNamespace.StrTokenNSPrefix('');
        // Create a custom metadata record
        Summit_Events_Contact_Matching_Mapping__mdt cmm = new Summit_Events_Contact_Matching_Mapping__mdt(
                DeveloperName = 'Title_Test',
                MasterLabel = 'Title Test',
                Source_Type__c = 'Field',
                Source_Object__c = namespace + 'Summit_Events_Registration__c',
                Source_Value__c = namespace + 'Registrant_Last_Name__c',
                Contact_Field_API_Name__c = 'Title',
                Contact_Matching_Method__c = 'Admissions'
        );
        // Add the custom metadata record to the list
        cmmList.add(cmm);
        // Insert the custom metadata records

        SummitEventsContactMatching.mappedMatchingMethods.put(cmm.Contact_Matching_Method__c, cmmList);

        System.runAs(testUser) {
            Test.startTest();
            seaTestRegistration.Status__c = 'Registered';
            seaTestRegistration.Registrant_Preferred_First_Name__c = 'Big T';
            update seaTestRegistration;
            System.assert(String.isBlank(seaTestRegistration.Contact__c));

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
    }

    @IsTest
    static void testSearchForContacts() {
        // Prepare test data
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Record', 'test@example.com', '55555', '1971-03-22', '2012', null);

        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);
        seaTestEvent.Contact_Matching_Rules__c = 'Use Salesforce Duplicate Rule';
        seaTestEvent.Contact_Creation_Duplicate_Rule__c = 'Standard Contact Duplicate Rule';
        seaTestEvent.Custom_Metadata_Contact_Matching_Method__c = 'Admissions';
        seaTestEvent.Contact_Matching_No_Match_Behavior__c = 'Create Contact';
        seaTestEvent.Contact_Matching_Multiple_Match_Behavior__c = 'Match with most recently modified';
        update seaTestEvent;

        Map<Id, Summit_Events__c> matchingRules = new Map<Id, Summit_Events__c>();
        matchingRules.put(seaTestEvent.Id, seaTestEvent);

        Map<String, List<SObject>> contactMappings = new Map<String, List<SObject>>();
        Map<String, List<SObject>> leadMappings = new Map<String, List<SObject>>();

        // Set the mock
        Test.setMock(HttpCalloutMock.class, new SummitEventsFindDuplicatesMock());

        List<Summit_Events_Registration__c> newRegistrations = new List<Summit_Events_Registration__c>();
        newRegistrations.add(seaTestRegistration);
        // Call the method to test
        Test.startTest();
        SummitEventsContactMatching.searchForContacts(newRegistrations, matchingRules, contactMappings, leadMappings);
        Test.stopTest();

        // Add assertions to verify the behavior
        System.assertNotEquals(null, seaTestRegistration.Contact__c, 'The Contact__c field should not be null');
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
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Admin');
        System.runAs(testUser) {
            Test.startTest();
            seaTestRegistration.Registrant_Preferred_First_Name__c = 'Big T';
            update seaTestRegistration;
            Test.stopTest();
        }
    }

    @IsTest
    static void SummitEventsLeadMatching1() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Record', 'test@example.com', '55555', '1971-03-22', '2012', null);
        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);
        seaTestEvent.Contact_Matching_No_Match_Behavior__c = null;
        seaTestEvent.Lead_matching_rules__c = 'Use Salesforce Duplicate Rule';
        seaTestEvent.Lead_Creation_Duplicate_Rule__c = 'Standard Lead Duplicate Rule';
        seaTestEvent.Lead_Matching_No_Match_Behavior__c = 'Create Lead';
        seaTestEvent.Lead_Matching_Multiple_Match_Behavior__c = 'Match with most recently modified';
        seaTestEvent.Custom_Metadata_Lead_Matching_Method__c = 'Red';
        update seaTestEvent;
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Admin');
        System.runAs(testUser) {
            Test.startTest();
            seaTestRegistration.Status__c = 'Registered';
            seaTestRegistration.Registrant_Preferred_First_Name__c = 'Big T';
            update seaTestRegistration;

            seaTestRegistration.Lead__c = null;
            update seaTestRegistration;

            Test.stopTest();
        }
    }

    @IsTest
    static void SummitEventsPersonMatching() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'Test', 'Record', 'test@example.com', '55555', '1971-03-22', '2012', null);
        Summit_Events__c seaTestEvent = SummitEventsTestSharedDataFactory.getEventRecord(seaTestInstances[1].Event__c);
        seaTestEvent.Person_Matching_Rules__c = 'Use Salesforce Duplicate Rule';
        seaTestEvent.Person_Creation_Duplicate_Rule__c = 'Standard Person Account Duplicate Rule';
        seaTestEvent.Person_Matching_No_Match_Behavior__c = 'Create Person Account';
        seaTestEvent.Person_Matching_Multiple_Match_Behavior__c = 'Match with most recently modified';
        seaTestEvent.Custom_Metadata_Contact_Matching_Method__c = 'Admissions';
        update seaTestEvent;
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Admin');
        System.runAs(testUser) {
            Test.startTest();
            seaTestRegistration.Registrant_Preferred_First_Name__c = 'Big T';
            update seaTestRegistration;

            seaTestEvent.Contact_Matching_Multiple_Match_Behavior__c = 'Match with most recently modified';
            update seaTestEvent;

            // System.assert(String.isNotBlank(registration.Contact__c));
            Test.stopTest();
        }
    }

    @IsTest
    static void testMappedMatchingMethods() {
        // Prepare test data
        Map<String, List<SObject>> testData = new Map<String, List<SObject>>();
        testData.put('TestMethod', new List<SObject>{
                new Contact(LastName = 'Test')
        });

        // Set the test data to the property
        SummitEventsContactMatching.mappedMatchingMethods = testData;

        // Add assertions to verify the behavior
        System.assertEquals(testData, SummitEventsContactMatching.mappedMatchingMethods);
    }

    @IsTest
    static void testMatchingLog() {
        // Create a mock registration record
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'John', 'Doe', 'john.doe@example.com', '12345', '1971-03-22', '2012', null);

        // Create a list of mock SObject records
        List<SObject> foundObjects = new List<SObject>();

        // Create a mock Contact record
        Contact contact = new Contact(
                LastName = 'Smith',
                FirstName = 'Jane',
                Email = 'jane.smith@example.com',
                MailingPostalCode = '67890'
        );
        insert contact;
        foundObjects.add(contact);

        // Create a mock Lead record
        Lead lead = new Lead(
                LastName = 'Brown',
                FirstName = 'Charlie',
                Email = 'charlie.brown@example.com',
                PostalCode = '54321',
                Company = 'Charlie Brown Inc.'
        );
        insert lead;
        foundObjects.add(lead);

        // Call the matchingLog method
        String result = SummitEventsContactMatching.matchingLog(seaTestRegistration, foundObjects, 'Heading 1', 'Heading 2', true);

        // Verify the result
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assert(result.contains('Doe'), 'The result should contain the last name Doe');
        System.assert(result.contains('John'), 'The result should contain the first name John');
        System.assert(result.contains('john.doe@example.com'), 'The result should contain the email john.doe@example.com');
        System.assert(result.contains('12345'), 'The result should contain the zip code 12345');
        System.assert(result.contains('Smith'), 'The result should contain the last name Smith');
        System.assert(result.contains('Jane'), 'The result should contain the first name Jane');
        System.assert(result.contains('jane.smith@example.com'), 'The result should contain the email jane.smith@example.com');
        System.assert(result.contains('67890'), 'The result should contain the zip code 67890');
        System.assert(result.contains('Brown'), 'The result should contain the last name Brown');
        System.assert(result.contains('Charlie'), 'The result should contain the first name Charlie');
        System.assert(result.contains('charlie.brown@example.com'), 'The result should contain the email charlie.brown@example.com');
        System.assert(result.contains('54321'), 'The result should contain the zip code 54321');
    }

    @IsTest
    static void testApplyCorrectFieldTypesToValues() {
        // Create a mock map of field values
        Lead newLead = new Lead();
        Contact newContact = new Contact();
        Date newDate = Date.newInstance(2021, 1, 5);
        SObject result = SummitEventsContactMatching.applyCorrectFieldTypesToValues(newLead, 'AnnualRevenue', 100.00);
        SObject result2 = SummitEventsContactMatching.applyCorrectFieldTypesToValues(newLead, 'Company', 'Company Inc.');
        SObject result3 = SummitEventsContactMatching.applyCorrectFieldTypesToValues(newLead, 'HasOptedOutOfEmail', true);
        SObject result4 = SummitEventsContactMatching.applyCorrectFieldTypesToValues(newLead, 'NumberOfEmployees', 15);
        SObject result5 = SummitEventsContactMatching.applyCorrectFieldTypesToValues(newContact, 'Birthdate', newDate);
        Test.startTest();
        System.assertEquals(100.00, result.get('AnnualRevenue'), 'The AnnualRevenue field should be set to 100.00');
        System.assertEquals('Company Inc.', result2.get('Company'), 'The Company field should be set to Company Inc.');
        System.assertEquals(true, result3.get('HasOptedOutOfEmail'), 'The HasOptedOutOfEmail field should be set to true');
        System.assertEquals(15, result4.get('NumberOfEmployees'), 'The NumberOfEmployees field should be set to 15');
        System.assertEquals(newDate, result5.get('Birthdate'), 'The Birthdate field should be set to 2021-01-05');
        Test.stopTest();
    }
}