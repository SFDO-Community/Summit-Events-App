// SummitEventsRegisterScripts
let ChosenSchoolFilter;
let ChosenCollegeFilter;
let ChosenProcess = {};
let ChosenProcessActive = {};
let SESettings = JSON.parse(readCookie('SummitEvents'));
let audience;

//create spinner
const overlay = createSpinner();

let ready = (callback) => {
    if (document.readyState != "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

ready(() => {
    // get audience
    audience = getUrlParameter('audience');
    if (!audience) {
        if (SESettings != null) {
            if (SESettings.audience !== null) {
                audience = SESettings.audience;
            }
        }
    }
    if (!audience) {
        audience = "High School";
    }

    //make sure phone is formated correctly
    adjustLabelsFor();
    dynamicValidation();
    validYear();

    //Makes textareas look like textboxes
    document.querySelectorAll('textarea.input-textbox').forEach(textbox => {
        textbox.rows = 1;
    });

});

function dynamicValidation() {

    //Validate and format phone numbers on change
    let allPhones = document.querySelectorAll('[id$=phone], [id$=mobile], .validPhone');
    allPhones.forEach(function (ph) {
        ph.addEventListener('change', function (e) {
            formatPhone(ph);
        });
    });

    //Fill in city states when zip happens;
    let allZips = document.querySelectorAll('[id$=zip]');
    allZips.forEach(function (zp) {
        zp.addEventListener('change', function (e) {
            fillInCityStateOnZip(zp);
        });
    });
}

//Carries over number values when toggling between type of mobile and home
var phoneCarryover;
var newPhoneType;

function phoneTypeToggle(phoneType) {
    let phones = document.querySelectorAll('input[id$=mobile], input[id$=phone]');
    phones.forEach(function (phone) {
        phoneCarryover = phone.value;
    });
    newPhoneType = phoneType;
    setPhoneSetting(phoneType);
}

function setOldPhoneValue() {
    let phones = document.querySelectorAll('input[id$=mobile], input[id$=phone]');
    phones.forEach(function (phone) {
        phone.value = phoneCarryover;
    });
}


//Validation for the page
function checkForm() {

    var error_count = 0;
    var emailReg = /^([a-zA-Z0-9_.\-.'.+])+@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;

    document.querySelectorAll(".slds-is-required .slds-input, .slds-is-required .slds-textarea, .slds-is-required .slds-select").forEach(item => {
        let inputWrap = item.closest('.slds-form-element');
        let inputRequired = inputWrap.classList.contains('slds-is-required');
        if (item) {
            let inputType = '';
            if (item.type) {
                inputType = item.type.toLowerCase();
            }

            if (inputRequired && !item.value) {
                inputWrap.classList.add("slds-has-error");
                inputWrap.querySelectorAll(".slds-form-element__help").forEach(errorHelp => {
                    errorHelp.style.display = "block"
                });
                addErrorFixerListener(item, inputWrap, 'change');
                error_count++;
            }
            if (inputType == 'email' && inputRequired || inputType == 'email' && item.value) {
                if (!emailReg.test(item.value)) {
                    inputWrap.classList.add("slds-has-error");
                    addErrorFixerListener(item, inputWrap, 'change');
                    error_count++;
                }
            }
        }
    });

    document.querySelectorAll(".selectableOL").forEach(sel => {
        let selWrap = sel.closest('.slds-form-element');
        let hiddenData = document.querySelector('[id$="' + sel.dataset.hiddendataid + '"]').id;
        if (selWrap.classList.contains("slds-is-required")) {
            if (!document.getElementById(hiddenData).value) {
                selWrap.classList.add("slds-has-error");
                addErrorFixerListener(selWrap, selWrap, 'click');
                error_count++;
            }
        }
    });

    if (error_count > 0) {
        fadein();
        let foundErrors = document.querySelectorAll(".slds-has-error");
        window.scrollTo(0, foundErrors[0].offsetTop);
        return false;
    }
    return true;
}

function addErrorFixerListener(inpt, wrp, evtType) {
    inpt.addEventListener(evtType, (e) => {
        wrp.classList.remove("slds-has-error");
        wrp.querySelectorAll(".slds-form-element__help").forEach(errorHelp => {
            errorHelp.style.display = "none";
        });
    });
}

function fillInCityStateOnZip(zipObj) {
    let zip = zipObj.value;
    let url = "https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&addressdetails=1&postalcode=";
    if (zip.length === 5 && zip.match(/^[0-9]+$/) != null) {
        url = url + zip + "&country=united states";
    } else {
        url = url + zip;
    }

    let cityState = document.querySelectorAll('input[id$=city], select[id$=state]');
    cityState.forEach(function (cs) {
        let formElem = cs.closest(".slds-form-element");
        if (formElem !== null) {
            formElem.append(overlay.cloneNode(true));
        }
    });

    fetch(url)
        .then((response) => response.json())
        .then((result) => {
            if (result) {
                let city = result[0].address.city;
                if (city == null) {
                    city = result[0].address.hamlet;
                }
                if (city == null) {
                    city = result[0].address.town;
                }
                let state = result[0].address.state;
                if (state == null) {
                    state = result[0].address.county;
                }

                for (let [key, value] of Object.entries(RFIStates)) {
                    if (value === state) {
                        state = key;
                    }
                }
                let county = result[0].address.county;
                let country = result[0].address.country_code.toUpperCase();
                let cityInput = document.querySelector('[id$=city]');
                let stateInput = document.querySelector('[id$=state]');
                if (cityInput) {
                    cityInput.value = city;
                }
                if (stateInput) {
                    stateInput.value = state;
                }
            }
            cityState.forEach(function (cs) {
                let formElem = cs.closest(".slds-form-element");
                formElem.querySelectorAll('.waiting-overlay').forEach(function (wa) {
                    wa.remove();
                });
            });
        }).catch(error => {

    });
}

function formatPhone(phone) {
    let intr = false;
    let digits = 0;
    let inValue = phone.value;
    if (inValue.startsWith("+")) {
        intr = true;
    }
    digits = inValue.replace(/\D/g, '');
    if (intr) {
        if (digits.startsWith("0")) {
            digits = digits.substring(1);
        }
        phone.value = "+" + digits;
    } else {
        phone.value = digits.replace(/(\d{3})(\d{3})(\d{4})/, "($1) $2-$3");
    }
}

function validYear() {
    let yearsToValidate = document.querySelectorAll('.validYear');
    yearsToValidate.forEach(function (yr) {
        let yrWrap = yr.closest('.slds-form-element');
        yr.addEventListener("keyup", (e) => {
            if (yrWrap.classList.contains('slds-has-error')) {
                yrWrap.classList.remove('slds-has-error');
            }
            yrWrap.querySelectorAll(".slds-form-element__help").forEach(errorHelp => {
                errorHelp.style.display = "none"
            });
            yr.value = (yr.value.replace(/\D/g, ''));
            if (yr.value.length > 4) {
                yr.value = yr.value.slice(0, 4);
            }
        });
        yr.addEventListener("change", (e) => {
            let re = new RegExp(/(19|20)\d{2}/);
            if (!re.test(yr.value)) {
                yr.value = '';
                yrWrap.classList.add('slds-has-error');
                yrWrap.querySelectorAll(".slds-form-element__help").forEach(errorHelp => {
                    errorHelp.style.display = "block"
                });
            }
        });
    });
}

var RFIStates = {
    'AL': 'Alabama',
    'AK': 'Alaska',
    'AZ': 'Arizona',
    'AR': 'Arkansas',
    'CA': 'California',
    'CO': 'Colorado',
    'CT': 'Connecticut',
    'DE': 'Delaware',
    'FL': 'Florida',
    'GA': 'Georgia',
    'HI': 'Hawaii',
    'ID': 'Idaho',
    'IL': 'Illinois',
    'IN': 'Indiana',
    'IA': 'Iowa',
    'KS': 'Kansas',
    'KY': 'Kentucky',
    'LA': 'Louisiana',
    'ME': 'Maine',
    'MD': 'Maryland',
    'MA': 'Massachusetts',
    'MI': 'Michigan',
    'MN': 'Minnesota',
    'MS': 'Mississippi',
    'MO': 'Missouri',
    'MT': 'Montana',
    'NE': 'Nebraska',
    'NV': 'Nevada',
    'NH': 'New Hampshire',
    'NJ': 'New Jersey',
    'NM': 'New Mexico',
    'NY': 'New York',
    'NC': 'North Carolina',
    'ND': 'North Dakota',
    'OH': 'Ohio',
    'OK': 'Oklahoma',
    'OR': 'Oregon',
    'PA': 'Pennsylvania',
    'RI': 'Rhode Island',
    'SC': 'South Carolina',
    'SD': 'South Dakota',
    'TN': 'Tennessee',
    'TX': 'Texas',
    'UT': 'Utah',
    'VT': 'Vermont',
    'VA': 'Virginia',
    'WA': 'Washington',
    'WV': 'West Virginia',
    'WI': 'Wisconsin',
    'WY': 'Wyoming',
    'AB': 'Alberta',
    'AS': 'American Samoa',
    'BC': 'British Columbia',
    'DC': 'District of Columbia',
    'GU': 'Guam ',
    'MB': 'Manitoba',
    'NB': 'New Brunswick',
    'NL': 'Newfoundland and Labrador',
    'NS': 'Nova Scotia',
    'NT': 'Northwest Territories',
    'NU': 'Nunavut',
    'ON': 'Ontario',
    'PE': 'Prince Edward Island',
    'PR': 'Puerto Rico',
    'QC': 'Quebec',
    'SK': 'Saskatchewan',
    'VI': 'Virgin Islands',
    'YT': 'Yukon'
};

function createCookie(name, value, days) {
    var expires;

    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toGMTString();
    } else {
        expires = "";
    }
    document.cookie = encodeURIComponent(name) + "=" + encodeURIComponent(value) + expires + "; path=/";
}

function readCookie(name) {
    var nameEQ = encodeURIComponent(name) + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) === ' ')
            c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) === 0)
            return decodeURIComponent(c.substring(nameEQ.length, c.length));
    }
    return null;
}

