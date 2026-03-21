import { LightningElement, api, track } from 'lwc';

export default class SummitEventsAppointmentsPage extends LightningElement {
    @api eventData;

    @track _selections = [];   // {typeId, title, category, chosenState, inputType, inputValue, canRemove}
    @track _inputValues = {};  // typeId → staged input value (before Add is clicked)
    @track validationError = '';

    _allTypes = [];  // flat array built once from appointmentTypes map

    connectedCallback() {
        const typesMap = this.eventData?.appointmentTypes || {};
        this._allTypes = Object.values(typesMap)
            .sort((a, b) => (a.Sort_Order__c || 0) - (b.Sort_Order__c || 0));

        const existingApts = this.eventData?.primaryRegistration?.appointments || [];
        if (existingApts.length > 0) {
            // Re-populate from saved registration
            this._selections = existingApts.map(apt => ({
                typeId: apt.Event_Appointment_Type__c,
                title: apt.Appointment_Title__c || '',
                category: apt.Appointment_Category__c || '',
                chosenState: apt.Chosen_State__c || '',
                inputType: '',
                inputValue: apt.Registrant_Input__c || '',
                canRemove: apt.Chosen_State__c !== 'Added and Required'
            }));
        } else {
            // Auto-add pre-selected types
            this._selections = this._allTypes
                .filter(t => t.Chosen_State__c)
                .map(t => ({
                    typeId: t.Id,
                    title: t.Title__c,
                    category: t.Appointment_Category__c || '',
                    chosenState: t.Chosen_State__c,
                    inputType: t.Registrant_Input__c || '',
                    inputValue: '',
                    canRemove: t.Chosen_State__c !== 'Added and Required'
                }));
        }
    }

    // ── Computed getters ────────────────────────────────────────────────────

    get hasNoAppointments() {
        return this._allTypes.length === 0;
    }

    get availableTypes() {
        const selectedIds = new Set(this._selections.map(s => s.typeId));
        return this._allTypes
            .filter(t =>
                !selectedIds.has(t.Id) &&
                t.Chosen_State__c !== 'Added but not shown' &&
                (t.Appointment_Limits__c === undefined || t.Appointment_Limits__c === null || t.Appointment_Limits__c > 0)
            )
            .map(t => ({
                ...t,
                showPicklist: t.Registrant_Input__c === 'Custom pick list' || t.Registrant_Input__c === 'Required custom pick list',
                showTextInput: t.Registrant_Input__c === 'Text box' || t.Registrant_Input__c === 'Required text box',
                inputRequired: t.Registrant_Input__c === 'Required text box' || t.Registrant_Input__c === 'Required custom pick list',
                picklistOptions: this._buildPicklistOptions(t.Custom_Picklist__c),
                inputValue: this._inputValues[t.Id] || ''
            }));
    }

    get hasAvailableTypes() { return this.availableTypes.length > 0; }

    get visibleSelections() {
        return this._selections.filter(s => s.chosenState !== 'Added but not shown');
    }

    get hasVisibleSelections() { return this.visibleSelections.length > 0; }

    get hasRequiredAppointments() {
        return this._allTypes.some(t => t.Required_Appointment__c);
    }

    get unchosenLabel() {
        return this.eventData?.eventInfo?.Event_Appointment_Unchosen_Label__c || 'Choose your options';
    }

    get chosenLabel() {
        return this.eventData?.eventInfo?.Event_Appointment_Chosen_Label__c || 'Selected options';
    }

    get nextInstructions() {
        return this.eventData?.eventInfo?.Event_Appointment_Next_Instructions__c ||
            'Once you have made your selections click next.';
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    _buildPicklistOptions(customPicklist) {
        const opts = [{ label: 'Select...', value: '' }];
        if (!customPicklist) return opts;
        customPicklist.split('\n').forEach(v => {
            v = v.trim();
            if (v) opts.push({ label: v, value: v });
        });
        return opts;
    }

    // ── Event handlers ───────────────────────────────────────────────────────

    handleInputChange(event) {
        const typeId = event.target.dataset.typeId;
        this._inputValues = { ...this._inputValues, [typeId]: event.target.value };
    }

    handleAdd(event) {
        const typeId = event.target.dataset.typeId;
        const aptType = this._allTypes.find(t => t.Id === typeId);
        if (!aptType) return;

        const inputType = aptType.Registrant_Input__c || '';
        const inputValue = this._inputValues[typeId] || '';

        // Validate required input before adding
        if ((inputType === 'Required text box' || inputType === 'Required custom pick list') && !inputValue) {
            const el = this.template.querySelector(`[data-type-id="${typeId}"]`);
            if (el && typeof el.reportValidity === 'function') el.reportValidity();
            return;
        }

        this.validationError = '';
        this._selections = [
            ...this._selections,
            {
                typeId,
                title: aptType.Title__c,
                category: aptType.Appointment_Category__c || '',
                chosenState: '',
                inputType,
                inputValue,
                canRemove: true
            }
        ];
    }

    handleRemove(event) {
        const typeId = event.target.dataset.typeId;
        this._selections = this._selections.filter(s => s.typeId !== typeId);
    }

    // ── Page contract ────────────────────────────────────────────────────────

    @api
    validate() {
        this.validationError = '';
        const selectedIds = new Set(this._selections.map(s => s.typeId));
        const missingRequired = this._allTypes.filter(t => t.Required_Appointment__c && !selectedIds.has(t.Id));
        if (missingRequired.length > 0) {
            this.validationError = 'Please select all required appointments before continuing.';
            return false;
        }
        return true;
    }

    @api
    getData() {
        const appointments = this._selections.map(s => ({
            Event_Appointment_Type__c: s.typeId,
            Appointment_Title__c: s.title,
            Appointment_Category__c: s.category,
            Chosen_State__c: s.chosenState || null,
            Registrant_Input__c: s.inputValue || null
        }));
        return {
            primaryRegistration: {
                ...this.eventData.primaryRegistration,
                appointments
            }
        };
    }
}
