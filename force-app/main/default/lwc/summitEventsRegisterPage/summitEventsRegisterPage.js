import { LightningElement, api, track } from 'lwc';

export default class SummitEventsRegisterPage extends LightningElement {
    @api eventData;

    @track registration = {};

    connectedCallback() {
        if (this.eventData?.primaryRegistration?.registrationRecord) {
            this.registration = { ...this.eventData.primaryRegistration.registrationRecord };
        }
    }

    get config() {
        return this.eventData?.config || {};
    }

    get eventInfo() {
        return this.eventData?.eventInfo || {};
    }

    // Field visibility
    get showThirdPartyRegistrant() {
        return this.config.askThirdPartyRegistrant;
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

    get showPhone() {
        return this.config.askPhone;
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
        return {
            primaryRegistration: {
                ...this.eventData.primaryRegistration,
                registrationRecord: this.registration
            }
        };
    }
}

