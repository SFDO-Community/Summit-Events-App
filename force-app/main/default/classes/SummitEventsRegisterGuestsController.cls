/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/7/2021.
 */


public with sharing class SummitEventsRegisterGuestsController {

    public SummitEventsShared seaShared = new SummitEventsShared();
    public SummitEventsShared.SummitEventsInfo eventInformation { get; set; }

    public String navBreadCrumb { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public Summit_Events_Instance__c eventInstance { get; set; }
    public Summit_Events_Registration__c eventRegistration { get; set; }

    public String templateSelected { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean adminOpen { get; set; }
    public Map<String, PageReference> pageFlow { get; set; }
    public String guestJSON { get; set; }
    public Id oldRegId { get; set; }
    public String statePicklist { get; set; }
    public String countryPicklist { get; set; }
    public String namespace { get; set; }

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
                            Guest_Registration_Title__c, Guest_Max_Amount__c,Guest_Registrant_Information__c, Guest_Registration_Description__c, Guest_Table_Size__c, Guest_Tables_Available__c,
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

            eventRegistration = [
                    SELECT Id, Guest_JSON__c
                    FROM Summit_Events_Registration__c
                    WHERE Id = :eventInformation.registrationId
                    WITH SECURITY_ENFORCED
            ];
            guestJSON = eventRegistration.Guest_JSON__c;
            oldRegId = eventRegistration.Id;
            eventRegistration.Id = null;


            pageFlow = SeaShared.getPageFlow(eventInformation.eventId, eventInstance.Instance_Title__c, ApexPages.currentPage());
            System.debug('PAGE FLOW : ' + pageFlow);

            templateSelected = seaShared.getTemplate(eventPage.Template__c);

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                eventIsClosed = adminOpen;
            } else {
                eventIsClosed = seaShared.isEventClosed(eventPage, eventInstance);
            }
            navBreadCrumb = seaShared.navBreadcrumbBuilder(eventInstance, false);

            statePicklist = buildPicklist('State');

            countryPicklist = buildPicklist('Country');
        }
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

        Schema.sObjectField T = F.getSObjectField();
        //List<PicklistEntry> entries = T.getDescribe().getPicklistValues();
        htmlSelect += '<option value="">Select</option>';
        for (Schema.PicklistEntry PicklistValue : T.getDescribe().getPicklistValues()) {
            htmlSelect += '<option value="' + PicklistValue.getValue() + '">' + PicklistValue.getLabel() + '</option>';
        }
        htmlSelect += '</div>';
        htmlSelect += '</select>';
        System.debug(htmlSelect);
        return htmlSelect;
    }

    public List<String> getGuestRequirements() {
        String guestRequirements = eventPage.Guest_Registrant_Information__c;
        if (String.isNotBlank(guestRequirements)) {
            guestRequirements = guestRequirements.replace(' ', '_');
            guestRequirements = guestRequirements.replace('Address', 'Address;City;State;Zip;Country;');
            return guestRequirements.split(';');
        }
        return new List<String>();
    }

    public PageReference checkEventDetails() {
        return seaShared.checkForEvent();
    }

    public PageReference saveGuests() {
        doCRUD crudToDo = new doCRUD();
        crudToDo.updateRegistration(guestJSON, eventRegistration, oldRegId);
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