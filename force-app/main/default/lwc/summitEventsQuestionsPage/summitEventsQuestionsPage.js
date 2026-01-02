import { LightningElement, api, track } from 'lwc';

export default class SummitEventsQuestionsPage extends LightningElement {
    @api eventData;

    @track answers = {};

    connectedCallback() {
        // Initialize answers from current values
        if (this.eventData?.registrantQuestions) {
            this.eventData.registrantQuestions.forEach(question => {
                if (question.currentValue) {
                    this.answers[question.mapToField] = question.currentValue;
                } else if (question.defaultValue) {
                    this.answers[question.mapToField] = question.defaultValue;
                }
            });
        }
    }

    get questions() {
        return this.eventData?.registrantQuestions || [];
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

