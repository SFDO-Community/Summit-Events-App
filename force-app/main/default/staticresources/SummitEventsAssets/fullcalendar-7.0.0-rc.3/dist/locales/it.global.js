/*!
FullCalendar (Vanilla JS) v7.0.0-rc.3
Docs & License: https://fullcalendar.io
(c) 2026 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __it$l40 = {
        code: 'it',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        prevText: 'Prec',
        nextText: 'Succ',
        todayText: 'Oggi',
        yearText: 'Anno',
        monthText: 'Mese',
        weekTextLong: 'Settimana',
        weekTextShort: 'Sm',
        dayText: 'Giorno',
        listText: 'Agenda',
        allDayText: 'Tutto\nil giorno',
        moreLinkText(n) {
            return '+altri ' + n;
        },
        noEventsText: 'Non ci sono eventi da visualizzare',
    };

    globalLocales.push(__it$l40);

})(FullCalendar.Shared);
