Date windowStart = Date.valueOf('2026-03-29');
Date windowEnd = Date.valueOf('2026-05-10');
String eventQuery = 'SELECT Id, Event__r.Name, Event__r.Event_Status__c, Active_Status__c, Instance_Start_Date__c, Event__r.Audience__c, Event__r.Private_Event__c, Private_Instance__c FROM Summit_Events_Instance__c';
eventQuery += ' WHERE Event__r.Event_Status__c = \'Active\'';
eventQuery += ' AND Active_Status__c = \'Active\'';
eventQuery += ' AND Event__r.Private_Event__c = false';
eventQuery += ' AND Private_Instance__c = false';
eventQuery += ' AND (Event__r.Audience__c = null OR Event__r.Audience__c EXCLUDES (\'No Audience\'))';
eventQuery += ' AND Instance_Start_Date__c >= :windowStart';
eventQuery += ' AND Instance_Start_Date__c <= :windowEnd';
eventQuery += ' WITH USER_MODE ORDER BY Instance_Start_Date__c';
List<Summit_Events_Instance__c> results = Database.query(eventQuery);
System.debug('COUNT:' + results.size());
for (Summit_Events_Instance__c r : results) {
    System.debug('INSTANCE:' + r.Event__r.Name + ' | ' + r.Instance_Start_Date__c + ' | audience=' + r.Event__r.Audience__c);
}

