/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __fa$l27 = {
        code: 'fa',
        week: {
            dow: 6, // Saturday is the first day of the week.
            doy: 12, // The week that contains Jan 1st is the first week of the year.
        },
        direction: 'rtl',
        prevText: 'قبلی',
        nextText: 'بعدی',
        todayText: 'امروز',
        yearText: 'سال',
        monthText: 'ماه',
        weekText: 'هفته',
        weekTextShort: 'هف',
        dayText: 'روز',
        listText: 'برنامه',
        allDayText: 'تمام روز',
        moreLinkText(n) {
            return 'بیش از ' + n;
        },
        noEventsText: 'هیچ رویدادی به نمایش',
    };

    globalLocales.push(__fa$l27);

})(FullCalendar.Shared);
