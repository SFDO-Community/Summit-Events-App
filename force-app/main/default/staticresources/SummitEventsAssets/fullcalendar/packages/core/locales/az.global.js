/*!
FullCalendar Core v6.0.1
Docs & License: https://fullcalendar.io
(c) 2022 Adam Shaw
*/
(function (index_js) {
    'use strict';

    var locale = {
        code: 'az',
        week: {
            dow: 1,
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        buttonText: {
            prev: 'Əvvəl',
            next: 'Sonra',
            today: 'Bu Gün',
            month: 'Ay',
            week: 'Həftə',
            day: 'Gün',
            list: 'Gündəm',
        },
        weekText: 'Həftə',
        allDayText: 'Bütün Gün',
        moreLinkText(n) {
            return '+ daha çox ' + n;
        },
        noEventsText: 'Göstərmək üçün hadisə yoxdur',
    };

    index_js.globalLocales.push(locale);

})(FullCalendar);
