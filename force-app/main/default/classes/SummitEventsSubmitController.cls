// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsSubmitController {
    public SummitEventsShared seaShared = new SummitEventsShared();
    public SummitEventsShared.SummitEventsInfo eventInformation { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public Summit_Events_Instance__c eventInstance { get; set; }
    public List<Summit_Events_Appointment_Type__c> appointments { get; set; }
    public List<Summit_Events_Appointments__c> chosenAppointments { get; set; }
    public String templateSelected { get; set; }
    public Map <String, String> feesByIndex { get; set; }
    public String formattedNavDate { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean adminOpen { get; set; }
    public List<Summit_Events_Fee__c> eventFees { get; set; }
    public Double totalPaymentAmount { get; set; }
    public String totalPaymentAmountFormatted { get; set; }
    public Double existingPaymentAmount { get; set; }
    public Double eventOnlyPaymentAmount { get; set; }
    public String eventOnlyPaymentAmountFormatted { get; set; }
    public List<questionGuestData> guestAnswers { get; set; }
    public String paymentItemized { get; set; }
    public Boolean showPaymentButton { get; set; }
    public Map<String, PageReference> pageFlow { get; set; }

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
        showPaymentButton = false;

        //Get cookie or URL string variable
        eventInformation = seaShared.getSummitEventsInfo();

        if (!String.isEmpty(eventInformation.eventId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_Submit_Title__c, Event_Submit_Description__c, Event_Footer__c, Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c,
                            Tracking_Submit_Registration__c, Event_Full_Text__c, Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c,
                            Donation_Description__c, Display_Optional_Donation__c
                    FROM Summit_Events__c
                    WHERE Id = :eventInformation.eventId
                    WITH SECURITY_ENFORCED
            ];

            templateSelected = seaShared.getTemplate(eventPage.Template__c);

            eventInstance = [
                    SELECT Instance_Title__c, Event__r.Event_Name__c, Instance_Time_Zone__c,
                            Instance_Start_Time__c, Instance_End_Time__c, Instance_Start_Date__c,
                            Instance_End_Date__c, Current_Available_Capacity__c, Active_Status__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :eventInformation.instanceId
                    WITH SECURITY_ENFORCED
            ];

            pageFlow = SeaShared.getPageFlow(eventInformation.eventId, eventInstance.Instance_Title__c, ApexPages.currentPage());

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                eventIsClosed = adminOpen;
            } else {
                eventIsClosed = seaShared.isEventClosed(eventPage, eventInstance);
            }

            formattedNavDate = seaShared.navBreadcrumbBuilder(eventInstance);
        }

        if (!String.isBlank(eventInformation.registrationId)) {

            guestAnswers = new List<questionGuestData>();

            Summit_Events_Registration__c eventRegistration = [
                    SELECT Id, Guest_JSON__c
                    FROM Summit_Events_Registration__c
                    WHERE Id = :eventInformation.registrationId
            ];


            if (String.isNotBlank(eventRegistration.Guest_JSON__c)) {

                Map<Id, Summit_Events_Question__c> eventGuestQuestions = new Map<Id, Summit_Events_Question__c>([
                        SELECT Name, Question_Label__c, Question_Field_Type__c, Default_Value__c, Registrant_Type__c, Instructions__c, Help_Text__c, Display_Order__c,
                                Map_to_Field__c, Picklist_Values__c, Text_Limit__c, Controlling_Question__c, Controlling_Logic__c, Required__c, Is_Visible__c
                        FROM Summit_Events_Question__c
                        WHERE Event__c = :eventInformation.eventId
                        AND Registrant_Type__c = 'Guest'
                        WITH SECURITY_ENFORCED
                        ORDER BY Display_Order__c NULLS LAST
                ]);

                guestAnswers = (List<questionGuestData>) JSON.deserialize(eventRegistration.Guest_JSON__c, List<questionGuestData>.class);
                for (Integer xx = 0; xx < guestAnswers.size(); xx++) {
                    Integer questionCount = 0;
                    for (Integer yy = 0; yy < guestAnswers[xx].questions.size(); yy++) {
                        Id questionId = null;
                        try {
                            questionId = seaShared.decryptString(guestAnswers[xx].questions[yy].Id, true);
                        } catch (Exception e) {
                            System.debug(e.getMessage());
                        }
                        if (questionId != null) {
                            Summit_Events_Question__c questionParameters = eventGuestQuestions.get(questionId);
                            if (!questionParameters.Is_Visible__c) {
                                System.debug('not visible');
                                //remove NOT visible questions so they do not appear to front end user
                                guestAnswers[xx].questions.remove(yy);
                            }
                        }
                        questionCount++;
                    }
                }

            }

            chosenAppointments = [
                    SELECT Id, Appointment_Category__c, Event_Appointment_Type__c, Appointment_Type__c, Description__c, Appointment_Title__c, Chosen_State__c
                    FROM Summit_Events_Appointments__c
                    WHERE Event_Registration__c = :eventInformation.registrationId
                    AND Chosen_State__c != 'Added but not shown'
                    WITH SECURITY_ENFORCED
                    ORDER BY Appointment_Title__c
            ];

            /** Check for preexisting payment **/
            List<Summit_Events_Payment__c> existingPayment = [SELECT Id, Payment_Amount__c, TouchnetReceiptNumber__c FROM Summit_Events_Payment__c WHERE Event_Registration__c = :eventInformation.registrationId];
            if (existingPayment.size() > 0) {
                existingPaymentAmount = existingPayment[0].Payment_Amount__c;
            }

            /** Collect Fees **/
            eventFees = [
                    SELECT Name, Event_Fee__c, Event_Fee_Allocation__c, Description__c, Event_Fee_Type__c, Summit_Events__c, Event_Appointment_Type__c,
                            Event_Appointment_Type__r.Title__c, Event_Fee_Allocation__r.Name
                    FROM Summit_Events_Fee__c
                    WHERE Event_Registration__c = :eventInformation.registrationId
                    WITH SECURITY_ENFORCED
            ];

            if (eventFees.size() > 0) {
                feesByIndex = new Map<String, String>();
                eventOnlyPaymentAmount = 0;
                totalPaymentAmount = 0;
                for (Summit_Events_Fee__c fee : eventFees) {
                    if (fee.Event_Fee__c != null && fee.Event_Fee__c > 0) {
                        totalPaymentAmount += fee.Event_Fee__c;
                    }
                }
                if (existingPaymentAmount > 0) {
                    totalPaymentAmount = totalPaymentAmount - existingPaymentAmount;
                }
                eventOnlyPaymentAmountFormatted = prettyCurrencyString(eventOnlyPaymentAmount);
                totalPaymentAmountFormatted = prettyCurrencyString(totalPaymentAmount);
            }
            if (totalPaymentAmount > 0) {
                showPaymentButton = true;
            }
        }

    }

    public String prettyCurrencyString(Decimal numberIn) {
        String numberOut = '';
        List<String> args = new String[]{
                '0', 'number', '###,###,##0.00'
        };
        numberOut = '$' + String.format(numberIn.format(), args);
        return numberOut;
    }

    public PageReference checkEventDetails() {
        return seaShared.checkForEvent();
    }

    public PageReference submitRegistration() {
        return pageFlow.get('Next');
    }

    public PageReference previousPage() {
        return pageFlow.get('Previous');
    }
}