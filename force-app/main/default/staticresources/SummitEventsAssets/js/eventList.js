// SummitEventsScripts
var eventsObj, dMonth, dYear;
var overlay = '<div class="waiting-overlay"></div>';
//parse event cookie
var SESettings = JSON.parse(readCookie('SummitEvents'));
var fullCalType = 'month';

$(window).on('load resize', function () {
    getFullCalType();
});


function getFullCalType() {
    var curWidth = (window.innerWidth > 0) ? window.innerWidth : screen.width;
    if (curWidth >= 900) {
        fullCalType = 'month';
    } else {
        fullCalType = 'listMonth';
    }
    $("#fullCalendarView").fullCalendar('changeView', fullCalType);
}


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
            }
        }
    });


    $("#audienceDDwrap, #audienceDDwrap").append(overlay);

    $("#audienceDD").on("change", function () {
        eraseCookie('SummitEvents');
        createCookie('SummitEvents', '{"audience" : "' + $(this).val() + '"}', '');
        if ($(this).val() !== '') {
            //start loading in the list of events by audience
            loadJSONEvents();
        }
    });
    //initial load of dropdown audience type
    loadAudienceDD();
});

function setInstanceCookie(instanceID) {
    eraseCookie('SummitEvents');
    createCookie('SummitEvents', '{"audience" : "' + $("#audienceDD").val() + '", "instanceID" : "' + instanceID + '" }', '');
    return true;
}

function fullCalButtonEvts() {
    $('#fullCalendarView .fc-prev-button').click(function () {
        loadJSONEvents();
        //alert('prev is clicked, do something');
    });

    $('#fullCalendarView .fc-next-button').click(function () {
        loadJSONEvents();
        // alert('nextis clicked, do something');
    });
}

let feedURL = 'https://' + window.location.hostname + window.location.pathname;

function loadJSONEvents() {
    $("#dayEventList").html("<h3>Events</h3><p>Please select above to see events available to you.</p>");
    viewStart = getCurrentSOQLDateTimeLiteral($("#fullCalendarView").fullCalendar('getView').start).toString();
    viewEnd = getCurrentSOQLDateTimeLiteral($("#fullCalendarView").fullCalendar('getView').end).toString();
    $.ajax({
        url: feedURL + "/services/apexrest/summiteventsfeed",
        data: {'viewStart': viewStart, 'viewEnd': viewEnd, 'feedType': 'eventList', 'audience': $("#audienceDD").val()},
        dataType: "json",
        cache: false
    }).done(function (data) {
        eventsObj = data;
        if (!eventsObj.length) {
            $("#dayEventList").html("<h3>Events</h3><p>Sorry, no events for your particular settings at this time.</p>");
        }
        $("#fullCalendarView").fullCalendar('removeEvents');
        $("#fullCalendarView").fullCalendar('addEventSource', eventsObj);

    }).fail(function () {
        console.log("Error - Feed didn't load");
    }).always(function () {
        //alert( "complete" );
    });
}

function findEvents(edate, instanceID) {
    var evOut, niceDate, dateSplit, results;
    edate = getCurrentSOQLDateTimeLiteral(edate, true);
    niceDate = new Date(edate);
    if (instanceID) {
        results = $.grep(eventsObj, function (n, i) {
            return n.start.indexOf(edate) > -1;            //edate == n.startDate;
        });
    } else {
        edateSplit = edate.split("T");
        edate = edateSplit[0];
        results = $.grep(eventsObj, function (n, i) {
            return instanceID == n.id;            //edate == n.startDate;
        });
    }

    evOut = "<h3>Events on " + niceDate.toDateString() + "</h3><p>" + results.length + " results meet your criteria.</p>";
    evOut += "<table>";
    $.each(results, function (index, value) {
        evOut += "<tr>";
        evOut += "<td><p><strong>" + value.title + "</strong>";
        if (value.instanceTitle) {
            evOut += "<br>" + value.instanceTitle;
        }
        if (value.instanceDesc) {
            evOut += "<br>" + value.instanceDesc;
        }
        evOut += "</p>";
        if (value.Description) {
            evOut += "<p>" + value.Description + "</p>";
        }
        alert(value.eventClosed);
        if (value.eventClosed != true) {
            evOut += "<a href='/SummitEventsRegister?instanceID=" + value.ID + "&audience=" + encodeURI($("#audienceDD").val()) + "' class='button'>Register</a></td>"
        }
        evOut += "</tr>"
    });
    evOut += "</table>";
    $("#dayEventList").html(evOut);
}

function loadAudienceDD() {
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
            }
        }
        //reload the calendar with the new audience
        $("#fullCalendarView").fullCalendar('rerenderEvents');
    }).fail(function () {
        alert("error");
    }).always(function () {
        //alert( "complete" );
    });
}

function populateschSel(data, selector, keyAsText) {
    selector.find("option").remove();
    selector.append("<option value='' selected='selected'>Select...</option>");
    $.each(data, function (key, value) {
        selector.append($('<option>').text(value).attr('value', key));
    });
}

//Make a SOQL happy datetime with these two functions
function twoDigit(number) {
    var twodigit = number >= 10 ? number : "0" + number.toString();
    return twodigit;
}

function getCurrentSOQLDateTimeLiteral(dt, addTZ) {
    if (!dt) {
        dt = new Date()
    } else {
        dt = new Date(dt);
    }
    var soqlDTLiteral = dt.getUTCFullYear() + '-' + twoDigit(dt.getUTCMonth() + 1) + '-' + twoDigit(dt.getUTCDate());
    if (addTZ) {
        soqlDTLiteral += 'T';
    } else {
        soqlDTLiteral += ' ';
    }
    soqlDTLiteral += twoDigit(dt.getUTCHours()) + ':' + twoDigit(dt.getUTCMinutes()) + ':' + twoDigit(dt.getUTCSeconds());
    if (addTZ) {
        soqlDTLiteral += 'Z';
    }
    return soqlDTLiteral;
}

function createCookie(name, value, days) {
    var expires;

    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toGMTString();
    } else {
        expires = "";
    }
    document.cookie = encodeURIComponent(name) + "=" + encodeURIComponent(value) + expires + "; path=/";
}

function readCookie(name) {
    var nameEQ = encodeURIComponent(name) + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
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