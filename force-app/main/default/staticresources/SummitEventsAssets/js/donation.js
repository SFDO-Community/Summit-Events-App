document.addEventListener("DOMContentLoaded", () => {
    let startDonationAmtElm = document.querySelector("[id$=donationAmountEnter]");
    let startAmtSelected = document.querySelector("[id$=donationAmountSel]");
    let donationAmtElmArea = document.querySelector("[id$=donationAmount]");

    if(startDonationAmtElm.value && !startAmtSelected.value) {
        startAmtSelected.value = 'Other Amount';
        donationAmtElmArea.style.display = 'block';
    }

    document.querySelector("[id$=donationAmountSel]").addEventListener('change', function() {
        let donationSel = this.value;
        let donationAmtElm = document.querySelector("[id$=donationAmount]");
        let donationAmtElmArea = document.querySelector("[id$=donationAmountEnter]");
        if (this.value === 'Other Amount') {
            donationAmtElm.style.display = "block";
        } else {
            donationAmtElm.style.display = "none";
            donationAmtElmArea.value = this.value;
        }

    });
});