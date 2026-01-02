import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSummitEventData from '@salesforce/apex/SummitEventsLWCController.getSummitEventData';
import saveRegistration from '@salesforce/apex/SummitEventsLWCController.saveRegistration';

export default class SummitEventsRegistration extends LightningElement {
    @api eventInstanceId;
    @api registrationId;

    @track eventData;
    @track currentPageIndex = 0;
    @track isLoading = true;
    @track error;

    get currentPage() {
        return this.eventData?.pages?.[this.currentPageIndex];
    }

    get isFirstPage() {
        return this.currentPageIndex === 0;
    }

    get isLastPage() {
        return this.currentPageIndex === (this.eventData?.pages?.length - 1);
    }

    get showPreviousButton() {
        return !this.isFirstPage && this.currentPage?.pageType !== 'confirmation';
    }

    get showNextButton() {
        return !this.isLastPage && this.currentPage?.pageType !== 'confirmation';
    }

    get showSubmitButton() {
        return this.currentPage?.pageType === 'submit';
    }

    get pageTypeClass() {
        return 'page-container page-' + (this.currentPage?.pageType || 'unknown');
    }

    get isRegisterPage() {
        return this.currentPage?.pageType === 'register';
    }

    get isQuestionsPage() {
        return this.currentPage?.pageType === 'questions';
    }

    get isAppointmentsPage() {
        return this.currentPage?.pageType === 'appointments';
    }

    get isGuestsPage() {
        return this.currentPage?.pageType === 'guests';
    }

    get isDonationPage() {
        return this.currentPage?.pageType === 'donation';
    }

    get isSubmitPage() {
        return this.currentPage?.pageType === 'submit';
    }

    get isConfirmationPage() {
        return this.currentPage?.pageType === 'confirmation';
    }

    connectedCallback() {
        this.loadEventData();
    }

    loadEventData() {
        this.isLoading = true;
        this.error = null;

        getSummitEventData({
            eventInstanceId: this.eventInstanceId,
            registrationId: this.registrationId
        })
            .then(result => {
                this.eventData = result;
                this.currentPageIndex = result.currentPageIndex || 0;
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
                this.showToast('Error', this.getErrorMessage(error), 'error');
            });
    }

    handleNext() {
        if (this.validateCurrentPage()) {
            this.saveCurrentPageData();
            this.navigateToPage(this.currentPageIndex + 1);
        }
    }

    handlePrevious() {
        this.navigateToPage(this.currentPageIndex - 1);
    }

    handleSubmit() {
        if (this.validateCurrentPage()) {
            this.submitRegistration();
        }
    }

    navigateToPage(pageIndex) {
        if (pageIndex >= 0 && pageIndex < this.eventData.pages.length) {
            // Create new pages array with updated isActive flags to trigger reactivity
            const updatedPages = this.eventData.pages.map((page, index) => {
                return {
                    ...page,
                    isActive: index === pageIndex
                };
            });

            // Update eventData with new pages array
            this.eventData = {
                ...this.eventData,
                pages: updatedPages
            };

            // Update current page index (this is tracked so it will trigger reactivity)
            this.currentPageIndex = pageIndex;

            // Scroll to top
            window.scrollTo(0, 0);
        }
    }

    validateCurrentPage() {
        const pageComponent = this.template.querySelector('.current-page-component');
        if (pageComponent && typeof pageComponent.validate === 'function') {
            return pageComponent.validate();
        }
        return true;
    }

    saveCurrentPageData() {
        const pageComponent = this.template.querySelector('.current-page-component');
        if (pageComponent && typeof pageComponent.getData === 'function') {
            const pageData = pageComponent.getData();
            this.updateEventData(pageData);
        }
    }

    updateEventData(pageData) {
        if (pageData) {
            // Deep merge the data to maintain reactivity
            this.eventData = {
                ...this.eventData,
                ...pageData,
                // Preserve the pages array if not in pageData
                pages: pageData.pages || this.eventData.pages
            };
        }
    }

    submitRegistration() {
        this.isLoading = true;
        this.saveCurrentPageData();

        saveRegistration({
            wrapperJson: JSON.stringify(this.eventData)
        })
            .then(encryptedId => {
                this.registrationId = encryptedId;
                this.eventData.encryptedRegistrationId = encryptedId;
                const confirmationPageIndex = this.eventData.pages.findIndex(
                    page => page.pageType === 'confirmation'
                );
                if (confirmationPageIndex >= 0) {
                    this.navigateToPage(confirmationPageIndex);
                }
                this.isLoading = false;
                this.showToast('Success', 'Registration submitted successfully!', 'success');
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', this.getErrorMessage(error), 'error');
            });
    }

    getErrorMessage(error) {
        if (error.body) {
            if (error.body.message) {
                return error.body.message;
            }
            if (error.body.pageErrors && error.body.pageErrors.length > 0) {
                return error.body.pageErrors[0].message;
            }
        }
        return 'An unexpected error occurred';
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}

