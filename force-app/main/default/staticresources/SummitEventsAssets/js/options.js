// SummitEventsRegistrationOptionScripts

var appointmentsReady = (callback) => {
    if (document.readyState != "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

appointmentsReady(() => {

    //Initialize accordion toggles.
    let accordionHeads = document.querySelectorAll(".slds-accordion__summary-heading");
    accordionHeads.forEach(function (ab) {
        ab.addEventListener("click", function (e) {
            e.preventDefault();
            let section = ab.closest('.appointment');
            if (section.classList.contains('slds-is-open')) {
                section.classList.remove('slds-is-open')
            } else {
                section.classList.add('slds-is-open')
            }
        });
    });

    let chooser = document.querySelector("#chooser");
    let chosen = document.getElementById("chosen");

    //Initiate remove buttons that already exist
    let chosenRemoveButtons = chosen.querySelectorAll('.appointmentRemove');
    chosenRemoveButtons.forEach(function (removeBtn) {
        removeBtn.addEventListener('click', function () {
            removeSelectedOption(removeBtn);
        });
    });


    //Initiate add buttons in chooser column
    let allApptAddButtons = chooser.querySelectorAll(".appointmentAdd");

    allApptAddButtons.forEach(function (apptButton) {
        apptButton.addEventListener("click", (addAppt) => {
            addAppt.preventDefault();
            let Appt = apptButton.closest(".appointment");

            //check for required fields
            let error = false;
            let requiredInputs = Appt.querySelectorAll('.slds-is-required');
            requiredInputs.forEach(function (reqs) {
                let reqAppt = reqs.closest(".appointment");
                let incomingValue = '';
                if (reqAppt.querySelector(".appointmentType")) {
                    let selType = Appt.querySelector(".appointmentType");
                    incomingValue = selType.options[selType.selectedIndex].value;
                }
                if (reqAppt.querySelector(".appointmentCustomInput")) {
                    let inputType = Appt.querySelector(".appointmentCustomInput");
                    incomingValue = inputType.value;
                }
                if (!incomingValue) {
                    reqAppt.classList.add('slds-has-error');
                    error = true;
                }
            });

            if (!error) {
                //move and adjust data
                let chosenArea = document.getElementById("chosen");

                let limit = Appt.dataset.limit;

                addAppt = document.createElement('div');
                addAppt.classList.add('slds-box', 'slds-box_small', 'slds-m-vertical_x-small', 'appointmentChosen');
                Object.assign(addAppt.dataset, Appt.dataset);

                let appTitle = document.createElement('p');
                addAppt.classList.add('appointmentTitle', 'slds-text-body', 'slds-m-vertical_small');
                let findTitle = Appt.querySelector(".appointmentTitle");
                appTitle.textContent = findTitle.textContent;
                addAppt.append(appTitle);

                let desc = '';
                if (Appt.querySelector(".appointmentType")) {
                    let selType = Appt.querySelector(".appointmentType");
                    desc += selType.options[selType.selectedIndex].value;
                }

                if (Appt.querySelector(".appointmentCustomInput")) {
                    let inputType = Appt.querySelector(".appointmentCustomInput");
                    desc += inputType.value;
                }

                if (desc) {
                    let apptDesc = document.createElement('p');
                    apptDesc.classList.add('appointmentDesc', 'slds-text-body', 'slds-p-vertical_small');
                    apptDesc.textContent = desc;
                    addAppt.append(apptDesc);
                }

                //Create the remove button
                let removeButton = document.createElement('a');
                removeButton.classList.add('appointmentRemove', 'slds-button', 'slds-button_neutral');
                removeButton.textContent = ' Remove ';
                removeButton.addEventListener("click", function (evt) {
                    evt.preventDefault();
                    removeSelectedOption(removeButton)
                });
                addAppt.appendChild(removeButton);

                addAppt.id = 'appt' + limit + '-' + Appt.id;
                Appt.dataset.limit = String(limit - 1);

                chosenArea.append(addAppt);

                //remove all values from hidden appointments.
                if (Appt.classList.contains('slds-has-error')) {
                    Appt.classList.remove('slds-has-error');
                }

                if (Appt.querySelector(".appointmentType")) {
                    let selType = Appt.querySelector(".appointmentType");
                    desc += selType.options[selType.selectedIndex].value = '';
                }

                if (Appt.querySelector(".appointmentCustomInput")) {
                    let inputType = Appt.querySelector(".appointmentCustomInput");
                    desc += inputType.value = '';
                }

                if (Appt.dataset.limit < 1) {
                    Appt.style.display = "none";
                }

            }
        });
    });

});

function removeSelectedOption(removeButton) {
    let chooserArea = document.getElementById("chooser");
    let chosenArea = document.getElementById("chosen");
    let rmvAppt = removeButton.closest(".appointmentChosen");
    let origAppt = chooserArea.querySelector('#' + rmvAppt.dataset.apptid);
    origAppt.classList.remove('slds-is-open');
    origAppt.style.display = "block";
    chosenArea.removeChild(rmvAppt);
}


function populateApptJSON() {
    let jsonOut = [];
    let chosen = document.getElementById('chosen');
    let allChosen = chosen.querySelectorAll('.appointmentChosen');
    let pWithPad = document.createElement('p');
    pWithPad.classList.add('slds-p-vertical_small');
    allChosen.forEach(function (appointment) {
        let appt = {};
        appt['apptId'] = appointment.dataset.apptid;
        appt['apptCatagory'] = appointment.dataset.apptcat;
        appt['apptType'] = appointment.dataset.appttype;
        appt['apptText'] = appointment.dataset.appttext;
        appt['apptTitle'] = appointment.dataset.appttitle;
        appt['appChosenState'] = appointment.dataset.appchosenstate;
        appt['appSort'] = appointment.dataset.appsort;
        appt['appInput'] = appointment.dataset.appinput;
        let apptDesc = appointment.querySelector('.appointmentDesc');
        if (apptDesc) {
            appt['appDesc'] = apptDesc.textContent;
        }
        jsonOut.push(appt);
    });
    let hiddenData = document.querySelectorAll('[id$=outgoingApptJSon]');
    hiddenData.forEach(function (hidedata) {
        hidedata.value = JSON.stringify(jsonOut);
    });
    return checkForRequiredAppointments();
}

function checkForRequiredAppointments() {
    let chooser = document.getElementById('chooser');
    let requiredAppointments = chooser.querySelectorAll('.appointmentRequired');
    let allApptGood = true;
    requiredAppointments.forEach(function (appt) {
        if (window.getComputedStyle(appt).display !== "none") {
            allApptGood =  false;
            appt.classList.add('slds-has-error');
            if (!appt.classList.contains('slds-is-open')) {
                appt.classList.add('slds-is-open');
            }
            fadein();
        }
    });
    return allApptGood;
}