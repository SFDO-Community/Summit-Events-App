import { LightningElement,api } from 'lwc';

export default class Add2Calendar extends LightningElement {
    addToCalendarLink = "#";
    addToCalendarLinkClass = "slds-hide";
    @api
    addToCalendarPage;
    @api
    addToCalendarInstanceId;

    handleChange(event) {
        let index = event.srcElement.selectedIndex;
        this.addToCalendarLink = this.addToCalendarPage + "?instanceID=" + this.addToCalendarInstanceId;
        if (index > 0 && index < 6) { 
            this.addToCalendarLinkClass="slds-button slds-button_neutral";
            this.addToCalendarLink += ["","","&type=google","","&type=outlookweb","&type=yahoo"][index];
        } else {
            this.addToCalendarLink = "#";
            this.addToCalendarLinkClass = "slds-hide";
        }
    }
}