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
    let obj = {};
    let firstname = '';
    let lastname = '';
    let restOfData = ''
    let newId = uniqueId();
    obj['id'] = newId;
    var formData = new FormData(form);
    console.log(JSON.stringify(formData));
    for (var key of formData.keys()) {
        obj[key] = escape(formData.get(key));
        if (key.toLowerCase() === 'first_name') {
            firstname = escape(formData.get(key));
        } else if (key.toLowerCase() === 'last_name') {
            lastname = escape(formData.get(key));
        } else {
            if (formData.get(key)) {
                console.log(key + ' ' + formData.get(key));
                restOfData += '<span class="slds-badge slds-badge_lightest">' + formData.get(key) + '</span>';
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
                if (key.toLowerCase() === 'first_name') {
                    firstname = escape(allGuests[i][key]);
                } else if (key.toLowerCase() === 'last_name') {
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
            if (q['Required']) {
                qWrap.classList.add('slds-is-required')
            }
            qWrap.setAttribute('data-type', q['Type']);
            qWrap.setAttribute('data-object', q['Type']);
            qWrap.setAttribute('data-field', q['Type']);
            let label = document.createElement('label');
            label.classList.add('slds-form-element__label');
            if (!q['Required']) {
                label.innerHTML = q['Question'];
            } else {
                label.innerHTML = q['Question'] + '<abbr className="slds-required" title="required"> * </abbr>';
            }
            qWrap.appendChild(label);
            let formElement = document.createElement('div');
            formElement.classList.add('slds-form-element__control');
            switch (q['Type']) {
                case 'Pick-list':
                    formElement.innerHTML = buildPicklist(q);
                    break;
                case 'Text box':
                    formElement.innerHTML = buildInputBox(q);
                    break;
                case 'Text area':
                    formElement.innerHTML = buildTextarea(q);
                    break;
            }
            qWrap.appendChild(formElement);
            qWrapOuter.appendChild(qWrap);
            formInputs.appendChild(qWrapOuter);
            qNum++;
        });
    }
}

function buildInputBox(question) {
    let inputBox = '<input class="slds-input';
    if (question['Required']) {
        inputBox += ' required '
    }
    inputBox += '" ';
    if (question['Required']) {
        inputBox += ' required="required" ';
    }
    inputBox += '>'
    return inputBox;
}

function buildPicklist(question) {
    let picklist = '<div className="slds-select_container">';
    picklist += '<select class="slds-select">';
    question['picklist'].forEach(item => {
        picklist += '<option value="' + item + '">' + item + '</option>';
    });
    picklist += '</select>';
    picklist += '</div>';
    return picklist;
}

function buildTextarea(question) {
    let inputBox = '<textarea class="slds-textarea';
    if (question['Required']) {
        inputBox += ' required '
    }
    inputBox += '" ';
    if (question['Required']) {
        inputBox += ' required="required" ';
    }
    inputBox += '></textarea>';
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


const guestListTemplate = (fullName, uniqueId, restOfData) => `
    <article class="slds-card">
        <div class="slds-card__header slds-grid">
            <header class="slds-media slds-media_center slds-has-flexi-truncate">
                <div class="slds-media__figure">
                <span class="slds-icon_container slds-icon-standard-account" title="Guest">
                    <svg class="slds-icon slds-icon_small" aria-hidden="true">
                      <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#account"></use>
                    </svg>
                  <span class="slds-assistive-text guestName">${fullName}</span>
                </span>
                </div>
                <div class="slds-media__body slds-button__icon_x-small">
                    <h2 class="slds-card__header-title">
                        <a href="#" class="slds-card__header-link slds-truncate" title="${fullName}">
                            <span class="guestName">${fullName}</span>
                        </a>
                    </h2>
                </div>
                <div class="slds-no-flex">
                    <button class="slds-button" title="Delete guest" style="background-color:orangered;" onclick="javascript:removeById('${uniqueId}', this);">
                        <svg class="slds-icon slds-icon_small" aria-hidden="true">
                            <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#delete"></use>
                        </svg>
                    </button>
                </div>
            </header>
        </div>
        <div class="slds-card__body slds-card__body_inner">${restOfData}</div>
    </article>
`



