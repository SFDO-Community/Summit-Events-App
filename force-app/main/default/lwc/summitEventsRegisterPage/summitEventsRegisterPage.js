import { LightningElement, api, track } from 'lwc';

// Ported verbatim from the VF page's static resource register.js RFIStates: maps state/
// province codes to the full names Nominatim (OpenStreetMap) returns, so fillInCityStateOnZip
// can translate a lookup result back into the code the picklist/free-text field expects.
const RFI_STATES = {
    'AL': 'Alabama',
    'AK': 'Alaska',
    'AZ': 'Arizona',
    'AR': 'Arkansas',
    'CA': 'California',
    'CO': 'Colorado',
    'CT': 'Connecticut',
    'DE': 'Delaware',
    'FL': 'Florida',
    'GA': 'Georgia',
    'HI': 'Hawaii',
    'ID': 'Idaho',
    'IL': 'Illinois',
    'IN': 'Indiana',
    'IA': 'Iowa',
    'KS': 'Kansas',
    'KY': 'Kentucky',
    'LA': 'Louisiana',
    'ME': 'Maine',
    'MD': 'Maryland',
    'MA': 'Massachusetts',
    'MI': 'Michigan',
    'MN': 'Minnesota',
    'MS': 'Mississippi',
    'MO': 'Missouri',
    'MT': 'Montana',
    'NE': 'Nebraska',
    'NV': 'Nevada',
    'NH': 'New Hampshire',
    'NJ': 'New Jersey',
    'NM': 'New Mexico',
    'NY': 'New York',
    'NC': 'North Carolina',
    'ND': 'North Dakota',
    'OH': 'Ohio',
    'OK': 'Oklahoma',
    'OR': 'Oregon',
    'PA': 'Pennsylvania',
    'RI': 'Rhode Island',
    'SC': 'South Carolina',
    'SD': 'South Dakota',
    'TN': 'Tennessee',
    'TX': 'Texas',
    'UT': 'Utah',
    'VT': 'Vermont',
    'VA': 'Virginia',
    'WA': 'Washington',
    'WV': 'West Virginia',
    'WI': 'Wisconsin',
    'WY': 'Wyoming',
    'AB': 'Alberta',
    'AS': 'American Samoa',
    'BC': 'British Columbia',
    'DC': 'District of Columbia',
    'GU': 'Guam ',
    'MB': 'Manitoba',
    'NB': 'New Brunswick',
    'NL': 'Newfoundland and Labrador',
    'NS': 'Nova Scotia',
    'NT': 'Northwest Territories',
    'NU': 'Nunavut',
    'ON': 'Ontario',
    'PE': 'Prince Edward Island',
    'PR': 'Puerto Rico',
    'QC': 'Quebec',
    'SK': 'Saskatchewan',
    'VI': 'Virgin Islands',
    'YT': 'Yukon'
};

export default class SummitEventsRegisterPage extends LightningElement {
    @api eventData;

    @track registration = {};

    // 'mobile', 'home', or '' (undecided) - only meaningful when askPhoneMode is one of the
    // "with type" variants, where a single field toggles between Home/Mobile. See initializePhoneType.
    @track phoneType = '';

    // '', 'Primary Registrant', 'Parent/Guardian', 'Other', or 'Company Representative' - who is
    // filling out this registration. See Registrant_Third_Party_Status__c on the registration.
    @track thirdPartyStatus = '';

    // Debounce handle for fillInCityStateOnZip - not reactive state, just a timer id
    zipLookupTimeout;

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

    // Event Details / Event Cost - shown near the top of the page, mirroring
    // SummitEventsRegisterController's showLocation/totalEventCost sections
    get showLocation() {
        return this.config.showLocation;
    }

    get locationTitle() {
        return this.config.locationTitle;
    }

    get locationAddress() {
        return this.config.locationAddress;
    }

    get locationMapLink() {
        return this.config.locationMapLink;
    }

    get formattedLocationDate() {
        return this.eventData?.formattedNavDate;
    }

    get showEventCost() {
        return this.config.baseEventCost > 0;
    }

    get baseEventCost() {
        return this.config.baseEventCost;
    }

