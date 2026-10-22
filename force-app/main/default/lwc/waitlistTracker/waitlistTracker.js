import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getWaitlist from '@salesforce/apex/SummitEventsWaitlistTrackerController.getWaitlist';
import checkInRegistration from '@salesforce/apex/SummitEventsWaitlistTrackerController.checkInRegistration';
import cancelRegistration from '@salesforce/apex/SummitEventsWaitlistTrackerController.cancelRegistration';
import reinstateRegistration from '@salesforce/apex/SummitEventsWaitlistTrackerController.reinstateRegistration';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WaitlistTracker extends NavigationMixin(LightningElement) {
    @api recordId;
    allEntries = [];
    error;
    _wiredResult;
    isLoading = false;

    @wire(getWaitlist, { instanceId: '$recordId' })
    wiredWaitlist(result) {
        this._wiredResult = result;
        if (result.data) {
            this.allEntries = result.data.map(entry => ({
                ...entry,
                regRecordUrl: '/' + entry.id,
                formattedDate: new Date(entry.createdDate).toLocaleDateString('en-US', {
                    month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit'
                }),
                positionDisplay: entry.position ? '#' + entry.position : ''
            }));
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error.body ? result.error.body.message : 'An error occurred';
            this.allEntries = [];
        }
    }

    get checkedInEntries() { return this.allEntries.filter(e => e.isCheckedIn); }
    get registeredEntries() { return this.allEntries.filter(e => e.isRegistered); }
    get waitlistedEntries() { return this.allEntries.filter(e => e.isWaitlisted); }
    get cancelledEntries() { return this.allEntries.filter(e => e.isCancelled); }

    get hasCheckedIn() { return this.checkedInEntries.length > 0; }
    get hasRegistered() { return this.registeredEntries.length > 0; }
    get hasWaitlisted() { return this.waitlistedEntries.length > 0; }
    get hasCancelled() { return this.cancelledEntries.length > 0; }

    get checkedInCount() { return this.checkedInEntries.length; }
    get registeredCount() { return this.registeredEntries.length; }
    get waitlistedCount() { return this.waitlistedEntries.length; }
    get cancelledCount() { return this.cancelledEntries.length; }

    get hasEntries() { return this.allEntries.length > 0; }

    handleCheckIn(event) {
        const regId = event.currentTarget.dataset.id;
        const name = event.currentTarget.dataset.name;
        this.isLoading = true;
        checkInRegistration({ registrationId: regId })
            .then(() => {
                this.showToast('Checked In', name + ' has been checked in', 'success');
                return refreshApex(this._wiredResult);
            })
            .catch(error => {
                this.showToast('Error', error.body ? error.body.message : 'Error', 'error');
            })
            .finally(() => { this.isLoading = false; });
    }

    handleCancel(event) {
        const regId = event.currentTarget.dataset.id;
        const name = event.currentTarget.dataset.name;
        this.isLoading = true;
        cancelRegistration({ registrationId: regId })
            .then(() => {
                this.showToast('Cancelled', name + '\'s registration has been cancelled', 'warning');
                return refreshApex(this._wiredResult);
            })
            .catch(error => {
                this.showToast('Error', error.body ? error.body.message : 'Error', 'error');
            })
            .finally(() => { this.isLoading = false; });
    }

    handleReinstate(event) {
        const regId = event.currentTarget.dataset.id;
        const name = event.currentTarget.dataset.name;
        this.isLoading = true;
        reinstateRegistration({ registrationId: regId })
            .then(() => {
                this.showToast('Reinstated', name + ' is back on the list', 'success');
                return refreshApex(this._wiredResult);
            })
            .catch(error => {
                this.showToast('Error', error.body ? error.body.message : 'Error', 'error');
            })
            .finally(() => { this.isLoading = false; });
    }

    handleContactClick(event) {
        // The anchor carries a real href so it is keyboard-focusable; navigate in-app instead of a full page load
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.dataset.id,
                actionName: 'view'
            }
        });
    }

    handleRefresh() {
        refreshApex(this._wiredResult);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}