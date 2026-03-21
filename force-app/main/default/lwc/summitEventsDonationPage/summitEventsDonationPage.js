import { LightningElement, api, track } from 'lwc';

export default class SummitEventsDonationPage extends LightningElement {
    @api eventData;

    @track selectedAmount = '';
    @track selectedAllocationId = '';
    @track customAmount = '';

    connectedCallback() {
        // Restore from existing donation selection if re-visiting the page
        const sel = this.eventData?.donationSelection;
        if (sel?.amount) {
            const amtStr = String(parseFloat(sel.amount).toFixed(2));
            // Check if this is a known suggested amount or a custom entry
            const knownAmt = this._rawSuggestedAmounts().find(a => a === amtStr);
            if (knownAmt) {
                this.selectedAmount = knownAmt;
            } else {
                this.selectedAmount = 'Other Amount';
                this.customAmount   = String(sel.amount);
            }
        }
        if (sel?.allocationId) {
            this.selectedAllocationId = sel.allocationId;
        }
    }

    // ── Computed getters ─────────────────────────────────────────────────────

    _rawSuggestedAmounts() {
        const list = this.eventData?.eventInfo?.Donation_Suggested_Amount_List__c;
        if (!list) return [];
        return list.trim().split('\n')
            .map(line => line.trim().replace(/[^0-9.]/g, ''))
            .filter(v => v)
            .map(v => parseFloat(v).toFixed(2));
    }

    get suggestedAmounts() {
        const opts = [{ label: 'Select...', value: '' }];
        this._rawSuggestedAmounts().forEach(v => {
            const num = parseFloat(v);
            const label = '$' + num.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            opts.push({ label, value: v });
        });
        opts.push({ label: 'Other Amount', value: 'Other Amount' });
        return opts;
    }

    get donationAllocations() {
        const opts = [{ label: 'Select...', value: '' }];
        const eventInfo = this.eventData?.eventInfo;
        if (!eventInfo) return opts;
        for (let i = 1; i <= 5; i++) {
            const id  = eventInfo[`Donation_Allocation_${i}__c`];
            const rel = eventInfo[`Donation_Allocation_${i}__r`];
            if (id && rel?.Name) {
                opts.push({ label: rel.Name, value: id });
            }
        }
        return opts;
    }

    get hasAllocations() {
        return this.donationAllocations.length > 1;
    }

    get showCustomAmount() {
        return this.selectedAmount === 'Other Amount';
    }

    // ── Event handlers ───────────────────────────────────────────────────────

    handleAmountChange(event) {
        this.selectedAmount = event.target.value;
        if (this.selectedAmount !== 'Other Amount') {
            this.customAmount = '';
        }
    }

    handleAllocationChange(event) {
        this.selectedAllocationId = event.target.value;
    }

    handleCustomAmountChange(event) {
        this.customAmount = event.target.value;
    }

    // ── Page contract ────────────────────────────────────────────────────────

    @api
    validate() {
        if (this.selectedAmount === 'Other Amount' && !this.customAmount) {
            const input = this.template.querySelector('lightning-input');
            if (input) input.reportValidity();
            return false;
        }
        return true;
    }

    @api
    getData() {
        let amount = null;
        if (this.selectedAmount && this.selectedAmount !== '' && this.selectedAmount !== 'Select...') {
            if (this.selectedAmount === 'Other Amount') {
                amount = this.customAmount ? parseFloat(this.customAmount) : null;
            } else {
                amount = parseFloat(this.selectedAmount);
            }
        }

        const existingFeeId = this.eventData?.donationSelection?.existingFeeId || null;

        return {
            donationSelection: {
                amount,
                allocationId: this.selectedAllocationId || null,
                existingFeeId
            }
        };
    }
}
