// USTEventRegisterScripts
var overlay = '<div class="waiting-overlay"></div>';
var ChosenSchoolFilter;
var ChosenCollegeFilter;
var ChosenProcess = {};
var ChosenProcessActive = {};
var USTSettings = JSON.parse(readCookie('USTEvent'));
var audience;

$(document).ready(function () {
    $("input[type=hidden]").bind("change", function () {
        console.log($(this).val());
    });
    // get audience
    audience = getUrlParameter('audience');
    if (!audience) {
        if (USTSettings != null) {
            if (USTSettings.audience !== null) {
                audience = USTSettings.audience;
            }
        }
    }
    if (!audience) {
        audience = "High School";
    }

    $("input, textarea").each(function () {
        $(this).blur();
    });
    $("input, textarea").first().blur();


    window.scrollTo(0, 0);

    $("#cantFindHS").on("change", function () {
        if ($(this).is(":checked")) {
            $("#schoolSelector").val('').trigger('chosen:updated');
            populateHiddenSchoolValue();
            $("#schoolSelector_chosen").hide();
            $("[id$=HSAltInput]").show();
        } else {
            $("[id$=HSAltInput]").val('').hide();
            $("#schoolSelector_chosen").show();
        }
    });

    $("#cantFindCollege").on("change", function () {
        if ($(this).is(":checked")) {
            $("#collegeSelector").val('').trigger('chosen:updated');
            populateHiddenSchoolValue();
            $("#collegeSelector_chosen").hide();
            $("[id$=CollegeAltInput]").show();
        } else {
            $("[id$=CollegeAltInput]").val('').hide();
            $("#collegeSelector_chosen").show();
        }
    });

    //Set up both school selectors
    //check if selection has already been made
    if ($("[id$=school]").val() && $("[id$=schoolCode]").val()) {
        $("#schoolSelector").append($('<option>', {value: $("[id$=schoolCode]").val(), text: $("[id$=school]").val(), selected: true}));
    }
    if ($("[id$=college]").val() && $("[id$=collegeCode]").val()) {
        $("#collegeSelector").append($('<option>', {value: $("[id$=collegelCode]").val(), text: $("[id$=college]").val(), selected: true}));
    }


    $("#schoolSelector, #collegeSelector").chosen(
        {no_results_text: "<img src='//static.stthomas.edu/undergraduate-admissions/rfi/images/spinner.gif'/> No results yet, keep typing..."}
    ).change(function () {
        populateHiddenSchoolValue();
    }).select(function () {
        populateHiddenSchoolValue();
    });

    ChosenSchoolFilter = $("#schoolSelector").next('.chosen-container').find('.chosen-search-input');
    ChosenCollegeFilter = $("#collegeSelector").next('.chosen-container').find('.chosen-search-input');


    //activate zip fill in for city state
    $('[id$=zip]').on("change", function () {
        fillInCityStateOnZip($(this));
    });

    //make sure phone is formated correctly
    dynamicValidation();

    validYear();

    ChosenSchoolFilter.on("keyup", function (e) {
        var code = (e.keyCode || e.which);
        if (code == 37 || code == 38 || code == 39 || code == 40) {
            return true;
        }
        //When return is hit populate hidden data because something was selected.
        if (e.code == 13) {
            populateHiddenSchoolValue();
        }
        if ($(this).val().length > 3) {
            getSchoolOptions($(this).val(), 'highSchool');
        }
    });

    ChosenCollegeFilter.on("keyup", function (e) {
        var code = (e.keyCode || e.which);
        if (code == 37 || code == 38 || code == 39 || code == 40) {
            return true;
        }
        if ($(this).val().length > 3) {
            getSchoolOptions($(this).val(), 'college');
        }
    });

    if ($("[id$=HSAltInput]").val()) {
        $("#cantFindHS").click();
    }
    if ($("[id$=CollegeAltInput]").val()) {
        $("#cantFindCollege").click();
    }

    $('[id$=progInterest]').chosen({max_selected_options: 4});

});

function dynamicValidation() {
    $('[id$=phone], [id$=mobile], .validPhone').on('change', function () {
        formatPhone($(this));
    });
}

