import { LightningElement, api } from 'lwc';

export default class InputTime extends LightningElement {
    @api fieldValue;
    @api fieldLabel;
    @api required; 
    @api minTime;
    @api maxTime;
    @api placeholder;
    @api timeStyle;
    @api helpText;

    connectedCallback() {
        this.validity=true;
    }

    handleChange(event) {
        this.fieldValue = event.target.value;
    }
}