var eventsObj, dMonth, dYear;
var calendarEl = document.getElementById('fullCalendarView');
var feedURL = 'https://' + window.location.hostname;
if (window.location.pathname !== undefined) {
    feedURL += window.location.pathname;
}
var audience;
const overlay = '<div class="waiting-overlay"></div>';
var SESettings = JSON.parse(readCookie('SummitEvents'));
loadAudienceDD();

function getCalView() {
    let initialView = 'dayGridMonth';
    if (window.innerWidth <= 900) {
        initialView = 'listMonth';
    }
    return initialView;
}

<<<<<<< HEAD

document.addEventListener('DOMContentLoaded', function () {
    var calendarEl = document.getElementById('fullCalendarView');
    getFullCalType();

    var calendar = new Calendar(calendarEl, {
        defaultView: fullCalType,
        height: 'auto',
        events: eventsObj,
        viewRender: function (event, element) {
            loadJSONEvents();
            fullCalButtonEvts();
        },
        eventRender: function (event, $el) {
            var evtTmplt = '';
            var evtDesc = '';
            var eventClass = "SummitEventsItem";
            if (event.eventClosed) {
                eventClass += " ustEventItemClosed";
            }
            if (event.description != null) {
                evtDesc = event.description;
            }
            if (fullCalType == 'month') {
                evtTmplt = '<div class="' + eventClass + ' ustMonthView"><p>';
                if (!event.eventClosed) {
                    evtTmplt += '<a href="' + event.eventUrl + '&audience=' + $("#audienceDD").val() + '" onclick="return setInstanceCookie(' + event.ID + ');" title="' + evtDesc + '">' + event.title + '</a>';
                } else {
                    evtTmplt += '<a href="' + event.eventUrl + '" title="<em>Event Closed</em><br/>' + evtDesc + '"><em>' + event.title + '</em></a>';
                }
                evtTmplt += '</p></div>';
                $el.find('.fc-title').closest('.fc-content').html(evtTmplt);
            } else {
                evtTmplt = '<div class="' + eventClass + ' ustListView">';
                if (!event.eventClosed) {
                    evtTmplt += '<p><a href="' + event.eventUrl + '&audience=' + $("#audienceDD").val() + '" onclick="return setInstanceCookie(' + event.ID + ');" class="SummitEventsTitle"><strong>' + event.title + '</strong></a></p>';
                } else {
                    evtTmplt += '<p class="SummitEventsTitle"><strong>' + event.title + '</strong> <em> - Event closed</em></p>';
                }
                if (evtDesc) {
                    evtTmplt += '<p>' + evtDesc + '</p>';
                }
                if (!event.eventClosed) {
                    evtTmplt += '<p><a href="' + event.eventUrl + '&audience=' + $("#audienceDD").val() + '" onclick="return setInstanceCookie(' + event.ID + ');" class="button">Register</a></p>';
                }
                $el.find('.fc-list-item-title').html(evtTmplt);
                $el.find('.fc-list-item-time, .fc-list-item-marker').remove();
=======
var calendar = new FullCalendar.Calendar(calendarEl, {
    initialView: getCalView(),
    handleWindowResize: true,
    events: {
        url: feedURL + "services/apexrest/summiteventsfeed",
        extraParams: function () {
            return {
                'feedType': 'eventList',
                'audience': document.getElementById("audienceDD").value
>>>>>>> origin/master
            }
        },
    },
    eventDataTransform: function(rawEventData) {
        return {
            id: rawEventData.Id,
            title: rawEventData.title,
            url: rawEventData.eventUrl,
            start: rawEventData.start,
            end: rawEventData.end,
            description: rawEventData.description
        };
    },
    eventDisplay: 'block',
    eventTextColor : '#000',
    windowResize: function (arg) {
        this.view.type = getCalView();
    },
    eventClick: function (info) {
        info.jsEvent.preventDefault();
        if (info.event.url) {
            window.open(info.event.url);
        }
    }
    // eventContent: function (info) {
    //     let evtTmplt = '';
    //     let evtDesc = '';
    //     let eventClass = "SummitEventsItem";
    //     let audience = document.getElementById("audienceDD").value;
    //     if (info.event.eventClosed) {
    //         eventClass += " ustEventItemClosed";
    //     }
    //     if (info.event.description != null) {
    //         evtDesc = info.event.description;
    //     }
    //     let wrap = document.createElement('div');
    //     wrap.classList.add(eventClass);
    //     let link = document.createElement('a');
    //     link.href = info.event.url + '&audience=' + audience;
    //     link.target = '_blank';
    //     link.innerText = info.event.title;
    //     wrap.append(link);
    //    // if (fullCalType == 'month') {
    //    //      evtTmplt = '<div class="' + eventClass + ' ustMonthView"><p>';
    //    //      if (!info.event.eventClosed) {
    //    //          evtTmplt += '<a href="' + info.event.eventUrl + '&audience=' + audience + '" onclick="return setInstanceCookie(' + event.ID + ');" title="' + evtDesc + '">' + event.title + '</a>';
    //    //      } else {
    //    //          evtTmplt += '<a href="' + info.event.eventUrl + '" title="<em>Event Closed</em><br/>' + evtDesc + '"><em>' + event.title + '</em></a>';
    //    //      }
    //    //      evtTmplt += '</p></div>';
    //        // info.find('.fc-title').closest('.fc-content').html(evtTmplt);
    //     // } else {
    //     //     evtTmplt = '<div class="' + eventClass + ' ustListView">';
    //     //     if (!info.event.eventClosed) {
    //     //         evtTmplt += '<p><a href="' + info.event.eventUrl + '&audience=' + audience + '" onclick="return setInstanceCookie(' + event.ID + ');" class="SummitEventsTitle"><strong>' + event.title + '</strong></a></p>';
    //     //     } else {
    //     //         evtTmplt += '<p class="SummitEventsTitle"><strong>' + event.title + '</strong> <em> - Event closed</em></p>';
    //     //     }
    //     //     if (evtDesc) {
    //     //         evtTmplt += '<p>' + evtDesc + '</p>';
    //     //     }
    //     //     if (!info.event.eventClosed) {
    //     //         evtTmplt += '<p><a href="' + info.event.eventUrl + '&audience=' + audience + '" onclick="return setInstanceCookie(' + event.ID + ');" class="button">Register</a></p>';
    //     //     }
    //     //
    //     // }
    //     let arrayOfDomNodes = [ wrap ]
    //     return { domNodes: arrayOfDomNodes }
    // }
});

<<<<<<< HEAD

    $("#audienceDDwrap, #audienceDDwrap").append(overlay);
=======
calendar.render();
>>>>>>> origin/master

document.getElementById("audienceDD").addEventListener('change', function () {
    eraseCookie('SummitEvents');
    createCookie('SummitEvents', '{"audience" : "' + $(this).val() + '"}', '');
    calendar.refetchEvents();
});

function setInstanceCookie(instanceID) {
    eraseCookie('SummitEvents');
    createCookie('SummitEvents', '{"audience" : "' + $("#audienceDD").val() + '", "instanceID" : "' + instanceID + '" }', '');
    return true;
}

function loadAudienceDD() {
<<<<<<< HEAD
    $.ajax({
        url: feedURL + "/services/apexrest/summiteventsfeed",
        data: {'feedType': 'audienceDD'},
        dataType: "json"
    }).done(function (data) {
        populateschSel(data, $("#audienceDD"))
        $("#audienceDDwrap .waiting-overlay").remove();

        //preselect audience based on cookie
        if (SESettings != null) {
            if (SESettings.audience != null) {
                $("#audienceDD").val(SESettings.audience);
                loadJSONEvents();
=======
    fetch(
        feedURL + "services/apexrest/summiteventsfeed?feedType=audienceDD"
    ).then((resp) => resp.json())
        .then(function (data) {
            populateschSel(data, document.getElementById("audienceDD"))
            // $("#audienceDDwrap .waiting-overlay").remove();
            //preselect audience based on cookie
            if (SESettings != null) {
                if (SESettings.audience != null) {
                    document.getElementById("audienceDD").value = SESettings.audience;
                }
>>>>>>> origin/master
            }
            calendar.refetchEvents();
        }).catch(function (error) {
        console.log(error);
    });
}

function populateschSel(data, selector, keyAsText) {
    selector.innerHTML = '';
    let opt1 = document.createElement("option");
    opt1.value = '';
    opt1.text = 'Select...';
    selector.append(opt1);
    for (const [key, value] of Object.entries(data)) {
        let opt2 = document.createElement("option");
        opt2.value = value;
        opt2.text = key;
        selector.append(opt2);
    }
}

function createCookie(name, value, days) {
    let expires;

    if (days) {
        let date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toGMTString();
    } else {
        expires = "";
    }
    document.cookie = encodeURIComponent(name) + "=" + encodeURIComponent(value) + expires + "; path=/";
}

function readCookie(name) {
    let nameEQ = encodeURIComponent(name) + "=";
    let ca = document.cookie.split(';');
    for (let i = 0; i < ca.length; i++) {
        let c = ca[i];
        while (c.charAt(0) === ' ')
            c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) === 0)
            return decodeURIComponent(c.substring(nameEQ.length, c.length));
    }
    return null;
}

function eraseCookie(name) {
    createCookie(name, "", -1);
}