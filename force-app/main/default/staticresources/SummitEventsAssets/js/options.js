// SummitEventsRegistrationOptionScripts

var appointmentsReady = (callback) => {
    if (document.readyState != "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

appointmentsReady(() => {
    document.querySelectorAll("#chooser .appointmentAdd").forEach( apptClick => {

        let addAppt;
        let Appt = apptClick.closest(".appointment");
        let requiredSel = Appt.querySelectorAll('.required');
        let error = false;
        if (requiredSel.length > 0) {
            if (requiredSel.value === '') {
                error = true;
                requiredSel.classList.add('aptError');
                requiredSel.addEventListener('change', (err) => {
                    err.classList.remove("aptError");
                });
            }
        }

        if (!error) {

            // //build a box
            // var ApptOffset = Appt.offset();
            // var lc;
            // var movingBox = $("<div/>", {id: 'movingBox' + Appt.attr("id"), class: 'slds-box slds-box_small slds-theme_shade'});
            // movingBox.css({
            //     "width": (Appt.width() + 1) + 'px',
            //     "height": (Appt.height() + 1) + 'px',
            //     "left": ApptOffset.left + 'px',
            //     "top": ApptOffset.top + 'px',
            //     "position": "absolute"
            // });
            // movingBox.html('<p>Adding Appointment...</p>')
            // $('body').before(movingBox);
            // if ($("#choosen .appointmentChoosen:last-child").length > 0) {
            //     lc = $("#choosen .appointmentChoosen:last-child");
            // } else {
            //     lc = $("#choosen");
            // }
            // var lcOffset = lc.offset();
            // movingBox.delay(300).animate({'top': (lcOffset.top + lc.height() + 10) + 'px', 'left': lcOffset.left + 'px', "height": "0px", "opacity": 0}, 300).fadeOut(100, function () {
            //     $(this).remove();
            // });

            //move and adjust data
            var limit = Appt.dataset.limit;

            limit--;

            addAppt = document.createElement('div');
            addAppt.classList.add('slds-box', 'slds-box_small', 'slds-m-vertical_x-small');

            let appTitle = document.createElement('p');
            addAppt.classList.add('appointmentTitle');
            let findTitle = Appt.querySelector(".appointmentTitle");
            appTitle.textContent = findTitle.textContent;
            addAppt.append(appTitle);

            if (Appt.querySelectorAll(".appointmentType").length > 0) {
                let apptType = document.createElement('p');
                apptType.classList.add('appointmentType');
                let selType = Appt.querySelector(".appointmentType");
                apptType.textContent = selType.options[selType.selectedIndex].value;
                addAppt.append(apptType);
            }

            if (Appt.querySelectorAll(".appointmentCustomInput").length > 0) {
                let apptDesc = document.createElement('p');
                apptDesc.classList.add('appointmentDesc');
                apptDesc.textContent = Appt.querySelector(".appointmentCustomInput").value;
                addAppt.append(apptDesc);
            }

            addAppt.append(
                $('<a/>', {class: "appointmentRemove"})
                    .html(' Remove ')
                    .on("click", function () {
                        removeAppt($(this));
                    })
            );

            Appt.dataset.limit = limit;

            addAppt.dataset = Appt.dataset;
            addAppt.id = 'appt-' + Appt.id;

            let choosenArea = document.getElementById("choosen");
            choosenArea.append(addAppt)

        }
    });


    $(".slds-accordion__summary-heading").on("click", function () {
        let section = $(this).closest('section');
        if (section.hasClass('slds-is-open')) {
            section.removeClass('slds-is-open')
        } else {
            section.addClass('slds-is-open')
        }
    });

});


function removeAppt(rmvBtn) {
    var aptChoosen = rmvBtn.closest(".appointmentChoosen");
    var appChooser = $('#' + aptChoosen.data('apptid'));
    appChooser.data('limit', appChooser.data('limit') + 1);
    appChooser.fadeIn("fast");
    aptChoosen.remove();
}

function populateApptJSON() {
    jsonOut = [];
    $("#choosen div.appointmentChoosen").each(function () {
        appt = {};
        appt['apptId'] = $(this).data('apptid');
        appt['apptCatagory'] = $(this).data('apptcat');
        appt['apptType'] = $(this).data('appttype');
        appt['apptText'] = $(this).data('appttext');
        appt['apptTitle'] = $(this).data('appttitle');
        appt['appChosenState'] = $(this).data('appchosenstate');
        appt['appSort'] = $(this).data('appsort');
        appt['appInput'] = $(this).data('appinput');
        appt['appDesc'] = $(this).find('.appointmentDesc').html();
        jsonOut.push(appt);
    });
    $('[id$=outgoingApptJSon]').val(JSON.stringify(jsonOut));
    //console.log(JSON.stringify(jsonOut));
    return checkForRequiredAppointments();
}

function checkForRequiredAppointments() {
    allApptGood = true;
    $.each($('#chooser .appointmentRequired'), function () {
        if ($(this).is(':visible')) {
            allApptGood = false;
            fadein();
            if ($(this).find("i.fa").hasClass('fa-chevron-down')) {
                $(this).find("a.optionToggler").click();
            }
            $(this).css({borderColor: 'red'});
            $(".requiredSelectionLabel").css({'color': 'black', 'opacity': .5});
            $(".requiredSelectionLabel").animate({
                opacity: 1,
                color: 'red',
                fontWeight: 'bold'
            }, 1000, function () {
                // Animation complete.
            });
        }
    });
    return allApptGood;
}