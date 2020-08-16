@isTest
public class SummitEventsContactMatchingTest {
    @isTest
    static void SummitEventsContactMatching1(){
        Summit_Events__c event = new Summit_Events__c();
        event.Name = 'Test event';
        event.Contact_Matching_Rules__c = 'Matching rules 1';
        insert event;
        
        Summit_Events_Instance__c instance = new Summit_Events_Instance__c();
        instance.Event__c = event.Id;
        instance.Instance_Start_Date__c = System.today();
        instance.Instance_Start_Time__c = Time.newInstance(0,0,0,0);
        instance.Instance_End_Date__c = System.today();
        instance.Instance_End_Time__c = Time.newInstance(23,59,59,0);
        instance.Active_Status__c = 'Active';
        insert instance;
        
        Summit_Events_Registration__c registration = new Summit_Events_Registration__c();
        registration.Event__c = event.Id;
        registration.Event_Instance__c = instance.Id;
        registration.Status__c = 'Registered';
        registration.Registrant_First_Name__c = 'Test';
        registration.Registrant_Last_Name__c = 'Record';
        registration.Registrant_Email__c = 'test@example.com';
        registration.Registrant_Preferred_First_Name__c = 'Big T';
        insert registration;
        
        registration.Contact__c = null;
        registration.Registrant_Date_of_Birth__c = System.today();
        update registration;
        
        registration.Contact__c = null;
        registration.Registrant_First_Name__c = 'Tester';
        update registration;
        
        registration.Contact__c = null;
        registration.Registrant_Phone__c = '1234567890';
        update registration;
    }
    
    @isTest
    static void SummitEventsContactMatching2(){
        Summit_Events__c event = new Summit_Events__c();
        event.Name = 'Test event';
        event.Contact_Matching_Rules__c = 'Matching rules 2';
        insert event;
        
        Summit_Events_Instance__c instance = new Summit_Events_Instance__c();
        instance.Event__c = event.Id;
        instance.Instance_Start_Date__c = System.today();
        instance.Instance_Start_Time__c = Time.newInstance(0,0,0,0);
        instance.Instance_End_Date__c = System.today();
        instance.Instance_End_Time__c = Time.newInstance(23,59,59,0);
        instance.Active_Status__c = 'Active';
        insert instance;
        
        Summit_Events_Registration__c registration = new Summit_Events_Registration__c();
        registration.Event__c = event.Id;
        registration.Event_Instance__c = instance.Id;
        registration.Status__c = 'Registered';
        registration.Registrant_First_Name__c = 'Test';
        registration.Registrant_Last_Name__c = 'Record';
        registration.Registrant_Email__c = 'test@example.com';
        registration.Registrant_Preferred_First_Name__c = 'Big T';
        insert registration;
        
        registration.Contact__c = null;
        registration.Registrant_Date_of_Birth__c = null;
        update registration;
        
        registration.Contact__c = null;
        registration.Registrant_First_Name__c = 'Tester';
        update registration;
        
        registration.Contact__c = null;
        registration.Registrant_Phone__c = '1234567890';
        update registration;
    }
    
    @isTest
    static void SummitEventsContactMatching3(){
        Summit_Events__c event = new Summit_Events__c();
        event.Name = 'Test event';
        event.Contact_Matching_Rules__c = 'Use Salesforce Duplicate Rule';
        event.Contact_Creation_Duplicate_Rule__c = 'Summit Events Contact Creation';
        insert event;
        
        Summit_Events_Instance__c instance = new Summit_Events_Instance__c();
        instance.Event__c = event.Id;
        instance.Instance_Start_Date__c = System.today();
        instance.Instance_Start_Time__c = Time.newInstance(0,0,0,0);
        instance.Instance_End_Date__c = System.today();
        instance.Instance_End_Time__c = Time.newInstance(23,59,59,0);
        instance.Active_Status__c = 'Active';
        insert instance;
        
        Summit_Events_Registration__c registration = new Summit_Events_Registration__c();
        registration.Event__c = event.Id;
        registration.Event_Instance__c = instance.Id;
        registration.Status__c = 'Registered';
        registration.Registrant_First_Name__c = 'Test';
        registration.Registrant_Last_Name__c = 'Record';
        registration.Registrant_Email__c = 'test@example.com';
        registration.Registrant_Preferred_First_Name__c = 'Big T';
        insert registration;
        
        registration.Contact__c = null;
        update registration;
        
        registration.Contact__c = null;
        update registration;
    }
}