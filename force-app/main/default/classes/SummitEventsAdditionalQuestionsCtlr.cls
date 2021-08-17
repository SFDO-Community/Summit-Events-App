/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 7/13/2021.
 */


public with sharing class SummitEventsAdditionalQuestionsCtlr {

    private SummitEventsShared SeaShared = new SummitEventsShared();
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
    public Map<String, String> lookupHoldingValues { get; set; }

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

        if (String.isNotBlank(eventInformation.eventId) && String.isNotBlank(eventInformation.instanceId)) {

            eventPage = [
                    SELECT Name, Id, Event_Name__c, Event_description__c, Event_Footer__c, Event_Full_Text__c, Event_Home_Link_URL__c, Event_Home_Link_Title__c,
                            Template__c, Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c, Event_Additional_Question_Title__c, Event_Additional_Questions_Description__c
                    FROM Summit_Events__c
                    WHERE Id = :eventInformation.eventId
                    WITH SECURITY_ENFORCED
            ];

            eventInstance = [
                    SELECT Id, Name, Event__r.Name, Event__r.Event_Name__c, Event__r.Id, Instance_Title__c, Active_Status__c, Capacity__c,
                            Event__r.Event_description__c, Event__r.Audience__c, Current_Available_Capacity__c,
                            Location_Type_Override__c, Location_Address_Override__c, Event__r.Close_Event_Days_Before__c, Location_Map_Link_Override__c, Location_Title_Override__c,
                            Event_Fee_Additional_Allocation_Override__c, Event_Fee_Additional_Override__c, Event_Fee_Override__c, Event_Fee_Allocation_Override__c,
                            Instance_Start_Date__c, Instance_Start_Time__c, Instance_End_Date__c, Instance_End_Time__c, Instance_Time_Zone__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :eventInformation.instanceId
                    WITH SECURITY_ENFORCED
            ];

            templateSelected = SeaShared.getTemplate(eventPage.Template__c);
            pageFlow = SeaShared.getPageFlow(eventInformation.eventId, eventInstance.Instance_Title__c, ApexPages.currentPage());
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

            additionalQuestions = [
                    SELECT Name, Question_Label__c, Question_Field_Type__c, Default_Value__c, Registrant_Type__c, Instructions__c, Help_Text__c, Display_Order__c,
                            Map_to_Field__c, Picklist_Values__c, Text_Limit__c, Controlling_Question__c, Controlling_Logic__c, Required__c, Is_Visible__c, Error_Assist_Text__c,
                            Lookup_Object__c, Lookup_Fields__c, Lookup_Where_Clause__c, Lookup_No_Results_Label__c, Lookup_Secondary_Input_Link_Text__c, Lookup_Secondary_Value_Field__c,
                            Lookup_Secondary_Input_Instructions__c, Lookup_Results_Icon__c
                    FROM Summit_Events_Question__c
                    WHERE Event__c = :eventInformation.eventId
                    AND Registrant_Type__c = 'Registrant'
                    WITH SECURITY_ENFORCED
                    ORDER BY Display_Order__c NULLS LAST
            ];

            //Get namespace if packaged
            String namespace = SummitEventsNamespace.getNamespace();
            if (String.isNotBlank(namespace)) {
                namespace = namespace + '__';
            }

            eventRegistration = new Summit_Events_Registration__c();

            if (String.isNotBlank(eventInformation.registrationId)) {

                eventRegistration.Id = eventInformation.registrationId;

                mapToList = new List<String>();
                lookupHoldingValues = new Map<String, String>();
                //Start building out the query for all fields in mapToList
                mapToList.add('Id');
                mapToList.add(namespace + 'Event__c');
                mapToList.add(namespace + 'Event_Instance__c');

                Map<String, String> queryLookupFields = new Map<String, String>();

                for (Summit_Events_Question__c question : additionalQuestions) {
                    Object nextField;
                    Boolean mapToFieldExists = true;
                    questionItem quest = new questionItem();
                    quest.setupFail = false;
                    quest.setupError = '';

                    //Make sure this is really a field
                    if (String.isBlank(question.Map_to_Field__c)) {
                        quest.setupError += 'Map to field is not entered. ';
                        mapToFieldExists = false;
                    } else {
                        //Check if map to field exists
                        try {
                            nextField = Schema.SObjectType.Summit_Events_Registration__c.fields.getMap().get(question.Map_to_Field__c).getDescribe();
                        } catch (Exception e) {
                            mapToFieldExists = false;
                            quest.setupError += 'Map to field does not exist. ';
                        }
                    }

                    quest.question = question.Question_Label__c;
                    quest.required = question.Required__c;

                    //Make sure this field is accessible
                    if (mapToFieldExists) {
                        if (Schema.SObjectType.Summit_Events_Registration__c.isAccessible() &&
                                Schema.SObjectType.Summit_Events_Registration__c.fields.getMap().get(question.Map_to_Field__c).getDescribe().isAccessible() &&
                                Schema.SObjectType.Summit_Events_Registration__c.fields.getMap().get(question.Map_to_Field__c).getDescribe().isCreateable()) {
                            mapToList.add(question.Map_to_Field__c);
                            //build wrapper class to type and make picklist lists
                            quest.questionId = SeaShared.encryptString(question.Id);
                            quest.type = question.Question_Field_Type__c;
                            quest.picklist = createPicklists(question.Picklist_Values__c);
                            quest.help = question.Help_Text__c;
                            quest.instructions = question.Instructions__c;
                            quest.assist = question.Error_Assist_Text__c;
                            quest.defaultValue = question.Default_Value__c;
                            quest.textLimit = Integer.valueOf(question.Text_Limit__c);
                            quest.mapTo = question.Map_to_Field__c;
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

                            //Deal with record lookup questions
                            if (question.Question_Field_Type__c.equalsIgnoreCase('lookup')) {

                                quest.secondaryQuestion = question.Lookup_Secondary_Input_Instructions__c;
                                quest.secondaryMapTo = question.Lookup_Secondary_Value_Field__c;
                                if (String.isNotBlank(question.Lookup_Secondary_Value_Field__c)) {
                                    mapToList.add(question.Lookup_Secondary_Value_Field__c);
                                }
                                if (String.isNotBlank(question.Lookup_No_Results_Label__c)) {
                                    quest.secondaryNoResults = question.Lookup_No_Results_Label__c;
                                } else {
                                    quest.secondaryNoResults = 'No results found.';
                                }

                                String lookupObject = question.Lookup_Object__c.trim();
                                List<String> lookupFields = question.Lookup_Fields__c.split(',');

                                //Check if lookup object is accessible
                                Boolean lookupObjectAccessible = false;
                                try {
                                    lookupObjectAccessible = Schema.getGlobalDescribe().get(lookupObject).getDescribe().isAccessible();
                                } catch (Exception e) {
                                    lookupObjectAccessible = false;
                                }


                                if (lookupObjectAccessible) {
                                    Boolean allFieldsAccessible = true;
                                    for (String lookUpField : lookupFields) {
                                        try {
                                            System.debug(lookUpField);
                                            allFieldsAccessible = Schema.getGlobalDescribe().get(lookupObject).getDescribe().fields.getMap().get(lookUpField.trim()).getDescribe().isAccessible();
                                        } catch (Exception e) {
                                            allFieldsAccessible = false;
                                            break;
                                        }
                                    }
                                    if (allFieldsAccessible) {
                                        lookupHoldingValues.put(question.Map_to_Field__c, question.Lookup_Fields__c);
                                        Map<String, String> queryInfo = new Map<String, String>();
                                        queryInfo.put('Lookup_Object__c', question.Lookup_Object__c.replaceAll('\\s+', ''));
                                        queryInfo.put('Lookup_Fields__c', question.Lookup_Fields__c.replaceAll('\\s+', ''));
                                        queryInfo.put('Lookup_Where_Clause__c', question.Lookup_Where_Clause__c);
                                        quest.lookup = SeaShared.encryptString(JSON.serialize(queryInfo));

                                        //Build query for getting values later
                                        String lookupField = question.Map_to_Field__c.trim();
                                        lookupField = lookupField.removeEnd('__c');
                                        lookupField = lookupField + '__r.';
                                        List<String> lookupFieldsRelation = question.Lookup_Fields__c.split(',');
                                        String lookupQuery = '';
                                        for (String field : lookupFieldsRelation) {
                                            lookupQuery += lookupField + field.trim() + ', ';
                                        }
                                        lookupQuery = lookupQuery.removeEnd(', ');
                                        queryLookupFields.put(question.Lookup_Object__c.trim(), lookupQuery);
                                    } else {
                                        quest.setupError += 'Lookup fields provided are inaccessible. ';
                                    }
                                } else {
                                    quest.setupError += 'Lookup Object is inaccessible. ';
                                }
                            }

                        } else {
                            quest.setupError += 'Map to field is not accessible with current permissions. ';
                        }
                    }
                    System.debug(quest.setupError);
                    if (quest.setupError != '') {
                        quest.setupError = 'Question setup issue: ' + quest.setupError;
                        quest.setupFail = true;
                    }

                    //add question to question wrapper if it is visible, otherwise apply default value to the event registration.
                    if (question.Is_Visible__c) {
                        questionWrapper.add(quest);
                    } else {
                        if (String.isNotBlank(question.Default_Value__c)) {
                            hiddenValues.put(question.Map_to_Field__c, question.Default_Value__c);
                        }
                    }

                }

                // System.debug(JSON.serializePretty(questionWrapper));

                String regQuery = '';
                if (mapToList.size() > 0) {
                    regQuery += 'SELECT ';
                    regQuery += String.join(mapToList, ' , ');
                    //Lookup values added
                    if (queryLookupFields.size() > 0) {
                        regQuery += ', ';
                        for (String key : queryLookupFields.keySet()) {
                            regQuery += queryLookupFields.get(key) + ', ';
                        }
                    }
                    regQuery = regQuery.removeEnd(', ');
                    regQuery += ' FROM Summit_Events_Registration__c ';
                    regQuery += ' WHERE Id = \'' + String.escapeSingleQuotes(eventInformation.registrationId) + '\'';
                }

                System.debug(regQuery);

                if (String.isNotBlank(regQuery)) {
                    eventRegistration = Database.query(regQuery);
                    //Apply hidden values

                    for (String key: hiddenValues.keySet()) {
                        eventRegistration.put(key, hiddenValues.get(key));
                    }

                   // hiddenValues.put(question.Map_to_Field__c, question.Default_Value__c);

                    //Get the holding values if there are any
                    for (String key : lookupHoldingValues.keySet()) {
                        String lookupField = key.trim();
                        if (String.isNotBlank((String) eventRegistration.get(lookupField.trim()))) {
                            lookupField = lookupField.removeEnd('__c');
                            lookupField = lookupField + '__r';
                            List<String> lookupFieldsRelation = lookupHoldingValues.get(key).split(',');

                            String holding = '';
                            for (String field : lookupFieldsRelation) {
                                if (String.isNotBlank(eventRegistration.getSObject(lookupField.trim()).get(field.trim()).toString())) {
                                    holding += (String) eventRegistration.getSObject(lookupField.trim()).get(field.trim()) + ', ';
                                }
                            }
                            holding = holding.removeEnd(', ');
                            lookupHoldingValues.put(key, holding);
                        } else {
                            lookupHoldingValues.put(key, '');
                        }
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

    public PageReference submitAdditionalQuestions() {

        System.debug(JSON.serializePretty(eventRegistration));
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
                DescribeSObjectResult lookupObjectDesc = null;
                try {
                    //Define lookup object
                    lookupObjectDesc = Schema.getGlobalDescribe().get(queryInfo.get('Lookup_Object__c').trim()).getDescribe();
                } catch (Exception e) {
                    System.debug(e.getMessage());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Lookup object is inaccessible.' + e.getMessage()));
                }
                if (lookupObjectDesc != null) {
                    //Is lookup object accessible?
                    if (lookupObjectDesc.isAccessible()) {
                        //Check each fields accessibility and add it to the query
                        List<String> lookupFields = queryInfo.get('Lookup_Fields__c').split(',');
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
                                if (String.isNotBlank(lookupQuery) && String.isNotBlank(queryInfo.get('Lookup_Where_Clause__c'))) {
                                    if (queryInfo.get('Lookup_Where_Clause__c').contains('WHERE ')) {
                                        lookupQuery = lookupQuery + ' ' + queryInfo.get('Lookup_Where_Clause__c');
                                    } else {
                                        lookupQuery = lookupQuery + ' WHERE ' + queryInfo.get('Lookup_Where_Clause__c');
                                    }
                                    String likeStatement = '';

                                    for (String sField : validLookupFields) {
                                        likeStatement += sField.trim() + ' LIKE \'%' + String.escapeSingleQuotes(term) + '%\' OR ';
                                    }
                                    lookupQuery += ' AND ( ' + likeStatement.removeEnd(' OR ') + ' )';
                                    lookupQuery += ' ORDER BY ' + String.join(validLookupFields, ', ') + ' ASC';
                                    lookupQuery += ' LIMIT 50';

                                    List<SObject> foundValues = new List<SObject>();

                                    System.debug(lookupQuery);

                                    try {
                                        foundValues = Database.query(lookupQuery);
                                    } catch (Exception e) {
                                        System.debug(e.getMessage());
                                    }
                                    for (SObject obj : foundValues) {
                                        queryReturn qr = new queryReturn();
                                        String lineOne = '';
                                        String lineTwo = '';
                                        String retainValue = '';
                                        validLookupFields.add('Id');
                                        for (Integer xx = 0; xx < validLookupFields.size(); xx++) {
                                            //Don't ever show Ids in the returned value list
                                            String fieldType = String.valueOf(Schema.getGlobalDescribe().get(queryInfo.get('Lookup_Object__c')).getDescribe().fields.getMap().get(validLookupFields[xx]).getDescribe().getType()).toLowerCase();
                                            if (fieldType != 'id') {
                                                if (xx == 0) {
                                                    lineOne = (String) obj.get(validLookupFields[xx]);
                                                } else {
                                                    lineTwo += (String) obj.get(validLookupFields[xx]) + ', ';
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

                                } else {
                                    lookupQuery = '';
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Lookup where clause missing.'));
                                }
                            }

                        } else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Lookup object is inaccessible.'));
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