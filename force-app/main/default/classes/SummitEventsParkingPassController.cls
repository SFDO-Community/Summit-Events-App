// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsParkingPassController {
    public SummitEventsParkingPassController() {
        //No constructor logic needed
    }

/* DEPRECIATED 8/12/2025
   public String firstName { get; set; }
    public String warning { get; set; }
    public Summit_Events_Registration__c visitor { get; set; }
    public SummitEventsInfo eventInformation { get; set; }

    public SummitEventsParkingPassController() {
        warning = 'Sorry, this parking permit has expired or invalid.';
        String eventParameter = ApexPages.currentPage().getParameters().get('eventInfo');
        visitor = new Summit_Events_Registration__c();

        if (!String.isBlank(eventParameter)) {
            String decryptedParameter = SummitEventsShared.decryptString(eventParameter, false);

            if (String.isNotBlank(decryptedParameter)) {
                try {
                    eventInformation = (SummitEventsInfo) JSON.deserialize(decryptedParameter, SummitEventsInfo.class);
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }

                try {
                    visitor = [
                            SELECT Event_Instance_Start_Date__c, Event_Instance_Time_Zone__c, Event_Instance_Start_Date_Text__c, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Preferred_First_Name__c, Status__c
                            FROM Summit_Events_Registration__c
                            WHERE Id = :eventInformation.registrationId
                            WITH SECURITY_ENFORCED
                    ];
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }

                Datetime todayDateTime = SummitEventsShared.adjustForTimeZone(Datetime.now(), visitor.Event_Instance_Time_Zone__c);
                Date todayDate = Date.newInstance(todayDateTime.year(), todayDateTime.month(), todayDateTime.day());

                if (todayDate <= visitor.Event_Instance_Start_Date__c && visitor.Status__c != 'Started' && visitor.Status__c != 'Cancelled') {
                    if (!String.isBlank(visitor.Registrant_Preferred_First_Name__c)) {
                        firstName = visitor.Registrant_Preferred_First_Name__c;
                    } else {
                        firstName = visitor.Registrant_First_Name__c;
                    }
                    warning = '';
                }
            }
        }
    }
    */
}