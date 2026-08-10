import { LightningElement, api, track } from 'lwc';

export default class SummitEventsRegisterPage extends LightningElement {
    @api eventData;

    @track registration = {};

    // 'mobile', 'home', or '' (undecided) - only meaningful when askPhoneMode is one of the
    // "with type" variants, where a single field toggles between Home/Mobile. See initializePhoneType.
    @track phoneType = '';

    // '', 'Primary Registrant', 'Parent/Guardian', 'Other', or 'Company Representative' - who is
    // filling out this registration. See Registrant_Third_Party_Status__c on the registration.
    @track thirdPartyStatus = '';

    connectedCallback() {
        if (this.eventData?.primaryRegistration?.registrationRecord) {
            this.registration = { ...this.eventData.primaryRegistration.registrationRecord };
        }
        this.initializePhoneType();
        this.thirdPartyStatus = this.registration.Registrant_Third_Party_Status__c || '';
    }

    // Ported from SummitEventsRegisterController's constructor: infer which type was previously
    // selected from which field has a value, so returning to this page keeps the right field visible.
    initializePhoneType() {
        const home = this.registration.Registrant_Phone__c;
        const mobile = this.registration.Registrant_Mobile_Phone__c;
        if (this.phoneHasType && mobile && !home) {
            this.phoneType = 'mobile';
        } else if (!mobile && home) {
            this.phoneType = 'home';
        } else {
            this.phoneType = '';
        }
    }

    get config() {
        return this.eventData?.config || {};
    }

    get eventInfo() {
        return this.eventData?.eventInfo || {};
    }

    // Third Party Registrant - ported from the "THIRD PARTY REGISTRANTS" block in
    // SummitEventsRegister.page. When configured, a person other than the registrant (a parent, or
    // someone registering on a company's/other's behalf) can submit the registration; their own
    // contact info is captured separately from the registrant's.
    get showThirdPartyRegistrant() {
        return this.config.askThirdPartyRegistrant;
    }

    get thirdPartyOptions() {
        return this.config.thirdPartyOptions || [];
    }

    get thirdPartyRegistrantLabel() {
        return this.eventInfo.Third_Party_Registrant_Label__c || 'I am the';
    }

    get showParentInfo() {
        return this.thirdPartyStatus === 'Parent/Guardian';
    }

    get showOtherInfo() {
        return Boolean(this.thirdPartyStatus)
            && this.thirdPartyStatus !== 'Primary Registrant'
            && this.thirdPartyStatus !== 'Parent/Guardian';
    }

    get showThirdPartyDetails() {
        return this.showParentInfo || this.showOtherInfo;
    }

    // VF only relabels the main Registrant fields "Registrant Information" once a third party
    // registrant question is configured at all - independent of what's currently selected
    get showRegistrantInfoHeading() {
        return this.config.askThirdPartyRegistrant;
    }

    get parentFirstNameLabel() {
        return 'Parent ' + this.firstNameLabel;
    }

    get parentLastNameLabel() {
        return 'Parent ' + this.lastNameLabel;
    }

    get parentEmailLabel() {
        return 'Parent ' + this.emailLabel;
    }

    get parentPhoneLabel() {
        return 'Parent ' + this.phoneLabel;
    }

    get relationshipLabel() {
        return this.eventInfo.Registrant_Relationship_Label__c || 'Relationship';
    }

    get showPreferredName() {
        return this.config.askPreferredName;
    }

    get showDateOfBirth() {
        return this.config.askDateOfBirth;
    }

    get showGender() {
        return this.config.askGender;
    }

    get showPronoun() {
        return this.config.askPronoun;
    }

    get showMailingAddress() {
        return this.config.askMailingAddress;
    }

    // Ask_Phone__c drives a lot of conditional structure - ported field-for-field from the
    // rendered= conditions in SummitEventsRegister.page (the phoneBlock section) for parity.
    get askPhoneMode() {
        return this.eventInfo.Ask_Phone__c || '';
    }

    get showPhoneSection() {
        return Boolean(this.askPhoneMode) && !this.askPhoneMode.startsWith('Do not');
    }

    get phoneHasType() {
        return this.askPhoneMode.includes('with type');
    }

    get phoneShowBothFixed() {
        return this.askPhoneMode.includes('home and mobile');
    }

    get phoneRequireOne() {
        return this.askPhoneMode.includes('require one');
    }

