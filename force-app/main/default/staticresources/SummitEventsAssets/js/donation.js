document.addEventListener("DOMContentLoaded", () => {
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