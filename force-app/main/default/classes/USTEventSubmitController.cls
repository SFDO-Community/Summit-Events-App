// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class USTEventSubmitController {
    public USTEventShared USTShared = new USTEventShared();
    public String test { get; set; }
    public USTEventShared.USTEventInfo evtInfo { get; set; }
    public UST_Event__C eventPage { get; set; }
    public UST_Event_Instance__c evtInstance { get; set; }
    public List<UST_Event_Appointment_Type__c> appts { get; set; }
    public List<UST_Event_Appointments__c> chosenAppts { get; set; }
    public String chosenFormatted { get; set; }
    public String templateSelected { get; set; }
    public String eventStartDateTimeCrumb {get;set;}

    public USTEventSubmitController() {
        test = '';
        templateSelected = USTShared.defaultTemplate;

        //Get cookie or URL string variable
        evtInfo = USTShared.getUSTEventInfo();
        chosenFormatted = '';
        if (!String.isEmpty(evtInfo.evtId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_Submit_Title__c, Event_Submit_Description__c, Event_Footer__c, Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Submit_Registration__c
                    FROM UST_Event__c
                    WHERE Id = :evtinfo.evtId][0];
            templateSelected = eventPage.Template__c;

            evtInstance = [SELECT Instance_Title__c, Start_Date_Time__c, End_Date_Time__c FROM UST_Event_Instance__c WHERE Id = :evtinfo.instanceID LIMIT 1];

            if(evtInstance.Start_Date_Time__c != null && evtInstance.End_Date_Time__c != null ) {
                eventStartDateTimeCrumb = evtInstance.Start_Date_Time__c.format('MMMM d, YYYY, h:mm a') + ' - ' + evtInstance.End_Date_Time__c.format('h:mm a');
            }
        }


        if (!String.isBlank(evtinfo.evtRegId)) {
            chosenAppts = [
                    SELECT Id, Appointment_Category__c, Event_Appointment_Type__c, Appointment_Type__c, Description__c, Appointment_Title__c, Chosen_State__C
                    FROM UST_Event_Appointments__c
                    WHERE Event_Registration__c = :evtinfo.evtRegId
                    AND Chosen_State__c != 'Added but not shown'
                    ORDER BY Appointment_Title__c
            ];
            if (chosenAppts.size() > 0) {
                chosenFormatted += '<ul id="choosenAppointments">';
                for (UST_Event_appointments__c cappt : chosenAppts) {
                    chosenFormatted += '<li>';
                    chosenFormatted += cappt.Appointment_Title__c;
                    if (!String.isEmpty(cappt.Appointment_Type__c)) {
                        chosenFormatted += '<br/><em>' + cappt.Appointment_Type__c + '</em>';
                    } else if (!String.isEmpty(cappt.Description__c)) {
                        chosenFormatted += '<br/><em>' + cappt.Description__c + '</em>';
                    }
                    chosenFormatted += '</li>';
                }
                chosenFormatted += '</ul>';
            }
        }

    }

    public PageReference checkEventDetails() {
        return USTShared.checkForEvent();
    }

    public PageReference submitRegistration() {
        PageReference confirmPage = Page.USTEventConfirmation;
        return confirmPage;
    }

    public PageReference previousPage() {
        List<UST_Event_Appointment_Type__c> apptTypes = [
                SELECT Id
                From UST_Event_Appointment_Type__c
                WHERE UST_Event__c = :evtInfo.evtId
                AND (Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = null)
        ];
        PageReference lastPage;
        if (apptTypes.size() == 0) {
            //If no options skip that step
            lastPage = Page.USTEventRegister;
        } else {
            lastPage = Page.USTEventRegistrationOptions;
        }
        return lastPage;
    }
}