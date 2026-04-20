/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __bs$l11 = {
        code: 'bs',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 7, // The week that contains Jan 1st is the first week of the year.
        },
        prevText: 'Prošli',
        nextText: 'Sljedeći',
        todayText: 'Danas',
        yearText: 'Godina',
        monthText: 'Mjesec',
        weekText: 'Sedmica',
        weekTextShort: 'Sed',
        dayText: 'Dan',
        listText: 'Raspored',
        allDayText: 'Cijeli\ndan',
        moreLinkText(n) {
            return '+ još ' + n;
        },
        noEventsText: 'Nema događaja za prikazivanje',
    };

    globalLocales.push(__bs$l11);

})(FullCalendar.Shared);
