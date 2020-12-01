document.addEventListener("DOMContentLoaded", () => {
    let startDonationAmtElm = document.querySelector("[id$=donationAmount]");
    let startAmtSelected = document.querySelector("[id$=donationAmountSel]");

    if(startDonationAmtElm.value && !startAmtSelected.value) {
        startAmtSelected.value = 'Other Amount';
        startDonationAmtElm.style.display = 'block';
    }

    document.querySelector("[id$=donationAmountSel]").addEventListener('change', function() {
        let donationSel = this.value;
        let donationAmtElm = document.querySelector("[id$=donationAmount]");

        if (this.value === 'Other Amount') {
            donationAmtElm.style.display = "block";
        } else {
            donationAmtElm.style.display = "none";
            donationAmtElm.value = this.value;
        }

    });
});