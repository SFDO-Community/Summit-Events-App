// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 2/27/2019.

public with sharing class SummitEventsContactMatching {

    public static void matchContacts(List<Summit_Events_Registration__c> newRegistrations) {
        Map<Id, Summit_Events__c> matchingRules = new Map<Id, Summit_Events__c>();
        for (Summit_Events_Registration__c reg : newRegistrations) {
            matchingRules.put(reg.Event__c, null);
        }
        for (Summit_Events__c event : [SELECT Id, Contact_Matching_Rules__c FROM Summit_Events__c WHERE Id IN :matchingRules.keyset()]) {
            matchingRules.put(event.Id, event);
        }

        List<Summit_Events_Registration__c> byDuplicateRule = new List<Summit_Events_Registration__c>();
        for (Summit_Events_Registration__c reg : newRegistrations) {
            setNumberFields(reg);
            Summit_Events__c event = matchingRules.get(reg.Event__c);
            if (event.Contact_Matching_Rules__c == 'Use Salesforce Duplicate Rule' && String.isBlank(reg.Contact__c)) {
                byDuplicateRule.add(reg);
            }
        }

        if (!byDuplicateRule.isEmpty()) {
            matchContactsByDuplicateRule(byDuplicateRule);
        }
    }

    private static void setNumberFields(Summit_Events_Registration__c reg) {
        try {
            reg.Answer_1_Numeric__c = Integer.valueOf(reg.Add_Info_Answer_1__c);
        } catch (Exception e) {
            reg.Answer_1_Numeric__c = null;
        }
        try {
            reg.Answer_2_Numeric__c = Integer.valueOf(reg.Add_Info_Answer_2__c);
        } catch (Exception e) {
            reg.Answer_2_Numeric__c = null;
        }
        try {
            reg.Answer_3_Numeric__c = Integer.valueOf(reg.Add_Info_Answer_3__c);
        } catch (Exception e) {
            reg.Answer_3_Numeric__c = null;
        }
        try {
            reg.Answer_4_Numeric__c = Integer.valueOf(reg.Add_Info_Answer_4__c);
        } catch (Exception e) {
            reg.Answer_4_Numeric__c = null;
        }
        try {
            reg.Answer_5_Numeric__c = Integer.valueOf(reg.Add_Info_Answer_5__c);
        } catch (Exception e) {
            reg.Answer_5_Numeric__c = null;
        }
    }

    private static void matchContactsByDuplicateRule(List<Summit_Events_Registration__c> newRegistrations) {
        // Make it easy to tell what Matching Rule we're basing this off of
        Map<Id, String> matchType = new Map<Id, String>();
        Map<Id, Summit_Events__c> allEvents = new Map<Id, Summit_Events__c>();
        for (Summit_Events__c event : [
                SELECT Id, Contact_Creation_Duplicate_Rule__c, Custom_Metadata_Contact_Matching_Method__c, Contact_Matching_Multiple_Match_Behavior__c, Contact_Matching_No_Match_Behavior__c
                FROM Summit_Events__c
                WHERE Id IN (SELECT Event__c FROM Summit_Events_Registration__c WHERE Id IN :newRegistrations)
        ]) {
            String duplicateRuleName = event.Contact_Creation_Duplicate_Rule__c;
            duplicateRuleName = duplicateRuleName.replaceAll(' ', '_');

            matchType.put(event.Id, duplicateRuleName);
            allEvents.put(event.Id, event);
        }

        // Find out which Registrations need new Contacts, creates them,
        // and matches with existing Contacts whenever possible as defined by existing Duplicate Rules
        List<Contact> newContacts = new List<Contact>();
        for (Summit_Events_Registration__c reg : newRegistrations) {
            Summit_Events__c event = allEvents.get(reg.Event__c);
            Contact c = makeContact(reg, event.Custom_Metadata_Contact_Matching_Method__c);

            String matchLogHead = '<table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered slds-size_1-of-1">' +
                    '<thead><tr class="slds-line-height_reset">' +
                    '<th class="" scope="col"><div class="slds-truncate" title="Last Name">Last Name</div></th>' +
                    '<th class="" scope="col"><div class="slds-truncate" title="First Name">First Name</div></th>' +
                    '<th class="" scope="col"><div class="slds-truncate" title="Email">Email</div></th>' +
                    '<th class="" scope="col"><div class="slds-truncate" title="Zip">Zip</div></th>' +
                    '<th class="" scope="col"><div class="slds-truncate" title="Action">Action</div></th>' +
                    '</tr></thead>';

            List<Datacloud.FindDuplicatesResult> results = new List<Datacloud.FindDuplicatesResult>();
            doCrud crud = new doCrud();

            try { // Datacloud.FindDuplicates returns an error if no matching rules are active
                List<Contact> cons = new List<Contact>();
                cons.add(c);
                results = crud.findDuplicateContacts(cons);
            } catch (Exception e) {
            }

            List<Contact> matchContacts = new List<Contact>();
            for (Datacloud.DuplicateResult dr : results[0].getDuplicateResults()) {
                if (matchType.get(reg.Event__c) == dr.getDuplicateRule()) {
                    for (Datacloud.MatchResult mr : dr.getMatchResults()) {
                        for (Datacloud.MatchRecord mRecord : mr.getMatchRecords()) {
                            Contact con = (Contact) mRecord.getRecord();
                            matchContacts.add(con);
                        }
                    }
                }
            }

            System.debug(matchContacts);

            if (!matchContacts.isEmpty()) {
                String query = 'SELECT Id, LastName, FirstName, Email, MailingPostalCode FROM Contact WHERE Id IN (';
                for (Contact con : matchContacts)
                    query += '\'' + con.Id + '\',';
                query = query.removeEnd(',') + ') ORDER BY LastModifiedDate DESC';
                matchContacts = crud.findContacts(query);
            }
            if (matchContacts == null || matchContacts.isEmpty()) { // SOQL queries return null instead of empty lists
                if (event.Contact_Matching_No_Match_Behavior__c == 'Create Contact') {
                    for (Summit_Events_Contact_Matching_Mapping__mdt mapping : [
                            SELECT Contact_Field_API_Name__c, Source_Value__c, Source_Type__c
                            FROM Summit_Events_Contact_Matching_Mapping__mdt
                            WHERE Contact_Matching_Method__c = :event.Custom_Metadata_Contact_Matching_Method__c AND Matching_Only__c = TRUE
                    ]) {
                        c.put(mapping.Contact_Field_API_Name__c, null);
                    }

                    crud.addContact(c);

                    reg.New_Contact_Created__c = true;
                    reg.Contact__c = c.Id;

                    String matchLog = '<div class="slds-text-heading_small slds-m-vertical_medium">New contact created!</div>';
                    matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Match not found using Duplicate Rule <em>' + matchType.get(reg.Event__c) + '</em></div>';
                    matchLog += matchLogHead;
                    matchLog += '<tbody>';
                    matchLog += matchingLog(c.Id, reg.Registrant_Last_Name__c, reg.Registrant_First_Name__c, reg.Registrant_Email__c, reg.Registrant_Postal_Code__c, null);
                    matchLog += '</tbody></table>';

                    reg.Matching_Log__c = matchLog;
                } else {
                    String matchLog = '';
                    matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Match not found using Duplicate Rule <em>' + matchType.get(reg.Event__c) + '</em></div>';
                    matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Contact matching skipped based on "Contact Matching Skip Contact Creation" field value on Summit Events object</div>';

                    reg.Matching_Log__c = matchLog;
                }
            } else if (matchContacts.size() == 1) {
                reg.Contact__c = matchContacts[0].Id;
                reg.New_Contact_Created__c = false;

                String matchLog = '<div class="slds-text-heading_small slds-m-vertical_medium">Match found using Salesforce Duplicate Rule <em>' + matchType.get(reg.Event__c).replaceAll('_', ' ') + '</em></div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';

                matchLog += matchingLog(reg.Contact__c, reg.Registrant_Last_Name__c, reg.Registrant_First_Name__c, reg.Registrant_Email__c, reg.Registrant_Postal_Code__c, null);

                matchLog += '</tbody></table>';

                reg.Matching_Log__c = matchLog;
            } else {
                if (event.Contact_Matching_Multiple_Match_Behavior__c == 'Skip matching') {
                    System.debug('Matching skipped');
                    String matchLog = '<div class="slds-text-heading_small slds-m-vertical_medium">Multiple matches found using Salesforce Duplicate Rule <em>' + matchType.get(reg.Event__c).replaceAll('_', ' ') + '</em>, Contact matching skipped based on "Contact Matching Multiple Match Behavior" field value on Summit Events object</div>';
                    matchLog += matchLogHead;
                    matchLog += '<tbody>';

                    for (Contact con : matchContacts) {
                        matchLog += matchingLog(con.Id, con.LastName, con.FirstName, con.Email, con.MailingPostalCode, 'Skipped');
                    }

                    matchLog += '</tbody></table>';

                    reg.Matching_Log__c = matchLog;
                } else if (event.Contact_Matching_Multiple_Match_Behavior__c == 'Match with most recently modified') {
                    reg.Contact__c = matchContacts[0].Id;

                    String matchLog = '<div class="slds-text-heading_small slds-m-vertical_medium">Multiple matches found using Salesforce Duplicate Rule <em>' + matchType.get(reg.Event__c).replaceAll('_', ' ') + '</em>, Most recently modified Contact was selected based on "Contact Matching Multiple Match Behavior" field value on Summit Events object</div>';
                    matchLog += matchLogHead;
                    matchLog += '<tbody>';

                    Boolean isFirst = true;
                    for (Contact con : matchContacts) {
                        matchLog += matchingLog(con.Id, con.LastName, con.FirstName, con.Email, con.MailingPostalCode, isFirst ? 'Selected' : 'Skipped');
                        isFirst = false;
                    }

                    matchLog += '</tbody></table>';

                    reg.Matching_Log__c = matchLog;
                }
            }
        }
    }

    private static Contact makeContact(Summit_Events_Registration__c reg, String matchingMethod) {
        Contact c = new Contact();
        c.FirstName = reg.Registrant_First_Name__c;
        c.LastName = reg.Registrant_Last_Name__c;
        c.Email = reg.Registrant_Email__c;
        c.Birthdate = reg.Registrant_Date_of_Birth__c;

        c.MailingStreet = reg.Registrant_Street_1__c;
        c.MailingCity = reg.Registrant_City__c;
        c.MailingState = reg.Registrant_State__c;
        c.MailingPostalCode = reg.Registrant_Zip__c != '' ? reg.Registrant_Zip__c : reg.Registrant_Postal_Code__c;
        c.MailingCountry = reg.Registrant_Country__c;

        c.Phone = reg.Registrant_Phone__c;
        c.MobilePhone = reg.Registrant_Mobile_Phone__c;


        for (Summit_Events_Contact_Matching_Mapping__mdt mapping : [
                SELECT Contact_Field_API_Name__c, Source_Value__c, Source_Type__c
                FROM Summit_Events_Contact_Matching_Mapping__mdt
                WHERE Contact_Matching_Method__c = :matchingMethod AND Source_Object__c = 'summit__Summit_Events_Registration__c' AND Source_Type__c = 'Field'
        ]) {
            System.debug('mapping - ' + mapping);
            c.put(mapping.Contact_Field_API_Name__c, reg.get(mapping.Source_Value__c));
        }

        for (Summit_Events_Contact_Matching_Mapping__mdt mapping : [
                SELECT Contact_Field_API_Name__c, Source_Value__c, Source_Type__c
                FROM Summit_Events_Contact_Matching_Mapping__mdt
                WHERE Contact_Matching_Method__c = :matchingMethod AND Source_Type__c = 'Hardcoded'
        ]) {
            System.debug('mapping - ' + mapping);
            c.put(mapping.Contact_Field_API_Name__c, mapping.Source_Value__c);
        }

        return c;
    }

    private static String matchingLog(String ContactId, String LastName, String FirstName, String Email, String Zip, String Action) {
        String mOut = '<tr class="slds-hint-parent">';
        mOut += '<td data-label="Last Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + LastName + '</a></div></td>';
        mOut += '<td data-label="First Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + FirstName + '</a></div></td>';
        mOut += '<td data-label="Email"><div class="slds-truncate">' + Email + '</div></td>';
        mOut += '<td data-label="Zip"><div class="slds-truncate">' + Zip + '</div></td>';
        if (String.isBlank(Action)) {
            mOut += '<td data-label="Action"><div class="slds-truncate"> --- </div></td>';
        } else {
            mOut += '<td data-label="Action"><div class="slds-truncate"> ' + Action + ' </div></td>';
        }
        mOut += '</tr>';
        return mOut;
    }

    private without sharing class doCRUD {

        public List<Contact> findContacts(string query) {
            try {
                List<Contact> contactsFound = database.query(query);
                return contactsFound;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
            return null;
        }

        public Contact addContact(Contact contactToAdd) {
            try {
                upsert contactToAdd;
                return contactToAdd;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
            return null;
        }

        public List<Datacloud.FindDuplicatesResult> findDuplicateContacts(List<Contact> cons) {
            return Datacloud.FindDuplicates.findDuplicates(cons);
        }
    }
}