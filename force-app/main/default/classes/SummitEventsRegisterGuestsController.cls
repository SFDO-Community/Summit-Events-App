/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/7/2021.
 */


public with sharing class SummitEventsRegisterGuestsController {

    public SummitEventsInfo eventInformation { get; set; }
    public String formattedNavDate { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public Summit_Events_Instance__c eventInstance { get; set; }
    public Summit_Events_Registration__c eventRegistration { get; set; }
    public Map<Id, Summit_Events_Question__c> eventGuestQuestions { get; set; }
    public String templateSelected { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Map<String, PageReference> pageFlow { get; set; }
    public String guestJSON { get; set; }
    public String guestQuestionJSON { get; set; }
    public Id oldRegId { get; set; }
    public String namespace { get; set; }
    private List<questionData> hiddenQuestions { get; set; }

    public class question {
        public String id { get; set; }
        public String name { get; set; }
        public String type { get; set; }
        public String question { get; set; }
        public Boolean required { get; set; }
        public List<Map<String, String>> picklist { get; set; }
        public String help { get; set; }
        public String instructions { get; set; }
        public String assist { get; set; }
        public String defaultValue { get; set; }
        public Integer textLimit { get; set; }
        public String setupError { get; set; }
        public Boolean setupFail { get; set; }
    }

    public class questionGuestData {
        public String guestId { get; set; }
        public List<questionData> questions { get; set; }
    }

    public class questionData {
        public String id { get; set; }
        public String value { get; set; }
        public String question { get; set; }
    }

    public SummitEventsRegisterGuestsController() {
        eventInformation = SummitEventsShared.getSummitEventsInfo();
        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace.toLowerCase() + '__';
        }
        if (String.isNotBlank(eventInformation.eventId) && String.isNotBlank(eventInformation.instanceId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_Submit_Title__c, Event_Submit_Description__c, Event_Footer__c, Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c,
                            Tracking_Submit_Registration__c, Event_Full_Text__c, Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c,
                            Guest_Registration_Title__c, Guest_Max_Amount__c, Guest_Registration_Description__c, Guest_Table_Size__c, Guest_Tables_Available__c,
                            Display_Guest_Registration__c, Guest_Registration_Add_Button_Label__c, No_Guest_Registrations_Added_Message__c,
                            Account__r.Name, Audience__c, Filter_Category__c, Event_Sponsor__c, Guest_Unsaved_Cancel_Label__c, Guest_Unsaved_Continue_Label__c,
                            Guest_Unsaved_Modal_Text__c
                    FROM Summit_Events__c
                    WHERE Id = :eventInformation.eventId
                    WITH SECURITY_ENFORCED
            ];

            eventInstance = [
                    SELECT Id, Instance_Title__c, Instance_Start_Date__c, Instance_End_Date__c, Instance_Start_Time__c, Instance_End_Time__c, Instance_Time_Zone__c,
                            Current_Available_Capacity__c, Active_Status__c, Event__r.Event_Name__c, Registration_Close_Date__c, Registration_Close_Time__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :eventInformation.instanceId
                    WITH SECURITY_ENFORCED
            ];

            eventGuestQuestions = new Map<Id, Summit_Events_Question__c>([
                    SELECT Name, Question_Label__c, Question_Field_Type__c, Default_Value__c, Registrant_Type__c, Instructions__c, Help_Text__c, Display_Order__c,
                            Map_to_Field__c, Picklist_Values__c, Text_Limit__c, Controlling_Question__c, Controlling_Logic__c, Required__c, Is_Visible__c, Error_Assist_Text__c,
                            Existing_Picklist_Values__c, Picklist_Values_Long__c
                    FROM Summit_Events_Question__c
                    WHERE Event__c = :eventInformation.eventId
                    AND (Registrant_Type__c = 'Guest' OR Registrant_Type__c = 'Registrant and Guest')
                    WITH SECURITY_ENFORCED
                    ORDER BY Display_Order__c NULLS LAST
            ]);

            List<question> questionList = new List<question>();
            hiddenQuestions = new List<questionData>();

            for (Id key : eventGuestQuestions.keySet()) {
                Summit_Events_Question__c seaQuestion = eventGuestQuestions.get(key);
                question q = new question();
                //Check all mapTo fields before adding question
                q.setupFail = false;
                q.setupError = '';
                q.setupError = SummitEventsShared.checkFieldGuestAccess(namespace + 'Summit_Events_Registration__c', eventGuestQuestions.get(key).Map_to_Field__c, '', true, '');
                q.name = seaQuestion.Name;
                q.question = seaQuestion.Question_Label__c;
                q.id = SummitEventsShared.encryptString(seaQuestion.Id);
                q.name = seaQuestion.Name;
                q.question = seaQuestion.Question_Label__c;
                q.type = seaQuestion.Question_Field_Type__c;
                q.required = seaQuestion.Required__c;
                if (String.isNotBlank(seaQuestion.Existing_Picklist_Values__c)) {
                    q.picklist = createExistingPicklist(seaQuestion.Existing_Picklist_Values__c);
                } else if (String.isNotBlank(seaQuestion.Picklist_Values__c) || String.isNotBlank(seaQuestion.Picklist_Values_Long__c)) {
                    q.picklist = createPicklists(seaQuestion.Picklist_Values__c, seaQuestion.Picklist_Values_Long__c);
                }
                q.help = seaQuestion.Help_Text__c;
                q.instructions = seaQuestion.Instructions__c;
                q.defaultValue = seaQuestion.Default_Value__c;
                q.textLimit = (Integer) seaQuestion.Text_Limit__c;
                q.assist = seaQuestion.Error_Assist_Text__c;
                if (seaQuestion.Is_Visible__c) {
                    questionList.add(q);
                } else {
                    questionData hiddenQuestion = new questionData();
                    hiddenQuestion.id = SummitEventsShared.encryptString(seaQuestion.Id);
                    hiddenQuestion.value = seaQuestion.Default_Value__c;
                    hiddenQuestion.question = seaQuestion.Question_Label__c;
                    hiddenQuestions.add(hiddenQuestion);
                }
            }

            guestQuestionJSON = JSON.serialize(questionList);

            eventRegistration = [
                    SELECT Id, Guest_JSON__c
                    FROM Summit_Events_Registration__c
                    WHERE Id = :eventInformation.registrationId
                    WITH SECURITY_ENFORCED
            ];

            guestJSON = eventRegistration.Guest_JSON__c;

            //remove hidden inputs
            if (String.isNotEmpty(guestJSON)) {
                List<questionGuestData> hostedGuests = (List<questionGuestData>) JSON.deserialize(guestJSON, List<questionGuestData>.class);
                for (Integer xx = 0; xx < hostedGuests.size(); xx++) {
                    Integer questionCount = 0;
                    for (Integer yy = 0; yy < hostedGuests[xx].questions.size(); yy++) {
                        Id questionId = null;
                        try {
                            questionId = SummitEventsShared.decryptString(hostedGuests[xx].questions[yy].id, true);
                        } catch (Exception e) {
                            System.debug(e.getMessage());
                        }
                        if (questionId != null) {
                            Summit_Events_Question__c questionParameters = eventGuestQuestions.get(questionId);
                            if (!questionParameters.Is_Visible__c) {
                                //remove NOT visible questions so they do not appear to front end user
                                hostedGuests[xx].questions.remove(yy);
                            }
                        }
                        questionCount++;
                    }
                }
                guestJSON = JSON.serialize(hostedGuests);
            }

            oldRegId = eventRegistration.Id;
            eventRegistration.Id = null;
            pageFlow = SummitEventsShared.getPageFlow(eventInformation.eventId, eventInstance.Instance_Title__c, ApexPages.currentPage(), eventInstance.Instance_Start_Date__c, eventInstance.Instance_End_Date__c);
            templateSelected = SummitEventsShared.getTemplate(eventPage.Template__c);

            eventIsClosed = SummitEventsShared.isEventClosed(eventInstance);

            formattedNavDate = SummitEventsShared.navBreadcrumbBuilder(eventInstance);

        }
    }

    public List<Map<String, String>> createPicklists(String pickListString, String pickListString2) {
        List<Map<String, String>> cpl = new List<Map<String, String>>();
        List<SelectOption> splitList = SummitEventsShared.createPicklistsFromStrings(pickListString, pickListString2);
        for (SelectOption p : splitList) {
            cpl.add(new Map<String, String>{
                    p.getLabel() => p.getValue()
            });
        }
        return cpl;
    }

    public List<Map<String, String>> createExistingPicklist(String existingPicklist) {
        List<Map<String, String>> picklists = new List<Map<String, String>>();
        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace.toLowerCase() + '__';
        }

        Schema.DescribeSObjectResult registrationDescribe = ((SObject) Type.forName('Schema', namespace + 'Summit_Events_Registration__c').newInstance()).getSObjectType().getDescribe();

        String existingPicklistString = existingPicklist;
        if (!existingPicklistString.startsWith('c__')) {
            existingPicklistString = namespace + existingPicklistString;
        } else if (existingPicklistString.startsWith('c__')) {
            existingPicklistString = existingPicklist.removeStart('c__');
        }

        List<Schema.PicklistEntry> PicklistValues = registrationDescribe.fields.getMap().get(existingPicklistString).getDescribe().getPicklistValues();
        picklists.add(new Map<String, String>{
                'Select...' => ''
        });
        for (Schema.PicklistEntry PicklistValue : PicklistValues) {
            picklists.add(new Map<String, String>{
                    PicklistValue.getLabel() => PicklistValue.getValue()
            });
        }
        return picklists;
    }

    public PageReference checkEventDetails() {
        return SummitEventsShared.checkForEvent('guest');
    }

    public PageReference saveGuests() {
        doCRUD crudToDo = new doCRUD();
        //sanitize data
        if (String.isNotBlank(guestJSON)) {
            List<questionGuestData> guestAnswers = (List<questionGuestData>) JSON.deserialize(guestJSON, List<questionGuestData>.class);
            for (Integer xx = 0; xx < guestAnswers.size(); xx++) {
                Integer questionCount = 0;
                for (questionData q : guestAnswers[xx].questions) {
                    Id questionId = null;
                    try {
                        questionId = SummitEventsShared.decryptString(q.id, true);
                    } catch (Exception e) {
                        System.debug(e.getMessage());
                    }
                    if (questionId != null) {
                        Summit_Events_Question__c questionParameters = eventGuestQuestions.get(questionId);
                        //Remove all html tags from user input (done in javascript, but making sure on the back end)
                        q.value = q.value.replaceAll('<[^>]+>', '').trim();
                        //q.value = String.escapeSingleQuotes(q.value);
                        //q.value = q.value.escapeHtml4();
                        String fieldType = questionParameters.Question_Field_Type__c;
                        if (fieldType.equalsIgnoreCase('Text box')) {
                        }
                    }
                    questionCount++;
                }
                guestAnswers[xx].questions.addAll(hiddenQuestions);
            }
            guestJSON = JSON.serialize(guestAnswers);
            crudToDo.updateRegistration(guestJSON, eventRegistration, oldRegId);
        }
        return pageFlow.get('Next');
    }

    public PageReference previousPage() {
        return pageFlow.get('Previous');
    }

    private without sharing class doCRUD {

        public void updateRegistration(String jsonOut, Summit_Events_Registration__c eventRegistration, Id oldRegId) {
            eventRegistration.Id = oldRegId;
            eventRegistration.Guest_JSON__c = jsonOut;
            try {
                upsert eventRegistration;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

    }


}