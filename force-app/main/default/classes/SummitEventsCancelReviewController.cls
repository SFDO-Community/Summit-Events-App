// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on  5/1/2018.

public with sharing class SummitEventsCancelReviewController {
    public Summit_Events_Registration__c eventRegistration { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public SummitEventsInfo eventInformation { get; set; }
    public List<Summit_Events_Appointments__c> appointments { get; set; }
    public String templateSelected { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean eventNotFound { get; set; }
    public String formattedNavDate { get; set; }
    public String eventParameter { get; set; }
    public Summit_Events_Instance__c eventInstance { get; set; }

    public SummitEventsCancelReviewController() {
        eventParameter = ApexPages.currentPage().getParameters().get('eventInfo');
        eventNotFound = true;
        eventIsClosed = false;
        eventRegistration = new Summit_Events_Registration__c();
        templateSelected = SummitEventsShared.getTemplate('');

        if (!String.isBlank(eventParameter)) {
            String decryptedParameter = SummitEventsShared.decryptString(eventParameter, false);
            if (String.isNotBlank(decryptedParameter)) {
                try {
                    eventInformation = (SummitEventsInfo) JSON.deserialize(decryptedParameter, SummitEventsInfo.class);
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }

                if (String.isNotBlank(eventInformation.registrationId)) {
                    eventRegistration = [
                            SELECT Id, Status__c, Name, Event_Instance__c, Event_Name__c, Event_Instance__r.Instance_Title__c, Event__c
                            FROM Summit_Events_Registration__c
                            WHERE Id = :eventInformation.registrationId
                            WITH SECURITY_ENFORCED
                    ];

                    if (eventRegistration != null) {

                        appointments = [
                                SELECT Id, Appointment_Title__c, Appointment_Category__c, Appointment_Type__c
                                FROM Summit_Events_Appointments__c
                                WHERE Event_Registration__c = :eventParameter
                                WITH SECURITY_ENFORCED
                        ];

                        eventInstance = [
                                SELECT Id, Instance_Title__c, Instance_Start_Date__c, Instance_End_Date__c, Instance_Start_Time__c, Instance_End_Time__c, Instance_Time_Zone__c,
                                        Registration_Close_Date__c, Current_Available_Capacity__c, Active_Status__c, Registration_Close_Time__c
                                FROM Summit_Events_Instance__c W
                                WHERE Id = :eventRegistration.Event_Instance__c
                                WITH SECURITY_ENFORCED
                        ];

                        eventPage = [
                                SELECT Id, Event_Name__c, Event_description__c, Event_Footer__c, Event_Cancel_Review_Title__c, Event_Cancel_Review_Description__c,
                                Event_Cancelled_Notification_Text__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Cancel_Registration__c,
                                Account__r.Name, Audience__c, Filter_Category__c, Event_Sponsor__c, Event_Full_Text__c, Template__c
                                FROM Summit_Events__c
                                WHERE Id = :eventRegistration.Event__c
                                WITH SECURITY_ENFORCED
                        ];

                        templateSelected = SummitEventsShared.getTemplate(eventPage.Template__c);

                        eventIsClosed = SummitEventsShared.isEventClosed(eventInstance);

                        if (eventInstance != null) {
                            formattedNavDate = SummitEventsShared.navBreadcrumbBuilder(eventInstance);
                        }

                        eventNotFound = false;
                    }
                }
            }
        }
    }

    public PageReference cancelRegistration() {
        doCRUD regCrud = new doCRUD();
        if (eventRegistration != null) {
            eventRegistration.Status__c = 'Cancelled';
            eventRegistration = regCrud.updateRegistration(eventRegistration);
        }
        PageReference pg = Page.SummitEventsCancelReview;
        pg.getParameters().put('eventInfo', eventParameter);
        pg.setRedirect(true);
        return pg;
    }

    /**
     * Summit Events is a multi-step, guest user, registration solution so CRUD work needs to be done on records where guest record ownership is lost between steps.
     * The security aspects of guest record updating is achieved by:
     * - Using an encrypted cookie on the client browser to keep track of registration id, event id, instance id, and audience
     * - Dividing each controller class into a "with sharing" logic area and a sub "without sharing" CRUD area for purposeful CRUD
     * - When the encrypted cookie is not available as in the cancel registration link an encrypted string is provided through the URL to not expose the SF ID related to the record
     **/

    private without sharing class doCRUD {

        public Summit_Events_Registration__c updateRegistration(Summit_Events_Registration__c newEvtReg) {
            try {
                update newEvtReg;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
            return newEvtReg;
        }

    }

}