/*!
FullCalendar Core v6.0.1
Docs & License: https://fullcalendar.io
(c) 2022 Adam Shaw
*/
(function (index_js) {
    'use strict';

    var locale = {
        code: 'mk',
        buttonText: {
            prev: 'претходно',
            next: 'следно',
            today: 'Денес',
            month: 'Месец',
            week: 'Недела',
            day: 'Ден',
            list: 'График',
        },
        weekText: 'Сед',
        allDayText: 'Цел ден',
        moreLinkText(n) {
            return '+повеќе ' + n;
        },
        noEventsText: 'Нема настани за прикажување',
    };

    index_js.globalLocales.push(locale);

})(FullCalendar);
