/*!
FullCalendar Core v6.0.1
Docs & License: https://fullcalendar.io
(c) 2022 Adam Shaw
*/
(function (index_js) {
    'use strict';

    var locale = {
        code: 'nn',
        week: {
            dow: 1,
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        buttonText: {
            prev: 'Førre',
            next: 'Neste',
            today: 'I dag',
            month: 'Månad',
            week: 'Veke',
            day: 'Dag',
            list: 'Agenda',
        },
        weekText: 'Veke',
        allDayText: 'Heile dagen',
        moreLinkText: 'til',
        noEventsText: 'Ingen hendelser å vise',
    };

    index_js.globalLocales.push(locale);

})(FullCalendar);
