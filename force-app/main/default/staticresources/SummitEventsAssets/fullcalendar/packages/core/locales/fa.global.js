/*!
FullCalendar Core v6.0.1
Docs & License: https://fullcalendar.io
(c) 2022 Adam Shaw
*/
(function (index_js) {
    'use strict';

    var locale = {
        code: 'fa',
        week: {
            dow: 6,
            doy: 12, // The week that contains Jan 1st is the first week of the year.
        },
        direction: 'rtl',
        buttonText: {
            prev: 'قبلی',
            next: 'بعدی',
            today: 'امروز',
            month: 'ماه',
            week: 'هفته',
            day: 'روز',
            list: 'برنامه',
        },
        weekText: 'هف',
        allDayText: 'تمام روز',
        moreLinkText(n) {
            return 'بیش از ' + n;
        },
        noEventsText: 'هیچ رویدادی به نمایش',
    };

    index_js.globalLocales.push(locale);

})(FullCalendar);
