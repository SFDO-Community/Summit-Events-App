let readySLDS = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

readySLDS(() => {
    createRequiredSelects();
    activateTooltips();
    activateHelpButton();
    adjustLabelsFor();
    activateAutoComplete();
});

/* Tooltip */
function activateTooltips() {
    document.querySelectorAll('.aria-describedby-tooltip').forEach(item => {
        let toolTipElement = document.getElementById(item.getAttribute('aria-describedby'));
        item.addEventListener('mousemove', (e) => {
            let toolTipOffsetElem = toolTipElement.offsetParent;
            toolTipElement.classList.remove('slds-fall-into-ground', 'slds-nubbin_left', 'slds-nubbin_right');
            toolTipElement.classList.add('slds-rise-from-ground');
            let leftPosition = (e.clientX - toolTipOffsetElem.getBoundingClientRect().x);
            let topPosition = ((e.clientY - toolTipOffsetElem.getBoundingClientRect().y) + 25);
            if (document.body.clientWidth < toolTipElement.clientWidth + e.clientX) {
                toolTipElement.classList.add('slds-nubbin_top-right');
                leftPosition = leftPosition - (toolTipElement.clientWidth - 10);
            } else {
                toolTipElement.classList.add('slds-nubbin_top-left');
                leftPosition = leftPosition - 10;
            }
            toolTipElement.style.left = leftPosition + 'px';
            toolTipElement.style.top = topPosition + 'px';
        });
        item.addEventListener('mouseleave', () => {
            toolTipElement.classList.remove('slds-rise-from-ground');
            toolTipElement.classList.add('slds-fall-into-ground');
        });
    });
}

/* Tooltip */
function activateHelpButton() {
    document.querySelectorAll('.helpButton').forEach(item => {
        let toolTipElement = document.getElementById(item.getAttribute('aria-describedby'));

        item.addEventListener('click', (e) => {
            e.preventDefault();
        });
        item.addEventListener('mouseover', () => {
            toolTipElement.classList.remove('slds-fall-into-ground', 'slds-rise-from-ground');
            toolTipElement.classList.add('slds-rise-from-ground');
        });
        item.addEventListener('mouseout', () => {
            toolTipElement.classList.remove('slds-fall-into-ground', 'slds-rise-from-ground');
            toolTipElement.classList.add('slds-fall-into-ground');
        });
    });
}

function createRequiredSelects() {
    document.querySelectorAll('.slds-is-required select').forEach(selectFound => {
        selectFound.setAttribute('required', 'required');
    });
}

function adjustLabelsFor() {

    document.querySelectorAll('.slds-input, .slds-select, .slds-textarea, .slds-checkbox input').forEach(inputFound => {
        let inputWrapper = inputFound.closest('.slds-form-element');
        if (inputWrapper) {
            let inputLabel = inputWrapper.querySelector('label')
            let helpText = inputWrapper.querySelector('.slds-form-element__help');

            if (inputLabel) {
                if (inputFound.getAttribute('id')) {
                    inputLabel.htmlFor = inputFound.getAttribute('id');
                } else if (inputFound.getAttribute('name')) {
                    inputFound.setAttribute('id', inputFound.getAttribute('name'))
                    inputLabel.htmlFor = inputFound.getAttribute('id');
                }
            }

            if (inputFound.classList.contains('slds-checkbox')) {
                inputLabel.addEventListener('click', () => {
                    if (inputFound.getAttribute('checked')) {
                        inputFound.removeAttribute('checked')
                    } else {
                        inputFound.setAttribute('checked', 'checked');
                    }
                });
            }

            if (inputFound && helpText) {
                if (helpText) {
                    inputFound.setAttribute('aria-describedby', helpText.getAttribute('id'));
                    inputFound.setAttribute('aria-invalid', 'false');
                }
                if (inputWrapper.dataset.placeholder) {
                    field.setAttribute('placeholder', placeholders[inputId])
                    inputFound.setAttribute('placeholder', inputWrapper.dataset.placeholder);
                }
                if (inputWrapper.dataset.maxlength) {
                    inputFound.setAttribute('maxlength', inputWrapper.dataset.maxlength);
                }
            }
        }
    });

}