function populateHiddenSchoolValue() {
    if ($("[id$=school]").length > 0) {
        $("[id$=school]").val($("#schoolSelector option:selected").text());
        $("[id$=schoolCode]").val($("#schoolSelector").val());
    }
    if ($("[id$=college]").length > 0) {
        $("[id$=college]").val($("#collegeSelector option:selected").text());
        $("[id$=collegeCode]").val($("[id$=collegeSelector]").val());
    }
    if ($("[id$=HSAltInput]").val()) {
        $("[id$=school]").val($("#HSAltInput").val());
    }
    if ($("[id$=CollegeAltInput]").val()) {
        $("[id$=college]").val($("[id$=CollegeAltInput]").val());
    }
}

function getSchoolOptions(filter, type) {
    if (ChosenProcessActive[type]) {
        ChosenProcess[type].abort();
    }
    ChosenProcessActive[type] = true;
    ChosenProcess[type] = $.ajax({
        url: "/services/apexrest/ustadmissionsrest",
        data: {'type': type, 'filter': filter},
        dataType: "json"
    }).done(function (data) {
        if (data) {
            if (type == 'highSchool') {
                populateschSel(data, $("#schoolSelector"));
                $("#schoolSelector").trigger('chosen:updated');
            } else if (type == 'college') {
                populateschSel(data, $("#collegeSelector"));
                $("#collegeSelector").trigger('chosen:updated');
            }
        }
        ChosenProcessActive[type] = false;
    })
}

function populateschSel(data, selector, keyAsText) {
    selector.find("option").remove();
    selector.append($('<option>').text('Select a school from results...').attr('value', ''));
    $.each(data, function (key, value) {
        selector.append($('<option>').text(value).attr('value', key));
    });
}

