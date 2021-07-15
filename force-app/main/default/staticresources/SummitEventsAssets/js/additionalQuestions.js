let ready = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

ready(() => {
    const questionForm = document.querySelector("[id$=SummitEventQuestionForm]");
    questionForm.addEventListener('invalid', (e) => {
        e.preventDefault();
        let allInputs = document.querySelectorAll('input, select, textarea');
        allInputs.forEach(input => {
            if (!input.validity.valid) {
                fadein();
                input.setAttribute('aria-invalid', 'true')
                input.closest('.slds-form-element').classList.add('slds-has-error');
                input.addEventListener('change', () => {
                    input.closest('.slds-form-element').classList.remove('slds-has-error');
                    input.removeAttribute('aria-invalid')
                });
            }
        });
    }, true)
});
