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

        if (Schema.SObjectType.Summit_Events__c.isAccessible()) {
            for (Summit_Events__c event : [
                    SELECT Id, Contact_Matching_Rules__c
                    FROM Summit_Events__c
                    WHERE Id IN :matchingRules.keySet()
            ]) {
                matchingRules.put(event.Id, event);
            }
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
        if (Schema.SObjectType.Summit_Events__c.isAccessible()) {
            for (Summit_Events__c event : [
                    SELECT Id, Contact_Creation_Duplicate_Rule__c, Custom_Metadata_Contact_Matching_Method__c, Contact_Matching_Multiple_Match_Behavior__c, Contact_Matching_No_Match_Behavior__c
                    FROM Summit_Events__c
                    WHERE Id IN (
                            SELECT Event__c
                            FROM Summit_Events_Registration__c
                            WHERE Id IN :newRegistrations
                    )
            ]) {
                String duplicateRuleName = event.Contact_Creation_Duplicate_Rule__c;
                duplicateRuleName = duplicateRuleName.replaceAll(' ', '_');

                matchType.put(event.Id, duplicateRuleName);
                allEvents.put(event.Id, event);
            }
        }

        // Find out which Registrations need new Contacts, creates them,
        // and matches with existing Contacts whenever possible as defined by existing Duplicate Rules
        for (Summit_Events_Registration__c reg : newRegistrations) {
            Summit_Events__c event = allEvents.get(reg.Event__c);
            Contact c = makeContact(reg, event.Custom_Metadata_Contact_Matching_Method__c);

            List<Datacloud.FindDuplicatesResult> results = new List<Datacloud.FindDuplicatesResult>();
            doCRUD crud = new doCRUD();

            try { // Datacloud.FindDuplicates returns an error if no matching rules are active
                List<Contact> cons = new List<Contact>();
                cons.add(c);
                results = crud.findDuplicateContacts(cons);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }

            List<Contact> matchContacts = new List<Contact>();
            if (results.size() > 0) {
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
            }

            if (!matchContacts.isEmpty()) {
                List<Id> foundIds = new List<Id>();
                for (Contact con : matchContacts) {
                    foundIds.add(con.Id);
                }
                matchContacts = crud.findContacts(foundIds);
            }

            String matchLog = '';

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
                    matchLog += matchingLog(reg, new List<Contact>(), 'New contact created!', 'Match not found using Duplicate Rule <em>' + matchType.get(reg.Event__c) + '</em></div>');
                } else {
                    matchLog += matchingLog(null, new List<Contact>(), 'Match not found using Duplicate Rule <em>' + matchType.get(reg.Event__c) + '</em>', 'Contact matching skipped based on "Contact Matching Skip Contact Creation" field value on Summit Events object');
                }
            } else if (matchContacts.size() == 1) {
                reg.Contact__c = matchContacts[0].Id;
                reg.New_Contact_Created__c = false;
                matchLog += matchingLog(reg, new List<Contact>(), 'Match found using Salesforce Duplicate Rule <em>' + matchType.get(reg.Event__c).replaceAll('_', ' ') + '</em>', '');
            } else {
                if (event.Contact_Matching_Multiple_Match_Behavior__c == 'Skip matching') {
                    matchLog += matchingLog(null, matchContacts, 'Multiple matches found using Salesforce Duplicate Rule <em>' + matchType.get(reg.Event__c).replaceAll('_', ' ') + '</em>, Contact matching skipped based on "Contact Matching Multiple Match Behavior" field value on Summit Events object', '');
                } else if (event.Contact_Matching_Multiple_Match_Behavior__c == 'Match with most recently modified') {
                    matchLog += matchingLog(null, matchContacts, 'Multiple matches found using Salesforce Duplicate Rule <em>' + matchType.get(reg.Event__c).replaceAll('_', ' ') + '</em>, Most recently modified Contact was selected based on "Contact Matching Multiple Match Behavior" field value on Summit Events object', '');
                    reg.Contact__c = matchContacts[0].Id;
                }
            }
            reg.Matching_Log__c = matchLog;
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

        c.Created_with_Summit_Events__c = true;

        if (Schema.SObjectType.Summit_Events_Contact_Matching_Mapping__mdt.isAccessible()) {
            for (Summit_Events_Contact_Matching_Mapping__mdt mapping : [
                    SELECT Contact_Field_API_Name__c, Source_Value__c, Source_Type__c
                    FROM Summit_Events_Contact_Matching_Mapping__mdt
                    WHERE Contact_Matching_Method__c = :matchingMethod
                    AND Source_Object__c = 'summit__Summit_Events_Registration__c'
                    AND Source_Type__c = 'Field'
            ]) {
                c.put(mapping.Contact_Field_API_Name__c, reg.get(mapping.Source_Value__c));
            }


            for (Summit_Events_Contact_Matching_Mapping__mdt mapping : [
                    SELECT Contact_Field_API_Name__c, Source_Value__c, Source_Type__c
                    FROM Summit_Events_Contact_Matching_Mapping__mdt
                    WHERE Contact_Matching_Method__c = :matchingMethod
                    AND Source_Type__c = 'Hardcoded'
            ]) {
                c.put(mapping.Contact_Field_API_Name__c, mapping.Source_Value__c);
            }
        }

        return c;
    }

    private static String matchingLog(Summit_Events_Registration__c registration, List<Contact> foundContacts, String heading1, String heading2) {
        String mOut = '';
        if (String.isNotBlank(heading1)) {
            mOut += '<div class="slds-text-heading_small slds-m-vertical_medium">' + heading1 + '</div>';
        }
        if (String.isNotBlank(heading2)) {
            mOut += '<div class="slds-text-heading_small slds-m-vertical_medium">' + heading2 + '</div>';
        }
        if (registration != null || foundContacts.size() > 0) {
            mOut += '<table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered slds-size_1-of-1">';
            mOut += '<thead><tr class="slds-line-height_reset">';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="Last Name">Last Name</div></th>';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="First Name">First Name</div></th>';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="Email">Email</div></th>';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="Zip">Zip</div></th>';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="Action">Action</div></th>';
            mOut += '</tr></thead>';
            mOut += '<tbody>';
            if (registration != null) {
                mOut += matchingRow(registration.Id, registration.Registrant_Last_Name__c, registration.Registrant_First_Name__c, registration.Registrant_Email__c, registration.Registrant_Zip__c, '');
            }
            Boolean isFirst = true;
            for (Contact con : foundContacts) {
                mOut += matchingRow(con.Id, con.LastName, con.FirstName, con.Email, con.MailingPostalCode, isFirst ? 'Selected' : 'Skipped');
                isFirst = false;
            }
            mOut += '</tbody></table>';
        }
        return mOut;
    }

    private static String matchingRow(String ContactId, String LastName, String FirstName, String Email, String Zip, String Action) {
        String matchRow = '';
        matchRow += '<tr class="slds-hint-parent">';
        matchRow += '<td data-label="Last Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + LastName + '</a></div></td>';
        matchRow += '<td data-label="First Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + FirstName + '</a></div></td>';
        matchRow += '<td data-label="Email"><div class="slds-truncate">' + (String.isNOtBlank(Email) ? Email : '') + '</div></td>';
        matchRow += '<td data-label="Zip"><div class="slds-truncate">' + (String.isNOtBlank(Zip) ? Zip : '') + '</div></td>';
        matchRow += '<td data-label="Action"><div class="slds-truncate"> ' + (String.isNOtBlank(Action) ? Action : '') + ' </div></td>';
        matchRow += '</tr>';
        return matchRow;
    }

    private without sharing class doCRUD {

        public List<Contact> findContacts(List<Id> foundIds) {
            List<Contact> contactsFound = [
                    SELECT Id, LastName, FirstName, Email, MailingPostalCode
                    FROM Contact
                    WHERE Id IN :foundIds
                    ORDER BY LastModifiedDate DESC
            ];
            return contactsFound;
        }

        public Contact addContact(Contact contactToAdd) {
            try {
                upsert contactToAdd;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
            return contactToAdd;
        }

        public List<Datacloud.FindDuplicatesResult> findDuplicateContacts(List<Contact> cons) {
            return Datacloud.FindDuplicates.findDuplicates(cons);
        }
    }
}
