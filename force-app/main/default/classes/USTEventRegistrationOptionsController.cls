/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class USTEventRegistrationOptionsController {
    public USTEventShared USTShared = new USTEventShared();
    public String test { get; set; }
    public USTEventShared.USTEventInfo evtInfo { get; set; }
    public Map<Id, UST_Event_Appointment_Type__c> appts { get; set; }
    public List<UST_Event_Appointments__c> chosenAppts { get; set; }
    public UST_Event_Instance__c evtInstance { get; set; }
    public String apptFormatted { get; set; }
    public String chosenFormatted { get; set; }
    public String incomingApptJSon { get; set; }
    public UST_Event__C eventPage { get; set; }
    public String templateSelected { get; set; }
    public Boolean noOptionalAppointments { get; set; }
    public Boolean requiredAppt {get;set;}
    public String eventStartDateTimeCrumb {get;set;}

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

    public USTEventRegistrationOptionsController() {
        test = '';
        templateSelected = USTShared.defaultTemplate;
        //Get cookie or URL string variable
        evtInfo = USTShared.getUSTEventInfo();
        apptFormatted = '';
        chosenFormatted = '';
        noOptionalAppointments = true;

        Map<String, Integer> apptCount = new Map<String, Integer>();

        if (!String.isBlank(evtinfo.evtId)) {
            eventPage = [
                    SELECT Event_Name__c, Event_description__c, Event_Appointment_Title__c, Event_Appointment_Description__c, Event_Footer__c,
                            Template__c, Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Options_Registration__c
                    FROM UST_Event__c
                    WHERE Id = :evtinfo.evtId][0];
            templateSelected = eventPage.Template__c;

            if (!String.isBlank(evtinfo.evtRegId)) {
                evtInstance = [SELECT Instance_Title__c, Start_Date_Time__c, End_Date_Time__c FROM UST_Event_Instance__c WHERE Id = :evtinfo.instanceID LIMIT 1];

                if(evtInstance.Start_Date_Time__c != null && evtInstance.End_Date_Time__c != null ) {
                    eventStartDateTimeCrumb = evtInstance.Start_Date_Time__c.format('MMMM d, YYYY, h:mm a') + ' - ' + evtInstance.End_Date_Time__c.format('h:mm a');
                }

                if (evtInstance != null) {
                    //Datetime rightNow = USTShared.adjustForCenteralTime(Datetime.now());
                    String dayOfWeek = evtInstance.Start_Date_Time__c.format('EEEE');
                    // = dayOfWeek;
                    //Build available appointments
                    appts = new Map<ID, UST_Event_Appointment_Type__c>( [
                            SELECT Id, Name, Title__c, Description__c, Appointment_Type__c, Appointment_Category__c, Appointment_Limits__c, Chosen_State__c,
                                    Registrant_Input__c, Custom_Picklist__c, Sort_Order__c, Auto_Confirm_Appointment__c, Auto_add_building__c, Auto_Add_Time__c, Do_Not_Show_Time__c,
                                    Date_Available_Start__c, Date_Available_End__c, Day_of_Week_Availability__c, Required_Appointment__c, Appointment_Type_Status__c
                            FROM UST_Event_Appointment_Type__c
                            WHERE UST_Event__c = :evtinfo.evtId
                            AND (Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = null)
                            AND (Date_Available_Start__c <= :evtInstance.Start_Date_Time__c.date() OR Date_Available_Start__c = NULL)
                            AND (Date_Available_End__c >= :evtInstance.End_Date_Time__c.date() OR Date_Available_End__c = NULL)
                            AND (Day_of_Week_Availability__c INCLUDES (:dayOfWeek) OR Day_of_Week_Availability__c = NULL)
                            AND (Appointment_Type_Status__c = 'Active' OR Appointment_Type_Status__c = NULL)
                            ORDER BY Sort_Order__c ASC NULLS LAST
                    ]);

                    //Check if the user gets to select any appointments or they are all auto added
                    for (UST_Event_Appointment_Type__c chosenCheck : appts.values()) {
                        If (chosenCheck.Chosen_State__c != 'Added and Required' && chosenCheck.Chosen_State__c != 'Added but not shown' ) {
                            noOptionalAppointments = false;
                            break;
                        }
                    }

                    //Gather up the appointments that have already been chosen.
                    chosenAppts = [
                            SELECT Id, Appointment_Category__c, Event_Appointment_Type__c, Appointment_Type__c, Appointment_Title__c, Chosen_State__c, Description__c, Sort_Order__c,
                                    Registrant_Input__c, Do_Not_Show_Time__c
                            FROM UST_Event_Appointments__c
                            WHERE Event_Registration__c = :evtinfo.evtRegId
                            AND Client_Created_Appointment__c = true
                    ];


                    for (UST_Event_appointments__c cappt : chosenAppts) {

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
                        chosenFormatted += ' data-appttitle="' + cappt.Appointment_title__c + '"';
                        chosenFormatted += ' data-appchosenstate="' + cappt.Chosen_State__c + '"';
                        chosenFormatted += ' data-appsort="' + cappt.Sort_Order__c + '"';
                        chosenFormatted += ' data-appreginput="' + cappt.Registrant_Input__c + '"';
                        chosenFormatted += ' class="appointmentChoosen"';
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
                        IF (cappt.Chosen_State__c != 'Added and Required' && cappt.Chosen_State__c != 'Added but not shown') {
                            chosenFormatted += '<a href="javascript:;" onclick="removeAppt($(this))" class="appointmentRemove" title="Remove Appointment"><i class="fa fa-times-circle" aria-hidden="true"></i><span> Remove</span></span></a>';
                        }

                        chosenFormatted += '</div>';

                    }
                }
            }

            requiredAppt = false;
            for (UST_Event_Appointment_Type__c apt : appts.values()) {
                Integer apptLimit = 1;
                if (!String.isBlank(apt.Appointment_Limits__c)) {
                    apptLimit = Integer.valueOf(apt.Appointment_Limits__c);
                }
                if (apptCount.containsKey(apt.Id)) {
                    apptLimit = apptLimit - (Integer.valueOf(apptCount.get(apt.Id)));
                }
                apptFormatted += '<div id="' + apt.Id + '"';
                apptFormatted += ' data-apptid="' + apt.Id + '"';
                apptFormatted += ' data-apptcat="' + apt.Appointment_Category__c + '"';
                apptFormatted += ' data-appttype="' + apt.Appointment_Type__c + '"';
                apptFormatted += ' data-appttitle="' + apt.Title__c + '"';
                apptFormatted += ' data-appchosenstate="' + apt.Chosen_State__c + '"';
                apptFormatted += ' data-appsort="' + apt.Sort_Order__c + '"';
                apptFormatted += ' data-appinput="' + apt.Registrant_Input__c + '"';
                apptFormatted += ' data-limit=' + String.valueOf(apptLimit) + ' ';
                if (apptLimit <= 0) {
                    apptFormatted += ' style="display:none;" ';
                } else {
                    apptFormatted += ' data-limit="1" ';
                }
                apptFormatted += ' class="appointment';
                if (apt.Required_Appointment__c) {
                    apptFormatted += ' appointmentRequired';
                }
                apptFormatted += '">';
                apptFormatted += '<p class="appointmentTitle"><a href="javascript:;" class="optionToggler"><span>' + apt.Title__c;
                if (apt.Required_Appointment__c) {
                    requiredAppt = true;
                    apptFormatted += ' *';
                }
                apptFormatted += '</span><i class="fa fa-chevron-down" aria-hidden="true"></i></a></p>';
                apptFormatted += '<div class="apptmentDetail">';
                if (!String.isBlank(apt.Description__c)) {
                    apptFormatted += '<p class="appointmentDesc">' + apt.Description__c + '</p>';
                }
                if (apt.Appointment_Category__c != null) {
                    //getDependentSelectOptions(String parentObjName, String parentFieldName, String dependentFieldName, String parentValue)
                    Map<String, String> dependencies = USTShared.getDependentSelectOptions('UST_Event_Appointment_Type__c', 'Appointment_Category__c', 'Appointment_Type__c', apt.Appointment_Category__c);
                    if (dependencies.size() > 1) {
                        apptFormatted += '<select class="appointmentType required">';
                        apptFormatted += '<option value="">Select...</option>';
                        for (String thing : dependencies.keySet()) {
                            apptFormatted += '<option value="' + thing + '">' + dependencies.get(thing) + '</option>';
                        }

                        apptFormatted += '</select>';
                    }
                }
                if (apt.Registrant_Input__c == 'Text box' || apt.Registrant_Input__c == 'Required text box') {
                    apptFormatted += '<textarea rows="4" cols="50"';
                    if (apt.Registrant_Input__c == 'Required text box') {
                        apptFormatted += ' required="required" class="appointmentCustomInput required" ';
                    } else {
                        apptFormatted += ' class="appointmentCustomInput" ';
                    }
                    apptFormatted += '>';
                    apptFormatted += '</textarea>';
                }
                if (apt.Registrant_Input__c == 'Custom pick list' || apt.Registrant_Input__c == 'Required custom pick list') {
                    if(!String.isBlank(apt.Custom_Picklist__c)) {
                        apptFormatted += '<select';
                        if (apt.Registrant_Input__c == 'Required custom pick list') {
                            apptFormatted += ' required="required" class="appointmentCustomInput required" ';
                        } else {
                            apptFormatted += ' class="appointmentCustomInput" ';
                        }
                        apptFormatted += '>';
                        apptFormatted += '<option value="">Select...</option>';
                        String custPickListText = apt.Custom_Picklist__c;
                        custPickListText = custPickListText.Trim();
                        custPickListText = custPickListText.replace('\n\n', '\n');
                        String[] custPckListList = custPickListText.split('\n');

                        for (String cp : custPckListList) {
                            cp = cp.replaceAll('[^a-zA-Z0-9@<>?&;:\\[\\]!-. ]', '');
                            apptFormatted += '<option value="' + cp + '">' + cp + '</option>';
                        }
                        apptFormatted += '</select>';
                    } else {
                        apptFormatted += 'MISSING PICKLIST VALUES';
                    }

                }

                apptFormatted += '<a href="javascript:;" class="appointmentAdd"><span><i class="fa fa-plus" aria-hidden="true"></i> Add appointment</span></a>';
                apptFormatted += '</div>';
                apptFormatted += '</div>';
            }
        }
    }


    public PageReference checkEventDetails() {
        PageReference eventActivePg = USTShared.checkForEvent();
        if (eventActivePg == null) {
            //Get event into
            evtInfo = USTShared.getUSTEventInfo();
            Boolean addedAppts = false;
            Id RegId = evtinfo.evtRegId;
            evtInstance = [SELECT Instance_Title__c, Start_Date_Time__c, End_Date_Time__c FROM UST_Event_Instance__c WHERE Id = :evtinfo.instanceID LIMIT 1];
            List<UST_Event_Appointment_Type__c> autoAddAppt = [
                    SELECT Id, Name, Title__c, Description__c, Appointment_Type__c, Appointment_Category__c, Registrant_Input__c, Custom_Picklist__c, Appointment_Limits__c,
                            Chosen_State__c, Sort_Order__c, Auto_Confirm_Appointment__c, Auto_add_building__c, Auto_Add_Time__c, Do_Not_Show_Time__c
                    FROM UST_Event_Appointment_Type__c
                    WHERE UST_Event__c = :evtinfo.evtId
                    AND (Chosen_State__c = 'Added' OR Chosen_State__c = 'Added and Required'  OR Chosen_State__c = 'Added but not shown')
                    AND Id NOT IN (SELECT Event_Appointment_Type__c FROM UST_Event_Appointments__c WHERE Event_Registration__c = :RegId)
                    AND (Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = null)
                    ORDER BY Sort_Order__c ASC NULLS LAST
            ];

            for (UST_Event_Appointment_Type__c appt : autoAddAppt) {
                UST_event_Appointments__c addAppt = new UST_Event_Appointments__c();
                addAppt.Event_Appointment_Type__c = appt.Id;
                addAppt.Event_Registration__c = RegId;
                addAppt.Appointment_Title__c = appt.Title__c;
                addAppt.Appointment_Status__c = 'Registered';
                addAppt.Appointment_Category__c = appt.Appointment_Category__c;
                addAppt.Appointment_Type__c = appt.Appointment_Type__c;
                addAppt.Appointment_Detail__c = appt.Description__c;
                addAppt.Client_Created_Appointment__c = true;
                addAppt.Chosen_State__c = appt.Chosen_State__c;
                addAppt.Sort_Order__c = appt.Sort_Order__c;
                addAppt.Description__c = appt.Description__c;
                addAppt.Registrant_Input__c = appt.Registrant_Input__c;
                addAppt.Do_Not_Show_Time__c = appt.Do_Not_Show_Time__c;
                upsert addAppt;
                addedAppts = true;
            }

            if (addedAppts) {
                return new PageReference(ApexPages.currentPage().getUrl());
            }
        }
        return eventActivePg;
    }

    public PageReference saveOptions() {
        //remove old client created appointments
        UST_Event_Appointments__c[] deleteAppt = [
                SELECT Id, Event_Registration__c, Client_Created_Appointment__c, Chosen_State__c, Do_Not_Show_Time__c
                FROM UST_Event_Appointments__c
                WHERE Event_Registration__c = :evtinfo.evtRegId
                AND Client_Created_Appointment__c = true
        ];
        try {
            delete deleteAppt;
        } catch (DmlException e) {
            System.Debug('HERE IS THE DROID YOU ARE LOOKING FOR ======>' + e.getMessage());
        }
        List<incomingAppt> deserializedInvoices = (List<incomingAppt>) JSON.deserialize(incomingApptJSon, List<incomingAppt>.class);
        PageReference submitPage = Page.USTEventSubmit;
        for (incomingAppt appt : deserializedInvoices) {
            UST_event_Appointments__c addAppt = new UST_Event_Appointments__c();
            addAppt.Event_Registration__c = evtInfo.evtRegId;
            addAppt.Appointment_Status__c = 'Registered';
            addAppt.Client_Created_Appointment__c = true;
            addAppt.Event_Appointment_Type__c = appt.apptId;
            UST_Event_Appointment_Type__c apptDefinition = appts.get(appt.apptId);
            addAppt.Chosen_State__c = appt.appChosenState;
            if (!String.isBlank(appt.apptCatagory) && appt.apptCatagory != 'null' && appt.apptCatagory != 'undefined') {
                addAppt.Appointment_Category__c = appt.apptCatagory;
            }
            if (!String.isBlank(appt.apptType) && appt.apptType != 'null' && appt.apptType != 'undefined') {
                addAppt.Appointment_Type__c = appt.apptType;
            }
            addAppt.Appointment_title__c = appt.apptTitle;
            if(appt.appSort == null) {
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
            if(apptDefinition.Auto_Add_Time__c != null) {
                addAppt.Appointment_Time__c = apptDefinition.Auto_Add_Time__c;
            }
            addAppt.Description__c = appt.appDesc;
            addAppt.Registrant_Input__c = appt.appInput;

            upsert addAppt;
        }
        return submitPage;
    }

    public PageReference previousPage() {
//if (!String.isBlank(eventRegId)) {
        PageReference registerPage = Page.USTEventRegister;

        return registerPage;
    }
}