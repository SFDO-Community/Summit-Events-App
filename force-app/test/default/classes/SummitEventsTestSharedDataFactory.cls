// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 4/2/2019.

@IsTest
public with sharing class SummitEventsTestSharedDataFactory {


    public static List<Summit_Events_Instance__c> createTestEvent() {

        Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
        if (String.isBlank(SummitEventsSettings.Cookie_Encryption_Key__c)) {
            Blob cryptoKey = Crypto.generateAesKey(256);
            String encryptionString = EncodingUtil.base64Encode(cryptoKey).substring(0, 32);
            SummitEventsSettings.Cookie_Encryption_Key__c = encryptionString;
            insert SummitEventsSettings;
        }

        Summit_Events__c testEvent = new Summit_Events__c();

        //Create event
        testEvent = new Summit_Events__c(
                Name = 'Test Event',
                Event_Status__c = 'Active',
                Event_Name__c = 'Test Event',
                Start_Date__c = Date.today().addDays(-20),
                End_Date__c = Date.today().addDays(20),
                Template__c = 'GeneralSLDS',
                Close_Event_Days_Before__c = 0,
                Location_Title__c = 'A location',
                Location_Map_Link__c = 'Map Link 1',
                Location_Address__c = '123 Electric Ave.',
                Location_Type__c = 'On-Site'
        );
        insert testEvent;

        List<Summit_Events_Instance__c> seaTestInstances = new List<Summit_Events_Instance__c>();

        for (Integer x = -1; x < 10; x++) {
            Summit_Events_Instance__c seaInstance = new Summit_Events_Instance__c();
            seaInstance.Event__c = testEvent.Id;
            seaInstance.Instance_Title__c = testEvent.Name + ' Session ' + x;
            seaInstance.Instance_Start_Date__c = Date.today().addDays(x);
            seaInstance.Instance_Start_Time__c = Time.newInstance(8, 0, 0, 0);
            seaInstance.Instance_End_Date__c = Date.today().addDays(x);
            seaInstance.Instance_End_Time__c = Time.newInstance(14, 0, 0, 0);
            seaInstance.Instance_Time_Zone__c = 'Central Daylight Time (America/Chicago)';
            seaInstance.Active_Status__c = 'Active';
            seaInstance.Capacity__c = 500;
            seaInstance.Location_Title_Override__c = 'A location';
            seaTestInstances.add(seaInstance);
        }

        insert seaTestInstances;

//        Id classRecType = Schema.SObjectType.Summit_Events_Host__c.getRecordTypeInfosByName().get('Class').getRecordTypeId();
//        List<Summit_Events_Host__c> testHosts = new List<Summit_Events_Host__c>();
//        testHosts.add(new Summit_Events_Host__c(
//                Event_Instance__c = testInstance.Id,
//                First_Name__c = 'Host1',
//                Last_Name__c = 'Host1',
//                RecordTypeId = classRecType,
//                Preferred_Title__c = 'Mr.',
//                Gender__c = 'M',
//                Department__c = 'Host Dept 1',
//                Course_Name__c = 'Host 1 Course',
//                Max_Available__c = 10,
//                Location__c = 'TEST LOCATION 1'
//        ));
//
//        testHosts.add(new Summit_Events_Host__c(
//                Event_Instance__c = testInstance.Id,
//                First_Name__c = 'Host2',
//                Last_Name__c = 'Host2',
//                RecordTypeId = classRecType,
//                Preferred_Title__c = 'Mr.',
//                Gender__c = 'M',
//                Department__c = 'Host Dept 2',
//                Course_Name__c = 'Host 2 Course',
//                Max_Available__c = 10,
//                Assigned__c = 10,
//                Location__c = 'TEST LOCATION 2'
//        ));
//        insert testHosts;

        return seaTestInstances;

    }

    public static Summit_Events_Email__c createTestTransactionEmail(Summit_Events_Instance__c evtInst, String status, String subStatus) {

        // Add email on requested status
        Summit_Events_Email__c testEvtEmail = new Summit_Events_Email__c(
                Action_Status__c = status,
                Action_Sub_status__c = subStatus,
                BCC_Email__c = 'thad+test@valleyhill.net,thad+test2@valleyhill.net',
                Email_Subject__c = 'TEST EMAIL',
                Email_Content__c = 'Name: {!Registrant_First_Name__c} {!Registrant_Last_Name__c} Event Date: {!Event_Instance_Date_Time_Formatted__c} Event Session: {!Instance_Title__c} Attendees:{!Total_Number_of_Guests__c} Email: {!Registrant_Email__c} High School: {!Registrant_High_School__c}',
                Letterhead_HTML__c = '<html><style> p { margin-top: 0px; margin-bottom: 0px;} </style><body id="body" style=" background-color:#FFFFFF; color:#FFFFFF; " ><center><table cellpadding="0" width="500" cellspacing="0" height="450">  <tr valign="top">    <td id="header" style=" background-color:#FFFFFF; color:#FFFFFF; height:100px; " ><img src="https://c.cs65.visual.force.com/servlet/servlet.ImageServer?id=0150m000000AN8V&oid=00D0m000000Cra6"/>    </td>  </tr><tr valign="top"><td id="accent1" style=" background-color:#FFFFFF; color:#FFFFFF; height:5px; " ></tr><tr valign="top"><td height="300" style=" background-color:#FFFFFF; font-family:arial; font-size:12pt; color:#000000; " ><table border="0" cellpadding="5" width="550" cellspacing="5" height="400"><tr valign="top" height="400"><td id="main" style=" background-color:#FFFFFF; font-family:arial; font-size:12pt; color:#000000; " >[[DONT_DELETE_CONTENT_HERE]]</td></tr></table></td></tr><tr valign="top"><td id="accent2" style=" background-color:#FFFFFF; color:#FFFFFF; height:5px; " ></tr>  <tr valign="top">    <td id="footer" style=" background-color:#FFFFFF; color:#FFFFFF; height:100px; " >    </td>  </tr><tr valign="top"><td id="accent3" style=" background-color:#FFFFFF; color:#FFFFFF; height:5px; " ></tr></table></center></body>',
                Event__c = evtInst.Event__c
        );

        List<OrgWideEmailAddress> oweList = [SELECT Id, Address,DisplayName, IsAllowAllProfiles FROM OrgWideEmailAddress WHERE IsAllowAllProfiles = TRUE];

        if (oweList.size() > 0) {
            testEvtEmail.Org_Email_Id__c = oweList[0].Id;
        }
/*
        SELECT Action_Status__c, Action_Sub_status__c, Event__r.id, Letterhead_HTML__c, Email_Subject__c,
        Email_Content__c, Letterhead_Id__c, Org_Email_Id__c, BCC_Email__c
        FROM Summit_Events_Email__c
        WHERE Event__r.Id IN :affectedIds.values()
                AND Action_status__c != Null
                AND Action_Status__c != '--Inactive--'

                */
        insert testEvtEmail;

        return testEvtEmail;

    }

    public static Contact createContact(String firstName, String preferredFirst, String lastName, String Email, String Zip, String Phone, String DOB, String ClassYear) {

        Account a = new Account(Name = firstName + ' ' + lastName + ' Account Name');
        insert a;

        //Creating a student contact
        Contact student = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = Email,
                MailingStreet = '123 Rock Ave',
                MailingCity = 'Bedrock',
                MailingState = 'MN',
                MailingPostalCode = Zip,
                Phone = Phone,
                Birthdate = Date.valueOf(DOB),
                AccountId = a.Id
        );
        insert student;

        return student;

    }

    public static Summit_Events_Registration__c createEventRegistration(Summit_Events_Instance__c evtI, String firstName, String lastName, String Email, String Zip, String DOB, String ClassYear, Id optionalContactLinkId) {

        Summit_Events_Registration__c testRegistration = new Summit_Events_Registration__c(
                Event__c = evtI.Event__c,
                Event_Instance__c = evtI.Id,
                Registrant_Email__c = Email,
                Registrant_First_Name__c = firstName,
                Registrant_Last_Name__c = lastName,
                Registrant_Zip__c = Zip,
                Registrant_High_School_Code__c = '000000',
                Registrant_Date_of_Birth__c = Date.valueOf(DOB),
                Preferred_Class_Year__c = ClassYear,
                Status__c = 'Started',
                Registrant_Third_Party_Status__c = 'Primary Registrant'
        );

        insert testRegistration;

        if (optionalContactLinkId != null) {
            testRegistration.Contact__c = optionalContactLinkId;
            upsert testRegistration;
        }

        List<Summit_Events_Appointments__c> addToRegAppointments = new List<Summit_Events_Appointments__c>();
        Integer aptNum = 0;

        //Add athletic appointment
        addToRegAppointments.add(new Summit_Events_Appointments__c(
                Event_Registration__c = testRegistration.Id,
                Description__c = 'Athletic Appointment',
                Appointment_Category__c = 'Athletic Visit',
                Appointment_Type__c = 'Men\'s Golf',
                Appointment_Status__c = 'Registered'
        ));

        //Represent all other appointment types
        List<Summit_Events_Appointment_Type__c> newAppointmentTypes = [SELECT Id FROM Summit_Events_Appointment_Type__c WHERE Summit_Events__c = :evtI.Event__c];

        for (Summit_Events_Appointment_Type__c nat : newAppointmentTypes) {
            Summit_Events_Appointments__c addThisAppointment = new Summit_Events_Appointments__c (
                    Event_Appointment_Type__c = nat.Id,
                    Event_Registration__c = testRegistration.Id,
                    Client_Created_Appointment__c = true,
                    Room__c = 'TEST ROOM'
            );
            if (Math.mod(aptNum, 2) == 0) {
                addThisAppointment.Appointment_Status__c = 'Registered';
            } else {
                addThisAppointment.Appointment_Status__c = 'Confirmed';
            }

            addToRegAppointments.add(addThisAppointment);
            aptNum++;
        }
        insert addToRegAppointments;

        return testRegistration;

    }

    static Integer s_num = 1;

    public static String getFakeId(Schema.SObjectType sot) {
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() +
                '0'.repeat(12 - result.length()) + result;
    }

    public static Summit_Events_Registration__c createEventRegistrationObj(String firstName, String preferredFirst, String lastName, String Email, String Zip, String Phone, String DOB, String ClassYear) {
        Summit_Events_Registration__c eReg = new Summit_Events_Registration__c(
                Registrant_First_Name__c = firstName,
                Registrant_Preferred_First_Name__c = preferredFirst,
                Registrant_Last_Name__c = lastName,
                Registrant_Email__c = Email,
                Registrant_Zip__c = Zip,
                Registrant_Phone__c = Phone,
                Preferred_Class_Year__c = ClassYear
        );
        if (String.isNotBlank(DOB)) {
            eReg.Registrant_Date_of_Birth__c = Date.valueOf(DOB);
        }
        return eReg;
    }

}