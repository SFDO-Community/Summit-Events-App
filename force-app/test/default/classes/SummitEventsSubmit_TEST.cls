// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsSubmit_TEST {
    @IsTest static void testSubmit() {
        SummitEventsTestSharedDataFactory.createContact('TestFirst1', 'Test', 'TestLast1', 'test1@valleyhill.net', '55418', '(555) 555-5555', '1971-03-22', '2012');
        Summit_Events_Instance__c evtInst = SummitEventsTestSharedDataFactory.createTestEvent('Use Salesforce Duplicate Rule', 'Test Event', '', true, true, '');
        Summit_Events_Registration__c evtReg = SummitEventsTestSharedDataFactory.createEventRegistration(evtInst, 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        Test.startTest();
        PageReference pageRef = Page.SummitEventsSubmit;
        Test.setCurrentPage(pageRef);

        SummitEventsShared SEShared = new SummitEventsShared();
        SEShared.createEncryptedCookie('Transfer', evtInst.Id, evtInst.Event__c, evtReg.Id);

        //ApexPages.currentPage().getParameters().put('instanceID', evtInst.Id);
        SummitEventsSubmitController submitCtrl = new SummitEventsSubmitController();
        submitCtrl.checkEventDetails();
        submitCtrl.previousPage();
        submitCtrl.submitRegistration();
    }
}