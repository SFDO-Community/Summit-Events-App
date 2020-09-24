import {LightningElement} from 'lwc';

export default class EmailFormOverlay extends LightningElement {

    connectedCallback() {
        this.dispatchEvent(new CustomEvent('overlayloaded'));
    }
}