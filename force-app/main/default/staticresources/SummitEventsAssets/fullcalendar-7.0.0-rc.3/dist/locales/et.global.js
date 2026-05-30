/*!
FullCalendar (Vanilla JS) v7.0.0-rc.3
Docs & License: https://fullcalendar.io
(c) 2026 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __et$l25 = {
        code: 'et',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        prevText: 'Eelnev',
        nextText: 'Järgnev',
        todayText: 'Täna',
        yearText: 'Aasta',
        monthText: 'Kuu',
        weekTextLong: 'Nädal',
        weekTextShort: 'Näd',
        dayText: 'Päev',
        listText: 'Päevakord',
        allDayText: 'Kogu\npäev',
        moreLinkText(n) {
            return '+ veel ' + n;
        },
        noEventsText: 'Kuvamiseks puuduvad sündmused',
    };

    globalLocales.push(__et$l25);

})(FullCalendar.Shared);
