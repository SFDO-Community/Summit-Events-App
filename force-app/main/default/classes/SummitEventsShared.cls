// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsShared {

    public SummitEventsShared() {
    }

    public static String getTemplate(String templateName) {
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

    public static Map<String, PageReference> getPageFlow(Id eventId, String instanceTitle, PageReference currentPage, Date startDate, Date endDate) {

        //Get the url without anchors
        String currentUrl = currentPage.getUrl();
        currentUrl = currentUrl.replace('#', '?');
        List<String> currentUrlSplit = currentUrl.split('\\?');
        currentUrl = currentUrlSplit[0];
        currentUrlSplit = currentUrl.split('/');
        String currentPageName = currentUrlSplit[currentUrlSplit.size() - 1];

        String namespace = SummitEventsNamespace.StrTokenNSPrefix('');

        String dayOfWeek = convertDateToDatetime(startDate, null, '').format('EEEE');

        Integer appointmentTypes = SummitEventsReadShared.getAppointmentTypeCount(eventId, instanceTitle, startDate, endDate, dayOfWeek);

        Integer additionalQuestions = SummitEventsReadShared.getAdditionalQuestionsCount(eventId);

        Integer guestQuestions = SummitEventsReadShared.getGuestQuestionsCount(eventId);

        Summit_Events__c eventInformation = SummitEventsReadShared.getEventById(eventId);

        Map<String, PageReference> pageMovement = new Map<String, PageReference>();
        Map<String, String> currentPageParameters = currentPage.getParameters();
        List<String> pagesInEvent = new List<String>();
        Map<String, PageReference> allPageReferences = new Map<String, PageReference>();
        allPageReferences.put(namespace + 'SummitEventsRegister', Page.SummitEventsRegister);
        allPageReferences.put(namespace + 'SummitEventsAdditionalQuestions', Page.SummitEventsAdditionalQuestions);
        allPageReferences.put(namespace + 'SummitEventsRegisterGuests', Page.SummitEventsRegisterGuests);
        allPageReferences.put(namespace + 'SummitEventsRegisterAppointments', Page.SummitEventsRegisterAppointments);
        allPageReferences.put(namespace + 'SummitEventsDonation', Page.SummitEventsDonation);
        allPageReferences.put(namespace + 'SummitEventsSubmit', Page.SummitEventsSubmit);

        //If payment gateway exist add it here
        if (String.isNotBlank(eventInformation.Payment_Gateway__c) && eventInformation.Payment_Gateway__c != 'No Gateway') {
            allPageReferences.put('c__' + eventInformation.Payment_Gateway__c, new PageReference(Site.getBaseSecureUrl() + '/c__' + eventInformation.Payment_Gateway__c));
        }

        allPageReferences.put(namespace + 'SummitEventsConfirmation', Page.SummitEventsConfirmation);

        pagesInEvent.add(namespace + 'SummitEventsRegister');

        //Check for additional questions

        if (additionalQuestions > 0) {
            pagesInEvent.add(namespace + 'SummitEventsAdditionalQuestions');
        }

        //check for if event has guests
        if (eventInformation.Display_Guest_Registration__c && guestQuestions > 0) {
            pagesInEvent.add(namespace + 'SummitEventsRegisterGuests');
        }

        //check for if event has appointments
        if (appointmentTypes > 0) {
            pagesInEvent.add(namespace + 'SummitEventsRegisterAppointments');
        }

        //check for if event has donation
        if (eventInformation.Display_Optional_Donation__c) {
            pagesInEvent.add(namespace + 'SummitEventsDonation');
        }

        //If event has more than 1 item in list then submit page
        if (pagesInEvent.size() > 1 && !(pagesInEvent.size() == 2 && pagesInEvent.contains(namespace + 'SummitEventsRegister') && pagesInEvent.contains(namespace + 'SummitEventsAdditionalQuestions'))) {
            pagesInEvent.add(namespace + 'SummitEventsSubmit');
        }

        //If payment gateway exist add it here
        if (String.isNotBlank(eventInformation.Payment_Gateway__c) && eventInformation.Payment_Gateway__c != 'No Gateway') {
            pagesInEvent.add('c__' + eventInformation.Payment_Gateway__c);
        }

        pagesInEvent.add(namespace + 'SummitEventsConfirmation');

        Integer currentPageLocation = 0;
        for (Integer x = 0; x < pagesInEvent.size(); x++) {
            if (currentPageName.equalsIgnoreCase(pagesInEvent[x])) {
                currentPageLocation = x;
            }
        }

        if (currentUrl.equalsIgnoreCase(allPageReferences.get(namespace + 'SummitEventsRegister').getUrl()) || pagesInEvent == null || currentPageLocation == 0) {
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
            if (validParameters.contains(parameterKey)) {
                for (String key : pageMovement.keySet()) {
                    PageReference addBackParameters = pageMovement.get(key);
                    addBackParameters.getParameters().put(parameterKey, currentPageParameters.get(parameterKey));
                }
            }
        }
        return pageMovement;
    }

    public static SummitEventsInfo getSummitEventsInfo() {
        //{"audience":"High School Senior","instanceId":"a320m000000A5fOAAS","registrationId":"a350m0000008q63AAA,"eventId":"a330m0000001SOrAAM","valid":"true"}
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
        if (String.isNotBlank(eventInformation.registrationId) && String.isBlank(eventInformation.valid)) {
            Summit_Events_Registration__c evtReg = new Summit_Events_Registration__c();
            evtReg = SummitEventsReadShared.getRegistrationById(eventInformation.registrationId);
            if (evtReg.Status__c != 'Started' || evtReg == null) {
                eventInformation.registrationId = '';
            }
        }

        if (String.isBlank(eventInformation.eventId) && String.isNotBlank(eventInformation.instanceId)) {
            Summit_Events_Instance__c instanceInfo = SummitEventsReadShared.getInstanceById(eventInformation.instanceId);

            if (instanceInfo != null) {
                eventInformation.eventId = instanceInfo.Event__c;
            }
        }

        return eventInformation;
    }

    public static PageReference checkForEvent(String pageName) {
        PageReference myVFPage;
        SummitEventsInfo eventInformation = getSummitEventsInfo();

        Boolean onRegistrationPage = false;

        if (pageName.endsWithIgnoreCase('register')) {
            onRegistrationPage = true;
        }

        //Make sure there is a cookie encryption key. If no make one.
        crudToDo doCRUD = new crudToDo();
        doCRUD.setCookieKey();

        //Get home page link if it exists
        String eventHomeLink = '';
        Id newInstanceId = null;
        try {
            newInstanceId = eventInformation.instanceId;
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

        String newRegistrationId = eventInformation.registrationId;

        if (String.isNotBlank(eventInformation.valid) && eventInformation.valid.equalsIgnoreCase('false') && !pageName.equalsIgnoreCase('confirmation')) {
            newRegistrationId = '';
        }

        if (String.isNotBlank(newInstanceId)) {
            Summit_Events_Instance__c eventPage = SummitEventsReadShared.getInstanceById(newInstanceId);
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

        String namespace = SummitEventsNamespace.StrTokenNSPrefix('');

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
            createEncryptedCookie(eventInformation.audience, newInstanceId, eventInformation.eventId, newRegistrationId, true);
        } else if (onRegistrationPage) {
            createEncryptedCookie(eventInformation.audience, newInstanceId, eventInformation.eventId, newRegistrationId, true);
        }

        return myVFPage;
    }

    public static String createEncryptedCookie(String audience, String instanceId, String eventId, String registrationId, Boolean valid) {
        //Check everything to not let nulls through to JSON string
        return createEncryptedCookieWithNow(audience, instanceId, eventId, registrationId, Datetime.now(), valid);
    }

    public static String createEncryptedCookieWithNow(String audience, String instanceId, String eventId, String registrationId, Datetime nowTime, Boolean valid) {
        //Check everything to not let nulls through to JSON string
        audience = (String.isNotBlank(audience) && !audience.equalsIgnoreCase('null')) ? audience : '';
        instanceId = (String.isNotBlank(instanceId) && !instanceId.equalsIgnoreCase('null')) ? instanceId : '';
        eventId = (String.isNotBlank(eventId) && !eventId.equalsIgnoreCase('null')) ? eventId : '';
        registrationId = (String.isNotBlank(registrationId) && !registrationId.equalsIgnoreCase('null')) ? registrationId : '';
        valid = (valid != null) ? valid : false;
        String CookieValue = encryptString('{"audience":"' + audience + '","instanceId":"' + instanceId + '","eventId":"' + eventId + '","registrationId":"' + registrationId + '","dt":"' + String.valueOf(nowTime) + '","valid":"' + String.valueOf(valid) + '"}');
        Cookie SummitEventsCookie = new Cookie('SummitEvents', CookieValue, null, -1, true, 'Strict');
        ApexPages.currentPage().setCookies(new Cookie[]{
                SummitEventsCookie
        });
        return CookieValue;
    }

    public static String getDecryptCookie() {
        String CookieName = 'SummitEvents';
        Cookie encodedCipherText = ApexPages.currentPage().getCookies().get(CookieName);
        if (encodedCipherText != null) {
            return decryptString(encodedCipherText.getValue(), true);
        }
        return '';
    }

    public static String encryptString(String toEncrypt) {
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

    public static String decryptString(String encryptedString, Boolean urlDecodeString) {
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

    public static Boolean isBoolean(String booleanString) {
        Boolean b;
        booleanString = booleanString.toLowerCase();
        if (booleanString == 'true') {
            b = true;
        } else if (booleanString == 'false') {
            b = false;
        } else if (booleanString == '0') {
            b = false;
        } else if (booleanString == '1') {
            b = true;
        }
        return b;
    }

    public static Boolean isEventClosed(Summit_Events_Instance__c evtInstance, String masterEventStatus) {
        // Figure out if the event is closed.
        Boolean eventIsClosed = false;
        if (ApexPages.currentPage() != null && String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
            Boolean adminOpen = isBoolean(ApexPages.currentPage().getParameters().get('adminopen'));
            eventIsClosed = !adminOpen;
        } else {
            Datetime dt = Datetime.now();
            Time compareCloseTime = dt.timeGmt();
            String timeZonePick = getTimeZonePick(evtInstance.Instance_Time_Zone__c);
            TimeZone tz = getTimeZone(timeZonePick);
            dt = dt.addSeconds(tz.getOffset(dt) / 1000);
            compareCloseTime = compareCloseTime.addMilliseconds(tz.getOffset(dt));
            if (evtInstance.Registration_Close_Date__c <= dt.date()) {
                if (evtInstance.Registration_Close_Date__c == dt.date()) {
                    if (evtInstance.Registration_Close_Time__c < compareCloseTime) {
                        eventIsClosed = true;
                    }
                } else {
                    eventIsClosed = true;
                }
            }

            if (evtInstance.Current_Available_Capacity__c <= 0 || evtInstance.Active_Status__c != 'Active' || masterEventStatus != 'Active') {
                eventIsClosed = true;
            }
        }

        return eventIsClosed;
    }

    public static String getTimeZonePick(String pickListTimeZone) {
        if (String.isNotBlank(pickListTimeZone)) {
            if (pickListTimeZone.length() > 4) {
                pickListTimeZone = pickListTimeZone.substring(pickListTimeZone.indexOf('(') + 1, pickListTimeZone.indexOf(')'));
                return pickListTimeZone;
            }
        }
        return '';
    }

    public static TimeZone getTimeZone(String timeZoneId) {
        TimeZone tz = null;
        if (String.isNotBlank(timeZoneId)) {
            tz = TimeZone.getTimeZone(timeZoneId);
        }
        return tz;
    }

    public static String navBreadcrumbBuilder(Summit_Events_Instance__c eventInstance) {
        String instanceDate = '';

        if (eventInstance.Instance_Start_Date__c != null && eventInstance.Instance_End_Date__c != null) {

            //Get timezone to check if offset is not 0 (not GMT)
            String timeZonePick = getTimeZonePick(eventInstance.Instance_Time_Zone__c);
            TimeZone tz = getTimeZone(timeZonePick);
            Integer timezoneOffset = tz.getOffset(Datetime.now());

            Datetime convertedStartDate = Datetime.newInstance(
                    eventInstance.Instance_Start_Date__c,
                    eventInstance.Instance_Start_Time__c
            );

            Datetime convertedEndDate = Datetime.newInstance(
                    eventInstance.Instance_End_Date__c,
                    eventInstance.Instance_End_Time__c
            );

            convertedStartDate = convertedStartDate.addSeconds(timezoneOffset / 1000);
            convertedEndDate = convertedEndDate.addSeconds(timezoneOffset / 1000);

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
                instanceDate += ', ' + timeStart + ' - ' + dayNameEnd + ', ' + monthEnd + ' ' + dayEnd + ', ';
                if (yearStart == yearEnd) {
                    instanceDate += yearStart;
                } else {
                    instanceDate += yearEnd;
                }
                instanceDate += ', ' + timeEnd;
            } else {
                instanceDate += ', ' + yearStart + ', ' + timeStart + ' - ' + timeEnd;
            }

            if (String.isNotBlank(eventInstance.Instance_Time_Zone__c)) {
                String timeZoneDisplay = convertedStartDate.format('z', timeZonePick);
                instanceDate += ' ' + timeZoneDisplay;
            }

        }
        return instanceDate;
    }

    public static Datetime adjustForTimeZone(Datetime dt, String timezoneString) {
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

    public static Datetime convertDateToDatetime(Date dateIn, Time timeIn, String timezoneString) {
        if (timeIn == null) {
            timeIn = Time.newInstance(1, 12, 3, 4);
        }
        Datetime converted = Datetime.newInstance(dateIn.year(), dateIn.month(), dateIn.day(), timeIn.hour(), timeIn.minute(), timeIn.second());
        if (String.isNotBlank(timezoneString)) {
            converted = adjustForTimeZone(converted, timezoneString);
        }
        return converted;
    }

    public static String formatTime(Time myTime, Boolean military) {
        String formatTime = '';
        Integer hour = myTime.hour();
        Integer minute = myTime.minute();
        if (hour == 0 && !military) {
            formatTime = '12';
        } else if (hour >= 13 && hour >= 0 && !military) {
            if (myTime.hour() == 0) {

            } else {
                formatTime = String.valueOf(hour - 12);
            }
        } else {
            formatTime = String.valueOf(hour);
            if (hour < 10 && military) {
                formatTime = '0' + formatTime;
            }
        }
        formatTime += ':';
        if (minute < 10) {
            formatTime += '0' + String.valueOf(minute);
        } else {
            formatTime += String.valueOf(minute);
        }
        if (!military) {
            if (hour >= 12) {
                formatTime += ' PM';
            } else {
                formatTime += ' AM';
            }
        }
        return formatTime;
    }

    public static String removeHTMLandEscape(String incomingString, Boolean escapeHTML) {
        if (String.isNotBlank(incomingString)) {
            incomingString = incomingString.replaceAll('<[^>]+>', '').trim();
            if (escapeHTML) {
                incomingString = incomingString.escapeHtml4();
            }
        }
        return incomingString;
    }

    public static List<SelectOption> createPicklistsFromStrings(String returnSepStringList, String returnSepStringList2) {
        List<SelectOption> cpl = new List<SelectOption>();
        cpl.add(new SelectOption('', 'Select...'));
        List<String> splitList = new List<String>();
        splitList.addAll(sanitizePicklistString(returnSepStringList));
        splitList.addAll(sanitizePicklistString(returnSepStringList2));
        for (String p : splitList) {
            p = p.replaceAll('[^a-zA-Z0-9@<>?&;:\\[\\]!-./ ]', '');
            if (String.isNotBlank(p)) {
                cpl.add(new SelectOption(p, p));
            }
        }
        return cpl;
    }

    public static List<String> sanitizePicklistString(String picklistString) {
        List<String> pickList = new List<String>();
        if (String.isNotBlank(picklistString)) {
            picklistString = picklistString.trim();
            picklistString = picklistString.replace('\n\n', '\n');
            pickList = picklistString.split('\n');
        }
        return pickList;
    }

    // Test to see if person accounts are enabled.
    public static Boolean personAccountsEnabled()
    {
        return Schema.SObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
    }

    //Method to test object and field availability for current user (Guest user)
    public static String checkFieldGuestAccess(String objectApiName, String fieldName, String requiredFieldType, Boolean testCreatable, String qualifierLabel) {
        String returnError = '';
        DescribeFieldResult fieldDescribe;
        DescribeSObjectResult objDescribe;
        SObject objInstance;
        Type schemaType;
        if (String.isBlank(qualifierLabel)) {
            qualifierLabel = '';
        }
        try {
            schemaType = Type.forName(objectApiName);
            objInstance = (SObject) schemaType.newInstance();
            objDescribe = objInstance.getSObjectType().getDescribe();
        } catch (Exception ex) {
            returnError = qualifierLabel + objectApiName + ' may not exist or is inaccessible. ';
        }

        if (String.isBlank(returnError)) {
            if (!objDescribe.isAccessible()) {
                returnError += qualifierLabel + objectApiName + ' is not accessible (check sharing rules and permissions). ';
            }
        }
        if (String.isNotBlank(fieldName) && String.isBlank(returnError)) {
            try {
                Map<String, SObjectField> fields = objDescribe.fields.getMap();
                fieldDescribe = fields.get(fieldName).getDescribe();
            } catch (Exception ex) {
                returnError += qualifierLabel + 'Field ' + fieldName + ' may not exist. ';
            }

            if (String.isBlank(returnError)) {
                if (!fieldDescribe.isAccessible()) {
                    returnError += qualifierLabel + 'Field ' + fieldName + ' is not accessible by guest user.';
                }
            }
/*            if (String.isBlank(returnError) && testCreatable) {
                if (!fieldDescribe.isCreateable()) {
                    returnError += qualifierLabel + 'Field ' + fieldName + ' is not writable. ';
                }
            }*/
            if (String.isBlank(returnError) && String.isNotBlank(requiredFieldType)) {
                if (!String.valueOf(fieldDescribe.getType()).equalsIgnoreCase(requiredFieldType)) {
                    returnError += qualifierLabel + 'Field ' + fieldName + ' is not the required field type ' + requiredFieldType + '. ';
                }
            }
        }
        return returnError;
    }

    public static Map<String, String> getDependentSelectOptions(String parentObjName, String parentFieldName, String dependentFieldName, String parentValue) {
        Map<String, String> dependentItems = new Map<String, String>();
        if (null != parentObjName && null != parentFieldName && null != dependentFieldName && null != parentValue) {
            String namespace = SummitEventsNamespace.StrTokenNSPrefix('');

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

    public static String getCookieKey() {
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