@RestResource(urlMapping='/tnx')
global without sharing class SummitEventsTouchNetuPayPost {

    global static final String postBackPath = '/tnx';

    @HttpPost
    global static String processPostBack() {
        RestRequest req = RestContext.request;
        // TODO test if query string parameters can overwrite/supplement POST body params
        // TODO remove these debug statements?
        system.debug(String.format('Summit Events TouchNet Postback {0} Received POST from {1}',new String[]{postBackPath,req.remoteAddress}));
        system.debug('Summit Events TouchNet Postback ' + postBackPath + ' request headers: '+ JSON.serializePretty(req.headers));
        system.debug('Summit Events TouchNet Postback ' + postBackPath + ' request parameters: '+ JSON.serializePretty(req.params));
        Map<String,String> params = req.params;
        Summit_Events_Settings__c settings = Summit_Events_Settings__c.getInstance();
        String postingKey = settings.Upay_Posting_Key__c;
        String validationKey = settings.Upay_Validation_Key__c;
        // TODO figure out how to handle an actual posting key mismatch -- log the Payment with an error status/message?
        if (String.isNotBlank(postingKey) && postingKey != params.get('posting_key')) {
            system.debug('posting_key ERROR received '+ params.get('posting_key') +' should be '+ postingKey);
            // Whoever sent an invalid posting key doesn't need to know it is invalid
            return 'Success';
        }
        String evtRegId = params.get('EXT_TRANS_ID');
        List<Summit_Events_Registration__c> getReg = [SELECT Id,Event_Instance__c,Event__c FROM Summit_Events_Registration__c WHERE Id=:evtRegId];
        if (getReg.size() != 1) {
            // TODO long-term, how much error logging is needed? Is a custom application log appropriate for TouchNet connectivity issues?
            system.debug(LoggingLevel.ERROR, 'Invalid TouchNet uPay postback EXT_TRANS_ID '+evtRegId);
            // Whoever sent an invalid transaction Id doesn't need to know it is invalid
            return 'Success';
        }
        Summit_Events_Registration__c reg = getReg[0];

        Summit_Events_Payment__c paymentInformation = new Summit_Events_Payment__c();
        paymentInformation.Event_Registration__c = reg.Id;
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
        // I don't see session_identifier in the TouchNet docs
        paymentInformation.Gateway_Session_Identifier__c = params.get('session_identifier');
        paymentInformation.TouchnetReceiptNumber__c = params.get('sys_tracking_id');
        paymentInformation.GatewayApprovalCode__c = params.get('tpg_trans_id');
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
            WHERE Event_Registration__c = :reg.Id
        ];

        if (eventFees.size() > 0) {
            //Update fees to connect the payment record to them.
            for (Summit_Events_Fee__c fee:eventFees) {
                fee.Summit_Events_Payment__c = paymentInformation.Id;
                fee.Summit_Events__c = reg.Event__c;
            }
            update eventFees;
        } else {
            system.debug(LoggingLevel.WARN, 'No related Event Fees found for Payment Postback: '+ paymentInformation.Id);
        }

        return 'Success';
    }

}
