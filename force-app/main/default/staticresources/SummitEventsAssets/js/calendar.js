let ready = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

ready(() => {
    initCalendar();
});

const hideInstanceTitle = true;
let calendar
let eventCount = 0;

function initCalendar() {
    const calendarEl = document.getElementById('fullCalendarView');
    const audienceDD = document.getElementById('audienceDD');
    const hideCalendarUntilAudience = false;

    if (audienceDD) {
        loadAudienceDD();
    }
    calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: getCalView(),
        handleWindowResize: true,
        events: {
            url: feedURL,
            extraParams: function () {
                return {
                    'feedType': 'eventList',
                    'audience': getAudienceDDValue()
                }
            },
        },
        eventDataTransform: function (rawEventData) {
            return {
                id: rawEventData.Id,
                title: rawEventData.title,
                url: rawEventData.eventUrl,
                start: rawEventData.start.replace('Z', ''),
                end: rawEventData.end.replace('Z', ''),
                description: rawEventData.description,
                className: rawEventData.className,
            };
        },
        eventDisplay: 'auto',
        eventTextColor: '#000',
        eventContent: function (info) {
            eventCount++;
            let toolTipId = 'tool-tip-' + eventCount;
            let wrap = document.createElement('div');
            let eventTitle = info.event.title;
            if (hideInstanceTitle) {
                let eventTitleArr = eventTitle.split('-');
                eventTitle = '';
                for (let xx = 0; xx < eventTitleArr.length - 1; xx++) {
                    if (xx > 0) {
                        eventTitle += ' - '
                    }
                    eventTitle += eventTitleArr[xx].trim();
                }
            }
            wrap.classList.add('SummitEventsItem', 'aria-describedby-tooltip');
            wrap.setAttribute('aria-describedby', toolTipId)

            let titleWrap = document.createElement('span');
            titleWrap.classList.add('summitEventsTitle');

            if (info.event.classNames !== 'eventClosed') {
                titleWrap.innerHTML = eventTitle
                wrap.addEventListener('click', function (e) {
                    e.preventDefault();
                    window.open(info.event.url, 'new_window');
                });
            } else {
                titleWrap.innerHTML = eventTitle + '<br><em>Event is closed.</em>';
            }

            let descWrap = document.createElement('div');
            descWrap.classList.add('summitEventsDesc');
            descWrap.innerHTML = info.event.extendedProps.description;
            let timeWrap = document.createElement('div');
            timeWrap.classList.add('summitEventsTimes');
            let startTime = formatTimeString(info.event.start.toLocaleString());
            let endTime = formatTimeString(info.event.end.toLocaleString());
            timeWrap.innerHTML = startTime + ' - ' + endTime;
            wrap.append(titleWrap);
            if (info.view.type === 'dayGridMonth') {
                wrap.append(timeWrap);
            } else {
                wrap.append(descWrap);
            }
            let tooltip = document.createElement('div')
            tooltip.id = toolTipId;
            tooltip.classList.add('slds-popover', 'slds-popover_tooltip', 'slds-fall-into-ground');
            tooltip.style.position = 'absolute';
            let tooltipDesc = document.createElement('div');
            tooltipDesc.classList.add('slds-popover__body');
            tooltipDesc.style.whiteSpace = 'normal';
            tooltipDesc.innerHTML = info.event.extendedProps.description;
            tooltip.append(tooltipDesc);
            let calWrap = document.getElementById('eventCalWrap');
            calWrap.parentNode.insertBefore(tooltip, calWrap.nextSibling);
            let arrayOfDomNodes = [wrap]
            return {domNodes: arrayOfDomNodes}
        },
        windowResize: function (arg) {
            this.changeView(getCalView());
            this.refetchEvents();
            activateTooltips();
        },
        eventDidMount: function () {
            activateTooltips();
        }
    });

    calendar.render();

    if (audienceDD) {
        audienceDD.addEventListener('change', function () {
            eraseCookie('SummitEvents');
            createCookie('SummitEvents', '{"audience" : "' + getAudienceDDValue() + '"}', '');
            if (getAudienceDDValue() === '' && hideCalendarUntilAudience) {
                calendarEl.style.visibility = "hidden";
            } else {
                calendarEl.style.visibility = "visible";
            }
            calendar.refetchEvents();
        });
    }

}

function getCalView() {
    let initialView = 'dayGridMonth';
    if (window.innerWidth <= 900) {
        initialView = 'listMonth';
    }
    return initialView;
}

function formatTimeString(stringIn) {
    let stringOut;
    stringIn = stringIn.split(',');
    stringIn = stringIn[stringIn.length - 1];
    let first = stringIn.indexOf(',');
    let last = stringIn.lastIndexOf(":");
    stringOut = stringIn.substring(stringIn, last);
    stringOut += stringIn.substring(last + 3, stringIn.length);
    return stringOut;
}

function getAudienceDDValue() {
    let audienceDDValue = '';
    if (audienceDD) {
        audienceDDValue = audienceDD.value;
    }
    if (audienceDDValue === 'Select...') {
        audienceDDValue = '';
    }
    return audienceDDValue;
}

function loadAudienceDD() {
    fetch(
        feedURL + "?feedType=audienceDD"
    ).then((resp) => resp.json())
        .then(function (data) {
            populateOptions(data, audienceDD)
            //preselect audience based on cookie
            const SESettings = JSON.parse(readCookie('SummitEvents'));
            if (SESettings != null) {
                if (SESettings.audience != null) {
                    audienceDD.value = SESettings.audience;
                }
            }
            calendar.refetchEvents();
            if (getAudienceDDValue() === '' && hideCalendarUntilAudience) {
                calendarEl.style.visibility = "hidden";
            }
        }).catch(function (error) {
        console.log(error);
    });
}

function populateOptions(data, selector, keyAsText) {
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

/* Tooltip */
function activateTooltips() {
    document.querySelectorAll('.aria-describedby-tooltip').forEach(item => {
        let toolTipElement = document.getElementById(item.getAttribute('aria-describedby'));
        if (toolTipElement && getCalView() !== 'listMonth') {
            toolTipElement.style.cssText = 'position:absolute; min-width:150px; max-width:250px; z-index:99';
            item.addEventListener('mousemove', function (e) {
                let toolTipOffsetElem = toolTipElement.offsetParent;
                toolTipElement.classList.remove('slds-fall-into-ground', 'slds-nubbin_left', 'slds-nubbin_right');
                toolTipElement.classList.add('slds-rise-from-ground');
                let leftPosition = (e.clientX - toolTipOffsetElem.getBoundingClientRect().x + 15);
                let topPosition = (e.clientY - toolTipOffsetElem.getBoundingClientRect().y + 25);
                if (document.body.clientWidth < toolTipElement.clientWidth + e.clientX) {
                    toolTipElement.classList.add('slds-nubbin_top-right');
                    leftPosition = leftPosition - (toolTipElement.clientWidth);
                } else {
                    toolTipElement.classList.add('slds-nubbin_top-left');
                    leftPosition = leftPosition - 10;
                }
                toolTipElement.style.left = leftPosition + 'px';
                toolTipElement.style.top = topPosition + 'px';
            });
            item.addEventListener('mouseleave', function (e) {
                toolTipElement.classList.remove('slds-rise-from-ground');
                toolTipElement.classList.add('slds-fall-into-ground');
            });
        }
    });
}