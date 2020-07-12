// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsShared {
    //private key for encryption
    Private Blob key; 
    Private Summit_Events_Settings__c settings;
    Public String defaultTemplate = 'CastorTemplate2017';

    public class SummitEventsInfo {
        public String audience { get; set; }
        public String instanceID { get; set; }
        public String evtRegId { get; set; }
        public String evtId { get; set; }
    }

    public SummitEventsShared() {
        settings = Summit_Events_Settings__c.getInstance();
        key = Blob.valueOf(settings.Encryption_Key__c);
    }

    public SummitEventsInfo getSummitEventsInfo() {
        //{"audience":"High School Senior","instanceID":"a320m000000A5fOAAS","evtRegId":"a350m0000008q63AAA,"evtId":"a330m0000001SOrAAM"}
        String jsonInput = '';
        SummitEventsInfo evtInfo = new SummitEventsInfo();
        String URLaudience = ApexPages.currentPage().getParameters().get('audience');
        String URLinstanceID = ApexPages.currentPage().getParameters().get('instanceID');
        jsonInput = getDecryptCookie('SummitEvents');
        if (!String.isBlank(jsonInput)) {
            try {
                evtInfo = (SummitEventsInfo) JSON.deserialize(jsonInput, SummitEventsInfo.class);
                if (!String.isBlank(URLaudience)) {
                    evtInfo.audience = URLaudience;
                }
            } catch (Exception e) {
                //Cookie was un-serializable so delete it
                Cookie deleteCookie = new Cookie('SummitEvents', '', null, 0, false); // Note the 0 to delete the cookie
                ApexPages.currentPage().setCookies(new Cookie[]{
                        deleteCookie
                });
            }
        }
        if (!String.isBlank(URLinstanceID)) {
            if (URLinstanceID.length() > 14) {
                if (URLinstanceID != evtInfo.instanceID) {
                    //event instance has changed so delete cookie and reestablish with new instance
                    Cookie deleteCookie = new Cookie('SummitEvents', '', null, 0, false); // Note the 0 to delete the cookie
                    ApexPages.currentPage().setCookies(new Cookie[]{
                            deleteCookie
                    });
                    evtInfo = new SummitEventsInfo();
                    evtInfo.instanceID = URLinstanceID;
                    if (!String.isBlank(URLaudience)) {
                        evtInfo.audience = URLaudience;
                    }
                    String eventCookie = '{"audience":"' + evtInfo.audience + '","instanceID":"' + evtInfo.instanceID + '","evtRegId":"COMING","evtId":"' + evtInfo.evtId + '"}';
                    System.Debug('COOKIE 1: ' + eventCookie);
                    createEncryptedCookie(eventCookie, 'SummitEvents');
                }
            }
        }

        //check if regid is there  and whether status it is set to registered. IF so reset cookie if it is.
        if (!String.isBlank(evtInfo.evtRegId) && evtInfo.evtRegId != 'COMING') {
            Summit_Events_Registration__c evtReg = [SELECT Status__c FROM Summit_Events_Registration__c WHERE ID = :evtInfo.evtRegId][0];
            if (evtReg.Status__c != 'Started') {
                //Registration is complete and a new form should be generated.
                String eventCookie2 = '{"audience":"' + evtInfo.audience + '","instanceID":"' + evtInfo.instanceID + '","evtRegId":"","evtId":"' + evtInfo.evtId + '"}';
                createEncryptedCookie(eventCookie2, 'SummitEvents');
            }
        }

        //If eventInfo is null return to default page (add to event definition object.

        return evtInfo;
    }

    public PageReference checkForEvent() {
        SummitEventsInfo evt = new SummitEventsInfo();
        PageReference myVFPage = null;
        evt = getSummitEventsInfo();

        Summit_Events_Settings__c myUserSetting = Summit_Events_Settings__c.getInstance(UserInfo.getUserId());
        String communityBaseURL = myUserSetting.Community_Base_URL__c;

        if ((String.isBlank(evt.evtRegId) && !ApexPages.currentPage().getUrl().containsIgnoreCase('SummitEventsRegister')) || String.isBlank(evt.instanceID)) {
            //Reset the cookie to prevent loop on registration page
            Cookie deleteCookie = new Cookie('SummitEvents', '', null, 0, false); // Note the 0 to delete the cookie
            ApexPages.currentPage().setCookies(new Cookie[]{
                    deleteCookie
            });

            if (!String.isBlank(evt.evtId)) {
                Summit_Events__c eventPage = [SELECT Event_Home_Link_URL__c FROM Summit_Events__c WHERE Id = :evt.evtId][0];
                if (!String.isBlank(eventPage.Event_Home_Link_URL__c)) {
                    myVFPage = new PageReference(eventPage.Event_Home_Link_URL__c);
                } else if (String.isNotBlank(evt.instanceID) && !ApexPages.currentPage().getUrl().containsIgnoreCase('SummitEventsRegister')) {
                    myVFPage = new PageReference(communityBaseURL + 'SummitEventsRegister?instanceID=' + evt.instanceID);
                } else {
                    myVFPage = new PageReference(communityBaseURL + 'SummitEvents');
                }
            } else {
                myVFPage = new PageReference(communityBaseURL + 'SummitEvents');
            }
            myVFPage.setRedirect(true);
        }
        return myVFPage;
    }

    public String createEncryptedCookie(String CookieValue, String CookieName) {
        Blob data = Blob.valueOf(CookieValue);
        Blob encrypted = Crypto.encryptWithManagedIV('AES256', key, data);
        String encodedCipherText = EncodingUtil.base64Encode(encrypted);
        encodedCipherText = EncodingUtil.urlEncode(encodedCipherText, 'UTF-8');
        Cookie SummitEventsCookie = new Cookie(CookieName, encodedCipherText, null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{
                SummitEventsCookie
        });
        return encodedCipherText;
    }

    public String getDecryptCookie(String CookieName) {

        Cookie encodedCipherText = ApexPages.currentPage().getCookies().get(CookieName);
        if (encodedCipherText != null) {
            try {
                Blob decrypted = Crypto.decryptWithManagedIV(
                        'AES256',
                        key,
                        EncodingUtil.base64Decode(
                                EncodingUtil.urlDecode(encodedCipherText.getValue(), 'UTF-8')
                        )
                );
                return decrypted.toString();
            } catch (Exception e) {
                return '';
            }
        }
        return '';
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

    public Datetime convertDateToDatetime(Date dateIn, Time timeIn) {
        if (timeIn == null) {
            timeIn = Time.newInstance(1, 12, 3, 4);
        }
        Datetime converted = Datetime.newInstance(dateIn.year(), dateIn.month(), dateIn.day(), timeIn.hour(), timeIn.minute(), timeIn.second());
        return converted;
    }

    public String navBreadcrumbBuilder(Summit_Events_Instance__c eventInstance, Boolean dateTimeOnly) {
        String instanceDate = '';
        if (eventInstance.Instance_Start_Date__c != null && eventInstance.Instance_End_Date__c != null) {
            Datetime convertedStartDate = convertDateToDatetime(eventInstance.Instance_Start_Date__c, null);
            Datetime convertedEndDate = convertDateToDatetime(eventInstance.Instance_End_Date__c, null);
            String monthStart = convertedStartDate.format('MMMM');
            String monthEnd = convertedEndDate.format('MMMM');
            String yearStart = convertedStartDate.format('YYYY');
            String yearEnd = convertedEndDate.format('YYYY');
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
            if (dateTimeOnly) {
                return instanceDate;
            }
        }

        String crumb = '';
        crumb += '<nav role="navigation" aria-label="Breadcrumbs">';
        crumb += '   <ol class="slds-breadcrumb slds-list--horizontal">';
        if (String.isNotBlank(eventInstance.Event__r.Event_Name__c)) {
            crumb += '       <li class="slds-breadcrumb__item slds-text-title--caps"><a href="javascript:void(0);">' + eventInstance.Event__r.Event_Name__c + '</a></li>';
        }
        if (String.isNotBlank(eventInstance.Instance_Title__c)) {
            crumb += '       <li class="slds-breadcrumb__item slds-text-title--caps"><a href="javascript:void(0);">' + eventInstance.Instance_Title__c + '</a></li>';
        }
        if (String.isNotBlank(instanceDate)) {
            crumb += '       <li class="slds-breadcrumb__item slds-text-title--caps"><a href="javascript:void(0);">' + instanceDate + '</a></li>';
        }
        crumb += '   </ol>';
        crumb += '</nav>';
        return crumb;
    }

    public DateTime adjustForCentralTime(Datetime dt) {
        //Get the current GMT time and adjust for our timezone
        //tz = TimeZone.getTimeZone('America/Chicago');
        //Timezone adjustment example below:
        //Datetime NowDate = Datetime.now();
        //NowDate = NowDate.addSeconds(tz.getOffset(NowDate)/1000);
        TimeZone tz = TimeZone.getTimeZone('America/Chicago');
        dt = dt.addSeconds(tz.getOffset(dt) / 1000);
        return dt;
    }

    public String formatTime(Time myTime, boolean military) {
        String formatTime = '';
        if (myTime.hour() >= 13 && myTime.hour() > 0 && !military) {
            formatTime = String.valueOf(myTime.hour() - 12);
        } else {
            formatTime = String.valueOf(myTime.hour());
            if (myTime.hour() < 10) {
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
                String fieldname = d.getName().toLowerCase();
                String ftype = String.valueOf(d.getType()).toLowerCase();
                if (fieldname.equals(namespace + parentFieldName.toLowerCase()) && ('picklist'.equals(ftype) || 'multipicklist'.equals(ftype))) {
                    Schema.PicklistEntry[] pplvalues = d.getPicklistValues();
                    for (Integer i = 0; i < pplvalues.size(); i++) {
                        if (parentValue.equals(pplvalues[i].getValue())) {
                            parentValueIndex = i;
                            break;
                        }
                    }
                }
                if (fieldname.equals(namespace + dependentFieldName.toLowerCase()) && ('picklist'.equals(ftype) || 'multipicklist'.equals(ftype))) {
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


}