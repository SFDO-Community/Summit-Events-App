// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 2/27/2019.

public with sharing class SummitEventsContactMatching {

    public static void matchContacts(List<Summit_Events_Registration__c> newRegistrations) {

        Map<Id, Summit_Events__c> matchingRules = new Map<Id, Summit_Events__c>();

        for (Summit_Events_Registration__c reg : newRegistrations) {
            matchingRules.put(reg.Event__c, null);
        }

        if (Schema.SObjectType.Summit_Events__c.isAccessible()) {
            for (Summit_Events__c event : [
                    SELECT Id, Contact_Matching_Rules__c, Lead_matching_rules__c
                    FROM Summit_Events__c
                    WHERE Id IN :matchingRules.keySet()
            ]) {
                matchingRules.put(event.Id, event);
            }
        }

        List<Summit_Events_Registration__c> byDuplicateRule = new List<Summit_Events_Registration__c>();
        List<Summit_Events_Registration__c> findLead = new List<Summit_Events_Registration__c>();

        for (Summit_Events_Registration__c reg : newRegistrations) {
            setNumberFields(reg);
            Summit_Events__c event = matchingRules.get(reg.Event__c);
            if (event.Contact_Matching_Rules__c == 'Use Salesforce Duplicate Rule' && String.isBlank(reg.Contact__c)) {
                byDuplicateRule.add(reg);
            } else if (event.Lead_matching_rules__c == 'Use Salesforce Duplicate Rule' && String.isBlank(reg.Contact__c) && String.isBlank(reg.Lead__c)) {
                findLead.add(reg);
            }
        }

        if (!byDuplicateRule.isEmpty()) {
            matchContactsByDuplicateRule(byDuplicateRule);
        }

        if (!findLead.isEmpty()) {
            leadSearch(findLead);
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
        Map<Id, String> leadMatch = new Map<Id, String>();
        Map<Id, Summit_Events__c> allEvents = new Map<Id, Summit_Events__c>();
        if (Schema.SObjectType.Summit_Events__c.isAccessible()) {
            for (Summit_Events__c event : [
                    SELECT Id,
                            Contact_Creation_Duplicate_Rule__c, Custom_Metadata_Contact_Matching_Method__c, Contact_Matching_Multiple_Match_Behavior__c, Contact_Matching_No_Match_Behavior__c,
                            Lead_Creation_Duplicate_Rule__c, Custom_Metadata_Lead_Matching_Method__c, Lead_Matching_Multiple_Match_Behavior__c, Lead_Matching_No_Match_Behavior__c, Lead_matching_rules__c
                    FROM Summit_Events__c
                    WHERE Id IN (
                            SELECT Event__c
                            FROM Summit_Events_Registration__c
                            WHERE Id IN :newRegistrations
                    )
            ]) {
                String contactRuleName = event.Contact_Creation_Duplicate_Rule__c.replaceAll(' ', '_');
                String leadRuleName = (String.isNotBlank(event.Lead_Creation_Duplicate_Rule__c) ? event.Lead_Creation_Duplicate_Rule__c.replaceAll(' ', '_') : '');

                matchType.put(event.Id, contactRuleName);
                leadMatch.put(event.Id, leadRuleName);
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
                                try {
                                    Contact con = (Contact) mRecord.getRecord();
                                    matchContacts.add(con);
                                } catch (Exception e){
                                    System.debug(e);
                                }
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
                    crud.addRecord(c);
                    reg.New_Contact_Created__c = true;
                    reg.Contact__c = c.Id;
                    matchLog += matchingLog(reg, new List<Contact>(), 'Match not found using Duplicate Rule <em>' + matchType.get(reg.Event__c) + '</em></div>', 'New contact created!', true);
                } else {
                    matchLog += matchingLog(null, new List<Contact>(), 'Match not found using Duplicate Rule <em>' + matchType.get(reg.Event__c) + '</em>', 'Contact creation skipped based on "Contact Matching Skip Contact Creation" field value on Summit Events object', false);
                    matchLog += '<hr>' + searchForLead(reg, event, leadMatch.get(reg.Event__c));
                }
            } else if (matchContacts.size() == 1) {
                reg.Contact__c = matchContacts[0].Id;
                reg.New_Contact_Created__c = false;
                matchLog += matchingLog(reg, new List<Contact>(), 'Match found using Salesforce Duplicate Rule <em>' + matchType.get(reg.Event__c).replaceAll('_', ' ') + '</em>', '', false);
            } else {
                if (event.Contact_Matching_Multiple_Match_Behavior__c == 'Skip matching') {
                    matchLog += matchingLog(null, matchContacts, 'Multiple matches found using Salesforce Duplicate Rule <em>' + matchType.get(reg.Event__c).replaceAll('_', ' ') + '</em>, Contact matching skipped based on "Contact Matching Multiple Match Behavior" field value on Summit Events object', '', false);
                } else if (event.Contact_Matching_Multiple_Match_Behavior__c == 'Match with most recently modified') {
                    matchLog += matchingLog(null, matchContacts, 'Multiple matches found using Salesforce Duplicate Rule <em>' + matchType.get(reg.Event__c).replaceAll('_', ' ') + '</em>, Most recently modified Contact was selected based on "Contact Matching Multiple Match Behavior" field value on Summit Events object', '', true);
                    reg.Contact__c = matchContacts[0].Id;
                }
            }
            reg.Matching_Log__c = matchLog;
        }
    }

    private static void leadSearch(List<Summit_Events_Registration__c> newRegistrations) {
        Map<Id, String> leadMatch = new Map<Id, String>();
        Map<Id, Summit_Events__c> allEvents = new Map<Id, Summit_Events__c>();
        if (Schema.SObjectType.Summit_Events__c.isAccessible()) {
            for (Summit_Events__c event : [
                    SELECT Id,
                            Contact_Creation_Duplicate_Rule__c, Custom_Metadata_Contact_Matching_Method__c, Contact_Matching_Multiple_Match_Behavior__c, Contact_Matching_No_Match_Behavior__c,
                            Lead_Creation_Duplicate_Rule__c, Custom_Metadata_Lead_Matching_Method__c, Lead_Matching_Multiple_Match_Behavior__c, Lead_Matching_No_Match_Behavior__c, Lead_matching_rules__c
                    FROM Summit_Events__c
                    WHERE Id IN (
                            SELECT Event__c
                            FROM Summit_Events_Registration__c
                            WHERE Id IN :newRegistrations
                    )
            ]) {
                String leadRuleName = event.Lead_Creation_Duplicate_Rule__c.replaceAll(' ', '_');

                leadMatch.put(event.Id, leadRuleName);
                allEvents.put(event.Id, event);
            }
        }

        for (Summit_Events_Registration__c newReg : newRegistrations) {
            newReg.Matching_Log__c = searchForLead(newReg, allEvents.get(newReg.Event__c), leadMatch.get(newReg.Event__c));
        }
    }

    private static String searchForLead(Summit_Events_Registration__c reg, Summit_Events__c event, String matchingRule) {
        Lead l = makeLead(reg, event.Custom_Metadata_Lead_Matching_Method__c);

        List<Datacloud.FindDuplicatesResult> results = new List<Datacloud.FindDuplicatesResult>();
        doCRUD crud = new doCRUD();

        try { // Datacloud.FindDuplicates returns an error if no matching rules are active
            List<Lead> leads = new List<Lead>();
            leads.add(l);
            results = crud.findDuplicateLeads(leads);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        List<Lead> matchLeads = new List<Lead>();
        if (results.size() > 0) {
            for (Datacloud.DuplicateResult dr : results[0].getDuplicateResults()) {
                System.debug(matchingRule);
                System.debug(dr.getDuplicateRule());

                if (matchingRule == dr.getDuplicateRule()) {
                    for (Datacloud.MatchResult mr : dr.getMatchResults()) {
                        for (Datacloud.MatchRecord mRecord : mr.getMatchRecords()) {
                            try {
                                Lead led = (Lead) mRecord.getRecord();
                                matchLeads.add(led);
                            } catch (Exception e){
                                System.debug(e);
                            }
                        }
                    }
                }
            }
        }

        if (!matchLeads.isEmpty()) {
            List<Id> foundIds = new List<Id>();
            for (Lead led : matchLeads) {
                foundIds.add(led.Id);
            }
            matchLeads = crud.findLeads(foundIds);
        }

        String matchLog = '';
        if (matchLeads == null || matchLeads.isEmpty()) { // SOQL queries return null instead of empty lists
            if (event.Lead_Matching_No_Match_Behavior__c == 'Create Lead') {
                for (Summit_Events_Lead_Matching_Mapping__mdt mapping : [
                        SELECT Lead_Field_API_Name__c, Source_Value__c, Source_Type__c
                        FROM Summit_Events_Lead_Matching_Mapping__mdt
                        WHERE Lead_Matching_Method__c = :event.Custom_Metadata_Lead_Matching_Method__c AND Matching_Only__c = TRUE
                ]) {
                    l.put(mapping.Lead_Field_API_Name__c, null);
                }

                crud.addRecord(l);
                reg.New_Lead_Created__c = true;
                reg.Lead__c = l.Id;
                matchLog += matchingLog(reg, new List<Lead>(), 'Match not found using Duplicate Rule <em>' + matchingRule + '</em></div>', 'New lead created!', true);
            } else {
                matchLog += matchingLog(null, new List<Lead>(), 'Match not found using Duplicate Rule <em>' + matchingRule + '</em>', 'Lead creation skipped based on "Lead Matching Skip Lead Creation" field value on Summit Events object', true);
            }
        } else if (matchLeads.size() == 1) {
            reg.Lead__c = matchLeads[0].Id;
            reg.New_Lead_Created__c = false;
            matchLog += matchingLog(reg, new List<Lead>(), 'Match found using Salesforce Duplicate Rule <em>' + matchingRule.replaceAll('_', ' ') + '</em>', '', false);
        } else {
            if (event.Lead_Matching_Multiple_Match_Behavior__c == 'Skip matching') {
                matchLog += matchingLog(null, matchLeads, 'Multiple matches found using Salesforce Duplicate Rule <em>' + matchingRule.replaceAll('_', ' ') + '</em>, Lead matching skipped based on "Lead Matching Multiple Match Behavior" field value on Summit Events object', '', false);
            } else if (event.Lead_Matching_Multiple_Match_Behavior__c == 'Match with most recently modified') {
                matchLog += matchingLog(null, matchLeads, 'Multiple matches found using Salesforce Duplicate Rule <em>' + matchingRule.replaceAll('_', ' ') + '</em>, Most recently modified Lead was selected based on "Lead Matching Multiple Match Behavior" field value on Summit Events object', '', true);
                reg.Lead__c = matchLeads[0].Id;
            }
        }

        return matchLog;
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

        SObjectType r = ((SObject) (Type.forName('Schema.Contact').newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();

        if (Schema.SObjectType.Summit_Events_Contact_Matching_Mapping__mdt.isAccessible()) {
            for (Summit_Events_Contact_Matching_Mapping__mdt mapping : [
                    SELECT Contact_Field_API_Name__c, Source_Value__c, Source_Type__c
                    FROM Summit_Events_Contact_Matching_Mapping__mdt
                    WHERE Contact_Matching_Method__c = :matchingMethod
                    AND Source_Object__c = 'summit__Summit_Events_Registration__c'
                    AND Source_Type__c = 'Field'
            ]) {
                Schema.DisplayType fieldType = d.fields.getMap().get(mapping.Contact_Field_API_Name__c).getDescribe().getType();

                if (fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.CURRENCY) {
                    c.put(mapping.Contact_Field_API_Name__c, Double.valueOf(reg.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                    c.put(mapping.Contact_Field_API_Name__c, Boolean.valueOf(reg.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.DATE) {
                    c.put(mapping.Contact_Field_API_Name__c, Date.valueOf(reg.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.DATETIME) {
                    c.put(mapping.Contact_Field_API_Name__c, Datetime.valueOf(reg.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.INTEGER) {
                    c.put(mapping.Contact_Field_API_Name__c, Integer.valueOf(reg.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.PERCENT) {
                    c.put(mapping.Contact_Field_API_Name__c, Double.valueOf(reg.get(mapping.Source_Value__c)) / 100);
                } else {
                    c.put(mapping.Contact_Field_API_Name__c, reg.get(mapping.Source_Value__c));
                }
            }

            for (Summit_Events_Contact_Matching_Mapping__mdt mapping : [
                    SELECT Contact_Field_API_Name__c, Source_Value__c, Source_Type__c
                    FROM Summit_Events_Contact_Matching_Mapping__mdt
                    WHERE Contact_Matching_Method__c = :matchingMethod
                    AND Source_Type__c = 'Hardcoded'
            ]) {
                Schema.DisplayType fieldType = d.fields.getMap().get(mapping.Contact_Field_API_Name__c).getDescribe().getType();

                if (fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.CURRENCY) {
                    c.put(mapping.Contact_Field_API_Name__c, Double.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                    c.put(mapping.Contact_Field_API_Name__c, Boolean.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.DATE) {
                    c.put(mapping.Contact_Field_API_Name__c, Date.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.DATETIME) {
                    c.put(mapping.Contact_Field_API_Name__c, Datetime.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.INTEGER) {
                    c.put(mapping.Contact_Field_API_Name__c, Integer.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.PERCENT) {
                    c.put(mapping.Contact_Field_API_Name__c, Double.valueOf(mapping.Source_Value__c) / 100);
                } else {
                    c.put(mapping.Contact_Field_API_Name__c, mapping.Source_Value__c);
                }
            }
        }

        return c;
    }

    private static Lead makeLead(Summit_Events_Registration__c reg, String matchingMethod) {
        Lead l = new Lead();
        l.FirstName = reg.Registrant_First_Name__c;
        l.LastName = reg.Registrant_Last_Name__c;
        l.Email = reg.Registrant_Email__c;
        l.Company = reg.Preferred_First_Name_Formatted__c;

        l.Street = reg.Registrant_Street_1__c;
        l.City = reg.Registrant_City__c;
        l.State = reg.Registrant_State__c;
        l.PostalCode = reg.Registrant_Zip__c != '' ? reg.Registrant_Zip__c : reg.Registrant_Postal_Code__c;
        l.Country = reg.Registrant_Country__c;

        l.Phone = reg.Registrant_Phone__c;
        l.MobilePhone = reg.Registrant_Mobile_Phone__c;

        SObjectType r = ((SObject) (Type.forName('Schema.Lead').newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();

        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace + '__';
        }


        if (Schema.SObjectType.Summit_Events_Lead_Matching_Mapping__mdt.isAccessible()) {
            for (Summit_Events_Lead_Matching_Mapping__mdt mapping : [
                    SELECT Lead_Field_API_Name__c, Source_Value__c, Source_Type__c
                    FROM Summit_Events_Lead_Matching_Mapping__mdt
                    WHERE Lead_Matching_Method__c = :matchingMethod
                    AND Source_Object__c = 'Summit_Events_Registration__c'
                    AND Source_Type__c = 'Field'
            ]) {
                Schema.DisplayType fieldType = d.fields.getMap().get(mapping.Lead_Field_API_Name__c).getDescribe().getType();

                if (fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.CURRENCY) {
                    l.put(mapping.Lead_Field_API_Name__c, Double.valueOf(reg.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                    l.put(mapping.Lead_Field_API_Name__c, Boolean.valueOf(reg.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.DATE) {
                    l.put(mapping.Lead_Field_API_Name__c, Date.valueOf(reg.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.DATETIME) {
                    l.put(mapping.Lead_Field_API_Name__c, Datetime.valueOf(reg.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.INTEGER) {
                    l.put(mapping.Lead_Field_API_Name__c, Integer.valueOf(reg.get(mapping.Source_Value__c)));
                } else if (fieldType == Schema.DisplayType.PERCENT) {
                    l.put(mapping.Lead_Field_API_Name__c, Double.valueOf(reg.get(mapping.Source_Value__c)) / 100);
                } else {
                    l.put(mapping.Lead_Field_API_Name__c, reg.get(mapping.Source_Value__c));
                }
            }

            for (Summit_Events_Lead_Matching_Mapping__mdt mapping : [
                    SELECT Lead_Field_API_Name__c, Source_Value__c, Source_Type__c
                    FROM Summit_Events_Lead_Matching_Mapping__mdt
                    WHERE Lead_Matching_Method__c = :matchingMethod
                    AND Source_Type__c = 'Hardcoded'
            ]) {
                Schema.DisplayType fieldType = d.fields.getMap().get(mapping.Lead_Field_API_Name__c).getDescribe().getType();

                if (fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.CURRENCY) {
                    l.put(mapping.Lead_Field_API_Name__c, Double.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                    l.put(mapping.Lead_Field_API_Name__c, Boolean.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.DATE) {
                    l.put(mapping.Lead_Field_API_Name__c, Date.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.DATETIME) {
                    l.put(mapping.Lead_Field_API_Name__c, Datetime.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.INTEGER) {
                    l.put(mapping.Lead_Field_API_Name__c, Integer.valueOf(mapping.Source_Value__c));
                } else if (fieldType == Schema.DisplayType.PERCENT) {
                    l.put(mapping.Lead_Field_API_Name__c, Double.valueOf(mapping.Source_Value__c) / 100);
                } else {
                    l.put(mapping.Lead_Field_API_Name__c, mapping.Source_Value__c);
                }
            }
        }

        System.debug(matchingMethod + ' - ' + l);

        return l;
    }

    private static String matchingLog(Summit_Events_Registration__c registration, List<Contact> foundContacts, String heading1, String heading2, Boolean isNew) {
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
                mOut += matchingRow(registration.Id, registration.Registrant_Last_Name__c, registration.Registrant_First_Name__c, registration.Registrant_Email__c, registration.Registrant_Zip__c, (isNew ? 'Created' : 'Matched'));
            }
            Boolean isFirst = isNew;
            for (Contact con : foundContacts) {
                mOut += matchingRow(con.Id, con.LastName, con.FirstName, con.Email, con.MailingPostalCode, isFirst ? 'Selected' : 'Skipped');
                isFirst = false;
            }
            mOut += '</tbody></table>';
        }
        return mOut;
    }

    private static String matchingLog(Summit_Events_Registration__c registration, List<Lead> foundLeads, String heading1, String heading2, Boolean isNew) {
        String mOut = '';
        if (String.isNotBlank(heading1)) {
            mOut += '<div class="slds-text-heading_small slds-m-vertical_medium">' + heading1 + '</div>';
        }
        if (String.isNotBlank(heading2)) {
            mOut += '<div class="slds-text-heading_small slds-m-vertical_medium">' + heading2 + '</div>';
        }
        if (registration != null || foundLeads.size() > 0) {
            mOut += '<table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered slds-size_1-of-1">';
            mOut += '<thead><tr class="slds-line-height_reset">';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="Last Name">Last Name</div></th>';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="First Name">First Name</div></th>';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="Email">Email</div></th>';
            mOut += '<th class="" scope="col"><div class="slds-truncate" title="Action">Action</div></th>';
            mOut += '</tr></thead>';
            mOut += '<tbody>';
            if (registration != null) {
                mOut += matchingRow(registration.Id, registration.Registrant_Last_Name__c, registration.Registrant_First_Name__c, registration.Registrant_Email__c, (isNew ? 'Created' : 'Matched'));
            }
            Boolean isFirst = isNew;
            for (Lead led : foundLeads) {
                mOut += matchingRow(led.Id, led.LastName, led.FirstName, led.Email, isFirst ? 'Selected' : 'Skipped');
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
        matchRow += '<td data-label="Email"><div class="slds-truncate">' + (String.isNotBlank(Email) ? Email : '') + '</div></td>';
        matchRow += '<td data-label="Zip"><div class="slds-truncate">' + (String.isNotBlank(Zip) ? Zip : '') + '</div></td>';
        matchRow += '<td data-label="Action"><div class="slds-truncate"> ' + (String.isNotBlank(Action) ? Action : '') + ' </div></td>';
        matchRow += '</tr>';
        return matchRow;
    }

    private static String matchingRow(String ContactId, String LastName, String FirstName, String Email, String Action) {
        String matchRow = '';
        matchRow += '<tr class="slds-hint-parent">';
        matchRow += '<td data-label="Last Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + LastName + '</a></div></td>';
        matchRow += '<td data-label="First Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + FirstName + '</a></div></td>';
        matchRow += '<td data-label="Email"><div class="slds-truncate">' + (String.isNotBlank(Email) ? Email : '') + '</div></td>';
        matchRow += '<td data-label="Action"><div class="slds-truncate"> ' + (String.isNotBlank(Action) ? Action : '') + ' </div></td>';
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

        public List<Lead> findLeads(List<Id> foundIds) {
            List<Lead> leadsFound = [
                    SELECT Id, LastName, FirstName, Email
                    FROM Lead
                    WHERE Id IN :foundIds
                    ORDER BY LastModifiedDate DESC
            ];
            return leadsFound;
        }

        public SObject addRecord(SObject recordToAdd) {
            try {
                upsert recordToAdd;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
            return recordToAdd;
        }

        public List<Datacloud.FindDuplicatesResult> findDuplicateContacts(List<Contact> cons) {
            return Datacloud.FindDuplicates.findDuplicates(cons);
        }

        public List<Datacloud.FindDuplicatesResult> findDuplicateLeads(List<Lead> leads) {
            return Datacloud.FindDuplicates.findDuplicates(leads);
        }
    }
}
