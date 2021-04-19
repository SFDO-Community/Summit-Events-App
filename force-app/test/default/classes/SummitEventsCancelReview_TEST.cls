// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsCancelReview_TEST {
    @IsTest static void testRegCancel() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        SummitEventsShared SEAShared = new SummitEventsShared();
        String encryptedString = SEAShared.createEncryptedCookie('', seaTestRegistration.Event_Instance__c, seaTestRegistration.Event__c, seaTestRegistration.Id);
        encryptedString = EncodingUtil.urlDecode(encryptedString, 'UTF-8');
        if (encryptedString.length() > 255) {
            seaTestRegistration.Encrypted_Registration_Id_1__c = encryptedString.substring(0, 255);
            seaTestRegistration.Encrypted_Registration_Id_2__c = encryptedString.substring(255, encryptedString.length());
        } else {
            seaTestRegistration.Encrypted_Registration_Id_1__c = encryptedString;
        }
        seaTestRegistration.Status__c = 'Registered';
        update seaTestRegistration;

        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsCancelReview;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('eventInfo', seaTestRegistration.Encrypted_Registration_Id_1__c + seaTestRegistration.Encrypted_Registration_Id_2__c);
            ApexPages.currentPage().getParameters().put('eventInfo', encryptedString);

            SummitEventsCancelReviewController cancelReviewCtrl = new SummitEventsCancelReviewController();

            cancelReviewCtrl.cancelRegistration();

            Summit_Events_Registration__c statusRegistration = [
                    SELECT Id, Status__c
                    FROM Summit_Events_Registration__c
                    WHERE Id = :seaTestRegistration.Id
            ];

            System.assertEquals(statusRegistration.Status__c, 'Cancelled');
            Test.stopTest();
        }
    }

    @IsTest static void testEncryptedRegistrationTamper() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        SummitEventsShared SEAShared = new SummitEventsShared();
        String encryptedString = SEAShared.createEncryptedCookie('', seaTestRegistration.Event_Instance__c, seaTestRegistration.Event__c, seaTestRegistration.Id);
        encryptedString = EncodingUtil.urlDecode(encryptedString, 'UTF-8');
        if (encryptedString.length() > 255) {
            seaTestRegistration.Encrypted_Registration_Id_1__c = encryptedString.substring(0, 255);
            seaTestRegistration.Encrypted_Registration_Id_2__c = encryptedString.substring(255, encryptedString.length());
        } else {
            seaTestRegistration.Encrypted_Registration_Id_1__c = encryptedString;
        }
        seaTestRegistration.Status__c = 'Registered';
        update seaTestRegistration;

        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsCancelReview;
            pageRef.getParameters().put('eventInfo', seaTestRegistration.Encrypted_Registration_Id_1__c + seaTestRegistration.Encrypted_Registration_Id_2__c);
            Test.setCurrentPage(pageRef);
            String encryptedRegistrationId = SEAShared.createEncryptedCookie('', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id);
            ApexPages.currentPage().getParameters().put('eventInfo', encryptedRegistrationId + 'TAMPER');
            SummitEventsCancelReviewController cancelReviewCtrl = new SummitEventsCancelReviewController();
            cancelReviewCtrl.cancelRegistration();

            Summit_Events_Registration__c statusRegistration = [
                    SELECT Id, Status__c
                    FROM Summit_Events_Registration__c
                    WHERE Id = :seaTestRegistration.Id
            ];
            System.assertEquals(statusRegistration.Status__c, 'Registered');
            System.assertEquals(cancelReviewCtrl.eventNotFound, TRUE);
            Test.stopTest();
        }
    }
}