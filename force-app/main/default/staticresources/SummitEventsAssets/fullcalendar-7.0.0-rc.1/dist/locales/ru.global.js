/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __ru$l60 = {
        code: 'ru',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        prevText: 'Пред',
        nextText: 'След',
        todayText: 'Сегодня',
        yearText: 'Год',
        monthText: 'Месяц',
        weekText: 'Неделя',
        weekTextShort: 'Нед',
        dayText: 'День',
        listText: 'Повестка дня',
        allDayText: 'Весь\nдень',
        moreLinkText(n) {
            return '+ ещё ' + n;
        },
        noEventsText: 'Нет событий для отображения',
    };

    globalLocales.push(__ru$l60);

})(FullCalendar.Shared);
