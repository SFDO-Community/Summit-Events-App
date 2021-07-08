/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/7/2021.
 */


public with sharing class SummitEventsRegisterGuestsController {

    public SummitEventsShared seaShared = new SummitEventsShared();
    public SummitEventsShared.SummitEventsInfo eventInformation { get; set; }
    public String formattedNavDate { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public Summit_Events_Instance__c eventInstance { get; set; }
    public Summit_Events_Registration__c eventRegistration { get; set; }
    public Map<Id, Summit_Events_Question__c> eventGuestQuestions { get; set; }
    public String templateSelected { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean adminOpen { get; set; }
    public Map<String, PageReference> pageFlow { get; set; }
    public String guestJSON { get; set; }
    public String guestQuestionJSON { get; set; }
    public Id oldRegId { get; set; }
    public String statePicklist { get; set; }
    public String countryPicklist { get; set; }
    public String namespace { get; set; }
    public List<questionData> hiddenQuestions { get; set; }

    public class question {
        String id { get; set; }
        String name { get; set; }
        String type { get; set; }
        String question { get; set; }
        Boolean required { get; set; }
        List<String> picklist { get; set; }
        String help { get; set; }
        String instructions { get; set; }
        String defaultValue { get; set; }
        Integer textLimit { get; set; }
    }

    private class questionGuestData {
        String guestId { get; set; }
        List<questionData> questions { get; set; }
    }

    private class questionData {
        String id { get; set; }
        String value { get; set; }
        String question { get; set; }
    }

    public SummitEventsRegisterGuestsController() {
        eventInformation = seaShared.getSummitEventsInfo();
        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace.toLowerCase() + '__';
        }
        if (String.isNotBlank(eventInformation.eventId) && String.isNotBlank(eventInformation.instanceId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_Submit_Title__c, Event_Submit_Description__c, Event_Footer__c, Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c,
                            Tracking_Submit_Registration__c, Event_Full_Text__c, Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c,
                            Guest_Registration_Title__c, Guest_Max_Amount__c, Guest_Registration_Description__c, Guest_Table_Size__c, Guest_Tables_Available__c,
                            Display_Guest_Registration__c
                    FROM Summit_Events__c
                    WHERE Id = :eventInformation.eventId
                    WITH SECURITY_ENFORCED
            ];

            eventInstance = [
                    SELECT Id, Instance_Title__c, Instance_Start_Date__c, Instance_End_Date__c, Instance_Start_Time__c, Instance_End_Time__c, Instance_Time_Zone__c,
                            Current_Available_Capacity__c, Active_Status__c, Event__r.Event_Name__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :eventInformation.instanceId
                    WITH SECURITY_ENFORCED
            ];

            eventGuestQuestions = new Map<Id, Summit_Events_Question__c>([
                    SELECT Name, Question_Label__c, Question_Field_Type__c, Default_Value__c, Registrant_Type__c, Instructions__c, Help_Text__c, Display_Order__c,
                            Map_to_Field__c, Picklist_Values__c, Text_Limit__c, Controlling_Question__c, Controlling_Logic__c, Required__c, Is_Visible__c
                    FROM Summit_Events_Question__c
                    WHERE Event__c = :eventInformation.eventId
                    AND Registrant_Type__c = 'Guest'
                    WITH SECURITY_ENFORCED
                    ORDER BY Display_Order__c NULLS LAST
            ]);

            List<question> questionList = new List<question>();
            hiddenQuestions = new List<questionData>();

            for (Id key : eventGuestQuestions.keySet()) {
                Summit_Events_Question__c seaQuestion = eventGuestQuestions.get(key);
                question q = new question();
                q.id = seaShared.encryptString(seaQuestion.Id);
                q.name = seaQuestion.Name;
                q.question = seaQuestion.Question_Label__c;
                q.type = seaQuestion.Question_Field_Type__c;
                q.required = seaQuestion.Required__c;
                if (String.isNotBlank(seaQuestion.Picklist_Values__c)) {
                    q.picklist = createPicklists(seaQuestion.Picklist_Values__c);
                }
                q.help = seaQuestion.Help_Text__c;
                q.instructions = seaQuestion.Instructions__c;
                q.defaultValue = seaQuestion.Default_Value__c;
                q.textLimit = (Integer) seaQuestion.Text_Limit__c;
                if (seaQuestion.Is_Visible__c) {
                    questionList.add(q);
                } else {
                    questionData hiddenQuestion = new questionData();
                    hiddenQuestion.id = seaShared.encryptString(seaQuestion.Id);
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
                List<questionGuestData> guestAnswers = (List<questionGuestData>) JSON.deserialize(guestJSON, List<questionGuestData>.class);
                for (Integer xx = 0; xx < guestAnswers.size(); xx++) {
                    Integer questionCount = 0;
                    for (Integer yy = 0; yy < guestAnswers[xx].questions.size(); yy++) {
                        Id questionId = null;
                        try {
                            questionId = seaShared.decryptString(guestAnswers[xx].questions[yy].Id, true);
                        } catch (Exception e) {
                            System.debug(e.getMessage());
                        }
                        if (questionId != null) {
                            Summit_Events_Question__c questionParameters = eventGuestQuestions.get(questionId);
                            if (!questionParameters.Is_Visible__c) {
                                //remove NOT visible questions so they do not appear to front end user
                                guestAnswers[xx].questions.remove(yy);
                            }
                        }
                        questionCount++;
                    }
                }
                guestJSON = JSON.serialize(guestAnswers);
            }

            oldRegId = eventRegistration.Id;
            eventRegistration.Id = null;
            pageFlow = seaShared.getPageFlow(eventInformation.eventId, eventInstance.Instance_Title__c, ApexPages.currentPage());
            templateSelected = seaShared.getTemplate(eventPage.Template__c);

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                eventIsClosed = adminOpen;
            } else {
                eventIsClosed = seaShared.isEventClosed(eventPage, eventInstance);
            }
            formattedNavDate = seaShared.navBreadcrumbBuilder(eventInstance);

            statePicklist = buildPicklist('State');

            countryPicklist = buildPicklist('Country');
        }
    }

    public List<String> createPicklists(String returnSepStringList) {
        List<String> cpl = new List<String>();
        if (!String.isBlank(returnSepStringList)) {
            cpl.add('Select...');
            returnSepStringList = returnSepStringList.trim();
            returnSepStringList = returnSepStringList.replace('\n\n', '\n');
            String[] splitList = returnSepStringList.split('\n');
            for (String p : splitList) {
                p = p.replaceAll('[^a-zA-Z0-9@<>?&;:\\[\\]!-. ]', '');
                cpl.add(p);
            }
        }
        return cpl;
    }

    public String buildPicklist(String htmlId) {
        String htmlSelect = '<div class="slds-select_container">';
        htmlSelect += '<select id="' + htmlId + '" name="' + htmlId + '" class="slds-select">';
        Schema.DescribeFieldResult F;
        if (htmlId.equalsIgnoreCase('state')) {
            F = Summit_Events_Registration__c.Registrant_State_Global__c.getDescribe();
        }
        if (htmlId.equalsIgnoreCase('Country')) {
            F = Summit_Events_Registration__c.Registrant_Country__c.getDescribe();
        }

        Schema.SObjectField T = F.getSobjectField();
        //List<PicklistEntry> entries = T.getDescribe().getPicklistValues();
        htmlSelect += '<option value="">Select</option>';
        for (Schema.PicklistEntry PicklistValue : T.getDescribe().getPicklistValues()) {
            htmlSelect += '<option value="' + PicklistValue.getValue() + '">' + PicklistValue.getLabel() + '</option>';
        }
        htmlSelect += '</div>';
        htmlSelect += '</select>';
        return htmlSelect;
    }

    public PageReference checkEventDetails() {
        return seaShared.checkForEvent();
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
                        questionId = seaShared.decryptString(q.id, true);
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
            System.debug(JSON.serializePretty(guestAnswers));
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