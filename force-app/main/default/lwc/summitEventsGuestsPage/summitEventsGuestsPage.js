import { LightningElement, api, track } from 'lwc';

export default class SummitEventsGuestsPage extends LightningElement {
    @api eventData;

    @track guestForm = {};       // current in-progress guest form values
    @track _guests = [];         // committed guests [{id, displayName, email, fields:{}}]
    @track showUnsavedModal = false;
    @track _guestQuestionAnswers = {};  // mapToField → value for guest form questions

    _nextGuestId = 0;

    connectedCallback() {
        // Load existing guest registrations if present
        const existing = this.eventData?.guestRegistrations || [];
        this._guests = existing.map((reg, idx) => {
            const rec = reg.registrationRecord || {};
            const firstName = rec.Registrant_First_Name__c || '';
            const lastName  = rec.Registrant_Last_Name__c  || '';
            const email     = rec.Registrant_Email__c      || '';
            return {
                id: idx,
                displayName: [firstName, lastName].filter(Boolean).join(' ') || `Guest ${idx + 1}`,
                email,
                fields: rec
            };
        });
        this._nextGuestId = this._guests.length;
    }

    // ── Computed getters ─────────────────────────────────────────────────────

    get guestDescription() {
        return this.eventData?.eventInfo?.Guest_Registration_Description__c;
    }

    get guestQuestions() {
        return this.eventData?.guestQuestions || [];
    }

    get hasNoGuestQuestions() {
        return this.guestQuestions.length === 0;
    }

    get guestList() { return this._guests; }
    get hasGuests()  { return this._guests.length > 0; }

    get maxGuests() {
        return this.eventData?.config?.maxGuests || 0;
    }

    get isAtMaxGuests() {
        return this.maxGuests > 0 && this._guests.length >= this.maxGuests;
    }

    get showGuestsRemaining() {
        return this.maxGuests > 0;
    }

    get guestsRemainingText() {
        const remaining = this.maxGuests - this._guests.length;
        return `${remaining} guest registration${remaining !== 1 ? 's' : ''} remaining.`;
    }

    get addButtonLabel() {
        return this.eventData?.eventInfo?.Guest_Registration_Add_Button_Label__c || 'Register Guest';
    }

    get noGuestMessage() {
        return this.eventData?.eventInfo?.No_Guest_Registrations_Added_Message__c || 'No guest added yet.';
    }

    get unsavedModalText() {
        return this.eventData?.eventInfo?.Guest_Unsaved_Modal_Text__c ||
            'You have unsaved Guest information entered. Select Cancel to finish adding your guests.';
    }

    get unsavedCancelLabel() {
        return this.eventData?.eventInfo?.Guest_Unsaved_Cancel_Label__c || 'Cancel';
    }

    get unsavedContinueLabel() {
        return this.eventData?.eventInfo?.Guest_Unsaved_Continue_Label__c || 'Continue';
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    _formHasData() {
        // Default-field mode
        if (this.hasNoGuestQuestions) {
            return !!(this.guestForm.Registrant_First_Name__c ||
                      this.guestForm.Registrant_Last_Name__c  ||
                      this.guestForm.Registrant_Email__c);
        }
        return Object.values(this._guestQuestionAnswers).some(v => !!v);
    }

    _clearForm() {
        this.guestForm = {};
        this._guestQuestionAnswers = {};
        // Reset each question-field component's internal value
        this.template.querySelectorAll('c-summit-events-question-field').forEach(f => {
            if (typeof f.reset === 'function') f.reset();
        });
    }

    _validateForm() {
        if (this.hasNoGuestQuestions) {
            const inputs = this.template.querySelectorAll('lightning-input[required]');
            let valid = true;
            inputs.forEach(i => { i.reportValidity(); valid = valid && i.checkValidity(); });
            return valid;
        }
        const fields = this.template.querySelectorAll('c-summit-events-question-field');
        return Array.from(fields).reduce((ok, f) => ok && f.validate(), true);
    }

    // ── Event handlers ───────────────────────────────────────────────────────

    handleFormChange(event) {
        const field = event.target.dataset.field;
        const value = event.target.value;
        this.guestForm = { ...this.guestForm, [field]: value };
    }

    handleQuestionChange(event) {
        const { fieldName, value } = event.detail;
        this._guestQuestionAnswers = { ...this._guestQuestionAnswers, [fieldName]: value };
        // Mirror first/last/email into guestForm for display
        if (fieldName) {
            this.guestForm = { ...this.guestForm, [fieldName]: value };
        }
    }

    handleAddGuest() {
        if (this.isAtMaxGuests) return;
        if (!this._validateForm()) return;

        const firstName = this.guestForm.Registrant_First_Name__c || '';
        const lastName  = this.guestForm.Registrant_Last_Name__c  || '';
        const email     = this.guestForm.Registrant_Email__c      || '';

        this._guests = [
            ...this._guests,
            {
                id: this._nextGuestId++,
                displayName: [firstName, lastName].filter(Boolean).join(' ') || `Guest ${this._nextGuestId}`,
                email,
                fields: { ...this.guestForm }
            }
        ];
        this._clearForm();
    }

    handleRemoveGuest(event) {
        const guestId = parseInt(event.target.dataset.guestId, 10);
        this._guests = this._guests.filter(g => g.id !== guestId);
    }

    handleModalCancel() {
        this.showUnsavedModal = false;
    }

    handleModalContinue() {
        // Discard unsaved form data and proceed
        this._clearForm();
        this.showUnsavedModal = false;
    }

    // ── Page contract ────────────────────────────────────────────────────────

    @api
    validate() {
        if (this._formHasData()) {
            this.showUnsavedModal = true;
            return false;
        }
        return true;
    }

    @api
    getData() {
        const guestRegistrations = this._guests.map((g, idx) => ({
            registrationRecord: {
                Registrant_First_Name__c: g.fields.Registrant_First_Name__c || '',
                Registrant_Last_Name__c:  g.fields.Registrant_Last_Name__c  || '',
                Registrant_Email__c:      g.fields.Registrant_Email__c      || '',
                ...g.fields
            },
            appointments: [],
            isGuest: true,
            guestIndex: idx
        }));
        return { guestRegistrations };
    }
}
