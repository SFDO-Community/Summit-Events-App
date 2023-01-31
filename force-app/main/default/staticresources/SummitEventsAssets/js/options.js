// SummitEventsRegistrationOptionScripts

const appointmentsReady = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

const regExSingle = /'*'/g;
const regExDouble = /"*"/g;

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

    document.querySelectorAll('.appointmentDesc').forEach(title => {
        title.innerHTML = title.innerHTML.replaceAll('&amp;#39;', '\'');
        title.innerHTML = title.innerHTML.replaceAll('&amp;quot;', '\"');
        title.innerHTML = title.innerHTML.replace(regExSingle, '\'');
        title.innerHTML = title.innerHTML.replace(regExDouble, '\"');
    })


    //Initiate add buttons in chooser column
    chooser.querySelectorAll(".appointmentAdd").forEach(function (appButton) {
        appButton.addEventListener("click", (addAppointment) => {
            addAppointment.preventDefault();
            let appointment = appButton.closest(".appointment");

            //check for required fields
            let error = false;
            let requiredInputs = appointment.querySelectorAll('.slds-is-required');
            requiredInputs.forEach(function (reqs) {
                let reqApp = reqs.closest(".appointment");
                let incomingValue = '';
                if (reqApp.querySelector(".appointmentType")) {
                    let selType = appointment.querySelector(".appointmentType");
                    incomingValue = selType.options[selType.selectedIndex].value;
                }
                if (reqApp.querySelector(".appointmentCustomInput")) {
                    let inputType = appointment.querySelector(".appointmentCustomInput");
                    incomingValue = inputType.value;
                }
                if (!incomingValue) {
                    reqApp.classList.add('slds-has-error');
                    error = true;
                }
            });

            if (!error) {
                //move and adjust data
                let chosenArea = document.getElementById("chosen");

                let limit = appointment.dataset.limit;

                addAppointment = document.createElement('div');
                addAppointment.classList.add('slds-box', 'slds-box_small', 'slds-m-vertical_x-small', 'appointmentChosen');
                Object.assign(addAppointment.dataset, appointment.dataset);
                addAppointment.classList.add('appointmentTitle', 'slds-text-body', 'slds-m-vertical_small');

                let appTitle = document.createElement('div');
                appTitle.classList.add('slds-text-heading_small', 'slds-p-bottom_x-small');
                let findTitle = appointment.querySelector(".appointmentTitle");
                appTitle.textContent = findTitle.textContent;
                addAppointment.append(appTitle);

                let appDescription = document.createElement('div');
                appDescription.classList.add('slds-text-body_regular');
                let findDescription = appointment.querySelector('.appointmentDesc');
                appDescription.textContent = findDescription.textContent;
                addAppointment.append(appDescription);

                let registrantInput = '';
                if (appointment.querySelector(".appointmentType")) {
                    let selType = appointment.querySelector(".appointmentType");
                    registrantInput += selType.options[selType.selectedIndex].value;
                }

                if (appointment.querySelector(".appointmentCustomInput")) {
                    let inputType = appointment.querySelector(".appointmentCustomInput");
                    registrantInput += inputType.value;
                }

                if (registrantInput) {
                    registrantInput = registrantInput.replace(regExDouble, '\"').replace(regExSingle, '\'');
                    let appDesc = document.createElement('div');
                    appDesc.classList.add('appointmentDesc', 'slds-text-body_regular', 'slds-p-top_x-small');
                    appDesc.textContent = registrantInput;
                    addAppointment.append(appDesc);
                }

                addAppointment.dataset.appinput = registrantInput;

                //Create the remove button
                let removeButton = document.createElement('a');
                removeButton.classList.add('appointmentRemove', 'slds-button', 'slds-button_neutral', 'slds-m-top_small');
                removeButton.textContent = ' Remove ';
                removeButton.addEventListener("click", function (evt) {
                    evt.preventDefault();
                    removeSelectedOption(removeButton)
                });
                addAppointment.appendChild(removeButton);

                addAppointment.id = 'app' + limit + '-' + appointment.id;
                appointment.dataset.limit = String(limit - 1);

                chosenArea.append(addAppointment);

                //remove all values from hidden appointments.
                if (appointment.classList.contains('slds-has-error')) {
                    appointment.classList.remove('slds-has-error');
                }

                if (appointment.classList.contains('appointment-has-error')) {
                    appointment.classList.remove('appointment-has-error');
                }

                if (appointment.querySelector(".appointmentType")) {
                    let selType = appointment.querySelector(".appointmentType");
                    registrantInput += selType.options[selType.selectedIndex].value = '';
                }

                if (appointment.querySelector(".appointmentCustomInput")) {
                    let inputType = appointment.querySelector(".appointmentCustomInput");
                    registrantInput += inputType.value + '';
                }

                if (appointment.dataset.limit < 1) {
                    appointment.style.display = "none";
                }

            }
        });
    });

});

function removeSelectedOption(removeButton) {
    let chooserArea = document.getElementById("chooser");
    let chosenArea = document.getElementById("chosen");
    let rmvApp = removeButton.closest(".appointmentChosen");
    let origApp = chooserArea.querySelector('#' + rmvApp.dataset.appid);
    origApp.classList.remove('slds-is-open');
    origApp.style.display = "block";
    chosenArea.removeChild(rmvApp);
}


function populateAppJSON() {
    let allAppGood = checkForRequiredAppointments();
    if (allAppGood) {
        let jsonOut = [];
        let chosen = document.getElementById('chosen');
        chosen.querySelectorAll('.appointmentChosen').forEach(chosen => {
            let app = {};
            app['appId'] = chosen.dataset.appid;
            app['appCategory'] = chosen.dataset.appcat;
            app['appText'] = chosen.dataset.apptext;
            app['appChosenState'] = chosen.dataset.appchosenstate;
            app['appInput'] = chosen.dataset.appinput;
            jsonOut.push(app);
        });
        let pWithPad = document.createElement('p');
        pWithPad.classList.add('slds-p-vertical_small');
        let hiddenData = document.querySelectorAll('[id$=outgoingAppJSon]');
        hiddenData.forEach(function (hidedata) {
            hidedata.value = JSON.stringify(jsonOut);
        });
    }
    return allAppGood;
}

function checkForRequiredAppointments() {
    let chooser = document.getElementById('chooser');
    let requiredAppointments = chooser.querySelectorAll('.appointmentRequired');
    let allAppGood = true;
    requiredAppointments.forEach(function (app) {
        if (window.getComputedStyle(app).display !== "none") {
            allAppGood = false;
            app.classList.add('appointment-has-error');
            if (!app.classList.contains('slds-is-open')) {
                app.classList.add('slds-is-open');
            }
            fadein();
        }
    });
    return allAppGood;
}