function activateAutoComplete() {

    document.querySelectorAll('.bind-autocomplete').forEach(autoItem => {
        let inputWrapper = autoItem.closest('.slds-form-element');
        let isRequired = inputWrapper.classList.contains('slds-is-required');
        let alternateInput = inputWrapper.querySelector('.sea-alternate-input');
        let comboBoxContainer = autoItem.closest('.slds-combobox_container');
        let comboBox = comboBoxContainer.querySelector('.slds-combobox');
        let spinner = comboBox.querySelector('.slds-modal');
        let hiddenInput = comboBoxContainer.querySelector('[id$=lookupValue]');
        let removeButton = comboBox.querySelector('.refRemoveButton');
        let magGlass = comboBox.querySelector('.refMagGlass');
        let resultList = comboBox.querySelector('.slds-listbox');
        let originObjId = autoItem.id;
        let lookup = comboBoxContainer.dataset.lookup;
        let secondaryInputLink = document.createElement('a');
        let secondaryInput = document.querySelector('.sea-secondary-input');
        secondaryInputLink.innerText = comboBoxContainer.dataset.secondarylinktext;
        secondaryInputLink.addEventListener('click', () => {
            secondaryInput.style.display = 'block';
            comboBox.style.display = 'none';
        });
        let removeButtonSecondary = comboBoxContainer.querySelector('.removeButtonSecondary');

        if(isRequired) {
            alternateInput.setAttribute('required', 'required');
        }
        /* Remote reference lookup */
        const resultListTemplate = (title, subtitle, icon, originObjId, resultId) => `
            <li role="presentation" class="slds-listbox__item" data-title="${title}, ${subtitle}" data-origId="${originObjId}" data-resultId="${resultId}">
                <div id="option1" class="slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta" role="option">
                  <span class="slds-media__figure slds-listbox__option-icon">
                    <span class="slds-icon_container slds-icon-standard-account">
                      <svg class="slds-icon slds-icon_small" aria-hidden="true">
                        <use xlink:href="${icon}"></use>
                      </svg>
                    </span>
                  </span>
                  <span class="slds-media__body">
                    <span class="slds-listbox__option-text slds-listbox__option-text_entity">${title}</span>
                    <span class="slds-listbox__option-meta slds-listbox__option-meta_entity">${subtitle}</span>
                  </span>
                </div>
            </li>
        `;

        function refValueAdded() {
            comboBox.classList.remove('slds-is-open');
            autoItem.classList.add('slds-combobox__input-value');
            comboBoxContainer.classList.add('slds-has-selection');
            removeButton.style.display = 'inline-flex';
            magGlass.style.display = 'none';
            //if required remove required attribute of secondary input to prevent html5 validation error
            if (isRequired) {
                alternateInput.removeAttribute('required')
            }
        }

        function refValueRemoved() {
            comboBox.classList.remove('slds-is-open');
            autoItem.classList.remove('slds-combobox__input-value');
            comboBoxContainer.classList.remove('slds-has-selection');
            removeButton.style.display = 'none';
            magGlass.style.display = 'inline-flex';
            autoItem.value = '';
            hiddenInput.value = '';
            resultList.innerHTML = '';
            //if required reset required attribute
            if (isRequired) {
                alternateInput.setAttribute('required', 'required');
            }
        }

        async function fetchLookupResults(lookup, searchTerm) {
            try {
                let data = await lookupSearchJS(lookup, searchTerm);
                updateLookupUI(data);
            } catch (ex) {
                if (ex.name === 'AbortError') {
                    return; // Continuation logic has already been skipped, so return normally
                }
                resultList.innerHTML = ex.message;
            }
            setTimeout(() => {
                spinner.classList.remove('slds-fade-in-open');
                spinner.style.zIndex = '-1'
            }, 1000);
        }

        const updateLookupUI = (data) => {
            let outputList = ''
            console.log(JSON.stringify(data));
            if (data.length) {
                //make sure the promise with the latest seach term is turned into data
                if (data[0]['searchTerm'] === autoItem.value) {
                    data.forEach(result => {
                        let resultName = result['lineOne'];
                        let subTitle = result['lineTwo'];
                        let resultId = result['retainValue'];
                        outputList += resultListTemplate(resultName, subTitle, comboBoxContainer.dataset.listicon, originObjId, resultId);
                    });

                    comboBox.classList.remove('slds-is-open');
                    if (outputList) {
                        comboBox.classList.add('slds-is-open');
                    }
                    resultList.innerHTML = outputList;
                    resultList.querySelectorAll('li').forEach(refItem => {
                        refItem.addEventListener('click', () => {
                            hiddenInput.value = refItem.dataset.resultid;
                            autoItem.value = refItem.dataset.title;
                            refValueAdded();
                        });
                    });
                }
            } else {
                resultList.innerHTML = '<li role="presentation" class="slds-listbox__item "><div class="slds-listbox__option_entity no-results" role="option">' + comboBoxContainer.dataset.noresults + ' <span class="slds-media__body"></span></div></li>';
                comboBoxContainer.querySelector('.no-results').append(secondaryInputLink);
            }
        }

        if (autoItem.value) {
            autoItem.classList.remove('slds-has-focus');
            comboBox.classList.remove('slds-is-open');
            refValueAdded();
        }

        autoItem.addEventListener('focusin', () => {
            autoItem.classList.add('slds-has-focus');
            comboBox.classList.add('slds-is-open');
        });

        removeButton.addEventListener('click', (e) => {
            e.preventDefault();
            refValueRemoved();
        });

        removeButtonSecondary.addEventListener('click', (e) => {
            e.preventDefault();
            secondaryInput.querySelector('input').value = '';
            secondaryInput.style.display = 'none';
            comboBox.style.display = 'block';
        });

        autoItem.addEventListener('keyup', () => {
            spinner.style.zIndex = null;
            spinner.classList.add('slds-fade-in-open');
            let searchTerm = autoItem.value;
            if (lookup && searchTerm.length > 2) {
                fetchLookupResults(lookup, searchTerm);
            }
        });

    });

}
