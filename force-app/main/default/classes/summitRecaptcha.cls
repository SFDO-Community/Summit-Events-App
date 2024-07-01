/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 7/1/2024.
 */


public with sharing class summitRecaptcha {

    private static final Summit_Events_Settings__c recaptchaConfig = Summit_Events_Settings__c.getOrgDefaults();

    public static Boolean isReCAPTCHAValid(String tokenFromClient) {
        String SECRET_KEY = recaptchaConfig.reCAPTCHA_Secret_Key__c;
        String RECAPTCHA_SERVICE_URL = recaptchaConfig.reCAPTCHA_Endpoint__c;
        Decimal RECAPTCHAScore = recaptchaConfig.reCAPTCHA_v3_Score__c;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(RECAPTCHA_SERVICE_URL + '?secret=' + SECRET_KEY + '&response=' + tokenFromClient);
        request.setMethod('POST');
        request.setHeader('Content-Length', '0');
        HttpResponse response = http.send(request);
        Map<String, Object> mapOfBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        System.debug('response.getBody(): ' + JSON.serializePretty(response.getBody()));
        Boolean success = (Boolean) mapOfBody.get('success');
        Decimal score = (Decimal) mapOfBody.get('score');
        if(score < RECAPTCHAScore){
            success = false;
        }
        return success;
    }

    @TestVisible
    private static String remoteHost(final Map<String, String> headersMap) {
        String ret = '127.0.0.1';
        if (headersMap.get('x-original-remote-addr') != null) {
            ret = headersMap.get('x-original-remote-addr');
        } else if (headersMap.get('X-Salesforce-SIP') != null) {
            ret = headersMap.get('X-Salesforce-SIP');
        }
        return ret;
    }

}