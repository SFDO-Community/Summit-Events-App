public static void initializeEventSampleData() {

    UST_Event__c demoEvent = new UST_Event__c (
            Name = 'Test Event',
            Event_Name__c = 'Test Event',
            Event_Type__c = 'Admissions Event',
            Event_Status__c = 'Active',
            Audience__c = 'High School Senior',
            Template__c = 'CastorTemplate2017',
            Event_description__c = '<p><strong>Rich Text</strong> description of the event that appears on the first registration page.</p>',
            Event_Short_Listing_Description__c = 'This description appears in feed and should be concise',
            Event_Footer__c = 'This footer appears on every event registration page in the footer.',
            Event_Full_Text__c = 'Explain here that the event has reached capacity and is closed.',
            Event_Appointment_Title__c = 'This is the header of the appointment/options page.',
            Event_Appointment_Description__c = 'Body text for the appointment/options page explains what these appointments are about.',
            Event_Submit_Title__c = 'Heading for the Submit Page',
            Event_Submit_Description__c = 'Description of submission being the final act in the registration play.',
            Event_Confirmation_Title__c = 'Registration has been received title.',
            Event_Confirmation_Description__c = 'Explain the registration has been received from the client at this point and is complete',
            Event_Cancel_Review_Title__c = 'Online Cancel of Registration Heading',
            Event_Cancel_Review_Description__c = 'What does it mean to cancel a event.',
            Event_Cancelled_Notification_Text__c = 'The event has been cancelled.',
            Add_Info_Question_Type_1__c = 'Pick-list',
            Add_Info_Question_Text_1__c = 'What is your favorite color?',
            Add_Info_Question_Pick_List_1__c = 'Red\nYellow\nGreen\nBlue',
            Start_Date__c = System.Today().addDays(-1),
            End_Date__c = System.Today().addDays(30)
    );
    insert demoEvent;

    UST_Event_Instance__c demoEventInstance = new UST_Event_Instance__c (
            Event__c = demoEvent.Id,
            Active_Status__c = 'Active',
            Start_Date_Time__c = System.Today().addDays(4),
            End_Date_Time__c = System.Today().addDays(4),
            Capacity__c = 100
    );
    insert demoEventInstance;

    List<UST_Event_Appointment_Type__c> demoAppointmentTypes = new List<UST_Event_Appointment_Type__c>();
    demoAppointmentTypes.add(new UST_Event_Appointment_Type__c(
            Appointment_Type_Status__c = 'Active',
            UST_Event__c = demoEvent.Id,
            Title__c = 'Demo Appointment 1 - Ice Cream with Counselor',
            Description__c = 'Choose the ice cream you could prefer to consume during your visit',
            Appointment_Limits__c = '1',
            Chosen_State__c = '',
            Sort_Order__c = 10,
            Registrant_Input__c = 'Custom pick list',
            Custom_Picklist__c = 'Chocolate\nVanilla\nStrawberry\nLactose Free'
    ));
    demoAppointmentTypes.add(new UST_Event_Appointment_Type__c(
            Appointment_Type_Status__c = 'Active',
            UST_Event__c = demoEvent.Id,
            Title__c = 'Demo Appointment 2 - Meaning of life',
            Description__c = 'What is your definition of the meaning of life?',
            Appointment_Limits__c = '2',
            Chosen_State__c = '',
            Sort_Order__c = 20,
            Registrant_Input__c = 'Required text box'
    ));
    demoAppointmentTypes.add(new UST_Event_Appointment_Type__c(
            Appointment_Type_Status__c = 'Active',
            UST_Event__c = demoEvent.Id,
            Title__c = 'Demo Appointment 0 - Quite time',
            Description__c = 'Get yourself some quite time in our library.',
            Appointment_Limits__c = '1',
            Chosen_State__c = '',
            Sort_Order__c = 1,
            Registrant_Input__c = ''
    ));
    demoAppointmentTypes.add(new UST_Event_Appointment_Type__c(
            Appointment_Type_Status__c = 'Active',
            UST_Event__c = demoEvent.Id,
            Title__c = 'Demo Appointment 3 - Free Lunch',
            Description__c = 'There is such a thing!',
            Appointment_Limits__c = '1',
            Chosen_State__c = '',
            Sort_Order__c = 30,
            Registrant_Input__c = '',
            Auto_Confirm_Appointment__c = true
    ));

    insert demoAppointmentTypes;
}

public static void addingAdminPermissionSet() {
    //Add Permission set to all Admins
    List<PermissionSet> eventPermissionSets = [SELECT Name, Id FROM PermissionSet WHERE Name = 'UST_Event_Admin'];

    List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
    if (!eventPermissionSets.isEmpty()) {
        for (User u : [SELECT ID FROM User WHERE Profile.Name = 'System Administrator']) {
            permissionSetList.add(new PermissionSetAssignment(PermissionSetId = eventPermissionSets[0].Id, AssigneeId = u.Id));
        }
    }
    if (!permissionSetList.isEmpty()) {
        upsert permissionSetList;
    }
}

public static void setSiteURL() {

    String siteName = 'UST_Events';

    Site site = [
            SELECT GuestUserId
            FROM Site
            WHERE Name = :siteName
    ];

    String path = '/sites/servlet.SiteDebugMode';
    PageReference pr = new PageReference(path);
    pr.getParameters().put('guid', site.GuestUserId);
    pr.getParameters().put('sitedebugmode', 'x');
    String url = pr.getContent().toString().substringAfter('URL=').substringBefore(path);

    UST_Event_Settings__c eventSettings = UST_Event_Settings__c.getOrgDefaults();
    eventSettings.Community_Base_URL__c = url;
    upsert eventSettings;

}