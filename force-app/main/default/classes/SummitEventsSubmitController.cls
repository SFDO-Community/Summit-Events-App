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
    public List<Summit_Events_Appointment_Type__c> appointments { get; set; }
    public List<Summit_Events_Appointments__c> chosenAppointments { get; set; }
    public String chosenFormatted { get; set; }
    public String templateSelected { get; set; }
    public String navBreadCrumb { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean adminOpen { get; set; }

    public SummitEventsSubmitController() {
        eventIsClosed = false;
        test = '';

        //Get cookie or URL string variable
        evtInfo = SEShared.getSummitEventsInfo();
        chosenFormatted = '';
        if (!String.isEmpty(evtInfo.eventId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_Submit_Title__c, Event_Submit_Description__c, Event_Footer__c, Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c,
                            Tracking_Submit_Registration__c, Event_Full_Text__c, Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c
                    FROM Summit_Events__c
                    WHERE Id = :evtInfo.eventId
            ][0];

            templateSelected = SEShared.getTemplate(eventPage.Template__c);

            evtInstance = [
                    SELECT Instance_Title__c, Event__r.Event_Name__c, Instance_Time_Zone__c,
                            Instance_Start_Time__c, Instance_End_Time__c, Instance_Start_Date__c,
                            Instance_End_Date__c, Current_Available_Capacity__c, Active_Status__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :evtInfo.instanceId
                    LIMIT 1
            ];

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                eventIsClosed = adminOpen;
            } else {
                eventIsClosed = SEShared.isEventClosed(eventPage, evtInstance);
            }

            navBreadCrumb = SEShared.navBreadcrumbBuilder(evtInstance, false);
        }

        if (!String.isBlank(evtInfo.registrationId)) {
            chosenAppointments = [
                    SELECT Id, Appointment_Category__c, Event_Appointment_Type__c, Appointment_Type__c, Description__c, Appointment_Title__c, Chosen_State__c
                    FROM Summit_Events_Appointments__c
                    WHERE Event_Registration__c = :evtInfo.registrationId
                    AND Chosen_State__c != 'Added but not shown'
                    ORDER BY Appointment_Title__c
            ];
            if (chosenAppointments.size() > 0) {
                chosenFormatted += '<ul id="chosenAppointments" class="slds-list_dotted">';
                for (Summit_Events_Appointments__c appointment : chosenAppointments) {
                    chosenFormatted += '<li>';
                    chosenFormatted += appointment.Appointment_Title__c;
                    if (!String.isEmpty(appointment.Appointment_Type__c)) {
                        chosenFormatted += '<br/><em>' + appointment.Appointment_Type__c + '</em>';
                    } else if (!String.isEmpty(appointment.Description__c)) {
                        chosenFormatted += '<br/><em>' + appointment.Description__c + '</em>';
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
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
            confirmPage.setRedirect(true);
            confirmPage.getParameters().put('adminopen', ApexPages.currentPage().getParameters().get('adminopen'));
        }
        return confirmPage;
    }

    public PageReference previousPage() {
        List<Summit_Events_Appointment_Type__c> appointmentTypes = null;

        appointmentTypes = [
                SELECT Id
                FROM Summit_Events_Appointment_Type__c
                WHERE Summit_Events__c = :evtInfo.eventId
                AND (
                        Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c
                        OR Restrict_To_Instance_Title__r.Instance_Title__c = NULL)
        ];


        PageReference lastPage;
        if (appointmentTypes.size() == 0) {
            //If no options skip that step
            lastPage = Page.SummitEventsRegister;
        } else {
            lastPage = Page.SummitEventsRegisterAppointments;
        }

        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
            lastPage.setRedirect(true);
            lastPage.getParameters().put('adminopen', ApexPages.currentPage().getParameters().get('adminopen'));
        }

        return lastPage;
    }
}