import {LightningElement, api, track, wire} from 'lwc';
import {loadScript, loadStyle} from 'lightning/platformResourceLoader';
import SUMMIT_EVENTS_ASSETS from '@salesforce/resourceUrl/SummitEventsAssets';
import getAudienceOptions from '@salesforce/apex/SummitEventsCalendarController.getAudienceOptions';
import getCalendarEvents from '@salesforce/apex/SummitEventsCalendarController.getCalendarEvents';

// FullCalendar sets a global variable when loaded via loadScript.
// We use fullcalendar-patched.js which stubs out the CSS injection functions (xe, _e)
// so FullCalendar does NOT try to inject <style> tags into document.head.
// In LWC, document.head-injected CSS cannot pierce the shadow DOM boundary, so
// styles must be loaded via loadStyle() instead (see fullcalendar-extracted.css).
/* global FullCalendar */

export default class SummitEventsCalendar extends LightningElement {
    // -------------------------------------------------------------------------
    // Public (configurable from summitEventsWrapper or Experience Builder)
    // -------------------------------------------------------------------------

    /** Hide the audience filter dropdown. Defaults to false (dropdown is shown by default). */
    @api hideAudienceDropdown = false;

    /** Label text shown above the audience dropdown. */
    @api audienceDropdownLabel = 'Select who you are to see events curated for you';

    /** Pre-filter to a specific audience value (comma-separated for multi). */
    @api defaultAudience = '';

    /** Filter by event record type name. */
    @api recordType = '';

    /** Filter by Filter_Where_To_Display__c (comma-separated). */
    @api displayOn = '';

    /** Filter by Filter_Category__c (comma-separated). */
    @api category = '';

    /** Filter by Event_Type__c (single value). */
    @api eventType = '';

    /** Filter by program filter fields (comma-separated). */
    @api program = '';

    /** Filter by Event_Sponsor__c (comma-separated). */
    @api sponsor = '';

    /** Filter by Building__c (comma-separated). */
    @api building = '';

    /** Filter by location type (comma-separated). */
    @api locationType = '';

    /** When true, events with no remaining capacity are hidden. */
    @api hideClosed = false;

    // -------------------------------------------------------------------------
    // Internal state
    // -------------------------------------------------------------------------

    @track audienceOptions = [];
    @track selectedEvent = null;
    @track isLoading = true;
    @track errorMessage = '';

    _fullCalendarLoaded = false;
    _renderedOnce = false;
    _calendarInstance = null;
    _selectedAudience = '';
    _currentViewStart = null;
    _currentViewEnd = null;

    // -------------------------------------------------------------------------
    // Lifecycle
    // -------------------------------------------------------------------------

    connectedCallback() {
        this._selectedAudience = this.defaultAudience || '';
        Promise.all([
            loadStyle(this, SUMMIT_EVENTS_ASSETS + '/fullcalendar-7.0.0-rc.1/dist/skeleton.css'),
            loadStyle(this, SUMMIT_EVENTS_ASSETS + '/fullcalendar-7.0.0-rc.1/dist/themes/monarch/theme.css'),
            loadStyle(this, SUMMIT_EVENTS_ASSETS + '/fullcalendar-7.0.0-rc.1/dist/themes/monarch/palettes/purple.css'),
            loadScript(this, SUMMIT_EVENTS_ASSETS + '/fullcalendar-7.0.0-rc.1/dist/fullcalendar.global.js'),
            loadScript(this, SUMMIT_EVENTS_ASSETS + '/fullcalendar-7.0.0-rc.1/dist/themes/monarch/global.js')
        ]).then(() => {
            this._fullCalendarLoaded = true;
            // renderedCallback may have already fired and set _renderedOnce.
            if (this._renderedOnce) {
                this._mountCalendar();
            }
        }).catch((error) => {
            this.isLoading = false;
            this.errorMessage = 'Unable to load the calendar library. Please refresh the page.';
            console.error('[SEA] FullCalendar load error:', error);
        });
    }

    renderedCallback() {
        if (this._renderedOnce) {
            return;
        }
        this._renderedOnce = true;
        // If scripts finished loading before this callback, mount now.
        // Otherwise, the connectedCallback .then() handler will call _mountCalendar().
        if (this._fullCalendarLoaded) {
            this._mountCalendar();
        }
    }

    disconnectedCallback() {
        if (this._calendarInstance) {
            this._calendarInstance.destroy();
            this._calendarInstance = null;
        }
    }

    // -------------------------------------------------------------------------
    // Apex wire - audience options
    // -------------------------------------------------------------------------

    @wire(getAudienceOptions) handleAudienceOptionsResult({data, error}) {
        if (data) {
            this.audienceOptions = data;
        } else if (error) {
            console.error('Error loading audience options:', error);
        }
    }

