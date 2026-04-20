/*!
FullCalendar (Vanilla JS) v7.0.0-rc.1
Docs & License: https://fullcalendar.io
(c) 2025 Adam Shaw
*/
(function ({ F: globalLocales }) {
    

    function __de$affix(unitText) {
        return (unitText === 'Tag' || unitText === 'Monat') ? 'r' :
            unitText === 'Jahr' ? 's' : '';
    }
    var __de$l17 = {
        code: 'de',
        week: {
            dow: 1, // Monday is the first day of the week.
            doy: 4, // The week that contains Jan 4th is the first week of the year.
        },
        prevText: 'Zurück',
        nextText: 'Vor',
        todayText: 'Heute',
        yearText: 'Jahr',
        monthText: 'Monat',
        weekText: 'Woche',
        weekTextShort: 'KW',
        dayText: 'Tag',
        listText: 'Terminübersicht',
        allDayText: 'Ganztägig',
        moreLinkText(n) {
            return '+ weitere ' + n;
        },
        noEventsText: 'Keine Ereignisse anzuzeigen',
        prevHint(unitText) {
            return `Vorherige${__de$affix(unitText)} ${unitText}`;
        },
        nextHint(unitText) {
            return `Nächste${__de$affix(unitText)} ${unitText}`;
        },
        todayHint(unitText) {
            // → Heute, Diese Woche, Dieser Monat, Dieses Jahr
            if (unitText === 'Tag') {
                return 'Heute';
            }
            return `Diese${__de$affix(unitText)} ${unitText}`;
        },
        viewHint(unitText) {
            // → Tagesansicht, Wochenansicht, Monatsansicht, Jahresansicht
            const glue = unitText === 'Woche' ? 'n' : unitText === 'Monat' ? 's' : 'es';
            return unitText + glue + 'ansicht';
        },
        navLinkHint: 'Gehe zu $0',
        moreLinkHint(eventCnt) {
            return 'Zeige ' + (eventCnt === 1 ?
                'ein weiteres Ereignis' :
                eventCnt + ' weitere Ereignisse');
        },
        closeHint: 'Schließen',
        eventsHint: 'Ereignisse',
    };

    globalLocales.push(__de$l17);

})(FullCalendar.Shared);
