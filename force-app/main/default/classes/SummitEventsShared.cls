// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsShared {

    public class SummitEventsInfo {
        public String audience { get; set; }
        public String instanceId { get; set; }
        public String eventId { get; set; }
        public String registrationId { get; set; }
        public String dt { get; set; }
    }

    public SummitEventsShared() {

    }

    public String getTemplate(String templateName) {
        List<String> namespaceTemplate = new List<String>{
                'GeneralSLDS',
                'crowncollege2020',
                'OPUSTemplate2018',
                'CastorTemplate2017'
        };
        if (String.isNotBlank(templateName)) {
            if (!namespaceTemplate.contains(templateName)) {
                templateName = 'c__' + templateName;
            }
        } else {
            templateName = 'GeneralSLDS';
        }
        return templateName;
    }

    public Map<String, PageReference> getPageFlow(Id eventId, String instanceTitle, pageReference currentPage) {

        //Get the url without anchors
        String currentUrl = currentPage.getUrl();
        currentUrl = currentUrl.replace('#', '?');
        List<String> currentUrlSplit = currentUrl.split('\\?');
        currentUrl = currentUrlSplit[0];

        currentUrlSplit = currentUrl.split('/');
        String currentPageName = currentUrlSplit[currentUrlSplit.size() - 1];

        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace + '__';
        }

        Map<String, PageReference> pageMovement = New Map<String, PageReference>();
        Map<String, String> currentPageParameters = currentPage.getParameters();
        List<String> pagesInEvent = new List<String>();
        Map<String, PageReference> allPageReferences = new Map<String, PageReference>();
        allPageReferences.put(namespace + 'SummitEventsRegister', Page.SummitEventsRegister);
        allPageReferences.put(namespace + 'SummitEventsRegisterGuests', Page.SummitEventsRegisterGuests);
        allPageReferences.put(namespace + 'SummitEventsRegisterAppointments', Page.SummitEventsRegisterAppointments);
        allPageReferences.put(namespace + 'SummitEventsDonation', Page.SummitEventsDonation);
        allPageReferences.put(namespace + 'SummitEventsSubmit', Page.SummitEventsSubmit);
        allPageReferences.put(namespace + 'SummitEventsConfirmation', Page.SummitEventsConfirmation);

        List<Summit_Events_Appointment_Type__c> appointmentTypes = [
                SELECT Id, Chosen_State__c, Restrict_To_Instance_Title__r.Instance_Title__c
                FROM Summit_Events_Appointment_Type__c
                WHERE Summit_Events__c = :eventId
                AND Chosen_State__c != 'Added but not shown'
                AND (
                        Restrict_To_Instance_Title__r.Instance_Title__c = :instanceTitle
                        OR Restrict_To_Instance_Title__r.Instance_Title__c = NULL)
                WITH SECURITY_ENFORCED
        ];

        Summit_Events__c eventInformation = [
                SELECT Id, Display_Optional_Donation__c, Display_Guest_Registration__c
                FROM Summit_Events__c
                WHERE Id = :eventId
                WITH SECURITY_ENFORCED
        ];

        pagesInEvent.add(namespace + 'SummitEventsRegister');
        //check for if event has guests

        if (eventInformation.Display_Guest_Registration__c) {
            pagesInEvent.add(namespace + 'SummitEventsRegisterGuests');
        }

        //check for if event has appointments
        if (appointmentTypes.size() > 0) {
            pagesInEvent.add(namespace + 'SummitEventsRegisterAppointments');
        }

        //check for if event has donation
        if (eventInformation.Display_Optional_Donation__c) {
            pagesInEvent.add(namespace + 'SummitEventsDonation');
        }

        //If event has more than 1 item in list then submit page
        if (pagesInEvent.size() > 0) {
            pagesInEvent.add(namespace + 'SummitEventsSubmit');
        }
        pagesInEvent.add(namespace + 'SummitEventsConfirmation');

        Integer currentPageLocation = 0;
        for (Integer x = 0; x < pagesInEvent.size(); x++) {
            if (currentPageName.equalsIgnoreCase(pagesInEvent[x])) {
                currentPageLocation = x;
            }
        }

        System.debug(pagesInEvent);
        System.debug(currentPage);
        System.debug(currentPageLocation);

        if (currentUrl.equalsIgnoreCase(allPageReferences.get(namespace + 'SummitEventsRegister').getUrl())) {
            pageMovement.put('Previous', Page.SummitEventsRegister);
        } else {
            pageMovement.put('Previous', allPageReferences.get(pagesInEvent[currentPageLocation - 1]));
        }

        if (currentUrl.equalsIgnoreCase(allPageReferences.get(namespace + 'SummitEventsConfirmation').getUrl())) {
            pageMovement.put('Previous', Page.SummitEventsRegister);
            pageMovement.put('Next', Page.SummitEventsRegister);
        } else {
            pageMovement.put('Next', allPageReferences.get(pagesInEvent[currentPageLocation + 1]));
        }

        List<String> validParameters = new List<String>{
                'adminopen', 'instanceID', 'audience'
        };
        for (String parameterKey : currentPageParameters.keySet()) {
            System.debug(currentPageParameters);
            if (validParameters.contains(parameterKey)) {
                for (String key : pageMovement.keySet()) {
                    PageReference addBackParameters = pageMovement.get(key);
                    addBackParameters.getParameters().put(parameterKey, currentPageParameters.get(parameterKey));
                }
            }
        }

        return pageMovement;

    }

    public SummitEventsInfo getSummitEventsInfo() {
        //{"audience":"High School Senior","instanceId":"a320m000000A5fOAAS","registrationId":"a350m0000008q63AAA,"eventId":"a330m0000001SOrAAM"}
        SummitEventsInfo eventInformation = new SummitEventsInfo();
        String URLAudience = '';
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('audience'))) {
            URLAudience = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('audience'));
        }
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

        if (!String.isBlank(URLAudience)) {
            eventInformation.audience = URLAudience;
        }

        //check if URL instance has changed
        if (URLInstanceID != null) {
            if (URLInstanceID != eventInformation.instanceId) {
                eventInformation.instanceId = URLInstanceID;
                eventInformation.registrationId = '';
                if (!String.isBlank(URLAudience)) {
                    eventInformation.audience = URLAudience;
                }
            }
        }

        //check if registration id is there and whether status it is set to registered. IF so reset cookie if it is.
        if (String.isNotBlank(eventInformation.registrationId)) {
            Summit_Events_Registration__c evtReg = [
                    SELECT Status__c
                    FROM Summit_Events_Registration__c
                    WHERE Id = :eventInformation.registrationId
                    WITH SECURITY_ENFORCED
            ];
            if (evtReg.Status__c != 'Started') {
                eventInformation.registrationId = '';
            }
        }

        if (String.isBlank(eventInformation.eventId) && String.isNotBlank(eventInformation.instanceId)) {
            Summit_Events_Instance__c instanceInfo = [
                    SELECT Id, Event__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :eventInformation.instanceId
                    WITH SECURITY_ENFORCED
            ];
            if (instanceInfo != null) {
                eventInformation.eventId = instanceInfo.Event__c;
            }
        }

        return eventInformation;
    }

    public PageReference checkForEvent() {
        PageReference myVFPage;
        SummitEventsInfo eventInformation = getSummitEventsInfo();

        Boolean onRegistrationPage = false;
        String[] currentURL = ApexPages.currentPage().getUrl().split('\\?');
        if (currentURL[0].endsWithIgnoreCase('SummitEventsRegister')) {
            onRegistrationPage = true;
        }

        //Make sure there is a cookie encryption key. If no make one.
        crudToDo doCRUD = new crudToDo();
        doCRUD.setCookieKey();

        //Get home page link if it exists
        String eventHomeLink = '';
        Id newInstanceId = eventInformation.instanceId;
        String newRegistrationId = eventInformation.registrationId;

        if (String.isNotBlank(newInstanceId)) {
            Summit_Events_Instance__c eventPage = [
                    SELECT Event__r.Event_Home_Link_URL__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :newInstanceId
                    WITH SECURITY_ENFORCED
            ];
            if (eventPage != null) {
                eventHomeLink = eventPage.Event__r.Event_Home_Link_URL__c;
            }
        }

        //Get community base URL from custom settings
        Summit_Events_Settings__c myUserSetting = Summit_Events_Settings__c.getInstance(UserInfo.getUserId());
        String communityBaseURL = myUserSetting.Community_Base_URL__c;

        if (!communityBaseURL.endsWith('/')) {
            communityBaseURL += '/';
        }

        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace + '__';
        }

        String newUrl = '';

        if (onRegistrationPage) {
            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('instanceID'))) {
                Id URLInstanceID = null;
                try {
                    URLInstanceID = (Id) String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('instanceID'));
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
                if (newInstanceId != null && !newInstanceId.equals(URLInstanceID)) {
                    newInstanceId = URLInstanceID;
                    newUrl = communityBaseURL + namespace + 'SummitEventsRegister?instanceID=' + URLInstanceID;
                }
            }
        } else if (String.isBlank(newRegistrationId) && !onRegistrationPage) {
            if (String.isNotBlank(eventHomeLink)) {
                newUrl = eventHomeLink;
            } else if (String.isNotBlank(newInstanceId)) {
                newUrl = communityBaseURL + namespace + 'SummitEventsRegister?instanceID=' + newInstanceId;
            } else {
                newUrl = communityBaseURL + namespace + 'SummitEvents';
            }
        }
        if (String.isNotBlank(newUrl)) {
            myVFPage = new PageReference(newUrl);
            myVFPage.setRedirect(true);
            newRegistrationId = '';
            createEncryptedCookie(eventInformation.audience, newInstanceId, eventInformation.eventId, newRegistrationId);
        } else if (onRegistrationPage) {
            createEncryptedCookie(eventInformation.audience, newInstanceId, eventInformation.eventId, newRegistrationId);
        }

        return myVFPage;
    }

    public String createEncryptedCookie(String audience, String instanceId, String eventId, String registrationId) {
        //Check everything to not let nulls through to JSON string
        audience = (String.isNotBlank(audience) && !audience.equalsIgnoreCase('null')) ? audience : '';
        instanceId = (String.isNotBlank(instanceId) && !instanceId.equalsIgnoreCase('null')) ? instanceId : '';
        eventId = (String.isNotBlank(eventId) && !eventId.equalsIgnoreCase('null')) ? eventId : '';
        registrationId = (String.isNotBlank(registrationId) && !registrationId.equalsIgnoreCase('null')) ? registrationId : '';
        String CookieValue = encryptString('{"audience":"' + audience + '","instanceId":"' + instanceId + '","eventId":"' + eventId + '","registrationId":"' + registrationId + '","dt":"' + String.valueOf(Datetime.now()) + '"}');
        Cookie SummitEventsCookie = new Cookie('SummitEvents', CookieValue, null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{
                SummitEventsCookie
        });
        return CookieValue;
    }

    public String getDecryptCookie() {
        String CookieName = 'SummitEvents';
        Cookie encodedCipherText = ApexPages.currentPage().getCookies().get(CookieName);
        if (encodedCipherText != null) {
            return decryptString(encodedCipherText.getValue(), true);
        }
        return '';
    }

    public String encryptString(String toEncrypt) {
        String key = getCookieKey();
        String encryptedText = '';
        if (String.isNotBlank(String.valueOf(key))) {
            if (String.isNotBlank(toEncrypt)) {
                Blob data = Blob.valueOf(toEncrypt);
                Blob encrypted = Crypto.encryptWithManagedIV('AES256', Blob.valueOf(key), data);
                encryptedText = EncodingUtil.base64Encode(encrypted);
                encryptedText = EncodingUtil.urlEncode(encryptedText, 'UTF-8');

            }
        }
        return encryptedText;
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

    public Boolean isEventClosed(Summit_Events__c eventPage, Summit_Events_Instance__c evtInstance) {
        //Figure out if the event is closed.
        Boolean eventIsClosed = false;

        Date compareCloseDate = Date.today();

        if (eventPage.Close_Event_Days_Before__c != null && eventPage.Close_Event_Days_Before__c != 0) {
            compareCloseDate = compareCloseDate.addDays((Integer.valueOf(eventPage.Close_Event_Days_Before__c) + 1));
        }

        if (eventPage.Keep_Registration_Open_During_Event__c) {
            if (evtInstance.Instance_Start_Date__c < compareCloseDate && evtInstance.Instance_End_Date__c != compareCloseDate) {
                eventIsClosed = true;
            }
        } else if (evtInstance.Instance_Start_Date__c <= compareCloseDate) {
            eventIsClosed = true;
        }

        if (evtInstance.Current_Available_Capacity__c <= 0 || evtInstance.Active_Status__c != 'Active') {
            eventIsClosed = true;
        }

        return eventIsClosed;
    }

    public String getTimeZonePick(String pickListTimeZone) {
        if (String.isNotBlank(pickListTimeZone)) {
            if (pickListTimeZone.length() > 4) {
                pickListTimeZone = pickListTimeZone.substring(pickListTimeZone.indexOf('(') + 1, pickListTimeZone.indexOf(')'));
                return pickListTimeZone;
            }
        }
        return '';
    }

    public TimeZone getTimeZone(String timeZoneId) {
        TimeZone tz = null;
        if (String.isNotBlank(timeZoneId)) {
            tz = TimeZone.getTimeZone(timeZoneId);
        }
        return tz;
    }

    public String getTimeZoneDisplay(String timeZonePick, Boolean shortDisplay) {
        String displayName = '';
        if (String.isNotBlank(timeZonePick)) {
            timeZonePick = getTimeZonePick(timeZonePick);
            TimeZone tz = getTimeZone(timeZonePick);
            if (tz != null) {
                displayName = tz.getDisplayName();
                //remove all parenthesis items
                displayName = displayName.replaceAll('(\\(([^\\)]+)\\))', '');
                displayName = displayName.trim();
            }
            if (shortDisplay) {
                String[] displayNameWordList = displayName.split(' ');
                String shortDisplayOut = '';
                for (String word : displayNameWordList) {
                    shortDisplayOut += word.substring(0, 1);
                }
                return shortDisplayOut;
            }
        }
        return displayName;
    }

    public String navBreadcrumbBuilder(Summit_Events_Instance__c eventInstance) {
        String instanceDate = '';

        if (eventInstance.Instance_Start_Date__c != null && eventInstance.Instance_End_Date__c != null) {
            //Get timezone to check if offset is not 0 (not GMT)
            TimeZone tz = UserInfo.getTimeZone();
            Integer timezoneOffset = tz.getOffset(Datetime.now());

            Datetime convertedStartDate = Datetime.newInstance(
                    eventInstance.Instance_Start_Date__c,
                    eventInstance.Instance_Start_Time__c
            );
            Datetime convertedEndDate = Datetime.newInstanceGmt(
                    eventInstance.Instance_End_Date__c,
                    eventInstance.Instance_End_Time__c
            );

            //If the user is logged in and offset for user is not GMT than adjust datetime to act like GMT by removing the offset
            if (timezoneOffset != 0) {
                convertedStartDate = convertedStartDate.addSeconds(-(timezoneOffset) / 1000);
                convertedEndDate = convertedEndDate.addSeconds(-(timezoneOffset) / 1000);
            }

            String monthStart = convertedStartDate.format('MMMM');
            String monthEnd = convertedEndDate.format('MMMM');
            String yearStart = String.valueOf(eventInstance.Instance_Start_Date__c.year());
            String yearEnd = String.valueOf(eventInstance.Instance_End_Date__c.year());
            String dayNameStart = convertedStartDate.format('EEEE');
            String dayNameEnd = convertedEndDate.format('EEEE');
            String dayStart = convertedStartDate.format('dd');
            String dayEnd = convertedEndDate.format('dd');
            String timeStart = '';
            if (eventInstance.Instance_Start_Time__c != null) {
                timeStart = formatTime(eventInstance.Instance_Start_Time__c, false);
            }
            String timeEnd = '';
            if (eventInstance.Instance_End_Time__c != null) {
                timeEnd = formatTime(eventInstance.Instance_End_Time__c, false);
            }
            instanceDate = dayNameStart + ', ' + monthStart + ' ' + dayStart;
            if (eventInstance.Instance_Start_Date__c < eventInstance.Instance_End_Date__c) {
                if (yearStart != yearEnd) {
                    instanceDate += ', ' + yearStart;
                }
                instanceDate += ', ' + timeStart + ' - ' + dayNameEnd + ', ' + monthEnd + ', ' + dayEnd + ', ' + timeEnd;
                if (yearStart == yearEnd) {
                    instanceDate += ', ' + yearStart;
                } else {
                    instanceDate += ', ' + yearEnd;
                }
            } else {
                instanceDate += ', ' + yearStart + ', ' + timeStart + ' - ' + timeEnd;
            }

            if (String.isNotBlank(eventInstance.Instance_Time_Zone__c)) {
                String timeZoneDisplay = getTimeZoneDisplay(eventInstance.Instance_Time_Zone__c, true);
                instanceDate += ' ' + timeZoneDisplay;
            }

        }
        return instanceDate;
    }

    public Datetime adjustForTimeZone(Datetime dt, String timezoneString) {
        timezoneString = getTimeZonePick(timezoneString);
        //Get the current GMT time and adjust for our timezone
        //tz = TimeZone.getTimeZone('America/Chicago');
        //Timezone adjustment example below:
        //Datetime NowDate = Datetime.now();
        //NowDate = NowDate.addSeconds(tz.getOffset(NowDate)/1000);
        //Central Daylight Time (America/Chicago)
        TimeZone tz = TimeZone.getTimeZone(timezoneString);
        dt = dt.addSeconds(tz.getOffset(dt) / 1000);
        return dt;
    }

    public Datetime convertDateToDatetime(Date dateIn, Time timeIn, String timezoneString) {
        if (timeIn == null) {
            timeIn = Time.newInstance(1, 12, 3, 4);
        }
        Datetime converted = Datetime.newInstance(dateIn.year(), dateIn.month(), dateIn.day(), timeIn.hour(), timeIn.minute(), timeIn.second());
        if (String.isNotBlank(timezoneString)) {
            converted = adjustForTimeZone(converted, timezoneString);
        }
        return converted;
    }

    public String formatTime(Time myTime, Boolean military) {
        String formatTime = '';
        if (myTime.hour() >= 13 && myTime.hour() > 0 && !military) {
            formatTime = String.valueOf(myTime.hour() - 12);
        } else {
            formatTime = String.valueOf(myTime.hour());
            if (myTime.hour() < 10 && military) {
                formatTime = '0' + formatTime;
            }
        }
        formatTime += ':';
        if (myTime.minute() < 10) {
            formatTime += '0' + String.valueOf(myTime.minute());
        } else {
            formatTime += String.valueOf(myTime.minute());
        }
        if (!military) {
            if (myTime.hour() >= 12) {
                formatTime += ' PM';
            } else {
                formatTime += ' AM';
            }
        }
        return formatTime;
    }

    public Map<String, String> getDependentSelectOptions(String parentObjName, String parentFieldName, String dependentFieldName, String parentValue) {
        Map<String, String> dependentItems = new Map<String, String>();
        if (null != parentObjName && null != parentFieldName && null != dependentFieldName && null != parentValue) {
            String namespace = SummitEventsNamespace.getNamespace();
            if (String.isNotBlank(namespace)) {
                namespace = namespace + '__';
            }

            Schema.DescribeFieldResult dependentField;
            Integer parentValueIndex = -1;

            //FIRST get the Parent PL's index value
            Schema.DescribeSObjectResult objectMeta = Schema.describeSObjects(new String[]{
                    namespace + parentObjName
            })[0];
            Schema.SObjectField[] fields = objectMeta.fields.getMap().values();
            for (Schema.SObjectField f : fields) {
                Schema.DescribeFieldResult d = f.getDescribe();
                String fieldName = d.getName().toLowerCase();
                String ftype = String.valueOf(d.getType()).toLowerCase();
                if (fieldName.equals(namespace + parentFieldName.toLowerCase()) && ('picklist'.equals(ftype) || 'multipicklist'.equals(ftype))) {
                    Schema.PicklistEntry[] pplvalues = d.getPicklistValues();
                    for (Integer i = 0; i < pplvalues.size(); i++) {
                        if (parentValue.equals(pplvalues[i].getValue())) {
                            parentValueIndex = i;
                            break;
                        }
                    }
                }
                if (fieldName.equals(namespace + dependentFieldName.toLowerCase()) && ('picklist'.equals(ftype) || 'multipicklist'.equals(ftype))) {
                    dependentField = d;
                }
            }

            //2nd get the dependent PL values mapped to the target parent PL's value
            if (-1 != parentValueIndex && null != dependentField) {
                Schema.PicklistEntry[] plValues = dependentField.getPicklistValues();
                for (PicklistEntry plv : plValues) {
                    String jsonstr = JSON.serialize(plv);
                    Map<String, String> jMap = (Map<String, String>) JSON.deserialize(jsonstr, Map<String, String>.class);
                    String validFor = jMap.get('validFor');
                    String plvalue = jMap.get('value');
                    String plId = jMap.get('id');
                    if (null != validFor && !''.equals(validFor.trim()) && isDependentValue(parentValueIndex, validFor)) {
                        dependentItems.put(plvalue, plvalue);
                    }
                }
            }
        }
        return dependentItems;
    }

    private static Boolean isDependentValue(Integer index, String validFor) {
        String decoded = EncodingUtil.convertToHex(EncodingUtil.base64Decode(validFor));
        Integer bits = hexToInt(decoded);
        return ((bits & (128 >> Math.mod(index, 8))) != 0);
    }

    private static Integer hexToInt(String hex) {

        Map<String, Integer> hMap = new Map<String, Integer>{
                '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9, 'A' => 10, 'B' => 11, 'C' => 12, 'D' => 13, 'E' => 14, 'F' => 15, 'a' => 10, 'b' => 11, 'c' => 12, 'd' => 13, 'e' => 14, 'f' => 15
        };

        Integer retVal = 0;
        for (Integer i = 0; i < hex.length(); i += 2) {
            retVal += (hMap.get(hex.substring(i, i + 1)) * 16) + (hMap.get(hex.substring(i + 1, i + 2)));
        }
        return retVal;
    }

    public String getCookieKey() {
        String key = '';
        Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
        if (String.isNotBlank(SummitEventsSettings.Cookie_Encryption_Key__c)) {
            key = SummitEventsSettings.Cookie_Encryption_Key__c;
        }
        return key;
    }

    private without sharing class crudToDo {
        public void setCookieKey() {
            Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
            if (String.isBlank(SummitEventsSettings.Cookie_Encryption_Key__c)) {
                Blob cryptoKey = Crypto.generateAesKey(256);
                String encryptionString = EncodingUtil.base64Encode(cryptoKey).substring(0, 32);
                SummitEventsSettings.Cookie_Encryption_Key__c = encryptionString;
                update SummitEventsSettings;
            }
        }
    }

}