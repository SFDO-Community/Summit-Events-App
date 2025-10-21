// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsSubmitController {
    public SummitEventsInfo eventInformation { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public Summit_Events_Instance__c eventInstance { get; set; }
    public List<Summit_Events_Appointment_Type__c> appointments { get; set; }
    public List<Summit_Events_Appointments__c> chosenAppointments { get; set; }
    public String templateSelected { get; set; }
    public Map <String, String> feesByIndex { get; set; }
    public String formattedNavDate { get; set; }
    public Boolean eventIsClosed { get; set; }
    public List<Summit_Events_Fee__c> eventFees { get; set; }
    public Double totalPaymentAmount { get; set; }
    public Double existingPaymentAmount { get; set; }
    public Double eventOnlyPaymentAmount { get; set; }
    public List<questionGuestData> guestAnswers { get; set; }
    public Map<String, PageReference> pageFlow { get; set; }
    public Boolean hasPaymentGateway { get; set; }
    public Boolean hasMessages { get; set; }

    public class questionGuestData {
        public String guestId { get; set; }
        public List<questionData> questions { get; set; }
    }

    public class questionData {
        public String id { get; set; }
        public String value { get; set; }
        public String question { get; set; }
    }

    public SummitEventsSubmitController() {
        hasMessages = false;

        //Get cookie or URL string variable
        eventInformation = SummitEventsShared.getSummitEventsInfo();

        if (!String.isEmpty(eventInformation.eventId)) {
            eventPage = SummitEventsReadShared.getEventById(eventInformation.eventId);

            templateSelected = SummitEventsShared.getTemplate(eventPage.Template__c);

            if (String.isNotBlank(eventPage.Payment_Gateway__c) && eventPage.Payment_Gateway__c != 'No Gateway') {
                hasPaymentGateway = true;
            }

            eventInstance = SummitEventsReadShared.getInstanceById(eventInformation.instanceId);

            pageFlow = SummitEventsShared.getPageFlow(eventInformation.eventId, eventInstance.Instance_Title__c, ApexPages.currentPage(), eventInstance.Instance_Start_Date__c, eventInstance.Instance_End_Date__c);

            eventIsClosed = SummitEventsShared.isEventClosed(eventInstance, eventPage.Event_Status__c);

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('error'))) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ApexPages.currentPage().getParameters().get('error')));
            }

            formattedNavDate = SummitEventsShared.navBreadcrumbBuilder(eventInstance);
        }

        if (!String.isBlank(eventInformation.registrationId)) {

            guestAnswers = new List<questionGuestData>();

            Summit_Events_Registration__c eventRegistration = SummitEventsReadShared.getRegistrationById(eventInformation.registrationId);

            if (String.isNotBlank(eventRegistration.Guest_JSON__c)) {

                List<String> registrantTypes = new List<String>{
                        'Guest', 'Registrant and Guest'
                };
                Map<Id, Summit_Events_Question__c> eventGuestQuestions = SummitEventsReadShared.getAdditionalQuestionsByEventId(eventInformation.eventId, registrantTypes);

                guestAnswers = (List<questionGuestData>) JSON.deserialize(eventRegistration.Guest_JSON__c, List<questionGuestData>.class);
                for (Integer xx = 0; xx < guestAnswers.size(); xx++) {
                    Integer questionCount = 0;
                    for (Integer yy = 0; yy < guestAnswers[xx].questions.size(); yy++) {
                        Id questionId = null;
                        try {
                            questionId = SummitEventsShared.decryptString(guestAnswers[xx].questions[yy].id, true);
                        } catch (Exception e) {
                            System.debug(e.getMessage());
                        }
                        if (questionId != null) {
                            Summit_Events_Question__c questionParameters = eventGuestQuestions.get(questionId);
                            if (!questionParameters.Is_Visible__c) {
                                //remove NOT visible questions so they do not appear to front end user
                                guestAnswers[xx].questions.remove(yy);
                            }
                        }
                        questionCount++;
                    }
                }

            }

            chosenAppointments = SummitEventsReadShared.getAppointmentsByRegistrationId(eventInformation.registrationId);
            for (Integer x = 0; x < chosenAppointments.size(); x++) {
                chosenAppointments[x].Description__c = SummitEventsShared.removeHTMLandEscape(chosenAppointments[x].Description__c, false);
            }

            /** Check for preexisting payment **/
            List<Summit_Events_Payment__c> existingPayment = SummitEventsReadShared.getPaymentsByRegistrationId(eventInformation.registrationId);
            if (existingPayment.size() > 0) {
                existingPaymentAmount = existingPayment[0].Payment_Amount__c;
            }

            /** Collect Fees **/
            eventFees = SummitEventsReadShared.getFeesByRegistrationId(eventInformation.registrationId);
            if (eventFees.size() > 0) {
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
            }
        }
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        if (pageMessages.size() > 0) {
            hasMessages = true;
        }

    }

    public PageReference checkEventDetails() {
        return SummitEventsShared.checkForEvent('submit');
    }

    public PageReference submitRegistration() {
        return pageFlow.get('Next');
    }

    public PageReference previousPage() {
        return pageFlow.get('Previous');
    }
}