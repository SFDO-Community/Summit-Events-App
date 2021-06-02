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
    let allAppAddButtons = chooser.querySelectorAll(".appointmentAdd");

    allAppAddButtons.forEach(function (appButton) {
        appButton.addEventListener("click", (addApp) => {
            addApp.preventDefault();
            let App = appButton.closest(".appointment");

            //check for required fields
            let error = false;
            let requiredInputs = App.querySelectorAll('.slds-is-required');
            requiredInputs.forEach(function (reqs) {
                let reqApp = reqs.closest(".appointment");
                let incomingValue = '';
                if (reqApp.querySelector(".appointmentType")) {
                    let selType = App.querySelector(".appointmentType");
                    incomingValue = selType.options[selType.selectedIndex].value;
                }
                if (reqApp.querySelector(".appointmentCustomInput")) {
                    let inputType = App.querySelector(".appointmentCustomInput");
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

                let limit = App.dataset.limit;

                addApp = document.createElement('div');
                addApp.classList.add('slds-box', 'slds-box_small', 'slds-m-vertical_x-small', 'appointmentChosen');
                Object.assign(addApp.dataset, App.dataset);

                let appTitle = document.createElement('p');
                addApp.classList.add('appointmentTitle', 'slds-text-body', 'slds-m-vertical_small');
                let findTitle = App.querySelector(".appointmentTitle");
                appTitle.textContent = findTitle.textContent;
                addApp.append(appTitle);

                let desc = '';
                if (App.querySelector(".appointmentType")) {
                    let selType = App.querySelector(".appointmentType");
                    desc += selType.options[selType.selectedIndex].value;
                }

                if (App.querySelector(".appointmentCustomInput")) {
                    let inputType = App.querySelector(".appointmentCustomInput");
                    desc += inputType.value;
                }

                if (desc) {
                    let appDesc = document.createElement('p');
                    appDesc.classList.add('appointmentDesc', 'slds-text-body', 'slds-p-vertical_small');
                    appDesc.textContent = desc;
                    addApp.append(appDesc);
                }

                //Create the remove button
                let removeButton = document.createElement('a');
                removeButton.classList.add('appointmentRemove', 'slds-button', 'slds-button_neutral');
                removeButton.textContent = ' Remove ';
                removeButton.addEventListener("click", function (evt) {
                    evt.preventDefault();
                    removeSelectedOption(removeButton)
                });
                addApp.appendChild(removeButton);

                addApp.id = 'app' + limit + '-' + App.id;
                App.dataset.limit = String(limit - 1);

                chosenArea.append(addApp);

                //remove all values from hidden appointments.
                if (App.classList.contains('slds-has-error')) {
                    App.classList.remove('slds-has-error');
                }

                if (App.querySelector(".appointmentType")) {
                    let selType = App.querySelector(".appointmentType");
                    desc += selType.options[selType.selectedIndex].value = '';
                }

                if (App.querySelector(".appointmentCustomInput")) {
                    let inputType = App.querySelector(".appointmentCustomInput");
                    desc += inputType.value = '';
                }

                if (App.dataset.limit < 1) {
                    App.style.display = "none";
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
    let jsonOut = [];
    let chosen = document.getElementById('chosen');
    chosen.querySelectorAll('.appointmentChosen').forEach(chosen => {
        let app = {};
        app['appId'] = chosen.dataset.appid;
        app['appCategory'] = chosen.dataset.appcat;
        app['appType'] = chosen.dataset.apptype;
        app['appText'] = chosen.dataset.apptext;
        app['appTitle'] = chosen.dataset.apptitle;
        app['appChosenState'] = chosen.dataset.appchosenstate;
        app['appSort'] = chosen.dataset.appsort;
        app['appInput'] = chosen.dataset.appinput;
        let appDesc = chosen.querySelector('.appointmentDesc');
        if (appDesc) {
            app['appDesc'] = appDesc.textContent;
        }
        jsonOut.push(app);
    });
    let pWithPad = document.createElement('p');
    pWithPad.classList.add('slds-p-vertical_small');
    let hiddenData = document.querySelectorAll('[id$=outgoingAppJSon]');
    hiddenData.forEach(function (hidedata) {
        hidedata.value = JSON.stringify(jsonOut);
    });
    return checkForRequiredAppointments();
}

function checkForRequiredAppointments() {
    let chooser = document.getElementById('chooser');
    let requiredAppointments = chooser.querySelectorAll('.appointmentRequired');
    let allAppGood = true;
    requiredAppointments.forEach(function (app) {
        if (window.getComputedStyle(app).display !== "none") {
            allAppGood = false;
            app.classList.add('slds-has-error');
            if (!app.classList.contains('slds-is-open')) {
                app.classList.add('slds-is-open');
            }
            fadein();
        }
    });
    return allAppGood;
}