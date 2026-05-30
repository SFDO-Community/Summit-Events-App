/*!
FullCalendar (Vanilla JS) v7.0.0-rc.3
Docs & License: https://fullcalendar.io
(c) 2026 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __vi$l76 = {
        code: 'vi',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        prevText: 'Trước',
        nextText: 'Tiếp',
        todayText: 'Hôm nay',
        yearText: 'Năm',
        monthText: 'Tháng',
        weekTextLong: 'Tuần',
        weekTextShort: 'Tu',
        dayText: 'Ngày',
        listText: 'Lịch biểu',
        allDayText: 'Cả ngày',
        moreLinkText(n) {
            return '+ thêm ' + n;
        },
        noEventsText: 'Không có sự kiện để hiển thị',
    };

    globalLocales.push(__vi$l76);

})(FullCalendar.Shared);