    get showHomePhone() {
        return this.phoneShowBothFixed || this.phoneType === 'home';
    }

    get showMobilePhone() {
        return this.phoneShowBothFixed
            || this.askPhoneMode === 'Ask mobile'
            || this.askPhoneMode === 'Ask mobile and require'
            || this.phoneType === 'mobile'
            || (this.phoneType === '' && this.phoneHasType);
    }

    get showPhoneTypeSelect() {
        return this.phoneHasType;
    }

    get homePhoneRequired() {
        return this.askPhoneMode === 'Ask with type require' || this.askPhoneMode === 'Ask home and mobile require both';
    }

    get mobilePhoneRequired() {
        return this.homePhoneRequired || this.askPhoneMode === 'Ask mobile and require';
    }

    get phoneTypeRequired() {
        return this.askPhoneMode === 'Ask with type require';
    }

    get homePhoneLabel() {
        // VF: no "Home " prefix while the type dropdown hasn't been resolved yet
        const prefix = (this.phoneHasType && this.phoneType === '') ? '' : 'Home ';
        return prefix + this.phoneLabel;
    }

    get mobilePhoneLabel() {
        // VF: no "Mobile " prefix under "with type" modes or plain "Ask mobile" - the field is
        // unambiguous on its own there
        const noPrefix = this.phoneHasType
            || this.askPhoneMode === 'Ask mobile'
            || (this.askPhoneMode === 'Ask mobile and require' && this.phoneType === '');
        return (noPrefix ? '' : 'Mobile ') + this.phoneLabel;
    }

    get phoneTypeLabel() {
        return this.eventInfo.Phone_Type_Label__c || 'Phone Type';
    }

    get phoneTypeOptions() {
        return [
            { label: 'Select...', value: '' },
            { label: 'Mobile', value: 'mobile' },
            { label: 'Home', value: 'home' }
        ];
    }

    get showReceiveTexts() {
        return (this.askPhoneMode.includes('mobile') || this.phoneType === 'mobile')
            && !this.eventInfo.Do_not_show_receive_text_question__c;
    }

    get receiveTextsLabel() {
        return this.eventInfo.Registrant_Receive_Texts_Label__c || 'I agree to receive text messages';
    }

    get showCompanyOrganization() {
        return this.config.askCompanyOrganization;
    }

    get showTitle() {
        return this.config.askTitle;
    }

    get showDietaryRestrictions() {
        return this.config.askDietaryRestrictions;
    }

    get showAccessibilityNeeds() {
        return this.config.askAccessibilityNeeds;
    }

    // Field required state - "Ask and require" is the only value that makes the field mandatory
    get preferredNameRequired() {
        return this.config.askPreferredNameRequired || false;
    }

    get dateOfBirthRequired() {
        return this.config.askDateOfBirthRequired || false;
    }

    get genderRequired() {
        return this.config.askGenderRequired || false;
    }

    get pronounRequired() {
        return this.config.askPronounRequired || false;
    }

    get mailingAddressRequired() {
        return this.config.askMailingAddressRequired || false;
    }

    get companyOrganizationRequired() {
        return this.config.askCompanyOrganizationRequired || false;
    }

    get titleRequired() {
        return this.config.askTitleRequired || false;
    }

    get dietaryRestrictionsRequired() {
        return this.config.askDietaryRestrictionsRequired || false;
    }

    get accessibilityNeedsRequired() {
        return this.config.askAccessibilityNeedsRequired || false;
    }

    // "Additional Information" section - free-form questions and built-in time frame/guest count
    // fields configured directly on the event, separate from the Additional Questions wizard step
    get hasAdditionalInfoSection() {
        return this.config.hasAdditionalInfoSection;
    }

    get includeTimeFrameList() {
        return this.config.includeTimeFrameList;
    }

    get allowOtherAttendees() {
        return this.config.allowOtherAttendees;
    }

    get timeFrameOptions() {
        return this.config.timeFrameOptions || [];
    }

    get guestAmountOptions() {
        return this.config.guestAmountOptions || [];
    }

    get additionalInfoQuestions() {
        return (this.config.additionalInfoQuestions || []).map(question => ({
            ...question,
            currentValue: this.registration[question.mapToField]
        }));
    }

    // Field labels (use custom labels if provided)
    get firstNameLabel() {
        return this.eventInfo.First_Name_Label__c || 'First Name';
    }

