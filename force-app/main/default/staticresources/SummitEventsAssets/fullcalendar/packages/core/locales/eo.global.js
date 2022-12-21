/*!
FullCalendar Core v6.0.1
Docs & License: https://fullcalendar.io
(c) 2022 Adam Shaw
*/
(function (index_js) {
    'use strict';

    var locale = {
        code: 'eo',
        week: {
            dow: 1,
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        buttonText: {
            prev: 'Antaŭa',
            next: 'Sekva',
            today: 'Hodiaŭ',
            month: 'Monato',
            week: 'Semajno',
            day: 'Tago',
            list: 'Tagordo',
        },
        weekText: 'Sm',
        allDayText: 'Tuta tago',
        moreLinkText: 'pli',
        noEventsText: 'Neniuj eventoj por montri',
    };

    index_js.globalLocales.push(locale);

})(FullCalendar);
