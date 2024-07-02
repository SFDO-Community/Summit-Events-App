/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 7/1/2024.
 */


@IsTest
private class summitRecaptcha_TEST {
    @TestSetup static void init() {
        insert new Summit_Events_Settings__c(reCAPTCHA_Public_Key__c = 'public', reCAPTCHA_Secret_Key__c = 'private');
    }

    @IsTest static void testVerify() {
        Test.setMock(HttpCalloutMock.class, new summitRecaptcha_TEST.GoogleHTTPCalloutMock());
        Test.startTest();

/*        summitEventsRecaptcha.isReCAPTCHAValid('response', new Map<String, String>{
                'X-Salesforce-SIP' => 'Salesforce'
        });*/
        Test.stopTest();
    }

    @IsTest static void testVerifyOverload() {
        Test.setMock(HttpCalloutMock.class, new summitRecaptcha_TEST.GoogleHTTPCalloutMock());
        Test.startTest();
        summitEventsRecaptcha.isReCAPTCHAValid('response');
        Test.stopTest();
    }

    @IsTest static void testRemoteHost() {
        summitEventsRecaptcha.remoteHost(new Map<String, String>{
                'x-original-remote-addr' => ''
        });
        summitEventsRecaptcha.remoteHost(new Map<String, String>{
                'X-Salesforce-SIP' => ''
        });
    }
//
//    @IsTest static void testVerifyError() {
//        summitEventsRecaptcha.isReCAPTCHAValid('response', new Map<String, String>{
//                'X-Salesforce-SIP' => 'Salesforce'
//        });
//    }

    public class GoogleHTTPCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        public HttpResponse respond(HttpRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":"true", "score": 0.5}');
            res.setStatusCode(200);
            return res;
        }
    }
}