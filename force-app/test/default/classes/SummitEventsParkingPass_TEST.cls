// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsParkingPass_TEST {
    @IsTest static void testParkingPass() {
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Test Event', '', true, true, '');
        Summit_Events_Registration__c evtReg = SummitEventsTestSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        evtReg.Status__c = 'Registered';
        update evtReg;
        Test.startTest();
        SummitEventsParkingPassController parkingCtrl = new SummitEventsParkingPassController();
        ApexPages.currentPage().getParameters().put('regId', evtReg.Id);
        parkingCtrl = new SummitEventsParkingPassController();
        upsert evtReg;
        parkingCtrl = new SummitEventsParkingPassController();
        Test.stopTest();
    }
}