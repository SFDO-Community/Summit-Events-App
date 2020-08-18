/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class SummitEventsRegisterController {
    public String test { get; set; }
    public Summit_Events_Instance__c evtInstance { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public String ContactId { get; set; }
    public String instanceName { get; set; }
    public String EvtUserType { get; set; }
    public List<SelectOption> guestAmt { get; set; }
    public Summit_Events_Registration__c newEvtReg { get; set; }
    public Summit_Events_Registration__c oldEvtReg { get; set; }
    private SummitEventsShared SEShared = new SummitEventsShared();
    public SummitEventsShared.SummitEventsInfo evtInfo { get; set; }
    public String templateSelected { get; set; }
    public boolean contactSet { get; set; }
    public boolean eventIsClosed { get; set; }
    public boolean additionalQuestions { get; set; }
    public List<String> questionNum { get; set; }
    public List<SelectOption> addPick1 { get; set; }
    public List<SelectOption> addPick2 { get; set; }
    public List<SelectOption> addPick3 { get; set; }
    public List<SelectOption> addPick4 { get; set; }
    public List<SelectOption> addPick5 { get; set; }
    public List<String> selectedPrograms { get; set; }
    public String selectedProgramsOne { get; set; }
    public boolean showAddress { get; set; }
    public boolean showPhone { get; set; }
    public String applicantType { get; set; }
    public Boolean evtHasAppointments { get; set; }
    public String birthDateString { get; set; }
    public String dataLayerLocationType { get; set; }
    public String phoneType { get; set; }
    public String navBreadCrumb { get; set; }
    public boolean showLocation { get; set; }
    public String startTimeString { get; set; }
    public String endTimeString { get; set; }
    public Boolean adminOpen { get; set; }


    public SummitEventsRegisterController() {
        selectedPrograms = new List<String>();
        selectedProgramsOne = '';
        //array for looping through additional information questions
        questionNum = new List<String>{
                '1', '2', '3', '4', '5'
        };

        newEvtReg = new Summit_Events_Registration__c();
        newEvtReg.Add_Info_Answer_1__c = '';
        templateSelected = SEShared.defaultTemplate;
        test = '';
        contactSet = false;
        eventIsClosed = false;
        additionalQuestions = false;
        showAddress = false;
        showPhone = false;
        EvtUserType = UserInfo.getUserType();
        //Get cookie or URL string variable
        evtInfo = SEShared.getSummitEventsInfo();

        //Set applicant type if audience is passed
        if (!String.isBlank(evtInfo.audience)) {
            if (evtInfo.audience == 'Transfer' || evtInfo.audience == 'Transfer International') {
                applicantType = 'Transfer';
            } else if (evtInfo.audience == 'High School Senior' || evtInfo.audience == 'High School Junior or Younger' || evtInfo.audience == 'First-Year International' || evtInfo.audience == 'Dougherty Family College (2-Year)') {
                applicantType = 'First-Year';
            }
        }

        //Get Instance information
        if (String.isNotBlank(evtInfo.instanceID)) {
            evtInstance = [
                    SELECT Id, Name, Event__r.Name, Event__r.Event_Name__c, Event__r.Id, Instance_Title__c, Active_Status__c, Capacity__c,
                            Event__r.Event_description__c, Event__r.Audience__c, Instance_Start_Date__c, Instance_Start_Time__c, Instance_End_Date__c, Instance_End_Time__c, Instance_Time_Zone__c, Current_Available_Capacity__c,
                            Location_Type_Override__c, Location_Address_Override__c, Event__r.Close_Event_Days_Before__c, Location_Map_Link_Override__c, Location_Title_Override__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :evtInfo.instanceID
                    LIMIT 1
            ][0];

            //define Event ID from instanceInfo data
            evtInfo.evtId = evtInstance.Event__r.Id;
            instanceName = evtInstance.Name;
            startTimeString = SEShared.formatTime(evtInstance.Instance_Start_Time__c, false);
            endTimeString = SEShared.formatTime(evtInstance.Instance_End_Time__c, false);
        }

        //Get Event Info off of instance master detail id
        if (!String.isBlank(evtInfo.evtId)) {
            eventPage = [
                    SELECT Name, Id, Event_Name__c, Event_description__c, Event_Footer__c, Event_Full_Text__c, Audience__c,Include_Time_frame_List__c,
                            Max_Other_Attendees__c, Allow_Other_Attendees__c, College_High_School_Ask__c, Ask_Gender__c, Template__c,
                            Event_Home_Link_Title__c, Event_Home_Link_URL__c, Ask_If_Parent__c, Ask_Registrant_Program_Of_Interest__c,
                            Add_Info_Question_Pick_List_1__c, Add_Info_Question_Text_1__c, Add_Info_Question_Type_1__c,
                            Add_Info_Question_Pick_List_2__c, Add_Info_Question_Text_2__c, Add_Info_Question_Type_2__c,
                            Add_Info_Question_Pick_List_3__c, Add_Info_Question_Text_3__c, Add_Info_Question_Type_3__c,
                            Add_Info_Question_Pick_List_4__c, Add_Info_Question_Text_4__c, Add_Info_Question_Type_4__c,
                            Add_Info_Question_Pick_List_5__c, Add_Info_Question_Text_5__c, Add_Info_Question_Type_5__c,
                            Academic_Program_List__c, Ask_Mailing_Address__c, Ask_Phone__c, Event_Sponsor__c, Ask_Relationship_To_Institution__c,
                            Ask_Last_Name_As_Student__c, Ask_Preferred_Class_Year__c, Ask_Preferred_First_Name__c,
                            Ask_Applicant_Type__c, Location_Type__c, Location_Title__c, Location_Address__c, Location_Map_Link__c,
                            Tracking_Event_Registration__c, Ask_Date_Of_Birth__c, Event_Type__c, Contact_Creation__c, Contact_Matching_Rules__c,
                            Ask_Third_Party_Registrant__c, Registration_Email_Restriction__c, Ask_Pronoun__c, Keep_Registration_Open_During_Event__c,
                            Close_Event_Days_Before__c
                    FROM Summit_Events__c
                    WHERE Id = :evtInfo.evtId
                    LIMIT 1
            ][0];

            if (!String.isBlank(eventPage.Ask_Applicant_Type__c)) {
                //Important to start all of this with exact "Do not ask but assign " to assign correctly
                if (eventPage.Ask_Applicant_Type__c.startsWith('Do not ask but assign ')) {
                    applicantType = eventPage.Ask_Applicant_Type__c.replace('Do not ask but assign ', '');
                }
            }

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                eventIsClosed = adminOpen;
            } else {
                eventIsClosed = SEShared.isEventClosed(eventPage, evtInstance);
            }

            if (
                    !String.isBlank(eventPage.Add_Info_Question_Type_1__c) ||
                            !String.isBlank(eventPage.Add_Info_Question_Type_1__c) ||
                            !String.isBlank(eventPage.Add_Info_Question_Type_1__c) ||
                            !String.isBlank(eventPage.Add_Info_Question_Type_1__c) ||
                            !String.isBlank(eventPage.Add_Info_Question_Type_1__c) ||
                            eventPage.Include_Time_frame_List__c ||
                            eventPage.Allow_Other_Attendees__c ||
                            (eventPage.Ask_Gender__c != 'Do not ask' && eventPage.Ask_Gender__c != null) ||
                            (eventPage.Ask_Registrant_Program_Of_Interest__c != 'Do not ask' && eventPage.Ask_Registrant_Program_Of_Interest__c != null)
                    ) {
                additionalQuestions = true;
            }


            if (String.isNotBlank(eventPage.Location_Title__c)
                    || String.isNotBlank(evtInstance.Location_Title_Override__c)
                    || String.isNotBlank(evtInstance.Location_Address_Override__c)
                    || String.isNotBlank(eventPage.Location_Address__c)
                    || String.isNotBlank(evtInstance.Location_Map_Link_Override__c)
                    || String.isNotBlank(eventPage.Location_Map_Link__c)
                    || String.isNotBlank(evtInstance.Location_Map_Link_Override__c)
                    ) {
                showLocation = true;
            }
            String locationTitle = '';
            if (!String.isBlank(evtInstance.Location_Title_Override__c)) {
                locationTitle = evtInstance.Location_Title_Override__c;
            } else if (!String.isBlank(eventPage.Location_Title__c)) {
                locationTitle = eventPage.Location_Title__c;
            }

            String locationMapLink = '';
            if (!String.isBlank(evtInstance.Location_Map_Link_Override__c)) {
                locationMapLink = evtInstance.Location_Map_Link_Override__c;
            } else if (!String.isBlank(eventPage.Location_Map_Link__c)) {
                locationMapLink = eventPage.Location_Map_Link__c;
            }

            String locationAddress = '';
            if (!String.isBlank(evtInstance.Location_Address_Override__c)) {
                locationAddress = evtInstance.Location_Address_Override__c;
            } else if (!String.isBlank(eventPage.Location_Title__c)) {
                locationAddress = eventPage.Location_Title__c;
            }
            dataLayerLocationType = locationAddress;

            navBreadCrumb = SEShared.navBreadcrumbBuilder(evtInstance, false);

            //Check if the Event has appointments and therefore we have to redirect to the appointment page.
            evtHasAppointments = false;
            List<Summit_Events_Appointment_Type__c> apptTypes = [
                    SELECT Id
                    From Summit_Events_Appointment_Type__c
                    WHERE Summit_Events__c = :evtInfo.evtId
                    AND (Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = null)
            ];
            if (apptTypes.size() > 0) {
                evtHasAppointments = true;
            }

            //Grab the template if defined
            if (!String.isBlank(eventPage.Template__c)) {
                templateSelected = eventPage.Template__c;
            }

            if (eventPage.Allow_Other_Attendees__c) {
                guestAmt = new List<SelectOption>();
                if (Integer.valueOf(eventPage.Max_Other_Attendees__c) > 0) {
                    for (Integer ma = 0; ma <= Integer.valueOf(eventPage.Max_Other_Attendees__c); ma++) {
                        guestAmt.add(new SelectOption(String.valueOf(ma), String.valueOf(ma)));
                    }
                }
            }

            //Get Appoitment Types for event
            apptTypes = [SELECT Id, Title__c, Appointment_Category__c, Appointment_Type__c, Description__c FROM Summit_Events_Appointment_Type__c WHERE Summit_Events__c = :evtInfo.evtId];

            addPick1 = createPicklists(eventPage.Add_Info_Question_Pick_List_1__c);
            addPick2 = createPicklists(eventPage.Add_Info_Question_Pick_List_2__c);
            addPick3 = createPicklists(eventPage.Add_Info_Question_Pick_List_3__c);
            addPick4 = createPicklists(eventPage.Add_Info_Question_Pick_List_4__c);
            addPick5 = createPicklists(eventPage.Add_Info_Question_Pick_List_5__c);
        }

        //If the user is logged in use that data
        if ((!String.isBlank(EvtUserType) && EvtUserType != 'Guest' && EvtUserType != 'Standard') || (!String.isBlank(evtInfo.evtRegId) && evtInfo.evtRegId != 'COMING')) {
            //Fill in contact information
            Contact userContact = new Contact();
            if (String.isBlank(evtInfo.evtRegId) || evtInfo.evtRegId == 'COMING') {


                userContact = [
                        Select Id, Name, FirstName, LastName, Email, HomePhone, MobilePhone, Birthdate
                        FROM Contact
                        Where Id In (
                                Select ContactId
                                From User
                                Where Id = :UserInfo.getUserId()
                        )
                ];

                newEvtReg.Registrant_First_Name__c = userContact.FirstName;
                newEvtReg.Registrant_Last_Name__c = userContact.LastName;
                newEvtReg.Registrant_Email__c = userContact.Email;
                newEvtReg.Registrant_Phone__c = userContact.HomePhone;
                newEvtReg.Registrant_Mobile_Phone__c = userContact.MobilePhone;
                newEvtReg.Registrant_Date_of_Birth__c = userContact.Birthdate;
                if (userContact.Birthdate != null) {
                    birthDateString = userContact.Birthdate.format();
                }
                //    newEvtReg.Registrant_Receive_Texts__c = true;
                if (String.isBlank(userContact.Id)) {
                    contactId = userContact.Id;
                }
                contactSet = true;
            } else {
                newEvtReg = [
                        SELECT Contact__c, Contact__r.Id, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c, Number_of_Guests__c,
                                Registrant_Gender__c, Registrant_Street_1__c, Registrant_Street_2__c, Registrant_State__c, Registrant_City__c, Preferred_Visit_Time__c,
                                Registrant_Zip__c, Registrant_Phone__c, Registrant_Mobile_Phone__c, Registrant_College__c, Registrant_College_Code__c, Registrant_College_Year__c,
                                Registrant_High_School__c, Registrant_High_School_Code__c, Registrant_Receive_Texts__c, Registrant_High_School_Grad_Year__c, Registrant_High_School_Not_Found__c,
                                Registrant_College_Not_Found__c, Registrant_Parent_First_Name__c, Registrant_Parent_Last_Name__c, Registrant_Parent_Email__c, Registrant_Parent_Phone__c,
                                Add_Info_Answer_1__c, Add_Info_Answer_2__c, Add_Info_Answer_3__c, Add_Info_Answer_4__c, Add_Info_Answer_5__c, Registrant_Program_Interest__c, Registrant_Preferred_First_Name__c,
                                Registrant_date_of_Birth__c, Last_Name_as_Student__c, Preferred_Class_Year__c, Relationship_To_Institution__c, Registrant_Other_Email__c, Registrant_Other_First_Name__c, Registrant_Other_Last_Name__c, Registrant_Other_Phone__c, Registrant_Other_Relationship__c,
                                Registrant_Country__c, Registrant_State_Province__c, Registrant_Postal_Code__c, Registrant_Third_Party_Status__c, Registrant_Pronouns__c
                        FROM Summit_Events_Registration__c
                        WHERE id = :evtInfo.evtRegId
                ][0];

                if (newEvtReg.Registrant_date_of_Birth__c != null) {
                    birthDateString = newEvtReg.Registrant_date_of_Birth__c.format();
                }

                //for comparison after the form is filled out we keep original queried event the see if key information is changed and matching should be redone.
                oldEvtReg = newEvtReg;
            }

            if (EvtUserType != 'Guest') {
                contactSet = true;
            }
        }

        if (String.isBlank(newEvtReg.Registrant_Country__c)) {
            newEvtReg.Registrant_Country__c = 'United States';

        }

    }

    public PageReference setParentInfo(String n) {
        return null;
    }

    public PageReference checkEventDetails() {
        return SEShared.checkForEvent();
    }

    public List<SelectOption> getSexDD() {
        return PickThePicklist('Summit_Events_Registration__c', 'Registrant_Gender__c', true);
    }

    public List<SelectOption> getStateDD() {
        return PickThePicklist('Summit_Events_Registration__c', 'Registrant_State_Global__c', true);
    }

    public List<SelectOption> getCountryDD() {
        return PickThePicklist('Summit_Events_Registration__c', 'Registrant_Country__c', true);
    }

    public List<SelectOption> getTimeFrame() {
        return PickThePicklist('Summit_Events_Registration__c', 'Preferred_Visit_Time__c', true);
    }

    public List<SelectOption> getThirdPartyStatus() {
        return PickThePicklist('Summit_Events_Registration__c', 'Registrant_Third_Party_Status__c', true);
    }

    public List<SelectOption> getApplicantTypeDD() {
        return PickThePicklist('Summit_Events_Registration__c', 'Registrant_Applicant_Type__c', true);
    }

    public List<SelectOption> getRelationshipDD() {
        return PickThePicklist('Summit_Events_Registration__c', 'Relationship_To_Institution__c', false);
    }

    public List<SelectOption> getPronounDD() {
        return PickThePicklist('Summit_Events_Registration__c', 'Registrant_Pronouns__c', true);
    }

    public List<SelectOption> getProgramsAvailable() {
        List<SelectOption> progSelOpt = new List<SelectOption>();
        return progSelOpt;

    }

    public List<SelectOption> createPicklists(String returnSepStringList) {
        List<SelectOption> cpl = new List<SelectOption>();
        if (!String.isBlank(returnSepStringList)) {
            cpl.add(new SelectOption('', 'Select...'));
            returnSepStringList = returnSepStringList.Trim();
            returnSepStringList = returnSepStringList.replace('\n\n', '\n');
            String[] splitList = returnSepStringList.split('\n');
            for (String p : splitList) {
                p = p.replaceAll('[^a-zA-Z0-9@<>?&;:\\[\\]!-. ]', '');
                cpl.add(new SelectOption(p, p));
            }
        }
        return cpl;
    }

    public List<SelectOption> PickThePicklist(string YourObjectName, string YourFieldName, Boolean includeSelect) {
        List<SelectOption> picklists = new List<SelectOption>();
        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace.toLowerCase() + '__';
        }

        List<Schema.PicklistEntry> PicklistValues = Schema.getGlobalDescribe().get(namespace + YourObjectName).getDescribe().fields.getMap().get(namespace + YourFieldName).getDescribe().getPicklistValues();

        if (includeSelect) {
            picklists.add(new SelectOption('', 'Select...'));
        }

        if (YourFieldName == 'Registrant_Third_Party_Status__c') {
            picklists.add(new SelectOption('Primary Registrant', 'Primary Registrant'));
        }
        for (Schema.PicklistEntry PicklistValue : PicklistValues) {
            if (YourFieldName == 'Registrant_Third_Party_Status__c') {
                if (eventPage != null) {
                    if (eventPage.Ask_Third_Party_Registrant__c.contains(PicklistValue.getValue())) {
                        picklists.add(new SelectOption(PicklistValue.getValue(), PicklistValue.getLabel()));
                    }
                }
            } else {
                picklists.add(new SelectOption(PicklistValue.getValue(), PicklistValue.getLabel()));
            }

        }
        return picklists;
    }

    public PageReference saveContactRegistration() {
        System.debug(LoggingLevel.Info, ' HEY WE ARE SAVING HERE!');
        boolean newContactCreated = false;
        PageReference optionPage;

        //Record selected programs of interest
        String recordSelPrg = '';
        Pattern TAG_REGEX = Pattern.compile('\\((\\w+|\\w+\\|\\w+)\\)');
        List<String> majorCodes = new List<String>();
        Boolean progSelectionMade = true;

        registrationCRUD rCRUD = new registrationCRUD();

        if (String.isNotBlank(eventPage.Registration_Email_Restriction__c) && eventPage.Registration_Email_Restriction__c != 'No Limit') {
            System.debug('GOT TO REGISTRANT EMAIL RESTRICTIONS');
            Summit_Events_Registration__c foundRegistration = rCRUD.checkForOtherRegistrations(eventPage.Registration_Email_Restriction__c, newEvtReg.Registrant_Email__c, evtInstance.Id, eventPage.Id);
            if (foundRegistration != null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'It appears you’ve already registered for this event. Please contact the Event Host for more information.');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }

        newEvtReg.Registrant_Program_Interest__c = '';

        if (String.isNotBlank(birthDateString)) {
            newEvtReg.Registrant_Date_of_Birth__c = Date.parse(birthDateString);
        }

        if (!String.isBlank(applicantType)) {
            newEvtReg.Registrant_Applicant_Type__c = applicantType;
        } else if (eventPage.Ask_Applicant_Type__c == 'Do not ask but assign First-Year') {
            newEvtReg.Registrant_Applicant_Type__c = 'First-Year';
        } else if (eventPage.Ask_Applicant_Type__c == 'Do not ask but assign Transfer') {
            newEvtReg.Registrant_Applicant_Type__c = 'Transfer';
        } else if (eventPage.Ask_Applicant_Type__c == 'Do not ask but assign Graduate') {
            newEvtReg.Registrant_Applicant_Type__c = 'Graduate';
        }

        //Check if last name, email, phone number or DOB changed
        Boolean dataHasChanged = false;
        if (oldEvtReg != null) {
            if (oldEvtReg.Registrant_Date_of_Birth__c != newEvtReg.Registrant_Date_of_Birth__c
                    || oldEvtReg.Registrant_Last_Name__c != newEvtReg.Registrant_Last_Name__c
                    || oldEvtReg.Registrant_Email__c != newEvtReg.Registrant_Email__c
                    || oldEvtReg.Registrant_First_Name__c != newEvtReg.Registrant_First_Name__c
                    ) {
                dataHasChanged = true;
            }
        }

        //Create registration if event Registration does not exist
        if (String.isBlank(evtInfo.evtRegId) || evtInfo.evtRegId == 'COMING') {
            newEvtReg.Status__c = 'Started';
            newEvtReg.Event_Instance_Date_Time_Formatted__c = SEShared.navBreadcrumbBuilder(evtInstance, true);
            newEvtReg.Event__c = evtInfo.evtId;
            newEvtReg.Event_Instance__c = evtInfo.instanceID;
            newEvtReg.Contact__c = contactId;
            if (newContactCreated) {
                newEvtReg.New_Contact_Created__c = true;
            }
            newEvtReg = rCRUD.updateRegistration(newEvtReg);
            evtInfo.evtRegId = newEvtReg.Id;
        }

        //update registration it may already exist, and matching log has to be updated on new registration inserts
        newEvtReg = rCRUD.updateRegistration(newEvtReg);
        System.debug(JSON.serializePretty(newEvtReg));

        if (String.isNotBlank(evtInfo.evtRegId) && evtInfo.evtRegId != 'COMING') {
            if (evtHasAppointments) {
                optionPage = Page.SummitEventsRegisterAppointments;
            } else {
                optionPage = Page.SummitEventsConfirmation;
            }
            // create cookie to pass on to next page
            //Posting along everything we need to build the next page
            String encrytpString = SEShared.createEncryptedCookie('{"audience":"' + evtInfo.audience + '","instanceID":"' + evtInfo.instanceID + '","evtRegId":"' + evtInfo.evtRegId + '","evtId":"' + evtInfo.evtId + '"}', 'SummitEvents');

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                optionPage.setRedirect(true);
                optionPage.getParameters().put('adminopen', ApexPages.currentPage().getParameters().get('adminopen'));
            }

            return optionPage;
        }

        return null;
    }

    private without sharing class registrationCRUD {

        public Summit_Events_Registration__c updateRegistration(Summit_Events_Registration__c newEvtReg) {
            try {
                upsert newEvtReg;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'HELLO: ' + ex.getMessage()));
            }
            return newEvtReg;
        }

        public Summit_Events_Registration__c checkForOtherRegistrations(String checkType, String registrationEmail, Id eventInstanceId, Id eventId) {

            String[] notAcceptableStatuses = new List<String>();
            notAcceptableStatuses.add('Cancelled');
            notAcceptableStatuses.add('Started');
            notAcceptableStatuses.add('Status');

            List<Summit_Events_Registration__c> foundRegistrations = new List<Summit_Events_Registration__c>();
            Summit_Events_Registration__c foundRegistration = null;

            System.debug('Type: ' + checkType + ', email: ' + registrationEmail + ', Instance ID: ' + eventInstanceId + ', Event Id: ' + eventId);

            if (checkType == 'One registration per instance') {
                foundRegistrations = [
                        SELECT Id, LastModifiedDate, Registrant_Email__c
                        FROM Summit_Events_Registration__c
                        WHERE Registrant_Email__c = :registrationEmail
                        AND Event_Instance__c = :eventInstanceId
                        AND Status__c NOT IN :notAcceptableStatuses
                        ORDER BY LastModifiedDate
                ];
            } else if (checkType == 'One registration per event') {
                foundRegistrations = [
                        SELECT Id, LastModifiedDate, Registrant_Email__c
                        FROM Summit_Events_Registration__c
                        WHERE Registrant_Email__c = :registrationEmail
                        AND Event__c = :eventId
                        AND Status__c NOT IN :notAcceptableStatuses
                        ORDER BY LastModifiedDate
                ];
            }
            if (foundRegistrations.size() > 0) {
                foundRegistration = foundRegistrations[0];
            }
            return foundRegistration;
        }

    }
}