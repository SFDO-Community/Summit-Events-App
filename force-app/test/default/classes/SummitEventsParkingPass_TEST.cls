// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsParkingPass_TEST {
    @IsTest static void testParkingPass() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[2], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        Summit_Events_Registration__c seaTestRegistration2 = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst2', 'TestLast2', 'test2@valleyhill.net', '55418', '1971-03-22', '2012', null);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Registrant');
        SummitEventsShared SEAShared = new SummitEventsShared();
        String encryptedString = SEAShared.createEncryptedCookie('', seaTestRegistration.Event_Instance__c, seaTestRegistration.Event__c, seaTestRegistration.Id);
        String encryptedString2 = SEAShared.createEncryptedCookie('', seaTestRegistration2.Event_Instance__c, seaTestRegistration2.Event__c, seaTestRegistration2.Id);
        encryptedString = EncodingUtil.urlDecode(encryptedString, 'UTF-8');
        encryptedString2 = EncodingUtil.urlDecode(encryptedString2, 'UTF-8');
        if (encryptedString.length() > 255) {
            seaTestRegistration.Encrypted_Registration_Id_1__c = encryptedString.substring(0, 255);
            seaTestRegistration.Encrypted_Registration_Id_2__c = encryptedString.substring(255, encryptedString.length());
        } else {
            seaTestRegistration.Encrypted_Registration_Id_1__c = encryptedString;
        }
        if (encryptedString2.length() > 255) {
            seaTestRegistration2.Encrypted_Registration_Id_1__c = encryptedString2.substring(0, 255);
            seaTestRegistration2.Encrypted_Registration_Id_2__c = encryptedString2.substring(255, encryptedString2.length());
        } else {
            seaTestRegistration2.Encrypted_Registration_Id_1__c = encryptedString2;
        }
        seaTestRegistration.Status__c = 'Registered';
        seaTestRegistration.Registrant_Preferred_First_Name__c = 'Frank';
        update seaTestRegistration;
        update seaTestRegistration2;

        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsParkingPass;
            Test.setCurrentPage(pageRef);

            //Valid Parking pass
            ApexPages.currentPage().getParameters().put('eventInfo', encryptedString);
            SummitEventsParkingPassController parkingCtrl = new SummitEventsParkingPassController();
            System.assertEquals(parkingCtrl.warning, '');

            //Not registered parking pass
            ApexPages.currentPage().getParameters().remove('eventInfo');
            ApexPages.currentPage().getParameters().put('eventInfo', encryptedString2);
            parkingCtrl = new SummitEventsParkingPassController();
            System.assertNotEquals(parkingCtrl.warning, '');

            //Registered now with not preferred first name
            seaTestRegistration2.Status__c = 'Registered';
            upsert seaTestRegistration2;
            parkingCtrl = new SummitEventsParkingPassController();
            System.assertEquals(parkingCtrl.warning, '');

            //Tried to pass a bad id through the URL
            ApexPages.currentPage().getParameters().remove('eventInfo');
            ApexPages.currentPage().getParameters().put('eventInfo', encryptedString + 'TAMPER');
            parkingCtrl = new SummitEventsParkingPassController();
            System.assertNotEquals(parkingCtrl.warning, '');

            Test.stopTest();
        }
    }
}