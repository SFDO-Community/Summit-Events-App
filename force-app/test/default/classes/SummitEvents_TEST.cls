// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEvents_TEST {
    @IsTest
    static void testBehavior() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Test.startTest();
        PageReference pageRef = Page.SummitEvents;
        pageRef.getParameters().put('adminopen', 'true');
        Test.setCurrentPage(pageRef);
        SummitEventsController submitCtrl = new SummitEventsController();
        Test.stopTest();
    }
}