import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class SummitEventsWrapper extends LightningElement {
    // -------------------------------------------------------------------------
    // Public design attributes (configurable in Experience Builder)
    // -------------------------------------------------------------------------

    /** Force a specific instance ID — skips calendar and goes straight to registration. */
    @api eventInstanceId = '';

    /** Pre-populate an encrypted registration ID (for resuming a registration). */
    @api registrationId = '';

    // --- Calendar filter configuration ---

    /** Hide the audience filter dropdown on the calendar. Defaults to false (shown). */
    @api hideAudienceDropdown = false;

    /** Label for the audience dropdown. */
    @api audienceDropdownLabel = 'Select who you are to see events curated for you';

    /** Pre-filter calendar to one or more audiences (comma-separated). */
    @api defaultAudience = '';

    /** Filter calendar by Summit Events record type name. */
    @api recordType = '';

    /** Filter calendar by Filter_Where_To_Display__c (comma-separated). */
    @api displayOn = '';

    /** Filter calendar by Filter_Category__c (comma-separated). */
    @api category = '';

    /** Filter calendar by Event_Type__c (single value). */
    @api eventType = '';

    /** Filter calendar by program filter fields (comma-separated). */
    @api program = '';

    /** Filter calendar by Event_Sponsor__c (comma-separated). */
    @api sponsor = '';

    /** Filter calendar by Building__c (comma-separated). */
    @api building = '';

    /** Filter calendar by location type (comma-separated). */
    @api locationType = '';

    /** When true, events with no remaining capacity are hidden from the calendar. */
    @api hideClosed = false;

    // -------------------------------------------------------------------------
    // Internal state
    // -------------------------------------------------------------------------

    @track activeInstanceId = '';
    @track _navigatedFromCalendar = false;

    // -------------------------------------------------------------------------
    // URL parameter reading
    // -------------------------------------------------------------------------

    @wire(CurrentPageReference)
    handlePageReference(pageReference) {
        if (!pageReference) {
            return;
        }
        const state = pageReference.state || {};

        // Check all known parameter variants, including c__ prefix for Experience Cloud
        const instanceIdFromUrl =
            state.c__instanceId ||
            state.c__instanceID ||
            state.instanceId ||
            state.instanceID ||
            state.c__eventInstanceId ||
            state.eventInstanceId ||
            state.c__id ||
            state.id ||
            this._readWindowParam('instanceId') ||
            this._readWindowParam('instanceID') ||
            this._readWindowParam('eventInstanceId') ||
            this._readWindowParam('id');

        const registrationIdFromUrl =
            state.c__registrationId ||
            state.c__registrationID ||
            state.registrationId ||
            state.registrationID ||
            state.c__regId ||
            state.regId ||
            this._readWindowParam('registrationId') ||
            this._readWindowParam('registrationID') ||
            this._readWindowParam('regId');

        if (instanceIdFromUrl) {
            this.activeInstanceId = instanceIdFromUrl;
        } else if (this.eventInstanceId) {
            this.activeInstanceId = this.eventInstanceId;
        }

        if (registrationIdFromUrl) {
            this.registrationId = registrationIdFromUrl;
        }
    }

    // -------------------------------------------------------------------------
    // Getters
    // -------------------------------------------------------------------------

    get showRegistration() {
        return Boolean(this.activeInstanceId);
    }

    get showCalendar() {
        return !this.showRegistration;
    }

    /**
     * Only show the "Back to Events" button when the user navigated from the calendar
     * within the same page session (not when arriving directly via URL with an instanceId).
     */
    get showBackToCalendar() {
        return this._navigatedFromCalendar;
    }

    // -------------------------------------------------------------------------
    // Event handlers
    // -------------------------------------------------------------------------

    handleEventSelect(event) {
        const instanceId = event.detail?.instanceId;
        if (instanceId) {
            this._navigatedFromCalendar = true;
            this.activeInstanceId = instanceId;
        }
    }

    handleBackToCalendar() {
        this.activeInstanceId = '';
        this.registrationId = '';
        this._navigatedFromCalendar = false;
    }

    // -------------------------------------------------------------------------
    // Private helpers
    // -------------------------------------------------------------------------

    /**
     * Falls back to window.location.search for non-Experience-Cloud contexts.
     *
     * @param paramName The URL parameter name to look up
     * @return The parameter value or empty string
     */
    _readWindowParam(paramName) {
        try {
            return new URLSearchParams(window.location.search).get(paramName) || '';
        } catch (ignored) {
            return '';
        }
    }
}


