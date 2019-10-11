// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 6/19/2018.

@isTest
public with sharing class USTRestAdmissions_TEST {
/*    @testSetup static void insertCertainBaselineDataForTestsIfNotPresent() {
        Util.insertCertainBaselineDataForTestsIfNotPresent();
    }*/

    static testMethod void TestUSTRestAdmissions() {
        //Get majors
/*        EnrollmentrxRx__Program_Offered__c prog = New EnrollmentrxRx__Program_Offered__c(Name = 'Undeclared BA');
        insert prog;

        Major__c maj = new Major__c(Major_code__c = 'TEST', Major_Display_Name__c = 'Test Display', Program_offered__c = prog.Id, Status__c = 'Active', Display_on_Program_Finder__c = true);
        insert maj;

        Activities__c activ = new Activities__c(Club_type__c = 'Clubs and Organizations', Club_Description__c = 'Test', Display_on_Portal__c = 'Yes');
        insert activ;

        City__c cityList = new City__c(Name = 'Minneapolis', State_Code__c = 'mn');
        insert cityList;

        //school test data
        EnrollmentrxRx__High_School__c hs = new EnrollmentrxRx__High_School__c(Name = 'TEST', EnrollmentrxRx__CEEB_Code__c = '000', EnrollmentrxRx__High_School_State__c = 'mn', EnrollmentrxRx__High_School_City__c = 'minneapolis');
        Id hsRecTypeID = Schema.SObjectType.EnrollmentrxRx__High_School__c.getRecordTypeInfosByName().get('High School').getRecordTypeId();
        hs.RecordTypeId = hsRecTypeID;
        insert hs;

        EnrollmentrxRx__School__c gs = new EnrollmentrxRx__School__c(Name = 'TEST', Active_Display_on_Portal__c = true, Display_Order__c = 1);
        insert gs;

        EnrollmentrxRx__Program_Offered__c gspo = new EnrollmentrxRx__Program_Offered__c(Program_Code__c = 'TEST', Name = 'TEST', Status__c = 'Active', School__c = gs.Id);
        insert gspo;*/

        Test.startTest();
        getMaps('', '', '', '', '');
        getMaps('highschool', '', '', '', '');
        getMaps('ugmajors', '', '', '', '');
        getMaps('ugactivities', '', '', '', '');
        getMaps('ugclubsports', '', '', '', '');
        getMaps('ugvarsitysports', '', '', '', '');
        getMaps('ugmusic', '', '', '', '');
        getMaps('states', '', '', '', '');
        getMaps('countries', '', '', '', '');
        getMaps('cities', 'mn', '', '', '');
        getMaps('college', 'mn', '', '', '');
        getMaps('college', 'mn', 'minneapolis', '', '');
        getMaps('highschool', 'mn', 'minneapolis', '', '');
        getMaps('college', '', '', 'Beth', '');
        getMaps('gradschools', '', '', '', '');
/*        getMaps('gradprograms', '', '', '', gs.Id);*/
        getMaps('areaofinterest','','','','');
        getMaps('degree','','','','');
        getMaps('learningstyle','','','','');
        getMaps('programfinder','','','','');
        getMaps('programfinder','','','College','');
        Test.stopTest();
    }

    private static void getMaps(String type, String state, String city, String filter, String schoolID) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ustadmissionsrest';
        req.params.put('type', type);
        req.params.put('state', state);
        req.params.put('city', city);
        req.params.put('filter', filter);
        req.params.put('schoolid', schoolID);
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        USTRestAdmissions.getUstAdmissionsRest();
    }
}