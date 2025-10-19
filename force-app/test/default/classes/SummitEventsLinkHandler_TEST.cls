@IsTest(SeeAllData=true) 
private class SummitEventsLinkHandler_TEST {

    @IsTest(SeeAllData=true) 
    static void basicRun() {

        String namespace = SummitEventsNamespace.StrTokenNSPrefix('');

        ContentDistribution realCD = [SELECT Id,ContentVersionId FROM ContentDistribution LIMIT 1];
        Id realCVId = realCD.ContentVersionId;
        ContentVersion realCV = [SELECT Id,Title,PathOnClient,VersionData,IsMajorVersion,ContentUrl FROM ContentVersion WHERE Id = :realCVId];
        delete realCD; // god help us


        // Build a fake Summit Event record with an <img src=""> tag in an RTF field
        Summit_Events__c se = new Summit_Events__c(Name = 'Test Summit Event');
        se.put(namespace + 'Event_Full_Text__c', '<img src="' + realCV.ContentUrl + '">');
        system.debug(realCV.ContentUrl);
        insert se;

        // Minimal trigger-style map to simulate trigger.newMap
        Map<Id, SObject> newMap = new Map<Id, SObject>{ se.Id => se };

        // Call the handler
        Test.startTest();
        SummitEventsLinkHandler.run(newMap);
        Test.stopTest();

        // Basic sanity query to ensure record update didn’t throw
        Summit_Events__c updated = [SELECT Id, Event_Full_Text__c FROM Summit_Events__c WHERE Id = :se.Id];
        System.assertNotEquals(null, updated);
    }
}
