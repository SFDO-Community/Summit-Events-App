/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 4/25/2024.
 */

@RestResource(UrlMapping='/summiteventsqrcode/*')
global with sharing class SummitEventQRCode {

    @HttpGet
    global static void SummitEventQRCode() {
        String requestEndpoint = '/summiteventsqrcode';
        requestEndpoint = '?test=test';
        String qrcode = '';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + requestEndpoint);
        request.setMethod('GET');
        request.setHeader('Cookie','sid='+UserInfo.getSessionId());
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200 ) {
            String responseBody = response.getBody();
            System.debug('Response Content: ' + responseBody);
            try {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                Map<String, Object> mainResults = (Map<String, Object>)(results.get('main'));
                //qrcode = String.valueOf(mainResults.get('qrcode'));
            } catch (Exception e) {
                // Handle JSON parsing errors or other exceptions
                System.debug('Error parsing JSON: ' + e.getMessage());
            }
        } else {
            // Handle non-200 HTTP status codes
            System.debug('HTTP Request Error: Status Code ' + response.getStatusCode());
            // You can also log the response body here for further analysis
            System.debug('Response Content: ' + response.getBody());
        }
    }
}