// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsSubmitController {
    public SummitEventsShared SEShared = new SummitEventsShared();
    public String test { get; set; }
    public SummitEventsShared.SummitEventsInfo evtInfo { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public Summit_Events_Instance__c evtInstance { get; set; }
    public List<Summit_Events_Appointment_Type__c> appts { get; set; }
    public List<Summit_Events_Appointments__c> chosenAppts { get; set; }
    public String chosenFormatted { get; set; }
    public String templateSelected { get; set; }
    public String eventStartDateTimeCrumb { get; set; }
    public String navBreadCrumb { get; set; }

    public SummitEventsSubmitController() {
        test = '';
        templateSelected = SEShared.defaultTemplate;

        //Get cookie or URL string variable
        evtInfo = SEShared.getSummitEventsInfo();
        chosenFormatted = '';
        if (!String.isEmpty(evtInfo.evtId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_Submit_Title__c, Event_Submit_Description__c, Event_Footer__c, Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Submit_Registration__c
                    FROM Summit_Events__c
                    WHERE Id = :evtinfo.evtId
            ][0];
            templateSelected = eventPage.Template__c;

            evtInstance = [
                    SELECT Instance_Title__c, Event__r.Event_Name__c, Start_Date_Time__c, End_Date_Time__c,
                            Instance_Time_Zone__c, Instance_Start_Time__c, Instance_End_Time__c, Instance_Start_Date__c,
                            Instance_End_Date__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :evtinfo.instanceID
                    LIMIT 1
            ];

            if (evtInstance.Start_Date_Time__c != null && evtInstance.End_Date_Time__c != null) {
                eventStartDateTimeCrumb = evtInstance.Start_Date_Time__c.format('MMMM d, YYYY, h:mm a') + ' - ' + evtInstance.End_Date_Time__c.format('h:mm a');
            }

            navBreadCrumb = SEShared.navBreadcrumbBuilder(evtInstance,false);
        }

        if (!String.isBlank(evtinfo.evtRegId)) {
            chosenAppts = [
                    SELECT Id, Appointment_Category__c, Event_Appointment_Type__c, Appointment_Type__c, Description__c, Appointment_Title__c, Chosen_State__C
                    FROM Summit_Events_Appointments__c
                    WHERE Event_Registration__c = :evtinfo.evtRegId
                    AND Chosen_State__c != 'Added but not shown'
                    ORDER BY Appointment_Title__c
            ];
            if (chosenAppts.size() > 0) {
                chosenFormatted += '<ul id="choosenAppointments" class="slds-list_dotted">';
                for (Summit_Events_Appointments__c cappt : chosenAppts) {
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
        return SEShared.checkForEvent();
    }

    public PageReference submitRegistration() {
        PageReference confirmPage = Page.SummitEventsConfirmation;
        return confirmPage;
    }

    public PageReference previousPage() {
        List<Summit_Events_Appointment_Type__c> apptTypes = [
                SELECT Id
                From Summit_Events_Appointment_Type__c
                WHERE Summit_Events__c = :evtInfo.evtId
                AND (Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = null)
        ];
        PageReference lastPage;
        if (apptTypes.size() == 0) {
            //If no options skip that step
            lastPage = Page.SummitEventsRegister;
        } else {
            lastPage = Page.SummitEventsRegisterAppointments;
        }
        return lastPage;
    }
}