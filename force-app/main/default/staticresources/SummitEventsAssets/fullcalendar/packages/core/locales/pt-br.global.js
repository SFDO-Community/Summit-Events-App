/*!
FullCalendar Core v6.0.1
Docs & License: https://fullcalendar.io
(c) 2022 Adam Shaw
*/
(function (index_js) {
    'use strict';

    var locale = {
        code: 'pt-br',
        buttonText: {
            prev: 'Anterior',
            next: 'Próximo',
            today: 'Hoje',
            month: 'Mês',
            week: 'Semana',
            day: 'Dia',
            list: 'Lista',
        },
        weekText: 'Sm',
        allDayText: 'dia inteiro',
        moreLinkText(n) {
            return 'mais +' + n;
        },
        noEventsText: 'Não há eventos para mostrar',
    };

    index_js.globalLocales.push(locale);

})(FullCalendar);
