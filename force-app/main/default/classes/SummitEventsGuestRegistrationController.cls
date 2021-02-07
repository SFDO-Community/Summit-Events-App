/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/7/2021.
 */


public with sharing class SummitEventsGuestRegistrationController {

    public SummitEventsShared seaShared = new SummitEventsShared();
    public SummitEventsShared.SummitEventsInfo eventInformation { get; set; }
    public String navBreadCrumb { get; set; }
    public Summit_Events_Instance__c eventInstance { get; set; }
    public String templateSelected { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean adminOpen { get; set; }
    public Summit_Events__c eventPage { get; set; }

    public SummitEventsGuestRegistrationController() {
        eventInformation = seaShared.getSummitEventsInfo();
        if (String.isNotBlank(eventInformation.eventId) && String.isNotBlank(eventInformation.instanceId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_Submit_Title__c, Event_Submit_Description__c, Event_Footer__c, Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c,
                            Tracking_Submit_Registration__c, Event_Full_Text__c, Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c
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

            templateSelected = seaShared.getTemplate(eventPage.Template__c);

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                eventIsClosed = adminOpen;
            } else {
                eventIsClosed = seaShared.isEventClosed(eventPage, eventInstance);
            }

            navBreadCrumb = seaShared.navBreadcrumbBuilder(eventInstance, false);

        }
    }

    public PageReference checkEventDetails() {
        return seaShared.checkForEvent();
    }

    public PageReference saveGuests() {

        PageReference nextPage;
        List<Summit_Events_Appointment_Type__c> appointmentTypes = null;

        appointmentTypes = [
                SELECT Id
                FROM Summit_Events_Appointment_Type__c
                WHERE Summit_Events__c = :eventInformation.eventId
                AND (
                        Restrict_To_Instance_Title__r.Instance_Title__c = :eventInstance.Instance_Title__c
                        OR Restrict_To_Instance_Title__r.Instance_Title__c = NULL)
        ];

        if (appointmentTypes.size() == 0) {
            //If no options skip that step
            nextPage = Page.SummitEventsRegister;
        } else {
            nextPage = Page.SummitEventsRegisterAppointments;
        }
        return void;
    }

    public PageReference previousPage() {




        PageReference lastPage;

//        if (appointmentTypes.size() == 0) {
//            //If no options skip that step
//            lastPage = Page.SummitEventsRegister;
//        } else {
//            lastPage = Page.SummitEventsRegisterAppointments;
//        }

        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
            lastPage.setRedirect(true);
            lastPage.getParameters().put('adminopen', ApexPages.currentPage().getParameters().get('adminopen'));
        }
        return lastPage;

    }
}