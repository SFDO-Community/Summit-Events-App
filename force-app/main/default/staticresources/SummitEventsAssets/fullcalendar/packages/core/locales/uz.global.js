/*!
FullCalendar Core v6.0.1
Docs & License: https://fullcalendar.io
(c) 2022 Adam Shaw
*/
(function (index_js) {
    'use strict';

    var locale = {
        code: 'uz',
        buttonText: {
            month: 'Oy',
            week: 'Xafta',
            day: 'Kun',
            list: 'Kun tartibi',
        },
        allDayText: 'Kun bo\'yi',
        moreLinkText(n) {
            return '+ yana ' + n;
        },
        noEventsText: 'Ko\'rsatish uchun voqealar yo\'q',
    };

    index_js.globalLocales.push(locale);

})(FullCalendar);
