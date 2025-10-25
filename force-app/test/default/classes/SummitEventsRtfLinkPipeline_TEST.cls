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
            + cv.Id + '?versionId=' + cv.Id + '" alt="test"></p>';

        Summit_Events__c se = new Summit_Events__c();
        se.put(namespace + 'Event_Full_Text__c', rtfUrl);
        insert se;

        Map<Id, SObject> newMap = new Map<Id, SObject>{ se.Id => se };

        Test.startTest();
        SummitEventsRtfLinkPipeline rtfp = new SummitEventsRtfLinkPipeline(newMap);
        rtfp.run();
        Test.stopTest();

        Summit_Events__c updated = [
            SELECT Event_Full_Text__c FROM Summit_Events__c WHERE Id = :se.Id
        ];
        System.assert(!updated.Event_Full_Text__c.contains('versionId=068'));
        System.assert(updated.Event_Full_Text__c.contains('https://'));
    }
}
