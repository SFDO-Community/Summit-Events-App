import { LightningElement, api } from 'lwc';

export default class SummitEventsGuestsPage extends LightningElement {
    @api eventData;

    @api validate() { return true; }
    @api getData() { return {}; }
}

