/*!
FullCalendar (Vanilla JS) v7.0.0-rc.3
Docs & License: https://fullcalendar.io
(c) 2026 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __uk$l73 = {
        code: 'uk',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 7, // The week that contains Jan 1st is the first week of the year.
        },
        prevText: 'Попередній',
        nextText: 'далі',
        todayText: 'Сьогодні',
        yearText: 'рік',
        monthText: 'Місяць',
        weekTextLong: 'Тиждень',
        weekTextShort: 'Тиж',
        dayText: 'День',
        listText: 'Порядок денний',
        allDayText: 'Увесь\nдень',
        moreLinkText(n) {
            return '+ще ' + n + '...';
        },
        noEventsText: 'Немає подій для відображення',
    };

    globalLocales.push(__uk$l73);

})(FullCalendar.Shared);
