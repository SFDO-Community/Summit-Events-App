@IsTest
private class SummitEventsWaitlistCode_TEST {

    private static Summit_Events_Instance__c fullInstance(String eventCode) {
        List<Summit_Events_Instance__c> instances = SummitEventsTestSharedDataFactory.createTestEvent();
        Summit_Events_Instance__c instance = instances[5];
        instance.Capacity__c = 1;
        update instance;
        Summit_Events__c event = new Summit_Events__c(Id = instance.Event__c, Waitlist_Code__c = eventCode);
        update event;
        Summit_Events_Registration__c registration = SummitEventsTestSharedDataFactory.createEventRegistration(instance, 'Full', 'Seat', 'full@example.com', '55555', '2000-01-01', '2030', null);
        registration.Status__c = 'Registered';
        update registration;
        return SummitEventsReadShared.getInstanceById(instance.Id);
    }

    private static void setUrl(Map<String, String> parameters) {
        PageReference pageRef = Page.SummitEventsRegister;
        pageRef.getParameters().putAll(parameters);
        Test.setCurrentPage(pageRef);
    }

    @IsTest
    static void fullInstanceStaysClosedWithoutCode() {
        Summit_Events_Instance__c instance = fullInstance('SECRET1');
        System.assert(instance.Current_Available_Capacity__c <= 0, 'Instance should be full');
        setUrl(new Map<String, String>());
        System.assertEquals(true, SummitEventsShared.isEventClosed(instance, 'Active'));
    }

    @IsTest
    static void correctCodeOpensFullInstance() {
        Summit_Events_Instance__c instance = fullInstance('SECRET1');
        setUrl(new Map<String, String>{'waitlist' => 'SECRET1'});
        System.assertEquals(true, SummitEventsShared.isWaitlistCodeValid(instance));
        System.assertEquals(false, SummitEventsShared.isEventClosed(instance, 'Active'));
    }

    @IsTest
    static void wrongOrDifferentCaseCodeStaysClosed() {
        Summit_Events_Instance__c instance = fullInstance('SECRET1');
        setUrl(new Map<String, String>{'waitlist' => 'WRONG'});
        System.assertEquals(true, SummitEventsShared.isEventClosed(instance, 'Active'));
        setUrl(new Map<String, String>{'waitlist' => 'secret1'});
        System.assertEquals(true, SummitEventsShared.isEventClosed(instance, 'Active'));
    }

    @IsTest
    static void blankEventCodeNeverMatches() {
        Summit_Events_Instance__c instance = fullInstance(null);
        setUrl(new Map<String, String>{'waitlist' => 'anything'});
        System.assertEquals(false, SummitEventsShared.isWaitlistCodeValid(instance));
        System.assertEquals(true, SummitEventsShared.isEventClosed(instance, 'Active'));
    }

    @IsTest
    static void codeWorksWithoutAdminOpenAndIgnoresIt() {
        Summit_Events_Instance__c instance = fullInstance('SECRET1');
        setUrl(new Map<String, String>{'waitlist' => 'SECRET1', 'adminopen' => '0'});
        System.assertEquals(false, SummitEventsShared.isEventClosed(instance, 'Active'));
    }

    @IsTest
    static void codeDoesNotOverrideInactiveStatus() {
        Summit_Events_Instance__c instance = fullInstance('SECRET1');
        setUrl(new Map<String, String>{'waitlist' => 'SECRET1'});
        System.assertEquals(true, SummitEventsShared.isEventClosed(instance, 'Archived'));
        instance.Active_Status__c = 'Cancelled';
        System.assertEquals(true, SummitEventsShared.isEventClosed(instance, 'Active'));
    }

    @IsTest
    static void waitlistParameterIsCarriedBetweenPages() {
        Summit_Events_Instance__c instance = fullInstance('SECRET1');
        setUrl(new Map<String, String>{'waitlist' => 'SECRET1'});
        Map<String, PageReference> pageFlow = SummitEventsShared.getPageFlow(instance.Event__r.Id, instance.Instance_Title__c, ApexPages.currentPage(), instance.Instance_Start_Date__c, instance.Instance_End_Date__c);
        System.assertEquals('SECRET1', pageFlow.get('Next').getParameters().get('waitlist'));
    }
}