//Validation for the page
function checkForm() {
    console.log('Check the form begins.....')
    populateHiddenSchoolValue();
    var error_count = 0;
    var emailReg = /^([a-zA-Z0-9_.\-.'.+])+@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;

    $.each($('[id$=USTRegistraterForm] input, [id$=USTRegistraterForm] select'), function (i, v) {
        if ($(this).hasClass("required") && !$(this).val()) {
            $(this).addClass("validationError");
            $('label[for="' + $(this).attr("id") + '"]').addClass("validationError");
            //console.log('THIS ERRORED:' + $(this).attr('id'));
            error_count++;
        }
        if ($(this).hasClass("validEmail")) {
            if (!emailReg.test($(this).val())) {
                $(this).addClass("validationError");
                $('label[for="' + $(this).attr("id") + '"]').addClass("validationError");
                error_count++;
                //console.log('THIS EMAIL ERRORED:' + $(this).attr('id'));
            }
        }
    });

    $.each($(".selectableOL"), function () {
        if ($(this).attr("required") == "required") {
            var sOLId = $(this).data("hiddendataid");
            sOLId = $("[id$=" + sOLId + "]");
            if (!sOLId.val()) {
                $('label[for="' + sOLId.attr("id") + '"]').addClass("validationError");
                sOLId.addClass("validationError");
                error_count++;
            }
        }

    });
    // require school be filled in.
    if ($("[id$=collegeAsk]").length > 0) {
        if (!$("[id$=college]").val() && !$("[id$=CollegeAltInput]").val()) {
            error_count++;
            $(this).addClass("validationError");
            if ($("[id$=CollegeAltInput]").val()) {
                $("#collegeSelector").addClass("validationError");
            } else {
                $("[id$=CollegeAltInput]").addClass("validationError");
            }
            $('label[for="collegeSelector"]').addClass("validationError");
        }
    }

    if ($("[id$=hsAsk]").length > 0) {
        if (!$("[id$=school]").val() && !$("[id$=HSAltInput]").val()) {
            error_count++;
            if ($("[id$=HSAltInput]").val()) {
                $("#schoolSelector").addClass("validationError");
            } else {
                $("[id$=HSAltInput]").addClass("validationError");
            }
            $('label[for="schoolSelector"]').addClass("validationError");
        }
    }

    console.log(error_count);
    if (error_count > 0) {
        fadein();
        validationErrorAction();
        //Scroll to first error
        var firstInvalid = $(".validationError:first");
        $([document.documentElement, document.body]).animate({
            scrollTop: firstInvalid.offset().top - 10
        }, 200);
        return false;
    }

    return true;
}

function validationErrorAction() {
    $(".validationError").on("change", function () {
        // alert();
        $('label[for="' + $(this).attr("id") + '"]').removeClass("validationError");
        $('label[for="' + $(this).attr("id") + '"]').removeClass("validationError");
        if ($(this).hasClass("HSAltInput")) {
            $('label[for="schoolSelector"]').removeClass("validationError");
        }
        if ($(this).hasClass("CollegeAltInput")) {
            $('label[for="collegeSelector"]').removeClass("validationError");
        }
        $(this).removeClass("validationError");
    });

}

function fillInCityStateOnZip(zipObj) {
    var zip = zipObj.val();
    var url = "https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&addressdetails=1&postalcode=";
    if (zip.length === 5 && zip.match(/^[0-9]+$/) != null) {
        url = url + zip + "&country=united states";
    } else {
        url = url + zip;
    }

    $('[id$=city], [id$=state]').closest(".columns").prepend(overlay)
    $.getJSON(url, function (result) {
        if (result.length > 0) {
            var city = result[0].address.city;
            if (city == null) {
                city = result[0].address.hamlet;
            }
            if (city == null) {
                city = result[0].address.town;
            }
            var state = result[0].address.state;
            if (state == null) {
                state = result[0].address.county;
            }

            $.each(RFIStates, function (key, value) {
                if (value === state) {
                    state = key;
                }
            });
            //state = RFIStates.value[state].key;
            var county = result[0].address.county;
            var country = result[0].address.country_code.toUpperCase();
            $("[id$=city]").val(city);
            $("[id$=state]").val(state);
        }
    }).always(function () {
        $(".waiting-overlay").remove();
    });
}

function formatPhone(obj) {
    var intr = false,
        digits = 0;
    if (obj.val().startsWith("+")) {
        intr = true;
    }
    digits = obj.val().replace(/\D/g, '');
    if (intr) {
        if (digits.startsWith("0")) {
            digits = digits.substring(1);
        }
        obj.val("+" + digits);
    } else {
        obj.val(digits.replace(/(\d{3})(\d{3})(\d{4})/, "($1) $2-$3"));
    }
}

function validYear() {
    $(".validYear").on("keyup", function () {
        $(this).val($(this).val().replace(/\D/g, ''));
        $(this).parent().find(".yearError").remove();
        if (this.value.length > 4) {
            $(this).val(this.value.slice(0, 4));
        }
    });
    $(".validYear").on("change", function () {
        var re = new RegExp(/(19|20)\d{2}/);
        if (!re.test($(this).val())) {
            $(this).val("");
            $(this).after("<span class='yearError'>Enter a valid graduation year.</span>");
        }
        ;
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

/* isNumberKey
    Only allows NUMBERS to be keyed into a text field.
    @environment ALL
    @param evt - The specified EVENT that happens on the element.
    @return True if number, false otherwise.
*/
function isNumberKey(evt) {

    return true;
} // isNumberKey

$(document).ready(function () {
    $.each($(".selectableOL"), function () {
        //get the id of of the hidden value field in ol tag data of the selectable list
        var data2Id = $(this).data("hiddendataid");
        //get the hidden data and split it into an array
        var oldSelections = $("[id$=" + data2Id + "]").val().split(';');
        //iterate over all the li in the current ol and if the value is in the array make it selected on load
        $.each($(this).children("li"), function () {
            if ($.inArray($(this).html(), oldSelections) > -1) {
                $(this).addClass('ui-selected');
            }
        });

        $("#" + $(this).attr("id")).bind("mousedown", function (e) {
            e.metaKey = true;
        }).selectable({
            //load all selected items of each list into an array
            stop: function () {
                var selectList = [];
                $.each(
                    $(this).children("li.ui-selected"),
                    function () {
                        selectList.push($(this).html())
                    });
                //populate the hidden data field to transfer to SF on submit
                $("[id$=" + data2Id + "]").val(selectList.join(';'));
                //remove any validation errors that might exist from previous submit
                $("[id$=" + data2Id + "]").removeClass('validationError');
                $('label[for="' + $("[id$=" + data2Id + "]").attr("id") + '"]').removeClass('validationError');
            }
        });
    });
});