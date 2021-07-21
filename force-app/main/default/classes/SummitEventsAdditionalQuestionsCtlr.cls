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

    public class questionItem {
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
        private String recordQuery { get; set; }
    }

    public SummitEventsAdditionalQuestionsCtlr() {
        eventIsClosed = false;
        eventInformation = SeaShared.getSummitEventsInfo();
        if (String.isNotBlank(eventInformation.eventId) && String.isNotBlank(eventInformation.instanceId)) {

            eventPage = [
                    SELECT Name, Id, Event_Name__c, Event_description__c, Event_Footer__c, Event_Full_Text__c, Event_home_Link_URL__c, Event_Home_Link_Title__c,
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
                            Map_to_Field__c, Picklist_Values__c, Text_Limit__c, Controlling_Question__c, Controlling_Logic__c, Required__c, Is_Visible__c, Error_Assist_Text__c
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
                mapToList.add('Id');
                mapToList.add(namespace + 'Event__c');
                mapToList.add(namespace + 'Event_Instance__c');
                questionWrapper = new List<questionItem>();
                for (Summit_Events_Question__c question : additionalQuestions) {
                    Object nextField;
                    Boolean fieldExists = true;
                    //Make sure this is really a field
                    try {
                        nextField = Schema.SObjectType.Summit_Events_Registration__c.fields.getMap().get(question.Map_to_Field__c).getDescribe();
                    } catch (Exception e) {
                        fieldExists = false;
                    }

                    //Make sure this field is accessible
                    if (fieldExists && Schema.SObjectType.Summit_Events_Registration__c.isAccessible() &&
                            Schema.SObjectType.Summit_Events_Registration__c.fields.getMap().get(question.Map_to_Field__c).getDescribe().isAccessible() &&
                            Schema.SObjectType.Summit_Events_Registration__c.fields.getMap().get(question.Map_to_Field__c).getDescribe().isCreateable()) {
                        mapToList.add(question.Map_to_Field__c);

                        //build wrapper class to type and make picklist lists
                        questionItem quest = new questionItem();
                        quest.type = question.Question_Field_Type__c;
                        quest.question = question.Question_Label__c;
                        quest.required = question.Required__c;
                        quest.picklist = createPicklists(question.Picklist_Values__c);
                        quest.help = question.Help_Text__c;
                        quest.instructions = question.Instructions__c;
                        quest.assist = question.Error_Assist_Text__c;
                        quest.defaultValue = question.Default_Value__c;
                        quest.textLimit = Integer.valueOf(question.Text_Limit__c);
                        quest.mapTo = question.Map_to_Field__c;
                        questionWrapper.add(quest);
                    }
                }

                String regQuery = '';

                if (mapToList.size() > 0) {
                    regQuery += 'SELECT ';
                    regQuery += String.join(mapToList, ' , ');
                    regQuery += ' FROM Summit_Events_Registration__c ';
                    regQuery += ' WHERE Id = \'' + String.escapeSingleQuotes(eventInformation.registrationId) + '\'';
                }
                if (String.isNotBlank(regQuery)) {
                    eventRegistration = Database.query(regQuery);
                    incomingRegId = eventRegistration.Id;
                    eventRegistration.Id = null;
                }

                System.debug(JSON.serializePretty(mapToList));
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
    public static List<SObject> lookupSearch(String sObj, String sObjFilter, String sObjNameField, String term) {
        return new ActionWithSharing().lookupSearchWithSharing(sObj, sObjFilter, sObjNameField, term);
    }
    public with sharing class ActionWithSharing {
        public List<SObject> lookupSearchWithSharing(String sObj, String sObjFilter, String sObjNameField, String term) {
            if (Schema.getGlobalDescribe().get(sObj).getDescribe().isAccessible()) {
                if (String.isBlank(sObjNameField)) {
                    sObjNameField = 'Name';
                }
                List<String> sObjNameFields = sObjNameField.split(',');

                for (Integer x = 0; x < sObjNameFields.size(); x++) {
                    sObjNameFields[x] = sObjNameFields[x].trim();
                }

                String fieldList = String.join(sObjNameFields, ', ');
                String likeStatement = '';

                for (String sField : sObjNameFields) {
                    likeStatement += sField + ' LIKE \'%' + String.escapeSingleQuotes(term) + '%\' OR ';
                }
                likeStatement = ' ( ' + likeStatement.removeEnd(' OR ') + ' )';

                String query = 'SELECT Id, ' + fieldList;
                query += ' FROM ' + sObj;
                query += ' WHERE ' + likeStatement;
                if (String.isNotBlank(sObjFilter)) {
                    query += ' AND ' + sObjFilter;
                }
                query += ' ORDER BY ' + fieldList + ' ASC';
                query += ' LIMIT 50';
                System.debug('Query -- ' + query);
                System.debug(UserInfo.getProfileId());
                System.debug(UserInfo.getUserRoleId());
                System.debug(UserInfo.getUserType());

                try {
                    return Database.query(query);
                } catch (Exception e) {
                    System.debug('Error --- ' + e.getMessage());
                    return new List<SObject>();
                }
            }
            return new List<SObject>();
        }
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