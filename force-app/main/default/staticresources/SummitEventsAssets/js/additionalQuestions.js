let ready = (callback) => {
    if (document.readyState !== "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

ready(() => {
    const questionForm = document.querySelector("[id$=SummitEventQuestionForm]");
    const allInputs = questionForm.querySelectorAll('input, select, textarea');
    questionForm.addEventListener('invalid', (e) => {
        e.preventDefault();
        allInputs.forEach(formInput => {
            if (!formInput.validity.valid) {
                fadein();
                formInput.setAttribute('aria-invalid', 'true')
                formInput.closest('.slds-form-element').classList.add('slds-has-error');
                formInput.addEventListener('change', () => {
                    formInput.closest('.slds-form-element').classList.remove('slds-has-error');
                    formInput.removeAttribute('aria-invalid')
                });

            }
        });
    }, true);

});
