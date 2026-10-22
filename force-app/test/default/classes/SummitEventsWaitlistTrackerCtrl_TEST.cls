@IsTest
private class SummitEventsWaitlistTrackerCtrl_TEST {

    private static Summit_Events_Instance__c makeInstance(Decimal capacity, Boolean enableWaitlist) {
        Summit_Events__c evt = new Summit_Events__c(
                Event_Name__c = 'Waitlist Tracker Test Event',
                Template__c = 'GeneralSLDS',
                Event_Status__c = 'Active'
        );
        insert evt;
        Summit_Events_Instance__c inst = new Summit_Events_Instance__c(
                Event__c = evt.Id,
                Instance_Title__c = 'WL Tracker Instance',
                Active_Status__c = 'Active',
                Capacity__c = capacity,
                Enable_Waitlist__c = enableWaitlist,
                Instance_Start_Date__c = Date.today().addDays(7),
                Instance_End_Date__c = Date.today().addDays(7)
        );
        insert inst;
        return inst;
    }

    private static Summit_Events_Registration__c makeReg(Summit_Events_Instance__c inst, String status, String firstName) {
        return makeReg(inst, status, firstName, null);
    }

    private static Summit_Events_Registration__c makeReg(Summit_Events_Instance__c inst, String status, String firstName, Decimal guests) {
        Summit_Events_Registration__c r = new Summit_Events_Registration__c(
                Event__c = inst.Event__c,
                Event_Instance__c = inst.Id,
                Registrant_First_Name__c = firstName,
                Registrant_Last_Name__c = 'WLTest',
                Registrant_Email__c = firstName.toLowerCase() + '.wl@test.example',
                Number_of_Guests__c = guests,
                Status__c = status
        );
        insert r;
        if (!insideTestContext) {
            // Records inserted in one test share a CreatedDate second; space them out so FIFO order is deterministic
            regSequence++;
            Test.setCreatedDate(r.Id, Datetime.now().addMinutes(-100 + regSequence));
        }
        return r;
    }

    // Test.setCreatedDate() is not allowed after Test.startTest(), so registrations made there keep their natural CreatedDate
    private static Boolean insideTestContext = false;

    private static Integer regSequence = 0;

    private static String statusOf(Id regId) {
        return [SELECT Status__c FROM Summit_Events_Registration__c WHERE Id = :regId].Status__c;
    }

    // ---- Tracker actions ----

    @IsTest static void testCheckInFlipsToAttended() {
        Summit_Events_Instance__c inst = makeInstance(10, false);
        Summit_Events_Registration__c reg = makeReg(inst, 'Registered', 'CheckMe');

        Test.startTest();
        SummitEventsWaitlistTrackerController.checkInRegistration(reg.Id);
        Test.stopTest();

        Summit_Events_Registration__c after = [SELECT Status__c, Substatus__c FROM Summit_Events_Registration__c WHERE Id = :reg.Id];
        System.assertEquals('Attended', after.Status__c, 'Check In button should stamp Status=Attended');
        System.assertEquals(null, after.Substatus__c, 'Substatus should be cleared on manual check-in');
    }

    @IsTest static void testCancelFlipsToCancelled() {
        Summit_Events_Instance__c inst = makeInstance(10, false);
        Summit_Events_Registration__c reg = makeReg(inst, 'Registered', 'CancelMe');

        Test.startTest();
        SummitEventsWaitlistTrackerController.cancelRegistration(reg.Id);
        Test.stopTest();

        System.assertEquals('Cancelled', statusOf(reg.Id));
    }

    @IsTest static void testReinstateWithCapacityGoesToRegistered() {
        Summit_Events_Instance__c inst = makeInstance(10, false);
        Summit_Events_Registration__c reg = makeReg(inst, 'Cancelled', 'Comeback');

        Test.startTest();
        SummitEventsWaitlistTrackerController.reinstateRegistration(reg.Id);
        Test.stopTest();

        System.assertEquals('Registered', statusOf(reg.Id), 'Reinstate with open capacity should promote to Registered');
    }

    @IsTest static void testReinstateFullWithWaitlistGoesToWaitlisted() {
        Summit_Events_Instance__c inst = makeInstance(1, true);
        makeReg(inst, 'Registered', 'Filler');
        Summit_Events_Registration__c reg = makeReg(inst, 'Cancelled', 'BackFromDead');

        Test.startTest();
        SummitEventsWaitlistTrackerController.reinstateRegistration(reg.Id);
        Test.stopTest();

        System.assertEquals('Waitlisted', statusOf(reg.Id), 'Reinstate when full should go to Waitlisted on a waitlist-enabled instance');
    }

