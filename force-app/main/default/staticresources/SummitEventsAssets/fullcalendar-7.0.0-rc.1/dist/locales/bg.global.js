/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __bg$l9 = {
        code: 'bg',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        prevText: 'назад',
        nextText: 'напред',
        todayText: 'днес',
        yearText: 'година',
        monthText: 'Месец',
        weekText: 'Седмица',
        dayText: 'Ден',
        listText: 'График',
        allDayText: 'Цял ден',
        moreLinkText(n) {
            return '+още ' + n;
        },
        noEventsText: 'Няма събития за показване',
    };

    globalLocales.push(__bg$l9);

})(FullCalendar.Shared);
