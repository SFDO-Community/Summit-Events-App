import { LightningElement, api, track } from 'lwc';

export default class CpeFlowStageProgressIndicator extends LightningElement {

    _builderContext;
    _values;
	_automaticOutputVariables;

    @api _type;

    errorMessage = '';

    @track inputValues = {
        // option: {value: null, valueDataType: null, isCollection: false, label: '', required: false},
        allStages: {value: null, valueDataType: null, isCollection: false, label: 'All Stages'},
        currentStage: {value: null, valueDataType: null, isCollection: false, label: 'Current Stage'},
        type: {value: null, valueDataType: null, isCollection: false, label: 'Type'},
        variant: {value: null, valueDataType: null, isCollection: false, label: 'Variant'},
        hasError: {value: null, valueDataType: null, isCollection: false, label: 'Has Error?'},
    };

    settigs = {
        inputAttributePrefix: 'select_',
    }

    typeOptions = [
        { label: 'Base (Circles)', value: 'base' },
        { label: 'Path (Chevrons)', value: 'path' },
    ];

    variantOptions= [
        { label: 'Base (Default)', value: 'base' },
        { label: 'Shade (Light Gray Border)', value: 'shaded' },
    ];

    @api get builderContext() {
        return this._builderContext;
    }

    set builderContext(value) {
        this._builderContext = value;
    }

    @api get inputVariables() {
        return this._values;
    }

    set inputVariables(value) {

        this._values = value;
        this.initializeValues();
    }

    @api get automaticOutputVariables () {
        return this._automaticOutputVariables;
    }

    set automaticOutputVariables (value) {
        this._automaticOutputVariables = value;
    }

    initializeValues(value) {
        if (this._values && this._values.length) {
            this._values.forEach(curInputParam => {
                if (curInputParam.name && this.inputValues[curInputParam.name]) {
                    this.inputValues[curInputParam.name].value = curInputParam.value;
                    this.inputValues[curInputParam.name].valueDataType = curInputParam.valueDataType;
                }
            });
        }
        // this.handleDefaultAttributes();
    }

    handleDefaultAttributes() {
        let isChanged = false;
        // if (this.isObject) {
        //     if (this.inputValues.useWhichObjectKeyForData.value !== defaults.fieldDescriptorValueAttribute) {
        //         this.inputValues.useWhichObjectKeyForData.value = defaults.fieldDescriptorValueAttribute;
        //         isChanged = true;
        //     }

        // } else {
        //     if (this.inputValues.useWhichObjectKeyForData.value !== defaults.defaultValueAttribute) {
        //         this.inputValues.useWhichObjectKeyForData.value = defaults.defaultValueAttribute;
        //         isChanged = true;
        //     }
        // }
        if (isChanged) {
            this.dispatchFlowValueChangeEvent(defaults.useWhichObjectKeyForData, this.inputValues.useWhichObjectKeyForData.value, defaults.typeString);
        }
    }

    get isBaseType() {
        if(this._type === 'base')
            return true;

        return this.inputValues.type === 'base';
    }

    handleTypeChange(event){
        this._type = event.detail.value;
        this.dispatchFlowValueChangeEvent('type', event.detail.value, 'String');
    }

    handleVariantChange(event){
        this.dispatchFlowValueChangeEvent('variant', event.detail.value, 'String');
    }

    handleFlowComboboxValueChange(event) {
        if (event.target && event.detail) {
            let curAttributeName = event.target.name.replace(this.settigs.inputAttributePrefix, '');
            let curAttributeValue = event.detail.newValue;
            let curAttributeType = event.detail.newValueDataType;
            this.dispatchFlowValueChangeEvent(curAttributeName, curAttributeValue, curAttributeType);
        }

    }

    dispatchFlowValueChangeEvent(id, newValue, newValueDataType) {
        const valueChangedEvent = new CustomEvent('configuration_editor_input_value_changed', {
            bubbles: true,
            cancelable: false,
            composed: true,
            detail: {
                name: id,
                newValue: newValue ? newValue : null,
                newValueDataType: newValueDataType
            }
        });
        this.dispatchEvent(valueChangedEvent);
    }

    @api
    validate() {
        const validity = [];
        // Do checks and assign error to this.errorMessage
        return validity;
    }

}