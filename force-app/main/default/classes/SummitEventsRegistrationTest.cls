@isTest
public class SummitEventsRegistrationTest {
    @isTest
    public static void TestSummitEventsRegistration(){
        Summit_Events__c event = new Summit_Events__c();
        event.Name = 'Test event';
        insert event;

        Summit_Events_Instance__c instance = new Summit_Events_Instance__c();
        instance.Event__c = event.Id;
        instance.Instance_Start_Date__c = System.today();
        instance.Instance_Start_Time__c = Time.newInstance(0,0,0,0);
        instance.Instance_End_Date__c = System.today();
        instance.Instance_End_Time__c = Time.newInstance(23,59,59,0);
        instance.Active_Status__c = 'Active';
        insert instance;

        Summit_Events_Email__c email1 = new Summit_Events_Email__c();
        email1.Event__c = event.Id;
        email1.Action_Status__c = 'Registered';
        email1.Email_Content__c = 'Sample text here';
        email1.Letterhead_HTML__c = 'Letterhead goes here<br/>[[DONT_DELETE_CONTENT_HERE]]';
        email1.BCC_Email__c = 'bcc@example.com';
        insert email1;

        Summit_Events_Email__c email2 = new Summit_Events_Email__c();
        email2.Event__c = event.Id;
        email2.Action_Status__c = 'Registered';
        email2.Action_Sub_status__c = 'In Progress';
        email2.Email_Content__c = 'Sample text here';
        email2.Letterhead_HTML__c = 'Letterhead goes here<br/>[[DONT_DELETE_CONTENT_HERE]]';
        email2.BCC_Email__c = 'bcc@example.com';
        insert email2;

        Summit_Events_Registration__c registration = new Summit_Events_Registration__c();
        registration.Event__c = event.Id;
        registration.Event_Instance__c = instance.Id;
        registration.Status__c = 'Registered';
        registration.Registrant_First_Name__c = 'Test';
        registration.Registrant_Last_Name__c = 'Record';
        registration.Registrant_Email__c = 'test@example.com';
        insert registration;

        registration.Substatus__c = 'In Progress';
        update registration;
    }
}