/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __ro$l59 = {
        code: 'ro',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 7, // The week that contains Jan 1st is the first week of the year.
        },
        prevText: 'precedentă',
        nextText: 'următoare',
        todayText: 'Azi',
        yearText: 'An',
        monthText: 'Lună',
        weekText: 'Săptămână',
        weekTextShort: 'Săpt',
        dayText: 'Zi',
        listText: 'Agendă',
        allDayText: 'Toată\nziua',
        moreLinkText(n) {
            return '+alte ' + n;
        },
        noEventsText: 'Nu există evenimente de afișat',
    };

    globalLocales.push(__ro$l59);

})(FullCalendar.Shared);
