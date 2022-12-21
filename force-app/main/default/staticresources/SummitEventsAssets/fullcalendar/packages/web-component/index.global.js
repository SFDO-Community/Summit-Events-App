/*!
FullCalendar Web Component v6.0.1
Docs & License: https://fullcalendar.io
(c) 2022 Adam Shaw
*/
(function (core) {
    'use strict';

    class FullCalendarElement extends HTMLElement {
        constructor() {
            super(...arguments);
            this._calendar = null;
            this._options = null;
        }
        connectedCallback() {
            this._handleOptionsStr(this.getAttribute('options'));
        }
        disconnectedCallback() {
            this._handleOptionsStr(null);
        }
        attributeChangedCallback(name, oldVal, newVal) {
            if (name === 'options' &&
                this._calendar // initial render happened
            ) {
                this._handleOptionsStr(newVal);
            }
        }
        get options() {
            return this._options;
        }
        set options(options) {
            this._handleOptions(options);
        }
        getApi() {
            return this._calendar;
        }
        _handleOptionsStr(optionsStr) {
            this._handleOptions(optionsStr ? JSON.parse(optionsStr) : null);
        }
        _handleOptions(options) {
            if (options) {
                if (this._calendar) {
                    this._calendar.resetOptions(options);
                }
                else {
                    this.innerHTML = '<div></div>';
                    let calendarEl = this.querySelector('div');
                    let calendar = new core.Calendar(calendarEl, options);
                    calendar.render();
                    this._calendar = calendar;
                }
                this._options = options;
            }
            else {
                if (this._calendar) {
                    this._calendar.destroy();
                    this._calendar = null;
                }
                this._options = null;
            }
        }
        static get observedAttributes() {
            return ['options'];
        }
    }

    globalThis.FullCalendarElement = FullCalendarElement;
    customElements.define('full-calendar', FullCalendarElement);

})(FullCalendar);
