// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 6/12/2018.

@IsTest
public with sharing class SummitEventsShared_TEST {

    /**

    Data Factory Methods:

    createTestEvent(String recType, String testEventName, String audience, Boolean includeAppt, Boolean includeAddQuestions)
        - Returns Event Instance
    createContact(String firstName, String preferredFirst, String lastName, String Email, String Zip, String Phone, String DOB, String ClassYear)
        - Returns contact
    createUserByContactId(Id cId)
        - Returns user
    createEventRegistration(Summit_Events_Instance__c evtI, String firstName, String lastName, String Email, String Zip, String DOB, String ClassYear)
        - Returns Event Registration
    createEventRegistrationObj(String firstName, String preferredFirst, String lastName, String Email, String Zip, String Phone, String DOB, String ClassYear)
        -Returns Event Registration Object
    createTestTransactionEmail(Id evtId, String status)
        -Returns Summit_Events_Email__c

     **/

    @IsTest
    static void testDepreciation() {
        Boolean depreciated = true;
        System.assertEquals(depreciated, true);
    }
}