// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 2/27/2019.

public with sharing class USTEventContactMatching {

    public USTEventContactMatching() {

    }

    public Map<String, String> USTEventContactMatching(String matchingType, UST_Event_Registration__c evt, String matchingScope) {
        Map<String, String> matchingResult = new Map<String, String>();
        //Direct to correct matching method
        if (!matchingScope.startsWith('No matching')) {
            if (matchingType.equalsIgnoreCase('Undergraduate')) {
                matchingResult = UG_Matching(evt, matchingScope);
            } else if (matchingType.equalsIgnoreCase('UDAR')) {
                matchingResult = UDAR_matching(evt, matchingScope);
            } else if (matchingType.equalsIgnoreCase('Graduate')) {
                //Using Undergrad matching for now
                matchingResult = UG_Matching(evt, matchingScope);
            }
        }
        return matchingResult;
    }

    //Check for Matches
    private Map<String, String> UDAR_matching(UST_Event_Registration__c evt, String matchingScope) {
        Id ContactId = null;
        String matchLog = '';
        Boolean newContactCreated = false;
        String hardMatchHeading = '';
        /* These fields may be depreciated witht he matching log
        String softEmailMatches = '';
        String softFirstLastZipMatches = '';
        End of Depreciated fields */
        String matchLogHead = '<table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered slds-size_1-of-1">';
        matchLogHead += '<thead><tr class="slds-line-height_reset">';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Last Name">Last Name</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="First Name">Student Last Name</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="First Name">First Name</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Email">Class Year</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Email">Email</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Email">Phone</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Action">Action</div></th>';
        matchLogHead += '</tr></thead>';

        // Create the Log Header
        matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Original Registration Information</div>';
        matchLog += matchLogHead;
        matchLog += '<tbody>';
        matchLog += UDARMatchTD('javascript();', evt.Registrant_Last_Name__c, evt.Last_Name_as_Student__c, evt.Registrant_First_Name__c, evt.Preferred_St_Thomas_Class_Year__c, evt.Registrant_Email__c, '', evt.Registrant_Phone__c, '', false);
        matchLog += '</tbody></table>';

        /**** HARD MATCH TESTING ****/
        Contact hardContactFound = null;
        //Hard test on LAST NAME, EMAIL, CLASS

        String query = '';
        String orStat = '';
        String querySelect = ' SELECT Id, FirstName, LastName, Email, Personal_Email__c, hed__WorkEmail__c, Previous_Last_Name__c, Preferred_Class_Year__c, Phone, HomePhone FROM Contact';
        /** Hard match on Last Name, Email, Class Year  **/
        if (
                (String.isNotBlank(evt.Registrant_Last_Name__c) || String.isNotBlank(evt.Last_Name_as_Student__c))
                        && String.isNotBlank(evt.Registrant_Email__c)
                        && String.isNotBlank(evt.Preferred_St_Thomas_Class_Year__c)) {
            query += querySelect;

            /** Test on Last Name name Match **/
            if (String.isNotBlank(evt.Registrant_Last_Name__c)) {
                orStat += ' OR LastName = \'' + String.escapeSingleQuotes(evt.Registrant_Last_Name__c) + '\' ';
            }

            /** Test on Last Name on previous last name Match **/
            if (String.isNotBlank(evt.Last_Name_as_Student__c)) {
                orStat += ' OR LastName = \'' + String.escapeSingleQuotes(evt.Last_Name_as_Student__c) + '\' ';
                orStat += ' OR Previous_Last_Name__c = \'' + String.escapeSingleQuotes(evt.Last_Name_as_Student__c) + '\' ';
            }
            orStat = orStat.removeStart(' OR');
            query += ' WHERE ( ' + orStat + ' ) ';
            orStat = '';

            /** Test on EMAIL Match **/
            query += ' AND ( ';
            query += ' Email = \'' + String.escapeSingleQuotes(evt.Registrant_Email__c) + '\' ';
            query += ' OR Personal_Email__c = \'' + String.escapeSingleQuotes(evt.Registrant_Email__c) + '\' ';
            query += ' OR hed__WorkEmail__c = \'' + String.escapeSingleQuotes(evt.Registrant_Email__c) + '\' ';
            query += ' ) ';

            query += ' AND Preferred_Class_Year__c = \'' + String.escapeSingleQuotes(evt.Preferred_St_Thomas_Class_Year__c) + '\' ';

            List<Contact> hardContactTestEmail = database.query(query);

            if (hardContactTestEmail.size() == 1) {
                hardContactFound = hardContactTestEmail[0];
                hardMatchHeading = 'Hard match on LAST NAME, EMAIL and CLASS YEAR';
            }
        }

        query = '';
        orStat = '';
        /** Hard test on LAST NAME, FIRST NAME, EMAIL **/
        if (
                (hardContactFound == null && String.isNotBlank(evt.Registrant_Last_Name__c) || String.isNotBlank(evt.Last_Name_as_Student__c))
                        && String.isNotBlank(evt.Registrant_Email__c)
                        && (String.isNotBlank(evt.Registrant_First_Name__c) || String.isNotBlank(evt.Registrant_Preferred_First_Name__c))) {
            //Hard test on LAST NAME, FIRST NAME, EMAIL
            query += querySelect;
            /** Test on Last Name name Match **/
            if (String.isNotBlank(evt.Registrant_Last_Name__c)) {
                orStat += ' OR LastName = \'' + String.escapeSingleQuotes(evt.Registrant_Last_Name__c) + '\' ';
            }

            /** Test on Last Name on previous last name Match **/
            if (String.isNotBlank(evt.Last_Name_as_Student__c)) {
                orStat += ' OR LastName = \'' + String.escapeSingleQuotes(evt.Last_Name_as_Student__c) + '\' ';
                orStat += ' OR Previous_Last_Name__c = \'' + String.escapeSingleQuotes(evt.Last_Name_as_Student__c) + '\' ';
            }
            orStat = orStat.removeStart(' OR');
            query += ' WHERE ( ' + orStat + ' ) ';
            orStat = '';

            /** Test on Last Name name Match **/
            if (String.isNotBlank(evt.Registrant_First_Name__c)) {
                orStat += ' OR FirstName = \'' + String.escapeSingleQuotes(evt.Registrant_First_Name__c) + '\' ';
                orStat += ' OR Preferred_First_Name__c = \'' + String.escapeSingleQuotes(evt.Registrant_First_Name__c) + '\' ';
            }
            /** Test on Last Name on previous last name Match **/
            if (String.isNotBlank(evt.Registrant_Preferred_First_Name__c)) {
                orStat += ' OR Preferred_First_Name__c = \'' + String.escapeSingleQuotes(evt.Registrant_Preferred_First_Name__c) + '\' ';
            }
            orStat = orStat.removeStart(' OR');
            query += ' AND ( ' + orStat + ' ) ';
            orStat = '';

            /** Test on EMAIL Match **/
            query += ' AND ( ';
            query += ' Email = \'' + String.escapeSingleQuotes(evt.Registrant_Email__c) + '\' ';
            query += ' OR Personal_Email__c = \'' + String.escapeSingleQuotes(evt.Registrant_Email__c) + '\' ';
            query += ' OR hed__WorkEmail__c = \'' + String.escapeSingleQuotes(evt.Registrant_Email__c) + '\' ';
            query += ' ) ';

            List<Contact> hardContactTestFirst = database.query(query);
            if (hardContactTestFirst.size() == 1) {
                hardContactFound = hardContactTestFirst[0];
                hardMatchHeading = 'Hard match on LAST NAME, FIRST NAME and EMAIL';
            }

        }

        query = '';
        orStat = '';

        /** Hard test on LAST NAME, CLASS, FIRST NAME, PHONE **/
        if (
                (hardContactFound == null && String.isNotBlank(evt.Registrant_Last_Name__c) || String.isNotBlank(evt.Last_Name_as_Student__c))
                        && String.isNotBlank(evt.Registrant_Phone__c)
                        && (String.isNotBlank(evt.Registrant_First_Name__c) || String.isNotBlank(evt.Registrant_Preferred_First_Name__c))
                        && String.isNotBlank(evt.Preferred_St_Thomas_Class_Year__c)) {
            query += querySelect;
            /** Test on Last Name name Match **/
            if (String.isNotBlank(evt.Registrant_Last_Name__c)) {
                orStat += ' OR LastName = \'' + String.escapeSingleQuotes(evt.Registrant_Last_Name__c) + '\' ';
            }

            /** Test on Last Name on previous last name Match **/
            if (String.isNotBlank(evt.Last_Name_as_Student__c)) {
                orStat += ' OR LastName = \'' + String.escapeSingleQuotes(evt.Last_Name_as_Student__c) + '\' ';
                orStat += ' OR Previous_Last_Name__c = \'' + String.escapeSingleQuotes(evt.Last_Name_as_Student__c) + '\' ';
            }
            orStat = orStat.removeStart(' OR');
            query += ' WHERE ( ' + orStat + ' ) ';
            orStat = '';

            /** Test on First Name name Match **/
            if (String.isNotBlank(evt.Registrant_First_Name__c)) {
                orStat += ' OR FirstName = \'' + String.escapeSingleQuotes(evt.Registrant_First_Name__c) + '\' ';
                orStat += ' OR Preferred_First_Name__c = \'' + String.escapeSingleQuotes(evt.Registrant_First_Name__c) + '\' ';
            }

            /** Test on Last Name on previous last name Match **/
            if (String.isNotBlank(evt.Registrant_Preferred_First_Name__c)) {
                orStat += ' OR Preferred_First_Name__c = \'' + String.escapeSingleQuotes(evt.Registrant_Preferred_First_Name__c) + '\' ';
            }
            orStat = orStat.removeStart(' OR');
            query += ' AND ( ' + orStat + ' ) ';
            orStat = '';

            query += ' AND (';
            query += ' Phone = \'' + String.escapeSingleQuotes(evt.Registrant_Phone__c) + '\' ';
            query += ' OR MobilePhone = \'' + String.escapeSingleQuotes(evt.Registrant_Phone__c) + '\' ';
            query += ' OR HomePhone =  \'' + String.escapeSingleQuotes(evt.Registrant_Phone__c) + '\' ';
            query += ' OR hed__WorkPhone__c =  \'' + String.escapeSingleQuotes(evt.Registrant_Phone__c) + '\' ';
            query += ' )';
            query += ' AND Preferred_Class_Year__c = \'' + String.escapeSingleQuotes(evt.Preferred_St_Thomas_Class_Year__c) + '\' ';

            List<Contact> hardContactTestNamePhoneClass = database.query(query);
            if (hardContactTestNamePhoneClass.size() == 1) {
                hardContactFound = hardContactTestNamePhoneClass[0];
                hardMatchHeading = 'Hard match on LAST NAME, FIRST NAME and PHONE';
            }
        }

        query = '';
        orStat = '';
        if (
                (hardContactFound == null && String.isNotBlank(evt.Registrant_Last_Name__c) || String.isNotBlank(evt.Last_Name_as_Student__c))
                        && (String.isNotBlank(evt.Registrant_First_Name__c) || String.isNotBlank(evt.Registrant_Preferred_First_Name__c))
                        && String.isNotBlank(evt.Preferred_St_Thomas_Class_Year__c)) {

            /* Get the first three characters of name and preferred name */
            String firstThree = evt.Registrant_First_Name__c;
            if (firstThree.length() > 3) {
                firstThree = firstThree.substring(0, 3);
            }
            String prefFirstThree = '';
            if (String.isNotBlank(evt.Registrant_Preferred_First_Name__c)) {
                prefFirstThree = evt.Registrant_Preferred_First_Name__c;
                if (prefFirstThree.length() > 3) {
                    prefFirstThree = prefFirstThree.substring(0, 3);
                }
            }

            //Hard test on LAST NAME, CLASS, FIRST 3 LETTERS
            query += querySelect;
            /** Test on Last Name name Match **/
            if (String.isNotBlank(evt.Registrant_Last_Name__c)) {
                orStat += ' OR LastName = \'' + String.escapeSingleQuotes(evt.Registrant_Last_Name__c) + '\' ';
            }

            /** Test on Last Name on previous last name Match **/
            if (String.isNotBlank(evt.Last_Name_as_Student__c)) {
                orStat += ' OR LastName = \'' + String.escapeSingleQuotes(evt.Last_Name_as_Student__c) + '\' ';
                orStat += ' OR Previous_Last_Name__c = \'' + String.escapeSingleQuotes(evt.Last_Name_as_Student__c) + '\' ';
            }
            orStat = orStat.removeStart(' OR');
            query += ' WHERE ( ' + orStat + ' ) ';
            orStat = '';

            If (String.IsNotBlank(firstThree)) {
                orStat += ' FirstName LIKE \'' + firstThree + '%\' OR ';
                orStat += ' Preferred_First_Name__c LIKE \'' + firstThree + '%\' OR ';
            }
            if (String.IsNotBlank(prefFirstThree)) {
                orStat += ' Preferred_First_Name__c LIKE \'' + prefFirstThree + '%\' OR ';
            }
            orStat = orStat.removeEnd(' OR ');
            if (String.isNotBlank(orStat)) {
                query += ' AND ( ' + orStat + ' ) ';
            }
            orStat = '';

            query += ' AND Preferred_Class_Year__c = \'' + String.escapeSingleQuotes(evt.Preferred_St_Thomas_Class_Year__c) + '\' ';

            System.Debug(query);
            List<Contact> hardContactTestNameFirstThreeClass = database.query(query);
            if (hardContactTestNameFirstThreeClass.size() == 1) {
                hardContactFound = hardContactTestNameFirstThreeClass[0];
                hardMatchHeading = 'Hard match on LAST NAME, FIRST 3 LETTERS OF FIRST NAME and CLASS';
            }
        }

        if (hardContactFound != null) {
            matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">' + hardMatchHeading + '!</div>';
            matchLog += matchLogHead;
            matchLog += '<tbody>';
            matchLog += UDARMatchTD(hardContactFound.Id, hardContactFound.LastName, hardContactFound.Previous_Last_Name__c, hardContactFound.FirstName, hardContactFound.Preferred_Class_Year__c, hardContactFound.Email, '', hardContactFound.HomePhone, '', false);
            matchLog += '</tbody></table>';
            contactId = hardContactFound.Id;
        }

        /**** SOFT MATCH TESTING ****/
        query = '';
        orStat = '';
        if (hardContactFound == null && (matchingScope.startsWith('Full matching') || String.isBlank(matchingScope))) {
            //SOFT MATCHES BEGIN
            Boolean queryComplete = true;
            query += querySelect;
            /** Test on Last Name name Match **/
            if (String.isNotBlank(evt.Registrant_Last_Name__c)) {
                orStat += ' OR LastName = \'' + String.escapeSingleQuotes(evt.Registrant_Last_Name__c) + '\' ';
                /** Test on Last Name on previous last name Match **/
                if (String.isNotBlank(evt.Last_Name_as_Student__c)) {
                    orStat += ' OR LastName = \'' + String.escapeSingleQuotes(evt.Last_Name_as_Student__c) + '\' ';
                    orStat += ' OR Previous_Last_Name__c = \'' + String.escapeSingleQuotes(evt.Last_Name_as_Student__c) + '\' ';
                }
            } else {
                queryComplete = false;
            }

            if (String.isNotBlank(orStat)) {
                orStat = orStat.removeStart(' OR');
                query += ' WHERE ( ' + orStat + ' ) ';
            }
            orStat = '';

            if (String.isNotBlank(evt.Registrant_Phone__c)) {
                query += ' AND (';
                query += ' Phone = \'' + String.escapeSingleQuotes(evt.Registrant_Phone__c) + '\' ';
                query += ' OR MobilePhone = \'' + String.escapeSingleQuotes(evt.Registrant_Phone__c) + '\' ';
                query += ' OR HomePhone =  \'' + String.escapeSingleQuotes(evt.Registrant_Phone__c) + '\' ';
                query += ' OR hed__WorkPhone__c =  \'' + String.escapeSingleQuotes(evt.Registrant_Phone__c) + '\' ';
                query += ' )';
            } else {
                queryComplete = false;
            }

            if (String.isNotBlank(evt.Preferred_St_Thomas_Class_Year__c)) {
                query += ' AND Preferred_Class_Year__c = \'' + String.escapeSingleQuotes(evt.Preferred_St_Thomas_Class_Year__c) + '\' ';
            } else {
                queryComplete = false;
            }

            List<Contact> softContactTestNamePhoneClass = new List<Contact>();
            if (queryComplete) {
                softContactTestNamePhoneClass = database.query(query);
            }

            if (softContactTestNamePhoneClass.size() > 0) {
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Soft Matches on LAST NAME, PHONE and CLASS.</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                for (Contact softy : softContactTestNamePhoneClass) {
                    matchLog += UDARMatchTD(softy.Id, softy.lastName, softy.Previous_Last_Name__c, softy.FirstName, softy.Preferred_Class_Year__c, softy.Email, '', softy.HomePhone, '', true);
                }
                matchLog += '</tbody></table>';
            }

            //if no contact ID was found create a new contact
            if (hardContactFound == null) {
                Contact newCreatedContact = createNewContact(evt);
                contactId = newCreatedContact.Id;
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">New Contact Created</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                matchLog += UDARMatchTD(contactId, evt.Registrant_Last_Name__c, '', evt.Registrant_First_Name__c, evt.Preferred_St_Thomas_Class_Year__c, newCreatedContact.Email, '', evt.Registrant_Phone__c, '', false);
                matchLog += '</tbody></table>';
                newContactCreated = true;
            }

        }

        return new Map<String, String>{
                'contactId' => contactId,
                'matchLog' => matchLog,
                'newContactCreated' => String.valueOf(newContactCreated)
        };
    }

    private String UDARMatchTD(String ContactId, String LastName, String StudentLastName, String FirstName, String ClassYear, String Email, String EmailSuffix, String Phone, String PhoneSuffix, Boolean Action) {
        String mOut = '<tr class="slds-hint-parent">';
        if (String.isBlank(LastName)) {
            LastName = '';
        }
        mOut += '<td data-label="Last Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + LastName + '</a></div></td>';
        if (String.isBlank(StudentLastName)) {
            StudentLastName = '';
        }
        mOut += '<td data-label="Last Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + StudentLastName + '</a></div></td>';
        if (String.isBlank(FirstName)) {
            FirstName = '';
        }
        mOut += '<td data-label="First Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + FirstName + '</a></div></td>';
        if (String.isBlank(ClassYear)) {
            ClassYear = '';
        }
        mOut += '<td data-label="First Name"><div class="slds-truncate">' + ClassYear + '</div></td>';
        if (String.isBlank(Email)) {
            Email = '';
        }
        mOut += '<td data-label="Email"><div class="slds-truncate">' + Email;
        if (String.isBlank(EmailSuffix)) {
            mOut += ' ' + EmailSuffix;
        }
        mOut += '</div></td>';
        if (String.isBlank(Phone)) {
            Phone = '';
        }
        mOut += '<td data-label="Phone"><div class="slds-truncate">' + Phone;
        if (String.isNotBlank(PhoneSuffix)) {
            mOut += ' ' + PhoneSuffix;
        }
        mOut += '</div></td>';
        if (Action) {
            mOut += '<td data-label="Action"><div class="slds-truncate"><a class="slds-text-link_reset" href="/apex/USTEventReparent?regId=[[REGID]]&reparentTo=' + ContactId + '"><span class="slds-text-link">Reparent</span></a></div></td>';
        } else {
            mOut += '<td data-label="Action"><div class="slds-truncate"> --- </div></td>';
        }
        mOut += '</tr>';
        return mOut;
    }

    private Map<String, String> UG_Matching(UST_Event_Registration__c evt, String matchingScope) {
        String contactId = '';
        String softEmailMatches = '';
        String softFirstLastZipMatches = '';
        boolean newContactCreated = false;
        String query = '';

        /* Start the the matching log HTML table */
        String matchLog = '';
        String matchLogHead = '<table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered slds-size_1-of-1">';
        matchLogHead += '<thead><tr class="slds-line-height_reset">';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Last Name">Last Name</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="First Name">First Name</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Email">Email</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Zip">Zip</div></th>';
        matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Action">Action</div></th>';
        matchLogHead += '</tr></thead>';


        if (String.isNotBlank(evt.Contact__r.Id)) {
            contactId = evt.Contact__r.Id;
        }

        String lastName = evt.Registrant_Last_Name__c;
        String email = evt.Registrant_Email__c;

        /* Match on first 3 letters of first name / preferred first name, last name, and birthdate */

        if (String.isBlank(contactId) && evt.Registrant_Date_of_Birth__c != null && String.isNotBlank(evt.Registrant_Last_Name__c)) {

            /* Get the first three characters of name and preferred name */
            String firstThree = evt.Registrant_First_Name__c;
            if (firstThree.length() > 3) {
                firstThree = firstThree.substring(0, 3);
            }
            String prefFirstThree = evt.Registrant_Preferred_First_Name__c;
            if (prefFirstThree.length() > 3) {
                prefFirstThree = prefFirstThree.substring(0, 3);
            }

            query = ' SELECT Id, LastName, FirstName, Email, MailingPostalCode FROM Contact WHERE (';
            if (String.isNotBlank(firstThree)) {
                query += ' firstName LIKE \'' + firstThree + '%\' OR';
            }
            if (String.isNotBlank(prefFirstThree)) {
                query += ' Preferred_First_Name__c LIKE \'' + prefFirstThree + '%\' OR';
            }
            query = query.removeEnd(' OR');
            query += ' ) ';
            query += ' AND LastName = \'' + evt.Registrant_Last_Name__c + '\' ';
            query += ' AND Birthdate = ' + String.valueOf(evt.Registrant_Date_of_Birth__c).removeEnd(' 00:00:00');
            System.Debug(query);
            List<Contact> hardContactTest1 = database.query(query);
            if (hardContactTest1.size() > 0) {
                contactId = hardContactTest1[0].Id;

                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Hard match on FIRST NAME (first 3), LAST NAME, BIRTH DATE!</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                matchLog += UGMatchTD(hardContactTest1[0].Id, hardContactTest1[0].LastName, hardContactTest1[0].FirstName, hardContactTest1[0].Email, hardContactTest1[0].MailingPostalCode, false);
                matchLog += '</tbody></table>';
            }
        }

        //Test to find if contact already exists - HARD TEST last name and email match
        if (String.isBlank(contactId)) {
            List<Contact> hardContactTest2 = [SELECT Id, LastName, FirstName, Email, MailingPostalCode FROM Contact WHERE LastName = :lastName AND Email = :email];
            if (hardContactTest2.size() > 0) {
                contactId = hardContactTest2[0].Id;
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Hard match on LAST NAME, EMAIL!</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                matchLog += UGMatchTD(hardContactTest2[0].Id, hardContactTest2[0].LastName, hardContactTest2[0].FirstName, hardContactTest2[0].Email, hardContactTest2[0].MailingPostalCode, false);
                matchLog += '</tbody></table>';
            }
        }

        //Check for already made DUPLICATE emails and attach to matching
        if (String.isBlank(contactId) && (matchingScope.startsWith('Full matching') || String.isBlank(matchingScope))) {
            String[] possibleEmails = new List<String>();
            possibleEmails.add(evt.Registrant_Email__c);
            for (Integer x = 1; x <= 10; x++) {
                possibleEmails.add('Event_Dup_' + String.valueOf(x) + '_' + evt.Registrant_Email__c);
            }
            List<Contact> hardContactTest3 = [SELECT Id, LastName, FirstName, Email, MailingPostalCode FROM Contact WHERE LastName = :lastName AND Email IN :possibleEmails];
            if (hardContactTest3.size() > 0) {
                //hard match on first DUP email found.
                contactId = hardContactTest3[0].Id;
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Hard match on LAST NAME, EMAIL (Email was duplicate email)</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                matchLog += UGMatchTD(hardContactTest3[0].Id, hardContactTest3[0].LastName, hardContactTest3[0].FirstName, hardContactTest3[0].Email, hardContactTest3[0].MailingPostalCode, false);
                matchLog += '</tbody></table>';
            }
        }

        if (String.isBlank(contactId) && (matchingScope.startsWith('Full matching') || String.isBlank(matchingScope))) {
            //Check if first name last name zip match
            List<Contact> zipContactTest = [
                    SELECT Id, LastName, FirstName, Email, MailingPostalCode
                    FROM Contact
                    WHERE FirstName = :evt.Registrant_First_Name__c
                    AND LastName = :evt.Registrant_Last_Name__c
                    AND MailingPostalCode = :evt.Registrant_Zip__c
            ];
            if (zipContactTest.size() > 0) {
                //Soft Match found with zip
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Soft Match on Zip, Last Name, First Name</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                for (Contact c : zipContactTest) {
                    matchLog += UGMatchTD(c.Id, c.LastName, c.FirstName, c.Email, c.MailingPostalCode, true);
                    softFirstLastZipMatches += c.Id + ' ';
                }
                matchLog += '</tbody></table>';
            }
            List<Contact> emailContactTest = [
                    SELECT Id, LastName, FirstName, Email, MailingPostalCode
                    FROM Contact
                    WHERE Email = :evt.Registrant_Email__c
            ];
            if (emailContactTest.size() > 0) {
                //Soft Match found with email
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Soft Match on Email</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                for (Contact c : emailContactTest) {
                    matchLog += UGMatchTD(c.Id, c.LastName, c.FirstName, c.Email, c.MailingPostalCode, true);
                    softEmailMatches += c.Id + ' ';
                }
                matchLog += '</tbody></table>';
            }
            Contact newEvtContact = createNewContact(evt);
            contactId = newEvtContact.Id;

            matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">New contact created!</div>';
            matchLog += matchLogHead;
            matchLog += '<tbody>';
            matchLog += UGMatchTD(newEvtContact.Id, newEvtContact.LastName, newEvtContact.FirstName, newEvtContact.Email, newEvtContact.MailingPostalCode, false);
            matchLog += '</tbody></table>';
            newContactCreated = true;
            //Create new contact
        }

        System.Debug(matchLog);
        return new Map<String, String>{
                'contactId' => contactId,
                'softEmailMatches' => softEmailMatches.abbreviate(255),
                'softFirstLastZipMatches' => softFirstLastZipMatches.abbreviate(255),
                'newContactCreated' => String.valueOf(newContactCreated),
                'matchLog' => matchLog
        };
    }

    private String UGMatchTD(String ContactId, String LastName, String FirstName, String Email, String Zip, Boolean Action) {
        String mOut = '<tr class="slds-hint-parent">';
        mOut += '<td data-label="Last Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + LastName + '</a></div></td>';
        mOut += '<td data-label="First Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + FirstName + '</a></div></td>';
        mOut += '<td data-label="Email"><div class="slds-truncate">' + Email + '</div></td>';
        mOut += '<td data-label="Zip"><div class="slds-truncate">' + Zip + '</div></td>';
        if (Action) {
            mOut += '<td data-label="Action"><div class="slds-truncate"><a class="slds-text-link_reset" href="/apex/USTEventReparent?regId=[[REGID]]&reparentTo=' + ContactId + '"><span class="slds-text-link">Reparent</span></a></div></td>';
        } else {
            mOut += '<td data-label="Action"><div class="slds-truncate"> --- </div></td>';
        }
        mOut += '</tr>';
        return mOut;
    }

    private Contact createNewContact(UST_Event_Registration__c evt) {
        //Create a HEDA address for new contact to be applied after insert
        hed__Address__c newAddress = new hed__Address__c();
        newAddress.hed__Address_Type__c = 'Home';
        newAddress.hed__MailingStreet__c = evt.Registrant_Street_1__c;
        newAddress.hed__MailingStreet2__c = evt.Registrant_Street_2__c;
        newAddress.hed__MailingCity__c = evt.Registrant_City__c;
        newAddress.hed__MailingState__c = evt.Registrant_State__c;
        newAddress.hed__MailingPostalCode__c = evt.Registrant_Zip__c;

        //Start the new contact
        Contact newEvtContact = new Contact();
        newEvtContact.FirstName = evt.Registrant_First_Name__c;
        newEvtContact.LastName = evt.Registrant_Last_Name__c;

        //Generate all possible emails that could be created, or already exist and put them in a list to limit query and keep out of a loop
        String[] possibleEmails = new List<String>();
        possibleEmails.add(evt.Registrant_Email__c);
        for (Integer x = 1; x <= 10; x++) {
            possibleEmails.add('Event_Dup_' + String.valueOf(x) + '_' + evt.Registrant_Email__c);
        }

        //Check for all possible email matches including dupes
        List<Contact> emailContactTest = [
                SELECT Id, Email
                FROM Contact
                WHERE Email IN :possibleEmails
        ];

        //If query is empty then we are free to use the email provided else we have to creat/check for dup emails
        if (emailContactTest.size() == 0) {
            newEvtContact.Email = evt.Registrant_Email__c;
        } else {
            //add all found emails to a string array
            List<String> foundEmails = new List<String>();
            for (Contact em : emailContactTest) {
                foundEmails.add(em.Email);
            }

            if (!foundEmails.contains(evt.Registrant_Email__c)) {
                //if the registration email isn't in the list use it -- probably won't happen
                newEvtContact.Email = evt.Registrant_Email__c;
            } else {
                //loop through possible emails until one is not found and use it.
                for (String possEm : possibleEmails) {
                    if (!foundEmails.contains(possEm)) {
                        newEvtContact.Email = possEm;
                        break;
                    }
                }
            }
        }

        newEvtContact.hed__Gender__c = evt.Registrant_Gender__c;
        newEvtContact.MobilePhone = evt.Registrant_Mobile_Phone__c;
        newEvtContact.HomePhone = evt.Registrant_Phone__c;
        newEvtContact.Previous_Last_Name__c = evt.Last_Name_as_Student__c;
        newEvtContact.Preferred_Class_Year__c = evt.Preferred_St_Thomas_Class_Year__c;
        //newEvtContact.High_School_Expected_Graduation_Year__c = evt.Registrant_High_School_Grad_Year__c;
        newEvtContact.LeadSource = 'Event';

        /*if (!String.isBlank(evt.Registrant_Applicant_Type__c)) {
            newEvtContact.Inquiry_Applicant_Type__c = evt.Registrant_Applicant_Type__c;
        }

        if (!String.isBlank(evt.Registrant_High_School_Code__c) && String.isBlank(evt.Registrant_College_Code__c)) {
            newEvtContact.EnrollmentrxRx__High_School_Code__c = evt.Registrant_High_School_Code__c;
        } else if (!String.isBlank(evt.Registrant_College_Code__c)) {
            newEvtContact.EnrollmentrxRx__High_School_Code__c = evt.Registrant_College_Code__c;
        }*/

        //New HEDA field is inverse
        if (evt.Registrant_Receive_Texts__c = true) {
            newEvtContact.Do_Not_Text__c = false;
        }
        try {
            upsert newEvtContact;
            //HEDA address
            newAddress.hed__Parent_Contact__c = newEvtContact.Id;
            upsert newAddress;
        } catch (Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
            ApexPages.addMessage(myMsg);
        }

        //Flag registration to show new contact was created
        evt.New_Contact_Created__c = true;
        return newEvtContact;

    }

}