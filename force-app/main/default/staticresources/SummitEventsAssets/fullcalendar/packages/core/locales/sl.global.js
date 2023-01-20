/*!
FullCalendar Core v6.0.1
Docs & License: https://fullcalendar.io
(c) 2022 Adam Shaw
*/
(function (index_js) {
    'use strict';

    var locale = {
        code: 'sl',
        week: {
            dow: 1,
            doy: 7, // The week that contains Jan 1st is the first week of the year.
        },
        buttonText: {
            prev: 'Prejšnji',
            next: 'Naslednji',
            today: 'Trenutni',
            month: 'Mesec',
            week: 'Teden',
            day: 'Dan',
            list: 'Dnevni red',
        },
        weekText: 'Teden',
        allDayText: 'Ves dan',
        moreLinkText: 'več',
        noEventsText: 'Ni dogodkov za prikaz',
    };

    index_js.globalLocales.push(locale);

})(FullCalendar);
