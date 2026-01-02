import { LightningElement, api } from 'lwc';

export default class SummitEventsConfirmationPage extends LightningElement {
    @api eventData;

    get registrationId() {
        return this.eventData?.encryptedRegistrationId;
    }

    get eventName() {
        return this.eventData?.eventInfo?.Event_Name__c;
    }

    get instanceTitle() {
        return this.eventData?.instance?.Instance_Title__c;
    }

    get registrantName() {
        const reg = this.eventData?.primaryRegistration?.registrationRecord;
        return reg ? `${reg.Registrant_First_Name__c} ${reg.Registrant_Last_Name__c}` : '';
    }

    get registrantEmail() {
        return this.eventData?.primaryRegistration?.registrationRecord?.Registrant_Email__c;
    }

    @api
    validate() {
        return true; // No validation needed on confirmation page
    }

    @api
    getData() {
        return {}; // No data to return from confirmation page
    }
}

