@RestResource(urlMapping='/txy')
global without sharing class SummitEventsTouchNetSuccess {

    @HttpPost
    global static void processUserPostBack() {
        RestRequest req = RestContext.request;
        // TODO test if query string parameters can overwrite/supplement POST body params
        system.debug('/txy Received POST from '+req.remoteAddress);
        system.debug('/txy request headers: '+ JSON.serializePretty(req.headers));
        system.debug('/txy request parameters: '+ JSON.serializePretty(req.params));
        Map<String,String> params = req.params;
        SummitEventSettings__c settings = Summit_Events_Settings__c.getInstance();
        // TODO decrypt the cookie to check that the registration ID matches EXT_TRANS_ID
        SummitEventsShared SEShared = new SummitEventsShared();
        String postingKey = settings.Upay_Posting_Key;
        String validationKey = settings.Upay_Validation_Key;
        // TODO figure out how to handle an actual posting key mismatch -- log the Payment with an error status/message?
        if (String.isNotBlank(postingKey) && postingKey != params.get('posting_key')) {
            system.debug('posting_key ERROR received '+ params.get('posting_key') +' should be '+ postingKey);
        }
        Id evtRegId = params.get('EXT_TRANS_ID');
        // TODO Error handling for bad EXT_TRANS_ID and checking it against the cookie to ensure same "session"
        Summit_Events_Registration__c reg = [SELECT Id,Event_Instance__c,Event__c FROM Summit_Events_Registration__c WHERE Id=:evtRegId];

        Summit_Events_Payment__c paymentInformation = new Summit_Events_Payment__c();
        paymentInformation.Event_Registration__c = evtRegId;
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
        // sys_tracking_id is Marketplace internal id (order ID) displayed to customer
        //     on uPay receipt page
        // pmt_status = success or cancelled
        // tpg_trans_id is payment gateway reference number

        insert paymentInformation;

        List<Summit_Events_Fee__c> eventFees = [
            SELECT Name, Event_Fee__c, Event_Fee_Attribute__c, Description__c, Event_Fee_Type__c, Summit_Events__c, Event_Appointment_Type__c,
                    Event_Appointment_Type__r.Title__c, Event_Fee_Attribute__r.Name
            FROM Summit_Events_Fee__c
            WHERE Event_Registration__c = :evtInfo.EvtRegId
        ];

        //Update fees to connect the payment record to them.
        for (Summit_Events_Fee__c fee:eventFees) {
            fee.Summit_Events_Payment__c = paymentInformation.Id;
            fee.Summit_Events__c = evtInfo.evtId;
        }
        update eventFees;

        RestContext.response.headers.put('Location','/SummitEventsConfirmation');
        RestContext.response.responseBody='';
        RestContext.response.statusCode = 302;
        return;
    }

}
