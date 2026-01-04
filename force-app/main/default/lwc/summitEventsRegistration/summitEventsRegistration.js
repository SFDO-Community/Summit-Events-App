import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import getSummitEventData from '@salesforce/apex/SummitEventsLWCController.getSummitEventData';
import saveRegistration from '@salesforce/apex/SummitEventsLWCController.saveRegistration';

export default class SummitEventsRegistration extends LightningElement {
    @api eventInstanceId;
    @api registrationId;

    @track eventData;
    @track currentPageIndex = 0;
    @track isLoading = true;
    @track error;

    // Wire CurrentPageReference to get URL parameters in Experience Cloud
    @wire(CurrentPageReference)
    pageRef;

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
        // Don't show Next on confirmation page
        if (this.currentPage?.pageType === 'confirmation') {
            return false;
        }
        // Don't show Next on submit page
        if (this.currentPage?.pageType === 'submit') {
            return false;
        }
        // Don't show Next if this is the only page (show Submit instead)
        if (this.eventData?.pages?.length === 1) {
            return false;
        }
        // Show Next if not on last page
        return !this.isLastPage;
    }

    get showSubmitButton() {
        // Show Submit on the submit page
        if (this.currentPage?.pageType === 'submit') {
            return true;
        }
        // Show Submit if there's only one page (registration only)
        if (this.eventData?.pages?.length === 1) {
            return true;
        }
        return false;
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
        // Get URL parameters
        this.readUrlParameters();
        this.loadEventData();
    }

    /**
     * Read instance ID and registration ID from URL parameters
     * Uses CurrentPageReference for Experience Cloud compatibility
     * URL parameters take precedence over component properties
     */
    readUrlParameters() {
        // Get URL parameters from CurrentPageReference (works in Experience Cloud)
        const stateParams = this.pageRef?.state || {};

        console.log('PageRef State:', stateParams);
        console.log('Full PageRef:', JSON.stringify(this.pageRef));

        // Check for instanceId in URL state - URL parameter OVERRIDES @api property
        // Experience Cloud uses 'c__' prefix for custom parameters
        // Note: Also checking for 'instanceID' (capital D) for backward compatibility
        const urlInstanceId = stateParams.c__instanceId ||
                             stateParams.c__instanceID ||
                             stateParams.instanceId ||
                             stateParams.instanceID ||
                             stateParams.c__eventInstanceId ||
                             stateParams.eventInstanceId ||
                             stateParams.c__id ||
                             stateParams.id;

        if (urlInstanceId) {
            console.log('Found instance ID in URL:', urlInstanceId);
            this.eventInstanceId = urlInstanceId;
        }

        // Check for registrationId in URL state - URL parameter OVERRIDES @api property
        const urlRegistrationId = stateParams.c__registrationId ||
                                 stateParams.c__registrationID ||
                                 stateParams.registrationId ||
                                 stateParams.registrationID ||
                                 stateParams.c__regId ||
                                 stateParams.regId;

        if (urlRegistrationId) {
            console.log('Found registration ID in URL:', urlRegistrationId);
            this.registrationId = urlRegistrationId;
        }

        // Fallback: Try standard window.location.search (for non-Experience Cloud)
        if (!urlInstanceId) {
            const urlParams = new URLSearchParams(window.location.search);
            const fallbackInstanceId = urlParams.get('instanceId') ||
                                       urlParams.get('instanceID') ||
                                       urlParams.get('eventInstanceId') ||
                                       urlParams.get('id');

            if (fallbackInstanceId) {
                console.log('Found instance ID in window.location:', fallbackInstanceId);
                this.eventInstanceId = fallbackInstanceId;
            }

            if (!urlRegistrationId) {
                const fallbackRegId = urlParams.get('registrationId') ||
                                     urlParams.get('registrationID') ||
                                     urlParams.get('regId');
                if (fallbackRegId) {
                    console.log('Found registration ID in window.location:', fallbackRegId);
                    this.registrationId = fallbackRegId;
                }
            }
        }

        // Log final values for debugging
        console.log('Final Event Instance ID (from URL or API):', this.eventInstanceId);
        console.log('Final Registration ID (from URL or API):', this.registrationId);
    }

    loadEventData() {
        this.isLoading = true;
        this.error = null;

        // Validate that we have an instance ID
        if (!this.eventInstanceId) {
            this.error = 'Event Instance ID is required. Please provide it via URL parameter (instanceId, eventInstanceId, or id) or component property.';
            this.isLoading = false;
            this.showToast('Error', this.error, 'error');
            return;
        }

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

