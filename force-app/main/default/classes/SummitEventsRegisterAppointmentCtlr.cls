// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsRegisterAppointmentCtlr {
    public SummitEventsInfo eventInformation { get; set; }
    public Map<Id, Summit_Events_Appointment_Type__c> appointments { get; set; }
    public List<Summit_Events_Appointments__c> chosenApps { get; set; }
    public Summit_Events_Instance__c evtInstance { get; set; }
    public String incomingAppointmentJSON { get; set; }
    public Boolean eventIsClosed { get; set; }
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
        public Boolean appTypeSet { get; set; }
        public String appTitle { get; set; }
        public String appChosenState { get; set; }
        public String appDesc { get; set; }
        public String appSort { get; set; }
        public String appInput { get; set; }
        public Integer appLimit { get; set; }
        public Boolean appRequired { get; set; }
        public Boolean inputRequired { get; set; }
        public List<String> picklistItemList { get; set; }
    }

    public SummitEventsRegisterAppointmentCtlr() {
        eventIsClosed = false;
        eventInformation = SummitEventsShared.getSummitEventsInfo();
        noOptionalAppointments = true;

        Map<String, Integer> appCount = new Map<String, Integer>();

        if (!String.isBlank(eventInformation.eventId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_description__c, Event_Appointment_Title__c, Event_Appointment_Description__c, Event_Footer__c,
                            Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Options_Registration__c, Event_Full_Text__c,
                            Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c, Display_Optional_Donation__c, Event_Appointment_Chosen_Label__c,
                            Event_Appointment_Unchosen_Label__c, Event_Appointment_Next_Instructions__c, Account__r.Name, Audience__c, Filter_Category__c, Event_Sponsor__c,
                            Event_Status__c
                    FROM Summit_Events__c
                    WHERE Id = :eventInformation.eventId
                    WITH SECURITY_ENFORCED
            ];

            templateSelected = SummitEventsShared.getTemplate(eventPage.Template__c);

            if (!String.isBlank(eventInformation.registrationId)) {
                evtInstance = [
                        SELECT Instance_Title__c, Event__r.Event_Name__c,
                                Instance_Time_Zone__c, Instance_Start_Time__c, Instance_End_Time__c, Instance_Start_Date__c,
                                Instance_End_Date__c, Current_Available_Capacity__c, Active_Status__c, Registration_Close_Date__c, Registration_Close_Time__c
                        FROM Summit_Events_Instance__c
                        WHERE Id = :eventInformation.instanceId
                        WITH SECURITY_ENFORCED
                ];

                pageFlow = SummitEventsShared.getPageFlow(eventInformation.eventId, evtInstance.Instance_Title__c, ApexPages.currentPage(), evtInstance.Instance_Start_Date__c, evtInstance.Instance_End_Date__c);

                eventIsClosed = SummitEventsShared.isEventClosed(evtInstance, eventPage.Event_Status__c);

                if (evtInstance != null) {
                    String dayOfWeek = SummitEventsShared.convertDateToDatetime(evtInstance.Instance_Start_Date__c, null, '').format('EEEE');
                    // = dayOfWeek;
                    //Build appointments
                    appointments = new Map<Id, Summit_Events_Appointment_Type__c>([
                            SELECT Id, Name, Title__c, Description__c, Appointment_Type__c, Appointment_Category__c, Appointment_Limits__c, Chosen_State__c,
                                    Registrant_Input__c, Custom_Picklist__c, Sort_Order__c, Auto_Confirm_Appointment__c, Auto_add_building__c, Auto_Add_Time__c, Do_Not_Show_Time__c,
                                    Date_Available_Start__c, Date_Available_End__c, Day_of_Week_Availability__c, Required_Appointment__c, Appointment_Type_Status__c,
                                    Enforce_Registrations_Limit__c, Appointment_Registrations_Limit__c, (SELECT Id FROM UG_Visit_Appointments__r)
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

                    List<Id> unavailableAppointments = new List<Id>();
                    for(Summit_Events_Appointment_Type__c apt : appointments.values()){
                        if(apt.Enforce_Registrations_Limit__c){
                            if( apt.UG_Visit_Appointments__r.size() >= apt.Appointment_Registrations_Limit__c){
                                unavailableAppointments.add(apt.Id);
                            }
                        }
                    }
                    for(Id unavailableAppointmentId : unavailableAppointments){
                        appointments.remove(unavailableAppointmentId);
                    }
                    
                    formattedNavDate = SummitEventsShared.navBreadcrumbBuilder(evtInstance);

                    //Check if the user gets to select any appointments or they are all auto added

                    allAvailableAppointments = new List<incomingAppointments>();

                    for (Summit_Events_Appointment_Type__c chosenCheck : appointments.values()) {
                        if (chosenCheck.Chosen_State__c != 'Added and Required' && chosenCheck.Chosen_State__c != 'Added but not shown') {
                            noOptionalAppointments = false;
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

                    //Add the chosen state appointments
                    for (Integer x = 0; x < chosenApps.size(); x++) {
                        chosenApps[x].Description__c = SummitEventsShared.removeHTMLandEscape(chosenApps[x].Description__c, false);
                        //Keep track of appointment ids to not show in available appointments later
                        if (!String.isBlank(chosenApps[x].Event_Appointment_Type__c)) {
                            if (!appCount.containsKey(chosenApps[x].Event_Appointment_Type__c)) {
                                appCount.put(chosenApps[x].Event_Appointment_Type__c, 0);
                            }
                            Integer increment = appCount.get(chosenApps[x].Event_Appointment_Type__c) + 1;
                            appCount.put(chosenApps[x].Event_Appointment_Type__c, increment);
                        }
                    }

                    requiredAppointments = false;
                    if (appointments.size() > 0) {
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
                            addAppointment.inputRequired = false;
                            if(String.isNotBlank(apt.Appointment_Type__c)) {
                                addAppointment.appTypeSet = true;
                            }

                            if (String.isNotBlank(apt.Registrant_Input__c) && apt.Registrant_Input__c.containsIgnoreCase('Required')) {
                                addAppointment.inputRequired = true;
                            }

                            if (apt.Appointment_Category__c != null) {
                                Map<String, String> dependencies = SummitEventsShared.getDependentSelectOptions('Summit_Events_Appointment_Type__c', 'Appointment_Category__c', 'Appointment_Type__c', apt.Appointment_Category__c);
                                List<String> pickListItems = new List<String>();
                                if (dependencies.size() > 0) {
                                    for (String item : dependencies.keySet()) {
                                        pickListItems.add(dependencies.get(item));
                                    }
                                    addAppointment.picklistItemList = pickListItems;
                                }
                            }

                            if (String.isNotBlank(apt.Registrant_Input__c)) {
                                if (apt.Registrant_Input__c.equalsIgnoreCase('Custom pick list') || apt.Registrant_Input__c.equalsIgnoreCase('Required custom pick list')) {
                                    if (String.isNotBlank(apt.Custom_Picklist__c)) {
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
                            }
                            allAvailableAppointments.add(addAppointment);
                        }
                    }

                }
            }
        }
    }


    public PageReference checkEventDetails() {
        return SummitEventsShared.checkForEvent('appointment');
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

            //Get appointment type information to pass on to appointment from appointment map above
            Summit_Events_Appointment_Type__c appDefinition = appointments.get(app.appId);
            addAppointment.Appointment_Type__c = appDefinition.Appointment_Type__c;
            addAppointment.Appointment_Title__c = appDefinition.Title__c;
            addAppointment.Sort_Order__c = appDefinition.Sort_Order__c;
            addAppointment.Description__c = appDefinition.Description__c;


            //Set know states
            addAppointment.Event_Registration__c = eventInformation.registrationId;
            addAppointment.Appointment_Status__c = 'Requested';
            addAppointment.Client_Created_Appointment__c = true;

            if (!String.isBlank(appDefinition.Auto_add_building__c)) {
                addAppointment.Building__c = appDefinition.Auto_add_building__c;
            }
            System.debug(appDefinition.Auto_Confirm_Appointment__c);
            if (appDefinition.Auto_Confirm_Appointment__c) {
                addAppointment.Appointment_Status__c = 'Confirmed';
            }
            if (appDefinition.Do_Not_Show_Time__c != null) {
                addAppointment.Do_Not_Show_Time__c = appDefinition.Do_Not_Show_Time__c;
            }
            if (appDefinition.Auto_Add_Time__c != null) {
                addAppointment.Appointment_Time__c = appDefinition.Auto_Add_Time__c;
            }

            //Get values passed in from page in JSON
            addAppointment.Event_Appointment_Type__c = app.appId;
            addAppointment.Chosen_State__c = app.appChosenState;
            if (String.isNotBlank(app.appCategory) && app.appCategory != 'null' && app.appCategory != 'undefined') {
                addAppointment.Appointment_Category__c = app.appCategory;
                if (String.isNotBlank(app.appInput) && String.isBlank(addAppointment.Appointment_Type__c)) {
                    addAppointment.Appointment_Type__c = app.appInput;
                }
            }
            if (String.isNotBlank(app.appInput)) {
                addAppointment.Registrant_Input__c = app.appInput;
            }
            appointmentsToAdd.add(addAppointment);
        }

        if (appointmentsToAdd.size() > 0) {
            doCRUD.insertAppointments(appointmentsToAdd);
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

        public void insertAppointments(List<Summit_Events_Appointments__c> appointments) {
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