@IsTest
public with sharing class SummitEventsRtfLinkPipeline_TEST {

    @TestSetup
    static void makeData() {
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'test.txt',
            VersionData = Blob.valueOf('Test.jpg'),
            IsMajorVersion = true
        );
        insert cv;
    }

    @IsTest
    static void testLinkReplacement() {

        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        String namespace = SummitEventsNamespace.getNamespace();

        String rtfUrl = '<p><img src="https://example.force.com/sfc/servlet.shepherd/version/download/'
            + cv.Id + '?versionId=' + cv.Id + '" alt="test"></img></p>';

        Summit_Events__c se = new Summit_Events__c();
        se.put(namespace + 'Event_Full_Text__c', rtfUrl);
        se.put(namespace + 'Event_Name__c', 'Test Event');
        se.put(namespace + 'Event_Status__c', 'Active');
        se.put(namespace + 'Name', 'Test Event');
        insert se;
        se = [SELECT Event_Full_Text__c,Event_Name__c,Event_Status__c,Name FROM Summit_Events__c WHERE Id = :se.Id];


        Map<Id, Summit_Events__c> newMap = new Map<Id, Summit_Events__c>{ se.Id => se };

        Test.startTest();
        SummitEventsRtfLinkPipeline rtfp = new SummitEventsRtfLinkPipeline(newMap);
        rtfp.run();
        Test.stopTest();

        Summit_Events__c updated = [
            SELECT Event_Full_Text__c,Event_Name__c,Event_Status__c,Name FROM Summit_Events__c WHERE Id = :se.Id
        ];
        ContentDistribution cd = [SELECT Id, DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId = :cv.Id LIMIT 1];
        System.assert(!updated.Event_Full_Text__c.contains('versionId=068'));
        System.assert(updated.Event_Full_Text__c.contains('https://'));
        System.assert(updated.Event_Full_Text__c.contains(cd.DistributionPublicUrl));
    }
}
