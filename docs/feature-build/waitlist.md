# Waitlisting
Waitlisting allows people to register for events which have reached their capacity. When enabled, the event form does not close when capacity is reached. Instead, additional registrations beyond the capacity threshold come in with a status of “Waitlisted”, and affected registrants see an extra page at the end of the registration experience informing them that they are on the waitlist. Waitlisted registrations do not count against the event capacity. When a registration that was previously at “Registered” status is updated to “Cancelled”, the oldest waitlisted registration (first in line), if any, is updated to “Registered”, triggering any opportunity creation and/or status-based email (if applicable).

You can turn waitlisting on or off per event instance using the “Enable Waitlist” checkbox field on the instance.

## Waitlist code (private waitlist link)
Set **Waitlist Code** on the Summit Event to open registration for a full instance without making the waitlist public. Add `&waitlist=YOURCODE` to the registration link, for example `.../SummitEventsRegister?instanceID=...&waitlist=YOURCODE`.

- The code belongs to one event and works for every instance of that event. It does not need `adminopen`, and `adminopen` is ignored when a valid code is present.
- It overrides **capacity only**. A closed registration date, an inactive instance, or an inactive event still close registration.
- Registrants who arrive on a full instance with the code are placed on the waitlist, even when Enable Waitlist is off on the instance.
- Codes are exact and case sensitive. A blank code never opens anything. Uniqueness is not enforced; use a different code per event if you want codes that cannot be reused.
- The code is read in system mode and is only visible to the Summit Events Admin permission set, not to guests.

## Technical Notes

**Fields on Summit Events Instance**

| Field | API name | Purpose |
|-------|----------|---------|
| Enable Waitlist | Enable_Waitlist__c | Toggles feature for instance. When checked, the registration wizard stays open past capacity and overflow registrations are automatically stamped as Waitlisted. When unchecked, the wizard closes at capacity Works in both pre-reg and standard reg. |

**Automation**

| Component | Type | What it does |
|-----------|------|--------------|
| Waitlist When At Capacity | Record-triggered flow — Draft | Would divert a registration to Waitlisted when the instance is full. |    
| Waitlist Auto Promote | Record-triggered flow — Draft | Would promote the next waitlisted person when a place frees up. |
| waitlistTracker | LWC and WaitlistTrackerController | Waitlist console on the Event record page. Active and usable. |

**Customizing promotion:** `Waitlist Auto Promote` is a starting point. Clone it and change the rules (priority, party limits, who is eligible) to match your process. It promotes at most one waitlisted registration per cancellation: the earliest one whose party fits in the free seats, skipping a party that is too large. Inside a record-triggered flow the instance's roll-up fields (`Current_Available_Capacity__c`) still count the registration being cancelled, because Salesforce recalculates them after the flow runs. The flow's `maxPartySize` formula adds the cancelled party's seats back. Keep that in mind if you clone it. Raising an instance's capacity does not promote anyone automatically.
