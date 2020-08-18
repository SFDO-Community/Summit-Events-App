// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 2/27/2019.

public with sharing class SummitEventsContactMatching {
    
    public void matchContacts(List<Summit_Events_Registration__c> newRegistrations){
        Map<Id, Summit_Events__c> matchingRules = new Map<Id, Summit_Events__c>();
        for (Summit_Events_Registration__c reg : newRegistrations){
            matchingRules.put(reg.Event__c, null);
        }
        for (Summit_Events__c event : [SELECT Id, Contact_Matching_Rules__c, Contact_Creation__c FROM Summit_Events__c WHERE Id IN :matchingRules.keyset()]){
            matchingRules.put(event.Id, event);
        }
        
        List<Summit_Events_Registration__c> byDuplicateRule = new List<Summit_Events_Registration__c>();
        for (Summit_Events_Registration__c reg : newRegistrations){
            try {
                reg.Answer_1_Numeric__c = Integer.valueOf(reg.Add_Info_Answer_1__c);
            } catch (Exception e){
                reg.Answer_1_Numeric__c = null;
            }
            Summit_Events__c event = matchingRules.get(reg.Event__c);
            
            if (event.Contact_Matching_Rules__c == 'Matching rules 1' || event.Contact_Matching_Rules__c == 'Matching rules 2'){
                Map<String, String> output = SummitEventsContactMatching(event.Contact_Matching_Rules__c, reg, event.Contact_Creation__c);
                reg.Contact__c = output.get('contactId');
                reg.New_Contact_Created__c = Boolean.valueOf(output.get('newContactCreated'));
                reg.Matching_Log__c = output.get('matchLog');
            } else if (event.Contact_Matching_Rules__c == 'Use Salesforce Duplicate Rule' && String.isBlank(reg.Contact__c)){
                byDuplicateRule.add(reg);
            }
        }
        
        if (!byDuplicateRule.isEmpty()){
            matchContactsByDuplicateRule(byDuplicateRule);
        }
    }
    
    public void matchContactsByDuplicateRule(List<Summit_Events_Registration__c> newRegistrations){
        // Make it easy to tell what Matching Rule we're basing this off of
        Map<Id, String> matchType = new Map<Id, String>();
        Map<Id, String> matchMethod = new Map<Id, String>();
        for (Summit_Events__c event : [SELECT Id, Contact_Creation_Duplicate_Rule__c, Custom_Metadata_Contact_Matching_Method__c
                                               FROM Summit_Events__c
                                               WHERE Id IN (SELECT Event__c FROM Summit_Events_Registration__c WHERE Id IN :newRegistrations)])
        {
            String duplicateRuleName = event.Contact_Creation_Duplicate_Rule__c;
            duplicateRuleName = duplicateRuleName.replaceAll(' ', '_');
            
            matchType.put(event.Id, duplicateRuleName);
            
            matchMethod.put(event.Id, event.Custom_Metadata_Contact_Matching_Method__c);
        }
        
        // Find out which Registrations need new Contacts, creates them, 
        // and matches with existing Contacts whenever possible as defined by existing Duplicate Rules
        List<Contact> newContacts = new List<Contact>();
        for(Summit_Events_Registration__c reg : newRegistrations){
            Contact c = makeContact(reg, matchMethod.get(reg.Event__c));
            
            String matchLogHead = '<table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered slds-size_1-of-1">' +
                '<thead><tr class="slds-line-height_reset">' +
                '<th class="" scope="col"><div class="slds-truncate" title="Last Name">Last Name</div></th>' +
                '<th class="" scope="col"><div class="slds-truncate" title="First Name">First Name</div></th>' +
                '<th class="" scope="col"><div class="slds-truncate" title="Email">Email</div></th>' +
                '<th class="" scope="col"><div class="slds-truncate" title="Zip">Zip</div></th>' +
                '<th class="" scope="col"><div class="slds-truncate" title="Action">Action</div></th>' +
                '</tr></thead>';
            
            List<Datacloud.FindDuplicatesResult> results = new List<Datacloud.FindDuplicatesResult>();
            
            try { // Datacloud.FindDuplicates returns an error if no matching rules are active
                List<Contact> cons = new List<Contact>();
                cons.add(c);
                results = Datacloud.FindDuplicates.findDuplicates(cons);
            } catch (Exception e){}
            
            for (Datacloud.DuplicateResult dr : results[0].getDuplicateResults()) {
                if ((matchType.get(reg.Event__c) == (dr.getDuplicateRule()) && dr.getMatchResults().size() > 0 && dr.getMatchResults()[0].getMatchRecords().size() > 0)){
                    Contact con = (Contact)dr.getMatchResults()[0].getMatchRecords()[0].getRecord();
                    
                    reg.Contact__c = con.Id;
                    reg.New_Contact_Created__c = false;
                    
                    String matchLog = '<div class="slds-text-heading_small slds-m-vertical_medium">Match found using Salesforce Duplicate Rule <em>' + matchType.get(reg.Event__c).replaceAll('_',' ') + '</em></div>';
                    matchLog += matchLogHead;
                    matchLog += '<tbody>';
                    
                    matchLog += matching1TD(con.Id, reg.Registrant_Last_Name__c, reg.Registrant_First_Name__c, reg.Registrant_Email__c, reg.Registrant_Postal_Code__c, false);
                    
                    matchLog += '</tbody></table>';
                    
                    reg.Matching_Log__c = matchLog;
                }
            }
            
            if (reg.Contact__c == null){
                newContacts.add(c);
            }
        }
        
        
        // Create the Contacts and match them with the correct Registrations
        if (!newContacts.isEmpty()){
            insert newContacts;
            
            for(Summit_Events_Registration__c reg : newRegistrations){
                if (reg.Contact__c == null){
                    Contact con = newContacts.remove(0);
                    reg.New_Contact_Created__c = true;
                    reg.Contact__c = con.Id;
                    
                    String matchLogHead = '<table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered slds-size_1-of-1">';
                    matchLogHead += '<thead><tr class="slds-line-height_reset">';
                    matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Last Name">Last Name</div></th>';
                    matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="First Name">First Name</div></th>';
                    matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Email">Email</div></th>';
                    matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Zip">Zip</div></th>';
                    matchLogHead += '<th class="" scope="col"><div class="slds-truncate" title="Action">Action</div></th>';
                    matchLogHead += '</tr></thead>';
                    
                    String matchLog = 'New contact created!';
                    matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Match found using Duplicate Rule <em>' + matchType.get(reg.Event__c) + '</em></div>';
                    matchLog += matchLogHead;
                    matchLog += '<tbody>';
                    matchLog += matching1TD(con.Id, reg.Registrant_Last_Name__c, reg.Registrant_First_Name__c, reg.Registrant_Email__c, reg.Registrant_Postal_Code__c, false);
                    matchLog += '</tbody></table>';
                    
                    reg.Matching_Log__c = matchLog;
                }
            }
        }
        
    }
    
    private Contact makeContact(Summit_Events_Registration__c reg, String matchingMethod){
        Contact c = new Contact();
        c.FirstName = reg.Registrant_First_Name__c;
        c.LastName = reg.Registrant_Last_Name__c;
        c.Email = reg.Registrant_Email__c;
        c.Birthdate = reg.Registrant_Date_of_Birth__c;
        
        c.MailingStreet = reg.Registrant_Street_1__c;
        c.MailingCity = reg.Registrant_City__c;
        c.MailingState = reg.Registrant_State__c;
        c.MailingPostalCode = reg.Registrant_Zip__c != ''? reg.Registrant_Zip__c : reg.Registrant_Postal_Code__c;
        c.MailingCountry = reg.Registrant_Country__c;
        
        c.Phone = reg.Registrant_Phone__c;
        c.MobilePhone = reg.Registrant_Mobile_Phone__c;
        
        
        for (Summit_Events_Contact_Matching_Mapping__mdt mapping : [SELECT Contact_Field_API_Name__c, Source_Value__c, Source_Type__c
                                                                    FROM Summit_Events_Contact_Matching_Mapping__mdt
                                                                    WHERE Contact_Matching_Method__c = :matchingMethod])
        {
            System.debug('mapping - ' + mapping);
            if (mapping.Source_Type__c == 'Field'){
                c.put(mapping.Contact_Field_API_Name__c, reg.get(mapping.Source_Value__c));
            }
            if (mapping.Source_Type__c == 'Hardcoded'){
                c.put(mapping.Contact_Field_API_Name__c, mapping.Source_Value__c);
            }
        }
        
        System.debug('c - ' + c);
        return c;
    }
    
    
    public Map<String, String> SummitEventsContactMatching(String matchingType, Summit_Events_Registration__c evt, String matchingScope) {
        Map<String, String> matchingResult = new Map<String, String>();
        //Direct to correct matching method
        if (!matchingScope.startsWith('No matching')) {
            if (matchingType.equalsIgnoreCase('Matching rules 2')) {
                matchingResult = matchingRules2 (evt, matchingScope);
            } else {
                matchingResult = matchingRules1(evt, matchingScope);
            }
        }
        return matchingResult;
    }
    
    //Check for Matches
    
    private Map<String, String> matchingRules1(Summit_Events_Registration__c evt, String matchingScope) {
        String contactId = '';
        String softEmailMatches = '';
        String softFirstLastZipMatches = '';
        boolean newContactCreated = false;
        String query = '';
        doCRUD CRUDtoDo = new doCRUD();
        
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
        
        
        if (String.isNotBlank(evt.Contact__c)) {
            contactId = evt.Contact__c;
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
            String prefFirstThree = String.isBlank(evt.Registrant_Preferred_First_Name__c)? '' : evt.Registrant_Preferred_First_Name__c;
            if (prefFirstThree.length() > 3) {
                prefFirstThree = prefFirstThree.substring(0, 3);
            }
            
            query = ' SELECT Id, LastName, FirstName, Email, MailingPostalCode FROM Contact WHERE (';
            if (String.isNotBlank(firstThree)) {
                query += ' firstName LIKE \'' + String.escapeSingleQuotes(firstThree) + '%\' OR';
            }
            if (String.isNotBlank(prefFirstThree)) {
                query += ' firstName LIKE \'' + String.escapeSingleQuotes(prefFirstThree) + '%\' OR';
            }
            query = query.removeEnd(' OR');
            query += ' ) ';
            query += ' AND LastName = \'' + evt.Registrant_Last_Name__c + '\' ';
            query += ' AND Birthdate = ' + String.valueOf(evt.Registrant_Date_of_Birth__c).removeEnd(' 00:00:00');
            
            List<Contact> hardContactTest1 = CRUDtoDo.findContacts(query);
            
            if (hardContactTest1.size() > 0) {
                contactId = hardContactTest1[0].Id;
                
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Hard match on FIRST NAME (first 3), LAST NAME, BIRTH DATE!</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                matchLog += matching1TD(hardContactTest1[0].Id, hardContactTest1[0].LastName, hardContactTest1[0].FirstName, hardContactTest1[0].Email, hardContactTest1[0].MailingPostalCode, false);
                matchLog += '</tbody></table>';
            }
        }
        
        //Test to find if contact already exists - HARD TEST last name and email match
        if (String.isBlank(contactId)) {
            List<Contact> hardContactTest2 = CRUDtoDo.emailLastMatch(email, lastName);
            if (hardContactTest2.size() > 0) {
                contactId = hardContactTest2[0].Id;
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Hard match on LAST NAME, EMAIL!</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                matchLog += matching1TD(hardContactTest2[0].Id, hardContactTest2[0].LastName, hardContactTest2[0].FirstName, hardContactTest2[0].Email, hardContactTest2[0].MailingPostalCode, false);
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
            List<Contact> hardContactTest3 = CRUDtoDo.possibleEmailLastMatches(lastName, possibleEmails);
            if (hardContactTest3.size() > 0) {
                //hard match on first DUP email found.
                contactId = hardContactTest3[0].Id;
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Hard match on LAST NAME, EMAIL (Email was duplicate email)</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                matchLog += matching1TD(hardContactTest3[0].Id, hardContactTest3[0].LastName, hardContactTest3[0].FirstName, hardContactTest3[0].Email, hardContactTest3[0].MailingPostalCode, false);
                matchLog += '</tbody></table>';
            }
        }
        
        if (String.isBlank(contactId) && (matchingScope.startsWith('Full matching') || String.isBlank(matchingScope))) {
            //Check if first name last name zip match
            List<Contact> zipContactTest = CRUDtoDo.zipFirstLastMatch(evt.Registrant_Zip__c, evt.Registrant_Last_Name__c, evt.Registrant_First_Name__c);
            if (zipContactTest.size() > 0) {
                //Soft Match found with zip
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Soft Match on Zip, Last Name, First Name</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                for (Contact c : zipContactTest) {
                    matchLog += matching1TD(c.Id, c.LastName, c.FirstName, c.Email, c.MailingPostalCode, true);
                    softFirstLastZipMatches += c.Id + ' ';
                }
                matchLog += '</tbody></table>';
            }
            List<Contact> emailContactTest = CRUDtoDo.emailOnlyMatch(evt.Registrant_Email__c);
            if (emailContactTest.size() > 0) {
                //Soft Match found with email
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Soft Match on Email</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                for (Contact c : emailContactTest) {
                    matchLog += matching1TD(c.Id, c.LastName, c.FirstName, c.Email, c.MailingPostalCode, true);
                    softEmailMatches += c.Id + ' ';
                }
                matchLog += '</tbody></table>';
            }
            Contact newEvtContact = createNewContact(evt);
            contactId = newEvtContact.Id;
            
            matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">New contact created!</div>';
            matchLog += matchLogHead;
            matchLog += '<tbody>';
            matchLog += matching1TD(newEvtContact.Id, newEvtContact.LastName, newEvtContact.FirstName, newEvtContact.Email, newEvtContact.MailingPostalCode, false);
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
                'matchLog' => matchLog};
    }
    
    private String matching1TD(String ContactId, String LastName, String FirstName, String Email, String Zip, Boolean Action) {
        String mOut = '<tr class="slds-hint-parent">';
        mOut += '<td data-label="Last Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + LastName + '</a></div></td>';
        mOut += '<td data-label="First Name"><div class="slds-truncate"><a href="/' + ContactId + '" target="_blank">' + FirstName + '</a></div></td>';
        mOut += '<td data-label="Email"><div class="slds-truncate">' + Email + '</div></td>';
        mOut += '<td data-label="Zip"><div class="slds-truncate">' + Zip + '</div></td>';
        if (Action) {
            mOut += '<td data-label="Action"><div class="slds-truncate"><a class="slds-text-link_reset" href="/apex/SummitEventsReparent?regId=[[REGID]]&reparentTo=' + ContactId + '"><span class="slds-text-link">Reparent</span></a></div></td>';
        } else {
            mOut += '<td data-label="Action"><div class="slds-truncate"> --- </div></td>';
        }
        mOut += '</tr>';
        return mOut;
    }
    
    private Contact createNewContact(Summit_Events_Registration__c evt) {
        //Create a HEDA address for new contact to be applied after insert
        doCRUD CRUDtoDo = new doCRUD();
        
        //Start the new contact
        Contact newEvtContact = new Contact();
        newEvtContact.FirstName = evt.Registrant_First_Name__c;
        newEvtContact.LastName = evt.Registrant_Last_Name__c;
        
        newEvtContact.MailingStreet = evt.Registrant_Street_1__c;
        //newAddress.hed__MailingStreet2__c = evt.Registrant_Street_2__c;
        newEvtContact.MailingCity = evt.Registrant_City__c;
        newEvtContact.MailingState = evt.Registrant_State__c;
        newEvtContact.MailingPostalCode = evt.Registrant_Zip__c;
        
        Summit_Events__c event = [SELECT Custom_Metadata_Contact_Matching_Method__c FROM Summit_Events__c WHERE Id = :evt.Event__c];
        for (Summit_Events_Contact_Matching_Mapping__mdt mapping : [SELECT Contact_Field_API_Name__c, Source_Value__c, Source_Type__c
                                                                    FROM Summit_Events_Contact_Matching_Mapping__mdt
                                                                    WHERE Contact_Matching_Method__c = :event.Custom_Metadata_Contact_Matching_Method__c])
        {
            System.debug('mapping - ' + mapping);
            if (mapping.Source_Type__c == 'Field'){
                newEvtContact.put(mapping.Contact_Field_API_Name__c, evt.get(mapping.Source_Value__c));
            }
            if (mapping.Source_Type__c == 'Hardcoded'){
                newEvtContact.put(mapping.Contact_Field_API_Name__c, mapping.Source_Value__c);
            }
        }
        
        //Generate all possible emails that could be created, or already exist and put them in a list to limit query and keep out of a loop
        String[] possibleEmails = new List<String>();
        possibleEmails.add(evt.Registrant_Email__c);
        for (Integer x = 1; x <= 10; x++) {
            possibleEmails.add('Event_Dup_' + String.valueOf(x) + '_' + evt.Registrant_Email__c);
        }
        
        //Check for all possible email matches including dupes
        List<Contact> emailContactTest = CRUDtoDo.possibleEmailMatches(possibleEmails);
        
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
        
        // newEvtContact.hed__Gender__c = evt.Registrant_Gender__c;
        newEvtContact.MobilePhone = evt.Registrant_Mobile_Phone__c;
        newEvtContact.HomePhone = evt.Registrant_Phone__c;
        //newEvtContact.Previous_Last_Name__c = evt.Last_Name_as_Student__c;
        //newEvtContact.Preferred_Class_Year__c = evt.Preferred_Class_Year__c;
        //newEvtContact.High_School_Expected_Graduation_Year__c = evt.Registrant_High_School_Grad_Year__c;
        //newEvtContact.LeadSource = 'Event';
        
        /*if (!String.isBlank(evt.Registrant_Applicant_Type__c)) {
newEvtContact.Inquiry_Applicant_Type__c = evt.Registrant_Applicant_Type__c;
}

if (!String.isBlank(evt.Registrant_High_School_Code__c) && String.isBlank(evt.Registrant_College_Code__c)) {
newEvtContact.EnrollmentrxRx__High_School_Code__c = evt.Registrant_High_School_Code__c;
} else if (!String.isBlank(evt.Registrant_College_Code__c)) {
newEvtContact.EnrollmentrxRx__High_School_Code__c = evt.Registrant_College_Code__c;
}*/
        System.debug('newEvtContact - ' + newEvtContact);
        
        //New HEDA field is inverse
        /*if (evt.Registrant_Receive_Texts__c = true) {
            newEvtContact.Do_Not_Text__c = false;
        }*/
        
        System.debug('Contact to create!!!:  ' + JSON.serializePretty(newEvtContact));
        newEvtContact = CRUDtoDo.addContact(newEvtContact);
        //HEDA address
        // newAddress.hed__Parent_Contact__c = newEvtContact.Id;
        // newAddress = CRUDtoDo.addAddress(newAddress);
        
        //Flag registration to show new contact was created
        evt.New_Contact_Created__c = true;
        return newEvtContact;
        
    }
    
    private Map<String, String> matchingRules2(Summit_Events_Registration__c evt, String matchingScope) {
        Id ContactId = null;
        String matchLog = '';
        Boolean newContactCreated = false;
        String hardMatchHeading = '';
        doCRUD CRUDtoDo = new doCRUD();
        
        /* These fields may be depreciated with he matching log
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
        matchLog += matching2TD('javascript();', evt.Registrant_Last_Name__c, evt.Last_Name_as_Student__c, evt.Registrant_First_Name__c, evt.Preferred_Class_Year__c, evt.Registrant_Email__c, '', evt.Registrant_Phone__c, '', false);
        matchLog += '</tbody></table>';
        
        /**** HARD MATCH TESTING ****/
        Contact hardContactFound = null;
        //Hard test on LAST NAME, EMAIL, CLASS
        
        String query = '';
        String orStat = '';
        String querySelect = ' SELECT Id, FirstName, LastName, Email, Phone, HomePhone FROM Contact';
        /** Hard match on Last Name, Email, Class Year  **/
        if (
            (String.isNotBlank(evt.Registrant_Last_Name__c) || String.isNotBlank(evt.Last_Name_as_Student__c))
            && String.isNotBlank(evt.Registrant_Email__c)
            && String.isNotBlank(evt.Preferred_Class_Year__c)) {
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
                query += ' AND Email = \'' + String.escapeSingleQuotes(evt.Registrant_Email__c) + '\' ';
                
                query += ' AND Preferred_Class_Year__c = \'' + String.escapeSingleQuotes(evt.Preferred_Class_Year__c) + '\' ';
                
                List<Contact> hardContactTestEmail = CRUDtoDo.findContacts(query);
                
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
                    orStat += ' OR FirstName = \'' + String.escapeSingleQuotes(evt.Registrant_First_Name__c) + '\' ';
                }
                /** Test on Last Name on previous last name Match **/
                if (String.isNotBlank(evt.Registrant_Preferred_First_Name__c)) {
                    orStat += ' OR FirstName = \'' + String.escapeSingleQuotes(evt.Registrant_Preferred_First_Name__c) + '\' ';
                }
                orStat = orStat.removeStart(' OR');
                query += ' AND ( ' + orStat + ' ) ';
                orStat = '';
                
                /** Test on EMAIL Match **/
                query += ' AND  Email = \'' + String.escapeSingleQuotes(evt.Registrant_Email__c) + '\' ';
                
                List<Contact> hardContactTestFirst = CRUDtoDo.findContacts(query);
                
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
            && String.isNotBlank(evt.Preferred_Class_Year__c)) {
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
                    orStat += ' OR FirstName = \'' + String.escapeSingleQuotes(evt.Registrant_First_Name__c) + '\' ';
                }
                
                /** Test on Last Name on previous last name Match **/
                if (String.isNotBlank(evt.Registrant_Preferred_First_Name__c)) {
                    orStat += ' OR FirstName = \'' + String.escapeSingleQuotes(evt.Registrant_Preferred_First_Name__c) + '\' ';
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
                query += ' AND Preferred_Class_Year__c = \'' + String.escapeSingleQuotes(evt.Preferred_Class_Year__c) + '\' ';
                
                List<Contact> hardContactTestNamePhoneClass = CRUDtoDo.findContacts(query);
                
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
            && String.isNotBlank(evt.Preferred_Class_Year__c)) {
                
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
                    orStat += ' FirstName LIKE \'' + String.escapeSingleQuotes(firstThree) + '%\' OR ';
                }
                if (String.IsNotBlank(prefFirstThree)) {
                    orStat += ' FirstName LIKE \'' +  String.escapeSingleQuotes(prefFirstThree) + '%\' OR ';
                }
                orStat = orStat.removeEnd(' OR ');
                if (String.isNotBlank(orStat)) {
                    query += ' AND ( ' + orStat + ' ) ';
                }
                orStat = '';
                
                query += ' AND Preferred_Class_Year__c = \'' + String.escapeSingleQuotes(evt.Preferred_Class_Year__c) + '\' ';
                
                List<Contact> hardContactTestNameFirstThreeClass = CRUDtoDo.findContacts(query);
                
                if (hardContactTestNameFirstThreeClass.size() == 1) {
                    hardContactFound = hardContactTestNameFirstThreeClass[0];
                    hardMatchHeading = 'Hard match on LAST NAME, FIRST 3 LETTERS OF FIRST NAME and CLASS';
                }
            }
        
        if (hardContactFound != null) {
            matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">' + hardMatchHeading + '!</div>';
            matchLog += matchLogHead;
            matchLog += '<tbody>';
            matchLog += matching2TD(hardContactFound.Id, hardContactFound.LastName, /*hardContactFound.Previous_Last_Name__c*/ null, hardContactFound.FirstName, /*hardContactFound.Preferred_Class_Year__c*/ null, hardContactFound.Email, '', hardContactFound.HomePhone, '', false);
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
            /*
            if (String.isNotBlank(evt.Preferred_Class_Year__c)) {
                query += ' AND Preferred_Class_Year__c = \'' + String.escapeSingleQuotes(evt.Preferred_Class_Year__c) + '\' ';
            } else {
                queryComplete = false;
            }
            */
            List<Contact> softContactTestNamePhoneClass = new List<Contact>();
            if (queryComplete) {
                softContactTestNamePhoneClass = CRUDtoDo.findContacts(query);
            }
            
            if (softContactTestNamePhoneClass != null && softContactTestNamePhoneClass.size() > 0) {
                matchLog += '<div class="slds-text-heading_small slds-m-vertical_medium">Soft Matches on LAST NAME, PHONE and CLASS.</div>';
                matchLog += matchLogHead;
                matchLog += '<tbody>';
                for (Contact softy : softContactTestNamePhoneClass) {
                    matchLog += matching2TD(softy.Id, softy.lastName, /*softy.Previous_Last_Name__c*/ null, softy.FirstName, /*softy.Preferred_Class_Year__c*/ null, softy.Email, '', softy.HomePhone, '', true);
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
                matchLog += matching2TD(contactId, evt.Registrant_Last_Name__c, '', evt.Registrant_First_Name__c, /*evt.Preferred_Class_Year__c*/ null, newCreatedContact.Email, '', evt.Registrant_Phone__c, '', false);
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
    
    private String matching2TD(String ContactId, String LastName, String StudentLastName, String FirstName, String ClassYear, String Email, String EmailSuffix, String Phone, String PhoneSuffix, Boolean Action) {
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
            mOut += '<td data-label="Action"><div class="slds-truncate"><a class="slds-text-link_reset" href="/apex/SummitEventsReparent?regId=[[REGID]]&reparentTo=' + ContactId + '"><span class="slds-text-link">Reparent</span></a></div></td>';
        } else {
            mOut += '<td data-label="Action"><div class="slds-truncate"> --- </div></td>';
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }
            return null;
        }
        
        public Contact addContact(Contact contactToAdd) {
            try {
                upsert contactToAdd;
                return contactToAdd;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }
            return null;
        }
        /*
        public hed__Address__c addAddress(hed__Address__c addressToAdd) {
            try {
                upsert addressToAdd;
                return addressToAdd;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }
            return null;
        }
        */
        Public List<Contact> emailLastMatch(String email, String last) {
            List<Contact> foundContacts = [SELECT Id, LastName, FirstName, Email, MailingPostalCode FROM Contact WHERE LastName = :last AND Email = :email];
            return foundContacts;
        }
        
        Public List<Contact> possibleEmailLastMatches(String last, List<String> possibleEmails) {
            List<Contact> foundContacts = [SELECT Id, LastName, FirstName, Email, MailingPostalCode FROM Contact WHERE LastName = :last AND Email IN :possibleEmails];
            return foundContacts;
        }
        
        Public List<Contact> possibleEmailMatches(String[] possibleEmails) {
            List<Contact> foundContacts = [SELECT Id, Email FROM Contact WHERE Email IN :possibleEmails];
            return foundContacts;
        }
        
        public List<Contact> emailOnlyMatch(string email) {
            List<Contact> foundContacts = [SELECT Id, LastName, FirstName, Email, MailingPostalCode FROM Contact WHERE Email = :email];
            return foundContacts;
        }
        
        public List<Contact> zipFirstLastMatch(String zip, String last, String first) {
            List<Contact> foundContacts = [
                SELECT Id, LastName, FirstName, Email, MailingPostalCode
                FROM Contact
                WHERE FirstName = :first
                AND LastName = :last
                AND MailingPostalCode = :zip
            ];
            return foundContacts;
        }
        
    }
    
}