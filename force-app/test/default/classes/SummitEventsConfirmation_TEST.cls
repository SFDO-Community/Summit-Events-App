// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsConfirmation_TEST {
    @IsTest static void testRegConfirmationPage() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c evtReg = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsConfirmation;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);
            SummitEventsShared SEShared = new SummitEventsShared();
            SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, evtReg.Id);
            SummitEventsConfirmationController confirmCtrl = new SummitEventsConfirmationController();
            confirmCtrl.eventIsClosed = false;
            confirmCtrl.checkEventDetails();
            Summit_Events_Registration__c checkRegistrationStatus = [
                    SELECT Id, Status__c
                    FROM
                            Summit_Events_Registration__c
                    WHERE Id = :evtReg.Id
            ];
            System.assertEquals(checkRegistrationStatus.Status__c, 'Registered');
            Test.stopTest();
        }
    }

    @IsTest static void testConfirmationWithGuests() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');

        //Test question with empty map_to_field defined.
        List<Summit_Events_Question__c> testQuestions = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'Text Area', 'Guest');
        List<Summit_Events_Question__c> testQuestions2 = SummitEventsTestSharedDataFactory.addQuestionsToEvent(seaTestInstances[1].Event__c, 'picklist', 'Guest');
        testQuestions2[0].Is_Visible__c = false;
        update testQuestions2;

        SummitEventsShared seaShared = new SummitEventsShared();

        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsConfirmation;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);
            SummitEventsShared SEShared = new SummitEventsShared();
            SEShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);
            SummitEventsConfirmationController confirmCtrl = new SummitEventsConfirmationController();
            confirmCtrl.eventIsClosed = false;
            confirmCtrl.checkEventDetails();
            Summit_Events_Registration__c checkRegistrationStatus = [
                    SELECT Id, Status__c
                    FROM
                            Summit_Events_Registration__c
                    WHERE Id = :seaTestRegistration.Id
            ];
            System.assertEquals(checkRegistrationStatus.Status__c, 'Registered');
            Test.stopTest();
        }
    }
}