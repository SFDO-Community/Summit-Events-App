/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __lv$l49 = {
        code: 'lv',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        prevText: 'Iepr.',
        nextText: 'Nāk.',
        todayText: 'Šodien',
        yearText: 'Gads',
        monthText: 'Mēnesis',
        weekText: 'Nedēļa',
        weekTextShort: 'Ned.',
        dayText: 'Diena',
        listText: 'Dienas kārtība',
        allDayText: 'Visu\ndienu',
        moreLinkText(n) {
            return '+vēl ' + n;
        },
        noEventsText: 'Nav notikumu',
    };

    globalLocales.push(__lv$l49);

})(FullCalendar.Shared);
