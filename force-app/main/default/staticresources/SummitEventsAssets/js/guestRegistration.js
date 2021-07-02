let ready = (callback) => {
    if (document.readyState != "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

let allGuests = [];

ready(() => {
    const guestInputForm = document.getElementById("guestInput");
    guestInputForm.addEventListener('submit', handleGuestInput);
    buildGuestForm();
    loadUpPreviousData();
});


let serializeForm = function (form) {
    form.reportValidity();
    let obj = {};
    let firstname = '';
    let lastname = '';
    let restOfData = ''
    let newId = uniqueId();
    obj['id'] = newId;
    let formData = new FormData(form);
    for (let key of formData.keys()) {
        let formValue = escape(formData.get(key).replace(/<[^>]*>/ig, ""));
        obj[key] = formValue;
        if (key.toLowerCase() === 'registrants_first_name') {
            firstname = formValue;
        } else if (key.toLowerCase() === 'registrants_last_name') {
            lastname = formValue;
        } else {
            if (formData.get(key)) {
                restOfData += '<span class="slds-badge slds-badge_lightest">' + formValue + '</span>';
            }
        }
    }
    restOfData = restOfData.slice(0, -2);
    //Put the new guest in the list;
    let guestListWrap = document.getElementById('guestList');
    let fullName = (firstname + ' ' + lastname).trim();
    if (document.contains(document.getElementById("noGuestPlaceholder"))) {
        document.getElementById("noGuestPlaceholder").remove();
    }
    let guestListItem = guestListTemplate(fullName, newId, restOfData);
    guestListWrap.insertAdjacentHTML("beforeend", guestListItem);
    console.log(obj);
    return obj;
};

function uniqueId() {
    let a = new Uint32Array(3);
    window.crypto.getRandomValues(a);
    return (performance.now().toString(36) + Array.from(a).map(A => A.toString(36)).join("")).replace(/\./g, "");
};

function handleGuestInput(event) {
    event.preventDefault();
    let newGuest = serializeForm(event.target);
    allGuests.push(newGuest);
    let guestJSON = document.querySelector("[id$='guestJSON']");
    guestJSON.value = JSON.stringify(allGuests);
    event.target.reset();
}

function loadUpPreviousData() {
    let guestJSON = document.querySelector("[id$='guestJSON']").value;
    if (guestJSON) {
        allGuests = JSON.parse(guestJSON);
        let guestListWrap = document.getElementById('guestList');

        for (let i = 0; i < allGuests.length; i++) {
            let firstname = '';
            let lastname = '';
            let restOfData = '';
            for (let key in allGuests[i]) {
                if (key.toLowerCase() === 'registrants_first_name') {
                    firstname = escape(allGuests[i][key]);
                } else if (key.toLowerCase() === 'registrants_last_name') {
                    lastname = escape(allGuests[i][key]);
                } else if (key.toLowerCase() !== 'id') {
                    if (allGuests[i][key]) {
                        restOfData += '<span class="slds-badge slds-badge_lightest">' + allGuests[i][key] + '</span>';
                    }
                }
            }
            restOfData = restOfData.slice(0, -2);
            let fullName = (firstname + ' ' + lastname).trim();
            let guestListItem = guestListTemplate(fullName, allGuests[i]['id'], restOfData);
            if (document.contains(document.getElementById("noGuestPlaceholder"))) {
                document.getElementById("noGuestPlaceholder").remove();
            }
            guestListWrap.insertAdjacentHTML("beforeend", guestListItem);
        }
    }


}

function buildGuestForm() {
    if (guestQuestionJSON.length > 0) {
        let formInputs = document.getElementById('questQuestions');
        let qNum = 0;
        guestQuestionJSON.forEach(q => {
            let qWrapOuter = document.createElement('div');
            qWrapOuter.classList.add('slds-col', 'slds-p-vertical_x-small', 'slds-size_1-of-1');
            let qWrap = document.createElement('div');
            qWrap.classList.add('slds-form-element');
            if (q['required']) {
                qWrap.classList.add('slds-is-required')
            }
            qWrap.setAttribute('data-type', q['type']);
            qWrap.setAttribute('data-object', q['type']);
            qWrap.setAttribute('data-field', q['type']);
            let label = document.createElement('label');
            label.classList.add('slds-form-element__label');
            label.innerHTML = q['question'];

            if (q['required']) {
                let requiredInput = document.createElement('abbr');
                requiredInput.title = 'required';
                requiredInput.classList.add('slds-required');
                requiredInput.innerHTML = ' * ';
                label.appendChild(requiredInput);
            }
            qWrap.appendChild(label);

            if (q['help']) {
                let helpInfo = helpTextTemplate(q['help'], q['id'] + '_help');
                qWrap.insertAdjacentHTML('beforeend', helpInfo);
            }

            let formElement = document.createElement('div');
            formElement.classList.add('slds-form-element__control');
            switch (q['type'].toLowerCase()) {
                case 'picklist':
                    formElement.appendChild(buildPicklist(q));
                    break;
                case 'textbox':
                    formElement.appendChild(buildInputBox(q, 'text'));
                    break;
                case 'email':
                    formElement.appendChild(buildInputBox(q, 'email'));
                    break;
                case 'date':
                    formElement.appendChild(buildInputBox(q, 'date'));
                    break;
                case 'text area':
                    formElement.appendChild(buildTextarea(q));
                    break;
            }

            qWrap.appendChild(formElement);

            if (q['instructions']) {
                let instruct = document.createElement('div');
                instruct.classList.add('slds-form-element__help');
                instruct.innerHTML = q['instructions'];
                instruct.id = q['id'] + '_error';
                qWrap.appendChild(instruct);
            }

            qWrapOuter.appendChild(qWrap);
            formInputs.appendChild(qWrapOuter);
            qNum++;
        });
    }
}

function buildInputBox(question, inputType) {
    let inputBox = document.createElement('input');
    inputBox.classList.add('slds-input');
    inputBox.type = inputType;
    inputBox.name = question['mapTo'];
    if (question['required']) {
        inputBox.classList.add('required');
        inputBox.required = true;
    }
    return inputBox;
}

function buildPicklist(question) {
    let picklistWrap = document.createElement('div');
    picklistWrap.classList.add('slds-select_container');
    let picklist = document.createElement('select');
    if (question['required']) {
        picklist.classList.add('required');
        picklist.required = true;
    }
    picklist.classList.add('slds-select');
    picklist.name = question['mapTo'];
    question['picklist'].forEach(item => {
        let selectOption = document.createElement('option');
        selectOption.text = item;
        if (item === 'Select...') {
            selectOption.value = '';
        } else {
            selectOption.value = item;
        }
        picklist.add(selectOption);
    });
    picklistWrap.appendChild(picklist);
    return picklistWrap;
}

function buildTextarea(question) {
    let inputBox = document.createElement('textarea');
    inputBox.classList.add('slds-textarea');
    inputBox.name = question['mapTo'];
    if (question['required']) {
        inputBox.classList.add('required');
        inputBox.required = true;
    }
    return inputBox;
}

function removeById(idToRemove, element) {
    let removeIndex = allGuests.map(item => item.id).indexOf(idToRemove);
    ~removeIndex && allGuests.splice(removeIndex, 1);
    console.log(allGuests);

    let guestJSON = document.querySelector("[id$='guestJSON']");
    guestJSON.value = JSON.stringify(allGuests);
    let itemWrapper = element.closest('article');
    itemWrapper.remove();
}

const helpTextTemplate = (helpText, id) => `
<div class="slds-form-element__icon">
  <button class="slds-button slds-button_icon helpButton" aria-describedby="${id}">
    <svg class="slds-button__icon" aria-hidden="true">
      <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#info"></use>
    </svg>
    <span class="slds-assistive-text">Help</span>
  </button>
  <div class="slds-popover slds-fall-into-ground slds-nubbin_bottom-left" role="tooltip" id="${id}" style="position:absolute;top:-45px;left:-15px;width:200px">
    <div class="slds-popover__body">${helpText}</div>
  </div>
</div>
`

const guestListTemplate = (fullName, uniqueId, restOfData) => `
<article class="slds-card">
    <div class="slds-card__header slds-grid">
        <header class="slds-media slds-media_center slds-has-flexi-truncate">
            <div class="slds-media__figure">
            <span class="slds-icon_container slds-icon-standard-user slds-p-around_xx-small" title="Guest">
                <svg class="slds-icon slds-icon_x-small" aria-hidden="true">
                  <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#user"></use>
                </svg>
              <span class="slds-assistive-text guestName">${fullName}</span>
            </span>
            </div>
            <div class="slds-media__body">
                <h2 class="slds-card__header-title">
                    <span class="slds-card__header-link slds-truncate" title="${fullName}">
                        <span class="guestName" style="margin-top:-109">${fullName}</span>
                    </span>
                </h2>
            </div>
            <div class="slds-no-flex">
                <button class="slds-button slds-p-around_xx-small" title="Delete guest" style="background-color:orangered;" onclick="javascript:removeById('${uniqueId}', this);">
                    <svg class="slds-icon slds-icon_x-small" aria-hidden="true">
                        <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#delete"></use>
                    </svg>
                </button>
            </div>
        </header>
    </div>
    <div class="slds-card__body slds-card__body_inner">${restOfData}</div>
</article>
`



