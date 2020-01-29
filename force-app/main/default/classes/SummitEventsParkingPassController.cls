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
        Datetime todaysDateTime = SEShared.adjustForCentralTime(Datetime.now());
        DateTime todaysDate = SEShared.adjustForCentralTime(date.newinstance(todaysDateTime.year(), todaysDateTime.month(), todaysDateTime.day()));
        try {
            regId = (Id) regId;
        } Catch (Exception e) {
            validId = false;
        }
        if (validId) {
            Summit_Events_Registration__c visitor = new Summit_Events_Registration__c();
            try {
                visitor = [SELECT Date__c, Contact__r.Name, Contact__r.FirstName, Contact__r.Preferred_First_Name__c, Status__c FROM Summit_Events_Registration__c WHERE id = :regId][0];
            } catch (Exception e) {
                System.Debug(e.getMessage());
            }

            if (todaysDate <= visitor.Date__c && visitor.Status__c != 'Started' && visitor.Status__c != 'Cancelled') {
                couponOut += '<p>NAME:&nbsp; ' + visitor.Contact__r.Name + '</p>';
                couponOut += '<p>DATE VALID:&nbsp; ' + visitor.Date__c.format() + '</p>';
                if (!String.isBlank(visitor.Contact__r.Preferred_First_Name__c)) {
                    firstName = visitor.Contact__r.Preferred_First_Name__c;
                } else {
                    firstName = visitor.Contact__r.FirstName;
                }


            } else {
                warning = '<p>Sorry, this parking permit has expired or invalid. (' + regId + ')</p>';
            }

            
        } else {
            warning = '<p>Sorry, We could not find your parking permit ID. (' + regId + ')</p>';
        }
    }
}