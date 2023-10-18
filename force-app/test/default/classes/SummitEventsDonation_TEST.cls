// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 12/28/2020.

@IsTest
private class SummitEventsDonation_TEST {
    @IsTest
    static void testDonations() {
        List<Summit_Events_Instance__c> seaTestInstances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Registration__c seaTestRegistration = SummitEventsTestSharedDataFactory.createEventRegistration(seaTestInstances[1], 'TestFirst', 'TestLast', 'test@valleyhill.net', '55418', '1971-03-22', '2012', null);
        List<Summit_Events_Fee_Allocation__c> testFeeAllocations = SummitEventsTestSharedDataFactory.AddFeesToEvent(seaTestInstances[1].Event__c);
        SummitEventsTestSharedDataFactory.AddDonationsToEvents(seaTestInstances[1].Event__c, testFeeAllocations);
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User','Summit_Events_Registrant');
        System.runAs(testUser) {
            Test.startTest();
            PageReference pageRef = Page.SummitEventsDonation;
            pageRef.getParameters().put('adminopen', 'true');
            Test.setCurrentPage(pageRef);
            SummitEventsShared.createEncryptedCookie('Transfer', seaTestInstances[1].Id, seaTestInstances[1].Event__c, seaTestRegistration.Id, true);
            SummitEventsDonationController donationController = new SummitEventsDonationController();

            System.assert(donationController.getDonationAllocationList().size() > 0);
            System.assertEquals(donationController.getSuggestedDonation().size(), 6);
            System.assertEquals(donationController.checkEventDetails(), null);

            String namespace = SummitEventsNamespace.getNamespace();
            if (String.isNotBlank(namespace)) {
                System.assertEquals(donationController.previousPage().getUrl(), '/apex/' + namespace + '__summiteventsregister?adminopen=true');
            } else {
                System.assertEquals(donationController.previousPage().getUrl(), '/apex/summiteventsregister?adminopen=true');
            }


            donationController.donationAllocation = testFeeAllocations[1].Id;
            donationController.donationAmountSelect = donationController.getSuggestedDonation().get(1).getValue();
            donationController.donationAmount = donationController.donationAmountSelect;
            donationController.submitDonation();
            List<Summit_Events_Fee__c> feesSoFar = [
                    SELECT Id
                    FROM Summit_Events_Fee__c
                    WHERE Event_Fee_Type__c = 'Optional Donation'
                    AND Event_Registration__c = :seaTestRegistration.Id
                    AND Event_Fee_Allocation__c = :testFeeAllocations[1].Id
            ];
            System.assertEquals(feesSoFar.size(), 1);

            donationController = new SummitEventsDonationController();
            donationController.donationAllocation = testFeeAllocations[2].Id;
            donationController.donationAmountSelect = donationController.getSuggestedDonation().get(2).getValue();
            donationController.donationAmount = donationController.donationAmountSelect;
            donationController.submitDonation();
            feesSoFar = [
                    SELECT Id
                    FROM Summit_Events_Fee__c
                    WHERE Event_Fee_Type__c = 'Optional Donation'
                    AND Event_Registration__c = :seaTestRegistration.Id
                    AND Event_Fee_Allocation__c = :testFeeAllocations[2].Id
            ];
            System.assertEquals(feesSoFar.size(), 1);

            Test.stopTest();
        }
    }
}