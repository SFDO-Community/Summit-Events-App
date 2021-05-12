@RestResource(urlMapping='/summiteventscalendar/*')

global with sharing class SummitEventsAdminCalendarController {

  private Class SummitEvent {
    public string ID { get; set; }
    public string title { get; set; }
    public Datetime start { get; set; }
    public Datetime end_date { get; set; }
  }

  public String Summit_Org_Domain { get; private set; }
  public String User_Time_Zone { get; private set; }

  public SummitEventsAdminCalendarController() {
    Summit_Org_Domain = URL.getOrgDomainUrl().getHost().toLowerCase().split('\\.')[0];
    User_Time_Zone = UserInfo.getTimeZone().getDisplayName().split('\\(')[2].split('\\)')[0];
  }

  @HttpGet
  global static void getEvents() {
    RestRequest req = RestContext.request;
    List<Summit_Events_Instance__c> events = getSummitEvents();
    List<SummitEvent> summit_events = new List<SummitEvent>();

    for (Summit_Events_Instance__c eventInstance : events) {
      SummitEvent s_event = new SummitEvent();
      s_event.ID = eventInstance.Id;

      if (eventInstance.Event__r.Event_Name__c != null) {
        s_event.title = eventInstance.Event__r.Event_Name__c;
      } else {
        s_event.title = eventInstance.Event__r.Name;
      }

      if (eventInstance.Instance_Title__c != null) {
        s_event.title += ' - ' + eventInstance.Instance_Title__c;
      }

      if (eventInstance.Instance_Start_Date__c != null) {
        s_event.start = combineDateAndTime(eventInstance.Instance_Start_Date__c, eventInstance.Instance_Start_Time__c);
      }

      if (eventInstance.Instance_End_Date__c != null) {
        s_event.end_date = combineDateAndTime(eventInstance.Instance_End_Date__c, eventInstance.Instance_End_Time__c);
      }

      summit_events.add(s_event);
  }

    String serialized_json = JSON.serialize(summit_events);
    serialized_json = serialized_json.replace('"end_date":', '"end":');
    RestResponse res = RestContext.response;
    res.addHeader('Content-Type', 'application/json');
    res.statusCode = 200;
    res.responseBody = Blob.valueOf(serialized_json);
  }

  @HttpPut
  global static void updateEvent(String instance_id, String start_date_time, String end_date_time) {
    Datetime start_date = Datetime.valueOf(start_date_time);
    Datetime end_date = Datetime.valueOf(end_date_time);
    Summit_Events_Instance__c my_summit = [SELECT id FROM Summit_Events_Instance__c WHERE id = :instance_id];
    my_summit.Instance_Start_Date__c = Date.newInstance(start_date.year(), start_date.month(), start_date.day());
    my_summit.Instance_Start_Time__c = Time.newInstance(start_date.hour(), start_date.minute(), start_date.second(), start_date.millisecond());
    my_summit.Instance_End_Date__c = Date.newInstance(end_date.year(), end_date.month(), end_date.day());
    my_summit.Instance_End_Time__c = Time.newInstance(end_date.hour(), end_date.minute(), end_date.second(), end_date.millisecond());
    update my_summit;
  }

  private static List<Summit_Events_Instance__c> getSummitEvents() {
    RestRequest req = RestContext.request;
    DateTime start = Date.valueOf(req.params.get('start_date'));
    DateTime end_date = Date.valueOf(req.params.get('end_date'));
    Boolean is_personal = Boolean.valueOf(req.params.get('my_events'));
    String user_id = UserInfo.getUserId();
    String serialized_json;

    String query_string = '';
    query_string += 'SELECT Id, Event__r.Name, Event__r.Event_Name__c, Event__r.Event_Status__c, Active_Status__c, Instance_Title__c, Instance_Short_Description__c, ';
    query_string += 'Instance_Start_Date__c, Instance_End_Date__c, Instance_Start_Time__c, Instance_End_Time__c, Instance_Time_Zone__c ';

    if(is_personal) {
      query_string += ', (SELECT Calendar_Subscriber__c FROM Summit_Events_Calendar_Subscriptions__r WHERE Calendar_Subscriber__c = :user_id) ';
    }

    query_string += 'FROM Summit_Events_Instance__c ';
    query_string += 'WHERE Instance_Start_Date__c >= ' + start.format('yyyy-MM-dd') + ' ';
    query_string += 'AND Instance_Start_Date__c <= ' + end_date.format('yyyy-MM-dd') + ' ';
    query_string += 'AND Event__R.Event_Status__c = \'Active\' ';
    query_string += 'AND Active_Status__c = \'Active\'';
    query_string += 'WITH SECURITY_ENFORCED';

    List<Summit_Events_Instance__c> event_instances = database.query(query_string);

    if(is_personal) {
      List<Summit_Events_Instance__c> my_instances = new List<Summit_Events_Instance__c>();
      for(Summit_Events_Instance__c instance : event_instances) {
        for(Summit_Events_Calendar_Subscription__c sub : instance.Summit_Events_Calendar_Subscriptions__r) {
          my_instances.add(instance);
        }
      }
      return my_instances;
    }

    return event_instances;
  }

  private static Datetime combineDateAndTime(Date date_in, Time time_in) {
    if (time_in == null) {
      time_in = Time.newInstance(1, 12, 3, 4);
    }

    Datetime converted = Datetime.newInstance(date_in.year(), date_in.month(), date_in.day(), time_in.hour(), time_in.minute(), time_in.second());
    
    return converted;    
  }
}