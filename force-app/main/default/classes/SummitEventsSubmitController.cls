// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsSubmitController {
    public SummitEventsShared SEShared = new SummitEventsShared();
    public String test { get; set; }
    public SummitEventsShared.SummitEventsInfo evtInfo { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public Summit_Events_Registration__c eventRegistration { get; set; }
    public Summit_Events_Instance__c evtInstance { get; set; }
    public List<Summit_Events_Appointment_Type__c> appts { get; set; }
    public List<Summit_Events_Appointments__c> chosenAppts { get; set; }
    public String chosenFormatted { get; set; }
    public String templateSelected { get; set; }
    public String eventStartDateTimeCrumb { get; set; }
    public String communityBaseURL { get; set; }
    public Map <String, String> feesByIndex { get; set; }
    public Boolean eventHasOptions { get; set; }

    /*Below are all private attribute*/
    private String touchNetService;
    private String gatewayOrigin;
    private Map<String, String> mapResponse = new Map<String, String>();
    private String contactName;
    private Map<String, String> params;
    private List<Summit_Events_Fee__c> eventFees { get; set; }

    /*Below are all public get;set; attribute*/
    public String upayURL { get; set; }
    public String upayId { get; set; }
    public Boolean successReturnFromGateway { get; set; }
    public String ticket { get; set; }
    public String ticketName { get; set; }
    public Double paymentAmount { get; set; }
    public Double existingPaymentAmount { get; set; }
    public Boolean showPaymentButton { get; set; }

    public string headers { get; set; }

    public SummitEventsSubmitController() {
        test = '';
        eventHasOptions = false;
        templateSelected = SEShared.defaultTemplate;

        /** Get custom settings for SummitEventss **/
        Summit_Events_Settings__c custSetting = Summit_Events_Settings__c.getOrgDefaults();
        communityBaseURL = custSetting.Community_Base_URL__c;
        communityBaseURL = communityBaseURL.replace('http://', 'https://');
        touchNetService = custSetting.Tlink_URL__c;
        upayURL = custSetting.Upay_URL__c;
        upayId = custSetting.UpayId__c;
        gatewayOrigin = custSetting.Gateway_Origin__c;

        /** Code for Custom Payment Setting End from here **/
        paymentAmount = 0;
        existingPaymentAmount = 0;
        //Get cookie or URL string variable
        evtInfo = SEShared.getSummitEventsInfo();
        chosenFormatted = '';
        if (!String.isEmpty(evtInfo.evtId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_Submit_Title__c, Event_Submit_Description__c, Event_Footer__c, Template__c,
                            Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Submit_Registration__c
                    FROM Summit_Events__c
                    WHERE Id = :evtinfo.evtId
            ][0];
            templateSelected = eventPage.Template__c;

            evtInstance = [SELECT Instance_Title__c, Start_Date_Time__c, End_Date_Time__c FROM Summit_Events_Instance__c WHERE Id = :evtinfo.instanceID LIMIT 1];

            if (evtInstance.Start_Date_Time__c != null && evtInstance.End_Date_Time__c != null) {
                eventStartDateTimeCrumb = evtInstance.Start_Date_Time__c.format('MMMM d, YYYY, h:mm a') + ' - ' + evtInstance.End_Date_Time__c.format('h:mm a');
            }

            List<Summit_Events_Appointment_Type__c> apptTypes = [
                    SELECT Id
                    From Summit_Events_Appointment_Type__c
                    WHERE Summit_Events__c = :evtInfo.evtId
                    AND (Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = null)
            ];

            if (apptTypes.size() > 0) {
                eventHasOptions = true;
            }
        }


        if (!String.isBlank(evtinfo.evtRegId)) {
            chosenAppts = [
                    SELECT Id, Appointment_Category__c, Event_Appointment_Type__c, Appointment_Type__c, Description__c, Appointment_Title__c, Chosen_State__C
                    FROM Summit_Events_Appointments__c
                    WHERE Event_Registration__c = :evtinfo.evtRegId
                    AND Chosen_State__c != 'Added but not shown'
                    ORDER BY Appointment_Title__c
            ];
            if (chosenAppts.size() > 0) {
                chosenFormatted += '<ul id="choosenAppointments">';
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

            /** Get Event registrant information if possible **/
            eventRegistration = [
                    SELECT Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_City__c, Registrant_State_Province__c, Registrant_State__c,
                            Registrant_Postal_Code__c, Registrant_Zip__c, Registrant_Street_1__c, Registrant_Street_2__c, Registrant_Email__c, Registrant_Country__c,
                            Event_Name__c, Event_Instance_Title__c, Date_Time_Text__c, Contact__c
                    FROM Summit_Events_Registration__c
                    WHERE Id = :evtInfo.evtRegId
            ];

            /** Check for preexisting payment **/
            List<Summit_Events_Payment__c> existingPayment = [SELECT Id, Payment_Amount__c, TouchnetReceiptNumber__c From Summit_Events_Payment__c WHERE Event_Registration__c = :evtInfo.evtRegId];
            if (existingPayment.size() > 0) {
                existingPaymentAmount = existingPayment[0].Payment_Amount__c;
            }

            /** Collect Fees **/
            eventFees = [SELECT Name, Event_Fee__c, Event_Fee_Attribute__c, Description__c, Fee_Type__c, Summit_Events__c, Event_Appointment_Type__c FROM Summit_Events_Fee__c WHERE Event_Registration__c = :evtInfo.EvtRegId];
            feesByIndex = new Map<String, String>();
            for (Summit_Events_Fee__c fee : eventFees) {
                if (fee.Event_Fee__c != null && fee.Event_Fee__c > 0) {
                    paymentAmount += fee.Event_Fee__c;
                    if (feesByIndex.size() > 0) {
                        if (feesByIndex.containsKey(fee.Event_Fee_Attribute__c)) {
                            Decimal newFee = Decimal.valueOf(feesByIndex.get(fee.Event_Fee_Attribute__c));
                            newFee = newFee + fee.Event_Fee__c;
                            newFee = newFee.setScale(2);
                            feesByIndex.put(fee.Event_Fee_Attribute__c, String.valueOf(newFee));
                        } else {
                            feesByIndex.put(fee.Event_Fee_Attribute__c, String.valueOf(fee.Event_Fee__c));
                        }
                    } else {
                        feesByIndex.put(fee.Event_Fee_Attribute__c, String.valueOf(fee.Event_Fee__c));
                    }
                }
            }
            if (existingPaymentAmount > 0) {
                paymentAmount = paymentAmount - existingPaymentAmount;
            }

            if (paymentAmount > 0) {
                showPaymentButton = true;
                generateTicket();
            }
        }

    }

    public void displayTestingHeaders() {
        /** OPTIONAL METHOD - Display headers and parameters for testing **/
        //headers = '';

        MAP<string, string> hdrs = ApexPages.currentPage().getheaders();
        for (string key : hdrs.keySet()) {
            headers += key + ' : ' + hdrs.get(key) + '<br/>';
        }
        headers += '<br/><br/><strong>Params</strong><br/>';
        params = ApexPages.currentPage().getParameters();
        for (string key : params.keySet()) {
            headers += key + ' = ' + params.get(key) + '<br/>';
        }

        showPaymentButton = false;
        if (paymentAmount != null && paymentAmount > 0) {
            showPaymentButton = true;
            generateTicket();
        }

        headers += '<br/><br/>';
    }

    public PageReference checkEventDetails() {

        /** Below method will display headers and parameters for the page for testing. **/
        //displayTestingHeaders();

        /** Check for postback of payment gateway **/
        params = ApexPages.currentPage().getParameters();
        Map<String, String> returnHeaders = ApexPages.currentPage().getheaders();
        if (!returnHeaders.isEmpty()) {
            if (returnHeaders.get('Referer') != null) {
                String returnedReferrer = returnHeaders.get('Referer').toLowerCase();
                if (String.isNotBlank(returnedReferrer)) {
                    if (String.isBlank(gatewayOrigin)) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Set your orgs gateway settings or fees will not be collected.'));
                    } else {
                        if (returnedReferrer.trim().contains(gatewayOrigin)) {
                            /** Check for session identifier to see if a payment was successful **/
                            if (params.get('session_identifier') != null) {
                                successReturnFromGateway = true;
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Your payment is processing. Please do not refresh the page.'));
                            } else {
                                successReturnFromGateway = false;
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Your payment is processing was unsuccessful. Please try again.'));
                            }
                            return addPaymentInformation();
                        }
                    }
                }
            }
        }


        successReturnFromGateway = false;
        return SEShared.checkForEvent();
    }

    public PageReference submitRegistration() {
        PageReference confirmPage = Page.SummitEventsConfirmation;
        return confirmPage;
    }

    public PageReference previousPage() {
        List<Summit_Events_Appointment_Type__c> apptTypes = [
                SELECT Id
                From Summit_Events_Appointment_Type__c
                WHERE Summit_Events__c = :evtInfo.evtId
                AND (Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = null)
        ];
        PageReference lastPage;
        if (apptTypes.size() == 0) {
            //If no options skip that step
            lastPage = Page.SummitEventsRegister;
        } else {
            lastPage = Page.SummitEventsRegisterAppointments;
        }
        return lastPage;
    }


    /******* Below is used to generating ticket for Touchnet ********/
    public void generateTicket() {

        ticketName = 'ThomasTicket';

        String envelop = '';

        envelop = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://types.secureLink.touchnet.com">';
        envelop += '<soapenv:Header/>';
        envelop += '<soapenv:Body>';
        envelop += '    <typ:generateSecureLinkTicketRequest>';
        envelop += '        <typ:ticketName>' + ticketName + '</typ:ticketName>';
        envelop += '        <typ:nameValuePairs>';
        envelop += '            <typ:name>AMT</typ:name>';
        envelop += '            <typ:value>' + paymentAmount + '</typ:value>';
        envelop += '        </typ:nameValuePairs>';

        /** Add fees by index code **/
        Integer ff = 0;
        String accountSuffix = '';
        for (String key : feesByIndex.keySet()) {
            if (ff > 0) {
                accountSuffix = '_' + String.valueOf(ff + 1);
            } else {
                accountSuffix = '';
            }
            envelop += '        <typ:nameValuePairs>';
            envelop += '            <typ:name>CREDIT_ACCT_CODE' + accountSuffix + '</typ:name>';
            envelop += '            <typ:value>' + feesByIndex.get(key) + '</typ:value>';
            envelop += '        </typ:nameValuePairs>';
            envelop += '        <typ:nameValuePairs>';
            envelop += '            <typ:name>CREDIT_ACCT_AMT' + accountSuffix + '</typ:name>';
            envelop += '            <typ:value>' + key + '</typ:value>';
            envelop += '        </typ:nameValuePairs>';
            ff++;
        }

        /** Pass along customer NAME to pre-fill form. Concat first and last name if they exist with a space between. **/
        if (String.isNotBlank(eventRegistration.Registrant_First_Name__c) || String.isNotBlank(eventRegistration.Registrant_Last_Name__c)) {
            envelop += '        <typ:nameValuePairs>';
            envelop += '            <typ:name>BILL_NAME</typ:name>';
            envelop += '            <typ:value>';
            if (String.isNotBlank(eventRegistration.Registrant_First_Name__c)) {
                envelop += eventRegistration.Registrant_First_Name__c;

            }
            if (String.isNotBlank(eventRegistration.Registrant_First_Name__c) && String.isNotBlank(eventRegistration.Registrant_Last_Name__c)) {
                envelop += ' ';
            }
            if (String.isNotBlank(eventRegistration.Registrant_Last_Name__c)) {
                envelop += eventRegistration.Registrant_Last_Name__c;
            }
            envelop += '            </typ:value>';
            envelop += '        </typ:nameValuePairs>';
        }


        /** Pass along customer EMAIL to pre-fill form **/
        if (String.isNotBlank(eventRegistration.Registrant_Email__c)) {
            envelop += '        <typ:nameValuePairs>';
            envelop += '            <typ:name>BILL_EMAIL_ADDRESS</typ:name>';
            envelop += '            <typ:value>' + eventRegistration.Registrant_Email__c + '</typ:value>';
            envelop += '        </typ:nameValuePairs>';
        }

        /** Pass along customer ADDRESS 1 to pre-fill form **/
        if (String.isNotBlank(eventRegistration.Registrant_Street_1__c)) {
            envelop += '        <typ:nameValuePairs>';
            envelop += '            <typ:name>BILL_STREET1</typ:name>';
            envelop += '            <typ:value>' + eventRegistration.Registrant_Street_1__c + '</typ:value>';
            envelop += '        </typ:nameValuePairs>';
        }

        /** Pass along customer ADDRESS 2 to pre-fill form **/
        if (String.isNotBlank(eventRegistration.Registrant_Street_2__c)) {
            envelop += '        <typ:nameValuePairs>';
            envelop += '            <typ:name>BILL_STREET2</typ:name>';
            envelop += '            <typ:value>' + eventRegistration.Registrant_Street_2__c + '</typ:value>';
            envelop += '        </typ:nameValuePairs>';
        }

        /** Pass along customer CITY to pre-fill form **/
        if (String.isNotBlank(eventRegistration.Registrant_City__c)) {
            envelop += '        <typ:nameValuePairs>';
            envelop += '            <typ:name>BILL_CITY</typ:name>';
            envelop += '            <typ:value>' + eventRegistration.Registrant_City__c + '</typ:value>';
            envelop += '        </typ:nameValuePairs>';
        }

        /** Pass along customer STATE to pre-fill form **/
        if (String.isNotBlank(eventRegistration.Registrant_State__c)) {
            envelop += '        <typ:nameValuePairs>';
            envelop += '            <typ:name>BILL_STATE</typ:name>';
            envelop += '            <typ:value>' + eventRegistration.Registrant_State__c.toUpperCase() + '</typ:value>';
            envelop += '        </typ:nameValuePairs>';
        }

        /** Pass along customer ZIP or POSTAL CODE to pre-fill form **/
        if (String.isNotBlank(eventRegistration.Registrant_Zip__c)) {
            envelop += '        <typ:nameValuePairs>';
            envelop += '            <typ:name>BILL_POSTAL_CODE</typ:name>';
            envelop += '            <typ:value>' + eventRegistration.Registrant_Zip__c + '</typ:value>';
            envelop += '        </typ:nameValuePairs>';
        } else if (String.isNotBlank(eventRegistration.Registrant_Postal_Code__c)) {
            envelop += '        <typ:nameValuePairs>';
            envelop += '            <typ:name>BILL_STATE</typ:name>';
            envelop += '            <typ:value>' + eventRegistration.Registrant_Postal_Code__c + '</typ:value>';
            envelop += '        </typ:nameValuePairs>';
        }

        /** Pass along customer COUNTRY to pre-fill form **/
        If (String.isNotBlank(eventRegistration.Registrant_Country__c)) {
            envelop += '        <typ:nameValuePairs>';
            envelop += '            <typ:name>BILL_COUNTRY</typ:name>';
            if (eventRegistration.Registrant_Country__c.equalsIgnoreCase('united states')) {
                envelop += '            <typ:value>US</typ:value>';
            } else {
                envelop += '            <typ:value>' + eventRegistration.Registrant_Country__c.toLowerCase() + '</typ:value>';
            }
            envelop += '        </typ:nameValuePairs>';
        }

        /** Links where to send on different return status -- All the same? **/
        envelop += '        <typ:nameValuePairs>';
        envelop += '            <typ:name>SUCCESS_LINK</typ:name>';
        envelop += '            <typ:value>' + communityBaseURL + 'SummitEventsSubmit</typ:value>';
        envelop += '        </typ:nameValuePairs>';
        envelop += '        <typ:nameValuePairs>';
        envelop += '            <typ:name>CANCEL_LINK</typ:name>';
        envelop += '            <typ:value>' + communityBaseURL + 'SummitEventsSubmit</typ:value>';
        envelop += '        </typ:nameValuePairs>';
        envelop += '        <typ:nameValuePairs>';
        envelop += '            <typ:name>ERROR_LINK</typ:name>';
        envelop += '            <typ:value>' + communityBaseURL + 'SummitEventsSubmit</typ:value>';
        envelop += '        </typ:nameValuePairs>';


        envelop += '        <typ:nameValuePairs>';
        envelop += '            <typ:name>EXT_TRANS_ID</typ:name>';
        envelop += '            <typ:value>' + evtInfo.evtRegId + '</typ:value>';
        envelop += '        </typ:nameValuePairs>';

        /** Event Label **/
        if (String.isNotBlank(eventRegistration.Event_Name__c) || String.isNotBlank(eventRegistration.Event_Instance_Title__c)) {
            List<String> eventLabel = new List<String>();
            if (String.isNotBlank(eventRegistration.Event_Name__c)) {
                eventLabel.add(eventRegistration.Event_Name__c);
            }
            if (String.isNotBlank(eventRegistration.Event_Instance_Title__c)) {
                eventLabel.add(eventRegistration.Event_Instance_Title__c);
            }
            if (String.isNotBlank(eventRegistration.Date_Time_Text__c)) {
                eventLabel.add(eventRegistration.Date_Time_Text__c);
            }
            envelop += '        <typ:nameValuePairs>';
            envelop += '            <typ:name>EXT_TRANS_ID_LABEL</typ:name>';
            envelop += '            <typ:value>' + String.join(eventLabel, ' - ') + '</typ:value>';
            envelop += '        </typ:nameValuePairs>';
        }

        envelop += '        <typ:nameValuePairs>';
        envelop += '            <typ:name>POSTING_KEY</typ:name>';
        envelop += '            <typ:value>' + evtInfo.evtRegId + '</typ:value>';
        envelop += '        </typ:nameValuePairs>';
        envelop += '    </typ:generateSecureLinkTicketRequest>';
        envelop += '</soapenv:Body>';
        envelop += '</soapenv:Envelope>';

        // Get ride of multiples spaces maintained for readability above
        envelop = envelop.normalizeSpace();

        try {
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            r.setEndpoint(touchNetService);
            r.setHeader('Authorization', getAuthorizationHeader());
            r.setHeader('SOAPAction', touchNetService);
            r.setMethod('GET');
            r.setBody(envelop);
            HTTPResponse resp = h.send(r);
            DOM.Document doc = resp.getBodyDocument();
            DOM.XMLNode root = doc.getRootElement();
            walkThrough(root);
            ticket = mapResponse.get('ticket');
        } catch (Exception ex) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Error connecting payment gateway, please try later!!' + ex.getMessage()));
        }
    }

    private String getAuthorizationHeader() {
        Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();

        Blob headerValue = Blob.valueOf('Enrollment:m49g3TEXu');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        /*
        Blob headerValue = Blob.valueOf('Enrollment:' + SummitEventsSettings.Encryption_Key__c.substring(0,9));
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.Debug ('AUTH HEADER:  ' + authorizationHeader);
        */

        return authorizationHeader;

    }

    @TestVisible private String walkThrough(DOM.XMLNode node) {
        String result = '\n';
        if (node.getNodeType() == DOM.XMLNodeType.COMMENT) {
            return 'Comment (' + node.getText() + ')';
        }
        if (node.getNodeType() == DOM.XMLNodeType.TEXT) {
            return 'Text (' + node.getText() + ')';
        }
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            result += 'Element: ' + node.getName();
            if (node.getText().trim() != '') {
                result += ', text=' + node.getText().trim();
                if (!mapResponse.containsKey(node.getName())) {
                    mapResponse.put(node.getName(), node.getText().trim());
                }
            }
            if (node.getAttributeCount() > 0) {
                for (Integer i = 0; i < node.getAttributeCount(); i++) {
                    result += ', attribute #' + i + ':' + node.getAttributeKeyAt(i) + '=' + node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i));
                }
            }
            for (Dom.XMLNode child : node.getChildElements()) {
                result += walkThrough(child);
            }
            return result;
        }
        return '';  //should never reach here
    }

    public PageReference addPaymentInformation() {
        PageReference pageRedirect = null;
        Savepoint sp = null;
        doCRUD CRUDtoDo = new doCRUD();
        try {
            if (successReturnFromGateway) {
                String envelop = '';
                envelop += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://types.secureLink.touchnet.com">';
                envelop += '    <soapenv:Header/>';
                envelop += '    <soapenv:Body>';
                envelop += '        <typ:authorizeAccountRequest>';
                envelop += '            <typ:session>' + params.get('session_identifier') + '</typ:session>';
                envelop += '            <typ:invoiceNumber>' + evtInfo.evtRegId + '</typ:invoiceNumber>';
//                envelop += '            <typ:ancillaryData>EnrollmentRx Berkeley</typ:ancillaryData>';
//                envelop += '            <typ:application>EnrollmentRx</typ:application>';
                envelop += '            </typ:authorizeAccountRequest>';
                envelop += '    </soapenv:Body>';
                envelop += '</soapenv:Envelope>';
                HTTP h = new HTTP();
                HTTPRequest r = new HTTPRequest();
                r.setTimeout(120000); // timeout in milliseconds
                r.setEndpoint(touchNetService);
                r.setHeader('Authorization', getAuthorizationHeader());
                r.setHeader('SOAPAction', touchNetService);
                r.setMethod('GET');
                r.setBody(envelop);
                HTTPResponse resp = h.send(r);
                DOM.Document doc = resp.getBodyDocument();
                DOM.XMLNode root = doc.getRootElement();
                walkThrough(root);

                if (mapResponse.containskey('receiptNumber') && mapResponse.get('receiptNumber') != '') {
                    //feeTypeInfo = getTransactionFeeName();
                    sp = Database.setSavepoint();
                    Summit_Events_Payment__c paymentInformation = new Summit_Events_Payment__c();
                    paymentInformation.Event_Registration__c = evtInfo.evtRegId;
                    paymentInformation.Address_1__c = params.get('acct_addr');
                    paymentInformation.Address_2__c = params.get('acct_addr2');
                    paymentInformation.City__c = params.get('acct_city');
                    paymentInformation.Country__c = params.get('acct_country');
                    paymentInformation.Email_Address__c = params.get('acct_email_address');
                    paymentInformation.Account_Number__c = params.get('acct_number');
                    paymentInformation.Phone__c = params.get('acct_phone_mobile');
                    paymentInformation.State__c = params.get('acct_state');
                    paymentInformation.Zip__c = params.get('acct_zip');
                    paymentInformation.Card_Type__c = params.get('card_type');
                    paymentInformation.Name_On_Account__c = params.get('name_on_acct');
                    paymentInformation.Payment_Amount__c = decimal.valueOf(params.get('pmt_amt'));
                    paymentInformation.Payment_Method__c = params.get('pmt_method');
                    paymentInformation.Payment_Method_Expiration_Date__c = params.get('pmt_method_exp_date');
                    paymentInformation.Gateway_Session_Identifier__c = params.get('session_identifier');
                    paymentInformation.TouchnetReceiptNumber__c = mapResponse.get('receiptNumber');
                    paymentInformation.GatewayApprovalCode__c = mapResponse.get('approvalCode');
                    paymentInformation.Method_of_Payment__c = 'Credit Card';
                    paymentInformation.Payment_Status__c = 'Received';
                    paymentInformation.Payment_Received_Date__c = System.Now();

                    CRUDtoDo.createPaymentRecord(paymentInformation);

                    //Update fees to connect the payment record to them.
                    for (Integer fi = 0; fi < eventFees.size(); fi++) {
                        eventFees[fi].Summit_Events_Payment__c = paymentInformation.Id;
                        eventFees[fi].Summit_Events__c = evtInfo.evtId;
                    }
                    CRUDtoDo.updateFees(eventFees);

                    successReturnFromGateway = false;

                    pageRedirect = Page.SummitEventsConfirmation;
                    pageRedirect.setRedirect(true);
                    return pageRedirect;
                } else {
                    successReturnFromGateway = false;
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Transaction was not successful, please try again'));
                }
            } else {
                return pageRedirect;
            }
        } catch (Exception ex) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Payment can not be processed, please try later!!' + ex));
            successReturnFromGateway = false;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            toAddresses.add('dahl3702@stthomas.edu');

            // Sets the paramaters of the email
            email.setSubject('UST Events Transaction Error');
            email.setToAddresses(toAddresses);
            email.setPlainTextBody(ex.getStackTraceString() + '***' + ex.getMessage());

            // Sends the email
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    email
            });
            if (sp != null) {
                Database.rollback(sp);
            }
        }
        return pageRedirect;
    }

    private without sharing class doCRUD {

        public void updateFees(List<Summit_Events_Fee__c> upsertableFees) {
            try {
                upsert upsertableFees;
            } catch (Exception ex) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                ApexPages.addMessage(myMsg);
            }
        }

        public void createPaymentRecord(Summit_Events_Payment__c payment) {
            try {
                insert payment;
            } catch (Exception ex) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                ApexPages.addMessage(myMsg);
            }
        }
    }

}