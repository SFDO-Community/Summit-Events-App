let ready = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

let allGuests = [];
let currentGuestAmount = 0;

ready(() => {
    const guestInputForm = document.getElementById("guestInput");
    guestInputForm.addEventListener('submit', handleGuestInput);
    buildGuestForm();
    loadUpPreviousData();
});

let serializeForm = function (form) {
    form.reportValidity();
    let guest = {};
    let questions = [];
    let restOfData = ''
    let newId = uniqueId();
    guest['guestId'] = newId;
    let formData = new FormData(form);
    for (let key of formData.keys()) {
        let question = {}
        let formValue = formData.get(key).replace(/<[^>]*>/ig, "");
        question['id'] = key;
        question['value'] = formValue;
        let questionText = document.getElementById(key).closest('.slds-form-element').querySelector('label').innerHTML;
        question['question'] = questionText.replace(/<[^>]*>/ig, "").replaceAll(' * ', "");
        restOfData += answerTemplate(question['question'], formValue);
        questions.push(question);
    }
    guest['questions'] = questions;
    restOfData = restOfData.slice(0, -2);
    //Put the new guest in the list;
    let guestListWrap = document.getElementById('guestList');
    let fullName = '';
    if (document.contains(document.getElementById("noGuestPlaceholder"))) {
        document.getElementById("noGuestPlaceholder").remove();
    }
    let guestListItem = guestListTemplate(fullName, newId, restOfData);
    guestListWrap.insertAdjacentHTML("beforeend", guestListItem);
    return guest;
};

function uniqueId() {
    let a = new Uint32Array(3);
    window.crypto.getRandomValues(a);
    return (performance.now().toString(36) + Array.from(a).map(A => A.toString(36)).join("")).replace(/\./g, "");
}

function handleGuestInput(event) {
    event.preventDefault();
    //Check if anything has been entered
    let form = document.getElementById("guestInput");
    let valuesEntered = false;
    Array.from(form.elements).forEach(input => {
        if (input.value) {
            valuesEntered = true;
        }
    });
    if (valuesEntered) {
        let newGuest = serializeForm(event.target);
        allGuests.push(newGuest);
        let guestJSON = document.querySelector("[id$='guestJSON']");
        guestJSON.value = JSON.stringify(allGuests);
        setGuestRemaining();
        event.target.reset();
    }
}

function loadUpPreviousData() {
    currentGuestAmount = 0;
    let guestJSON = document.querySelector("[id$='guestJSON']").value;
    if (guestJSON) {
        allGuests = JSON.parse(guestJSON);
        let guestListWrap = document.getElementById('guestList');
        let restOfData = '';
        currentGuestAmount = allGuests.length;
        for (let i = 0; i < currentGuestAmount; i++) {
            for (let y = 0; y < allGuests[i]['questions'].length; y++) {
                let question = allGuests[i]['questions'][y];
                restOfData += answerTemplate(question.question, question.value);
            }
            let guestListItem = guestListTemplate('', allGuests[i]['guestId'], restOfData);
            restOfData = '';
            if (document.contains(document.getElementById("noGuestPlaceholder"))) {
                document.getElementById("noGuestPlaceholder").remove();
            }
            guestListWrap.insertAdjacentHTML("beforeend", guestListItem);
        }
    }
    setGuestRemaining();
}

function buildGuestForm() {
    if (guestQuestionJSON.length > 0) {
        let formInputs = document.getElementById('questQuestions');
        let form = document.getElementById('guestInput');
        let qNum = 0;
        guestQuestionJSON.forEach(q => {
            let qWrapOuter = document.createElement('div');
            qWrapOuter.classList.add('slds-col', 'slds-p-bottom_small', 'slds-size_1-of-1');
            let qWrap = document.createElement('div');
            qWrap.classList.add('slds-form-element');
            if (q['required']) {
                qWrap.classList.add('slds-is-required')
            }
            let label = document.createElement('label');
            label.classList.add('slds-form-element__label', 'slds-p-bottom_xxx-small');
            label.innerHTML = q.question;
            label.setAttribute('for', q.id);

            if (q.required) {
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
                case 'text area':
                    formElement.appendChild(buildInputBox(q, 'textarea'));
                    break;
                case 'phone':
                    formElement.appendChild(buildInputBox(q, 'tel'));
                    break;
                case 'email':
                    formElement.appendChild(buildInputBox(q, 'email'));
                    break;
                case 'date':
                    formElement.appendChild(buildInputBox(q, 'date'));
                    break;
            }

            qWrap.appendChild(formElement);

            // maybe use for assistive text
            if (q.assist) {
                let errorHelp = document.createElement('div');
                errorHelp.classList.add('slds-form-element__help');
                errorHelp.innerHTML = q.assist;
                errorHelp.id = 'error_' + q.id;
                qWrap.appendChild(errorHelp);
            }

            if (q.instructions) {
                let instruct = document.createElement('p');
                instruct.classList.add('slds-text-body_regular', 'slds-p-top_xxx-small');
                instruct.innerHTML = q['instructions'];
                qWrap.appendChild(instruct);
            }
            qWrapOuter.appendChild(qWrap);
            formInputs.appendChild(qWrapOuter);

            qNum++;
        });

        form.addEventListener('invalid', (e) => {
            e.preventDefault();
            let allInputs = document.querySelectorAll('input, select, textarea');
            allInputs.forEach(input => {
                if (!input.validity.valid) {
                    input.setAttribute('aria-invalid', 'true')
                    input.closest('.slds-form-element').classList.add('slds-has-error');
                    input.addEventListener('change', () => {
                        input.closest('.slds-form-element').classList.remove('slds-has-error');
                        input.removeAttribute('aria-invalid')
                    });
                }
            });
        }, true)

    }
}

