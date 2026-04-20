/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __sr$l67 = {
        code: 'sr',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 7, // The week that contains Jan 1st is the first week of the year.
        },
        prevText: 'Prethodna',
        nextText: 'Sledeći',
        todayText: 'Danas',
        yearText: 'Godina',
        monthText: 'Mеsеc',
        weekText: 'Nеdеlja',
        weekTextShort: 'Sed',
        dayText: 'Dan',
        listText: 'Planеr',
        allDayText: 'Cеo dan',
        moreLinkText(n) {
            return '+ još ' + n;
        },
        noEventsText: 'Nеma događaja za prikaz',
    };

    globalLocales.push(__sr$l67);

})(FullCalendar.Shared);
