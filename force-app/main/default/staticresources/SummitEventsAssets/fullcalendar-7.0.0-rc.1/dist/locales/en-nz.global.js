/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __en_nz$l21 = {
        code: 'en-nz',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        weekTextShort: 'W',
        todayHint: 'This $0',
        prevHint: 'Previous $0',
        nextHint: 'Next $0',
        viewHint: '$0 view',
        navLinkHint: 'Go to $0',
        moreLinkHint(eventCnt) {
            return `Show ${eventCnt} more event${eventCnt === 1 ? '' : 's'}`;
        },
    };

    globalLocales.push(__en_nz$l21);

})(FullCalendar.Shared);
