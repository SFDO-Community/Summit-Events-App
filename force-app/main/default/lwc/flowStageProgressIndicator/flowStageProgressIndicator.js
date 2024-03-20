import { LightningElement, api } from 'lwc';

export default class flowStageProgressIndicator extends LightningElement {
    @api steps;
    @api currentStep;
    @api type;
    @api variant;
    @api hasError;
}