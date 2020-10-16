import { LightningElement,wire } from 'lwc';
import { getSObjectValue } from '@salesforce/apex';
import getEmailTemplates from '@salesforce/apex/SummitEventsEmailUtil.getEmailTemplates';
import NAME_FIELD from '@salesforce/schema/EmailTemplate.Name';
export default class EmailTemplateSelector extends LightningElement {
    @wire(getEmailTemplates)
    templates;

    value = null;

    get options() {
        if (! this.templates || ! this.templates.data) {
            return [];
        }
        return this.templates.data.map(template=>({ label: getSObjectValue(template,NAME_FIELD), value: template.Id }));
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

}