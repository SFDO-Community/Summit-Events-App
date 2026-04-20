/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __nb$l52 = {
        code: 'nb',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        prevText: 'Forrige',
        nextText: 'Neste',
        todayText: 'I dag',
        yearText: 'År',
        monthText: 'Måned',
        weekText: 'Uke',
        dayText: 'Dag',
        listText: 'Agenda',
        allDayText: 'Hele\ndagen',
        moreLinkText: 'til',
        noEventsText: 'Ingen hendelser å vise',
        prevHint: 'Forrige $0',
        nextHint: 'Neste $0',
        todayHint: 'Nåværende $0',
        viewHint: '$0 visning',
        navLinkHint: 'Gå til $0',
        moreLinkHint(eventCnt) {
            return `Vis ${eventCnt} flere hendelse${eventCnt === 1 ? '' : 'r'}`;
        },
    };

    globalLocales.push(__nb$l52);

})(FullCalendar.Shared);