function setGuestRemaining() {
    let form = document.getElementById("guestInput");
    let button = document.getElementById("registerGuestButton");
    //guestMaxAmount set make sure not to exceed that amount
    if (guestMaxAmount) {
        const guestCountWrap = document.getElementById("guestRemaining");
        const guestListWrap = document.getElementById("guestList");
        let guestArticleCount = guestListWrap.querySelectorAll('article').length;
        guestCountWrap.innerHTML = guestArticleCount + ' - ' + guestMaxAmount;
        if (guestArticleCount === guestMaxAmount) {
            Array.from(form.elements).forEach(input => {
                input.setAttribute('disabled', 'disabled');
            })
            button.setAttribute('disabled', 'disabled');
        } else {
            Array.from(form.elements).forEach(input => {
                input.removeAttribute('disabled');
            })
            button.removeAttribute('disabled');
        }
    }
}

function buildInputBox(question, inputType) {
    let inputBox;
    console.log(inputType);
    if (inputType === 'textarea') {
        inputBox = document.createElement('textarea');
    } else {
        inputBox = document.createElement('input');
        inputBox.type = inputType;
    }
    if (question.defaultValue) {
        inputBox.value = question.defaultValue;
    }
    if (question.textLimit) {
        inputBox.maxLength = question.textLimit;
    }
    inputBox.setAttribute('data-type', question.type);
    if (inputType === 'tel') {
        //inputBox.setAttribute('pattern', '[\\+]\\d{2}[\\(]\\d{2}[\\)]\\d{4}[\\-]\\d{4}');
    }
    inputBox.classList.add('slds-input');
    inputBox.name = question.id;
    inputBox.id = question.id;
    inputBox.setAttribute('aria-describedby', 'error_' + question.id);
    if (question.required) {
        inputBox.classList.add('required');
        inputBox.required = true;
    }
    return inputBox;
}

function buildPicklist(question) {
    let picklistWrap = document.createElement('div');
    picklistWrap.classList.add('slds-select_container');
    let picklist = document.createElement('select');
    if (question.required) {
        picklist.classList.add('required');
        picklist.required = true;
    }
    picklist.classList.add('slds-select');
    picklist.setAttribute('data-type', question.type);
    picklist.name = question.id;
    picklist.id = question.id;
    picklist.setAttribute('aria-describedby', 'error_' + question.id);
    question['picklist'].forEach(item => {
        let selectOption = document.createElement('option');
        selectOption.text = item;
        if (item === 'Select...') {
            selectOption.value = '';
        } else {
            if (question.defaultValue === item) {
                selectOption.selected = true;
            }
            selectOption.value = item;
        }
        picklist.add(selectOption);
    });
    picklistWrap.appendChild(picklist);
    return picklistWrap;
}

function removeById(idToRemove, element) {
    let removeIndex = allGuests.map(item => item.guestId).indexOf(idToRemove);
    ~removeIndex && allGuests.splice(removeIndex, 1);
    let guestJSON = document.querySelector("[id$='guestJSON']");
    guestJSON.value = JSON.stringify(allGuests);
    let itemWrapper = element.closest('article');
    itemWrapper.remove();
    setGuestRemaining();
}


//Templates

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
`;

const guestListTemplate = (fullName, uniqueId, restOfData) => `
<article class="slds-card slds-clearfix slds-p-vertical_none">
    <div class="slds-card__body slds-card__body_inner slds-clearfix slds-m-vertical_x-small slds-p-horizontal_small">
        <div class="slds-no-flex slds-float_right slds-m-bottom_large">
            <button class="slds-button slds-p-around_xx-small slds-button_neutral" title="Delete" style="" onclick="removeById('${uniqueId}', this);">
                <svg class="slds-icon slds-icon_x-small slds-icon-text-default" aria-hidden="true">
                    <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#delete"></use>
                </svg>
                <span class="slds-assistive-text">Delete</span>
            </button>
        </div>
        ${restOfData}
    </div>
</article>
`;

const answerTemplate = (question, answer) => `
<div class="slds-float_left slds-m-right_large slds-p-bottom_x-small">
    <label class="slds-form-element__label">
        ${question}
    </label>
    <div class="slds-float_none slds-text-body_regular">
        ${answer}
    </div>
</div>
`;