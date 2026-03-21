import { LightningElement, api } from 'lwc';

export default class SummitEventsSubmitPage extends LightningElement {
    @api eventData;

    // ── Guest summary ────────────────────────────────────────────────────────

    get guestSummary() {
        return (this.eventData?.guestRegistrations || []).map((reg, idx) => {
            const rec = reg.registrationRecord || {};
            const firstName = rec.Registrant_First_Name__c || '';
            const lastName  = rec.Registrant_Last_Name__c  || '';
            return {
                id: idx,
                displayName: [firstName, lastName].filter(Boolean).join(' ') || `Guest ${idx + 1}`,
                email: rec.Registrant_Email__c || ''
            };
        });
    }

    get hasGuests() { return this.guestSummary.length > 0; }

    get guestSubmitLabel() {
        return this.eventData?.eventInfo?.Event_Guest_Submit_List_Label__c || 'Additional guests registered';
    }

    // ── Appointment summary ──────────────────────────────────────────────────

    get appointmentSummary() {
        return (this.eventData?.primaryRegistration?.appointments || [])
            .filter(a => a.Chosen_State__c !== 'Added but not shown')
            .map(a => ({
                typeId: a.Event_Appointment_Type__c || a.Appointment_Title__c,
                title: a.Appointment_Title__c || '',
                inputValue: a.Registrant_Input__c || ''
            }));
    }

    get hasAppointments() { return this.appointmentSummary.length > 0; }

    get appointmentSubmitLabel() {
        return this.eventData?.eventInfo?.Event_Appointment_Submit_List_Label__c || 'Selected options';
    }

    // ── Fee summary ──────────────────────────────────────────────────────────

    get eventFeeAmount() {
        const fee = this.eventData?.eventInfo?.Event_Fee__c;
        return fee && fee > 0 ? fee : null;
    }

    get eventFeeLabel() {
        return this.eventData?.eventInfo?.Event_Fee_Label__c || 'Event Cost';
    }

    get eventFeeFormatted() {
        return this._formatCurrency(this.eventFeeAmount);
    }

    get donationAmount() {
        const amt = this.eventData?.donationSelection?.amount;
        return amt && amt > 0 ? amt : null;
    }

    get donationFormatted() {
        return this._formatCurrency(this.donationAmount);
    }

    get totalAmount() {
        return (this.eventFeeAmount || 0) + (this.donationAmount || 0);
    }

    get totalFormatted() {
        return this._formatCurrency(this.totalAmount);
    }

    get hasCharges() {
        return this.totalAmount > 0;
    }

    get feeSubmitLabel() {
        return this.eventData?.eventInfo?.Event_Fee_Submit_List_Label__c || 'Event Charges';
    }

    get feeTotalLabel() {
        return this.eventData?.eventInfo?.Event_Fee_Total_Label__c || 'Total';
    }

    // ── Empty state ──────────────────────────────────────────────────────────

    get showEmptyState() {
        return !this.hasGuests && !this.hasAppointments && !this.hasCharges;
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    _formatCurrency(amount) {
        if (amount == null) return '';
        return '$' + parseFloat(amount).toLocaleString('en-US', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    // ── Page contract ────────────────────────────────────────────────────────

    @api validate() { return true; }
    @api getData()   { return {}; }
}
