// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause License
// license that can be found in the LICENSE file
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsConfirmationController {
    public SummitEventsInfo eventInformation { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public Summit_Events_Instance__c eventInstance { get; set; }
    public String templateSelected { get; set; }
    public String formattedNavDate { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Summit_Events_Registration__c eventRegistration { get; set; }
    public List<Summit_Events_Fee__c> eventFees { get; set; }
    public Double totalPaymentAmount { get; set; }
    public Double existingPaymentAmount { get; set; }
    public Double eventOnlyPaymentAmount { get; set; }
    public Boolean paymentReceived { get; set; }

    private class questionData {
        String guestId { get; set; }
        List<Question> questions { get; set; }
    }

    private class Question {
        String id { get; set; }
        String value { get; set; }
        String question { get; set; }
    }

    public SummitEventsConfirmationController() {
        eventIsClosed = false;
        eventInformation = SummitEventsShared.getSummitEventsInfo();
        if (!String.isEmpty(eventInformation.eventId)) {
            eventPage = SummitEventsReadShared.getEventById(eventInformation.eventId);

            if (eventPage != null) {

                templateSelected = SummitEventsShared.getTemplate(eventPage.Template__c);

                if (String.isNotBlank(eventInformation.instanceId)) {
                    eventInstance = SummitEventsReadShared.getInstanceById(eventInformation.instanceId);
                    eventIsClosed = SummitEventsShared.isEventClosed(eventInstance, eventPage.Event_Status__c);
                    formattedNavDate = SummitEventsShared.navBreadcrumbBuilder(eventInstance);
                }

                if (String.isNotBlank(eventInformation.registrationId)) {
                    eventRegistration = SummitEventsReadShared.getRegistrationById(eventInformation.registrationId);
                }

                gatherPaymentInformation();

            }
        }
    }

    public PageReference checkEventDetails() {

        PageReference pageRef = null;
        eventInformation = SummitEventsShared.getSummitEventsInfo();
        Boolean eventRegistrationSuccess = true;

        //Make sure the event has not expired
        eventIsClosed = SummitEventsShared.isEventClosed(eventInstance, eventPage.Event_Status__c);

        // Default to submit page, submit will redirect to beginning if no reg id is present. Prevents pre-filled forms in one step registrations.
        ApexPages.currentPage().getHeaders().put('referer', Page.SummitEventsSubmit.getUrl());

        if (!eventIsClosed && !eventInformation.valid.equalsIgnoreCase('false')) {
            if (String.isNotBlank(eventInformation.registrationId)) {

                Summit_Events_Registration__c eventRegistration = SummitEventsReadShared.getRegistrationById(eventInformation.registrationId);

                //Make sure there is returned registration information
                if (eventRegistration != null) {

                    registrationCRUD regCRUD = new registrationCRUD();

                    //Hosted Guests turn into registrations here if Guest_JSON__c is present in data
                    if (String.isNotBlank(eventRegistration.Guest_JSON__c)) {

                        List<Summit_Events_Registration__c> guestRegistrations = new List<Summit_Events_Registration__c>();

                        //Get all questions defined for the event that are for guests
                        List<String> registrantTypes = new List<String>{
                                'Guest', 'Registrant and Guest'
                        };
                        Map<Id, Summit_Events_Question__c> availableQuestions = SummitEventsReadShared.getAdditionalQuestionsByEventId(eventInformation.eventId, registrantTypes);

                        List<questionData> guestAnswers = (List<questionData>) JSON.deserialize(eventRegistration.Guest_JSON__c, List<questionData>.class);

                        for (Integer xx = 0; xx < guestAnswers.size(); xx++) {
                            Summit_Events_Registration__c guestRegistration = new Summit_Events_Registration__c();
                            SObjectType seaObject = Summit_Events_Registration__c.getSObjectType();
                            DescribeSObjectResult seaObjectResults = seaObject.getDescribe();
                            for (Question q : guestAnswers[xx].questions) {
                                Id questionId = null;
                                try {
                                    questionId = SummitEventsShared.decryptString(q.id, true);
                                } catch (Exception e) {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Invalid question Id detected.'));
                                }

                                if (questionId != null) {
                                    Summit_Events_Question__c questionParameters = availableQuestions.get(questionId);
                                    String mapToField = questionParameters.Map_to_Field__c;
                                    String questionLabel = questionParameters.Question_Label__c;
                                    if (String.isNotBlank(mapToField)) {
                                        mapToField = String.escapeSingleQuotes(mapToField).escapeHtml4();
                                        Boolean fieldExists = true;
                                        Object nextField;

                                        try {
                                            nextField = Schema.SObjectType.Summit_Events_Registration__c.fields.getMap().get(mapToField).getDescribe();
                                        } catch (Exception e) {
                                            fieldExists = false;
                                        }

                                        if (fieldExists && seaObjectResults.isAccessible() &&
                                                seaObjectResults.fields.getMap().get(mapToField).getDescribe().isAccessible() &&
                                                seaObjectResults.fields.getMap().get(mapToField).getDescribe().isCreateable()) {
                                            Integer inputLength = seaObjectResults.fields.getMap().get(mapToField).getDescribe().length;
                                            String valueIn = q.value.trim();
                                            if (String.isNotBlank(valueIn)) {
                                                String fieldType = String.valueOf(seaObjectResults.fields.getMap().get(mapToField).getDescribe().getType()).toLowerCase();
                                                try {
                                                    switch on fieldType {
                                                        when 'date' {
                                                            guestRegistration.put(mapToField, Date.valueOf(valueIn));
                                                        }
                                                        when 'datetime' {
                                                            Date incomingDate = Date.valueOf(valueIn);
                                                            Datetime dateAndTime = Datetime.newInstance(incomingDate.year(), incomingDate.month(), incomingDate.day(), 0, 0, 0);
                                                            guestRegistration.put(mapToField, dateAndTime);
                                                        }
                                                        when 'integer' {
                                                            guestRegistration.put(mapToField, Integer.valueOf(valueIn));
                                                        }
                                                        when 'double' {
                                                            guestRegistration.put(mapToField, Decimal.valueOf(valueIn));
                                                        }
                                                        when else {
                                                            switch on fieldType {
                                                                when 'email' {
                                                                    inputLength = 80;
                                                                }
                                                                when 'phone' {
                                                                    inputLength = 40;
                                                                }
                                                            }
                                                            if (valueIn.length() > inputLength) {
                                                                guestRegistration.put(mapToField, valueIn.abbreviate(inputLength));
                                                            } else {
                                                                guestRegistration.put(mapToField, valueIn);
                                                            }
                                                        }
                                                    }
                                                } catch (Exception e) {
                                                    //eventRegistrationSuccess = false;
                                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Hosted Record: Could not covert response (' + fieldType + ') on question "' + questionLabel + '"'));
                                                }
                                            }
                                        } else {
                                            //eventRegistrationSuccess = false;
                                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Hosted Record: Insufficient Access to field for question: ' + questionLabel));
                                        }
                                    }
                                }
                            }

                            if (guestRegistration != null) {
                                guestRegistration.Event_Instance__c = eventInformation.instanceId;
                                guestRegistration.Event__c = eventInformation.eventId;
                                guestRegistration.Event_Instance_Date_Time_Formatted__c = eventRegistration.Event_Instance_Date_Time_Formatted__c;
                                guestRegistration.Guest_Host_Status__c = 'Hosted registrant';
                                guestRegistration.Status__c = 'Registered';
                                //Get original registration id for host
                                guestRegistration.Guest_Host__c = eventInformation.registrationId;
                                guestRegistrations.add(guestRegistration);
                            }
                        }

                        if (guestRegistrations.size() > 0 && eventRegistrationSuccess) {
                            eventRegistrationSuccess = regCRUD.addGuestRegistration(guestRegistrations);
                            //TODO: Ask original registrant if they are attending the event and enter value below.
                            eventRegistration.Guest_Host_Status__c = 'Host attending';
                            eventRegistration.Hosted_Registrants__c = guestRegistrations.size();
                        }

                    }

                    if (String.isNotBlank(eventRegistration.Event__r.Payment_Gateway__c) && eventRegistration.Event__r.Payment_Gateway__c != 'No Gateway') {
                        pageRef = checkForPayment();
                    }

                    if (eventRegistrationSuccess && pageRef == null) {
                        //Build encrypted string for registration. Used for cancel link or other services outside of Summit Events App
                        //valid = false will not work for registration pages, only confirmation and cancel registration pages

                        String encryptedString = SummitEventsShared.createEncryptedCookie(eventInformation.audience, eventInformation.instanceId, eventInformation.eventId, eventInformation.registrationId, false);

                        if (encryptedString.length() > 255) {
                            eventRegistration.Encrypted_Registration_Id_1__c = encryptedString.substring(0, 255);
                            eventRegistration.Encrypted_Registration_Id_2__c = encryptedString.substring(255, encryptedString.length());
                        } else {
                            eventRegistration.Encrypted_Registration_Id_1__c = encryptedString;
                        }

                        eventRegistration.Status__c = 'Registered';
                        eventRegistration = regCRUD.updateRegistration(eventRegistration);

                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Hosted guest record(s) could not be saved.'));
                    }


                }
            }

        }
        return pageRef;
    }

    public PageReference checkForPayment() {
        String errorMessage = '';
        PageReference pageRef = null;
        List<Summit_Events_Payment__c> payments = [
                SELECT Id, Payment_Amount__c
                FROM Summit_Events_Payment__c
                WHERE Event_Registration__c = :eventInformation.registrationId
        ];
        if (payments.size() > 0) {
            paymentReceived = true;
        } else if (payments.size() == 0) {
            errorMessage = 'Payment was not received. Please try again.';
        } else {
            errorMessage = 'Multiple payments were received. Please contact event.';
        }
        if (String.isNotBlank(errorMessage)) {
            pageRef = Page.SummitEventsSubmit;
            pageRef.getParameters().put('error', EncodingUtil.urlEncode(errorMessage, 'UTF-8'));
            pageRef.setRedirect(true);
        }
        return pageRef;
    }

    public void gatherPaymentInformation() {
        /** Collect Fees **/
        eventOnlyPaymentAmount = 0;
        totalPaymentAmount = 0;

        eventFees = SummitEventsReadShared.getFeesByRegistrationId(eventInformation.registrationId);

        List<Summit_Events_Payment__c> payments = SummitEventsReadShared.getPaymentsByRegistrationId(eventInformation.registrationId);

        for (Summit_Events_Fee__c fee : eventFees) {
            if (fee.Event_Fee__c != null && fee.Event_Fee__c > 0) {
                totalPaymentAmount += fee.Event_Fee__c;
            }
            if (fee.Event_Fee_Type__c == 'Event' || fee.Event_Fee_Type__c == 'Event Additional') {
                eventOnlyPaymentAmount += fee.Event_Fee__c;
            }

        }

        if (payments.size() > 0) {
            paymentReceived = true;
            //Payment received. Get payment fees to display.
            existingPaymentAmount = payments[0].Payment_Amount__c;
            totalPaymentAmount = totalPaymentAmount - payments[0].Payment_Amount__c;
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }
            return newEvtReg;
        }

        public Boolean addGuestRegistration(List<Summit_Events_Registration__c> guestRegistrations) {
            Boolean guestAdded = false;
            try {
                insert guestRegistrations;
                guestAdded = true;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }
            return guestAdded;
        }
    }
}