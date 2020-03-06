// SummitEventsRegistrationOptionScripts

var appointmentsReady = (callback) => {
    if (document.readyState != "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

appointmentsReady(() => {
    let chooser = document.querySelector("#chooser");
    let allApptAddButtons = chooser.querySelectorAll(".appointmentAdd");
    allApptAddButtons.forEach(function (apptButton) {
        apptButton.addEventListener("click", (addAppt) => {
            console.log('Add Appointment fired');
            let Appt = apptButton.closest(".appointment");
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
                //move and adjust data
                let choosenArea = document.getElementById("choosen");
                let chooserArea = document.getElementById("chooser");
                let limit = Appt.dataset.limit;
                limit--;

                addAppt = document.createElement('div');
                addAppt.classList.add('slds-box', 'slds-box_small', 'slds-m-vertical_x-small', 'appointmentChoosen');
                console.log(addAppt.dataset);
                addAppt.dataset= Appt.dataset;

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

                //Create the remove button
                let removeButton = document.createElement('a');
                removeButton.classList.add('appointmentRemove');
                removeButton.textContent = ' Remove ';
                removeButton.addEventListener("click", function () {
                    let rmvAppt = removeButton.closest(".appointmentChoosen");
                    let origId = rmvAppt.dataset.origId;
                    let origAppt = chooserArea.querySelector('#' + origId);
                    origAppt.style.display = "block";
                    origAppt.dataset.limit = removeButton
                    choosenArea.removeChild(rmvAppt);
                    // let apptChoosen = docuemnt.querySelector('#chooser');
                    // let appt = removeButton.closest(".appointmentChoosen");
                    // let chooseId = apptChoose.origId;
                    // var appChooser = $('#' + aptChoosen.data('apptid'));
                    // appChooser.data('limit', appChooser.data('limit') + 1);
                    // appChooser.fadeIn("fast");
                    // aptChoosen.remove();


                    // removeAppt(removeButton);
                });
                addAppt.appendChild(removeButton);

                Appt.dataset.limit = limit;


                addAppt.id = 'appt-' + Appt.id;
                addAppt.dataset.origId = Appt.id;


                choosenArea.append(addAppt);

                if (Appt.dataset.limit < 1) {
                    Appt.style.display = "none";
                }

            }
        });
    });


    let accordionHeads = document.querySelectorAll(".slds-accordion__summary-heading");
    accordionHeads.forEach(function (ab) {
        ab.addEventListener("click", function () {
                let section = ab.closest('.appointment');
                if (section.classList.contains('slds-is-open')) {
                    section.classList.remove('slds-is-open')
                } else {
                    section.classList.add('slds-is-open')
                }
            }
        );
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