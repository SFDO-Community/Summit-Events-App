/**
 * Created by thad on 1/3/2026.
 */

import {LightningElement, api, track} from 'lwc';
import fetchRecords from '@salesforce/apex/SummitEventsLookupController.fetchRecords';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 500;

export default class SummitEventsLookup extends LightningElement {
@api helpText = "custom search lookup";
    @api label = "Parent Account";
    @api required;
    @api selectedIconName = "standard:account";
    @api objectLabel = "Account";
    @track recordsList = [];
    selectedRecordName;
    @track focusedIndex = -1; // Track focused option for keyboard navigation

    @api objectApiName = "Account";
    @api fieldApiName = "Name";
    @api otherFieldApiName = "Industry";
    @api searchString = "";
    @api selectedRecordId = "";
    @api parentRecordId;
    @api parentFieldApiName;
    @api recordTypeName;
    @api type;
    @api placeholder;

    @api
    checkValidity() {
        let isSelfValidated = false;
        isSelfValidated = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        return isSelfValidated;
    }

    preventClosingOfSearchPanel = false;

    get methodInput() {
        return {
            objectApiName: this.objectApiName,
            fieldApiName: this.fieldApiName,
            otherFieldApiName: this.otherFieldApiName,
            searchString: this.searchString,
            selectedRecordId: this.selectedRecordId,
            parentRecordId: this.parentRecordId,
            parentFieldApiName: this.parentFieldApiName,
            recordTypeName: this.recordTypeName,
            type: this.type
        };
    }

    get showRecentRecords() {
        if (!this.recordsList) {
            return false;
        }
        return this.recordsList.length > 0;
    }

    /**
     * Get records with focused state for display
     */
    get displayRecords() {
        return this.recordsList.map((rec, index) => ({
            ...rec,
            focused: index === this.focusedIndex,
            itemClass: index === this.focusedIndex
                ? 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta slds-has-focus'
                : 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta'
        }));
    }

    /**
     * Handle keyboard events for navigation
     */
    handleKeyDown(event) {
        const key = event.key;

        if (!this.showRecentRecords) return;

        switch (key) {
            case 'ArrowDown':
                event.preventDefault();
                if (this.focusedIndex < this.recordsList.length - 1) {
                    this.focusedIndex++;
                } else {
                    this.focusedIndex = 0; // Wrap to first
                }
                this._scrollToFocusedOption();
                break;
            case 'ArrowUp':
                event.preventDefault();
                if (this.focusedIndex > 0) {
                    this.focusedIndex--;
                } else {
                    this.focusedIndex = this.recordsList.length - 1; // Wrap to last
                }
                this._scrollToFocusedOption();
                break;
            case 'Enter':
                event.preventDefault();
                if (this.focusedIndex >= 0 && this.focusedIndex < this.recordsList.length) {
                    this._selectRecord(this.recordsList[this.focusedIndex]);
                }
                break;
            case 'Escape':
                event.preventDefault();
                this.recordsList = [];
                this.focusedIndex = -1;
                break;
            default:
                break;
        }
    }

    /**
     * Scroll to keep focused option visible
     */
    _scrollToFocusedOption() {
        setTimeout(() => {
            const listItems = this.template.querySelectorAll('.slds-listbox__item');
            if (listItems && listItems.length > this.focusedIndex && this.focusedIndex >= 0) {
                const focusedItem = listItems[this.focusedIndex];
                if (focusedItem) {
                    focusedItem.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
                }
            }
        }, 0);
    }

    /**
     * Select a record programmatically
     */
    _selectRecord(record) {
        this.selectedRecordId = record.id;
        if (record.subField) {
            this.selectedRecordName = record.mainField + ' - ' + record.subField;
        } else {
            this.selectedRecordName = record.mainField;
        }
        this.recordsList = [];
        this.focusedIndex = -1;

        // Creates the event
        const selectedEvent = new CustomEvent('valueselected', {
            detail: {
                mainField: record.mainField,
                subField: record.subField,
                id: record.id
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    //getting the default selected record
    connectedCallback() {
        if (this.selectedRecordId) {
            this.fetchSobjectRecords(true);
        }
    }

    //call the apex method
    fetchSobjectRecords(loadEvent) {
        fetchRecords({
            inputWrapper: this.methodInput
        }).then(result => {
            if (loadEvent && result) {
                this.selectedRecordName = result[0].mainField;
            } else if (result) {
                this.recordsList = JSON.parse(JSON.stringify(result));
                this.focusedIndex = -1; // Reset focused index when new results arrive
            } else {
                this.recordsList = [];
                this.focusedIndex = -1;
            }
        }).catch(error => {
            console.log(error);
        })
    }

    get isValueSelected() {
        return this.selectedRecordId;
    }

    //handler for calling apex when user change the value in lookup
    handleChange(event) {
        this.searchString = event.target.value;
        if (this.searchString.length > 2) {
            this.fetchSobjectRecords(false);
        }
    }

    //handler for clicking outside the selection panel
    handleBlur() {
        //this.recordsList = [];
        this.preventClosingOfSearchPanel = true;
    }

    handleFocus(event) {
        // this.recordsList = [];
        console.log('focused');
        event.querySelector('.slds-listbox__item').focus();
        this.preventClosingOfSearchPanel = true;
    }

    //handle the click inside the search panel to prevent it getting closed
    handleDivClick() {
        this.preventClosingOfSearchPanel = true;
    }

    //handler for deselection of the selected item
    handleCommit() {
        this.selectedRecordId = "";
        this.selectedRecordName = "";
    }

    //handler for selection of records from lookup result list
    handleSelect(event) {
        let selectedRecord = {
            mainField: event.currentTarget.dataset.mainfield,
            subField: event.currentTarget.dataset.subfield,
            id: event.currentTarget.dataset.id
        };
        this.selectedRecordId = selectedRecord.id;
        if (selectedRecord.subField) {
            this.selectedRecordName = selectedRecord.mainField + ' - ' + selectedRecord.subField;
        } else {
            this.selectedRecordName = selectedRecord.mainField;
        }
        this.recordsList = [];
        // Creates the event
        const selectedEvent = new CustomEvent('valueselected', {
            detail: selectedRecord
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    }

    //to close the search panel when clicked outside of search input
    handleInputBlur(event) {
        // Debouncing this method: Do not actually invoke the Apex call as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            if (!this.preventClosingOfSearchPanel) {
                this.recordsList = [];
            }
            this.preventClosingOfSearchPanel = false;
        }, DELAY);
    }
}