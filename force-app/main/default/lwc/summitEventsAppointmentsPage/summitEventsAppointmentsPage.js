import { LightningElement, api } from 'lwc';

export default class SummitEventsAppointmentsPage extends LightningElement {
    @api eventData;

    @api
    validate() {
        return true;
    }

    @api
    getData() {
        return {};
    }
}

