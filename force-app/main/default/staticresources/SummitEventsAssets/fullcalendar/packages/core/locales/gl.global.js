/*!
FullCalendar Core v6.0.1
Docs & License: https://fullcalendar.io
(c) 2022 Adam Shaw
*/
(function (index_js) {
    'use strict';

    var locale = {
        code: 'gl',
        week: {
            dow: 1,
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        buttonText: {
            prev: 'Ant',
            next: 'Seg',
            today: 'Hoxe',
            month: 'Mes',
            week: 'Semana',
            day: 'Día',
            list: 'Axenda',
        },
        weekText: 'Sm',
        allDayText: 'Todo o día',
        moreLinkText: 'máis',
        noEventsText: 'Non hai eventos para amosar',
    };

    index_js.globalLocales.push(locale);

})(FullCalendar);
