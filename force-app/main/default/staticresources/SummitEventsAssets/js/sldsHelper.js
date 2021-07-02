let readySLDS = (callback) => {
    if (document.readyState != "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

readySLDS(() => {
    activateTooltips();
    activateHelpButton();
});

/* Tooltip */
function activateTooltips() {
    document.querySelectorAll('.aria-describedby-tooltip').forEach(item => {
        let toolTipElement = document.getElementById(item.getAttribute('aria-describedby'));
        item.addEventListener('mousemove', function (e) {
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
        item.addEventListener('mouseleave', function (e) {
            toolTipElement.classList.remove('slds-rise-from-ground');
            toolTipElement.classList.add('slds-fall-into-ground');
        });
    });
}

/* Tooltip */
function activateHelpButton() {
    document.querySelectorAll('.helpButton').forEach(item => {
        let toolTipElement = document.getElementById(item.getAttribute('aria-describedby'));

        item.addEventListener('click', function (e) {
            e.preventDefault();
        });
        item.addEventListener('mouseover', function (e) {
            toolTipElement.classList.remove('slds-fall-into-ground', 'slds-rise-from-ground');
            toolTipElement.classList.add('slds-rise-from-ground');
        });
        item.addEventListener('mouseout', function (e) {
            toolTipElement.classList.remove('slds-fall-into-ground', 'slds-rise-from-ground');
            toolTipElement.classList.add('slds-fall-into-ground');
        });
    });
}