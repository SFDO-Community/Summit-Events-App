// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 2/10/2020.


public with sharing class SummitEventsDonationController {
    public SummitEventsShared SEShared = new SummitEventsShared();
    public SummitEventsShared.SummitEventsInfo eventInfo { get; set; }

    public Summit_Events_Instance__c eventInstance { get; set; }
    public String templateSelected { get; set; }
    public String donationRecipient { get; set; }
    public String donationAmountSelect { get; set; }
    public String donationAmount { get; set; }
    public Summit_Events_Fee__c incomingFee { get; set; }

    public SummitEventsDonationController() {
        eventInfo = SEShared.getSummitEventsInfo();

        List<Summit_Events_Instance__c> eventInstanceList = [
                SELECT Id, Event__r.Display_Optional_Donation__c, Event__r.Donation_Suggested_Amount_List__c, Event__r.Donation_Description__c,
                        Event__r.Donation_Recipient_1__c,Event__r.Donation_Recipient_2__c, Event__r.Donation_Recipient_3__c, Event__r.Donation_Recipient_4__c,
                        Event__r.Donation_Recipient_5__c, Event__r.Donation_Recipient_1__r.Name, Event__r.Donation_Recipient_2__r.Name,
                        Event__r.Donation_Recipient_3__r.Name, Event__r.Donation_Recipient_4__r.Name, Event__r.Donation_Recipient_5__r.Name,
                        Event__r.Event_Name__c, Instance_Title__c, Event__r.Event_Home_Link_URL__c, Event__r.Event_Home_Link_Title__c, Event__r.Template__c
                FROM Summit_Events_Instance__c
                WHERE Id = :eventInfo.instanceID
        ];


        if (eventInstanceList.size() > 0) {
            eventInstance = eventInstanceList[0];
            templateSelected = SEShared.getTemplate(eventInstance.Event__r.Template__c);

            //Check for current donation fees for this registration
            List<Summit_Events_Fee__c> previousDonationFees = [
                    SELECT Id, Event_Registration__c, Event_Fee__c, Event_Fee_Attribute__c
                    FROM Summit_Events_Fee__c
                    WHERE Event_Registration__c = :eventInfo.registrationId
                    AND Event_Fee_Type__c = 'Optional Donation'
            ];

            if (previousDonationFees.size() > 0) {
                incomingFee = previousDonationFees[0];
                System.debug('INCOMING FEE: ' + incomingFee);
                donationRecipient = incomingFee.Event_Fee_Attribute__c;
                donationAmount = String.valueOf(incomingFee.Event_Fee__c);
                donationAmountSelect = String.valueOf(incomingFee.Event_Fee__c);
            }
        }
    }

    public List<SelectOption> getDonationRecipientList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select...'));

        for (Integer xx = 1; xx < 6; xx++) {
            if (String.isNotBlank(String.valueOf(eventInstance.getSObject('Event__r').get('Donation_Recipient_' + xx + '__c')))) {
                options.add(
                        new SelectOption(
                                String.valueOf(eventInstance.getSObject('Event__r').get('Donation_Recipient_' + xx + '__c')),
                                String.valueOf(eventInstance.getSObject('Event__r').getSObject('Donation_Recipient_' + xx + '__r').get('Name'))
                        )
                );
            }
        }
        return options;
    }

    public List<SelectOption> getSuggestedDonation() {
        List<SelectOption> cpl = new List<SelectOption>();
        String suggested = '';
        if (!String.isBlank(eventInstance.Event__r.Donation_Suggested_Amount_List__c)) {
            suggested = eventInstance.Event__r.Donation_Suggested_Amount_List__c;
            cpl.add(new SelectOption('', 'Select...'));
            suggested = suggested.trim();
            suggested = suggested.replace('\n\n', '\n');
            String[] splitList = suggested.split('\n');
            for (String p : splitList) {
                Decimal numberIn = cleanFeeStringToDecimal(p).setScale(2);
                cpl.add(new SelectOption(String.valueOf(numberIn), prettyCurrencyString(numberIn)));
            }
            cpl.add(new SelectOption('Other Amount', 'Other Amount'));
        }
        return cpl;
    }

    public Decimal cleanFeeStringToDecimal(String currencyString) {
        currencyString = currencyString.replaceAll('[^0-9.]', '');
        Decimal d = Decimal.valueOf(!String.isEmpty(currencyString) ? currencyString : '0');
        d = d.setScale(8, RoundingMode.HALF_EVEN);
        return d;
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

    public PageReference submitDonation() {

        doCRUD CRUDToDo = new doCRUD();
        System.debug('Donation Amount' + donationAmount);
        if (String.isNotBlank(donationAmount)) {
            //Build fee on what we have for donation information
            Summit_Events_Fee__c newFee = new Summit_Events_Fee__c();
            newFee.Event_Fee_Attribute__c = donationRecipient;
            newFee.Event_Fee__c = cleanFeeStringToDecimal(donationAmount);
            newFee.Event_Registration__c = eventInfo.registrationId;
            newFee.Summit_Events__c = eventInfo.eventId;
            newFee.Event_Fee_Type__c = 'Optional Donation';
            //If there is an incoming fee already for a donation just update it by applying the id
            if (incomingFee != null) {
                newFee.Id = incomingFee.Id;
            }
            System.debug('Incoming Fee: ' + JSON.serializePretty(incomingFee));
            CRUDToDo.upsertFee(newFee);
        } else {
            //If there is no amount and a fee exists than delete it.
            if (incomingFee != null) {
                CRUDToDo.deleteFee(incomingFee);
            }
        }

        PageReference submitPage = Page.SummitEventsSubmit;
        return submitPage;
    }

    public PageReference previousPage() {
        PageReference prevPage = Page.SummitEventsRegister;
        List<Summit_Events_Appointment_Type__c> appointmentTypes = [
                SELECT Id
                FROM Summit_Events_Appointment_Type__c
                WHERE Summit_Events__c = :eventInfo.eventId
                AND (Restrict_To_Instance_Title__r.Instance_Title__c = :eventInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = NULL)
                AND Appointment_Type_Status__c = 'Active'
        ];
        if (appointmentTypes.size() > 0) {
            prevPage = Page.SummitEventsRegisterAppointments;
        }
        return prevPage;
    }

    private without sharing class doCRUD {

        public void upsertFee(Summit_Events_Fee__c feeIn) {
            upsert feeIn;
        }

        public void deleteFee(Summit_Events_Fee__c feeIn) {
            delete feeIn;
        }

    }
}