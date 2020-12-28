// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsParkingPass_TEST {
    @IsTest static void testParkingPass() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c testEventRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        testEventRegistration.Status__c = 'Registered';
        update testEventRegistration;
        Test.startTest();
        SummitEventsParkingPassController parkingCtrl = new SummitEventsParkingPassController();
        ApexPages.currentPage().getParameters().put('regId', testEventRegistration.Id);
        parkingCtrl = new SummitEventsParkingPassController();
        upsert testEventRegistration;
        parkingCtrl = new SummitEventsParkingPassController();
        Test.stopTest();
    }
}