function eraseCookie(name) {
    createCookie(name, "", -1);
}

var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};


ready(() => {
    document.querySelectorAll(".selectableOL").forEach(selOl => {
        //get the id of of the hidden value field in ol tag data of the selectable list
        let data2Id = selOl.dataset.hiddendataid;
        //iterate over all the li in the current ol and if the value is in the array make it selected on load
        let selOlSelected = document.querySelector("[id$=" + data2Id + "]");
        let oldSelArray = [];

        if (selOlSelected.value != null) {
            oldSelArray = selOlSelected.value.split(';');
        }

        selOl.querySelectorAll('li').forEach(selLi => {
            let textValue = selLi.innerText.trim();
            if (oldSelArray.includes(textValue)) {
                console.log('found: ' + textValue);
                selLi.classList.add('selOl-selected');
            }
            selLi.addEventListener("click", (e) => {
                let selArray = selOlSelected.value.split(';');
                if (selLi.classList.contains('selOl-selected')) {
                    selLi.classList.remove('selOl-selected');
                    selArray = arrayRemove(selArray, textValue);
                } else {
                    selLi.classList.add('selOl-selected');
                    selArray.push(textValue);
                }
                selOlSelected.value = selArray.join(';');
            });
        });

    });
});

function arrayRemove(arr, value) {
    return arr.filter(function (ele) {
        return ele != value;
    });
}

function adjustLabelsFor() {

    document.querySelectorAll('.slds-input, .slds-select, .slds-textarea').forEach(inputFound => {
        let inputWrapper = inputFound.closest('.slds-form-element')
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
    });
}

function createSpinner() {
    let overlay = document.createElement('div');
    overlay.classList.add('waiting-overlay', 'slds-spinner_container');
    let overlay1 = document.createElement('div');
    overlay1.classList.add('slds-spinner', 'slds-spinner_small');
    let overlay2 = document.createElement('div');
    overlay2.classList.add('slds-spinner__dot-a')
    let overlay3 = document.createElement('div');
    overlay3.classList.add('slds-spinner__dot-b')
    let overlay4 = document.createElement('span');
    overlay4.textContent = 'Loading';
    overlay4.classList.add('slds-assistive-text');
    overlay1.append(overlay2);
    overlay1.append(overlay3);
    overlay1.append(overlay4);
    overlay.append(overlay1);
    return overlay;
}