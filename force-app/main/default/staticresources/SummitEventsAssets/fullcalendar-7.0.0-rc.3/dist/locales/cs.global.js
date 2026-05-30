/*!
FullCalendar (Vanilla JS) v7.0.0-rc.3
Docs & License: https://fullcalendar.io
(c) 2026 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __cs$l13 = {
        code: 'cs',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        prevText: 'Dříve',
        nextText: 'Později',
        todayText: 'Nyní',
        yearText: 'Rok',
        monthText: 'Měsíc',
        weekTextLong: 'Týden',
        weekTextShort: 'Týd',
        dayText: 'Den',
        listText: 'Agenda',
        allDayText: 'Celý den',
        moreLinkText(n) {
            return '+další: ' + n;
        },
        noEventsText: 'Žádné akce k zobrazení',
    };

    globalLocales.push(__cs$l13);

})(FullCalendar.Shared);