    @IsTest static void testReinstateFullWithoutWaitlistIsRejected() {
        Summit_Events_Instance__c inst = makeInstance(1, false);
        makeReg(inst, 'Registered', 'Filler');
        Summit_Events_Registration__c reg = makeReg(inst, 'Cancelled', 'NoRoom');

        Boolean threw = false;
        Test.startTest();
        try {
            SummitEventsWaitlistTrackerController.reinstateRegistration(reg.Id);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assert(threw, 'Reinstate into a full instance without the waitlist should be refused');
        System.assertEquals('Cancelled', statusOf(reg.Id), 'Registration should be left unchanged');
    }

    @IsTest static void testReinstateUntrackedCapacityGoesToRegistered() {
        Summit_Events_Instance__c inst = makeInstance(null, false);
        Summit_Events_Registration__c reg = makeReg(inst, 'Cancelled', 'Unlimited');

        Test.startTest();
        SummitEventsWaitlistTrackerController.reinstateRegistration(reg.Id);
        Test.stopTest();

        System.assertEquals('Registered', statusOf(reg.Id), 'Untracked capacity always reinstates to Registered');
    }

    @IsTest static void testGetWaitlistReturnsSortedEntries() {
        Summit_Events_Instance__c inst = makeInstance(10, true);
        makeReg(inst, 'Cancelled', 'A');
        makeReg(inst, 'Waitlisted', 'B');
        makeReg(inst, 'Confirmed', 'C');
        makeReg(inst, 'Registered', 'D');
        makeReg(inst, 'Attended', 'E');

        Test.startTest();
        List<SummitEventsWaitlistTrackerController.WaitlistEntry> entries = SummitEventsWaitlistTrackerController.getWaitlist(inst.Id);
        Test.stopTest();

        System.assertEquals(5, entries.size());
        System.assertEquals(true, entries[0].isCheckedIn, 'First should be checked in (Attended)');
        System.assertEquals(true, entries[1].isRegistered, 'Confirmed should sit in the Registered bucket');
        System.assertEquals(true, entries[2].isRegistered, 'Registered should sit in the Registered bucket');
        System.assertEquals(true, entries[3].isWaitlisted, 'Fourth should be Waitlisted');
        System.assertEquals(true, entries[4].isCancelled, 'Fifth should be Cancelled');
    }

    @IsTest static void testWaitlistedEntriesGetPositions() {
        Summit_Events_Instance__c inst = makeInstance(1, true);
        makeReg(inst, 'Registered', 'Seat');
        makeReg(inst, 'Waitlisted', 'W1');
        makeReg(inst, 'Waitlisted', 'W2');
        makeReg(inst, 'Waitlisted', 'W3');

        Test.startTest();
        List<SummitEventsWaitlistTrackerController.WaitlistEntry> entries = SummitEventsWaitlistTrackerController.getWaitlist(inst.Id);
        Test.stopTest();

        Integer positioned = 0;
        for (SummitEventsWaitlistTrackerController.WaitlistEntry e : entries) {
            if (e.isWaitlisted) {
                positioned++;
                System.assertEquals(positioned, e.position, 'Waitlisted entries should be numbered in order');
            } else {
                System.assertEquals(null, e.position, 'Non-waitlisted entries should have null position');
            }
        }
        System.assertEquals(3, positioned, 'Should be 3 waitlisted entries with positions');
    }

    // ---- Waitlist_When_At_Capacity flow ----

    @IsTest static void testInsertWhenFullIsWaitlisted() {
        Summit_Events_Instance__c inst = makeInstance(1, true);
        makeReg(inst, 'Registered', 'Seat');

        Test.startTest();
        insideTestContext = true;
        Summit_Events_Registration__c overflow = makeReg(inst, 'Registered', 'Overflow');
        Test.stopTest();

        System.assertEquals('Waitlisted', statusOf(overflow.Id), 'Registered insert into a full waitlist-enabled instance should be waitlisted');
    }

    @IsTest static void testInsertWhenFullWithoutWaitlistIsUnchanged() {
        Summit_Events_Instance__c inst = makeInstance(1, false);
        makeReg(inst, 'Registered', 'Seat');

        Test.startTest();
        insideTestContext = true;
        Summit_Events_Registration__c overflow = makeReg(inst, 'Registered', 'Overflow');
        Test.stopTest();

        System.assertEquals('Registered', statusOf(overflow.Id), 'Waitlist-off instances keep existing behavior');
    }

    // ---- Waitlist_Auto_Promote flow ----

    @IsTest static void testCancelPromotesNextWaitlisted() {
        Summit_Events_Instance__c inst = makeInstance(1, true);
        Summit_Events_Registration__c seated = makeReg(inst, 'Registered', 'Seat');
        Summit_Events_Registration__c first = makeReg(inst, 'Waitlisted', 'First');
        Summit_Events_Registration__c second = makeReg(inst, 'Waitlisted', 'Second');

        Test.startTest();
        seated.Status__c = 'Cancelled';
        update seated;
        Test.stopTest();

        System.assertEquals('Registered', statusOf(first.Id), 'Earliest waitlisted registration should be promoted');
        System.assertEquals('Waitlisted', statusOf(second.Id), 'Only one registration should be promoted per freed seat');
    }

    @IsTest static void testCancelDoesNotPromoteWhenWaitlistDisabled() {
        Summit_Events_Instance__c inst = makeInstance(1, false);
        Summit_Events_Registration__c seated = makeReg(inst, 'Registered', 'Seat');
        Summit_Events_Registration__c waiting = makeReg(inst, 'Waitlisted', 'Waiting');

        Test.startTest();
        seated.Status__c = 'Cancelled';
        update seated;
        Test.stopTest();

        System.assertEquals('Waitlisted', statusOf(waiting.Id), 'Auto-promote must not run on instances that have not opted in');
    }

    @IsTest static void testCancelSkipsPartyTooLargeForFreedSeats() {
        // Default Capacity_Control__c is Registrants plus Guests, so a party of 3 needs 3 seats
        Summit_Events_Instance__c inst = makeInstance(1, true);
        Summit_Events_Registration__c seated = makeReg(inst, 'Registered', 'Seat');
        Summit_Events_Registration__c bigParty = makeReg(inst, 'Waitlisted', 'BigParty', 2);
        Summit_Events_Registration__c single = makeReg(inst, 'Waitlisted', 'Single');

        Test.startTest();
        seated.Status__c = 'Cancelled';
        update seated;
        Test.stopTest();

        System.assertEquals('Waitlisted', statusOf(bigParty.Id), 'A party larger than the freed seats should stay waitlisted');
        System.assertEquals('Registered', statusOf(single.Id), 'The next party that fits should be promoted');
    }

    @IsTest static void testCancelUsesAllFreeSeatsNotJustTheCancelledParty() {
        // Capacity 6: two parties of 2 are seated, so 2 seats were already free. Cancelling one party frees 2 more (4 total),
        // enough for the waitlisted party of 3 even though the cancelled party only held 2.
        Summit_Events_Instance__c inst = makeInstance(6, true);
        Summit_Events_Registration__c seated = makeReg(inst, 'Registered', 'SeatOne', 1);
        makeReg(inst, 'Registered', 'SeatTwo', 1);
        Summit_Events_Registration__c party = makeReg(inst, 'Waitlisted', 'Party', 2);

        Test.startTest();
        seated.Status__c = 'Cancelled';
        update seated;
        Test.stopTest();

        System.assertEquals('Registered', statusOf(party.Id), 'Promotion should use every free seat, including seats that were already open');
    }

    @IsTest static void testCancelDoesNotPromoteWhenStillOverbooked() {
        // Individual Registrants: capacity 1 but two seated (admin override). One cancellation leaves it exactly full.
        Summit_Events_Instance__c inst = makeInstance(1, true);
        inst.Capacity_Control__c = 'Individual Registrants';
        update inst;
        Summit_Events_Registration__c seated = makeReg(inst, 'Registered', 'SeatOne');
        makeReg(inst, 'Confirmed', 'SeatTwo');
        Summit_Events_Registration__c waiting = makeReg(inst, 'Waitlisted', 'Waiting');

        Test.startTest();
        seated.Status__c = 'Cancelled';
        update seated;
        Test.stopTest();

        System.assertEquals('Waitlisted', statusOf(waiting.Id), 'No seat is free after the cancellation, so nobody is promoted');
    }
}
