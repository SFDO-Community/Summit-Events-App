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
        @AuraEnabled public DonationSelection donationSelection { get; set; }

        // Event crumb shown at the top of every wizard step - Event Name, Instance Title (if set), and the
        // formatted instance date/time range. See SummitEventsShared.navBreadcrumbBuilder for the date logic
        // (multi-day ranges, per-instance time zone display, etc.) - ported unchanged from the VF breadcrumb.
        @AuraEnabled public String formattedNavDate { get; set; }
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
        @AuraEnabled public Boolean askApplicantType { get; set; }
        @AuraEnabled public Boolean askPreferredClassYear { get; set; }
        @AuraEnabled public Boolean askRelationshipToInstitution { get; set; }
        @AuraEnabled public Boolean askLastNameAsStudent { get; set; }
        @AuraEnabled public Integer maxGuests { get; set; }

        // Event Details / Event Cost - shown near the top of the Register page, resolved from
        // instance-level overrides falling back to the event-level base value, mirroring
        // SummitEventsRegisterController's showLocation/totalEventCost logic.
        @AuraEnabled public Boolean showLocation { get; set; }
        @AuraEnabled public String locationTitle { get; set; }
        @AuraEnabled public String locationAddress { get; set; }
        @AuraEnabled public String locationMapLink { get; set; }
        @AuraEnabled public Decimal baseEventCost { get; set; }
        @AuraEnabled public String eventCostLabel { get; set; }

        // Whether each asked field is "Ask and require" (vs. optional "Ask") on the event config
        @AuraEnabled public Boolean askPreferredNameRequired { get; set; }
        @AuraEnabled public Boolean askDateOfBirthRequired { get; set; }
        @AuraEnabled public Boolean askGenderRequired { get; set; }
        @AuraEnabled public Boolean askPronounRequired { get; set; }
        @AuraEnabled public Boolean askMailingAddressRequired { get; set; }
        @AuraEnabled public Boolean askCompanyOrganizationRequired { get; set; }
        @AuraEnabled public Boolean askTitleRequired { get; set; }
        @AuraEnabled public Boolean askDietaryRestrictionsRequired { get; set; }
        @AuraEnabled public Boolean askAccessibilityNeedsRequired { get; set; }
        @AuraEnabled public Boolean askApplicantTypeRequired { get; set; }
        @AuraEnabled public Boolean askPreferredClassYearRequired { get; set; }
        @AuraEnabled public Boolean askRelationshipToInstitutionRequired { get; set; }
        @AuraEnabled public Boolean askLastNameAsStudentRequired { get; set; }

        // Options for the built-in registrant fields that are picklists on Summit_Events_Registration__c
        @AuraEnabled public List<PicklistOption> genderOptions { get; set; }
        @AuraEnabled public List<PicklistOption> pronounOptions { get; set; }
        @AuraEnabled public List<PicklistOption> applicantTypeOptions { get; set; }
        @AuraEnabled public List<PicklistOption> relationshipToInstitutionOptions { get; set; }
        @AuraEnabled public List<PicklistOption> accessibilityOptions { get; set; }
        @AuraEnabled public String lastNameAsStudentLabel { get; set; }
        @AuraEnabled public String accessibilityDetailLabel { get; set; }
        // Mailing address Country picklist, and its dependent State/Province options keyed by
        // country value. A country only appears in stateOptionsByCountry when it has 2+ defined
        // states/provinces - otherwise the page falls back to a free-text state field, matching
        // SummitEventsRegisterController.getStateDD()/getCountryDD().
        @AuraEnabled public List<PicklistOption> countryOptions { get; set; }
        @AuraEnabled public Map<String, List<PicklistOption>> stateOptionsByCountry { get; set; }
        // "Primary Registrant" + whichever of Parent/Guardian, Other, Company Representative the
        // event's Ask_Third_Party_Registrant__c multi-select picklist allows
        @AuraEnabled public List<PicklistOption> thirdPartyOptions { get; set; }

        // "Additional Information" section on the Register page - distinct from the separate
        // Additional Questions wizard step (Summit_Events_Question__c). Driven by the event's
        // Include_Time_frame_List__c / Allow_Other_Attendees__c / Add_Info_Question_*_N__c fields.
        @AuraEnabled public Boolean hasAdditionalInfoSection { get; set; }
        @AuraEnabled public Boolean includeTimeFrameList { get; set; }
        @AuraEnabled public Boolean allowOtherAttendees { get; set; }
        @AuraEnabled public List<PicklistOption> timeFrameOptions { get; set; }
        @AuraEnabled public List<PicklistOption> guestAmountOptions { get; set; }
        @AuraEnabled public List<AdditionalInfoQuestion> additionalInfoQuestions { get; set; }
    }

    public class AdditionalInfoQuestion {
        @AuraEnabled public String questionNumber { get; set; }
        @AuraEnabled public String questionText { get; set; }
        @AuraEnabled public String mapToField { get; set; }
        @AuraEnabled public Boolean required { get; set; }
        @AuraEnabled public Boolean isTextBox { get; set; }
        @AuraEnabled public Boolean isTextArea { get; set; }
        @AuraEnabled public Boolean isPicklist { get; set; }
        @AuraEnabled public List<PicklistOption> picklistOptions { get; set; }
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

    public class DonationSelection {
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public String allocationId { get; set; }
        @AuraEnabled public String existingFeeId { get; set; }
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
            wrapper.formattedNavDate = SummitEventsShared.navBreadcrumbBuilder(wrapper.instance);

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
            wrapper.config = buildEventConfiguration(wrapper.eventInfo, wrapper.instance, wrapper.appointmentTypes);

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

            // Initialize donation selection (populated from existing fees if re-loading)
            wrapper.donationSelection = new DonationSelection();
            if (wrapper.fees != null) {
                for (Summit_Events_Fee__c fee : wrapper.fees) {
                    if (fee.Event_Fee_Type__c == 'Optional Donation') {
                        wrapper.donationSelection.amount = fee.Event_Fee__c;
                        wrapper.donationSelection.allocationId = fee.Event_Fee_Allocation__c;
                        wrapper.donationSelection.existingFeeId = fee.Id;
                        break;
                    }
                }
            }

        } catch (Exception e) {
            System.debug('Error in getSummitEventData: ' + e.getMessage());
            throw new AuraHandledException('Error loading event data: ' + e.getMessage());
        }

        return wrapper;
    }

    private static EventConfiguration buildEventConfiguration(Summit_Events__c eventInfo, Summit_Events_Instance__c eventInstance, Map<Id, Summit_Events_Appointment_Type__c> appointmentTypes) {
        EventConfiguration config = new EventConfiguration();

        // Event Details - instance-level override falls back to the event-level base value
        config.locationTitle = String.isNotBlank(eventInstance.Location_Title_Override__c) ? eventInstance.Location_Title_Override__c : eventInfo.Location_Title__c;
        config.locationAddress = String.isNotBlank(eventInstance.Location_Address_Override__c) ? eventInstance.Location_Address_Override__c : eventInfo.Location_Address__c;
        config.locationMapLink = String.isNotBlank(eventInstance.Location_Map_Link_Override__c) ? eventInstance.Location_Map_Link_Override__c : eventInfo.Location_Map_Link__c;
        config.showLocation = String.isNotBlank(config.locationTitle) || String.isNotBlank(config.locationAddress) || String.isNotBlank(config.locationMapLink);

        // Event Cost - the event's base sticker price, separate from wrapper.totalEventCost (which
        // is the running total of actually-selected fees, used on the Submit/Review page)
        Decimal baseFee = eventInstance.Event_Fee_Override__c != null ? eventInstance.Event_Fee_Override__c : eventInfo.Event_Fee__c;
        Decimal additionalFee = eventInstance.Event_Fee_Additional_Override__c != null ? eventInstance.Event_Fee_Additional_Override__c : eventInfo.Event_Fee_Additional__c;
        config.baseEventCost = (baseFee != null ? baseFee : 0) + (additionalFee != null ? additionalFee : 0);
        config.eventCostLabel = String.isNotBlank(eventInfo.Event_Fee_Submit_List_Label__c) ? eventInfo.Event_Fee_Submit_List_Label__c : 'Event Cost';

        // Check for appointments
        config.hasAppointments = appointmentTypes != null && !appointmentTypes.isEmpty();

        // Guest registration
        config.hasGuestRegistration = eventInfo.Display_Guest_Registration__c;
        config.maxGuests = eventInfo.Guest_Max_Amount__c != null ? eventInfo.Guest_Max_Amount__c.intValue() : 0;

        // Donations and fees
        config.hasDonations = eventInfo.Display_Optional_Donation__c;
        config.hasEventFee = eventInfo.Event_Fee__c != null && eventInfo.Event_Fee__c > 0;

        // Ask_Third_Party_Registrant__c is a multi-select picklist (Parent/Guardian, Other, Company
        // Representative) - it has no 'Do not ask' value, so blank/null is the only "don't ask" state
        config.askThirdPartyRegistrant = String.isNotBlank(eventInfo.Ask_Third_Party_Registrant__c);
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
        config.askApplicantType = eventInfo.Ask_Applicant_Type__c != 'Do not ask' && eventInfo.Ask_Applicant_Type__c != null;
        config.askPreferredClassYear = eventInfo.Ask_Preferred_Class_Year__c != 'Do not ask' && eventInfo.Ask_Preferred_Class_Year__c != null;
        config.askRelationshipToInstitution = eventInfo.Ask_Relationship_To_Institution__c != 'Do not ask' && eventInfo.Ask_Relationship_To_Institution__c != null;
        config.askLastNameAsStudent = eventInfo.Ask_Last_Name_As_Student__c != 'Do not ask' && eventInfo.Ask_Last_Name_As_Student__c != null;

        // "Ask and require" is the only value on these fields that makes the field mandatory - "Ask" alone is optional
        config.askPreferredNameRequired = eventInfo.Ask_Preferred_First_Name__c == 'Ask and require';
        config.askDateOfBirthRequired = eventInfo.Ask_Date_Of_Birth__c == 'Ask and require';
        config.askGenderRequired = eventInfo.Ask_Gender__c == 'Ask and require';
        config.askPronounRequired = eventInfo.Ask_Pronoun__c == 'Ask and require';
        config.askMailingAddressRequired = eventInfo.Ask_Mailing_Address__c == 'Ask and require';
        config.askCompanyOrganizationRequired = eventInfo.Ask_Company_Organization__c == 'Ask and require';
        config.askTitleRequired = eventInfo.Ask_Title__c == 'Ask and require';
        config.askDietaryRestrictionsRequired = eventInfo.Ask_Dietary_Restrictions__c == 'Ask and require';
        config.askAccessibilityNeedsRequired = eventInfo.Ask_Accessibility_Needs__c == 'Ask and require';
        config.askApplicantTypeRequired = eventInfo.Ask_Applicant_Type__c == 'Ask and require';
        config.askPreferredClassYearRequired = eventInfo.Ask_Preferred_Class_Year__c == 'Ask and require';
        config.askRelationshipToInstitutionRequired = eventInfo.Ask_Relationship_To_Institution__c == 'Ask and require';
        config.askLastNameAsStudentRequired = eventInfo.Ask_Last_Name_As_Student__c == 'Ask and require';
        config.lastNameAsStudentLabel = eventInfo.Last_Name_As_Student_Label__c;

        if (config.askThirdPartyRegistrant) {
            config.thirdPartyOptions = buildThirdPartyOptions(eventInfo.Ask_Third_Party_Registrant__c);
        }
        if (config.askGender) {
            config.genderOptions = buildPicklistFromField('Registrant_Gender__c');
        }
        if (config.askPronoun) {
            config.pronounOptions = buildPicklistFromField('Registrant_Pronouns__c');
        }
        if (config.askMailingAddress) {
            config.countryOptions = buildPicklistFromField('Registrant_Country__c');
            config.stateOptionsByCountry = buildStateOptionsByCountry();
        }
        if (config.askApplicantType) {
            config.applicantTypeOptions = buildPicklistFromField('Registrant_Applicant_Type__c');
        }
        if (config.askRelationshipToInstitution) {
            config.relationshipToInstitutionOptions = buildPicklistFromField('Relationship_To_Institution__c');
        }
        if (config.askAccessibilityNeeds) {
            config.accessibilityOptions = buildPicklistFromField('Accessibility_Need__c');
            config.accessibilityDetailLabel = eventInfo.Accessibility_Detail_Label__c;
        }

        buildAdditionalInfoConfig(eventInfo, config);

        return config;
    }

    private static void buildAdditionalInfoConfig(Summit_Events__c eventInfo, EventConfiguration config) {
        config.includeTimeFrameList = eventInfo.Include_Time_frame_List__c == true;
        config.allowOtherAttendees = eventInfo.Allow_Other_Attendees__c == true;

        if (config.includeTimeFrameList) {
            config.timeFrameOptions = buildPicklistFromField('Preferred_Visit_Time__c');
        }

        if (config.allowOtherAttendees) {
            config.guestAmountOptions = new List<PicklistOption>();
            Integer maxOtherAttendees = eventInfo.Max_Other_Attendees__c != null ? eventInfo.Max_Other_Attendees__c.intValue() : 0;
            for (Integer i = 0; i <= maxOtherAttendees; i++) {
                config.guestAmountOptions.add(newPicklistOption(String.valueOf(i), String.valueOf(i)));
            }
        }

        config.additionalInfoQuestions = new List<AdditionalInfoQuestion>();
        for (Integer i = 1; i <= 5; i++) {
            String questionText = (String) eventInfo.get('Add_Info_Question_Text_' + i + '__c');
            String questionType = (String) eventInfo.get('Add_Info_Question_Type_' + i + '__c');
            if (String.isBlank(questionText) || String.isBlank(questionType)) {
                continue;
            }

            AdditionalInfoQuestion question = new AdditionalInfoQuestion();
            question.questionNumber = String.valueOf(i);
            question.questionText = questionText;
            question.mapToField = 'Add_Info_Answer_' + i + '__c';
            question.required = questionType.containsIgnoreCase('required');
            question.isTextBox = questionType.containsIgnoreCase('Text box');
            question.isTextArea = questionType.containsIgnoreCase('Text area');
            question.isPicklist = questionType.containsIgnoreCase('Pick-list');

            if (question.isPicklist) {
                String pickListValues = (String) eventInfo.get('Add_Info_Question_Pick_List_' + i + '__c');
                String pickListValuesLong = (String) eventInfo.get('Add_Info_Question_Pick_List_Long_' + i + '__c');
                question.picklistOptions = buildPicklistFromString(pickListValues, pickListValuesLong);
            }

            config.additionalInfoQuestions.add(question);
        }

        config.hasAdditionalInfoSection = config.includeTimeFrameList || config.allowOtherAttendees || !config.additionalInfoQuestions.isEmpty();
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

            // Lookup Picklist: options come from distinct records on a related object, not a static list
            if (String.isNotBlank(question.Question_Field_Type__c) && question.Question_Field_Type__c.equalsIgnoreCase('lookup picklist')) {
                wrapper.picklistValues = buildLookupPicklist(
                    question.Lookup_Object__c,
                    question.Lookup_Where_Clause__c,
                    question.Lookup_Fields__c,
                    question.Lookup_Order_By__c
                );
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

    // Ported from SummitEventsRegisterController.PickThePicklist's Registrant_Third_Party_Status__c
    // branch: "Primary Registrant" is always offered, then only whichever of the schema's other
    // picklist entries (Parent/Guardian, Other, Company Representative) the event's
    // Ask_Third_Party_Registrant__c multi-select picklist actually allows.
    private static List<PicklistOption> buildThirdPartyOptions(String allowedStatuses) {
        List<PicklistOption> options = new List<PicklistOption>();
        options.add(newPicklistOption('', 'Select...'));
        options.add(newPicklistOption('Primary Registrant', 'Primary Registrant'));

        for (PicklistOption entry : buildPicklistFromField('Registrant_Third_Party_Status__c')) {
            if (String.isNotBlank(entry.value) && allowedStatuses.contains(entry.value)) {
                options.add(entry);
            }
        }

        return options;
    }

    private static List<PicklistOption> buildPicklistFromField(String fieldName) {
        List<PicklistOption> options = new List<PicklistOption>();
        options.add(newPicklistOption('', 'Select...'));

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

    // Ported from SummitEventsRegisterController.getStateDD(): a country only gets a dependent
    // State/Province dropdown when it has 2+ defined states; countries with 0 or 1 fall back to
    // a free-text field in the LWC (Registrant_State_Province__c), same as the VF page.
    private static Map<String, List<PicklistOption>> buildStateOptionsByCountry() {
        Map<String, List<PicklistOption>> result = new Map<String, List<PicklistOption>>();

        Map<String, Map<String, String>> allDependencies = SummitEventsShared.getAllDependentSelectOptions(
            'Summit_Events_Registration__c', 'Registrant_Country__c', 'Registrant_State_Global__c'
        );

        for (String country : allDependencies.keySet()) {
            Map<String, String> states = allDependencies.get(country);
            if (states.size() > 1) {
                List<PicklistOption> options = new List<PicklistOption>();
                options.add(newPicklistOption('', 'Select...'));
                for (String stateValue : states.keySet()) {
                    options.add(newPicklistOption(stateValue, states.get(stateValue)));
                }
                result.put(country, options);
            }
        }

        return result;
    }

    private static PicklistOption newPicklistOption(String value, String label) {
        PicklistOption option = new PicklistOption();
        option.value = value;
        option.label = label;
        return option;
    }

    private static List<PicklistOption> buildPicklistFromString(String picklistValues, String picklistValuesLong) {
        List<PicklistOption> options = new List<PicklistOption>();
        options.add(newPicklistOption('', 'Select...'));

        List<String> valueList = new List<String>();
        if (String.isNotBlank(picklistValues)) {
            valueList.addAll(picklistValues.split('\n'));
        }
        if (String.isNotBlank(picklistValuesLong)) {
            valueList.addAll(picklistValuesLong.split('\n'));
        }

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

    // Lookup_Where_Clause__c / Lookup_Order_By__c are admin-authored SOQL fragments, so they can't be
    // escaped like guest input without breaking normal usage (e.g. Status__c = 'Active'). Instead this
    // blocks the constructs an admin-authored filter/order-by clause never legitimately needs: statement
    // separators, comments, and nested SELECTs (subquery-based data exfiltration beyond the target object).
    private static Boolean isSafeSoqlFragment(String fragment) {
        if (String.isBlank(fragment)) {
            return true;
        }
        String lower = fragment.toLowerCase();
        return !(lower.contains(';') || lower.contains('--') || lower.contains('/*') || lower.contains('select '));
    }

    private static List<PicklistOption> buildLookupPicklist(String objectName, String filterClause, String fields, String orderBy) {
        List<PicklistOption> options = new List<PicklistOption>();
        options.add(newPicklistOption('', 'Select...'));

        if (String.isBlank(objectName) || String.isBlank(fields)) {
            return options;
        }

        if (!isSafeSoqlFragment(filterClause) || !isSafeSoqlFragment(orderBy)) {
            return options;
        }

        Schema.DescribeSObjectResult objectDescribe;
        try {
            Schema.SObjectType lookupType = Schema.getGlobalDescribe().get(objectName.trim().toLowerCase());
            if (lookupType == null) {
                return options;
            }
            objectDescribe = lookupType.getDescribe();
        } catch (Exception e) {
            return options;
        }
        if (objectDescribe == null || !objectDescribe.isAccessible()) {
            return options;
        }

        List<String> validFieldNames = new List<String>();
        for (String fieldName : fields.split(',')) {
            fieldName = fieldName.trim();
            if (String.isNotBlank(fieldName)) {
                Schema.SObjectField fieldToken = objectDescribe.fields.getMap().get(fieldName);
                if (fieldToken != null && fieldToken.getDescribe().isAccessible()) {
                    validFieldNames.add(fieldName);
                }
            }
        }
        if (validFieldNames.isEmpty()) {
            return options;
        }

        String query = 'SELECT Id,' + String.join(validFieldNames, ',') + ' FROM ' + objectDescribe.getName();
        if (String.isNotBlank(filterClause)) {
            query += ' WHERE ' + filterClause;
        }
        query += String.isNotBlank(orderBy) ? ' ' + orderBy : ' ORDER BY ' + validFieldNames[0];

        List<SObject> results;
        try {
            results = Database.query(query);
        } catch (Exception e) {
            System.debug('Error building lookup picklist: ' + e.getMessage());
            return options;
        }

        for (SObject record : results) {
            List<String> parts = new List<String>();
            for (String fieldName : validFieldNames) {
                Object value = record.get(fieldName);
                if (value != null) {
                    parts.add(String.valueOf(value));
                }
            }
            if (!parts.isEmpty()) {
                PicklistOption option = new PicklistOption();
                option.value = (String) record.get('Id');
                option.label = String.join(parts, ' - ');
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
        registerPage.pageDescription = eventInfo.Event_description__c;
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
        if (config.hasGuestRegistration) {
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

    // Save registration data — handles registration record, appointments, guests, and donation fee
    @AuraEnabled
    public static String saveRegistration(String wrapperJson) {
       // try {
            SummitEventWrapper wrapper = (SummitEventWrapper) JSON.deserialize(wrapperJson, SummitEventWrapper.class);
            RegistrationCRUD crud = new RegistrationCRUD();

            // 1. Serialize guest registrations into Guest_JSON__c on the primary registration
            if (wrapper.guestRegistrations != null && !wrapper.guestRegistrations.isEmpty()) {
                List<Map<String, Object>> guestList = new List<Map<String, Object>>();
                for (Registration guest : wrapper.guestRegistrations) {
                    Map<String, Object> guestMap = new Map<String, Object>();
                    if (guest.registrationRecord != null) {
                        guestMap.put('firstName', guest.registrationRecord.Registrant_First_Name__c);
                        guestMap.put('lastName', guest.registrationRecord.Registrant_Last_Name__c);
                        guestMap.put('email', guest.registrationRecord.Registrant_Email__c);
                    }
                    guestList.add(guestMap);
                }
                wrapper.primaryRegistration.registrationRecord.Guest_JSON__c = JSON.serialize(guestList);
            }

            // 2. Save primary registration record
            String registrationId = crud.saveRegistration(wrapper.primaryRegistration.registrationRecord);
            Id regId = (Id) registrationId;

            // 3. Save appointments
            if (wrapper.primaryRegistration.appointments != null && !wrapper.primaryRegistration.appointments.isEmpty()) {
                List<Summit_Events_Appointments__c> aptsToSave = new List<Summit_Events_Appointments__c>();
                for (Summit_Events_Appointments__c apt : wrapper.primaryRegistration.appointments) {
                    apt.Event_Registration__c = regId;
                    aptsToSave.add(apt);
                }
                crud.upsertAppointments(aptsToSave);
            }

            // 4. Save optional donation fee
            if (wrapper.donationSelection != null
                && wrapper.donationSelection.amount != null
                && wrapper.donationSelection.amount > 0) {
                Summit_Events_Fee__c fee = new Summit_Events_Fee__c();
                if (String.isNotBlank(wrapper.donationSelection.existingFeeId)) {
                    fee.Id = wrapper.donationSelection.existingFeeId;
                }
                fee.Event_Fee__c = wrapper.donationSelection.amount;
                fee.Event_Fee_Allocation__c = wrapper.donationSelection.allocationId;
                fee.Event_Registration__c = regId;
                if (wrapper.eventInfo != null) {
                    fee.Summit_Events__c = wrapper.eventInfo.Id;
                }
                fee.Event_Fee_Type__c = 'Optional Donation';
                crud.upsertFee(fee);
            }

            return SummitEventsShared.encryptString(registrationId);
//        } catch (Exception e) {
//            throw new AuraHandledException('Error saving registration: ' + e.getMessage());
//        }
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
                Database.insert(registration, true, System.AccessLevel.SYSTEM_MODE);
            } else {
                Database.update(registration, true, System.AccessLevel.SYSTEM_MODE);
            }
            return registration.Id;
        }

        public void upsertAppointments(List<Summit_Events_Appointments__c> appointments) {
            List<Summit_Events_Appointments__c> toInsert = new List<Summit_Events_Appointments__c>();
            List<Summit_Events_Appointments__c> toUpdate = new List<Summit_Events_Appointments__c>();
            for (Summit_Events_Appointments__c apt : appointments) {
                if (apt.Id == null) {
                    toInsert.add(apt);
                } else {
                    toUpdate.add(apt);
                }
            }
            if (!toInsert.isEmpty()) {
                Database.insert(toInsert, true, System.AccessLevel.SYSTEM_MODE);
            }
            if (!toUpdate.isEmpty()) {
                Database.update(toUpdate, true, System.AccessLevel.SYSTEM_MODE);
            }
        }

        public void upsertFee(Summit_Events_Fee__c fee) {
            Database.upsert(fee, true, System.AccessLevel.SYSTEM_MODE);
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