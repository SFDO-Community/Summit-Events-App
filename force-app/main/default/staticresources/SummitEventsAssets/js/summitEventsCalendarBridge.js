/**
 * summitEventsCalendarBridge.js
 *
 * Loaded via loadScript AFTER fullcalendar/index.global.min.js.
 * Both scripts run in the LWS trusted realm, so this script CAN access
 * window.FullCalendar even though LWC component JavaScript cannot.
 *
 * Communication pattern (LWS realm-safe):
 *   LWC  --sea:init-->  document  -->  bridge
 *   LWC  <--sea:ready--  container element  <--
 *   LWC  --sea:refetch-->  container element
 *   LWC  --sea:destroy-->  container element
 *
 * DOM CustomEvents cross the LWS realm boundary via bubbling.
 * Window property access does not cross the realm boundary.
 */
(function () {
    // Listen for the init request from the LWC component.
    // The event bubbles up from the container element to the document.
    document.addEventListener('sea:init', function (event) {
        var containerEl = event.detail && event.detail.container;
        var config = event.detail && event.detail.config;

        if (!containerEl) {
            return;
        }

        if (!window.FullCalendar) {
            containerEl.dispatchEvent(new CustomEvent('sea:error', {
                bubbles: false,
                composed: false,
                detail: { message: 'FullCalendar global not available in bridge realm.' }
            }));
            return;
        }

        try {
            var calendar = new window.FullCalendar.Calendar(containerEl, config);
            calendar.render();

            // Store on element so refetch/destroy can reach it without going
            // back through the LWS window proxy.
            containerEl._seaCalendarInstance = calendar;

            containerEl.dispatchEvent(new CustomEvent('sea:ready', {
                bubbles: false,
                composed: false,
                detail: { calendar: calendar }
            }));
        } catch (err) {
            containerEl.dispatchEvent(new CustomEvent('sea:error', {
                bubbles: false,
                composed: false,
                detail: { message: String(err) }
            }));
        }
    });

    // Listen for refetch requests dispatched on the container element.
    document.addEventListener('sea:refetch', function (event) {
        var containerEl = event.detail && event.detail.container;
        if (containerEl && containerEl._seaCalendarInstance) {
            containerEl._seaCalendarInstance.refetchEvents();
        }
    });

    // Listen for destroy requests dispatched on the container element.
    document.addEventListener('sea:destroy', function (event) {
        var containerEl = event.detail && event.detail.container;
        if (containerEl && containerEl._seaCalendarInstance) {
            containerEl._seaCalendarInstance.destroy();
            delete containerEl._seaCalendarInstance;
        }
    });
}());
