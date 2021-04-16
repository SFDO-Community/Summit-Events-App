// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsCancelReview_TEST {
    @IsTest static void testRegCancel() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c testRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        testRegistration.Status__c = 'Registered';
        update testRegistration;
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsCancelReview;
            Test.setCurrentPage(pageRef);
            SummitEventsShared SEAShared = new SummitEventsShared();
            String encryptedRegistrationId = SEAShared.createEncryptedCookie('', seaTestInstances[1].Id, seaTestInstances[1].Event__c, testRegistration.Id);
            ApexPages.currentPage().getParameters().put('eventInfo', encryptedRegistrationId);
            SummitEventsCancelReviewController cancelReviewCtrl = new SummitEventsCancelReviewController();
            cancelReviewCtrl.cancelRegistration();

            Summit_Events_Registration__c statusRegistration = [
                    SELECT Id, Status__c
                    FROM Summit_Events_Registration__c
                    WHERE Id = :testRegistration.Id
            ];
            System.assertEquals(statusRegistration.Status__c, 'Cancelled');
            Test.stopTest();
        }
    }

    @IsTest static void testEncryptedRegistrationTamper() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c testRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        testRegistration.Status__c = 'Registered';
        update testRegistration;
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsCancelReview;
            Test.setCurrentPage(pageRef);
            SummitEventsShared SEAShared = new SummitEventsShared();
            String encryptedRegistrationId = SEAShared.createEncryptedCookie('', seaTestInstances[1].Id, seaTestInstances[1].Event__c, testRegistration.Id);
            ApexPages.currentPage().getParameters().put('eventInfo', encryptedRegistrationId + 'TAMPER');
            SummitEventsCancelReviewController cancelReviewCtrl = new SummitEventsCancelReviewController();
            cancelReviewCtrl.cancelRegistration();

            Summit_Events_Registration__c statusRegistration = [
                    SELECT Id, Status__c
                    FROM Summit_Events_Registration__c
                    WHERE Id = :testRegistration.Id
            ];
            System.assertEquals(statusRegistration.Status__c, 'Registered');
            System.assertEquals(cancelReviewCtrl.eventNotFound, TRUE);
            Test.stopTest();
        }
    }
}