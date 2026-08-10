import { LightningElement, api, track } from 'lwc';

export default class SummitEventsQuestionsPage extends LightningElement {
    @api eventData;

    @track answers = {};

    connectedCallback() {
        // Initialize answers, preferring whatever the registrant already entered on a previous
        // visit to this page (persisted client-side in primaryRegistration.registrationRecord as
        // the wizard navigates) over the question's static currentValue/defaultValue from Apex.
        const registrationRecord = this.eventData?.primaryRegistration?.registrationRecord || {};
        if (this.eventData?.registrantQuestions) {
            this.eventData.registrantQuestions.forEach(question => {
                const savedValue = registrationRecord[question.mapToField];
                if (savedValue !== undefined && savedValue !== null && savedValue !== '') {
                    this.answers[question.mapToField] = savedValue;
                } else if (question.currentValue) {
                    this.answers[question.mapToField] = question.currentValue;
                } else if (question.defaultValue) {
                    this.answers[question.mapToField] = question.defaultValue;
                }
            });
        }
    }

    get questions() {
        return (this.eventData?.registrantQuestions || []).map(question => ({
            ...question,
            currentValue: this.answers[question.mapToField] ?? question.currentValue
        }));
    }

    get visibleQuestions() {
        return this.questions.filter(q => this.isQuestionVisible(q));
    }

    isQuestionVisible(question) {
        if (!question.isVisible) {
            return false;
        }

        // Check controlling logic
        if (question.controllingQuestion && question.controllingLogic) {
            const controllingValue = this.answers[question.controllingQuestion];
            return this.evaluateControllingLogic(controllingValue, question.controllingLogic);
        }

        return true;
    }

    evaluateControllingLogic(value, logic) {
        // Simple evaluation - can be enhanced
        try {
            // Replace field references with values
            const evalLogic = logic.replace(/{{VALUE}}/g, `'${value}'`);
            // eslint-disable-next-line no-eval
            return eval(evalLogic);
        } catch (e) {
            console.error('Error evaluating controlling logic:', e);
            return true;
        }
    }

    handleQuestionChange(event) {
        const field = event.detail.fieldName;
        const value = event.detail.value;
        this.answers[field] = value;
    }

    @api
    validate() {
        const questionFields = this.template.querySelectorAll('c-summit-events-question-field');
        const allValid = Array.from(questionFields).reduce((validSoFar, field) => {
            return validSoFar && field.validate();
        }, true);

        return allValid;
    }

    @api
    getData() {
        // Update registration record with answers
        const registration = { ...this.eventData.primaryRegistration.registrationRecord };

        Object.keys(this.answers).forEach(field => {
            registration[field] = this.answers[field];
        });

        return {
            primaryRegistration: {
                ...this.eventData.primaryRegistration,
                registrationRecord: registration
            }
        };
    }
}

