// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsRegisterAppointmentCtlr {
    public SummitEventsShared seaShared = new SummitEventsShared();
    public String test { get; set; }
    public SummitEventsShared.SummitEventsInfo eventInformation { get; set; }
    public Map<Id, Summit_Events_Appointment_Type__c> appts { get; set; }
    public List<Summit_Events_Appointments__c> chosenAppts { get; set; }
    public Summit_Events_Instance__c evtInstance { get; set; }
    public String appointments { get; set; }
    public String chosenFormatted { get; set; }
    public String incomingAppointmentJSON { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean adminOpen { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public String templateSelected { get; set; }
    public Boolean noOptionalAppointments { get; set; }
    public Boolean requiredAppt { get; set; }
    public String navBreadCrumb { get; set; }

    public class incomingAppt {
        String apptId;
        String apptCatagory;
        String apptType;
        String apptTitle;
        String appChosenState;
        String appDesc;
        String appSort;
        String appInput;
    }

    public SummitEventsRegisterAppointmentCtlr() {
        eventIsClosed = false;
        test = '';
        eventInformation = seaShared.getSummitEventsInfo();
        System.debug('cookie reception on appointment page: ' + JSON.serializePretty(eventInformation));
        appointments = '';
        chosenFormatted = '';
        noOptionalAppointments = true;

        Map<String, Integer> apptCount = new Map<String, Integer>();

        if (!String.isBlank(eventInformation.eventId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_description__c, Event_Appointment_Title__c, Event_Appointment_Description__c, Event_Footer__c,
                            Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Options_Registration__c, Event_Full_Text__c,
                            Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c, Display_Optional_Donation__c
                    FROM Summit_Events__c
                    WHERE Id = :eventInformation.eventId
            ][0];

            templateSelected = seaShared.getTemplate(eventPage.Template__c);

            if (!String.isBlank(eventInformation.registrationId)) {
                evtInstance = [
                        SELECT Instance_Title__c, Event__r.Event_Name__c,
                                Instance_Time_Zone__c, Instance_Start_Time__c, Instance_End_Time__c, Instance_Start_Date__c,
                                Instance_End_Date__c, Current_Available_Capacity__c, Active_Status__c
                        FROM Summit_Events_Instance__c
                        WHERE Id = :eventInformation.instanceId
                        LIMIT 1
                ];

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
                    appts = new Map<Id, Summit_Events_Appointment_Type__c>([
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
                            ORDER BY Sort_Order__c ASC NULLS LAST
                    ]);

                    navBreadCrumb = seaShared.navBreadcrumbBuilder(evtInstance, false);

                    //Check if the user gets to select any appointments or they are all auto added
                    for (Summit_Events_Appointment_Type__c chosenCheck : appts.values()) {
                        if (chosenCheck.Chosen_State__c != 'Added and Required' && chosenCheck.Chosen_State__c != 'Added but not shown') {
                            noOptionalAppointments = false;
                            break;
                        }
                    }

                    //Gather up the appointments that have already been chosen.
                    chosenAppts = [
                            SELECT Id, Appointment_Category__c, Event_Appointment_Type__c, Appointment_Type__c, Appointment_Title__c, Chosen_State__c, Description__c, Sort_Order__c,
                                    Registrant_Input__c, Do_Not_Show_Time__c
                            FROM Summit_Events_Appointments__c
                            WHERE Event_Registration__c = :eventInformation.registrationId
                            AND Client_Created_Appointment__c = TRUE
                    ];


                    for (Summit_Events_Appointments__c cappt : chosenAppts) {

                        //Keep track of appointment ids to not show in available appointments later
                        if (!String.isBlank(cappt.Event_Appointment_Type__c)) {
                            if (!apptCount.containsKey(cappt.Event_Appointment_Type__c)) {
                                apptCount.put(cappt.Event_Appointment_Type__c, 0);
                            }
                            Integer increment = apptCount.get(cappt.Event_Appointment_Type__c) + 1;
                            apptCount.put(cappt.Event_Appointment_Type__c, increment);
                        }

                        //build chosen appointments for list

                        chosenFormatted += '<div id="appt-' + cappt.Id + '"';
                        chosenFormatted += ' data-apptid="' + cappt.Event_Appointment_Type__c + '"';
                        chosenFormatted += ' data-apptcat="' + cappt.Appointment_Category__c + '"';
                        chosenFormatted += ' data-appttype="' + cappt.Appointment_Type__c + '"';
                        chosenFormatted += ' data-appttitle="' + cappt.Appointment_Title__c + '"';
                        chosenFormatted += ' data-appchosenstate="' + cappt.Chosen_State__c + '"';
                        chosenFormatted += ' data-appsort="' + cappt.Sort_Order__c + '"';
                        chosenFormatted += ' data-appreginput="' + cappt.Registrant_Input__c + '"';
                        chosenFormatted += ' class="appointmentChosen slds-box slds-box_small slds-m-vertical_x-small"';
                        if (cappt.Chosen_State__c == 'Added but not shown') {
                            chosenFormatted += ' style="display:none" ';
                        }
                        chosenFormatted += ' >';
                        chosenFormatted += '<p class="appointmentTitle">' + cappt.Appointment_Title__c + '</p>';
                        if (!String.isEmpty(cappt.Appointment_Type__c)) {
                            chosenFormatted += '<p class="appointmentDesc">' + cappt.Appointment_Type__c + '</p>';
                        } else if (!String.isBlank(cappt.Description__c)) {
                            chosenFormatted += '<p class="appointmentDesc">' + cappt.Description__c + '</p>';
                        }
                        if (cappt.Chosen_State__c != 'Added and Required' && cappt.Chosen_State__c != 'Added but not shown') {
                            chosenFormatted += '<a href="javascript:;" class="appointmentRemove slds-button slds-button_neutral" title="Remove Appointment">Remove</a>';
                        }

                        chosenFormatted += '</div>';

                    }
                }
            }

            requiredAppt = false;
            for (Summit_Events_Appointment_Type__c apt : appts.values()) {
                Integer apptLimit = 1;
                if (!String.isBlank(apt.Appointment_Limits__c)) {
                    apptLimit = Integer.valueOf(apt.Appointment_Limits__c);
                }
                if (apptCount.containsKey(apt.Id)) {
                    apptLimit = apptLimit - (Integer.valueOf(apptCount.get(apt.Id)));
                }

                appointments += '<section  id="' + apt.Id + '"';
                appointments += ' name="' + apt.Id + '"';
                appointments += ' data-apptid="' + apt.Id + '"';
                appointments += ' data-apptcat="' + apt.Appointment_Category__c + '"';
                appointments += ' data-appttype="' + apt.Appointment_Type__c + '"';
                appointments += ' data-appttitle="' + apt.Title__c + '"';
                appointments += ' data-appchosenstate="' + apt.Chosen_State__c + '"';
                appointments += ' data-appsort="' + apt.Sort_Order__c + '"';
                appointments += ' data-appinput="' + apt.Registrant_Input__c + '"';
                appointments += ' data-limit=' + String.valueOf(apptLimit) + ' ';

                if (apptLimit <= 0) {
                    appointments += ' style="display:none;" ';
                } else {
                    appointments += ' data-limit="1" ';
                }
                appointments += ' class="slds-accordion__section appointment slds-box slds-box_small slds-m-vertical_x-small';
                if (apt.Required_Appointment__c) {
                    appointments += ' appointmentRequired';
                }
                appointments += '">';

                //Heading
                appointments += '<div class="slds-accordion__summary">';
                appointments += '<h3 class="slds-accordion__summary-heading">';
                appointments += '<button aria-controls="accordion-details-01" aria-expanded="true" class="slds-button slds-button_reset slds-accordion__summary-action">';
                appointments += '<svg class="slds-accordion__summary-action-icon slds-button__icon slds-button__icon_left" aria-hidden="true">';
                appointments += '<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#switch"></use>';
                appointments += '</svg>';
                appointments += '<span class="slds-truncate appointmentTitle" title="' + apt.Title__c + '">';
                appointments += apt.Title__c;
                if (apt.Required_Appointment__c) {
                    requiredAppt = true;
                    appointments += ' *';
                }
                appointments += '</span>';
                appointments += '</button>';
                appointments += '</h3>';
                appointments += '</div>';


                appointments += '<div class="slds-accordion__content" id="accordion-details-01">';

                if (String.isNotBlank(apt.Registrant_Input__c) && apt.Registrant_Input__c.toLowerCase().contains('required')) {
                    appointments += '<div class="slds-form-element slds-is-required">';
                } else {
                    appointments += '<div class="slds-form-element">';
                }

                if (!String.isBlank(apt.Description__c)) {
                    appointments += '<label class="slds-form-element__label slds-text-body_regular slds-p-vertical_x-small" for="input' + apt.Id + '">';
                    appointments += apt.Description__c;
                    appointments += '</label>';
                }

                appointments += '<div class="slds-form-element__control slds-p-vertical_x-small">';

                if (apt.Appointment_Category__c != null) {
                    //getDependentSelectOptions(String parentObjName, String parentFieldName, String dependentFieldName, String parentValue)
                    Map<String, String> dependencies = seaShared.getDependentSelectOptions('Summit_Events_Appointment_Type__c', 'Appointment_Category__c', 'Appointment_Type__c', apt.Appointment_Category__c);
                    if (dependencies.size() > 1) {
                        appointments += '<div class="slds-select_container">';
                        appointments += '<select class="appointmentType required slds-select" id="input' + apt.Id + '" name="input' + apt.Id + '">';
                        appointments += '<option value="">Select...</option>';
                        for (String thing : dependencies.keySet()) {
                            appointments += '<option value="' + thing + '">' + dependencies.get(thing) + '</option>';
                        }
                        appointments += '</select>';
                        appointments += '</div>';
                    }
                }

                if (apt.Registrant_Input__c == 'Text box' || apt.Registrant_Input__c == 'Required text box') {
                    appointments += '<textarea';
                    if (apt.Registrant_Input__c == 'Required text box') {
                        appointments += ' required="required" class="appointmentCustomInput required slds-textarea" ';
                    } else {
                        appointments += ' class="appointmentCustomInput slds-textarea" ';
                    }
                    appointments += '>';
                    appointments += '</textarea>';
                }

                if (apt.Registrant_Input__c == 'Custom pick list' || apt.Registrant_Input__c == 'Required custom pick list') {
                    if (!String.isBlank(apt.Custom_Picklist__c)) {
                        appointments += '<div class="slds-select_container">';
                        appointments += '<select id="input' + apt.Id + '" name="input' + apt.Id + '"';
                        if (apt.Registrant_Input__c == 'Required custom pick list') {
                            appointments += ' required="required" class="appointmentType required slds-select required" ';
                        } else {
                            appointments += ' class="appointmentType slds-select" ';
                        }
                        appointments += '>';
                        appointments += '<option value="">Select...</option>';
                        String custPickListText = apt.Custom_Picklist__c;
                        custPickListText = custPickListText.trim();
                        custPickListText = custPickListText.replace('\n\n', '\n');
                        String[] custPckListList = custPickListText.split('\n');

                        for (String cp : custPckListList) {
                            cp = cp.replaceAll('[^a-zA-Z0-9@<>?&;:\\[\\]!-. ]', '');
                            appointments += '<option value="' + cp + '">' + cp + '</option>';
                        }
                        appointments += '</select>';
                        appointments += '</div>';
                    } else {
                        appointments += 'MISSING PICKLIST VALUES';
                    }

                    appointments += '</div>';

                }
                appointments += '<button class="appointmentAdd slds-button slds-button_brand slds-align_absolute-center slds-not-selected slds-p-horizontal_xx-large slds-p-vertical_xx-small" aria-live="assertive">';
                appointments += '<svg class="slds-button__icon slds-button__icon_small slds-button__icon_left" aria-hidden="true">';
                appointments += '<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#add"></use>';
                appointments += '</svg>Add';
                appointments += '</button>';

                appointments += '</div>';
                appointments += '</section>';
            }
        }
    }


    public PageReference checkEventDetails() {
        return seaShared.checkForEvent();
    }

    public PageReference saveOptions() {
        //remove old client created appointments
        crudToDo doCRUD = new crudToDo();
        PageReference submitPage = null;
        if (eventPage.Display_Optional_Donation__c) {
            submitPage = Page.SummitEventsDonation;
        } else {
            submitPage = Page.SummitEventsSubmit;
        }

        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
            submitPage.setRedirect(true);
            submitPage.getParameters().put('adminopen', ApexPages.currentPage().getParameters().get('adminopen'));
        }

        Summit_Events_Appointments__c[] deleteAppt = [
                SELECT Id, Event_Registration__c, Client_Created_Appointment__c, Chosen_State__c, Do_Not_Show_Time__c
                FROM Summit_Events_Appointments__c
                WHERE Event_Registration__c = :eventInformation.registrationId
                AND Client_Created_Appointment__c = TRUE
        ];
        doCRUD.deleteAppointments(deleteAppt);

        List<incomingAppt> deserializedInvoices = (List<incomingAppt>) JSON.deserialize(incomingAppointmentJSON, List<incomingAppt>.class);

        List<Summit_Events_Appointments__c> apptToAdd = new List<Summit_Events_Appointments__c>();
        for (incomingAppt appt : deserializedInvoices) {
            Summit_Events_Appointments__c addAppt = new Summit_Events_Appointments__c();
            addAppt.Event_Registration__c = eventInformation.registrationId;
            addAppt.Appointment_Status__c = 'Registered';
            addAppt.Client_Created_Appointment__c = true;
            addAppt.Event_Appointment_Type__c = appt.apptId;
            Summit_Events_Appointment_Type__c apptDefinition = appts.get(appt.apptId);
            addAppt.Chosen_State__c = appt.appChosenState;
            if (!String.isBlank(appt.apptCatagory) && appt.apptCatagory != 'null' && appt.apptCatagory != 'undefined') {
                addAppt.Appointment_Category__c = appt.apptCatagory;
            }
            if (!String.isBlank(appt.apptType) && appt.apptType != 'null' && appt.apptType != 'undefined') {
                addAppt.Appointment_Type__c = appt.apptType;
            }
            addAppt.Appointment_Title__c = appt.apptTitle;
            if (appt.appSort == null) {
                addAppt.Sort_Order__c = 99;
            } else {
                addAppt.Sort_Order__c = Integer.valueOf(appt.appSort);
            }

            //Auto add fields from appointment type as defined auto add
            //TODO: slim down on ui interface storing values and used appt Type map ID to get them
            if (!String.isBlank(apptDefinition.Auto_add_building__c)) {
                addAppt.Building__c = apptDefinition.Auto_add_building__c;
            }
            if (apptDefinition.Auto_Confirm_Appointment__c) {
                addAppt.Appointment_Status__c = 'Confirmed';
            }
            if (apptDefinition.Do_Not_Show_Time__c != null) {
                addAppt.Do_Not_Show_Time__c = apptDefinition.Do_Not_Show_Time__c;
            }
            if (apptDefinition.Auto_Add_Time__c != null) {
                addAppt.Appointment_Time__c = apptDefinition.Auto_Add_Time__c;
            }
            addAppt.Description__c = appt.appDesc;
            addAppt.Registrant_Input__c = appt.appInput;

            apptToAdd.add(addAppt);
        }

        if (apptToAdd.size() > 0) {
            doCRUD.updateAppointments(apptToAdd);
        }
        return submitPage;
    }

    public PageReference previousPage() {

        PageReference registerPage = Page.SummitEventsRegister;
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
            registerPage.setRedirect(true);
            registerPage.getParameters().put('adminopen', ApexPages.currentPage().getParameters().get('adminopen'));
        }
        return registerPage;
    }

    private without sharing class crudToDo {

        public void updateAppointments(List<Summit_Events_Appointments__c> appointments) {
            try {
                upsert appointments;
            } catch (Exception ex) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                ApexPages.addMessage(myMsg);
            }
        }

        public void deleteAppointments(List<Summit_Events_Appointments__c> appointments) {
            try {
               // if (Schema.sObjectType.Summit_Events_Appointments__c.isDeletable()) {
                    delete appointments;
              //  }
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }
        }

    }
}