    _mountCalendar() {
        // Use this.refs for reliable access to the lwc:ref="calendarContainer" element.
        const containerElement = this.refs.calendarContainer;
        if (!containerElement) {
            this.isLoading = false;
            this.errorMessage = 'Calendar container not found.';
            return;
        }
        if (!FullCalendar) {
            this.isLoading = false;
            this.errorMessage = 'FullCalendar library failed to initialize.';
            return;
        }
        const calendar = new FullCalendar.Calendar(containerElement, this._calendarConfig());
        calendar.render();
        this._calendarInstance = calendar;
    }

    _calendarConfig() {
        return {
            initialView: 'dayGridMonth', headerToolbar: {
                left: 'prev,next today', center: 'title', right: 'dayGridMonth,listMonth'
            }, events: (fetchInfo, successCallback, failureCallback) => {
                this._fetchEvents(fetchInfo, successCallback, failureCallback);
            }, eventClick: (clickInfo) => {
                clickInfo.jsEvent.preventDefault();
                this._handleEventClick(clickInfo.event);
            }, loading: (isLoadingNow) => {
                this.isLoading = isLoadingNow;
            }
        };
    }

    _fetchEvents(fetchInfo, successCallback, failureCallback) {
        this._currentViewStart = fetchInfo.startStr.substring(0, 10);
        this._currentViewEnd = fetchInfo.endStr.substring(0, 10);

        const filters = {
            audience: this._selectedAudience || null,
            recordType: this.recordType || null,
            displayOn: this.displayOn || null,
            category: this.category || null,
            eventType: this.eventType || null,
            program: this.program || null,
            sponsor: this.sponsor || null,
            building: this.building || null,
            locationType: this.locationType || null,
            hideClosed: this.hideClosed || false,
            viewStart: this._currentViewStart,
            viewEnd: this._currentViewEnd
        };

        getCalendarEvents({filters})
            .then((calendarEventItems) => {
                const fullCalendarEvents = calendarEventItems.map((item) => ({
                    id: item.instanceId,
                    title: item.title,
                    start: item.startDatetime,
                    end: item.endDatetime,
                    classNames: [item.cssClass],
                    extendedProps: {
                        instanceId: item.instanceId,
                        instanceDescription: item.instanceDescription,
                        shortDescription: item.shortDescription,
                        locationTitle: item.locationTitle,
                        locationType: item.locationType,
                        locationAddress: item.locationAddress,
                        locationMapLink: item.locationMapLink,
                        locationBuilding: item.locationBuilding,
                        registerButtonText: item.registerButtonText,
                        alternateRegistrationUrl: item.alternateRegistrationUrl,
                        eventClosed: item.eventClosed,
                        capacityTotal: item.capacityTotal,
                        capacityRemaining: item.capacityRemaining
                    }
                }));
                successCallback(fullCalendarEvents);
            })
            .catch((error) => {
                console.error('Error fetching calendar events:', error);
                failureCallback(error);
            });
    }

    _handleEventClick(fullCalendarEvent) {
        this.selectedEvent = {
            instanceId: fullCalendarEvent.extendedProps.instanceId,
            title: fullCalendarEvent.title,
            instanceDescription: fullCalendarEvent.extendedProps.instanceDescription,
            shortDescription: fullCalendarEvent.extendedProps.shortDescription,
            locationTitle: fullCalendarEvent.extendedProps.locationTitle,
            locationType: fullCalendarEvent.extendedProps.locationType,
            locationAddress: fullCalendarEvent.extendedProps.locationAddress,
            locationMapLink: fullCalendarEvent.extendedProps.locationMapLink,
            locationBuilding: fullCalendarEvent.extendedProps.locationBuilding,
            registerButtonText: fullCalendarEvent.extendedProps.registerButtonText || 'Register',
            alternateRegistrationUrl: fullCalendarEvent.extendedProps.alternateRegistrationUrl,
            eventClosed: fullCalendarEvent.extendedProps.eventClosed
        };
    }

    // -------------------------------------------------------------------------
    // Getters
    // -------------------------------------------------------------------------

    get calendarWrapperClass() {
        return this.isLoading ? 'sea-calendar-mount sea-calendar-loading' : 'sea-calendar-mount';
    }

    // -------------------------------------------------------------------------
    // Event handlers
    // -------------------------------------------------------------------------

    handleAudienceChange(event) {
        this._selectedAudience = event.target.value;
        this.selectedEvent = null;
        if (this._calendarInstance) {
            this._calendarInstance.refetchEvents();
        }
    }

    handleRegisterClick(event) {
        const instanceId = event.currentTarget.dataset.instanceId;
        this.selectedEvent = null;
        this.dispatchEvent(new CustomEvent('eventselect', {
            detail: {instanceId}, bubbles: true, composed: true
        }));
    }

    handleClosePopover() {
        this.selectedEvent = null;
    }
}

