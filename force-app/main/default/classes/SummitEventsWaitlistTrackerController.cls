public with sharing class SummitEventsWaitlistTrackerController {
    @AuraEnabled(cacheable=true)
    public static List<WaitlistEntry> getWaitlist(Id instanceId) {
        List<WaitlistEntry> entries = new List<WaitlistEntry>();
        Integer position = 0;

        List<Summit_Events_Registration__c> registrations = [
            SELECT Id, Name, Status__c, Substatus__c, Contact__c, Contact__r.Name,
                   Registrant_First_Name__c, Registrant_Last_Name__c,
                   Registrant_Email__c, CreatedDate
            FROM Summit_Events_Registration__c
            WHERE Event_Instance__c = :instanceId
            AND Status__c IN ('Registered', 'Waitlisted', 'Confirmed', 'Cancelled', 'Attended')
            WITH USER_MODE
            ORDER BY CreatedDate ASC, Id ASC
        ];

        // Sort by status priority: Attended (0), Registered/Confirmed (1), Waitlisted (2), Cancelled (3)
        // A record counts as attended if Status = Attended OR Status = Confirmed with Substatus = Attended
        List<Summit_Events_Registration__c> sorted = new List<Summit_Events_Registration__c>();
        List<Summit_Events_Registration__c> checkedIn = new List<Summit_Events_Registration__c>();
        List<Summit_Events_Registration__c> registered = new List<Summit_Events_Registration__c>();
        List<Summit_Events_Registration__c> waitlisted = new List<Summit_Events_Registration__c>();
        List<Summit_Events_Registration__c> cancelled = new List<Summit_Events_Registration__c>();
        for (Summit_Events_Registration__c r : registrations) {
            if (isAttended(r)) { checkedIn.add(r); }
            else if (r.Status__c == 'Registered' || r.Status__c == 'Confirmed') { registered.add(r); }
            else if (r.Status__c == 'Waitlisted') { waitlisted.add(r); }
            else { cancelled.add(r); }
        }
        sorted.addAll(checkedIn);
        sorted.addAll(registered);
        sorted.addAll(waitlisted);
        sorted.addAll(cancelled);

        for (Summit_Events_Registration__c reg : sorted) {
            WaitlistEntry entry = new WaitlistEntry();
            entry.id = reg.Id;
            entry.regName = reg.Name;
            entry.status = reg.Status__c;
            entry.substatus = reg.Substatus__c;
            entry.contactId = reg.Contact__c;
            entry.contactName = reg.Contact__c != null ? reg.Contact__r.Name : (String.isNotBlank(reg.Registrant_First_Name__c) ? reg.Registrant_First_Name__c + ' ' : '') + (String.isNotBlank(reg.Registrant_Last_Name__c) ? reg.Registrant_Last_Name__c : '');
            entry.email = reg.Registrant_Email__c;
            entry.createdDate = reg.CreatedDate;
            entry.isCheckedIn = isAttended(reg);
            entry.isRegistered = !entry.isCheckedIn && (reg.Status__c == 'Registered' || reg.Status__c == 'Confirmed');
            entry.isWaitlisted = reg.Status__c == 'Waitlisted';
            entry.isCancelled = reg.Status__c == 'Cancelled';
            if (reg.Status__c == 'Waitlisted') {
                position++;
                entry.position = position;
            } else {
                entry.position = null;
            }
            entries.add(entry);
        }

        return entries;
    }

    private static Boolean isAttended(Summit_Events_Registration__c r) {
        return r.Status__c == 'Attended' || (r.Status__c == 'Confirmed' && r.Substatus__c == 'Attended');
    }

    @AuraEnabled
    public static void checkInRegistration(Id registrationId) {
        Summit_Events_Registration__c reg = [SELECT Id, Status__c FROM Summit_Events_Registration__c WHERE Id = :registrationId WITH USER_MODE];
        reg.Status__c = 'Attended';
        reg.Substatus__c = null;
        update as user reg;
    }

    @AuraEnabled
    public static void cancelRegistration(Id registrationId) {
        Summit_Events_Registration__c reg = [SELECT Id, Status__c FROM Summit_Events_Registration__c WHERE Id = :registrationId WITH USER_MODE];
        reg.Status__c = 'Cancelled';
        update as user reg;
    }

    @AuraEnabled
    public static void reinstateRegistration(Id registrationId) {
        // Bring a cancelled registrant back. Open spot → Registered. Full → Waitlisted at the back of the line,
        // but only when the instance has opted in to waitlisting; otherwise the reinstate is refused.
        Summit_Events_Registration__c reg = [
            SELECT Id, Status__c, Substatus__c, Event_Instance__c,
                   Event_Instance__r.Capacity__c,
                   Event_Instance__r.Current_Available_Capacity__c,
                   Event_Instance__r.Enable_Waitlist__c
            FROM Summit_Events_Registration__c
            WHERE Id = :registrationId
            WITH USER_MODE
        ];

        Decimal capacity = reg.Event_Instance__r.Capacity__c;
        Decimal available = reg.Event_Instance__r.Current_Available_Capacity__c;
        Boolean noCapacityTracking = capacity == null || capacity == 0;
        Boolean hasOpenSpot = noCapacityTracking || (available != null && available > 0);

        if (!hasOpenSpot && reg.Event_Instance__r.Enable_Waitlist__c != true) {
            throw new AuraHandledException('This instance is full and does not have the waitlist enabled.');
        }

        reg.Status__c = hasOpenSpot ? 'Registered' : 'Waitlisted';
        reg.Substatus__c = null;
        update as user reg;
    }

    public class WaitlistEntry {
        @AuraEnabled public Id id;
        @AuraEnabled public String regName;
        @AuraEnabled public String status;
        @AuraEnabled public String substatus;
        @AuraEnabled public Id contactId;
        @AuraEnabled public String contactName;
        @AuraEnabled public String email;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Integer position;
        @AuraEnabled public Boolean isCheckedIn;
        @AuraEnabled public Boolean isRegistered;
        @AuraEnabled public Boolean isWaitlisted;
        @AuraEnabled public Boolean isCancelled;
    }
}
