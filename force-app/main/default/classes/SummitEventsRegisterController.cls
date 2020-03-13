/**
 * Created by dahl3702 on 5/1/2018.
 */

public with sharing class SummitEventsRegisterController {
    public String test { get; set; }
    public Summit_Events_Instance__c evtInstance { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public List<Summit_Events_Appointment_Type__c> apptTypes { get; set; }
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
    public String locationCrumb { get; set; }
    public String eventStartDateTimeCrumb { get; set; }
    public Boolean evtHasAppointments { get; set; }
    public String birthDateString { get; set; }
    public String dataLayerLocationType { get; set; }
    public Decimal totalEventCost { get; set; }
    public List<Summit_Events_Fee__c> eventFeeList { get; set; }
    public String phoneType { get; set; }
    public String navBreadCrumb { get; set; }


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
        locationCrumb = '';
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
                            Event__r.Event_description__c, Event__r.Audience__c, Start_Date_Time__c, End_Date_Time__c, Current_Available_Capacity__c,
                            Location_Type_Override__c, Location_Address_Override__c, Event__r.Close_Event_Days_Before__c, Location_Map_Link_Override__c, Location_Title_Override__c,
                            Event_Fee_Additional_Attribute_Override__c, Event_Fee_Additional_Override__c, Event_Fee_Override__c, Event_Fee_Attribute_Override__c

                    FROM Summit_Events_Instance__c
                    WHERE Id = :evtInfo.instanceID
                    LIMIT 1
            ][0];

            //define Event ID from instanceInfo data
            evtInfo.evtId = evtInstance.Event__r.Id;
            instanceName = evtInstance.Name;
            Datetime currentDT = SEShared.adjustForCentralTime(Datetime.Now());

            if (evtInstance.Event__r.Close_Event_Days_Before__c != null) {
                currentDT = currentDT.addDays(Integer.Valueof(evtInstance.Event__r.Close_Event_Days_Before__c) + 1);
            }

            if (evtInstance.Current_Available_Capacity__c <= 0 || evtInstance.Active_Status__c != 'Active' || evtInstance.End_Date_Time__c <= currentDT) {
                eventIsClosed = true;
            }

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                Boolean adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                eventIsClosed = adminOpen;
            }

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
                            Ask_Third_Party_Registrant__c
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

            if (!String.isBlank(locationTitle)) {
                locationCrumb = locationTitle + '<br/>';
            }

            if (!String.isBlank(locationAddress) && !String.isBlank(locationMapLink)) {
                locationCrumb += ' <a href="' + locationMapLink + '" target="_blank">' + locationAddress + '</a><br/>';
            } else if (!String.isBlank(locationMapLink)) {
                locationCrumb += ' <a href="' + locationMapLink + '" target="_blank">Map</a><br/>';
            }

            if (evtInstance.Start_Date_Time__c != null && evtInstance.End_Date_Time__c != null) {
                eventStartDateTimeCrumb = evtInstance.Start_Date_Time__c.format('MMMM d, YYYY, h:mm a') + ' - ' + evtInstance.End_Date_Time__c.format('h:mm a');
            }

            if (!String.isBlank(locationCrumb)) {
                locationCrumb = locationCrumb.removeEnd('<br/>');
                String eventTime = '';
                if (evtInstance.Start_Date_Time__c != null && evtInstance.End_Date_Time__c != null) {
                    eventTime = evtInstance.Start_Date_Time__c.format('EEEE MMMM dd, YYYY');
                    eventTime += '<br/>' + evtInstance.Start_Date_Time__c.format('h:mm a') + ' - ' + evtInstance.End_Date_Time__c.format('h:mm a') + '<br/>';
                }
                locationCrumb = eventTime + locationCrumb;
                locationCrumb = '<h3>Event Details</h3> <p>' + locationCrumb + '</p>';
            }

            navBreadCrumb = SEShared.navBreadcrumbBuilder(evtInstance);

            //Check if the Event has appointments and therefore we have to redirect to the appointment page.
            evtHasAppointments = false;
            List<Summit_Events_Appointment_Type__c> apptTypes = [
                    SELECT Id
                    From Summit_Events_Appointment_Type__c
                    WHERE Summit_Events__c = :evtInfo.evtId
                    AND (Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = null)
                    AND Appointment_Type_Status__c = 'Active'
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

            //Calculate event cost by Instance and Event fees and add to list of fees for upsert
            eventFeeList = new List<Summit_Events_Fee__c>();
            totalEventCost = 0;

            if (evtInstance.Event_Fee_Override__c != null) {
                totalEventCost += evtInstance.Event_Fee_Override__c;
                eventFeeList.add(new Summit_Events_Fee__c(
                        Event_Fee__c = evtInstance.Event_Fee_Override__c,
                        Event_Fee_Attribute__c = evtInstance.Event_Fee_Attribute_Override__c,
                        Event_Fee_Type__c = 'Event'
                ));
            } else if (eventPage.Event_Fee__c != null) {
                totalEventCost += eventPage.Event_Fee__c;
                eventFeeList.add(new Summit_Events_Fee__c(
                        Event_Fee__c = eventPage.Event_Fee__c,
                        Event_Fee_Attribute__c = eventPage.Event_Fee_Attribute__c,
                        Event_Fee_Type__c = 'Event'
                ));
            }

            if (evtInstance.Event_Fee_Additional_Override__c != null) {
                totalEventCost += evtInstance.Event_Fee_Additional_Override__c;
                eventFeeList.add(new Summit_Events_Fee__c(
                        Event_Fee__c = evtInstance.Event_Fee_Additional_Override__c,
                        Event_Fee_Attribute__c = evtInstance.Event_Fee_Additional_Attribute_Override__c,
                        Event_Fee_Type__c = 'Event Additional'
                ));
            } else if (eventPage.Event_Fee_Additional__c != null) {
                totalEventCost += eventPage.Event_Fee_Additional__c;
                eventFeeList.add(new Summit_Events_Fee__c(
                        Event_Fee__c = eventPage.Event_Fee_Additional__c,
                        Event_Fee_Attribute__c = eventPage.Event_Fee_Additional_Attribute__c,
                        Event_Fee_Type__c = 'Event Additional'
                ));
            }

        }

        //If the user is logged in use that data
        if ((!String.isBlank(EvtUserType) && EvtUserType != 'Guest' && EvtUserType != 'Standard') || (!String.isBlank(evtInfo.evtRegId) && evtInfo.evtRegId != 'COMING')) {
            //Fill in contact information
            Contact userContact = new Contact();
            if (String.isBlank(evtInfo.evtRegId) || evtInfo.evtRegId == 'COMING') {
                hed__Address__c userAddress = new hed__Address__c();
                List<hed__Address__c> userAddressList = [
                        SELECT hed__Address_Type__c, hed__MailingState__c, hed__MailingStreet2__c, hed__MailingPostalCode__c,
                                hed__Parent_Contact__r.Id
                        FROM hed__Address__c
                        Where hed__Address_Type__c = 'Home'
                        AND hed__Parent_Contact__c IN (
                                SELECT ContactId
                                FROM User
                                Where Id = :UserInfo.getUserId()
                        )
                ];
                if (userAddressList.size() > 0) {
                    userAddress = userAddressList[0];
                }

                userContact = [
                        Select Id, Name, FirstName, LastName, Email, hed__Gender__c, HomePhone, MobilePhone, Do_Not_Text__c, Preferred_First_Name__c, Birthdate
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
                newEvtReg.Registrant_Gender__c = userContact.hed__Gender__c;
                newEvtReg.Registrant_Street_1__c = userAddress.hed__MailingStreet__c;
                newEvtReg.Registrant_Street_2__c = userAddress.hed__MailingStreet2__c;
                newEvtReg.Registrant_State__c = userAddress.hed__MailingState__c;
                newEvtReg.Registrant_City__c = userAddress.hed__MailingCity__c;
                newEvtReg.Registrant_Zip__c = userAddress.hed__MailingPostalCode__c;
                newEvtReg.Registrant_Phone__c = userContact.HomePhone;
                newEvtReg.Registrant_Mobile_Phone__c = userContact.MobilePhone;
                //Path to the following not in HEDA ORG yet
                //newEvtReg.Registrant_College__c = userContact.EnrollmentrxRx__High_School__r.Name;
                //newEvtReg.Registrant_College_Code__c = userContact.EnrollmentrxRx__High_School__r.EnrollmentrxRx__CEEB_Code__c;
                //newEvtReg.Registrant_High_School__c = userContact.EnrollmentrxRx__High_School__r.Name;
                //newEvtReg.Registrant_High_School_Code__c = userContact.EnrollmentrxRx__High_School__r.EnrollmentrxRx__CEEB_Code__c;
                newEvtReg.Registrant_Preferred_First_Name__c = userContact.Preferred_First_Name__c;
                newEvtReg.Registrant_Date_of_Birth__c = userContact.Birthdate;
                if (userContact.Birthdate != null) {
                    birthDateString = userContact.Birthdate.format();
                }
                //    newEvtReg.Registrant_Receive_Texts__c = true;
                if (String.isBlank(userContact.Id)) {
                    contactId = userContact.Id;
                }
                if (!userContact.Do_Not_Text__c) {
                    newEvtReg.Registrant_Receive_Texts__c = true;
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
                                Registrant_Country__c, Registrant_State_Province__c, Registrant_Postal_Code__c, Registrant_Third_Party_Status__c
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
        return PickThePicklist('Contact', 'hed__Gender__c', true);
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

    public List<SelectOption> getProgramsAvailable() {
        List<SelectOption> progSelOpt = new List<SelectOption>();
        /*String prgString = eventPage.Academic_Program_List__c;
        String prgSelectedAlready = newEvtReg.Registrant_Program_Interest__c;
        if (eventPage.Ask_Registrant_Program_Of_Interest__c == 'Ask and require one selection') {
            selectedProgramsOne = prgSelectedAlready;
        }

        //If program list is empty then get the full list
        //Missing field in HEDA org
        If (String.isBlank(prgString)) {
            List<Major__c> schoolProgs = new List<Major__c>();
            if (!String.isBlank(eventPage.School__c)) {
                Id schoolId = eventPage.School__c;
                schoolProgs = [
                        SELECT Id,Name, Major_Name__c,Major_Display_Name__c, Major_Code__c, Program_Offered__r.Program_Code__c, Program_Offered__r.Degree_Level__c
                        FROM Major__c
                        WHERE Status__c = 'Active'
                        AND Program_Offered__r.EnrollmentrxRx__Program_Catalog__r.Name != 'Undergraduate'
                        AND Program_Offered__r.Program_Code__c != NULL
                        AND Program_Offered__r.School__c = :schoolId
                        ORDER BY Major_Name__c
                ];
            } else {
                schoolProgs = [
                        SELECT Id,Name, Major_Name__c,Major_Display_Name__c, Major_Code__c, Program_Offered__r.Program_Code__c, Program_Offered__r.Degree_Level__c
                        FROM Major__c
                        WHERE Status__c = 'Active'
                        AND Program_Offered__r.EnrollmentrxRx__Program_Catalog__r.Name != 'Undergraduate'
                        AND Program_Offered__r.Program_Code__c != NULL
                        ORDER BY Major_Name__c
                ];
            }
            //turn list into a ; separated string to consume below
            prgString = '';
            For (Major__c prog : schoolProgs) {
                prgString += prog.Major_Display_Name__c + ' - ' + prog.Program_Offered__r.Degree_Level__c + ' (' + prog.Program_Offered__r.Program_Code__c;
                if (!String.isBlank(prog.Major_Code__c)) {
                    prgString += '|' + prog.Major_Code__c;
                }
                prgString += ');';
            }
            prgString = prgString.removeEnd(';');
        }


        progSelOpt.add(new SelectOption('', 'Select...'));

        List<String> prgList = prgString.split(';');
        for (String prg : prgList) {
            progSelOpt.add(
                    new SelectOption(
                            prg,
                            prg.replaceAll('\\(\\w+\\|\\w+\\)|\\(\\w+\\)', '').trim()
                    )
            );
            if (!String.isBlank(prgSelectedAlready) && eventPage.Ask_Registrant_Program_Of_Interest__c != 'Ask and require one selection') {
                if (prgSelectedAlready.indexOf(prg) > -1) {
                    selectedPrograms.add(prg);
                }
            }
        }*/
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
                if (eventPage.Ask_Third_Party_Registrant__c.contains(PicklistValue.getValue())) {
                    picklists.add(new SelectOption(PicklistValue.getValue(), PicklistValue.getLabel()));
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

        doCRUD CRUDtoDo = new doCRUD();
        CRUDtoDO.setKey();
        /* if (selectedPrograms.isEmpty() && String.isBlank(selectedProgramsOne) && !String.isBlank(eventPage.Academic_Program_List__c)) {
             selectedPrograms = eventPage.Academic_Program_List__c.split(';');
             progSelectionMade = false;
         }

         if (!String.isBlank(selectedProgramsOne)) {
             selectedPrograms.add(selectedProgramsOne);
         }

         if (!selectedPrograms.isEmpty()) {
             for (String selPrg : selectedPrograms) {
                 recordSelPrg += selPrg + ';';
                 Matcher matcher = TAG_REGEX.matcher(selPrg);
                 while (matcher.find()) {
                     majorCodes.add(matcher.group(1).trim());
                 }
             }
             recordSelPrg.removeEnd(';');
             // Missing Major fields in HEDA
             List<Major__c> majorIdList = [SELECT Id From Major__c Where Prog_Major_Conc_Code__c IN :majorCodes];

             if (majorIdList.size() > 0) {
                 for (Integer mc = 0; mc < 4; mc++) {
                     if (mc < majorIdList.size()) {
                         if (mc == 0) {
                             newEvtReg.Registrant_Major__c = majorIdList[0].id;
                         } else {
                             newEvtReg.put('Registrant_Major_' + (mc + 1) + '__c', majorIdList[mc].id);
                         }
                     } else {
                         newEvtReg.put('Registrant_Major_' + (mc + 1) + '__c', '');
                     }
                 }
             }
             //get major ids and save them
         }*/

//        if ((eventPage.Ask_Registrant_Program_Of_Interest__c == 'Ask but do not require' || eventPage.Ask_Registrant_Program_Of_Interest__c == 'Ask and require' || eventPage.Ask_Registrant_Program_Of_Interest__c == 'Ask and require one selection') && progSelectionMade) {
//            newEvtReg.Registrant_Program_Interest__c = recordSelPrg;
//        } else {
        newEvtReg.Registrant_Program_Interest__c = '';
//        }

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

        //Begin matching based on event record type to get contact ID or create a new contact ID
        SummitEventsContactMatching matcher = new SummitEventsContactMatching();
        Map<String, String> matched = new Map<String, String>();

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

        if (String.isNotBlank(evtInfo.evtRegId) && String.isNotBlank(newEvtReg.Contact__r.Id) && !dataHasChanged) {
            matched.put('contactId', newEvtReg.Contact__r.Id);
            contactId = newEvtReg.Contact__r.Id;
        } else {
            //pass record type and event reg to matcher helper class
            String matchingScope = '';
            if (String.isNotBlank(eventPage.Contact_Creation__c)) {
                matchingScope = eventPage.Contact_Creation__c;
            } else {
                matchingScope = 'Full matching contact creation with duplicate management';
            }
            if (!matchingScope.startsWith('No matching')) {
                String matchingRule = eventPage.Contact_Matching_Rules__c;
                if (String.isBlank(matchingRule)) {
                    matchingRule = 'Matching rules 1';
                }
                matched = matcher.SummitEventsContactMatching(matchingRule, newEvtReg, matchingScope);
                //Populate matching results into data - matched may be blank depending on the Contact_Creation__c setting
                if (matched.size() > 0) {
                    if (String.isNotBlank(matched.get('contactId'))) {
                        contactId = (Id) matched.get('contactId');
                        newContactCreated = Boolean.valueOf(matched.get('newContactCreated'));
                    }
                    newEvtReg.Contact_Soft_Match_Email__c = String.valueOf(matched.get('softEmailMatches'));
                    newEvtReg.Contact_Soft_Match_First_Last_Zip__c = String.valueOf(matched.get('softFirstLastZipMatches'));
                    newEvtReg.Matching_Log__c = String.valueOf(matched.get('matchLog'));
                }
            }
        }

        //Create registration if event Registration does not exist

        if (String.isBlank(evtInfo.evtRegId) || evtInfo.evtRegId == 'COMING') {
            newEvtReg.Status__c = 'Started';
            newEvtReg.Date__c = Date.valueof(evtInstance.Start_Date_Time__c);
            newEvtReg.Event__c = evtInfo.evtId;
            newEvtReg.Event_Instance__c = evtInfo.instanceID;
            newEvtReg.Contact__c = contactId;
            if (newContactCreated) {
                newEvtReg.New_Contact_Created__c = true;
            }
            newEvtReg = CRUDtoDO.updateRegistration(newEvtReg);
            //Update matching log with new ID
            newEvtReg.Matching_Log__c = newEvtReg.Matching_Log__c.replaceAll('\\[\\[REGID\\]\\]', newEvtReg.Id);
            evtInfo.evtRegId = newEvtReg.Id;
            //make matching log functional for reparenting
        }

        //Check and create fees and save on registration
        List<Summit_Events_Fee__c> recordedEventFeeList = [
                SELECT Id, Event_Fee_Type__c, Event_Fee_Attribute__c, Event_Fee__c
                FROM Summit_Events_Fee__c
                WHERE Event_Fee_Type__c != 'Appointment'
                AND Event_Fee_Type__c != 'Appointment Additional'
                AND Event_Registration__c = :evtInfo.evtRegId
        ];
        if (recordedEventFeeList.size() > 0) {
            //Fees already exist so checks need to be made if current fees are there
            List<Id> recordedUsedIds = new list<Id>();
            for (Integer ff = 0; ff < eventFeeList.size(); ff++) {
                for (Summit_Events_Fee__c recordedFees : recordedEventFeeList) {
                    if (eventFeeList[ff].Event_Fee_Type__c == recordedFees.Event_Fee_Type__c) {
                        eventFeeList[ff].Id = recordedFees.Id;
                        recordedUsedIds.add(recordedFees.Id);
                    }
                }
                if (String.isBlank(eventFeeList[ff].Event_Registration__c)) {
                    eventFeeList[ff].Event_Registration__c = evtInfo.evtRegId;
                }
            }
            List<Summit_Events_Fee__c> deleteEventFees = [
                    SELECT Id, Event_Fee_Type__c, Event_Fee_Attribute__c, Event_Fee__c
                    FROM Summit_Events_Fee__c
                    WHERE Event_Fee_Type__c != 'Appointment'
                    AND Event_Fee_Type__c != 'Appointment Additional'
                    AND Event_Registration__c = :evtInfo.evtRegId
                    AND Id NOT IN :recordedUsedIds
            ];
            if (deleteEventFees.size() > 0) {
                CRUDtoDo.deleteFees(deleteEventFees);
            }
        } else {
            //No Fees have ever been recorded on this event. Apply event registration id to all fees.
            if (eventFeeList.size() > 0) {
                for (Integer ff = 0; ff < eventFeeList.size(); ff++) {
                    eventFeeList[ff].Event_Registration__c = evtInfo.evtRegId;
                }
            }
        }
        if (eventFeeList.size() > 0) {
            CRUDtoDo.updateFees(eventFeeList);
        }

        //update registration it may already exist, and matching log has to be updated on new registration inserts
        newEvtReg = CRUDtoDO.updateRegistration(newEvtReg);
        System.debug(JSON.serializePretty(newEvtReg));

        if (String.isNotBlank(evtInfo.evtRegId) && evtInfo.evtRegId != 'COMING') {
            if (evtHasAppointments) {
                optionPage = Page.SummitEventsRegisterAppointments;
            } else if (eventPage.Display_Optional_Donation__c) {
                optionPage = Page.SummitEventsDonation;
            } else if (eventFeeList.size() > 0) {
                optionPage = Page.SummitEventsSubmit;
            } else {
                optionPage = Page.SummitEventsConfirmation;
            }
            // create cookie to pass on to next page
            //Posting along everything we need to build the next page
            String encrytpString = SEShared.createEncryptedCookie('{"audience":"' + evtInfo.audience + '","instanceID":"' + evtInfo.instanceID + '","evtRegId":"' + evtInfo.evtRegId + '","evtId":"' + evtInfo.evtId + '"}', 'SummitEvents');
            return optionPage;
        }

        return null;
    }

    private without sharing class doCRUD {

        public Summit_Events_Registration__c updateRegistration(Summit_Events_Registration__c newEvtReg) {
            try {
                upsert newEvtReg;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'HELLO: ' + ex.getMessage()));
            }
            return newEvtReg;
        }

        public void setKey() {
            Summit_Events_Settings__c SummitEventsSettings = Summit_Events_Settings__c.getOrgDefaults();
            if (String.isBlank(SummitEventsSettings.Encryption_Key__c)) {
                Blob cryptoKey = Crypto.generateAesKey(256);
                String encryptionString = EncodingUtil.base64Encode(cryptoKey).substring(0, 32);
                SummitEventsSettings.Encryption_Key__c = encryptionString;
                upsert SummitEventsSettings;
            }
        }

        public void deleteFees(List<Summit_Events_Fee__c> deletableFees) {
            try {
                delete deletableFees;
            } catch (Exception ex) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                ApexPages.addMessage(myMsg);
            }
        }

        public void updateFees(List<Summit_Events_Fee__c> upsertableFees) {
            try {
                upsert upsertableFees;
            } catch (Exception ex) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
                ApexPages.addMessage(myMsg);
            }
        }

    }
}