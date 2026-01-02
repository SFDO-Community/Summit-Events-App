// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on  1/1/2026.

public with sharing class SummitEventsLWCController {

    //Build wrapper classes to send to LWC
    public class SummitEventWrapper {
        @AuraEnabled public List<PageInfo> pages { get; set; }
        @AuraEnabled public Integer currentPageIndex { get; set; }
        @AuraEnabled public Registration primaryRegistration { get; set; }
        @AuraEnabled public List<Registration> guestRegistrations { get; set; }
        @AuraEnabled public Summit_Events_Instance__c instance { get; set; }
        @AuraEnabled public Summit_Events__c eventInfo { get; set; }
        @AuraEnabled public Map<Id, Summit_Events_Appointment_Type__c> appointmentTypes { get; set; }
        @AuraEnabled public List<SummitEventsQuestionWrapper> registrantQuestions { get; set; }
        @AuraEnabled public List<SummitEventsQuestionWrapper> guestQuestions { get; set; }
        @AuraEnabled public EventConfiguration config { get; set; }
        @AuraEnabled public String audience { get; set; }
        @AuraEnabled public String encryptedRegistrationId { get; set; }
        @AuraEnabled public List<Summit_Events_Fee__c> fees { get; set; }
        @AuraEnabled public Decimal totalEventCost { get; set; }
        @AuraEnabled public RecaptchaInfo recaptcha { get; set; }
    }

    public class EventConfiguration {
        @AuraEnabled public Boolean hasAdditionalQuestions { get; set; }
        @AuraEnabled public Boolean hasAppointments { get; set; }
        @AuraEnabled public Boolean hasGuestRegistration { get; set; }
        @AuraEnabled public Boolean hasDonations { get; set; }
        @AuraEnabled public Boolean hasEventFee { get; set; }
        @AuraEnabled public Boolean askThirdPartyRegistrant { get; set; }
        @AuraEnabled public Boolean askPreferredName { get; set; }
        @AuraEnabled public Boolean askDateOfBirth { get; set; }
        @AuraEnabled public Boolean askGender { get; set; }
        @AuraEnabled public Boolean askPronoun { get; set; }
        @AuraEnabled public Boolean askMailingAddress { get; set; }
        @AuraEnabled public Boolean askPhone { get; set; }
        @AuraEnabled public Boolean askCompanyOrganization { get; set; }
        @AuraEnabled public Boolean askTitle { get; set; }
        @AuraEnabled public Boolean askDietaryRestrictions { get; set; }
        @AuraEnabled public Boolean askAccessibilityNeeds { get; set; }
        @AuraEnabled public Integer maxGuests { get; set; }
    }

    public class SummitEventsQuestionWrapper {
        @AuraEnabled public String questionId { get; set; }
        @AuraEnabled public String questionLabel { get; set; }
        @AuraEnabled public String questionFieldType { get; set; }
        @AuraEnabled public String helpText { get; set; }
        @AuraEnabled public String instructions { get; set; }
        @AuraEnabled public String errorAssistText { get; set; }
        @AuraEnabled public String mapToField { get; set; }
        @AuraEnabled public String defaultValue { get; set; }
        @AuraEnabled public Boolean required { get; set; }
        @AuraEnabled public Boolean isVisible { get; set; }
        @AuraEnabled public Integer displayOrder { get; set; }
        @AuraEnabled public Integer textLimit { get; set; }
        @AuraEnabled public String displayStyle { get; set; }
        @AuraEnabled public String registrantType { get; set; }

        // Picklist fields
        @AuraEnabled public List<PicklistOption> picklistValues { get; set; }
        @AuraEnabled public String existingPicklistField { get; set; }

        // Lookup fields
        @AuraEnabled public String lookupObject { get; set; }
        @AuraEnabled public String lookupFields { get; set; }
        @AuraEnabled public String lookupWhereClause { get; set; }
        @AuraEnabled public String lookupOrderBy { get; set; }
        @AuraEnabled public String lookupIcon { get; set; }
        @AuraEnabled public String lookupNoResultsLabel { get; set; }
        @AuraEnabled public String lookupSecondaryInputLinkText { get; set; }
        @AuraEnabled public String lookupSecondaryInputInstructions { get; set; }
        @AuraEnabled public String lookupSecondaryValueField { get; set; }

        // Controlling logic
        @AuraEnabled public String controllingQuestion { get; set; }
        @AuraEnabled public String controllingLogic { get; set; }

        // Current value (from registration)
        @AuraEnabled public Object currentValue { get; set; }
    }

    public class Registration {
        @AuraEnabled public Summit_Events_Registration__c registrationRecord { get; set; }
        @AuraEnabled public List<Summit_Events_Appointments__c> appointments { get; set; }
        @AuraEnabled public Boolean isGuest { get; set; }
        @AuraEnabled public Integer guestIndex { get; set; }
    }

    public class PicklistOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
    }

    public class PageInfo {
        @AuraEnabled public String pageType { get; set; } // 'register', 'questions', 'appointments', 'guests', 'submit', 'confirmation'
        @AuraEnabled public Integer pageIndex { get; set; }
        @AuraEnabled public String pageName { get; set; }
        @AuraEnabled public String pageMetaTitle { get; set; }
        @AuraEnabled public String pageHeading { get; set; }
        @AuraEnabled public String pageSubheading { get; set; }
        @AuraEnabled public String pageDescription { get; set; }
        @AuraEnabled public Boolean isActive { get; set; }
    }

    public class RecaptchaInfo {
        @AuraEnabled public Integer version { get; set; }
        @AuraEnabled public String publicKey { get; set; }
        @AuraEnabled public String apiUrl { get; set; }
        @AuraEnabled public Decimal failScore { get; set; }
    }


    @AuraEnabled(Cacheable=true)
    public static SummitEventWrapper getSummitEventData(Id eventInstanceId, String registrationId) {
        SummitEventWrapper wrapper = new SummitEventWrapper();

        try {
            // Get instance and event information
            wrapper.instance = SummitEventsReadShared.getInstanceById(eventInstanceId);
            if (wrapper.instance == null) {
                return null;
            }

            Id eventId = wrapper.instance.Event__c;
            wrapper.eventInfo = SummitEventsReadShared.getEventById(eventId);

            // Get day of week for appointment filtering
            String dayOfWeek = SummitEventsShared.convertDateToDatetime(
                wrapper.instance.Instance_Start_Date__c, null, ''
            ).format('EEEE');

            // Get appointment types for this event
            wrapper.appointmentTypes = SummitEventsReadShared.getAppointmentTypesByEventId(
                eventId,
                wrapper.instance.Instance_Title__c,
                wrapper.instance.Instance_Start_Date__c,
                wrapper.instance.Instance_End_Date__c,
                dayOfWeek
            );

            // Build event configuration
            wrapper.config = buildEventConfiguration(wrapper.eventInfo, wrapper.appointmentTypes);

            // Get questions for registrants and guests
            List<String> registrantTypes = new List<String>{'Registrant', 'Registrant and Guest'};
            Map<Id, Summit_Events_Question__c> registrantQuestionMap = SummitEventsReadShared.getAdditionalQuestionsByEventId(eventId, registrantTypes);
            wrapper.registrantQuestions = buildQuestionWrappers(registrantQuestionMap, null);

            List<String> guestTypes = new List<String>{'Guest', 'Registrant and Guest'};
            Map<Id, Summit_Events_Question__c> guestQuestionMap = SummitEventsReadShared.getAdditionalQuestionsByEventId(eventId, guestTypes);
            wrapper.guestQuestions = buildQuestionWrappers(guestQuestionMap, null);

            // Update config with actual question count
            wrapper.config.hasAdditionalQuestions = !wrapper.registrantQuestions.isEmpty();

            // Initialize registration objects
            wrapper.primaryRegistration = new Registration();
            wrapper.primaryRegistration.registrationRecord = new Summit_Events_Registration__c();
            wrapper.primaryRegistration.appointments = new List<Summit_Events_Appointments__c>();
            wrapper.primaryRegistration.isGuest = false;
            wrapper.primaryRegistration.guestIndex = -1;
            wrapper.guestRegistrations = new List<Registration>();

            // Load existing registration if provided
            if (String.isNotBlank(registrationId)) {
                wrapper.encryptedRegistrationId = registrationId;
                String decryptedRegId = SummitEventsShared.decryptString(registrationId, true);

                if (String.isNotBlank(decryptedRegId)) {
                    Summit_Events_Registration__c existingReg = SummitEventsReadShared.getRegistrationById(decryptedRegId);
                    if (existingReg != null) {
                        wrapper.primaryRegistration.registrationRecord = existingReg;

                        // Load appointments
                        wrapper.primaryRegistration.appointments = SummitEventsReadShared.getAppointmentsByRegistrationId(decryptedRegId);

                        // Load fees
                        wrapper.fees = SummitEventsReadShared.getFeesByRegistrationId(decryptedRegId);
                        wrapper.totalEventCost = calculateTotalCost(wrapper.fees);

                        // Parse guest registrations from JSON
                        if (String.isNotBlank(existingReg.Guest_JSON__c)) {
                            wrapper.guestRegistrations = parseGuestRegistrations(existingReg.Guest_JSON__c);
                        }

                        // Update question wrappers with current values from registration
                        wrapper.registrantQuestions = buildQuestionWrappers(registrantQuestionMap, existingReg);
                    }
                }
            } else {
                // Set default values for new registration
                wrapper.primaryRegistration.registrationRecord.Event__c = eventId;
                wrapper.primaryRegistration.registrationRecord.Event_Instance__c = eventInstanceId;
                wrapper.fees = new List<Summit_Events_Fee__c>();
                wrapper.totalEventCost = 0;
            }

            // Build page flow
            wrapper.pages = buildPageInfo(wrapper.eventInfo, wrapper.instance, wrapper.config);
            wrapper.currentPageIndex = 0;

            // Build recaptcha info if configured
            wrapper.recaptcha = buildRecaptchaInfo(wrapper.eventInfo);

        } catch (Exception e) {
            System.debug('Error in getSummitEventData: ' + e.getMessage());
            throw new AuraHandledException('Error loading event data: ' + e.getMessage());
        }

        return wrapper;
    }

    private static EventConfiguration buildEventConfiguration(Summit_Events__c eventInfo, Map<Id, Summit_Events_Appointment_Type__c> appointmentTypes) {
        EventConfiguration config = new EventConfiguration();

        // Check for appointments
        config.hasAppointments = appointmentTypes != null && !appointmentTypes.isEmpty();

        // Guest registration
        config.hasGuestRegistration = eventInfo.Display_Guest_Registration__c;
        config.maxGuests = eventInfo.Guest_Max_Amount__c != null ? eventInfo.Guest_Max_Amount__c.intValue() : 0;

        // Donations and fees
        config.hasDonations = eventInfo.Display_Optional_Donation__c;
        config.hasEventFee = eventInfo.Event_Fee__c != null && eventInfo.Event_Fee__c > 0;

        // Questions about registrant - these are picklist fields, check if not 'Do not ask'
        config.askThirdPartyRegistrant = eventInfo.Ask_Third_Party_Registrant__c != 'Do not ask' && eventInfo.Ask_Third_Party_Registrant__c != null;
        config.askPreferredName = eventInfo.Ask_Preferred_First_Name__c != 'Do not ask' && eventInfo.Ask_Preferred_First_Name__c != null;
        config.askDateOfBirth = eventInfo.Ask_Date_Of_Birth__c != 'Do not ask' && eventInfo.Ask_Date_Of_Birth__c != null;
        config.askGender = eventInfo.Ask_Gender__c != 'Do not ask' && eventInfo.Ask_Gender__c != null;
        config.askPronoun = eventInfo.Ask_Pronoun__c != 'Do not ask' && eventInfo.Ask_Pronoun__c != null;
        config.askMailingAddress = eventInfo.Ask_Mailing_Address__c != 'Do not ask' && eventInfo.Ask_Mailing_Address__c != null;
        config.askPhone = eventInfo.Ask_Phone__c != 'Do not ask' && eventInfo.Ask_Phone__c != null;
        config.askCompanyOrganization = eventInfo.Ask_Company_Organization__c != 'Do not ask' && eventInfo.Ask_Company_Organization__c != null;
        config.askTitle = eventInfo.Ask_Title__c != 'Do not ask' && eventInfo.Ask_Title__c != null;
        config.askDietaryRestrictions = eventInfo.Ask_Dietary_Restrictions__c != 'Do not ask' && eventInfo.Ask_Dietary_Restrictions__c != null;
        config.askAccessibilityNeeds = eventInfo.Ask_Accessibility_Needs__c != 'Do not ask' && eventInfo.Ask_Accessibility_Needs__c != null;

        return config;
    }

    private static List<SummitEventsQuestionWrapper> buildQuestionWrappers(
        Map<Id, Summit_Events_Question__c> questionMap,
        Summit_Events_Registration__c registration
    ) {
        List<SummitEventsQuestionWrapper> wrappers = new List<SummitEventsQuestionWrapper>();

        if (questionMap == null || questionMap.isEmpty()) {
            return wrappers;
        }

        for (Summit_Events_Question__c question : questionMap.values()) {
            SummitEventsQuestionWrapper wrapper = new SummitEventsQuestionWrapper();

            // Basic fields
            wrapper.questionId = SummitEventsShared.encryptString(question.Id);
            wrapper.questionLabel = question.Question_Label__c;
            wrapper.questionFieldType = question.Question_Field_Type__c;
            wrapper.helpText = question.Help_Text__c;
            wrapper.instructions = question.Instructions__c;
            wrapper.errorAssistText = question.Error_Assist_Text__c;
            wrapper.mapToField = question.Map_to_Field__c;
            wrapper.defaultValue = question.Default_Value__c;
            wrapper.required = question.Required__c;
            wrapper.isVisible = question.Is_Visible__c;
            wrapper.displayOrder = question.Display_Order__c != null ? question.Display_Order__c.intValue() : 0;
            wrapper.textLimit = question.Text_Limit__c != null ? question.Text_Limit__c.intValue() : null;
            wrapper.displayStyle = question.Display_Style__c;
            wrapper.registrantType = question.Registrant_Type__c;

            // Picklist values
            if (String.isNotBlank(question.Existing_Picklist_Values__c)) {
                wrapper.existingPicklistField = question.Existing_Picklist_Values__c;
                wrapper.picklistValues = buildPicklistFromField(question.Existing_Picklist_Values__c);
            } else if (String.isNotBlank(question.Picklist_Values__c) || String.isNotBlank(question.Picklist_Values_Long__c)) {
                wrapper.picklistValues = buildPicklistFromString(question.Picklist_Values__c, question.Picklist_Values_Long__c);
            }

            // Lookup fields
            wrapper.lookupObject = question.Lookup_Object__c;
            wrapper.lookupFields = question.Lookup_Fields__c;
            wrapper.lookupWhereClause = question.Lookup_Where_Clause__c;
            wrapper.lookupOrderBy = question.Lookup_Order_By__c;
            wrapper.lookupIcon = String.isNotBlank(question.Lookup_Results_Icon__c) ? question.Lookup_Results_Icon__c : 'account';
            wrapper.lookupNoResultsLabel = String.isNotBlank(question.Lookup_No_Results_Label__c) ? question.Lookup_No_Results_Label__c : 'No results found.';
            wrapper.lookupSecondaryInputLinkText = String.isNotBlank(question.Lookup_Secondary_Input_Link_Text__c) ? question.Lookup_Secondary_Input_Link_Text__c : 'Manually enter information.';
            wrapper.lookupSecondaryInputInstructions = question.Lookup_Secondary_Input_Instructions__c;
            wrapper.lookupSecondaryValueField = question.Lookup_Secondary_Value_Field__c;

            // Controlling logic
            wrapper.controllingQuestion = question.Controlling_Question__c;
            wrapper.controllingLogic = question.Controlling_Logic__c;

            // Get current value from registration if available
            if (registration != null && String.isNotBlank(question.Map_to_Field__c)) {
                wrapper.currentValue = getFieldValue(registration, question.Map_to_Field__c);
            }

            wrappers.add(wrapper);
        }

        return wrappers;
    }

    private static List<PicklistOption> buildPicklistFromField(String fieldName) {
        List<PicklistOption> options = new List<PicklistOption>();

        try {
            String namespace = SummitEventsNamespace.StrTokenNSPrefix('');
            String objectName = namespace + 'Summit_Events_Registration__c';

            // Add namespace if needed for packaged fields
            List<String> packagedFields = new List<String>{
                'Registrant_Third_Party_Status__c',
                'Registrant_State_Global__c',
                'Registrant_Country__c',
                'Registrant_Pronouns__c',
                'Registrant_Applicant_Type__c',
                'Preferred_Visit_Time__c',
                'Registrant_Gender__c'
            };

            String fullFieldName = fieldName;
            if (String.isNotBlank(namespace) && packagedFields.contains(fieldName)) {
                fullFieldName = namespace + fieldName;
            }

            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            if (objType != null) {
                Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fullFieldName).getDescribe();

                for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                    if (entry.isActive()) {
                        PicklistOption option = new PicklistOption();
                        option.label = entry.getLabel();
                        option.value = entry.getValue();
                        options.add(option);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error building picklist from field: ' + e.getMessage());
        }

        return options;
    }

    private static List<PicklistOption> buildPicklistFromString(String picklistValues, String picklistValuesLong) {
        List<PicklistOption> options = new List<PicklistOption>();

        String values = String.isNotBlank(picklistValuesLong) ? picklistValuesLong : picklistValues;
        if (String.isBlank(values)) {
            return options;
        }

        List<String> valueList = values.split('\n');
        for (String value : valueList) {
            value = value.trim();
            if (String.isNotBlank(value)) {
                PicklistOption option = new PicklistOption();

                // Check if value has label|value format
                if (value.contains('|')) {
                    List<String> parts = value.split('\\|', 2);
                    option.label = parts[0].trim();
                    option.value = parts.size() > 1 ? parts[1].trim() : parts[0].trim();
                } else {
                    option.label = value;
                    option.value = value;
                }

                options.add(option);
            }
        }

        return options;
    }

    private static Object getFieldValue(Summit_Events_Registration__c registration, String fieldName) {
        try {
            if (registration == null || String.isBlank(fieldName)) {
                return null;
            }

            String namespace = SummitEventsNamespace.StrTokenNSPrefix('');
            String fullFieldName = fieldName.toLowerCase();

            // Build dynamic SOQL to get the field value
            String query = 'SELECT ' + String.escapeSingleQuotes(fullFieldName) +
                          ' FROM ' + namespace + 'Summit_Events_Registration__c WHERE Id = :registration.Id LIMIT 1';

            SObject result = Database.query(query);
            return result.get(fullFieldName);
        } catch (Exception e) {
            System.debug('Error getting field value: ' + e.getMessage());
            return null;
        }
    }


    private static List<PageInfo> buildPageInfo(Summit_Events__c eventInfo, Summit_Events_Instance__c eventInstance, EventConfiguration config) {
        List<PageInfo> pages = new List<PageInfo>();
        Integer pageIndex = 0;

        // Page 1: Registration (always present)
        PageInfo registerPage = new PageInfo();
        registerPage.pageType = 'register';
        registerPage.pageIndex = pageIndex++;
        registerPage.pageName = 'Registration';
        registerPage.pageMetaTitle = eventInfo.Event_Home_Link_Title__c;
        registerPage.pageHeading = eventInfo.Event_Name__c;
        registerPage.pageSubheading = eventInstance.Instance_Title__c;
        registerPage.pageDescription = eventInfo.Event_Full_Text__c;
        registerPage.isActive = true;
        pages.add(registerPage);

        // Page 2: Additional Questions (if configured)
        if (config.hasAdditionalQuestions) {
            PageInfo questionsPage = new PageInfo();
            questionsPage.pageType = 'questions';
            questionsPage.pageIndex = pageIndex++;
            questionsPage.pageName = 'Additional Questions';
            questionsPage.pageMetaTitle = eventInfo.Event_Home_Link_Title__c;
            questionsPage.pageHeading = String.isNotBlank(eventInfo.Event_Additional_Question_Title__c) ?
                eventInfo.Event_Additional_Question_Title__c : 'Additional Questions';
            questionsPage.pageDescription = eventInfo.Event_Additional_Questions_Description__c;
            questionsPage.isActive = false;
            pages.add(questionsPage);
        }

        // Page 3: Appointments (if configured)
        if (config.hasAppointments) {
            PageInfo appointmentsPage = new PageInfo();
            appointmentsPage.pageType = 'appointments';
            appointmentsPage.pageIndex = pageIndex++;
            appointmentsPage.pageName = 'Appointments';
            appointmentsPage.pageMetaTitle = eventInfo.Event_Home_Link_Title__c;
            appointmentsPage.pageHeading = String.isNotBlank(eventInfo.Event_Appointment_Title__c) ?
                eventInfo.Event_Appointment_Title__c : 'Choose Your Appointments';
            appointmentsPage.pageDescription = eventInfo.Event_Appointment_Description__c;
            appointmentsPage.isActive = false;
            pages.add(appointmentsPage);
        }

        // Page 4: Guest Registration (if configured)
        if (config.hasGuestRegistration && config.maxGuests > 0) {
            PageInfo guestsPage = new PageInfo();
            guestsPage.pageType = 'guests';
            guestsPage.pageIndex = pageIndex++;
            guestsPage.pageName = 'Guest Registration';
            guestsPage.pageMetaTitle = eventInfo.Event_Home_Link_Title__c;
            guestsPage.pageHeading = String.isNotBlank(eventInfo.Guest_Registration_Title__c) ?
                eventInfo.Guest_Registration_Title__c : 'Guest Registration';
            guestsPage.pageDescription = eventInfo.Guest_Registration_Description__c;
            guestsPage.isActive = false;
            pages.add(guestsPage);
        }

        // Page 5: Donation (if configured)
        if (config.hasDonations) {
            PageInfo donationPage = new PageInfo();
            donationPage.pageType = 'donation';
            donationPage.pageIndex = pageIndex++;
            donationPage.pageName = 'Donation';
            donationPage.pageMetaTitle = eventInfo.Event_Home_Link_Title__c;
            donationPage.pageHeading = String.isNotBlank(eventInfo.Donation_Title__c) ?
                eventInfo.Donation_Title__c : 'Optional Donation';
            donationPage.pageDescription = eventInfo.Donation_Description__c;
            donationPage.isActive = false;
            pages.add(donationPage);
        }

        // Page 6: Submit/Review (always present)
        PageInfo submitPage = new PageInfo();
        submitPage.pageType = 'submit';
        submitPage.pageIndex = pageIndex++;
        submitPage.pageName = 'Review & Submit';
        submitPage.pageMetaTitle = eventInfo.Event_Home_Link_Title__c;
        submitPage.pageHeading = String.isNotBlank(eventInfo.Event_Submit_Title__c) ?
            eventInfo.Event_Submit_Title__c : 'Review and Submit';
        submitPage.pageDescription = eventInfo.Event_Submit_Description__c;
        submitPage.isActive = false;
        pages.add(submitPage);

        // Page 7: Confirmation (shown after submit)
        PageInfo confirmationPage = new PageInfo();
        confirmationPage.pageType = 'confirmation';
        confirmationPage.pageIndex = pageIndex++;
        confirmationPage.pageName = 'Confirmation';
        confirmationPage.pageMetaTitle = eventInfo.Event_Home_Link_Title__c;
        confirmationPage.pageHeading = String.isNotBlank(eventInfo.Event_Confirmation_Title__c) ?
            eventInfo.Event_Confirmation_Title__c : 'Registration Confirmed';
        confirmationPage.pageDescription = eventInfo.Event_Confirmation_Description__c;
        confirmationPage.isActive = false;
        pages.add(confirmationPage);

        return pages;
    }

    private static RecaptchaInfo buildRecaptchaInfo(Summit_Events__c eventInfo) {
        RecaptchaInfo recaptcha = new RecaptchaInfo();

        if (String.isNotBlank(eventInfo.reCAPTCHA__c)) {
            Summit_Events_Settings__c settings = Summit_Events_Settings__c.getOrgDefaults();
            if (settings != null) {
                if (eventInfo.reCAPTCHA__c.contains('v3')) {
                    recaptcha.version = 3;
                    recaptcha.publicKey = settings.reCAPTCHA_Site_Key__c;
                    recaptcha.apiUrl = settings.reCAPTCHA_Library_Url__c;
                    recaptcha.failScore = eventInfo.reCAPTCHA_v3_Score_Fail_Text__c != null ?
                        Decimal.valueOf(eventInfo.reCAPTCHA_v3_Score_Fail_Text__c) : 0.5;
                } else if (eventInfo.reCAPTCHA__c.contains('v2')) {
                    recaptcha.version = 2;
                    recaptcha.publicKey = settings.reCAPTCHA_Site_Key__c;
                    recaptcha.apiUrl = settings.reCAPTCHA_Library_Url__c;
                }
            }
        }

        return recaptcha;
    }

    private static Decimal calculateTotalCost(List<Summit_Events_Fee__c> fees) {
        Decimal total = 0;

        if (fees != null) {
            for (Summit_Events_Fee__c fee : fees) {
                if (fee.Event_Fee__c != null) {
                    total += fee.Event_Fee__c;
                }
            }
        }

        return total;
    }

    private static List<Registration> parseGuestRegistrations(String guestJson) {
        List<Registration> guestRegistrations = new List<Registration>();

        try {
            if (String.isNotBlank(guestJson)) {
                List<Object> guestList = (List<Object>) JSON.deserializeUntyped(guestJson);
                Integer guestIndex = 0;

                for (Object guestObj : guestList) {
                    Map<String, Object> guestMap = (Map<String, Object>) guestObj;
                    Registration guestReg = new Registration();
                    guestReg.isGuest = true;
                    guestReg.guestIndex = guestIndex++;

                    // Build a registration record from the JSON data
                    Summit_Events_Registration__c guestRecord = new Summit_Events_Registration__c();

                    // Map common fields from JSON to registration object
                    if (guestMap.containsKey('firstName')) {
                        guestRecord.Registrant_First_Name__c = (String) guestMap.get('firstName');
                    }
                    if (guestMap.containsKey('lastName')) {
                        guestRecord.Registrant_Last_Name__c = (String) guestMap.get('lastName');
                    }
                    if (guestMap.containsKey('email')) {
                        guestRecord.Registrant_Email__c = (String) guestMap.get('email');
                    }

                    guestReg.registrationRecord = guestRecord;
                    guestReg.appointments = new List<Summit_Events_Appointments__c>();
                    guestRegistrations.add(guestReg);
                }
            }
        } catch (Exception e) {
            System.debug('Error parsing guest registrations: ' + e.getMessage());
        }

        return guestRegistrations;
    }

    // Save registration data
    @AuraEnabled
    public static String saveRegistration(String wrapperJson) {
        try {
            SummitEventWrapper wrapper = (SummitEventWrapper) JSON.deserialize(wrapperJson, SummitEventWrapper.class);

            // Use the registration CRUD class for without sharing operations
            RegistrationCRUD crud = new RegistrationCRUD();
            String registrationId = crud.saveRegistration(wrapper.primaryRegistration.registrationRecord);

            // Return encrypted registration ID
            return SummitEventsShared.encryptString(registrationId);
        } catch (Exception e) {
            throw new AuraHandledException('Error saving registration: ' + e.getMessage());
        }
    }

    // Lookup search for question lookup fields
    @AuraEnabled(Cacheable=false)
    public static List<LookupSearchResult> lookupSearch(String questionId, String searchTerm) {
        try {
            String decryptedQuestionId = SummitEventsShared.decryptString(questionId, true);
            Summit_Events_Question__c question = [
                SELECT Lookup_Object__c, Lookup_Fields__c, Lookup_Where_Clause__c, Lookup_Order_By__c
                FROM Summit_Events_Question__c
                WHERE Id = :decryptedQuestionId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            LookupCRUD lookupCrud = new LookupCRUD();
            return lookupCrud.search(
                question.Lookup_Object__c,
                question.Lookup_Fields__c,
                question.Lookup_Where_Clause__c,
                question.Lookup_Order_By__c,
                searchTerm
            );
        } catch (Exception e) {
            throw new AuraHandledException('Error searching: ' + e.getMessage());
        }
    }

    public class LookupSearchResult {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String subtitle { get; set; }
        @AuraEnabled public String icon { get; set; }
    }

    // Without sharing class for registration CRUD
    private without sharing class RegistrationCRUD {
        public String saveRegistration(Summit_Events_Registration__c registration) {
            if (registration.Id == null) {
                insert registration;
            } else {
                update registration;
            }
            return registration.Id;
        }
    }

    // Without sharing class for lookup operations
    private without sharing class LookupCRUD {
        public List<LookupSearchResult> search(
            String objectName,
            String fields,
            String whereClause,
            String orderBy,
            String searchTerm
        ) {
            List<LookupSearchResult> results = new List<LookupSearchResult>();

            // Build and execute dynamic query
            List<String> fieldList = String.isNotBlank(fields) ? fields.split(',') : new List<String>{'Name'};
            String query = 'SELECT Id, ' + String.join(fieldList, ', ') + ' FROM ' + objectName;

            if (String.isNotBlank(searchTerm)) {
                query += ' WHERE ' + fieldList[0] + ' LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
                if (String.isNotBlank(whereClause)) {
                    query += ' AND (' + whereClause + ')';
                }
            } else if (String.isNotBlank(whereClause)) {
                query += ' WHERE ' + whereClause;
            }

            if (String.isNotBlank(orderBy)) {
                query += ' ' + orderBy;
            }

            query += ' LIMIT 50';

            for (SObject record : Database.query(query)) {
                LookupSearchResult result = new LookupSearchResult();
                result.id = (String) record.get('Id');
                result.title = (String) record.get(fieldList[0]);
                result.subtitle = fieldList.size() > 1 ? (String) record.get(fieldList[1]) : '';
                result.icon = 'standard:' + objectName.toLowerCase();
                results.add(result);
            }

            return results;
        }
    }

}
