// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 2/27/2019.

public with sharing class SummitEventsContactMatching {

    @TestVisible
    private static Map<String, List<SObject>> mappedMatchingMethods { get; set; }

    //Make a wrapper class to list registrations and their matching contacts
    public class RegistrationContactWrapper {
        public Summit_Events_Registration__c registration { get; set; }
        public List<Contact> contacts { get; set; }
        public List<Account> accounts { get; set; }
        public List<Lead> leads { get; set; }
    }

    public static void matchReg(List<Summit_Events_Registration__c> newRegistrations, List<Summit_Events_Registration__c> oldRegistrations) {
        Map<Id, Summit_Events__c> matchingRules = new Map<Id, Summit_Events__c>();

        for (Summit_Events_Registration__c reg : newRegistrations) {
            matchingRules.put(reg.Event__c, null);
        }
        //Map old reg id to reg
        Map<Id, Summit_Events_Registration__c> oldRegMap = new Map<Id, Summit_Events_Registration__c>();
        if (oldRegistrations != null) {
            for (Summit_Events_Registration__c reg : oldRegistrations) {
                oldRegMap.put(reg.Id, reg);
            }
        }

        if (Schema.SObjectType.Summit_Events__c.isAccessible()) {
            matchingRules = new Map<Id, Summit_Events__c>([
                    SELECT Id, Contact_Matching_Rules__c, Lead_matching_rules__c, Person_Matching_Rules__c, Custom_Metadata_Person_Matching_Method__c, Person_Creation_Duplicate_Rule__c, Person_Matching_No_Match_Behavior__c,
                            Contact_Creation_Duplicate_Rule__c, Custom_Metadata_Contact_Matching_Method__c, Contact_Matching_Multiple_Match_Behavior__c, Contact_Matching_No_Match_Behavior__c,
                            Lead_Creation_Duplicate_Rule__c, Custom_Metadata_Lead_Matching_Method__c, Lead_Matching_Multiple_Match_Behavior__c, Lead_Matching_No_Match_Behavior__c, Person_Matching_Multiple_Match_Behavior__c
                    FROM Summit_Events__c
                    WHERE Id IN :matchingRules.keySet()
                    AND (Custom_Metadata_Contact_Matching_Method__c != NULL OR Custom_Metadata_Lead_Matching_Method__c != NULL OR Custom_Metadata_Person_Matching_Method__c != NULL)
            ]);
        }

        if (!matchingRules.isEmpty()) {
            Boolean personAccountActive = SummitEventsShared.personAccountsEnabled();
            // Setting up contact matching methods and mappings
            Set<String> matchingMethods = new Set<String>();
            Set<String> personMatchingMethods = new Set<String>();
            Map<String, List<SObject>> contactMappings = new Map<String, List<SObject>>();
            Map<String, List<SObject>> personAccountMappings = new Map<String, List<SObject>>();
            for (Summit_Events__c evt : matchingRules.values()) {
                matchingMethods.add(evt.Custom_Metadata_Contact_Matching_Method__c);
                personMatchingMethods.add(evt.Custom_Metadata_Person_Matching_Method__c);
            }
            if (!matchingMethods.isEmpty()) {
                contactMappings = processMappings(matchingMethods, 'Summit_Events_Contact_Matching_Mapping__mdt', 'Contact_Matching_Method__c', 'Contact_Field_API_Name__c');
                personAccountMappings = processMappings(personMatchingMethods, 'Summit_Events_Contact_Matching_Mapping__mdt', 'Contact_Matching_Method__c', 'Contact_Field_API_Name__c');
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

            List<Summit_Events_Registration__c> findContact = new List<Summit_Events_Registration__c>();
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

                //Check and see if person accounts are enabled then use the person account matching rules NOT contact
                Boolean contactEmpty = String.isBlank(reg.Contact__c);
                Boolean personEmpty = String.isBlank(reg.Person_Account__c);

                // Assemble the reg record for lead, person, contact matching
                Summit_Events__c event = matchingRules.get(reg.Event__c);

                //Find all registrations that have Salesforce Duplicate Rule selected
                if (event.Contact_Matching_Rules__c == 'Use Salesforce Duplicate Rule' && contactEmpty && !personAccountActive) {
                    findContact.add(reg);
                }
                if (event.Lead_matching_rules__c == 'Use Salesforce Duplicate Rule' && (!personAccountActive && contactEmpty || personAccountActive && personAccountActive) && String.isBlank(reg.Lead__c)) {
                    findLead.add(reg);
                }
                if (event.Person_Matching_Rules__c == 'Use Salesforce Duplicate Rule' && personEmpty) {
                    findPerson.add(reg);
                }
            }

            List<RegistrationContactWrapper> registrationContactWrappers = new List<RegistrationContactWrapper>();

            if (!findContact.isEmpty() || !findPerson.isEmpty() || !findLead.isEmpty()) {

                for (Summit_Events_Registration__c reg : newRegistrations) {
                    List<Contact> matchContacts = new List<Contact>();
                    List<Account> matchAccounts = new List<Account>();
                    List<Lead> matchLeads = new List<Lead>();
                    Summit_Events__c event = matchingRules.get(reg.Event__c);

                    //Compare old reg to new to see if it should move on
                    Boolean skipThisRegMatching = false;
                    if (String.isNotBlank(reg.Id) && oldRegMap.containsKey(reg.Id)) {
                        Summit_Events_Registration__c oldReg = oldRegMap.get(reg.Id);
                        if (oldReg.Registrant_Email__c == reg.Registrant_Email__c && oldReg.Registrant_First_Name__c == reg.Registrant_First_Name__c && oldReg.Registrant_Last_Name__c == reg.Registrant_Last_Name__c) {
                            skipThisRegMatching = true;
                        }
                    }
                    System.debug(skipThisRegMatching);

                    if (!skipThisRegMatching) {
                        if (!findContact.isEmpty()) {
                            matchContacts = handleMatching(reg, event.Contact_Creation_Duplicate_Rule__c, event.Contact_Matching_No_Match_Behavior__c, event.Contact_Matching_Multiple_Match_Behavior__c, event.Custom_Metadata_Contact_Matching_Method__c, contactMappings, 'Contact', 'Contact__c', 'New_Contact_Created__c');
                        }

                        if (!findPerson.isEmpty()) {
                            matchAccounts = handleMatching(reg, event.Person_Creation_Duplicate_Rule__c, event.Person_Matching_No_Match_Behavior__c, event.Person_Matching_Multiple_Match_Behavior__c, event.Custom_Metadata_Person_Matching_Method__c, personAccountMappings, 'Account', 'Person_Account__c', 'New_Person_Account_Created__c');
                        }

                        if (!findLead.isEmpty()) {
                            matchLeads = handleMatching(reg, event.Lead_Creation_Duplicate_Rule__c, event.Lead_Matching_No_Match_Behavior__c, event.Lead_Matching_Multiple_Match_Behavior__c, event.Custom_Metadata_Lead_Matching_Method__c, leadMappings, 'Lead', 'Lead__c', 'New_Lead_Created__c');
                        }

                        RegistrationContactWrapper rcw = new RegistrationContactWrapper();
                        rcw.registration = reg;
                        rcw.contacts = matchContacts;
                        rcw.accounts = matchAccounts;
                        rcw.leads = matchLeads;
                        registrationContactWrappers.add(rcw);
                    }
                }

                //Get all the IDs for the contacts, accounts, and leads to query them all at once
                Set<Id> accountIds = new Set<Id>();
                Set<Id> contactIds = new Set<Id>();
                Set<Id> leadIds = new Set<Id>();
                for (RegistrationContactWrapper rw : registrationContactWrappers) {
                    for (Contact c : rw.contacts) {
                        contactIds.add(c.Id);
                    }
                    for (Account a : rw.accounts) {
                        accountIds.add(a.Id);
                    }
                    for (Lead l : rw.leads) {
                        leadIds.add(l.Id);
                    }
                }
                //Query all contacts, accounts, and leads to get the most recent data using queryMatchedRecords method. This is to bulkify the query and not inline for each new registration
                Map<Id, SObject> contactsComplete = new Map<Id, SObject>();
                Map<Id, SObject> accountsComplete = new Map<Id, SObject>();
                Map<Id, SObject> leadsComplete = new Map<Id, SObject>();
                if (contactIds.size() > 0) {
                    contactsComplete = new doCRUD().queryMatchedRecords('Email, MailingPostalCode', 'Contact', contactIds);
                }
                if (accountIds.size() > 0 && personAccountActive) {
                    accountsComplete = new doCRUD().queryMatchedRecords('PersonEmail, PersonMailingPostalCode', 'Account', accountIds);
                }
                if (leadIds.size() > 0) {
                    leadsComplete = new doCRUD().queryMatchedRecords('Email, PostalCode', 'Lead', leadIds);
                }

                //Update the registration records with the matched contact, account, and lead records
                for (RegistrationContactWrapper rw : registrationContactWrappers) {
                    List<Contact> contactsQueried = new List<Contact>();
                    List<Account> accountsQueried = new List<Account>();
                    List<Lead> leadsQueried = new List<Lead>();
                    lastModCompare lastModCompare = new lastModCompare();

                    for (Contact c : rw.contacts) {
                        if (contactsComplete.containsKey(c.Id)) {
                            contactsQueried.add((Contact) contactsComplete.get(c.Id));
                        }
                    }
                    contactsQueried.sort(lastModCompare);
                    rw.contacts = contactsQueried;

                    for (Account a : rw.accounts) {
                        if (accountsComplete.containsKey(a.Id)) {
                            accountsQueried.add((Account) accountsComplete.get(a.Id));
                        }
                    }
                    accountsQueried.sort(lastModCompare);
                    rw.accounts = accountsQueried;

                    for (Lead l : rw.leads) {
                        if (leadsComplete.containsKey(l.Id)) {
                            leadsQueried.add((Lead) leadsComplete.get(l.Id));
                        }
                    }
                    leadsQueried.sort(lastModCompare);
                    rw.leads = leadsQueried;
                }

                //Build matching logs for each registration
                for (RegistrationContactWrapper rw : registrationContactWrappers) {
                    Summit_Events__c event = matchingRules.get(rw.registration.Event__c);
                    String matchLogString = rw.registration.Matching_Log__c;
                    matchLogString += handleMatchingLog('Contact', findContact.isEmpty(), event.Contact_Matching_No_Match_Behavior__c, event.Contact_Matching_Multiple_Match_Behavior__c, rw.registration.New_Contact_Created__c, rw.registration.Contact__c, rw.contacts, matchingRules.get(rw.registration.Event__c).Contact_Creation_Duplicate_Rule__c);
                    matchLogString += handleMatchingLog('Person Account', findPerson.isEmpty(), event.Person_Matching_No_Match_Behavior__c, event.Person_Matching_Multiple_Match_Behavior__c, rw.registration.New_Person_Account_Created__c, rw.registration.Person_Account__c, rw.accounts, matchingRules.get(rw.registration.Event__c).Person_Creation_Duplicate_Rule__c);
                    matchLogString += handleMatchingLog('Lead', findLead.isEmpty(), event.Lead_Matching_No_Match_Behavior__c, event.Lead_Matching_Multiple_Match_Behavior__c, rw.registration.New_Lead_Created__c, rw.registration.Lead__c, rw.leads, matchingRules.get(rw.registration.Event__c).Lead_Creation_Duplicate_Rule__c);
                    //html encode the string
                    System.debug(matchLogString);
                    rw.registration.Matching_Log__c = matchLogString;
                }

            }

            System.debug(JSON.serializePretty(newRegistrations));

        }
    }

    // Class to compare Employees by year joined
    public class lastModCompare implements Comparator<SObject> {
        public Integer compare(SObject a, SObject b) {
            Datetime dateA = (Datetime) a.get('LastModifiedDate');
            Datetime dateB = (Datetime) b.get('LastModifiedDate');
            return dateA > dateB ? -1 : dateA == dateB ? 0 : 1;
        }
    }

    private static String handleMatchingLog(String sObjectType, Boolean isEmpty, String noMatchBehavior, String multipleMatchBehavior, Boolean newCreated, Id sObjectId, List<SObject> sObjects, String duplicateRule) {
        String matchLog = '';
        if (!isEmpty) {
            if (noMatchBehavior.startsWithIgnoreCase('create') && newCreated && sObjectId != null) {
                matchLog += matchingLog(sObjects, 'Match not found using Duplicate Rule <em>' + duplicateRule.replaceAll(' ', '_') + '</em></div>', 'New ' + sObjectType + ' created!', true);
            }
            if (!sObjects.isEmpty() && !newCreated) {
                if (multipleMatchBehavior.startsWithIgnoreCase('skip')) {
                    matchLog += matchingLog(sObjects, 'Multiple matches found using Salesforce Duplicate Rule <em>' + duplicateRule.replaceAll(' ', '_') + '</em>, ' + sObjectType + ' matching skipped based on "Multiple Match Behavior" field value on Summit Events object', '', false);
                } else if (multipleMatchBehavior.equals('Match with most recently modified')) {
                    matchLog += matchingLog(sObjects, 'Multiple matches found using Salesforce Duplicate Rule <em>' + duplicateRule.replaceAll(' ', '_') + '</em>, Most recently modified ' + sObjectType + ' was selected based on "Multiple Match Behavior" field value on Summit Events object', '', false);
                }
            }
        }
        return matchLog;
    }

    private static List<SObject> handleMatching(Summit_Events_Registration__c reg, String matchingMethod, String noMatchBehavior, String multipleMatchBehavior, String customMappingType, Map<String, List<SObject>> mappings, String sObjectType, String fieldAPIName, String newFieldAPIName) {
        //Build a Contact, Account, or Lead object
        List<SObject> matches = new List<SObject>();
        if (String.isNotBlank(matchingMethod)) {
            SObject newObj = makeSObject(reg, customMappingType, mappings, sObjectType);
            String matchType = matchingMethod.replaceAll(' ', '_');
            matches = findMatches(newObj, matchType);
            doCRUD crud = new doCRUD();

            if (matches.isEmpty() && noMatchBehavior.startsWithIgnoreCase('Create')) {
                crud.addRecord(newObj);
                reg.put(fieldAPIName, newObj.Id);
                reg.put(newFieldAPIName, true);
                matches.add(newObj);
            } else if (!matches.isEmpty() && multipleMatchBehavior.equals('Match with most recently modified')) {
                reg.put(fieldAPIName, matches.get(0).Id);
                reg.put(newFieldAPIName, false);
            }
        }
        return matches;
    }

    private static SObject makeSObject(Summit_Events_Registration__c reg, String customMappingType, Map<String, List<SObject>> mappings, String sObjectType) {
        if (sObjectType.equals('Contact')) {
            return makeContact(reg, customMappingType, mappings);
        } else if (sObjectType.equals('Account')) {
            return makePerson(reg, customMappingType, mappings);
        } else if (sObjectType.equals('Lead')) {
            return makeLead(reg, customMappingType, mappings);
        }
        return null;
    }

    @TestVisible
    private static Map<String, List<SObject>> processMappings(Set <String> matchingMethods, String sObjectType, String fieldAPIName, String sourceValue) {
        String namespace = SummitEventsNamespace.StrTokenNSPrefix('');
        mappedMatchingMethods = new Map<String, List<SObject>>();
        if (mappedMatchingMethods.isEmpty()) {
            if (matchingMethods.size() > 0) {
                String query = 'SELECT Source_Value__c, Source_Type__c, ' + fieldAPIName + ', ' + sourceValue + ' FROM ' + namespace + sObjectType + ' WHERE ' + fieldAPIName + ' IN :matchingMethods';
                List<SObject> results = Database.query(query);
                for (SObject mapping : results) {
                    String method = (String) mapping.get(fieldAPIName);
                    if (!mappedMatchingMethods.containsKey(method)) {
                        mappedMatchingMethods.put(method, new List<SObject>());
                    }
                    mappedMatchingMethods.get(method).add(mapping);
                }
            }
        }
        return mappedMatchingMethods;
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
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                if (matchingRule == dupeResult.getDuplicateRule()) {
                    for (Datacloud.MatchResult mr : dupeResult .getMatchResults()) {
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
        c = (Contact) applyMappings(c, matchingMethod, contactMappings, reg);

        return c;
    }

    private static SObject applyMappings(SObject record, String matchingMethod, Map<String, List<SObject>> mappings, Summit_Events_Registration__c reg) {
        if (mappings.containsKey(matchingMethod)) {
            List<SObject> mappingList = mappings.get(matchingMethod);
            for (SObject mapping : mappingList) {
                String sourceType = (String) mapping.get('Source_Type__c');
                String fieldAPIName = (String) mapping.get('Contact_Field_API_Name__c');
                Object value = sourceType.equalsIgnoreCase('Hardcoded') ? mapping.get('Source_Value__c') : reg.get((String) mapping.get('Source_Value__c'));
                record = applyCorrectFieldTypesToValues(record, fieldAPIName, value);
            }
        }
        return record;
    }

    private static Account makePerson(Summit_Events_Registration__c reg, String customMappingType, Map<String, List<SObject>> contactMappings) {
        Account personAccount = new Account();
        Boolean personAccountActive = SummitEventsShared.personAccountsEnabled();
        try {

            //Assign the value to account with put method to avoid conflicting when person accounts are not enabled
            if (personAccountActive) {
                Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                personAccount.put('RecordTypeId', personAccountRecordTypeId);
                personAccount.put('PersonEmail', reg.Registrant_Email__c);
                personAccount.put('PersonBirthdate', reg.Registrant_Date_of_Birth__c);
                personAccount.put('PersonMailingStreet', reg.Registrant_Street_1__c);
                personAccount.put('PersonMailingCity', reg.Registrant_City__c);
                personAccount.put('PersonMailingState', reg.Registrant_State__c);
                personAccount.put('PersonMailingPostalCode', reg.Registrant_Zip__c != '' ? reg.Registrant_Zip__c : reg.Registrant_Postal_Code__c);
                personAccount.put('PersonMailingCountry', reg.Registrant_Country__c);
                personAccount.put('PersonHomePhone', reg.Registrant_Phone__c);
                personAccount.put('PersonMobilePhone', reg.Registrant_Mobile_Phone__c);
                personAccount.put('FirstName', reg.Registrant_First_Name__c);
                personAccount.put('LastName', reg.Registrant_Last_Name__c);
            }
            //personAccount.put('PersonContact.Created_with_Summit_Events__c', true);
        } catch (Exception e) {
            System.debug(e.getMessage() + ' - Person Accounts are not enabled');
        }

        // Apply any mapped values from custom metadata to the contact
        personAccount = (Account) applyMappings(personAccount, customMappingType, contactMappings, reg);
        return personAccount;
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
        l = (Lead) applyMappings(l, matchingMethod, leadMappings, reg);

        return l;
    }

    @TestVisible
    private static SObject applyCorrectFieldTypesToValues(SObject l, String objFieldAPIName, Object value) {
        DescribeSObjectResult d = l.getSObjectType().getDescribe();
        if (d.fields.getMap().containsKey(objFieldAPIName)) {
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
        }
        return l;
    }

    @TestVisible
    private static String matchingLog(List<SObject> foundObjects, String heading1, String heading2, Boolean isNew) {
        String mOut = '';
        if (String.isNotBlank(heading1)) {
            mOut += '<div class="slds-text-heading_small slds-m-vertical_medium"><p>' + heading1 + '</p></div>';
        }
        if (String.isNotBlank(heading2)) {
            mOut += '<div class="slds-text-heading_small slds-m-vertical_medium"><p>' + heading2 + '</p></div>';
        }

        if (foundObjects.size() > 0) {
            mOut += '<table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered slds-size_1-of-1" style="width:100%">';
            mOut += '<thead>';
            mOut += '<tr class="slds-line-height_reset">';
            mOut += '<th scope="col"><div class="slds-truncate" title="Last Name">Last Name</div></th>';
            mOut += '<th scope="col"><div class="slds-truncate" title="First Name">First Name</div></th>';
            mOut += '<th scope="col"><div class="slds-truncate" title="Email">Email</div></th>';
            mOut += '<th scope="col"><div class="slds-truncate" title="Zip">Zip</div></th>';
            mOut += '<th scope="col"><div class="slds-truncate" title="Modified">Modified</div></th>';
            mOut += '<th scope="col"><div class="slds-truncate" title="Action">Action</div></th>';
            mOut += '</tr>';
            mOut += '</thead>';
            mOut += '<tbody>';
            Boolean isFirst = true;
            for (SObject sObj : foundObjects) {
                Map<String, Object> sObjMapStringObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(sObj));

                String zip = '---';
                String firstName = '';
                String lastName = '';
                String email = '';

                // Get the org's time zone
                TimeZone orgTimeZone = UserInfo.getTimeZone();

                //Adjust the datetime to reflect the org's time zone
                Datetime lastModifiedDatetime = (Datetime) sObj.get('LastModifiedDate');
                String lastModifiedString = lastModifiedDatetime != null ? lastModifiedDatetime.format('MM/dd/yyyy hh:mm:ss', orgTimeZone.getID()) : '';

                if (sObj.getSObjectType() == Lead.SObjectType) {
                    if (sObjMapStringObj.containsKey('PostalCode')) {
                        zip = (String) sObj.get('PostalCode');
                    }
                    if (sObjMapStringObj.containsKey('Email')) {
                        email = (String) sObj.get('Email');
                    }
                } else if (sObj.getSObjectType() == Account.SObjectType) {
                    if (sObjMapStringObj.containsKey('PersonMailingPostalCode')) {
                        zip = (String) sObj.get('PersonMailingPostalCode');
                    }
                    if (sObjMapStringObj.containsKey('PersonEmail')) {
                        email = (String) sObj.get('PersonEmail');
                    }
                } else if (sObj.getSObjectType() == Contact.SObjectType) {
                    if (sObjMapStringObj.containsKey('MailingPostalCode')) {
                        zip = (String) sObj.get('MailingPostalCode');
                    }
                    if (sObjMapStringObj.containsKey('Email')) {
                        email = (String) sObj.get('Email');
                    }
                }

                if (sObjMapStringObj.containsKey('LastName') && sObjMapStringObj.containsKey('FirstName')) {
                    firstName = (String) sObj.get('FirstName');
                    lastName = (String) sObj.get('LastName');
                } else if (sObjMapStringObj.containsKey('Name')) {
                    String[] name = ((String) sObj.get('Name')).split(' ');
                    if (name.size() > 1) {
                        firstName = name[0];
                        lastName = name[name.size() - 1];
                    } else {
                        lastName = name[0];
                    }
                }

                String action = 'Skipped';
                if (isNew) {
                    action = 'Created';
                } else if (isFirst) {
                    action = 'Selected';
                }

                mOut += matchingRow(
                        (String) sObj.get('Id'),
                        lastName,
                        firstName,
                        email,
                        zip,
                        action,
                        lastModifiedString
                );
                isFirst = false;
            }
            mOut += '</tbody>';
            mOut += '</table>';
        }

        return mOut;
    }

    private static String matchingRow(String recordId, String lastName, String firstName, String email, String zip, String action, String lastModifiedString) {
        String matchRow = '';
        matchRow += '<tr class="slds-hint-parent">';
        matchRow += '<td data-label="Last Name"><div class="slds-truncate"><a href="/' + recordId + '" target="_blank">' + lastName + '</a></div></td>';
        matchRow += '<td data-label="First Name"><div class="slds-truncate"><a href="/' + recordId + '" target="_blank">' + firstName + '</a></div></td>';
        matchRow += '<td data-label="Email"><div class="slds-truncate">' + email + '</div></td>';
        matchRow += '<td data-label="Zip"><div class="slds-truncate">' + zip + '</div></td>';
        matchRow += '<td data-label="Action"><div class="slds-truncate"> ' + lastModifiedString + ' </div></td>';
        matchRow += '<td data-label="Action"><div class="slds-truncate"> ' + action + ' </div></td>';
        matchRow += '</tr>';
        return matchRow;
    }

    private without sharing class doCRUD {

        public SObject addRecord(SObject recordToAdd) {
            try {
                insert recordToAdd;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
            return recordToAdd;
        }

        public Map<Id, SObject> queryMatchedRecords(String queryFields, String sObjectName, Set<Id> matchedIds) {
            // Query all records for matched IDs
            String extraWhere = '';
            Boolean personAccountActive = SummitEventsShared.personAccountsEnabled();
            if (sObjectName == 'Account' && personAccountActive) {
                Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                extraWhere = ' AND IsPersonAccount = true And RecordTypeId = :personAccountRecordTypeId';
            }
            String query = 'SELECT Id, FirstName, LastName, LastModifiedDate, ' + queryFields + ' FROM ' + sObjectName + ' WHERE Id IN :matchedIds ' + extraWhere + ' ORDER BY LastModifiedDate ASC';
            List<SObject> matchedRecords = Database.query(query);

            Map<Id, SObject> matchedRecordsMap = new Map<Id, SObject>();
            for (SObject record : matchedRecords) {
                matchedRecordsMap.put(record.Id, record);
            }
            return matchedRecordsMap;
        }

        public List<Datacloud.FindDuplicatesResult> findDuplicatesResults(List<SObject> record) {
            return Datacloud.FindDuplicates.findDuplicates(record);
        }

    }
}