    get lastNameLabel() {
        return this.eventInfo.Last_Name_Label__c || 'Last Name';
    }

    get emailLabel() {
        return this.eventInfo.Email_Label__c || 'Email';
    }

    get phoneLabel() {
        return this.eventInfo.Phone_Label__c || 'Phone';
    }

    get mailingAddressLabel() {
        return this.eventInfo.Mailing_Address_Label__c || 'Mailing Address';
    }

    get preferredNameLabel() {
        return this.eventInfo.Preferred_First_Name_Label__c || 'Preferred First Name';
    }

    get dateOfBirthLabel() {
        return this.eventInfo.Date_Of_Birth_Label__c || 'Date of Birth';
    }

    get genderLabel() {
        return this.eventInfo.Gender_Label__c || 'Gender';
    }

    get pronounsLabel() {
        return this.eventInfo.Pronouns_Label__c || 'Pronouns';
    }

    get genderOptions() {
        return this.config.genderOptions || [];
    }

    get pronounOptions() {
        return this.config.pronounOptions || [];
    }

    get titleLabel() {
        return this.eventInfo.Title_Label__c || 'Title';
    }

    get companyOrganizationLabel() {
        return this.eventInfo.Company_Organization_Label__c || 'Company/Organization';
    }

    get dietaryRestrictionsLabel() {
        return this.eventInfo.Dietary_Restrictions_Label__c || 'Dietary Restrictions';
    }

    get accessibilityLabel() {
        return this.eventInfo.Accessibility_Label__c || 'Accessibility Needs';
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        const value = event.target.value;
        this.registration[field] = value;
    }

    handleThirdPartyChange(event) {
        this.thirdPartyStatus = event.detail.value;
        this.registration.Registrant_Third_Party_Status__c = this.thirdPartyStatus;
    }

    handleCheckboxChange(event) {
        const field = event.target.dataset.field;
        this.registration[field] = event.target.checked;
    }

    // Ported from register.js phoneTypeToggle/setOldPhoneValue: carry the typed number over to
    // whichever field the toggle switches to, instead of making the registrant retype it
    handlePhoneTypeChange(event) {
        const newType = event.detail.value;
        const carryoverValue = this.phoneType === 'home'
            ? this.registration.Registrant_Phone__c
            : this.registration.Registrant_Mobile_Phone__c;

        this.phoneType = newType;

        if (newType === 'mobile') {
            this.registration.Registrant_Mobile_Phone__c = carryoverValue;
            this.registration.Registrant_Phone__c = '';
        } else if (newType === 'home') {
            this.registration.Registrant_Phone__c = carryoverValue;
            this.registration.Registrant_Mobile_Phone__c = '';
        }
    }

    // Ported from register.js formatPhone(): 10-digit numbers become (XXX) XXX-XXXX; a leading
    // '+' is treated as international and left as +digits only; anything else is left as-is
    handlePhoneBlur(event) {
        const field = event.target.dataset.field;
        const rawValue = event.target.value;
        if (!rawValue) {
            return;
        }

        const isInternational = rawValue.startsWith('+');
        let digits = rawValue.replace(/\D/g, '');

        if (isInternational) {
            if (digits.startsWith('0')) {
                digits = digits.substring(1);
            }
            this.registration[field] = '+' + digits;
        } else {
            this.registration[field] = digits.replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
        }
    }

    handleAddressChange(event) {
        this.registration.Registrant_Street_1__c = event.detail.street;
        this.registration.Registrant_City__c = event.detail.city;
        this.registration.Registrant_State__c = event.detail.province;
        this.registration.Registrant_Postal_Code__c = event.detail.postalCode;
        this.registration.Registrant_Country__c = event.detail.country;
    }

    @api
    validate() {
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-input-address, lightning-combobox, lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        return allValid;
    }

    @api
    getData() {
        const registration = { ...this.registration };

        // Ported from SummitEventsRegisterController.saveContactRegistration: under "with type"
        // modes, blank out whichever field wasn't the selected type before it gets saved
        if (this.phoneType && this.phoneHasType) {
            if (this.phoneType === 'mobile') {
                registration.Registrant_Phone__c = '';
            } else if (this.phoneType === 'home') {
                registration.Registrant_Mobile_Phone__c = '';
            }
        }

        return {
            primaryRegistration: {
                ...this.eventData.primaryRegistration,
                registrationRecord: registration
            }
        };
    }
}

