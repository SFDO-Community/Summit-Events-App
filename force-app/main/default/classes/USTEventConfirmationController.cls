// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class USTEventConfirmationController {
    public USTEventShared USTShared = new USTEventShared();
    public USTEventShared.USTEventInfo evtInfo { get; set; }
    public UST_Event__C eventPage { get; set; }
    public UST_Event_Instance__c evtInstance { get; set; }
    public String templateSelected { get; set; }
    public String rName { get; set; }
    public String eventStartDateTimeCrumb {get;set;}
    public String locationCrumb { get; set; }
    public String dataLayerLocationType {get;set;}

    public USTEventConfirmationController() {

        templateSelected = USTShared.defaultTemplate;
        evtInfo = USTShared.getUSTEventInfo();

        if (!String.isEmpty(evtInfo.evtId)) {
            eventPage = [
                    SELECT Event_Confirmation_Title__c, Event_Name__c, Template__c, Event_Confirmation_Description__c, Event_Footer__c,
                            Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Confirmation_Registration__c,RecordType.Name,
                            Hand_Raise_Action__c
                    FROM UST_Event__c
                    WHERE Id = :evtinfo.evtId
            ][0];
            templateSelected = eventPage.Template__c;

            evtInstance = [
                    SELECT Instance_Title__c, Start_Date_Time__c, Event__r.Event_Name__c, End_Date_Time__c
                    FROM UST_Event_Instance__c
                    WHERE Id = :evtinfo.instanceID
                    LIMIT 1
            ];

            if(evtInstance.Start_Date_Time__c != null && evtInstance.End_Date_Time__c != null ) {
                eventStartDateTimeCrumb = evtInstance.Start_Date_Time__c.format('MMMM d, YYYY, h:mm a') + ' - ' + evtInstance.End_Date_Time__c.format('h:mm a');
            }

        }

    }

    public PageReference checkEventDetails() {
        //PageReference resultPageRef =  USTShared.checkForEvent();
        evtInfo = USTShared.getUSTEventInfo();
        locationCrumb = '';
        String eventTitle = '';
        if (!String.isBlank(evtInfo.evtRegId)) {
            /*UST_Event_Registration__c evtReg = [
                    SELECT Id, Status__c, Contact__c, Event_Name__c, Event_Instance_Title__c,
                            Registrant_First_Name__c, Registrant_Last_Name__c,Registrant_Gender__c,
                            Event_Instance_Date__c, Registrant_Street_1__c, Registrant_Street_2__c, Registrant_City__c,
                            Registrant_State__c, Registrant_Zip__c, Registrant_Email__c, Registrant_High_School_Grad_Year__c,
                            Registrant_Parent_First_Name__c, Registrant_Parent_Last_Name__c, Registrant_Parent_Email__c,
                            Registrant_Program_Interest__c, Registrant_Major__c, Registrant_Major_2__c, Registrant_Major_3__c,
                            Registrant_Major_4__c,
                            Registrant_Major__r.Program_Offered__r.School__c,
                            Registrant_Major_2__r.Program_Offered__r.School__c,
                            Registrant_Major_3__r.Program_Offered__r.School__c,
                            Registrant_Major_4__r.Program_Offered__r.School__c,
                            Registrant_Major__r.Program_Offered__c,
                            Registrant_Major_2__r.Program_Offered__c,
                            Registrant_Major_3__r.Program_Offered__c,
                            Registrant_Major_4__r.Program_Offered__c

                    FROM UST_Event_Registration__c
                    WHERE id = :evtInfo.evtRegId
            ][0];*/
            UST_Event_Registration__c evtReg = [
                    SELECT Id, Status__c, Contact__c, Event_Name__c, Event_Instance_Title__c,
                            Registrant_First_Name__c, Registrant_Last_Name__c,Registrant_Gender__c,
                            Event_Instance_Date__c, Registrant_Street_1__c, Registrant_Street_2__c, Registrant_City__c,
                            Registrant_State__c, Registrant_Zip__c, Registrant_Email__c, Registrant_High_School_Grad_Year__c,
                            Registrant_Parent_First_Name__c, Registrant_Parent_Last_Name__c, Registrant_Parent_Email__c,
                            Registrant_Program_Interest__c
                    FROM UST_Event_Registration__c
                    WHERE id = :evtInfo.evtRegId
            ][0];
            if (!String.isBlank(evtReg.Event_Instance_Title__c)) {
                eventTitle = evtReg.Event_Name__c + ' - ' + evtReg.Event_Instance_Title__c ;
            } else {
                eventTitle = evtReg.Event_Name__c;
            }
            evtReg.Status__c = 'Requested';
            upsert evtReg;
            //Remove the registration ID from the cookie so back button will redirect to the correct page.
            USTShared.createEncryptedCookie('{"audience":"' + evtInfo.audience + '","instanceID":"' + evtInfo.instanceID + '","evtRegId":"","evtId":"' + evtInfo.evtId + '"}', 'USTEvent');
            //create touchpoint

            if (eventPage.Hand_Raise_Action__c == 'Touchpoint' || String.isBlank(eventPage.Hand_Raise_Action__c)) {
                createTouchpoint(evtReg, eventTitle);
            }
        }

        return null;
    }

    private void createTouchpoint(UST_Event_Registration__c evtReg, String eventTitle) {
/*        Touch_Point__c tp = new Touch_Point__c();
        tp.Contact__c = evtReg.Contact__c;
        tp.Lead_Source__c = 'Event';
        tp.FirstName__c = evtReg.Registrant_First_Name__c;
        tp.LastName__c = evtReg.Registrant_Last_Name__c;
        tp.Gender__c = evtReg.Registrant_Gender__c;
        tp.Event_Name__c = eventTitle;
        tp.Event_date__c = evtReg.Event_Instance_Date__c;
        tp.Street__c = evtReg.Registrant_Street_1__c;
        tp.Street2__c = evtReg.Registrant_Street_2__c;
        tp.City__c = evtReg.Registrant_City__c;
        tp.State__c = evtReg.Registrant_State__c;
        tp.Zip_Postal_Code__c = evtReg.Registrant_Zip__c;
        tp.Email__c = evtReg.Registrant_Email__c;
        tp.HS_Grad_Year__c = evtReg.Registrant_High_School_Grad_Year__c;
        tp.Parent_1_First_Name__c = evtReg.Registrant_Parent_First_Name__c;
        tp.Parent_1_Last_Name__c = evtReg.Registrant_Parent_Last_Name__c;
        tp.Parent_1_Email__c = evtReg.Registrant_Parent_Email__c;
        tp.Major__c = evtReg.Registrant_Major__c;
        tp.Major2__c = evtReg.Registrant_Major_2__c;
        tp.Major3__c = evtReg.Registrant_Major_3__c;
        tp.Major4__c = evtReg.Registrant_Major_4__c;
        tp.School__c = evtReg.Registrant_Major__r.Program_Offered__r.School__c;
        tp.School2__c = evtReg.Registrant_Major_2__r.Program_Offered__r.School__c;
        tp.School3__c = evtReg.Registrant_Major_3__r.Program_Offered__r.School__c;
        tp.School4__c = evtReg.Registrant_Major_4__r.Program_Offered__r.School__c;
        tp.Program_Offered__c = evtReg.Registrant_Major__r.Program_Offered__c;
        tp.Program_Offered_2__c = evtReg.Registrant_Major_2__r.Program_Offered__c;
        tp.Program_Offered_3__c = evtReg.Registrant_Major_3__r.Program_Offered__c;
        tp.Program_Offered_4__c = evtReg.Registrant_Major_4__r.Program_Offered__c;
        tp.Country__c = evtReg.Registrant_Country__c;
        tp.State_Province__c = evtReg.Registrant_State_Province__c;
        tp.Postal_Code__c = evtReg.Registrant_Postal_Code__c;

        if (evtInfo.recordTypeName == 'Undergraduate' || String.isBlank(evtInfo.recordTypeName)) {
            List<EnrollmentrxRx__Program_Offered__c> UgProgOffered = [SELECT Id, EnrollmentrxRx__Program_Catalog__c, School__c FROM EnrollmentrxRx__Program_Offered__c WHERE Name = 'Undergraduate' AND Status__c = 'Active'];
            if (UgProgOffered.size() > 0) {
                tp.Program_Offered__c = UgProgOffered[0].Id;
                tp.Degree_Sought_Program_Catalog__c = UgProgOffered[0].EnrollmentrxRx__Program_Catalog__c;
                tp.School__c = UgProgOffered[0].School__c;
            }
        } else if (evtInfo.recordTypeName == 'Graduate') {
            List<EnrollmentrxRx__Program_Catalog__c> UgProgOffered = [SELECT Name, Id FROM EnrollmentrxRx__Program_Catalog__c WHERE Name = 'Graduate'];
            if (UgProgOffered.size() > 0) {
                tp.Degree_Sought_Program_Catalog__c = UgProgOffered[0].Id;
            }
        }

        insert tp;*/
    }
}