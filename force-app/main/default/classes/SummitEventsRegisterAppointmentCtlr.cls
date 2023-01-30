// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsRegisterAppointmentCtlr {
    public SummitEventsShared seaShared = new SummitEventsShared();
    public SummitEventsShared.SummitEventsInfo eventInformation { get; set; }
    public Map<Id, Summit_Events_Appointment_Type__c> appointments { get; set; }
    public List<Summit_Events_Appointments__c> chosenApps { get; set; }
    public Summit_Events_Instance__c evtInstance { get; set; }
    public String incomingAppointmentJSON { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean adminOpen { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public String templateSelected { get; set; }
    public Boolean noOptionalAppointments { get; set; }
    public Boolean requiredAppointments { get; set; }
    public String formattedNavDate { get; set; }
    public List<incomingAppointments> allAvailableAppointments { get; set; }
    public Map<String, PageReference> pageFlow { get; set; }

    public class incomingAppointments {
        public String appId { get; set; }
        public String appCategory { get; set; }
        public String appType { get; set; }
        public String appTitle { get; set; }
        public String appChosenState { get; set; }
        public String appDesc { get; set; }
        public String appSort { get; set; }
        public String appInput { get; set; }
        public Integer appLimit { get; set; }
        public Boolean appRequired { get; set; }
        public List<String> picklistItemList { get; set; }
    }

    public SummitEventsRegisterAppointmentCtlr() {
        eventIsClosed = false;
        eventInformation = seaShared.getSummitEventsInfo();
        noOptionalAppointments = true;

        Map<String, Integer> appCount = new Map<String, Integer>();

        if (!String.isBlank(eventInformation.eventId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_description__c, Event_Appointment_Title__c, Event_Appointment_Description__c, Event_Footer__c,
                            Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Options_Registration__c, Event_Full_Text__c,
                            Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c, Display_Optional_Donation__c
                    FROM Summit_Events__c
                    WHERE Id = :eventInformation.eventId
                    WITH SECURITY_ENFORCED
            ];

            templateSelected = seaShared.getTemplate(eventPage.Template__c);

            if (!String.isBlank(eventInformation.registrationId)) {
                evtInstance = [
                        SELECT Instance_Title__c, Event__r.Event_Name__c,
                                Instance_Time_Zone__c, Instance_Start_Time__c, Instance_End_Time__c, Instance_Start_Date__c,
                                Instance_End_Date__c, Current_Available_Capacity__c, Active_Status__c, Registration_Close_Date__c, Registration_Close_Time__c
                        FROM Summit_Events_Instance__c
                        WHERE Id = :eventInformation.instanceId
                        WITH SECURITY_ENFORCED
                ];

                pageFlow = seaShared.getPageFlow(eventInformation.eventId, evtInstance.Instance_Title__c, ApexPages.currentPage());

                if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                    adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                    eventIsClosed = adminOpen;
                } else {
                    eventIsClosed = seaShared.isEventClosed(eventPage, evtInstance);
                }

                if (evtInstance != null) {
                    String dayOfWeek = seaShared.convertDateToDatetime(evtInstance.Instance_Start_Date__c, null, '').format('EEEE');
                    // = dayOfWeek;
                    //Build available appointments
                    appointments = new Map<Id, Summit_Events_Appointment_Type__c>([
                            SELECT Id, Name, Title__c, Description__c, Appointment_Type__c, Appointment_Category__c, Appointment_Limits__c, Chosen_State__c,
                                    Registrant_Input__c, Custom_Picklist__c, Sort_Order__c, Auto_Confirm_Appointment__c, Auto_add_building__c, Auto_Add_Time__c, Do_Not_Show_Time__c,
                                    Date_Available_Start__c, Date_Available_End__c, Day_of_Week_Availability__c, Required_Appointment__c, Appointment_Type_Status__c
                            FROM Summit_Events_Appointment_Type__c
                            WHERE Summit_Events__c = :eventInformation.eventId
                            AND (Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = NULL)
                            AND (Date_Available_Start__c <= :evtInstance.Instance_Start_Date__c OR Date_Available_Start__c = NULL)
                            AND (Date_Available_End__c >= :evtInstance.Instance_End_Date__c OR Date_Available_End__c = NULL)
                            AND (Day_of_Week_Availability__c INCLUDES (:dayOfWeek) OR Day_of_Week_Availability__c = NULL)
                            AND (Appointment_Type_Status__c = 'Active' OR Appointment_Type_Status__c = NULL)
                            WITH SECURITY_ENFORCED
                            ORDER BY Sort_Order__c ASC NULLS LAST
                    ]);

                    formattedNavDate = seaShared.navBreadcrumbBuilder(evtInstance);

                    //Check if the user gets to select any appointments or they are all auto added

                    allAvailableAppointments = new List<incomingAppointments>();

                    for (Summit_Events_Appointment_Type__c chosenCheck : appointments.values()) {
                        if (chosenCheck.Chosen_State__c != 'Added and Required' && chosenCheck.Chosen_State__c != 'Added but not shown') {
                            noOptionalAppointments = false;
                            break;
                        }
                    }

                    //Gather up the appointments that have already been chosen.
                    chosenApps = [
                            SELECT Id, Appointment_Category__c, Event_Appointment_Type__c, Appointment_Type__c, Appointment_Title__c, Chosen_State__c, Description__c, Sort_Order__c,
                                    Registrant_Input__c, Do_Not_Show_Time__c
                            FROM Summit_Events_Appointments__c
                            WHERE Event_Registration__c = :eventInformation.registrationId
                            AND Client_Created_Appointment__c = TRUE
                            WITH SECURITY_ENFORCED
                    ];


                    for (Summit_Events_Appointments__c c : chosenApps) {

                        //Keep track of appointment ids to not show in available appointments later
                        if (!String.isBlank(c.Event_Appointment_Type__c)) {
                            if (!appCount.containsKey(c.Event_Appointment_Type__c)) {
                                appCount.put(c.Event_Appointment_Type__c, 0);
                            }
                            Integer increment = appCount.get(c.Event_Appointment_Type__c) + 1;
                            appCount.put(c.Event_Appointment_Type__c, increment);
                        }

                    }
                }
            }

            requiredAppointments = false;
            for (Summit_Events_Appointment_Type__c apt : appointments.values()) {
                Integer appLimit = 1;
                if (!String.isBlank(apt.Appointment_Limits__c)) {
                    appLimit = Integer.valueOf(apt.Appointment_Limits__c);
                }
                if (appCount.containsKey(apt.Id)) {
                    appLimit = appLimit - (Integer.valueOf(appCount.get(apt.Id)));
                }

                incomingAppointments addAppointment = new incomingAppointments();

                addAppointment.appId = apt.Id;
                addAppointment.appCategory = apt.Appointment_Category__c;
                addAppointment.appType = apt.Appointment_Type__c;
                addAppointment.appTitle = apt.Title__c;
                addAppointment.appChosenState = apt.Chosen_State__c;
                addAppointment.appDesc = apt.Description__c;
                addAppointment.appSort = String.valueOf(apt.Sort_Order__c);
                addAppointment.appInput = apt.Registrant_Input__c;
                addAppointment.appLimit = appLimit;
                addAppointment.appRequired = apt.Required_Appointment__c;

                if (apt.Appointment_Category__c != null) {
                    Map<String, String> dependencies = seaShared.getDependentSelectOptions('Summit_Events_Appointment_Type__c', 'Appointment_Category__c', 'Appointment_Type__c', apt.Appointment_Category__c);
                    if (dependencies.size() > 1) {
                        List<String> pickListItems = new List<String>();
                        for (String item : dependencies.keySet()) {
                            pickListItems.add(dependencies.get(item));
                        }
                        addAppointment.picklistItemList = pickListItems;
                    }
                }

                if (apt.Registrant_Input__c == 'Custom pick list') {
                    if (!String.isBlank(apt.Custom_Picklist__c)) {
                        String custPickListText = apt.Custom_Picklist__c;
                        custPickListText = custPickListText.trim();
                        custPickListText = custPickListText.replace('\n\n', '\n');
                        String[] custPckListList = custPickListText.split('\n');
                        List<String> pickListItems = new List<String>();
                        for (String cp : custPckListList) {
                            pickListItems.add(cp.replaceAll('[^a-zA-Z0-9@<>?&;:\\[\\]!-. ]', ''));
                        }
                        addAppointment.picklistItemList = pickListItems;
                    }
                }
                allAvailableAppointments.add(addAppointment);
            }
        }
    }


    public PageReference checkEventDetails() {
        return seaShared.checkForEvent();
    }

    public PageReference saveOptions() {
        //remove old client created appointments
        crudToDo doCRUD = new crudToDo();

        List<Summit_Events_Appointments__c> deleteAppointments = [
                SELECT Id, Event_Registration__c, Client_Created_Appointment__c, Chosen_State__c, Do_Not_Show_Time__c
                FROM Summit_Events_Appointments__c
                WHERE Event_Registration__c = :eventInformation.registrationId
                AND Client_Created_Appointment__c = TRUE
                WITH SECURITY_ENFORCED
        ];
        doCRUD.deleteAppointments(deleteAppointments);

        List<incomingAppointments> incomingAppointments = (List<incomingAppointments>) JSON.deserialize(incomingAppointmentJSON, List<incomingAppointments>.class);

        List<Summit_Events_Appointments__c> appointmentsToAdd = new List<Summit_Events_Appointments__c>();
        for (incomingAppointments app : incomingAppointments) {

            Summit_Events_Appointments__c addAppointment = new Summit_Events_Appointments__c();
            addAppointment.Event_Registration__c = eventInformation.registrationId;
            addAppointment.Appointment_Status__c = 'Registered';
            addAppointment.Client_Created_Appointment__c = true;
            addAppointment.Event_Appointment_Type__c = app.appId;
            Summit_Events_Appointment_Type__c appDefinition = appointments.get(app.appId);

            addAppointment.Chosen_State__c = app.appChosenState;
            if (String.isNotBlank(app.appCategory) && app.appCategory != 'null' && app.appCategory != 'undefined') {
                addAppointment.Appointment_Category__c = app.appCategory;
            }
            if (String.isNotBlank(app.appType) && app.appType != 'null' && app.appType != 'undefined') {
                addAppointment.Appointment_Type__c = app.appType;
            }
            addAppointment.Appointment_Title__c = app.appTitle;
            addAppointment.Sort_Order__c = appDefinition.Sort_Order__c;


            //Auto add fields from appointment type as defined auto add
            //TODO: slim down on ui interface storing values and used app Type map ID to get them
            if (!String.isBlank(appDefinition.Auto_add_building__c)) {
                addAppointment.Building__c = appDefinition.Auto_add_building__c;
            }
            if (appDefinition.Auto_Confirm_Appointment__c) {
                addAppointment.Appointment_Status__c = 'Confirmed';
            }
            if (appDefinition.Do_Not_Show_Time__c != null) {
                addAppointment.Do_Not_Show_Time__c = appDefinition.Do_Not_Show_Time__c;
            }
            if (appDefinition.Auto_Add_Time__c != null) {
                addAppointment.Appointment_Time__c = appDefinition.Auto_Add_Time__c;
            }
            addAppointment.Description__c = app.appDesc;
            if (String.isNotBlank(addAppointment.Registrant_Input__c)) {
                addAppointment.Registrant_Input__c = app.appInput;
            }
            appointmentsToAdd.add(addAppointment);
        }

        if (appointmentsToAdd.size() > 0) {
            doCRUD.updateAppointments(appointmentsToAdd);
        }
        return pageFlow.get('Next');
    }

    public PageReference previousPage() {
        return pageFlow.get('Previous');
    }

    /**
     * Summit Events is a multi-step, guest user, registration solution so CRUD work needs to be done on records where guest record ownership is lost between steps.
     * The security aspects of guest record updating is achieved by:
     * - Using an encrypted cookie on the client browser to keep track of registration id, event id, instance id, and audience
     * - Dividing each controller class into a "with sharing" logic area and a sub "without sharing" CRUD area for purposeful CRUD
     * - When the encrypted cookie is not available as in the cancel registration link an encrypted string is provided through the URL to not expose the SF ID related to the record
     **/

    private without sharing class crudToDo {

        public void updateAppointments(List<Summit_Events_Appointments__c> appointments) {
            try {
                insert appointments;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }
        }

        public void deleteAppointments(List<Summit_Events_Appointments__c> appointments) {
            try {
                delete appointments;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }
        }

    }
}