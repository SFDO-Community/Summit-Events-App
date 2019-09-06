public static void initializeEventSampleData(){

    UST_Event__c testEvent = new UST_Event__c (
        Name = 'Test Event',
        Event_Name__c = 'Test Event',
        Event_Type__c = 'Admissions Event',
        Event_Status__c = 'Active',
        Start_Date__c = System.Today(),
        End_Date__c = System.Today().addDays(7)
    );
    insert testEvent;

    UST_Event_Instance__c testEventInstance = new UST_Event_Instance__c (
        Event__c = testEvent.Id,
        Active_Status__c = 'Active',
        Start_Date_Time__c = System.Today(),
        End_Date_Time__c = System.Today().addDays(7)
    );
    insert testEventInstance;

}