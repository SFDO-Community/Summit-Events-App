// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsParkingPass_TEST {
    @IsTest static void testParkingPass() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c testEventRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[2], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        Summit_Events_Registration__c testEventRegistration2 = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst2', 'TestLast2', 'test2@valleyhill.net', '55418', '1971-03-22', '2012', null);
        testEventRegistration.Status__c = 'Registered';
        testEventRegistration.Registrant_Preferred_First_Name__c = 'Frank';
        update testEventRegistration;
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();

            //Valid Parking pass
            ApexPages.currentPage().getParameters().put('regId', testEventRegistration.Id);
            SummitEventsParkingPassController parkingCtrl = new SummitEventsParkingPassController();
            System.assertEquals(parkingCtrl.warning, '');

            //Not registered parking pass
            ApexPages.currentPage().getParameters().remove('regId');
            ApexPages.currentPage().getParameters().put('regId', testEventRegistration2.Id);
            parkingCtrl = new SummitEventsParkingPassController();
            System.assertNotEquals(parkingCtrl.warning, '');

            //Registered now with not preferred first name
            testEventRegistration2.Status__c = 'Registered';
            upsert testEventRegistration2;
            parkingCtrl = new SummitEventsParkingPassController();
            System.assertEquals(parkingCtrl.warning, '');

            //Tried to pass a bad id through the URL
            ApexPages.currentPage().getParameters().remove('regId');
            ApexPages.currentPage().getParameters().put('regId', 'BADID');
            parkingCtrl = new SummitEventsParkingPassController();
            System.assertNotEquals(parkingCtrl.warning, '');

            Test.stopTest();
        }
    }
}