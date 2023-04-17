/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 7/13/2021.
 */


public with sharing class SummitEventsAdditionalQuestionsCtlr {

    final SummitEventsShared SeaShared = new SummitEventsShared();
    public String templateSelected { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public Summit_Events_Instance__c eventInstance { get; set; }
    public Summit_Events_Registration__c eventRegistration { get; set; }
    public SummitEventsShared.SummitEventsInfo eventInformation { get; set; }
    public String instanceName { get; set; }
    public String startTimeString { get; set; }
    public String endTimeString { get; set; }
    public Map<String, PageReference> pageFlow { get; set; }
    public String formattedNavDate { get; set; }
    public List<Summit_Events_Question__c> additionalQuestions { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean adminOpen { get; set; }
    public List<String> mapToList { get; set; }
    public List<questionItem> questionWrapper { get; set; }
    private Id incomingRegId { get; set; }
    public Map<String, String> lookUpDisplayValue { get; set; }


    public class questionItem {
        public String questionId { get; set; }
        public String type { get; set; }
        public String question { get; set; }
        public Boolean required { get; set; }
        public List<SelectOption> picklist { get; set; }
        public String help { get; set; }
        public String instructions { get; set; }
        public String assist { get; set; }
        public String defaultValue { get; set; }
        public Integer textLimit { get; set; }
        public String mapTo { get; set; }
        public String lookup { get; set; }
        public String icon { get; set; }
        public String secondaryLinkText { get; set; }
        public String secondaryQuestion { get; set; }
        public String secondaryMapTo { get; set; }
        public String secondaryNoResults { get; set; }
        public String setupError { get; set; }
        public Boolean setupFail { get; set; }
        public String displayStyle { get; set; }
    }

    public class queryReturn {
        public String searchTerm { get; set; }
        public String lineOne { get; set; }
        public String lineTwo { get; set; }
        public String retainValue { get; set; }
    }

    public SummitEventsAdditionalQuestionsCtlr() {
        eventIsClosed = false;
        eventInformation = SeaShared.getSummitEventsInfo();
        questionWrapper = new List<questionItem>();
        Map<String, String> hiddenValues = new Map<String, String>();

        //eventInformation is an object gathered from the encrypted client cookie that contains event id and instance ids without which thou shall not pass
        if (String.isNotBlank(eventInformation.eventId) && String.isNotBlank(eventInformation.instanceId)) {

            eventPage = [
                    SELECT Name, Id, Event_Name__c, Event_description__c, Event_Footer__c, Event_Full_Text__c, Event_Home_Link_URL__c, Event_Home_Link_Title__c,
                            Template__c, Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c, Event_Additional_Question_Title__c, Event_Additional_Questions_Description__c,
                            Account__r.Name, Audience__c, Filter_Category__c, Event_Sponsor__c
                    FROM Summit_Events__c
                    WHERE Id = :eventInformation.eventId
                    WITH SECURITY_ENFORCED
            ];

            eventInstance = [
                    SELECT Id, Name, Event__r.Name, Event__r.Event_Name__c, Event__r.Id, Instance_Title__c, Active_Status__c, Capacity__c,
                            Event__r.Event_description__c, Event__r.Audience__c, Current_Available_Capacity__c,
                            Location_Type_Override__c, Location_Address_Override__c, Event__r.Close_Event_Days_Before__c, Location_Map_Link_Override__c, Location_Title_Override__c,
                            Event_Fee_Additional_Allocation_Override__c, Event_Fee_Additional_Override__c, Event_Fee_Override__c, Event_Fee_Allocation_Override__c,
                            Instance_Start_Date__c, Instance_Start_Time__c, Instance_End_Date__c, Instance_End_Time__c, Instance_Time_Zone__c,
                            Registration_Close_Date__c, Registration_Close_Time__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :eventInformation.instanceId
                    WITH SECURITY_ENFORCED
            ];

            templateSelected = SeaShared.getTemplate(eventPage.Template__c);
            pageFlow = SeaShared.getPageFlow(eventInformation.eventId, eventInstance.Instance_Title__c, ApexPages.currentPage(), eventInstance.Instance_Start_Date__c, eventInstance.Instance_End_Date__c);
            formattedNavDate = SeaShared.navBreadcrumbBuilder(eventInstance);
            instanceName = eventInstance.Name;
            startTimeString = SeaShared.formatTime(eventInstance.Instance_Start_Time__c, false);
            endTimeString = SeaShared.formatTime(eventInstance.Instance_End_Time__c, false);

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                eventIsClosed = adminOpen;
            } else {
                eventIsClosed = SeaShared.isEventClosed(eventPage, eventInstance);
            }

            //Get the question object questions
            additionalQuestions = [
                    SELECT Name, Question_Label__c, Question_Field_Type__c, Default_Value__c, Registrant_Type__c, Instructions__c, Help_Text__c, Display_Order__c,
                            Map_to_Field__c, Picklist_Values__c, Text_Limit__c, Controlling_Question__c, Controlling_Logic__c, Required__c, Is_Visible__c, Error_Assist_Text__c,
                            Lookup_Object__c, Lookup_Fields__c, Lookup_Where_Clause__c, Lookup_No_Results_Label__c, Lookup_Secondary_Input_Link_Text__c, Lookup_Secondary_Value_Field__c,
                            Lookup_Secondary_Input_Instructions__c, Lookup_Results_Icon__c, Existing_Picklist_Values__c, Display_Style__c
                    FROM Summit_Events_Question__c
                    WHERE Event__c = :eventInformation.eventId
                    AND (Registrant_Type__c = 'Registrant' OR Registrant_Type__c = 'Registrant and Guest')
                    WITH SECURITY_ENFORCED
                    ORDER BY Display_Order__c NULLS LAST
            ];

            //Get namespace if packaged
            String namespace = SummitEventsNamespace.getNamespace();
            if (String.isNotBlank(namespace)) {
                namespace = namespace + '__';
            }

            eventRegistration = new Summit_Events_Registration__c();

            // eventInformation is an object gathered from the encrypted client cookie that contains a registration id without which thou shall not pass
            if (String.isNotBlank(eventInformation.registrationId)) {

                // Apply the registration id from the cookie to a new registration object
                eventRegistration.Id = eventInformation.registrationId;

                mapToList = new List<String>();
                lookUpDisplayValue = new Map<String, String>();

                //Start building out the query for all fields in mapToList. Must query all needed fields from the Registration record
                mapToList.add('Id');
                mapToList.add(namespace + 'Event__c');
                mapToList.add(namespace + 'Event_Instance__c');

                for (Summit_Events_Question__c question : additionalQuestions) {
                    //Build each question item and add to question item list to inform creation of visualforce form.
                    questionItem quest = new questionItem();
                    quest.setupFail = false;
                    quest.setupError = '';
                    String mapToField = '';
                    String lookupObject = '';

                    if (String.isBlank(question.Display_Style__c)) {
                        quest.displayStyle = 'slds-large-size_3-of-6';
                    } else if (question.Display_Style__c.equalsIgnoreCase('full width')) {
                        quest.displayStyle = 'slds-large-size_6-of-6';
                    } else if (question.Display_Style__c.equalsIgnoreCase('third width')) {
                        quest.displayStyle = 'slds-large-size_2-of-6';
                    }

                    //Make sure this is really a field
                    if (String.isBlank(question.Map_to_Field__c)) {
                        quest.setupError += 'Map to field is not entered. ';
                    } else {
                        //Check if map to field exists
                        mapToField = question.Map_to_Field__c.trim().toLowerCase();
                        quest.setupError = SeaShared.checkFieldGuestAccess(namespace + 'Summit_Events_Registration__c', mapToField, '', true, 'Map to field: ');
                    }

                    //It would be counter productive to map to the same field, but if you do it live with the ordering consequences with your questions
                    if (!mapToList.contains(mapToField)) {
                        mapToList.add(mapToField);
                    } else {
                        quest.setupError += 'You have 2 questions mapped to the same field: ' + mapToField + '. ';
                    }

                    //build wrapper class to type and make picklist lists
                    quest.question = question.Question_Label__c;
                    quest.required = question.Required__c;
                    quest.questionId = SeaShared.encryptString(question.Id);
                    quest.type = question.Question_Field_Type__c;

                    if (String.isNotBlank(question.Existing_Picklist_Values__c)) {

                        List<String> packagedExistingPicklists = new List<String>{
                                'Registrant_Third_Party_Status__c',
                                'Registrant_State_Global__c',
                                'Registrant_Country__c',
                                'Registrant_Pronouns__c',
                                'Registrant_Applicant_Type__c',
                                'Preferred_Visit_Time__c',
                                'Registrant_Gender__c'
                        };

                        String existingPickListField = question.Existing_Picklist_Values__c;
                        //make sure packaged picklists get the namespace added if it is in play
                        if (String.isNotBlank(namespace) && packagedExistingPicklists.contains(existingPickListField)) {
                            existingPickListField = namespace + existingPickListField;
                        }
                        //Test if picklist is accessible and is a picklist
                        quest.setupError += SeaShared.checkFieldGuestAccess(namespace + 'Summit_Events_Registration__c', existingPickListField, 'picklist', false, '');
                        if (String.isBlank(quest.setupError)) {
                            quest.picklist = createExistingPicklist(existingPickListField);
                        }
                    } else {
                        quest.picklist = createPicklists(question.Picklist_Values__c);
                    }

                    quest.help = question.Help_Text__c;
                    quest.instructions = question.Instructions__c;
                    quest.assist = question.Error_Assist_Text__c;
                    quest.defaultValue = question.Default_Value__c;
                    quest.textLimit = Integer.valueOf(question.Text_Limit__c);
                    quest.mapTo = mapToField;

                    if (String.isNotBlank(question.Lookup_Results_Icon__c)) {
                        quest.icon = question.Lookup_Results_Icon__c.trim();
                    } else {
                        quest.icon = 'account';
                    }

                    if (String.isNotBlank(question.Lookup_Secondary_Input_Link_Text__c)) {
                        quest.secondaryLinkText = question.Lookup_Secondary_Input_Link_Text__c;
                    } else {
                        quest.secondaryLinkText = 'Manually enter information.';
                    }


                    quest.secondaryMapTo = question.Lookup_Secondary_Value_Field__c;
                    if (String.isNotBlank(question.Lookup_Secondary_Value_Field__c)) {
                        mapToList.add(question.Lookup_Secondary_Value_Field__c);
                    }

                    quest.secondaryQuestion = question.Lookup_Secondary_Input_Instructions__c;

                    if (String.isNotBlank(question.Lookup_No_Results_Label__c)) {
                        quest.secondaryNoResults = question.Lookup_No_Results_Label__c;
                    } else {
                        quest.secondaryNoResults = 'No results found.';
                    }

                    if (question.Question_Field_Type__c.equalsIgnoreCase('lookup') || question.Question_Field_Type__c.equalsIgnoreCase('lookup picklist')) {

                        List<String> cleanLookUpFields = new List<String>();
                        List<String> lookupFields = new List<String>();
                        List<String> referentialLookups = new List<String>();
                        Boolean mapToFieldIsLookup = true;

                        //Look up object is the source of the data in the lookup question that returns an idea when a record is selected
                        lookupObject = '';
                        if (String.isNotBlank(question.Lookup_Object__c)) {
                            lookupObject = question.Lookup_Object__c.trim().toLowerCase();
                            quest.setupError += SeaShared.checkFieldGuestAccess(lookupObject, '', '', false, 'Lookup Object: ');
                        }

                        quest.setupError += SeaShared.checkFieldGuestAccess(namespace + 'Summit_Events_Registration__c', mapToField, 'reference', true, 'Map To Field: ');

                        if (String.isNotBlank(question.Lookup_Fields__c)) {
                            String questionLookupFields = question.Lookup_Fields__c.toLowerCase();
                            questionLookupFields = questionLookupFields.replace('billingaddress', 'BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry');
                            questionLookupFields = questionLookupFields.replace('shippingaddress', 'ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry');

                            lookupFields = questionLookupFields.split(',');

                            // Test for accessibility and clean up lookup fields
                            for (String lookUpField : lookupFields) {
                                lookUpField = lookUpField.trim();

                                quest.setupError += SeaShared.checkFieldGuestAccess(lookupObject, lookUpField, '', false, 'Look up field: ');
                                if (String.isBlank(quest.setupError)) {
                                    cleanLookUpFields.add(lookUpField);
                                    if (mapToFieldIsLookup) {
                                        mapToList.add(mapToField.replace('__c', '__r.') + lookUpField);
                                        referentialLookups.add(lookUpField);
                                    }
                                }
                            }
                        } else {
                            cleanLookUpFields.add('Name');
                        }

                        //Build queryInfo object to encrypt to pass lookup query information not in the clear
                        Map<String, String> queryInfo = new Map<String, String>();
                        queryInfo.put('Lookup_Object__c', lookupObject);

                        if (cleanLookUpFields.size() > 0) {
                            queryInfo.put('Lookup_Fields__c', String.join(cleanLookUpFields, ','));
                            lookUpDisplayValue.put(mapToField, String.join(referentialLookups, ','));
                        }

                        if (String.isNotBlank(question.Lookup_Where_Clause__c)) {
                            queryInfo.put('Lookup_Where_Clause__c', question.Lookup_Where_Clause__c);
                        }

                        if (question.Question_Field_Type__c.equalsIgnoreCase('lookup')) {
                            //serialize object with query info in it to retrieve later when decrypted
                            quest.lookup = SeaShared.encryptString(JSON.serialize(queryInfo));

                            List<String> lookupFieldsRelation = new List<String>();
                            if (String.isNotBlank(question.Lookup_Fields__c)) {
                                lookupFieldsRelation = question.Lookup_Fields__c.split(',');
                            }
                        }

                        if (question.Question_Field_Type__c.equalsIgnoreCase('lookup picklist')) {
                            if (String.isBlank(quest.setupError)) {
                                quest.picklist = createLookupPicklist(queryInfo.get('Lookup_Object__c'), queryInfo.get('Lookup_Where_Clause__c'), queryInfo.get('Lookup_Fields__c'));
                            }
                        }
                    }

                    //add question to question wrapper if it is visible, otherwise apply default value to the event registration.
                    if (question.Is_Visible__c) {
                        questionWrapper.add(quest);
                    } else {
                        if (String.isNotBlank(question.Default_Value__c)) {
                            hiddenValues.put(mapToField, question.Default_Value__c);
                        }
                    }

                    if (quest.setupError != '') {
                        quest.setupError = 'Question setup issue(s): ' + quest.setupError;
                        quest.setupFail = true;
                    }
                }

                //outside question group
                String regQuery = '';
                if (mapToList.size() > 0) {
                    regQuery += 'SELECT ';
                    regQuery += String.join(mapToList, ',');
                    regQuery = regQuery.trim();
                    regQuery = regQuery.removeEndIgnoreCase(',');
                    regQuery += ' FROM Summit_Events_Registration__c ';
                    regQuery += ' WHERE Id = \'' + String.escapeSingleQuotes(eventInformation.registrationId) + '\'';
                }

                if (String.isNotBlank(regQuery)) {
                    try {
                        eventRegistration = Database.query(regQuery);
                    } catch (Exception e) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage()));
                    }

                    //Apply hidden values
                    for (String key : hiddenValues.keySet()) {
                        eventRegistration.put(key, hiddenValues.get(key));
                    }

                    //Get the holding values if there are any
                    for (String key : lookUpDisplayValue.keySet()) {
                        String lookupField = key.trim();
                        lookupField = lookupField.replace('__c', '__r');
                        List<String> lookupFieldsRelation = lookUpDisplayValue.get(key).split(',');
                        String holding = '';
                        for (String field : lookupFieldsRelation) {
                            String holdingValue = '';
                            try {
                                holdingValue = (String) eventRegistration.getSObject(lookupField).get(field);
                                holding += holdingValue + ', ';
                            } catch (Exception ex) {

                            }
                        }
                        holding = holding.removeEnd(', ');
                        lookUpDisplayValue.put(key, holding);
                    }
                    incomingRegId = eventRegistration.Id;
                    eventRegistration.Id = null;
                }
            }
        }
    }

    public List<SelectOption> createPicklists(String returnSepStringList) {
        List<SelectOption> cpl = new List<SelectOption>();
        if (!String.isBlank(returnSepStringList)) {
            cpl.add(new SelectOption('', 'Select...'));
            returnSepStringList = returnSepStringList.trim();
            returnSepStringList = returnSepStringList.replace('\n\n', '\n');
            String[] splitList = returnSepStringList.split('\n');
            for (String p : splitList) {
                p = p.replaceAll('[^a-zA-Z0-9@<>?&;:\\[\\]!-. ]', '');
                cpl.add(new SelectOption(p, p));
            }
        }
        return cpl;
    }

    public List<SelectOption> createExistingPicklist(String existingPicklist) {
        List<SelectOption> picklists = new List<SelectOption>();
        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace.toLowerCase() + '__';
        }

        String existingPicklistString = existingPicklist;
        if (!existingPicklistString.startsWith('c__')) {
            existingPicklistString = namespace + existingPicklistString;
        }

        Schema.DescribeSObjectResult registrationDescribe = ((SObject) Type.forName('Schema', namespace + 'Summit_Events_Registration__c').newInstance()).getSObjectType().getDescribe();

        List<Schema.PicklistEntry> PicklistValues = registrationDescribe.fields.getMap().get(existingPicklistString).getDescribe().getPicklistValues();
        picklists.add(new SelectOption('', 'Select...'));
        for (Schema.PicklistEntry PicklistValue : PicklistValues) {
            picklists.add(new SelectOption(PicklistValue.getValue(), PicklistValue.getLabel()));
        }
        return picklists;
    }

    public List<SelectOption> createLookupPicklist(String objectName, String filter, String fields) {
        List<SelectOption> pl = new List<SelectOption>();
        pl.add(new SelectOption('', 'Select...'));

        List<String> fieldNames = fields.split(',');

        String query = 'SELECT Id,' + fields;
        query += ' FROM ' + objectName;

        if (String.isNotBlank(filter)) {
            query += ' WHERE ' + filter;
        }

        query += ' ORDER BY ' + fieldNames.get(0);

        List<SObject> results = Database.query(query);

        for (SObject obj : results) {
            String name = '';

            for (Integer i = 0; i < fieldNames.size(); i++) {
                String field = fieldNames.get(i);

                if (i == 1 && fieldNames.size() > 0) {
                    name += ' - ';
                }
                if (i > 1) {
                    name += ', ';
                }
                if (String.isNotBlank((String) obj.get(field.trim()))) {
                    name += (String) obj.get(field.trim());
                } else {
                    name = name.removeEnd(', ');
                }
            }
            name = name.removeEnd(', ');
            SelectOption option = new SelectOption(obj.Id, name);
            pl.add(option);
        }

        return pl;
    }

    public PageReference submitAdditionalQuestions() {
        doCRUD CRUDToDo = new doCRUD();
        CRUDToDo.saveRegistration(eventRegistration, incomingRegId);
        return pageFlow.get('Next');
    }

    public PageReference previousPage() {
        return pageFlow.get('Previous');
    }

    public PageReference checkEventDetails() {
        return SeaShared.checkForEvent();
    }


    @RemoteAction
    public static List<queryReturn> lookupSearch(String question, String term) {
        SummitEventsShared SeaShared = new SummitEventsShared();
        List<queryReturn> returnValues = new List<queryReturn>();
        if (String.isNotBlank(question) && String.isNotBlank(term)) {
            question = SeaShared.decryptString(question, true);
            Map<String, String> queryInfo = (Map<String, String>) JSON.deserialize(question, Map<String, String>.class);
            if (queryInfo.size() > 0) {
                String lookupQuery = '';
                Schema.DescribeSObjectResult lookupObjectDesc = null;
                try {
                    //Define lookup object
                    lookupObjectDesc = ((SObject) Type.forName('Schema', queryInfo.get('Lookup_Object__c')).newInstance()).getSObjectType().getDescribe();
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Lookup object is inaccessible.' + e.getMessage()));
                }
                if (lookupObjectDesc != null) {
                    //Is lookup object accessible?
                    if (lookupObjectDesc.isAccessible()) {
                        //Check each fields accessibility and add it to the query
                        List<String> lookupFields = new List<String>();
                        if (String.isNotBlank(queryInfo.get('Lookup_Fields__c'))) {
                            lookupFields = queryInfo.get('Lookup_Fields__c').split(',');
                        }
                        List<String> validLookupFields = new List<String>();

                        if (lookupFields.size() > 0) {
                            for (String fieldName : lookupFields) {
                                if (String.isNotBlank(fieldName)) {
                                    if (lookupObjectDesc.fields.getMap().get(fieldName.trim()).getDescribe().isAccessible()) {
                                        validLookupFields.add(fieldName.trim());
                                    }
                                }
                            }
                            if (validLookupFields.size() == 0) {
                                //Alert if any of the fields don't make the accessibility cut
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'One or more of your lookup fields was inaccessible.'));
                            } else {
                                lookupQuery = 'SELECT Id, ' + String.join(validLookupFields, ', ') + ' FROM ' + queryInfo.get('Lookup_Object__c').trim() + ' ';
                                if (String.isNotBlank(lookupQuery)) {
                                    if (String.isNotBlank(queryInfo.get('Lookup_Where_Clause__c'))) {
                                        if (!queryInfo.get('Lookup_Where_Clause__c').contains('WHERE ')) {
                                            lookupQuery = lookupQuery + ' WHERE ';
                                        }
                                        lookupQuery += queryInfo.get('Lookup_Where_Clause__c') + ' AND ';
                                    } else {
                                        lookupQuery = lookupQuery + ' WHERE ';
                                    }

                                    String likeStatement = '';
                                    for (String sField : validLookupFields) {
                                        likeStatement += sField.trim() + ' LIKE \'%' + String.escapeSingleQuotes(term) + '%\' OR ';
                                    }

                                    lookupQuery += ' ( ' + likeStatement.removeEnd(' OR ') + ' )';
                                    lookupQuery += ' ORDER BY ' + String.join(validLookupFields, ', ') + ' ASC';
                                    lookupQuery += ' LIMIT 50';

                                    List<SObject> foundValues = new List<SObject>();

                                    try {
                                        foundValues = Database.query(lookupQuery);
                                    } catch (Exception e) {

                                    }
                                    for (SObject obj : foundValues) {
                                        queryReturn qr = new queryReturn();
                                        String lineOne = '';
                                        String lineTwo = '';
                                        String retainValue = '';
                                        validLookupFields.add('Id');
                                        for (Integer xx = 0; xx < validLookupFields.size(); xx++) {
                                            //Don't ever show Ids in the returned value list
                                            SObjectType lookupObjectDescribe = ((SObject) Type.forName('Schema', queryInfo.get('Lookup_Object__c')).newInstance()).getSObjectType();
                                            String fieldType = String.valueOf(lookupObjectDescribe.getDescribe().fields.getMap().get(validLookupFields[xx]).getDescribe().getType()).toLowerCase();
                                            if (fieldType != 'id') {
                                                if (xx == 0) {
                                                    lineOne = (String) obj.get(validLookupFields[xx]);
                                                } else {
                                                    if (String.isNotBlank((String) obj.get(validLookupFields[xx]))) {
                                                        lineTwo += (String) obj.get(validLookupFields[xx]) + ', ';
                                                    }
                                                }
                                            }
                                            retainValue = (String) obj.get('Id');
                                        }
                                        lineTwo = lineTwo.removeEnd(', ');
                                        qr.lineOne = lineOne;
                                        qr.lineTwo = lineTwo;
                                        qr.retainValue = retainValue;
                                        qr.searchTerm = term;
                                        returnValues.add(qr);
                                    }

                                }
                            }
                        }
                    }
                }
            }
        }
        return returnValues;
    }

    /**
     * Summit Events is a multi-step, guest user, registration solution so CRUD work needs to be done on records where guest record ownership is lost between steps.
     * The security aspects of guest record updating is achieved by:
     * - Using an encrypted cookie on the client browser to keep track of registration id, event id, instance id, and audience
     * - Dividing each controller class into a "with sharing" logic area and a sub "without sharing" CRUD area for purposeful CRUD
     * - When the encrypted cookie is not available as in the cancel registration link an encrypted string is provided through the URL to not expose the SF ID related to the record
     **/

    private without sharing class doCRUD {

        public void saveRegistration(Summit_Events_Registration__c eventRegistration, Id incomingId) {
            eventRegistration.Id = incomingId;
            update eventRegistration;
        }

    }

}