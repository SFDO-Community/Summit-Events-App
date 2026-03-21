List<Summit_Events_Instance__c> instances = [
    SELECT Id, Name, Event__r.Event_Name__c, Instance_Title__c, 
           Instance_Start_Date__c
    FROM Summit_Events_Instance__c 
    ORDER BY Instance_Start_Date__c
    LIMIT 20
];
for (Summit_Events_Instance__c i : instances) {
    System.debug('INST:' + i.Id + '|' + i.Event__r.Event_Name__c + '|' + i.Instance_Title__c + '|' + i.Instance_Start_Date__c);
}
