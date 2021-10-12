/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 10/12/2021.
 */


public with sharing class Touchnet {

    public class SummitEventsInfo {
        public String audience { get; set; }
        public String instanceId { get; set; }
        public String eventId { get; set; }
        public String registrationId { get; set; }
        public String dt { get; set; }
    }

    public Touchnet() {
        
    }

    public SummitEventsInfo getSummitEventsInfo() {
        //{"audience":"High School Senior","instanceId":"a320m000000A5fOAAS","registrationId":"a350m0000008q63AAA,"eventId":"a330m0000001SOrAAM"}
        SummitEventsInfo eventInformation = new SummitEventsInfo();
        Id URLInstanceID = null;
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('instanceID'))) {
            try {
                URLInstanceID = (Id) String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('instanceID'));
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
        String jsonInput = getDecryptCookie();
        //See if a cookie exists
        if (String.isNotBlank(jsonInput)) {
            try {
                eventInformation = (SummitEventsInfo) JSON.deserialize(jsonInput, SummitEventsInfo.class);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

        return eventInformation;
    }

    public String getDecryptCookie() {
        String CookieName = 'SummitEvents';
        Cookie encodedCipherText = ApexPages.currentPage().getCookies().get(CookieName);
        if (encodedCipherText != null) {
            return decryptString(encodedCipherText.getValue(), true);
        }
        return '';
    }

    public String decryptString(String encryptedString, Boolean urlDecodeString) {
        String key = getCookieKey();
        if (String.isNotBlank(encryptedString) && String.isNotBlank(String.valueOf(key))) {
            if (urlDecodeString) {
                encryptedString = EncodingUtil.urlDecode(encryptedString, 'UTF-8');
            }
            try {
                Blob decrypted = Crypto.decryptWithManagedIV(
                        'AES256',
                        Blob.valueOf(key),
                        EncodingUtil.base64Decode(encryptedString)
                );
                return decrypted.toString();
            } catch (Exception e) {
                return '';
            }
        }
        return '';
    }

    public String getCookieKey() {
        String key = '';
        Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
        if (String.isNotBlank(SummitEventsSettings.Cookie_Encryption_Key__c)) {
            key = SummitEventsSettings.Cookie_Encryption_Key__c;
        }
        return key;
    }

}