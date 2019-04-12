// USTEventsRegistrationOptionScripts
$(document).ready(function () {
    $("#chooser .appointmentAdd").on("click", function () {
        var addAppt;
        var Appt = $(this).closest(".appointment");
        var requiredSel = Appt.find('.required');
        var error = false;
        if (requiredSel.length > 0) {
            if (requiredSel.val() == '') {
                error = true;
                requiredSel.addClass('aptError').on('select, click, change', function () {
                    $(this).removeClass("aptError");
                });
            }
        }
        if (!error) {

            //build a box
            var ApptOffset = Appt.offset();
            var lc;
            var movingBox = $("<div/>", {id: 'movingBox' + Appt.attr("id"), class: 'movingBox'});
            movingBox.css({
                "width": (Appt.width() + 1) + 'px',
                "height": (Appt.height() + 1) + 'px',
                "left": ApptOffset.left + 'px',
                "top": ApptOffset.top + 'px',
            });
            movingBox.html('<p><i class="fa fa-plus" aria-hidden="true"></i> Adding Appointment...</p>')
            $('body').before(movingBox);
            if ($("#choosen .appointmentChoosen:last-child").length > 0) {
                lc = $("#choosen .appointmentChoosen:last-child");
            } else {
                lc = $("#choosen");
            }
            var lcOffset = lc.offset();
            movingBox.delay(300).animate({'top': (lcOffset.top + lc.height() + 10) + 'px', 'left': lcOffset.left + 'px', "height": "0px", "opacity": 0}, 300).fadeOut(100, function () {
                $(this).remove();
            });

            //move and adjust data
            var limit = Appt.data("limit");
            limit--;
            //build appointment list
            var apptcat = '', apptid = '', appttype = '', appttitle = '', appChosenState = '', appSort = '', appDesc = '', appInput = '';
            apptid = Appt.attr('id');
            if (Appt.data('apptcat')) {
                apptcat = Appt.data('apptcat');
            }
            if (Appt.find(".appointmentType").val()) {
                appttype = Appt.find(".appointmentType").val();
            }
            if (Appt.data('appchosenstate')) {
                appChosenState = Appt.data('appchosenstate')
            }
            if (Appt.data('appsort')) {
                appSort = Appt.data('appsort')
            }
            if (Appt.data('appdesc')) {
                appDesc = Appt.data('appdesc')
            }
            if (Appt.data('appinput')) {
                appInput = Appt.data('appinput')
            }
            appttitle = Appt.data('appttitle');

            addAppt = $('<div/>', {
                //'id' : 'appt-' + appid,
                'data-apptid': apptid,
                'data-apptcat': apptcat,
                'data-appttype': appttype,
                'data-appttitle': appttitle,
                'data-appchosenstate': appChosenState,
                'data-appsort': appSort,
                'data-appdesc': appDesc,
                'data-appinput': appInput,
                'class': 'appointmentChoosen'
            });
            addAppt.append('<p class="appointmentTitle">' + Appt.find(".appointmentTitle a").html() + '</p>');
            addAppt.find('i').remove();
            if (Appt.find(".appointmentType").length > 0) {
                addAppt.append('<p class="appointmentDesc">' + Appt.find(".appointmentType").val() + '</p>');
            }
            if (Appt.find(".appointmentCustomInput").length > 0) {
                addAppt.append('<p class="appointmentDesc">' + Appt.find(".appointmentCustomInput").val() + '</p>');
            }
            addAppt.append(
                $('<a/>', {class: "appointmentRemove"})
                    .html('<i class="fa fa-times-circle" aria-hidden="true"></i><span> Remove</span></span>')
                    .on("click", function () {
                        removeAppt($(this));
                    })
            );

            Appt.data("limit", limit);
            if (limit <= 0) {
                Appt.delay(300).fadeOut("fast", function () {
                    $("#choosen").append(addAppt);
                });
            } else {
                $("#choosen").append(addAppt);
                requiredSel.val('');
            }

        }
    });


    $(".appointmentTitle a").on("click", function () {
        if ($(this).find("i").hasClass("fa-chevron-down")) {
            $(this).find("i").removeClass("fa-chevron-down").addClass("fa-chevron-up");
        } else {
            $(this).find("i").removeClass("fa-chevron-up").addClass("fa-chevron-down");
        }
        $(this).closest(".appointment").find(".apptmentDetail").slideToggle("fast");
    });

});


function removeAppt(rmvBtn) {
    var aptChoosen = rmvBtn.closest(".appointmentChoosen");
    var appChooser = $('#' + aptChoosen.data('apptid'));
    appChooser.data('limit', appChooser.data('limit') + 1);
    appChooser.fadeIn("fast");
    aptChoosen.remove();
}

function populateApptJSON() {
    jsonOut = [];
    $("#choosen div.appointmentChoosen").each(function () {
        appt = {};
        appt['apptId'] = $(this).data('apptid');
        appt['apptCatagory'] = $(this).data('apptcat');
        appt['apptType'] = $(this).data('appttype');
        appt['apptText'] = $(this).data('appttext');
        appt['apptTitle'] = $(this).data('appttitle');
        appt['appChosenState'] = $(this).data('appchosenstate');
        appt['appSort'] = $(this).data('appsort');
        appt['appInput'] = $(this).data('appinput');
        appt['appDesc'] = $(this).find('.appointmentDesc').html();
        jsonOut.push(appt);
    });
    $('[id$=outgoingApptJSon]').val(JSON.stringify(jsonOut));
    //console.log(JSON.stringify(jsonOut));
    return checkForRequiredAppointments();
}

function checkForRequiredAppointments() {
    allApptGood = true;
    $.each($('#chooser .appointmentRequired'), function() {
        if($(this).is(':visible')) {
            allApptGood = false;
            fadein();
            if($(this).find("i.fa").hasClass('fa-chevron-down')) {
                $(this).find("a.optionToggler").click();
            }
            $(this).css({borderColor:'red'});
            $(".requiredSelectionLabel").css({'color':'black', 'opacity' : .5});
            $(".requiredSelectionLabel").animate({
                opacity: 1,
                color: 'red',
                fontWeight : 'bold'
            }, 1000, function() {
                // Animation complete.
            });
        }
    });
    return allApptGood;
}