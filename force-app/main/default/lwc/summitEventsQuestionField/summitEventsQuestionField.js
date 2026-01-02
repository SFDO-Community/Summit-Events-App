import { LightningElement, api, track } from 'lwc';

export default class SummitEventsQuestionField extends LightningElement {
    @api question;

    @track inputValue;

    connectedCallback() {
        this.inputValue = this.question?.currentValue || this.question?.defaultValue || '';
    }

    // Field type detection
    get isText() {
        return this.question?.questionFieldType === 'Text';
    }

    get isTextArea() {
        return this.question?.questionFieldType === 'Text Area';
    }

    get isEmail() {
        return this.question?.questionFieldType === 'Email';
    }

    get isPhone() {
        return this.question?.questionFieldType === 'Phone';
    }

    get isNumber() {
        return this.question?.questionFieldType === 'Number';
    }

    get isDate() {
        return this.question?.questionFieldType === 'Date';
    }

    get isCheckbox() {
        return this.question?.questionFieldType === 'Checkbox';
    }

    get isPicklist() {
        return this.question?.questionFieldType === 'Picklist';
    }

    get isMultiPicklist() {
        return this.question?.questionFieldType === 'Multi-Select Picklist';
    }

    get isRadio() {
        return this.question?.questionFieldType === 'Radio';
    }

    get isLookup() {
        return this.question?.questionFieldType === 'Lookup';
    }

    // Field properties
    get label() {
        return this.question?.questionLabel;
    }

    get isRequired() {
        return this.question?.required || false;
    }

    get helpText() {
        return this.question?.helpText;
    }

    get maxLength() {
        return this.question?.textLimit;
    }

    get picklistOptions() {
        if (!this.question?.picklistValues) {
            return [];
        }
        return this.question.picklistValues.map(option => ({
            label: option.label,
            value: option.value
        }));
    }

    get radioOptions() {
        return this.picklistOptions;
    }

    handleInputChange(event) {
        this.inputValue = event.target.value;
        this.dispatchChangeEvent();
    }

    handleCheckboxChange(event) {
        this.inputValue = event.target.checked;
        this.dispatchChangeEvent();
    }

    handleLookupChange(event) {
        this.inputValue = event.detail.value;
        this.dispatchChangeEvent();
    }

    dispatchChangeEvent() {
        const changeEvent = new CustomEvent('questionchange', {
            detail: {
                fieldName: this.question.mapToField,
                value: this.inputValue
            }
        });
        this.dispatchEvent(changeEvent);
    }

    @api
    validate() {
        const input = this.template.querySelector('[data-input]');
        if (input && typeof input.reportValidity === 'function') {
            input.reportValidity();
            return input.checkValidity();
        }
        return true;
    }
}

