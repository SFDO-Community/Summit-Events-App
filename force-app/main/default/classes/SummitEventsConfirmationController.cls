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
    public Map <String, String> feesByIndex { get; set; }
    public List<Summit_Events_Fee__c> eventFees { get; set; }
    public Double totalPaymentAmount { get; set; }
    public String totalPaymentAmountFormatted { get; set; }
    public Double existingPaymentAmount { get; set; }
    public Double eventOnlyPaymentAmount { get; set; }
    public String eventOnlyPaymentAmountFormatted { get; set; }
    public Boolean hasFees { get; set; }
    public Boolean hasMessages { get; set; }
    public Boolean paymentReceived { get; set; }

    public SummitEventsConfirmationController() {
        eventIsClosed = false;
        eventInformation = seaShared.getSummitEventsInfo();

        if (!String.isEmpty(eventInformation.eventId)) {
            eventPage = [
                    SELECT Event_Confirmation_Title__c, Event_Name__c, Template__c, Event_Confirmation_Description__c, Event_Footer__c,
                            Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Confirmation_Registration__c, Event_Full_Text__c,
                            Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c,
                            Hand_Raise_Action__c
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

            gatherPaymentInformation();
        }

    }

    public PageReference checkEventDetails() {

        PageReference pageRef = null;
        eventInformation = seaShared.getSummitEventsInfo();

        // Default to submit page, submit will redirect to beginning if no reg id is present. Prevents pre-filled forms in one step registrations.
        ApexPages.currentPage().getHeaders().put('referer', Page.SummitEventsSubmit.getUrl());

        if (!eventIsClosed) {
            String eventTitle = '';
            if (!String.isBlank(eventInformation.registrationId)) {
                Summit_Events_Registration__c eventReg = [
                        SELECT Id, Status__c, Event_Name__c, Event_Instance_Title__c, Event__r.Payment_Gateway__c
                        FROM Summit_Events_Registration__c
                        WHERE Id = :eventInformation.registrationId
                        WITH SECURITY_ENFORCED
                ];

                if (String.isNotBlank(eventReg.Event__r.Payment_Gateway__c) && eventReg.Event__r.Payment_Gateway__c != 'None') {
                    pageRef = gatherPaymentInformation();
                }

                if (pageRef == null) {
                    if (!String.isBlank(eventReg.Event_Instance_Title__c)) {
                        eventTitle = eventReg.Event_Name__c + ' - ' + eventReg.Event_Instance_Title__c ;
                    } else {
                        eventTitle = eventReg.Event_Name__c;
                    }
                    eventReg.Status__c = 'Registered';

                    String encryptedString = seaShared.createEncryptedCookie(eventInformation.audience, eventInformation.instanceId, eventInformation.eventId, eventInformation.registrationId);

                    if (encryptedString.length() > 255) {
                        eventReg.Encrypted_Registration_Id_1__c = encryptedString.substring(0, 255);
                        eventReg.Encrypted_Registration_Id_2__c = encryptedString.substring(255, encryptedString.length());
                    } else {
                        eventReg.Encrypted_Registration_Id_1__c = encryptedString;
                    }

                    registrationCRUD regCRUD = new registrationCRUD();
                    eventReg = regCRUD.updateRegistration(eventReg);

                    SummitEventsShared SEAShared = new SummitEventsShared();

                    //Remove the registration ID from the cookie so back button will redirect to the correct page.
                    SEAShared.createEncryptedCookie(eventInformation.audience, eventInformation.instanceId, eventInformation.eventId, '');

                }

            }
        }
        return pageRef;
    }

    public PageReference gatherPaymentInformation() {
        PageReference pageRef = null;

        /* Check if there is a fee and a gateway set */
        /** Collect Fees **/
        eventFees = [
                SELECT Name, Event_Fee__c, Event_Fee_Allocation__c, Description__c, Event_Fee_Type__c, Summit_Events__c, Event_Appointment_Type__c,
                        Event_Appointment_Type__r.Title__c, Event_Fee_Allocation__r.Name
                FROM Summit_Events_Fee__c
                WHERE Event_Registration__c = :eventInformation.registrationId
                WITH SECURITY_ENFORCED
        ];

        Integer payments = [
                SELECT COUNT()
                FROM Summit_Events_Payment__c
                WHERE Event_Registration__c = :eventInformation.registrationId
        ];

        String errorMessage = '';

        if (payments == 1) {
            paymentReceived = true;
            //Payment received. Get payment fees to display.
            feesByIndex = new Map<String, String>();
            eventOnlyPaymentAmount = 0;
            totalPaymentAmount = 0;
            for (Summit_Events_Fee__c fee : eventFees) {
                if (fee.Event_Fee__c != null && fee.Event_Fee__c > 0) {
                    totalPaymentAmount += fee.Event_Fee__c;
                }
                if (fee.Event_Fee_Type__c == 'Event' || fee.Event_Fee_Type__c == 'Event Additional') {
                    eventOnlyPaymentAmount += fee.Event_Fee__c;
                }

            }
            if (existingPaymentAmount > 0) {
                totalPaymentAmount = totalPaymentAmount - existingPaymentAmount;
            }
            eventOnlyPaymentAmountFormatted = prettyCurrencyString(eventOnlyPaymentAmount);
            totalPaymentAmountFormatted = prettyCurrencyString(totalPaymentAmount);
            if (totalPaymentAmount > 0) {
                hasFees = true;
            }
        } else if (payments == 0) {
            errorMessage = 'Payment was not received. Please try again.';
        } else {
            pageRef = Page.SummitEventsSubmit;
            errorMessage = 'Multiple payments were received. Please contact event .';
        }
        if (String.isNotBlank(errorMessage)) {
            pageRef = Page.SummitEventsSubmit;
            pageRef.getParameters().put('error', EncodingUtil.urlEncode(errorMessage, 'UTF-8'));
            pageRef.setRedirect(true);
        }
        return pageRef;
    }

    public String prettyCurrencyString(Decimal numberIn) {
        String numberOut = '';
        List<String> args = new String[]{
                '0', 'number', '###,###,##0.00'
        };
        numberOut = '$' + String.format(numberIn.format(), args);
        return numberOut;
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