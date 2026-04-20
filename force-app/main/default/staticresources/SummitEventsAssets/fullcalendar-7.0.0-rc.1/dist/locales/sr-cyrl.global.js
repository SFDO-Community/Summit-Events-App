/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __sr_cyrl$l66 = {
        code: 'sr-cyrl',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 7, // The week that contains Jan 1st is the first week of the year.
        },
        prevText: 'Претходна',
        nextText: 'следећи',
        todayText: 'Данас',
        yearText: 'Година',
        monthText: 'Месец',
        weekText: 'Недеља',
        weekTextShort: 'Сед',
        dayText: 'Дан',
        listText: 'Планер',
        allDayText: 'Цео дан',
        moreLinkText(n) {
            return '+ још ' + n;
        },
        noEventsText: 'Нема догађаја за приказ',
    };

    globalLocales.push(__sr_cyrl$l66);

})(FullCalendar.Shared);