    get eventCostLabel() {
        return this.config.eventCostLabel || 'Event Cost';
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

    get countryOptions() {
        return this.config.countryOptions || [];
    }

    // Ported from SummitEventsRegisterController.getStateDD(): a country only gets a
    // dependent State/Province dropdown when it has 2+ defined states; lightning-input-address
    // only falls back to a free-text province field when province-options is undefined - an
    // empty array is still treated as "options provided" and stays in dropdown mode, so this
    // must return undefined (not []) for countries with no dependent states.
    get stateOptionsForCountry() {
        const byCountry = this.config.stateOptionsByCountry || {};
        const options = byCountry[this.registration.Registrant_Country__c];
        return options && options.length > 0 ? options : undefined;
    }

    get showStateDropdown() {
        return !!this.stateOptionsForCountry;
    }

    // VF stores the dropdown-selected state in Registrant_State__c, but a freetext-entered
    // state (0/1-state countries) in the separate Registrant_State_Province__c field - mirror
    // that split here since lightning-input-address only exposes a single "province" slot.
    get currentProvinceValue() {
        return this.showStateDropdown
            ? this.registration.Registrant_State__c
            : this.registration.Registrant_State_Province__c;
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

    get accessibilityOptions() {
        return this.config.accessibilityOptions || [];
    }

    get accessibilityDetailLabel() {
        return this.config.accessibilityDetailLabel || 'Accessibility Details';
    }

    // Ported from SummitEventsRegister.page: the Accessibility Details textarea only appears
    // when the picklist's value is literally 'Yes' - not a general "isAsked" boolean
    get showAccessibilityDetails() {
        return this.registration.Accessibility_Need__c === 'Yes';
    }

    get showApplicantType() {
        return this.config.askApplicantType;
    }

    get applicantTypeRequired() {
        return this.config.askApplicantTypeRequired || false;
    }

    get applicantTypeOptions() {
        return this.config.applicantTypeOptions || [];
    }

    get showPreferredClassYear() {
        return this.config.askPreferredClassYear;
    }

    get preferredClassYearRequired() {
        return this.config.askPreferredClassYearRequired || false;
    }

    get showRelationshipToInstitution() {
        return this.config.askRelationshipToInstitution;
    }

    get relationshipToInstitutionRequired() {
        return this.config.askRelationshipToInstitutionRequired || false;
    }

    get relationshipToInstitutionOptions() {
        return this.config.relationshipToInstitutionOptions || [];
    }

    // lightning-dual-listbox needs an array value; the field itself stores a ';'-delimited
    // string, matching how Salesforce natively stores MultiselectPicklist values
    get relationshipToInstitutionValue() {
        const raw = this.registration.Relationship_To_Institution__c;
        return raw ? raw.split(';') : [];
    }

    handleRelationshipToInstitutionChange(event) {
        this.registration.Relationship_To_Institution__c = event.detail.value.join(';');
    }

    get showLastNameAsStudent() {
        return this.config.askLastNameAsStudent;
    }

    get lastNameAsStudentRequired() {
        return this.config.askLastNameAsStudentRequired || false;
    }

    get lastNameAsStudentLabel() {
        return this.config.lastNameAsStudentLabel || 'Last Name as a Student';
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
        // Evaluate before mutating registration, so this reflects the country that was in
        // effect when lightning-input-address last rendered its province field.
        const wasDropdown = this.showStateDropdown;
        const previousZip = this.registration.Registrant_Zip__c;

        this.registration.Registrant_Street_1__c = event.detail.street;
        this.registration.Registrant_Street_2__c = event.detail.subpremise;
        this.registration.Registrant_City__c = event.detail.city;
        this.registration.Registrant_Country__c = event.detail.country;
        this.registration.Registrant_Zip__c = event.detail.postalCode;

        if (wasDropdown) {
            this.registration.Registrant_State__c = event.detail.province;
        } else {
            this.registration.Registrant_State_Province__c = event.detail.province;
        }

        // register.js only looks up on the zip field's native 'change' event (blur-only).
        // lightning-input-address's onchange fires on every keystroke instead, so debounce
        // here to get the same "only after the user pauses" behavior and avoid hammering the
        // Nominatim API on each character.
        if (event.detail.postalCode && event.detail.postalCode !== previousZip) {
            clearTimeout(this.zipLookupTimeout);
            this.zipLookupTimeout = setTimeout(() => {
                this.fillInCityStateOnZip(event.detail.postalCode);
            }, 500);
        }
    }

    // Ported from register.js fillInCityStateOnZip(): looks up city/state via the
    // OpenStreetMap Nominatim API when a postal code is entered, same as the VF registration
    // page. 5-digit numeric zips are queried as US zips regardless of the currently selected
    // country, matching the original script exactly.
    fillInCityStateOnZip(zip) {
        let url = 'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&addressdetails=1&postalcode=';
        if (zip.length === 5 && /^[0-9]+$/.test(zip)) {
            url += zip + '&country=united states';
        } else {
            url += zip;
        }

        fetch(url)
            .then((response) => response.json())
            .then((results) => {
                if (!results || results.length === 0) {
                    return;
                }
                const address = results[0].address || {};

                const city = address.city || address.hamlet || address.town || '';

                let state = address.state || address.county || '';
                for (const [code, name] of Object.entries(RFI_STATES)) {
                    if (name === state) {
                        state = code;
                        break;
                    }
                }

                // Enhancement beyond VF parity - register.js computes this same value but never
                // uses it. Only fill Country when it's blank; never override an explicit
                // selection the registrant already made. Must happen before the showStateDropdown
                // check below, since that depends on the (possibly just-filled) country.
                if (!this.registration.Registrant_Country__c && address.country_code) {
                    this.registration.Registrant_Country__c = address.country_code.toUpperCase();
                }

                this.registration.Registrant_City__c = city;
                if (this.showStateDropdown) {
                    this.registration.Registrant_State__c = state;
                } else {
                    this.registration.Registrant_State_Province__c = state;
                }
            })
            // eslint-disable-next-line no-console
            .catch((error) => console.error('Error looking up city/state for zip', error));
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

