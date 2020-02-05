document.addEventListener("DOMContentLoaded", () => {

    let chooser = document.querySelector("#chooser");
    let choosen = document.querySelector("#choosen");

    //Build the interface from JSON data
    for (var key in allAppts) {
        apptGroup = allAppts[key];
        apptGroupId = key;
        grp = document.createElement("div");
        if (apptGroup.typeId) {
            grp.setAttribute("id", apptGroup[key]);
        } else {
            grp.setAttribute("id", 'generalPlaceholder');
            apptGroup.groupId = 'generalPlaceholder';
        }
        grp.setAttribute("data-choosable", apptGroup.choosable);
        grp.classList.add('apptGroup');
        grp.innerHTML = '<h5 class="apptGroupTitle">' + apptGroup.title + '</h5>';
        grp.innerHTML += '<p class="apptGroupDesc">' + apptGroup.description + '</p>';
        chooser.append(grp);

        for (var key in apptGroup.appointments) {
            let appt = apptGroup.appointments[key];
            let apptItem = document.createElement("div");
            let itemDetail = '';
            apptItem.setAttribute("id", appt.typeId);
            apptItem.setAttribute("data-groupTypeId", apptGroupId);
            apptItem.setAttribute("data-apptTypeId", appt.typeId);
            apptItem.setAttribute("data-apptId", appt.chosenId);
            apptItem.classList.add("appointment");
            apptItem.innerHTML = '<p class="appointmentTitle"><a href="javascript:;" class="optionToggler"><span>' + appt.title + '</span></span><i class="fa fa-chevron-down" aria-hidden="true"></i></a></p>';

            itemDetail = '<p class="appointmentDesc">' + appt.description + '</p>';
            itemDetail += '<a href="javascript:;" class="appointmentAdd"><span><i class="fa fa-plus" aria-hidden="true"></i> Add appointment</span></a>';

            itemDetail += '<a class="appointmentRemove" ';
            if (!appt.selected) {
                itemDetail += 'style="display:none;"';
            }
            itemDetail += ' ><i class="fa fa-times-circle" aria-hidden="true"></i><span> Remove</span></a>';

            let apptItemDesc = document.createElement("div");
            apptItemDesc.classList.add("apptmentDetail");
            apptItemDesc.innerHTML = itemDetail
            apptItem.append(apptItemDesc);
            grp.append(apptItem);

        }
    }

    chooser.append(grp);

    var choiceAppt = chooser.getElementsByClassName("appointment");

    for (var at = 0; at < choiceAppt.length; at++) {

        let currectAppt = choiceAppt[at];

        //Add event listener for title toggle for description
        let descToggler = currectAppt.querySelector(".optionToggler");
        descToggler.addEventListener('click', function () {
            var desc = currectAppt.querySelector(".apptmentDetail");
            var apptIcon = this.querySelector("i");
            if (apptIcon.classList.contains("fa-chevron-down")) {
                apptIcon.classList.remove("fa-chevron-down");
                apptIcon.classList.add("fa-chevron-up")
            } else {
                apptIcon.classList.remove("fa-chevron-up");
                apptIcon.classList.add("fa-chevron-down")
            }
            toggle(desc, "block");
        });

        let addAppt = currectAppt.querySelector(".appointmentAdd");
        if (addAppt !== null) {
            addAppt.addEventListener('click', function () {
                toggle(currectAppt.querySelector(".appointmentAdd"), 'block');
                toggle(currectAppt.querySelector(".appointmentRemove"), 'block');
                changeApppointmentData(currectAppt, true);
                choosen.appendChild(currectAppt);
            });
        }

        let removeAppt = currectAppt.querySelector(".appointmentRemove");
        if (removeAppt !== null) {
            removeAppt.addEventListener('click', function () {
                toggle(currectAppt.querySelector(".appointmentAdd"), 'block');
                toggle(currectAppt.querySelector(".appointmentRemove"), 'block');
                changeApppointmentData(currectAppt, false);
                chooser.appendChild(currectAppt);
            });
        }

    }

});

function changeApppointmentData(selAppt, choosenState) {
    let grpId = selAppt.dataset.grouptypeid;
    let typeId = selAppt.dataset.appttypeid;
    let apptId =  selAppt.dataset.apptid;
    allAppts[grpId].appointments[typeId].selected = choosenState;
    sendAppointmentInfo(typeId, grpId, apptId, choosenState, '');
}


function toggle(el, value) {
    var display = (window.getComputedStyle ? getComputedStyle(el, null) : el.currentStyle).display;
    if (display == 'none') el.style.display = value;
    else el.style.display = 'none';
}

function hide(el) {
    el.style.display = 'none';
}

function show(el, value) {
    el.style.display = value;
}
