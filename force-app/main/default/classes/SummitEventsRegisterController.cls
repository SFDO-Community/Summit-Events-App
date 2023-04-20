// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsRegisterController {
    public Summit_Events_Instance__c evtInstance { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public List<SelectOption> guestAmt { get; set; }
    public Summit_Events_Registration__c eventRegistration { get; set; }
    private final SummitEventsShared SeaShared = new SummitEventsShared();
    public SummitEventsShared.SummitEventsInfo eventInformation { get; set; }
    public String templateSelected { get; set; }
    public Boolean contactSet { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean additionalQuestions { get; set; }
    public List<String> questionNum { get; set; }
    public List<SelectOption> addPick1 { get; set; }
    public List<SelectOption> addPick2 { get; set; }
    public List<SelectOption> addPick3 { get; set; }
    public List<SelectOption> addPick4 { get; set; }
    public List<SelectOption> addPick5 { get; set; }
    public String applicantType { get; set; }
    public String birthDateString { get; set; }
    public Decimal totalEventCost { get; set; }
    public List<Summit_Events_Fee__c> eventFeeList { get; set; }
    public String phoneType { get; set; }
    public String formattedNavDate { get; set; }
    public Boolean showLocation { get; set; }
    public String startTimeString { get; set; }
    public String endTimeString { get; set; }
    public String registrantAudience { get; set; }
    public String EvtUserType { get; set; }
    public Id incomingEventRegistrationId { get; set; }
    public Map<String, PageReference> pageFlow { get; set; }
    public String nextUrl { get; set; }
    public String namespace { get; set; }

    public SummitEventsRegisterController() {
        //array for looping through additional information questions
        questionNum = new List<String>{
                '1', '2', '3', '4', '5'
        };

        namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace.toLowerCase() + '__';
        }

        contactSet = false;
        eventIsClosed = false;
        additionalQuestions = false;
        EvtUserType = UserInfo.getUserType();
        //Get cookie or URL string variable
        eventInformation = SeaShared.getSummitEventsInfo();

        //Create event registration. Populate with current registration if it exists with removed id
        eventRegistration = new Summit_Events_Registration__c();
        if (String.isNotBlank(eventInformation.registrationId)) {
            eventRegistration = getEventRegistration(eventInformation.registrationId);
            if (eventRegistration != null) {
                incomingEventRegistrationId = eventRegistration.Id;
                eventRegistration.Id = null;
            }
            if (eventRegistration.Registrant_Date_of_Birth__c != null) {
                birthDateString = eventRegistration.Registrant_Date_of_Birth__c.format();
            }
        }

        //Set the default country if it is in settings and matches something in the global pick list
        Summit_Events_Settings__c seaCustomSettings = Summit_Events_Settings__c.getOrgDefaults();
        String defaultCountry = seaCustomSettings.Default_Country__c;
        System.debug(defaultCountry);
        if (String.isNotBlank(defaultCountry) && String.isBlank(eventRegistration.Registrant_Country__c)) {
            List<SelectOption> getCountryDD = PickThePicklist('Summit_Events_Registration__c', 'Registrant_Country__c', false);
            for (SelectOption selectOption : getCountryDD) {
                if (selectOption.getLabel().equalsIgnoreCase(defaultCountry) || selectOption.getValue().equalsIgnoreCase(defaultCountry)) {
                    eventRegistration.Registrant_Country__c = selectOption.getValue();
                    break;
                }
            }
        }
        System.debug(eventRegistration.Registrant_Country__c);

        //Set applicant type if audience is passed
        registrantAudience = eventInformation.audience;
        if (!String.isBlank(registrantAudience)) {
            if (registrantAudience == 'Transfer' || registrantAudience == 'Transfer International') {
                applicantType = 'Transfer';
            } else if (registrantAudience == 'High School Senior' || registrantAudience == 'High School Junior or Younger' || registrantAudience == 'First-Year International' || registrantAudience == 'Dougherty Family College (2-Year)') {
                applicantType = 'First-Year';
            }
        } else {
            registrantAudience = '';
        }

        //Get Instance information
        if (String.isNotBlank(eventInformation.instanceId)) {
            evtInstance = [
                    SELECT Id, Name, Event__r.Name, Event__r.Event_Name__c, Event__r.Id, Instance_Title__c, Active_Status__c, Capacity__c,
                            Event__r.Event_description__c, Event__r.Audience__c, Current_Available_Capacity__c,
                            Location_Type_Override__c, Location_Address_Override__c, Event__r.Close_Event_Days_Before__c, Location_Map_Link_Override__c, Location_Title_Override__c,
                            Event_Fee_Additional_Allocation_Override__c, Event_Fee_Additional_Override__c, Event_Fee_Override__c, Event_Fee_Allocation_Override__c,
                            Instance_Start_Date__c, Instance_Start_Time__c, Instance_End_Date__c, Instance_End_Time__c, Instance_Time_Zone__c, Registration_Close_Date__c, Registration_Close_Time__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :eventInformation.instanceId
                    WITH SECURITY_ENFORCED
            ];

            //define Event ID from instanceInfo data
            eventInformation.eventId = evtInstance.Event__r.Id;
            startTimeString = SeaShared.formatTime(evtInstance.Instance_Start_Time__c, false);
            endTimeString = SeaShared.formatTime(evtInstance.Instance_End_Time__c, false);
        }

        //Get Event Info off of instance master detail id
        if (!String.isBlank(eventInformation.eventId)) {
            eventPage = [
                    SELECT Name, Id, Event_Name__c, Event_description__c, Event_Footer__c, Event_Full_Text__c, Audience__c, Include_Time_frame_List__c,
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
                            Close_Event_Days_Before__c, Ask_Title__c, Ask_Company_Organization__c, Event_Fee__c, Event_Fee_Additional__c,
                            Event_Fee_Additional_Allocation__c, Event_Fee_Allocation__c, Display_Optional_Donation__c,
                            Applicant_Type_Label__c, Company_Organization_Label__c, Date_Of_Birth_Label__c, Email_Label__c,
                            First_Name_Label__c, Gender_Label__c, Last_Name_As_Student_Label__c, Last_Name_Label__c, Mailing_Address_Label__c,
                            Phone_Label__c, Phone_Type_Label__c, Preferred_First_Name_Label__c, Pronouns_Label__c, Registrant_Receive_Texts_Label__c,
                            Relationship_To_Institution_Label__c, Third_Party_Registrant_Label__c, Title_Label__c, Preferred_Class_Year_Label__c,
                            Registrant_Relationship_Label__c, Event_Fee_Label__c, Event_Fee_Total_Label__c, Event_Fee_Submit_List_Label__c, Account__r.Name,
                            Filter_Category__c
                    FROM Summit_Events__c
                    WHERE Id = :eventInformation.eventId
                    WITH SECURITY_ENFORCED
            ];

            pageFlow = SeaShared.getPageFlow(eventInformation.eventId, evtInstance.Instance_Title__c, ApexPages.currentPage(), evtInstance.Instance_Start_Date__c, evtInstance.Instance_End_Date__c);
            nextUrl = pageFlow.get('Next').getUrl().toLowerCase();

            if (String.isNotBlank(eventPage.Ask_Phone__c)) {
                if (eventPage.Ask_Phone__c.containsIgnoreCase('with type') && String.isNotBlank(eventRegistration.Registrant_Mobile_Phone__c) && String.isBlank(eventRegistration.Registrant_Phone__c)) {
                    phoneType = 'mobile';
                } else if (String.isBlank(eventRegistration.Registrant_Mobile_Phone__c) && String.isNotBlank(eventRegistration.Registrant_Phone__c)) {
                    phoneType = 'home';
                }
            }

            if (String.isNotBlank(eventRegistration.Registrant_Applicant_Type__c)) {
                applicantType = eventRegistration.Registrant_Applicant_Type__c;
            } else if (!String.isBlank(eventPage.Ask_Applicant_Type__c)) {
                //Important to start all of this with exact "Do not ask but assign " to assign correctly
                if (eventPage.Ask_Applicant_Type__c.startsWith('Do not ask but assign ')) {
                    applicantType = eventPage.Ask_Applicant_Type__c.replace('Do not ask but assign ', '');
                }
            }

            eventIsClosed = SeaShared.isEventClosed(evtInstance);

            if (
                    (String.isNotBlank(eventPage.Add_Info_Question_Type_1__c) && String.isNotBlank(eventPage.Add_Info_Question_Text_1__c)) ||
                            (String.isNotBlank(eventPage.Add_Info_Question_Type_2__c) && String.isNotBlank(eventPage.Add_Info_Question_Text_2__c)) ||
                            (String.isNotBlank(eventPage.Add_Info_Question_Type_3__c) && String.isNotBlank(eventPage.Add_Info_Question_Text_3__c)) ||
                            (String.isNotBlank(eventPage.Add_Info_Question_Type_4__c) && String.isNotBlank(eventPage.Add_Info_Question_Text_4__c)) ||
                            (String.isNotBlank(eventPage.Add_Info_Question_Type_5__c) && String.isNotBlank(eventPage.Add_Info_Question_Text_5__c)) ||

                            eventPage.Include_Time_frame_List__c ||
                            eventPage.Allow_Other_Attendees__c ||
                            (eventPage.Ask_Gender__c != 'Do not ask' && eventPage.Ask_Gender__c != null)
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

            formattedNavDate = SeaShared.navBreadcrumbBuilder(evtInstance);

            //Grab the template if defined
            templateSelected = SeaShared.getTemplate(eventPage.Template__c);

            if (eventPage.Allow_Other_Attendees__c) {
                guestAmt = new List<SelectOption>();
                if (Integer.valueOf(eventPage.Max_Other_Attendees__c) > 0) {
                    for (Integer ma = 0; ma <= Integer.valueOf(eventPage.Max_Other_Attendees__c); ma++) {
                        guestAmt.add(new SelectOption(String.valueOf(ma), String.valueOf(ma)));
                    }
                }
            }

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
                        Event_Fee_Allocation__c = evtInstance.Event_Fee_Allocation_Override__c,
                        Event_Fee_Type__c = 'Event'
                ));
            } else if (eventPage.Event_Fee__c != null) {
                totalEventCost += eventPage.Event_Fee__c;
                eventFeeList.add(new Summit_Events_Fee__c(
                        Event_Fee__c = eventPage.Event_Fee__c,
                        Event_Fee_Allocation__c = eventPage.Event_Fee_Allocation__c,
                        Event_Fee_Type__c = 'Event'
                ));
            }

            if (evtInstance.Event_Fee_Additional_Override__c != null) {
                totalEventCost += evtInstance.Event_Fee_Additional_Override__c;
                eventFeeList.add(new Summit_Events_Fee__c(
                        Event_Fee__c = evtInstance.Event_Fee_Additional_Override__c,
                        Event_Fee_Allocation__c = evtInstance.Event_Fee_Additional_Allocation_Override__c,
                        Event_Fee_Type__c = 'Event Additional'
                ));
            } else if (eventPage.Event_Fee_Additional__c != null) {
                totalEventCost += eventPage.Event_Fee_Additional__c;
                eventFeeList.add(new Summit_Events_Fee__c(
                        Event_Fee__c = eventPage.Event_Fee_Additional__c,
                        Event_Fee_Allocation__c = eventPage.Event_Fee_Additional_Allocation__c,
                        Event_Fee_Type__c = 'Event Additional'
                ));
            }

            /*get Analytic data*/

            //Get current URL
            String baseURL = Url.getSalesforceBaseUrl().toExternalForm();
            String PageURL = ApexPages.currentPage().getUrl();
            eventRegistration.Event_Website__c = baseURL + PageURL.replace('\'', '').escapeHtml4();

            //Get referrer url if not blank
            if (String.isNotBlank(ApexPages.currentPage().getHeaders().get('Referer'))) {
                eventRegistration.Event_Website_Referrer__c = ApexPages.currentPage().getHeaders().get('Referer').replace('\'', '').escapeHtml4();
            }

            //get and sanitize utm variables
            List<String> analyticCodes = new List<String>{
                    'gclid__c', 'utm_campaign__c', 'utm_content__c', 'utm_creative_format__c', 'utm_id__c',
                    'utm_marketing_tactic__c', 'utm_medium__c', 'utm_source__c', 'utm_source_platform__c', 'utm_term__c'
            };

            for (String code : analyticCodes) {
                String urlParameter = code.removeEnd('__c');
                if (String.isNotBlank(ApexPages.currentPage().getParameters().get(urlParameter))) {
                    String codeValue = ApexPages.currentPage().getParameters().get(urlParameter);
                    codeValue = codeValue.replace('\'', '');
                    codeValue = codeValue.escapeHtml4();
                    eventRegistration.put(code, codeValue);
                }
            }

        }

        //If the user is logged in use that data
        if ((!String.isBlank(EvtUserType) && EvtUserType != 'Guest' && EvtUserType != 'Standard') || (String.isNotBlank(eventInformation.registrationId))) {
            //Fill in contact information
            Contact userContact = new Contact();
            if (String.isBlank(eventInformation.registrationId)) {

                userContact = [
                        SELECT Id, Name, FirstName, LastName, Email, HomePhone, MobilePhone, Birthdate, MailingStreet,
                                MailingState, MailingCountry, MailingPostalCode, MailingCity
                        FROM Contact
                        WHERE Id IN (
                                SELECT ContactId
                                FROM User
                                WHERE Id = :UserInfo.getUserId()
                        )
                        WITH SECURITY_ENFORCED
                ];

                eventRegistration.Registrant_Street_1__c = userContact.MailingStreet;
                eventRegistration.Registrant_State__c = userContact.MailingState;
                eventRegistration.Registrant_Country__c = userContact.MailingCountry;
                eventRegistration.Registrant_Postal_Code__c = userContact.MailingPostalCode;
                eventRegistration.Registrant_Zip__c = userContact.MailingPostalCode;
                eventRegistration.Registrant_City__c = userContact.MailingCity;
                eventRegistration.Registrant_First_Name__c = userContact.FirstName;
                eventRegistration.Registrant_Last_Name__c = userContact.LastName;
                eventRegistration.Registrant_Email__c = userContact.Email;
                eventRegistration.Registrant_Phone__c = userContact.HomePhone;
                eventRegistration.Registrant_Mobile_Phone__c = userContact.MobilePhone;
                eventRegistration.Registrant_Date_of_Birth__c = userContact.Birthdate;
                eventRegistration.Contact__c = userContact.Id;

                if (userContact.Birthdate != null) {
                    birthDateString = userContact.Birthdate.format();
                }
                //    newEvtReg.Registrant_Receive_Texts__c = true;
                if (String.isBlank(userContact.Id)) {
                    eventRegistration.Contact__c = userContact.Id;
                }
                contactSet = true;
            }
            if (EvtUserType != 'Guest') {
                contactSet = true;
            }
        }
    }

    public Summit_Events_Registration__c getEventRegistration(Id eventRegistrationId) {
        Summit_Events_Registration__c oldEventRegistration = [
                SELECT Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c, Number_of_Guests__c, Registrant_Applicant_Type__c,
                        Registrant_Gender__c, Registrant_Street_1__c, Registrant_Street_2__c, Registrant_State__c, Registrant_City__c, Preferred_Visit_Time__c,
                        Registrant_Zip__c, Registrant_Phone__c, Registrant_Mobile_Phone__c, Registrant_College__c, Registrant_College_Code__c, Registrant_College_Year__c,
                        Registrant_High_School__c, Registrant_High_School_Code__c, Registrant_Receive_Texts__c, Registrant_High_School_Grad_Year__c, Registrant_High_School_Not_Found__c,
                        Registrant_College_Not_Found__c, Registrant_Parent_First_Name__c, Registrant_Parent_Last_Name__c, Registrant_Parent_Email__c, Registrant_Parent_Phone__c,
                        Add_Info_Answer_1__c, Add_Info_Answer_2__c, Add_Info_Answer_3__c, Add_Info_Answer_4__c, Add_Info_Answer_5__c, Registrant_Program_Interest__c, Registrant_Preferred_First_Name__c,
                        Registrant_Date_of_Birth__c, Last_Name_as_Student__c, Preferred_Class_Year__c, Relationship_To_Institution__c, Registrant_Other_Email__c, Registrant_Other_First_Name__c, Registrant_Other_Last_Name__c,
                        Registrant_Other_Phone__c, Registrant_Other_Relationship__c, Registrant_Country__c, Registrant_State_Province__c, Registrant_Postal_Code__c, Registrant_Third_Party_Status__c,
                        Registrant_Pronouns__c, Registrant_Title__c, Registrant_Company_Organization__c, Event_Website__c, Event_Website_Referrer__c, gclid__c, utm_campaign__c, utm_content__c,
                        utm_creative_format__c, utm_id__c, utm_marketing_tactic__c, utm_medium__c, utm_source__c, utm_source_platform__c, utm_term__c
                FROM Summit_Events_Registration__c
                WHERE Id = :eventRegistrationId
                WITH SECURITY_ENFORCED
        ];
        if (oldEventRegistration != null) {
            return oldEventRegistration;
        }
        return new Summit_Events_Registration__c();
    }

    public PageReference checkEventDetails() {
        return SeaShared.checkForEvent();
    }

    public List<SelectOption> getSexDD() {
        return PickThePicklist('Summit_Events_Registration__c', 'Registrant_Gender__c', true);
    }

    public List<SelectOption> getStateDD() {
        List<SelectOption> pickListItems = new List<SelectOption>();
        if (String.isNotBlank(eventRegistration.Registrant_Country__c)) {
            Map<String, String> dependencies = SeaShared.getDependentSelectOptions('Summit_Events_Registration__c', 'Registrant_Country__c', 'Registrant_State_Global__c', eventRegistration.Registrant_Country__c);
            if (dependencies.size() > 1) {
                pickListItems.add(new SelectOption('', 'Select...'));
                for (String item : dependencies.keySet()) {
                    pickListItems.add(new SelectOption(item, dependencies.get(item)));
                }
            }
        }
        return pickListItems;
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

    public List<SelectOption> createPicklists(String returnSepStringList) {
        List<SelectOption> cpl = new List<SelectOption>();
        if (!String.isBlank(returnSepStringList)) {
            cpl.add(new SelectOption('', 'Select...'));
            returnSepStringList = returnSepStringList.trim();
            returnSepStringList = returnSepStringList.replace('\n\n', '\n');
            String[] splitList = returnSepStringList.split('\n');
            for (String p : splitList) {
                p = p.replaceAll('[^a-zA-Z0-9@<>?&;:\\[\\]!-. ]', '');
                cpl.add(new SelectOption(p, p));
            }
        }
        return cpl;
    }

    public List<SelectOption> PickThePicklist(String YourObjectName, String YourFieldName, Boolean includeSelect) {
        List<SelectOption> picklists = new List<SelectOption>();
        namespace = SummitEventsNamespace.getNamespace();
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
                if (eventPage != null && String.isNotBlank(eventPage.Ask_Third_Party_Registrant__c)) {
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
        PageReference optionPage;

        if (String.isNotBlank(phoneType) && eventPage.Ask_Phone__c.containsIgnoreCase('with type')) {
            if (phoneType.equalsIgnoreCase('mobile')) {
                eventRegistration.Registrant_Phone__c = '';
            } else if (phoneType.equalsIgnoreCase('home')) {
                eventRegistration.Registrant_Mobile_Phone__c = '';
            }
        }

        registrationCRUD rCRUD = new registrationCRUD();

        if (String.isNotBlank(eventPage.Registration_Email_Restriction__c) && eventPage.Registration_Email_Restriction__c != 'No Limit') {
            Summit_Events_Registration__c foundRegistration = rCRUD.checkForOtherRegistrations(eventPage.Registration_Email_Restriction__c, eventRegistration.Registrant_Email__c, evtInstance.Id, eventPage.Id);
            if (foundRegistration != null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'It appears you’ve already registered for this event. Please contact the Event Host for more information.');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }

        eventRegistration.Registrant_Program_Interest__c = '';

        if (String.isNotBlank(birthDateString)) {
            eventRegistration.Registrant_Date_of_Birth__c = Date.parse(birthDateString);
        }

        if (String.isNotBlank(applicantType)) {
            eventRegistration.Registrant_Applicant_Type__c = applicantType;
        } else if (eventPage.Ask_Applicant_Type__c == 'Do not ask but assign First-Year') {
            eventRegistration.Registrant_Applicant_Type__c = 'First-Year';
        } else if (eventPage.Ask_Applicant_Type__c == 'Do not ask but assign Transfer') {
            eventRegistration.Registrant_Applicant_Type__c = 'Transfer';
        } else if (eventPage.Ask_Applicant_Type__c == 'Do not ask but assign Graduate') {
            eventRegistration.Registrant_Applicant_Type__c = 'Graduate';
        }

        //Check and create fees and save on registration
        List<Summit_Events_Fee__c> recordedEventFeeList = [
                SELECT Id, Event_Fee_Type__c, Event_Fee_Allocation__c, Event_Fee__c
                FROM Summit_Events_Fee__c
                WHERE Event_Fee_Type__c != 'Appointment'
                AND Event_Fee_Type__c != 'Appointment Additional'
                AND Event_Fee_Type__c != 'Optional Donation'
                AND Event_Registration__c = :eventInformation.registrationId
                WITH SECURITY_ENFORCED
        ];
        if (recordedEventFeeList.size() > 0) {
            //Fees already exist so checks need to be made if current fees are there
            List<Id> recordedUsedIds = new List<Id>();
            for (Integer ff = 0; ff < eventFeeList.size(); ff++) {
                for (Summit_Events_Fee__c recordedFees : recordedEventFeeList) {
                    if (eventFeeList[ff].Event_Fee_Type__c == recordedFees.Event_Fee_Type__c) {
                        eventFeeList[ff].Id = recordedFees.Id;
                        recordedUsedIds.add(recordedFees.Id);
                    }
                }
            }
            List<Summit_Events_Fee__c> deleteEventFees = [
                    SELECT Id, Event_Fee_Type__c, Event_Fee_Allocation__c, Event_Fee__c
                    FROM Summit_Events_Fee__c
                    WHERE Event_Fee_Type__c != 'Appointment'
                    AND Event_Fee_Type__c != 'Appointment Additional'
                    AND Event_Fee_Type__c != 'Optional Donation'
                    AND Event_Registration__c = :eventInformation.registrationId
                    AND Id NOT IN :recordedUsedIds
                    WITH SECURITY_ENFORCED
            ];
            if (deleteEventFees.size() > 0) {
                rCRUD.deleteFees(deleteEventFees);
            }
        }

        eventRegistration.Status__c = 'Started';
        eventRegistration.Event_Instance_Date_Time_Formatted__c = SeaShared.navBreadcrumbBuilder(evtInstance);
        eventRegistration.Event__c = eventInformation.eventId;
        eventRegistration.Event_Instance__c = eventInformation.instanceId;

        eventRegistration = rCRUD.updateRegistration(eventRegistration, incomingEventRegistrationId, registrantAudience, eventFeeList);

        eventInformation.registrationId = eventRegistration.Id;

        String dayOfWeek = SeaShared.convertDateToDatetime(evtInstance.Instance_Start_Date__c, null, '').format('EEEE');
        //Insert pre-chosen appointments for appointments page
        List<Summit_Events_Appointment_Type__c> autoAddAppt = [
                SELECT Id, Name, Title__c, Description__c, Appointment_Type__c, Appointment_Category__c, Registrant_Input__c, Custom_Picklist__c, Appointment_Limits__c,
                        Chosen_State__c, Sort_Order__c, Auto_Confirm_Appointment__c, Auto_add_building__c, Auto_Add_Time__c, Do_Not_Show_Time__c
                FROM Summit_Events_Appointment_Type__c
                WHERE Summit_Events__c = :eventInformation.eventId
                AND (Chosen_State__c = 'Added' OR Chosen_State__c = 'Added and Required' OR Chosen_State__c = 'Added but not shown')
                AND Id NOT IN (SELECT Event_Appointment_Type__c FROM Summit_Events_Appointments__c WHERE Event_Registration__c = :eventInformation.registrationId)
                AND (Restrict_To_Instance_Title__r.Instance_Title__c = :evtInstance.Instance_Title__c OR Restrict_To_Instance_Title__r.Instance_Title__c = NULL OR Restrict_To_Instance_Title__r.Instance_Title__c = '')
                AND (Date_Available_Start__c <= :evtInstance.Instance_Start_Date__c OR Date_Available_Start__c = NULL)
                AND (Date_Available_End__c >= :evtInstance.Instance_End_Date__c OR Date_Available_End__c = NULL)
                AND (Day_of_Week_Availability__c INCLUDES (:dayOfWeek) OR Day_of_Week_Availability__c = NULL)
                AND (Appointment_Type_Status__c = 'Active' OR Appointment_Type_Status__c = NULL)
                ORDER BY Sort_Order__c ASC NULLS LAST
        ];

        List<Summit_Events_Appointments__c> appointmentsToAdd = new List<Summit_Events_Appointments__c>();
        for (Summit_Events_Appointment_Type__c appt : autoAddAppt) {
            Summit_Events_Appointments__c addAppt = new Summit_Events_Appointments__c();
            addAppt.Event_Appointment_Type__c = appt.Id;
            addAppt.Event_Registration__c = eventInformation.registrationId;
            addAppt.Appointment_Title__c = appt.Title__c;
            //If appointment is not shown and auto confirmed confirm it!
            if (appt.Auto_Confirm_Appointment__c) {
                addAppt.Appointment_Status__c = 'Confirmed';
            } else {
                addAppt.Appointment_Status__c = 'Requested';
            }
            if (String.isNotBlank(appt.Auto_add_building__c)) {
                addAppt.Building__c = appt.Auto_add_building__c;
            }
            if (appt.Auto_Add_Time__c != null) {
                addAppt.Appointment_Time__c = appt.Auto_Add_Time__c;
            }
            addAppt.Appointment_Category__c = appt.Appointment_Category__c;
            addAppt.Appointment_Type__c = appt.Appointment_Type__c;
            addAppt.Appointment_Detail__c = appt.Description__c;
            addAppt.Client_Created_Appointment__c = true;
            addAppt.Chosen_State__c = appt.Chosen_State__c;
            addAppt.Sort_Order__c = appt.Sort_Order__c;
            addAppt.Description__c = appt.Description__c;
            addAppt.Registrant_Input__c = appt.Registrant_Input__c;
            addAppt.Do_Not_Show_Time__c = appt.Do_Not_Show_Time__c;
            appointmentsToAdd.add(addAppt);
        }
        if (appointmentsToAdd.size() > 0) {
            rCRUD.insertAppointments(appointmentsToAdd);
        }


        optionPage = pageFlow.get('Next');

        return optionPage;
    }


    /**
     * Summit Events is a multi-step, guest user, registration solution so CRUD work needs to be done on records where guest record ownership is lost between steps.
     * The security aspects of guest record updating is achieved by:
     * - Using an encrypted cookie on the client browser to keep track of registration id, event id, instance id, and audience
     * - Dividing each controller class into a "with sharing" logic area and a sub "without sharing" CRUD area for purposeful CRUD
     * - When the encrypted cookie is not available as in the cancel registration link an encrypted string is provided through the URL to not expose the SF ID related to the record
     **/

    private without sharing class registrationCRUD {

        public Summit_Events_Registration__c updateRegistration(Summit_Events_Registration__c eventRegistration, Id incomingEventRegistrationId, String registrantAudience, List<Summit_Events_Fee__c> upsertFees) {
            System.debug(JSON.serializePretty(eventRegistration));
            try {
                if (String.isNotBlank(incomingEventRegistrationId)) {
                    eventRegistration.Id = incomingEventRegistrationId;
                    update eventRegistration;
                } else {
                    if (Schema.SObjectType.Summit_Events_Registration__c.isCreateable()) {
                        insert eventRegistration;
                    }
                }
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }

            //Save fees
            if (upsertFees.size() > 0) {
                for (Integer ff = 0; ff < upsertFees.size(); ff++) {
                    upsertFees[ff].Event_Registration__c = eventRegistration.Id;
                }
                try {
                    if (Schema.SObjectType.Summit_Events_Registration__c.isCreateable()) {
                        insert upsertFees;
                    }
                } catch (Exception ex) {
                    System.debug(ex.getMessage());
                }
            }

            //Update encrypted cookie
            SummitEventsShared SeaShared = new SummitEventsShared();
            SeaShared.createEncryptedCookie(registrantAudience, eventRegistration.Event_Instance__c, eventRegistration.Event__c, eventRegistration.Id);

            return eventRegistration;
        }

        public void deleteFees(List<Summit_Events_Fee__c> deletableFees) {
            try {
                delete deletableFees;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }

        public void insertAppointments(List<Summit_Events_Appointments__c> appointments) {
            try {
                insert appointments;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }
        }

        public Summit_Events_Registration__c checkForOtherRegistrations(String checkType, String registrationEmail, Id eventInstanceId, Id eventId) {

            String[] notAcceptableStatuses = new List<String>();
            notAcceptableStatuses.add('Cancelled');
            notAcceptableStatuses.add('Started');
            notAcceptableStatuses.add('Status');

            List<Summit_Events_Registration__c> foundRegistrations = new List<Summit_Events_Registration__c>();
            Summit_Events_Registration__c foundRegistration = null;

            if (checkType == 'One registration per instance') {
                foundRegistrations = [
                        SELECT Id, LastModifiedDate, Registrant_Email__c
                        FROM Summit_Events_Registration__c
                        WHERE Registrant_Email__c = :registrationEmail
                        AND Event_Instance__c = :eventInstanceId
                        AND Status__c NOT IN :notAcceptableStatuses
                        WITH SECURITY_ENFORCED
                        ORDER BY LastModifiedDate
                ];
            } else if (checkType == 'One registration per event') {
                foundRegistrations = [
                        SELECT Id, LastModifiedDate, Registrant_Email__c
                        FROM Summit_Events_Registration__c
                        WHERE Registrant_Email__c = :registrationEmail
                        AND Event__c = :eventId
                        AND Status__c NOT IN :notAcceptableStatuses
                        WITH SECURITY_ENFORCED
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