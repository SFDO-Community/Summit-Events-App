/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __bn$l10 = {
        code: 'bn',
        week: {
            dow: 0, // Sunday is the first day of the week.
            doy: 6, // The week that contains Jan 1st is the first week of the year.
        },
        prevText: 'পেছনে',
        nextText: 'সামনে',
        todayText: 'আজ',
        yearText: 'বছর',
        monthText: 'মাস',
        weekText: 'সপ্তাহ',
        dayText: 'দিন',
        listText: 'তালিকা',
        allDayText: 'সারাদিন',
        moreLinkText(n) {
            return '+অন্যান্য ' + n;
        },
        noEventsText: 'কোনো ইভেন্ট নেই',
    };

    globalLocales.push(__bn$l10);

})(FullCalendar.Shared);
