/*!
FullCalendar (Vanilla JS) v7.0.0-rc.3
Docs & License: https://fullcalendar.io
(c) 2026 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __ms$l51 = {
        code: 'ms',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 7, // The week that contains Jan 1st is the first week of the year.
        },
        prevText: 'Sebelum',
        nextText: 'Selepas',
        todayText: 'hari ini',
        yearText: 'Tahun',
        monthText: 'Bulan',
        weekTextLong: 'Minggu',
        weekTextShort: 'Mg',
        dayText: 'Hari',
        listText: 'Agenda',
        allDayText: 'Sepanjang\nhari',
        moreLinkText(n) {
            return 'masih ada ' + n + ' acara';
        },
        noEventsText: 'Tiada peristiwa untuk dipaparkan',
    };

    globalLocales.push(__ms$l51);

})(FullCalendar.Shared);
