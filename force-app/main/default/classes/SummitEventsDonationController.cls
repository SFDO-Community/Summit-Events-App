// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause License
// license that can be found in the LICENSE file'
// Created by Thaddaeus Dahlberg on 2/10/2020.

public with sharing class SummitEventsDonationController {

    public SummitEventsShared seaShared = new SummitEventsShared();
    public SummitEventsInfo eventInformation { get; set; }
    public Summit_Events_Instance__c eventInstance { get; set; }
    public String templateSelected { get; set; }
    public String donationAllocation { get; set; }
    public String donationAmountSelect { get; set; }
    public String donationAmount { get; set; }
    public Summit_Events_Fee__c incomingFee { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public String formattedNavDate { get; set; }
    public Map<String, PageReference> pageFlow {get;set;}

    public SummitEventsDonationController() {
        eventInformation = seaShared.getSummitEventsInfo();

        if (String.isNotBlank(eventInformation.eventId) && String.isNotBlank(eventInformation.instanceId)) {

            eventPage = [
                    SELECT Event_Name__c, Event_Submit_Title__c, Event_Submit_Description__c, Event_Footer__c, Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c,
                            Tracking_Submit_Registration__c, Event_Full_Text__c, Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c, Donation_Suggested_Amount_List__c,
                            Donation_Description__c, Display_Optional_Donation__c, Donation_Allocation_1__c, Donation_Allocation_2__c, Donation_Allocation_3__c, Donation_Allocation_4__c,
                            Donation_Allocation_5__c, Donation_Allocation_1__r.Name, Donation_Allocation_2__r.Name, Donation_Allocation_3__r.Name, Donation_Allocation_4__r.Name,
                            Donation_Allocation_5__r.Name, Donation_Title__c, Account__r.Name, Audience__c, Filter_Category__c, Event_Sponsor__c
                    FROM Summit_Events__c
                    WHERE Id = :eventInformation.eventId
                    WITH SECURITY_ENFORCED
            ];

            eventInstance = [
                    SELECT Id, Instance_Title__c, Instance_Start_Date__c, Instance_End_Date__c, Instance_Start_Time__c, Instance_End_Time__c, Instance_Time_Zone__c,
                            Current_Available_Capacity__c, Active_Status__c, Event__r.Event_Name__c, Registration_Close_Date__c, Registration_Close_Time__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :eventInformation.instanceId
                    WITH SECURITY_ENFORCED
            ];

            pageFlow = seaShared.getPageFlow(eventInformation.eventId, eventInstance.Instance_Title__c, ApexPages.currentPage(), eventInstance.Instance_Start_Date__c, eventInstance.Instance_End_Date__c);

            templateSelected = seaShared.getTemplate(eventPage.Template__c);

            //Check for current donation fees for this registration
            List<Summit_Events_Fee__c> previousDonationFees = [
                    SELECT Id, Event_Registration__c, Event_Fee__c, Event_Fee_Allocation__c
                    FROM Summit_Events_Fee__c
                    WHERE Event_Registration__c = :eventInformation.registrationId
                    AND Event_Fee_Type__c = 'Optional Donation'
                    WITH SECURITY_ENFORCED
            ];

            if (previousDonationFees.size() > 0) {
                incomingFee = previousDonationFees[0];
                donationAllocation = incomingFee.Event_Fee_Allocation__c;
                donationAmount = String.valueOf(incomingFee.Event_Fee__c);
                donationAmountSelect = String.valueOf(incomingFee.Event_Fee__c);
            }

            eventIsClosed = seaShared.isEventClosed(eventInstance);

            formattedNavDate = seaShared.navBreadcrumbBuilder(eventInstance);
        }
    }

    public List<SelectOption> getDonationAllocationList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select...'));

        for (Integer xx = 1; xx < 6; xx++) {
            if (String.isNotBlank(String.valueOf(eventPage.get('Donation_Allocation_' + xx + '__c')))) {
                options.add(
                        new SelectOption(
                                String.valueOf(eventPage.get('Donation_Allocation_' + xx + '__c')),
                                String.valueOf(eventPage.getSObject('Donation_Allocation_' + xx + '__r').get('Name'))
                        )
                );
            }
        }
        return options;
    }

    public List<SelectOption> getSuggestedDonation() {
        List<SelectOption> cpl = new List<SelectOption>();
        String suggested = '';
        if (!String.isBlank(eventPage.Donation_Suggested_Amount_List__c)) {
            suggested = eventPage.Donation_Suggested_Amount_List__c;
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
        return seaShared.checkForEvent();
    }

    public PageReference submitDonation() {

        doCRUD CRUDToDo = new doCRUD();
        if (String.isNotBlank(donationAmount)) {
            //Build fee on what we have for donation information
            Summit_Events_Fee__c newFee = new Summit_Events_Fee__c();
            newFee.Event_Fee_Allocation__c = donationAllocation;
            newFee.Event_Fee__c = cleanFeeStringToDecimal(donationAmount);
            newFee.Event_Registration__c = eventInformation.registrationId;
            newFee.Summit_Events__c = eventInformation.eventId;
            newFee.Event_Fee_Type__c = 'Optional Donation';
            //If there is an incoming fee already for a donation just update it by applying the id
            if (incomingFee != null) {
                newFee.Id = incomingFee.Id;
            }
            CRUDToDo.upsertFee(newFee);
        } else {
            //If there is no amount and a fee exists than delete it.
            if (incomingFee != null) {
                CRUDToDo.deleteFee(incomingFee);
            }
        }

        return pageFlow.get('Next');
    }

    public PageReference previousPage() {
        return pageFlow.get('Previous');
    }

    /**
     * Summit Events is a multi-step, guest user, registration solution so CRUD work needs to be done on records where guest record ownership is lost between steps.
     * The security aspects of guest record updating is achieved by:
     * - Using an encrypted cookie on the client browser to keep track of registration id, event id, instance id, and audience
     * - Dividing each controller class into a "with sharing" logic area and a sub "without sharing" CRUD area for purposeful CRUD
     * - When the encrypted cookie is not available as in the cancel registration link an encrypted string is provided through the URL to not expose the SF ID related to the record
     **/

    private without sharing class doCRUD {

        public void upsertFee(Summit_Events_Fee__c feeIn) {
            upsert feeIn;
        }

        public void deleteFee(Summit_Events_Fee__c feeIn) {
            if (Summit_Events_Fee__c.SObjectType.getDescribe().isDeletable()) {
                delete feeIn;
            }
        }

    }
}