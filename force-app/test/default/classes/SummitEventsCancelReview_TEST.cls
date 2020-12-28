// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsCancelReview_TEST {
    @IsTest static void testRegCancel() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c evtReg = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);

        Test.startTest();
        PageReference pageRef = Page.SummitEventsCancelReview;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('regId', evtReg.Id);
        SummitEventsCancelReviewController cancelReviewCtrl = new SummitEventsCancelReviewController();
        cancelReviewCtrl.cancelRegistration();
        Test.stopTest();
    }
}