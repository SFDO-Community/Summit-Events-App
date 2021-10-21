// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause License
// license that can be found in the LICENSE file
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsConfirmationController {
    public SummitEventsShared seaShared = new SummitEventsShared();
    public SummitEventsShared.SummitEventsInfo eventInformation { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public Summit_Events_Instance__c eventInstance { get; set; }
    public String templateSelected { get; set; }
    public String formattedNavDate { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean adminOpen { get; set; }

    public SummitEventsConfirmationController() {
        eventIsClosed = false;
        eventInformation = seaShared.getSummitEventsInfo();

        if (!String.isEmpty(eventInformation.eventId)) {
            eventPage = [
                    SELECT Event_Confirmation_Title__c, Event_Name__c, Template__c, Event_Confirmation_Description__c, Event_Footer__c,
                            Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Confirmation_Registration__c, Event_Full_Text__c,
                            Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c,
                            Hand_Raise_Action__c,Event_Confirmation_Show_Add_To_Calendar__c
                    FROM Summit_Events__c
                    WHERE Id = :eventInformation.eventId
                    WITH SECURITY_ENFORCED
            ];

            templateSelected = seaShared.getTemplate(eventPage.Template__c);

            eventInstance = [
                    SELECT Instance_Title__c, Event__r.Event_Name__c, Instance_Time_Zone__c, Instance_Start_Time__c, Instance_End_Time__c,
                            Instance_Start_Date__c, Instance_End_Date__c, Current_Available_Capacity__c, Active_Status__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :eventInformation.instanceId
                    LIMIT 1
            ];

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                eventIsClosed = adminOpen;
            } else {
                eventIsClosed = seaShared.isEventClosed(eventPage, eventInstance);
            }

            formattedNavDate = seaShared.navBreadcrumbBuilder(eventInstance);
        }

    }

    public void checkEventDetails() {
        eventInformation = seaShared.getSummitEventsInfo();

        if (!eventIsClosed) {
            String eventTitle = '';
            if (!String.isBlank(eventInformation.registrationId)) {
                Summit_Events_Registration__c evtReg = [
                        SELECT Id, Status__c, Event_Name__c, Event_Instance_Title__c
                        FROM Summit_Events_Registration__c
                        WHERE Id = :eventInformation.registrationId
                        WITH SECURITY_ENFORCED
                ];

                if (!String.isBlank(evtReg.Event_Instance_Title__c)) {
                    eventTitle = evtReg.Event_Name__c + ' - ' + evtReg.Event_Instance_Title__c ;
                } else {
                    eventTitle = evtReg.Event_Name__c;
                }
                evtReg.Status__c = 'Registered';

                String encryptedString = seaShared.createEncryptedCookie(eventInformation.audience, eventInformation.instanceId, eventInformation.eventId, eventInformation.registrationId);

                if (encryptedString.length() > 255) {
                    evtReg.Encrypted_Registration_Id_1__c = encryptedString.substring(0, 255);
                    evtReg.Encrypted_Registration_Id_2__c = encryptedString.substring(255, encryptedString.length());
                } else {
                    evtReg.Encrypted_Registration_Id_1__c = encryptedString;
                }

                registrationCRUD regCRUD = new registrationCRUD();
                evtReg = regCRUD.updateRegistration(evtReg);

                SummitEventsShared SEAShared = new SummitEventsShared();

                //Remove the registration ID from the cookie so back button will redirect to the correct page.
                SEAShared.createEncryptedCookie(eventInformation.audience, eventInformation.instanceId, eventInformation.eventId, '');
            }
        }
    }

    /**
     * Summit Events is a multi-step, guest user, registration solution so CRUD work needs to be done on records where guest record ownership is lost between steps.
     * The security aspects of guest record updating is achieved by:
     * - Using an encrypted cookie on the client browser to keep track of registration id, event id, instance id, and audience
     * - Dividing each controller class into a "with sharing" logic area and a sub "without sharing" CRUD area for purposeful CRUD
     * - When the encrypted cookie is not available as in the cancel registration link an encrypted string is provided through the URL to not expose the SF ID related to the record
     **/

    private without sharing class registrationCRUD {

        public Summit_Events_Registration__c updateRegistration(Summit_Events_Registration__c newEvtReg) {
            try {
                update newEvtReg;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }
            return newEvtReg;
        }

    }
}