@IsTest
public class SummitEventsCalendarSubscription_TEST {
    @IsTest
    public static void testSubscriptionCreationForNewInstance() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Admin');
        System.runAs(testUser) {
            Test.startTest();
            Summit_Events_Settings__c custom_setting = Summit_Events_Settings__c.getInstance(testUser.Id);
            custom_setting.Automatically_Subscribe_Calendar__c = true;
            upsert custom_setting;

            List<Summit_Events_Instance__c> my_instances = SummitEventsTestSharedDataFactory.createTestEvent();
            Summit_Events_Instance__c first_instance = my_instances[0];
            Summit_Events_Calendar_Subscription__c my_subscription = [SELECT Id, Calendar_Subscriber__c FROM Summit_Events_Calendar_Subscription__c WHERE Summit_Events_Instance__c = :first_instance.Id LIMIT 1];
            System.assertNotEquals(null, my_subscription.Id);
            System.assertEquals(my_subscription.Calendar_Subscriber__c, testUser.Id);            
            Test.stopTest();
        }
    }

    @IsTest
    public static void testPreventSubscriptionForNewInstance() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Admin');

        System.runAs(testUser) {
            Test.startTest();
            Summit_Events_Settings__c custom_setting = Summit_Events_Settings__c.getInstance(testUser.Id);
            custom_setting.Automatically_Subscribe_Calendar__c = false;
            upsert custom_setting;

            List<Summit_Events_Instance__c> my_instances = SummitEventsTestSharedDataFactory.createTestEvent();
            Summit_Events_Instance__c first_instance = my_instances[0];
            Summit_Events_Calendar_Subscription__c[] my_subscription = [SELECT Id, Calendar_Subscriber__c FROM Summit_Events_Calendar_Subscription__c WHERE Summit_Events_Instance__c = :first_instance.Id LIMIT 1];
            System.assert(my_subscription.size() == 0);
            Test.stopTest();
        }
    }

    @IsTest
    public static void testSingleAndDuplicateSubscription() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Admin');
        System.runAs(testUser) {
            Test.startTest();
            List<Summit_Events_Instance__c> my_instances = SummitEventsTestSharedDataFactory.createTestEvent();
            System.assertNotEquals(null, my_instances[0].Id);
            
            Summit_Events_Calendar_Subscription__c new_subscription = [SELECT Id FROM Summit_Events_Calendar_Subscription__c WHERE Summit_Events_Instance__c = :my_instances[0].Id];

            Summit_Events_Calendar_Subscription__c duplicate_subscription = new Summit_Events_Calendar_Subscription__c(Summit_Events_Instance__c = my_instances[0].Id, Calendar_Subscriber__c = testUser.Id);
            
            try{
                Insert duplicate_subscription;
            } catch(Exception e) {
            }

            System.assert(new_subscription.Id != null);
            System.assert(duplicate_subscription.Id == null);
            Test.stopTest();
        }
    }

    @IsTest
    public static void testGetAllSummitEvents() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Admin');
        System.runAs(testUser) {
            Test.startTest();
            SummitEventsTestSharedDataFactory.createTestEvent();
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            Datetime today = Datetime.now();
            Datetime ten_days = today.addDays(10);
            Integer response_ok = 200;
            String empty_array = '[]';

            req.httpMethod = 'GET';
            req.requestURI = '/services/apexrest/summiteventscalendar/getevents';
            req.addHeader('Content-Type', 'application/json; charset=UTF-8');
            req.addParameter('start_date', today.format('yyyy-MM-dd'));
            req.addParameter('end_date', ten_days.format('yyyy-MM-dd'));
            req.addParameter('my_events', 'false');
            RestContext.request = req;
            RestContext.response = res;
            
            SummitEventsAdminCalendarController cont = new SummitEventsAdminCalendarController();
            System.assert(cont.Summit_Org_Domain.length() != 0);
            System.assert(cont.User_Time_Zone.length() != 0);

            SummitEventsAdminCalendarController.getEvents();
            System.assertEquals(response_ok, res.statusCode);
            System.assertNotEquals(empty_array, res.responseBody.toString());
            Test.stopTest();
        }
    }

    @IsTest
    public static void testGetMySummitEvents() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Admin');
        System.runAs(testUser) {
            Test.startTest();
            List<Summit_Events_Instance__c> my_instances = SummitEventsTestSharedDataFactory.createTestEvent();
            Summit_Events_Instance__c first_instance = my_instances[0];
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            Datetime today = Datetime.now();
            Datetime ten_days = today.addDays(10);
            Integer response_ok = 200;
            String empty_array = '[]';

            req.httpMethod = 'GET';
            req.requestURI = '/services/apexrest/summiteventscalendar/getevents';
            req.addHeader('Content-Type', 'application/json; charset=UTF-8');
            req.addParameter('start_date', today.format('yyyy-MM-dd'));
            req.addParameter('end_date', ten_days.format('yyyy-MM-dd'));
            req.addParameter('my_events', 'true');
            RestContext.request = req;
            RestContext.response = res;
            
            SummitEventsAdminCalendarController cont = new SummitEventsAdminCalendarController();
            System.assert(cont.Summit_Org_Domain.length() != 0);
            System.assert(cont.User_Time_Zone.length() != 0);

            SummitEventsAdminCalendarController.getEvents();
            System.assertEquals(response_ok, res.statusCode);
            System.assertNotEquals(empty_array, res.responseBody.toString());
            Test.stopTest();
        }
    }

    @IsTest
    public static void testUpdateEvent() {
        User testUser = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', 'Summit_Events_Admin');
        System.runAs(testUser) {
            Test.startTest();
            List<Summit_Events_Instance__c> my_instances = SummitEventsTestSharedDataFactory.createTestEvent();
            Summit_Events_Instance__c first_instance = my_instances[0];
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            String new_start_time = '2021-03-15 12:00:00';
            String new_end_time = '2021-03-15 13:30:00';

            req.httpMethod = 'PUT';
            req.requestURI = '/services/apexrest/summiteventscalendar/updateevent';
            RestContext.request = req;
            RestContext.response = res;

            SummitEventsAdminCalendarController.updateEvent(first_instance.Id, new_start_time, new_end_time);

            Summit_Events_Instance__c updated_instance = [SELECT Id, Instance_Start_Date__c, Instance_End_Date__c, Instance_Start_Time__c, Instance_End_Time__c FROM Summit_Events_Instance__c WHERE Id = :first_instance.Id];
            System.assertEquals(updated_instance.Instance_Start_Date__c.year(), 2021);
            System.assertEquals(updated_instance.Instance_End_Date__c.year(), 2021);
            System.assertEquals(updated_instance.Instance_Start_Date__c.month(), 3);
            System.assertEquals(updated_instance.Instance_End_Date__c.month(), 3);
            System.assertEquals(updated_instance.Instance_Start_Date__c.day(), 15);
            System.assertEquals(updated_instance.Instance_End_Date__c.day(), 15);
            System.assertEquals(updated_instance.Instance_Start_Time__c.hour(), 12);
            System.assertEquals(updated_instance.Instance_End_Time__c.hour(), 13);
            System.assertEquals(updated_instance.Instance_Start_Time__c.minute(), 0);
            System.assertEquals(updated_instance.Instance_End_Time__c.minute(), 30);
            System.assertEquals(updated_instance.Instance_Start_Time__c.second(), 0);
            System.assertEquals(updated_instance.Instance_End_Time__c.second(), 0);
            Test.stopTest();
        }
    }
}