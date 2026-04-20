/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    var __es_us$l23 = {
        code: 'es',
        week: {
            dow: 0, // Sunday is the first day of the week.
            doy: 6, // The week that contains Jan 1st is the first week of the year.
        },
        prevText: 'Ant',
        nextText: 'Sig',
        todayText: 'Hoy',
        yearText: 'Año',
        monthText: 'Mes',
        weekText: 'Semana',
        weekTextShort: 'Sm',
        dayText: 'Día',
        listText: 'Agenda',
        prevHint: '$0 antes',
        nextHint: '$0 siguiente',
        todayHint(unitText, unit) {
            return (unit === 'day') ? 'Hoy' :
                ((unit === 'week') ? 'Esta' : 'Este') + ' ' + unitText.toLocaleLowerCase();
        },
        viewHint(unitText, unit) {
            return 'Vista ' + (unit === 'week' ? 'de la' : 'del') + ' ' + unitText.toLocaleLowerCase();
        },
        allDayText: 'Todo\nel día',
        moreLinkText: 'más',
        noEventsText: 'No hay eventos para mostrar',
    };

    globalLocales.push(__es_us$l23);

})(FullCalendar.Shared);
