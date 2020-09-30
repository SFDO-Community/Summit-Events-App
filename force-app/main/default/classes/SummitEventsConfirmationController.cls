// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsConfirmationController {
    public SummitEventsShared SEShared = new SummitEventsShared();
    public SummitEventsShared.SummitEventsInfo evtInfo { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public Summit_Events_Instance__c evtInstance { get; set; }
    public String templateSelected { get; set; }
    public String navBreadCrumb { get; set; }
    public boolean eventIsClosed { get; set; }
    public Boolean adminOpen { get; set; }

    public SummitEventsConfirmationController() {
        eventIsClosed = false;
        evtInfo = SEShared.getSummitEventsInfo();

        if (!String.isEmpty(evtInfo.evtId)) {
            eventPage = [
                    SELECT Event_Confirmation_Title__c, Event_Name__c, Template__c, Event_Confirmation_Description__c, Event_Footer__c,
                            Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Confirmation_Registration__c, Event_Full_Text__c,
                            Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c,
                            Hand_Raise_Action__c
                    FROM Summit_Events__c
                    WHERE Id = :evtinfo.evtId
                    LIMIT 1
            ];

            templateSelected = SEShared.getTemplate(eventPage.Template__c);

            evtInstance = [
                    SELECT Instance_Title__c, Event__r.Event_Name__c, Instance_Time_Zone__c, Instance_Start_Time__c, Instance_End_Time__c,
                            Instance_Start_Date__c, Instance_End_Date__c, Current_Available_Capacity__c, Active_Status__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :evtinfo.instanceID
                    LIMIT 1
            ];

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                eventIsClosed = adminOpen;
            } else {
                eventIsClosed = SEShared.isEventClosed(eventPage, evtInstance);
            }

            navBreadCrumb = SEShared.navBreadcrumbBuilder(evtInstance, false);

            System.Debug(navBreadCrumb);
        }

    }

    public PageReference checkEventDetails() {
        //PageReference resultPageRef =  SEShared.checkForEvent();
        evtInfo = SEShared.getSummitEventsInfo();

        System.debug('EVENT LOAD Cookie INFO: ' + JSON.serializePretty(evtInfo));
        String eventTitle = '';
        if (!String.isBlank(evtInfo.evtRegId)) {
            Summit_Events_Registration__c evtReg = [
                    SELECT Id, Status__c, Contact__c, Event_Name__c, Event_Instance_Title__c, Event_Instance__c,
                            Registrant_First_Name__c, Registrant_Last_Name__c,Registrant_Gender__c,
                            Event_Instance_Date__c, Registrant_Street_1__c, Registrant_Street_2__c, Registrant_City__c,
                            Registrant_State__c, Registrant_Zip__c, Registrant_Email__c, Registrant_High_School_Grad_Year__c,
                            Registrant_Parent_First_Name__c, Registrant_Parent_Last_Name__c, Registrant_Parent_Email__c,
                            Registrant_Program_Interest__c
                    FROM Summit_Events_Registration__c
                    WHERE id = :evtInfo.evtRegId
                    LIMIT 1
            ];

            System.debug('EVENT ON LOAD INFO: ' + JSON.serializePretty(evtReg));

            if (!String.isBlank(evtReg.Event_Instance_Title__c)) {
                eventTitle = evtReg.Event_Name__c + ' - ' + evtReg.Event_Instance_Title__c ;
            } else {
                eventTitle = evtReg.Event_Name__c;
            }
            evtReg.Status__c = 'Registered';


            registrationCRUD regCRUD = new registrationCRUD();
            evtReg = regCRUD.updateRegistration(evtReg);

            //Remove the registration ID from the cookie so back button will redirect to the correct page.
            SEShared.createEncryptedCookie('{"audience":"' + evtInfo.audience + '","instanceID":"' + evtInfo.instanceID + '","evtRegId":"","evtId":"' + evtInfo.evtId + '"}', 'SummitEvents');
        }
        return null;
    }

    private without sharing class registrationCRUD {

        public Summit_Events_Registration__c updateRegistration(Summit_Events_Registration__c newEvtReg) {
            try {
                upsert newEvtReg;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                ApexPages.addMessage(myMsg);
            }
            return newEvtReg;
        }

    }
}