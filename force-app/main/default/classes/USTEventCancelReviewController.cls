// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on  5/1/2018.

public with sharing class USTEventCancelReviewController {
    public USTEventShared USTShared = new USTEventShared();
    public UST_Event_Registration__c evt {get;set;}
    public List<UST_Event_Appointments__c> appt {get;set;}
    public String templateSelected { get; set; }
    public Boolean eventOver {get;set;}
    public Boolean eventNotFound {get;set;}
    public String eventStartDateTimeCrumb {get;set;}

    public USTEventCancelReviewController() {
        templateSelected =  USTShared.defaultTemplate;
        String regId = ApexPages.currentPage().getParameters().get('regId');
        eventNotFound = false;
        eventOver = false;

        if (!String.isBlank(regId)) {
            List<UST_Event_Registration__c> evtList = [SELECT id, Status__c, Name, Event__r.Name, Event__r.Event_Name__c, Event__r.Event_description__c,
                    Event__r.Event_Footer__c, Event__r.Event_Cancel_Review_Title__c, Event_Name__c, Event_Instance_Title__c,
                    Event__r.Event_Cancel_Review_Description__c, Event__r.Event_Cancelled_Notification_Text__c,
                    Event__r.Template__c, Event__r.Event_Home_Link_Title__c, Event__r.Event_Home_Link_URL__c, Event_Instance__r.Instance_Title__c,
                    Event_Instance__r.Start_Date_Time__c, Event_Instance__r.End_Date_Time__c, Event__r.Tracking_Cancel_Registration__c
            FROM UST_Event_Registration__c WHERE id = :regId];


            if (evtList.size() > 0) {
                evt = evtList[0];
                if(evt.Event_Instance__r.Start_Date_Time__c != null && evt.Event_Instance__r.End_Date_Time__c != null ) {
                    eventStartDateTimeCrumb = evt.Event_Instance__r.Start_Date_Time__c.format('MMMM d, YYYY, h:mm a') + ' - ' + evt.Event_Instance__r.End_Date_Time__c.format('h:mm a');
                }
                templateSelected = evt.Event__r.Template__c;
                appt = [SELECT Id, Appointment_Title__c, Appointment_Category__c, Appointment_Type__c FROM UST_Event_Appointments__c WHERE Event_Registration__c = :regId];
                if (evt.Event_Instance__r.End_Date_Time__c < UStShared.adjustForCenteralTime(Datetime.now())) {
                    eventOver = true;
                }
            } else {
                eventNotFound = true;
            }

        } else {
            eventNotFound = true;
        }

    }

    public PageReference cancelRegistration() {
        registrationCRUD regCrud = new registrationCRUD();
        if (evt != null) {
            evt.Status__c = 'Cancelled';
            evt = regCrud.updateRegistration(evt);
        }
        pageReference pg = new pageReference(ApexPages.currentPage().getURL());
        pg.getParameters().put('regid',evt.id);
        pg.setRedirect(TRUE);
        return pg;
    }

    private without sharing class registrationCRUD {

        public UST_Event_Registration__c updateRegistration(UST_Event_Registration__c newEvtReg) {
            try {
                upsert newEvtReg;
            } catch (Exception ex) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                ApexPages.addMessage(myMsg);
            }
            return newEvtReg;
        }

    }

}