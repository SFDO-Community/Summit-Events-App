// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsParkingPassController {
    public String couponOut { get; set; }
    public String firstName { get; set; }
    public String warning { get; set; }
    private SummitEventsShared SEShared = new SummitEventsShared();


    public SummitEventsParkingPassController() {
        warning = '';
        couponOut = '';
        Boolean validId = true;
        Id registrationId = null;
        String regId = ApexPages.currentPage().getParameters().get('regId');
        Datetime todayDateTime = SEShared.adjustForCentralTime(Datetime.now());
        DateTime todayDate = SEShared.adjustForCentralTime(date.newinstance(todayDateTime.year(), todayDateTime.month(), todayDateTime.day()));
        try {
            regId = (Id) regId;
        } Catch (Exception e) {
            validId = false;
        }
        if (validId) {
            Summit_Events_Registration__c visitor = new Summit_Events_Registration__c();
            try {
                visitor = [SELECT Event_Instance_Start_Date__c, Event_Instance_Start_Date_Text__c, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Preferred_First_Name__c, Status__c FROM Summit_Events_Registration__c WHERE id = :regId][0];
            } catch (Exception e) {
                System.Debug(e.getMessage());
            }

            if (todayDate <= visitor.Event_Instance_Start_Date__c && visitor.Status__c != 'Started' && visitor.Status__c != 'Cancelled') {
                if (!String.isBlank(visitor.Registrant_Preferred_First_Name__c)) {
                    firstName = visitor.Registrant_Preferred_First_Name__c;
                } else {
                    firstName = visitor.Registrant_First_Name__c;
                }
                couponOut += '<p>NAME:&nbsp; ' + firstName + ' ' + visitor.Registrant_Last_Name__c + '</p>';
                couponOut += '<p>DATE VALID:&nbsp; ' + visitor.Event_Instance_Start_Date_Text__c + '</p>';
            } else {
                warning = '<p>Sorry, this parking permit has expired or invalid. (' + regId + ')</p>';
            }


        } else {
            warning = '<p>Sorry, We could not find your parking permit ID. (' + regId + ')</p>';
        }
    }
}