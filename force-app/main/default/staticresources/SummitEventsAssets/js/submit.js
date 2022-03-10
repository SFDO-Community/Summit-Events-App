const submitReady = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

const regExSingle = /'*'/g;
const regExDouble = /"*"/g;

submitReady(() => {
    document.querySelectorAll('#chosenAppointments li, .feeAllocation').forEach(desc => {
        desc.innerHTML = desc.innerHTML.replaceAll('&amp;#39;', '\'');
        desc.innerHTML = desc.innerHTML.replaceAll('&amp;quot;', '\"');
        desc.innerHTML = desc.innerHTML.replace(regExSingle, '\'');
        desc.innerHTML = desc.innerHTML.replace(regExDouble, '\"');
    })
    document.querySelectorAll('.slds-notify__close .slds-button').forEach( closeBtn => {
        closeBtn.addEventListener('click', function (e) {
            e.preventDefault();
            closeBtn.closest('.slds-notify_alert').remove();
        });
    })
});