var loadReady = (callback) => {
    if (document.readyState != "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

loadReady(() => {
    let backpage = document.createElement("DIV");
    backpage.setAttribute("id","backpage");
    backpage.classList.add("popupBackground");

    let loadingPanel = document.createElement("DIV");
    loadingPanel.setAttribute("id","loading");
    loadingPanel.classList.add("PopupPanel");

    let background = document.createElement("DIV");
    background.classList.add("background");

    let pleaseWait = document.createElement("SPAN");
    pleaseWait.style.fontFamily = "Arial, Helvetica, sans-serif";
    pleaseWait.style.fontSize = '12px';
    pleaseWait.innerHTML = "Please Wait..";

    loadingPanel.appendChild(background);
    loadingPanel.appendChild(pleaseWait);
    backpage.appendChild(loadingPanel);
    document.body.appendChild(backpage);
});


function fadein() {
    let fadeWrapper = document.getElementById('backpage');
    if(fadeWrapper){
        fadeWrapper.style.display = "none";
    }
    return true;
}

function fadeout() {
    let fadeWrapper = document.getElementById('backpage');
    fadeWrapper.style.display = "block";
    return true;
}
