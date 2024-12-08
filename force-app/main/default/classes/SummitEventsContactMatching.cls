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
            matchingRules = new Map<Id, Summit_Events__c>([
                    SELECT Id, Contact_Matching_Rules__c, Lead_matching_rules__c, Person_Matching_Rules__c,
                            Contact_Creation_Duplicate_Rule__c, Custom_Metadata_Contact_Matching_Method__c, Contact_Matching_Multiple_Match_Behavior__c, Contact_Matching_No_Match_Behavior__c,
                            Lead_Creation_Duplicate_Rule__c, Custom_Metadata_Lead_Matching_Method__c, Lead_Matching_Multiple_Match_Behavior__c, Lead_Matching_No_Match_Behavior__c
                    FROM Summit_Events__c
                    WHERE Id IN :matchingRules.keySet()
                    AND (Custom_Metadata_Contact_Matching_Method__c != null OR Custom_Metadata_Lead_Matching_Method__c != null)
            ]);
        }

        if (!matchingRules.isEmpty()) {

            // Setting up contact matching methods and mappings
            Set<String> matchingMethods = new Set<String>();
            Map<String, List<SObject>> contactMappings = new Map<String, List<SObject>>();
            for (Summit_Events__c evt : matchingRules.values()) {
                matchingMethods.add(evt.Custom_Metadata_Contact_Matching_Method__c);
            }
            if (!matchingMethods.isEmpty()) {
                contactMappings = processMappings(matchingMethods, 'Summit_Events_Contact_Matching_Mapping__mdt', 'Contact_Matching_Method__c', 'Contact_Field_API_Name__c');
            }

            // Setting up lead matching methods and mappings
            Set<String> leadMatchingMethods = new Set<String>();
            Map<String, List<SObject>> leadMappings = new Map<String, List<SObject>>();
            for (Summit_Events__c evt : matchingRules.values()) {
                leadMatchingMethods.add(evt.Custom_Metadata_Lead_Matching_Method__c);
            }
            if (!leadMatchingMethods.isEmpty()) {
                leadMappings = processMappings(leadMatchingMethods, 'Summit_Events_Lead_Matching_Mapping__mdt', 'Lead_Matching_Method__c', 'Lead_Field_API_Name__c');
            }

            List<Summit_Events_Registration__c> byDuplicateRule = new List<Summit_Events_Registration__c>();
            List<Summit_Events_Registration__c> findLead = new List<Summit_Events_Registration__c>();
            List<Summit_Events_Registration__c> findPerson = new List<Summit_Events_Registration__c>();

            for (Summit_Events_Registration__c reg : newRegistrations) {

                // Find out if Answers are integers and apply to numeric answer fields if so
                for (Integer i = 1; i <= 5; i++) {
                    try {
                        reg.put('Answer_' + i + '_Numeric__c', Integer.valueOf(reg.get('Add_Info_Answer_' + i + '__c')));
                    } catch (Exception e) {
                        //Can't convert to value to integer so do nothing
                    }
                }

                // Assemble the reg record for lead, person, contact matching
                Summit_Events__c event = matchingRules.get(reg.Event__c);
                if (event.Contact_Matching_Rules__c == 'Use Salesforce Duplicate Rule' && String.isBlank(reg.Contact__c)) {
                    byDuplicateRule.add(reg);
                } else if (event.Lead_matching_rules__c == 'Use Salesforce Duplicate Rule' && String.isBlank(reg.Contact__c) && String.isBlank(reg.Lead__c)) {
                    findLead.add(reg);
                } else if (event.Person_Matching_Rules__c == 'Use Salesforce Duplicate Rule' && String.isBlank(reg.Person_Account__c)) {
                    findPerson.add(reg);
                }
            }

            if (!byDuplicateRule.isEmpty()) {
                searchForContacts(byDuplicateRule, matchingRules, contactMappings, leadMappings);
            }

            if (!findLead.isEmpty()) {
                leadSearch(findLead, matchingRules, leadMappings);
            }

            if (!findPerson.isEmpty()) {
                //personSearch(findPerson, matchingRules, contactMappings);
            }
        }
    }

    private static Map<String, List<SObject>> processMappings(
            Set<String> matchingMethods,
            String sObjectType,
            String fieldAPIName,
            String sourceValue) {
        Map<String, List<SObject>> mappings = new Map<String, List<SObject>>();
        if (matchingMethods.size() > 0) {
            String query = 'SELECT Source_Value__c, Source_Type__c, ' + fieldAPIName + ', ' + sourceValue + ' FROM ' + sObjectType + ' WHERE ' + fieldAPIName + ' IN :matchingMethods';
            List<SObject> results = Database.query(query);
            for (SObject mapping : results) {
                String method = (String) mapping.get(fieldAPIName);
                if (!mappings.containsKey(method)) {
                    mappings.put(method, new List<SObject>());
                }
                mappings.get(method).add(mapping);
            }
        }
        return mappings;
    }

    private static void searchForContacts(List<Summit_Events_Registration__c> newRegistrations, Map<Id, Summit_Events__c> matchingRules, Map<String, List<SObject>> contactMappings, Map<String, List<SObject>> leadMappings) {
        // Find out which Registrations need new Contacts, creates them,
        // and matches with existing Contacts whenever possible as defined by existing Duplicate Rules
        for (Summit_Events_Registration__c reg : newRegistrations) {
            Summit_Events__c event = matchingRules.get(reg.Event__c);
            Contact c = makeContact(reg, event.Custom_Metadata_Contact_Matching_Method__c, contactMappings);
            doCRUD crud = new doCRUD();
            String matchType = matchingRules.get(reg.Event__c).Contact_Creation_Duplicate_Rule__c.replaceAll(' ', '_');
            List<Contact> matchContacts = findMatches(c, matchType);
            System.debug('matchContacts: ' + JSON.serializePretty(matchContacts));
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
                    crud.addRecord(c);
                    reg.New_Contact_Created__c = true;
                    reg.Contact__c = c.Id;
                    matchLog += matchingLog(reg, new List<Contact>(), 'Match not found using Duplicate Rule <em>' + matchingRules.get(reg.Event__c).Contact_Creation_Duplicate_Rule__c.replaceAll(' ', '_') + '</em></div>', 'New contact created!', true);
                } else {
                    matchLog += matchingLog(null, new List<Contact>(), 'Match not found using Duplicate Rule <em>' + matchType + '</em>', 'Contact creation skipped based on "Contact Matching Skip Contact Creation" field value on Summit Events object', false);
                    matchLog += '<hr>';
                    String leadMatch = matchingRules.get(reg.Event__c).Lead_Creation_Duplicate_Rule__c;
                    if (String.isNotBlank(leadMatch)) {
                        leadMatch = leadMatch.replaceAll(' ', '_');
                        matchLog += searchForLead(reg, event, leadMatch, leadMappings);
                    }
                }
            } else if (matchContacts.size() == 1) {
                reg.Contact__c = matchContacts[0].Id;
                reg.New_Contact_Created__c = false;
                matchLog += matchingLog(reg, new List<Contact>(), 'Match found using Salesforce Duplicate Rule <em>' + matchType + '</em>', '', false);
            } else {
                if (event.Contact_Matching_Multiple_Match_Behavior__c == 'Skip matching') {
                    matchLog += matchingLog(null, matchContacts, 'Multiple matches found using Salesforce Duplicate Rule <em>' + matchType + '</em>, Contact matching skipped based on "Contact Matching Multiple Match Behavior" field value on Summit Events object', '', false);
                } else if (event.Contact_Matching_Multiple_Match_Behavior__c == 'Match with most recently modified') {
                    matchLog += matchingLog(null, matchContacts, 'Multiple matches found using Salesforce Duplicate Rule <em>' + matchType + '</em>, Most recently modified Contact was selected based on "Contact Matching Multiple Match Behavior" field value on Summit Events object', '', true);
                    reg.Contact__c = matchContacts[0].Id;
                }
            }
            reg.Matching_Log__c = matchLog;
        }
    }

    private static void leadSearch(List<Summit_Events_Registration__c> newRegistrations, Map<Id, Summit_Events__c> matchingRules, Map<String, List<SObject>> leadMappings) {
        for (Summit_Events_Registration__c newReg : newRegistrations) {
            Summit_Events__c seaEvent = matchingRules.get(newReg.Event__c);
            String leadRuleName = matchingRules.get(newReg.Event__c).Lead_Creation_Duplicate_Rule__c;
            newReg.Matching_Log__c = searchForLead(newReg, seaEvent, leadRuleName, leadMappings);
        }
    }

    private static String searchForLead(Summit_Events_Registration__c reg, Summit_Events__c event, String matchingRule, Map<String, List<SObject>> leadMappings) {

        //Matching rules match be label
        matchingRule = matchingRule.replaceAll(' ', '_');
        Lead l = makeLead(reg, event.Custom_Metadata_Lead_Matching_Method__c, leadMappings);
        List<Lead> matchLeads = findMatches(l, matchingRule);
        doCRUD crud = new doCRUD();
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
                crud.addRecord(l);
                reg.New_Lead_Created__c = true;
                reg.Lead__c = l.Id;
                matchLog += matchingLog(reg, new List<Lead>(), 'Match not found using Duplicate Rule <em>' + matchingRule + '</em></div>', '<a href="/' + l.Id + '" target="_blank">New lead created!</a>', true);
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

    private static List<SObject> findMatches(SObject record, String matchingRule) {
        List<Datacloud.FindDuplicatesResult> results = new List<Datacloud.FindDuplicatesResult>();
        doCRUD crud = new doCRUD();

        List<SObject> recordsFound = new List<SObject>();
        recordsFound.add(record);
        // Datacloud.FindDuplicates returns an error if no matching rules are active
        try {
            results = crud.findDuplicatesResults(recordsFound);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        List<SObject> matchSObjects = new List<SObject>();
        if (results.size() > 0) {
            for (Datacloud.DuplicateResult dr : results[0].getDuplicateResults()) {

                if (matchingRule == dr.getDuplicateRule()) {
                    for (Datacloud.MatchResult mr : dr.getMatchResults()) {
                        for (Datacloud.MatchRecord mRecord : mr.getMatchRecords()) {
                            try {
                                matchSObjects.add(mRecord.getRecord());
                            } catch (Exception e) {
                                System.debug(e);
                            }
                        }
                    }
                }
            }
        }
        return matchSObjects;
    }


    private static Contact makeContact(Summit_Events_Registration__c reg, String matchingMethod, Map<String, List<SObject>> contactMappings) {
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

        // Apply any mapped values from custom metadata to the contact
        if (contactMappings.containsKey(matchingMethod)) {
            List<Summit_Events_Contact_Matching_Mapping__mdt> mappings = contactMappings.get(matchingMethod);
            for (Summit_Events_Contact_Matching_Mapping__mdt mapping : mappings) {
                if (mapping.Source_Type__c.equalsIgnoreCase('Hardcoded')) {
                    c = (Contact) applyCorrectFieldTypesToValues(c, mapping.Contact_Field_API_Name__c, mapping.Source_Value__c);
                } else {
                    c = (Contact) applyCorrectFieldTypesToValues(c, mapping.Contact_Field_API_Name__c, reg.get(mapping.Source_Value__c));
                }
            }
        }

        return c;
    }

    private static Lead makeLead(Summit_Events_Registration__c reg, String matchingMethod, Map<String, List<SObject>> leadMappings) {
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

        //Apply any values mapped in custom metadata to the lead
        if (leadMappings.containsKey(matchingMethod)) {
            List<Summit_Events_Lead_Matching_Mapping__mdt> mappings = leadMappings.get(matchingMethod);
            for (Summit_Events_Lead_Matching_Mapping__mdt mapping : mappings) {
                if (mapping.Source_Type__c.equalsIgnoreCase('Hardcoded')) {
                    l = (Lead) applyCorrectFieldTypesToValues(l, mapping.Lead_Field_API_Name__c, mapping.Source_Value__c);
                } else {
                    l = (Lead) applyCorrectFieldTypesToValues(l, mapping.Lead_Field_API_Name__c, reg.get(mapping.Source_Value__c));
                }
            }
        }

        return l;
    }

    private static SObject applyCorrectFieldTypesToValues(SObject l, String objFieldAPIName, Object value) {
        DescribeSObjectResult d = l.getSObjectType().getDescribe();
        Schema.DisplayType fieldType = d.fields.getMap().get(objFieldAPIName).getDescribe().getType();
        if (fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.CURRENCY) {
            l.put(objFieldAPIName, Double.valueOf(value));
        } else if (fieldType == Schema.DisplayType.BOOLEAN) {
            l.put(objFieldAPIName, Boolean.valueOf(value));
        } else if (fieldType == Schema.DisplayType.DATE) {
            l.put(objFieldAPIName, Date.valueOf(value));
        } else if (fieldType == Schema.DisplayType.DATETIME) {
            l.put(objFieldAPIName, Datetime.valueOf(value));
        } else if (fieldType == Schema.DisplayType.INTEGER) {
            l.put(objFieldAPIName, Integer.valueOf(value));
        } else if (fieldType == Schema.DisplayType.PERCENT) {
            l.put(objFieldAPIName, Double.valueOf(value) / 100);
        } else {
            l.put(objFieldAPIName, value);
        }
        return l;
    }

    private static String matchingLog(Summit_Events_Registration__c registration, List<SObject> foundObjects, String heading1, String heading2, Boolean isNew) {
        String mOut = '';
        if (String.isNotBlank(heading1)) {
            mOut += '<div class="slds-text-heading_small slds-m-vertical_medium">' + heading1 + '</div>';
        }
        if (String.isNotBlank(heading2)) {
            mOut += '<div class="slds-text-heading_small slds-m-vertical_medium">' + heading2 + '</div>';
        }

        if (registration != null || foundObjects.size() > 0) {

            //Get the top level data structure of foundObjects
            System.debug('foundObjects: ' + JSON.serializePretty(foundObjects));

            mOut += '<table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered slds-size_1-of-1" style="width:100%">';
            mOut += '<thead><tr class="slds-line-height_reset">';
            mOut += '<th scope="col"><div class="slds-truncate" title="Last Name">Last Name</div></th>';
            mOut += '<th scope="col"><div class="slds-truncate" title="First Name">First Name</div></th>';
            mOut += '<th scope="col"><div class="slds-truncate" title="Email">Email</div></th>';
            mOut += '<th scope="col"><div class="slds-truncate" title="Zip">Zip</div></th>';
            mOut += '<th scope="col"><div class="slds-truncate" title="Action">Action</div></th>';
            mOut += '</tr></thead>';
            mOut += '<tbody>';
            if (registration != null) {
                mOut += matchingRow(registration.Id, registration.Registrant_Last_Name__c, registration.Registrant_First_Name__c, registration.Registrant_Email__c, registration.Registrant_Zip__c, (isNew ? 'Created' : 'Matched'));
            }
            Boolean isFirst = isNew;
            for (SObject sObj : foundObjects) {
                String zip = '';
                if (sObj.getSObjectType() == Lead.SObjectType) {
                    zip = (String) sObj.get('PostalCode');
                } else {
                    zip = (String) sObj.get('MailingPostalCode');
                }
                mOut += matchingRow(
                        (String) sObj.get('Id'),
                        (String) sObj.get('LastName'),
                        (String) sObj.get('FirstName'),
                        (String) sObj.get('Email'),
                        zip,
                        isFirst ? 'Selected' : 'Skipped'
                );
                isFirst = false;
            }
            mOut += '</tbody></table>';
        }
        return mOut;
    }

    private static String matchingRow(String recordId, String LastName, String FirstName, String Email, String Zip, String Action) {
        String matchRow = '';
        matchRow += '<tr class="slds-hint-parent">';
        matchRow += '<td data-label="Last Name"><div class="slds-truncate"><a href="/' + recordId + '" target="_blank">' + LastName + '</a></div></td>';
        matchRow += '<td data-label="First Name"><div class="slds-truncate"><a href="/' + recordId + '" target="_blank">' + FirstName + '</a></div></td>';
        matchRow += '<td data-label="Email"><div class="slds-truncate">' + (String.isNotBlank(Email) ? Email : '') + '</div></td>';
        if (String.isNotBlank(Zip)) {
            matchRow += '<td data-label="Zip"><div class="slds-truncate">' + (String.isNotBlank(Zip) ? Zip : '') + '</div></td>';
        } else {
            matchRow += '<td data-label="Zip">--</td>';
        }
        matchRow += '<td data-label="Action"><div class="slds-truncate"> ' + (String.isNotBlank(Action) ? Action : 'None') + ' </div></td>';
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
                    SELECT Id, LastName, FirstName, Email, PostalCode
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

        public List<Datacloud.FindDuplicatesResult> findDuplicatesResults(List<SObject> cons) {
            return Datacloud.FindDuplicates.findDuplicates(cons);
        }

    }
}