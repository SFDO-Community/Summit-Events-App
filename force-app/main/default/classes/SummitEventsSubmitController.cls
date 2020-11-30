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
    public Map <String, String> feesByIndex { get; set; }
    public String navBreadCrumb { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean adminOpen { get; set; }
    private List<Summit_Events_Fee__c> eventFees { get; set; }
    public Double totalPaymentAmount { get; set; }
    public Double existingPaymentAmount { get; set; }
    public Double eventOnlyPaymentAmount { get; set; }
    public String paymentItemized { get; set; }
    public Boolean showPaymentButton { get; set; }

    public SummitEventsSubmitController() {
        showPaymentButton = false;
        test = '';

        //Get cookie or URL string variable
        evtInfo = SEShared.getSummitEventsInfo();
        chosenFormatted = '';
        if (!String.isEmpty(evtInfo.evtId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_Submit_Title__c, Event_Submit_Description__c, Event_Footer__c, Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c,
                            Tracking_Submit_Registration__c, Event_Full_Text__c, Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c,
                            Donation_Description__c, Display_Optional_Donation__c
                    FROM Summit_Events__c
                    WHERE Id = :evtInfo.evtId
            ][0];

            templateSelected = SEShared.getTemplate(eventPage.Template__c);

            evtInstance = [
                    SELECT Instance_Title__c, Event__r.Event_Name__c, Instance_Time_Zone__c,
                            Instance_Start_Time__c, Instance_End_Time__c, Instance_Start_Date__c,
                            Instance_End_Date__c, Current_Available_Capacity__c, Active_Status__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :evtInfo.instanceID
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

        if (!String.isBlank(evtInfo.evtRegId)) {
            chosenAppts = [
                    SELECT Id, Appointment_Category__c, Event_Appointment_Type__c, Appointment_Type__c, Description__c, Appointment_Title__c, Chosen_State__c
                    FROM Summit_Events_Appointments__c
                    WHERE Event_Registration__c = :evtInfo.evtRegId
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

//            /** Get Event registrant information if possible **/
//            eventRegistration = [
//                    SELECT Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_City__c, Registrant_State_Province__c, Registrant_State__c,
//                            Registrant_Postal_Code__c, Registrant_Zip__c, Registrant_Street_1__c, Registrant_Street_2__c, Registrant_Email__c, Registrant_Country__c,
//                            Event_Name__c, Event_Instance_Title__c, Event_Instance_Date_Time_Formatted__c, Contact__c
//                    FROM Summit_Events_Registration__c
//                    WHERE Id = :evtInfo.evtRegId
//            ];

            /** Check for preexisting payment **/
            List<Summit_Events_Payment__c> existingPayment = [SELECT Id, Payment_Amount__c, TouchnetReceiptNumber__c From Summit_Events_Payment__c WHERE Event_Registration__c = :evtInfo.evtRegId];
            if (existingPayment.size() > 0) {
                existingPaymentAmount = existingPayment[0].Payment_Amount__c;
            }

            /** Collect Fees **/
            eventFees = [
                    SELECT Name, Event_Fee__c, Event_Fee_Attribute__c, Description__c, Event_Fee_Type__c, Summit_Events__c, Event_Appointment_Type__c,
                            Event_Appointment_Type__r.Title__c, Event_Fee_Attribute__r.Name
                    FROM Summit_Events_Fee__c
                    WHERE Event_Registration__c = :evtInfo.EvtRegId
            ];
            feesByIndex = new Map<String, String>();
            paymentItemized = '<table class="slds-table slds-table_cell-buffer slds-table_bordered">';
            paymentItemized += '<thead>';
            paymentItemized += '<tr class="slds-line-height_reset">';
            paymentItemized += '<th class="" scope="col">';
            paymentItemized += '<div class="slds-truncate" title="Item">Item</div>';
            paymentItemized += '</th>';
            paymentItemized += '<th class="" scope="col">';
            paymentItemized += '<div class="slds-truncate" title="Fee">Fee</div>';
            paymentItemized += '</th>';
            paymentItemized += '</thead><tbody>';
            eventOnlyPaymentAmount = 0;
            for (Summit_Events_Fee__c fee : eventFees) {
                if (fee.Event_Fee__c != null && fee.Event_Fee__c > 0) {
                    totalPaymentAmount += fee.Event_Fee__c;
                    if (!fee.Event_Fee_Type__c.equalsIgnoreCase('Event') || !fee.Event_Fee_Type__c.equalsIgnoreCase('Event Additional')) {
                        if (fee.Event_Fee_Type__c.equalsIgnoreCase('Appointment')) {
                            paymentItemized += '<tr class="eventAppointmentCost">';
                            paymentItemized += '<td>' + fee.Event_Appointment_Type__r.Title__c + '</td>';
                            paymentItemized += '<td>' + prettyCurrencyString(fee.Event_fee__c) + '</td>';
                            paymentItemized += '</tr>';
                        } else if (fee.Event_Fee_Type__c.equalsIgnoreCase('Optional Donation')) {
                            paymentItemized += '<tr class="eventDonation">';
                            paymentItemized += '<td>' + fee.Event_Fee_Type__c;
                            if (String.isNotBlank(fee.Event_Fee_Attribute__r.Name)) {
                                paymentItemized += ' - ' + fee.Event_Fee_Attribute__r.Name;
                            }
                            paymentItemized += '</td>';
                            paymentItemized += '<td>' + prettyCurrencyString(fee.Event_fee__c) + '</td>';
                            paymentItemized += '</tr>';
                        } else {
                            eventOnlyPaymentAmount += fee.Event_Fee__c;
                        }
                    }
                    if (feesByIndex.size() > 0 && feesByIndex.containsKey(fee.Event_Fee_Attribute__c)) {
                        Decimal newFee = Decimal.valueOf(feesByIndex.get(fee.Event_Fee_Attribute__c));
                        newFee = newFee + fee.Event_Fee__c;
                        newFee = newFee.setScale(2);
                        feesByIndex.put(fee.Event_Fee_Attribute__c, String.valueOf(newFee));
                    } else {
                        feesByIndex.put(fee.Event_Fee_Attribute__c, String.valueOf(fee.Event_Fee__c));
                    }

                }
            }


            if (existingPaymentAmount > 0) {
                totalPaymentAmount = totalPaymentAmount - existingPaymentAmount;
            }

            paymentItemized += '<tr class="eventOnlyCost">';
            paymentItemized += '<td>General Event</td>';
            paymentItemized += '<td>' + prettyCurrencyString(eventOnlyPaymentAmount) + '</td>';
            paymentItemized += '</tr>';

            paymentItemized += '<tr class="eventTotalCost">';
            paymentItemized += '<td><strong>Total Cost</strong></td>';
            paymentItemized += '<td><strong>' + prettyCurrencyString(totalPaymentAmount) + '</strong></td>';
            paymentItemized += '</tr>';

            paymentItemized += '</tbody></table>';

            System.debug(paymentItemized);
            if (totalPaymentAmount > 0) {
                showPaymentButton = true;
                //generateTicket();
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
                WHERE Summit_Events__c = :evtInfo.evtId
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