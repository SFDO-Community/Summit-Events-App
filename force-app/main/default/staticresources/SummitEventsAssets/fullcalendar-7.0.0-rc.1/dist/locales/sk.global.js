/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __sk$l62 = {
        code: 'sk',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        prevText: 'Predchádzajúci',
        nextText: 'Nasledujúci',
        todayText: 'Dnes',
        yearText: 'Rok',
        monthText: 'Mesiac',
        weekText: 'Týždeň',
        weekTextShort: 'Ty',
        dayText: 'Deň',
        listText: 'Rozvrh',
        allDayText: 'Celý deň',
        moreLinkText(n) {
            return '+ďalšie: ' + n;
        },
        noEventsText: 'Žiadne akcie na zobrazenie',
    };

    globalLocales.push(__sk$l62);

})(FullCalendar.Shared);
