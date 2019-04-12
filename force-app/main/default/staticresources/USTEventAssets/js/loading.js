$(document).ready(function () {
    var loadingImg = '<div id="backpage" class="popupBackground">';
    loadingImg += '<div id="loading" class="PopupPanel">';
    loadingImg += '<div class="background"></div>';
    loadingImg += '<span>Please Wait..</span>';
    loadingImg += '</div></div>';
    $('body').append(loadingImg);
});

function fadein() {
    $('#backpage').hide();
}

function fadeout() {
    $('#backpage').show();
}
