@IsTest
public with sharing class SummitEventsRtfLinkPipeline_TEST {

    private static final String SOURCE_FIELD = 'Event_Full_Text__c';

    @TestSetup
    static void makeData() {
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test.jpg'),
            IsMajorVersion = true
        );
        insert cv;
    }

    // ---------------------------------------------------------------------------------------
    // ContentVersion links (synchronous)
    // ---------------------------------------------------------------------------------------

    @IsTest
    static void testLinkReplacement() {

        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];

        String rtfUrl = '<p><img src="https://example.force.com/sfc/servlet.shepherd/version/download/'
            + cv.Id + '?versionId=' + cv.Id + '" alt="test"></img></p>';

        Summit_Events__c se = insertEvent('Test Event', rtfUrl);
        Map<Id, Summit_Events__c> newMap = new Map<Id, Summit_Events__c>{ se.Id => se };

        Test.startTest();
        SummitEventsRtfLinkPipeline rtfp = new SummitEventsRtfLinkPipeline(newMap);
        rtfp.run();
        Test.stopTest();

        Summit_Events__c updated = getEvent(se.Id);
        ContentDistribution cd = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId = :cv.Id LIMIT 1];
        Assert.isFalse(updated.Event_Full_Text__c.contains('versionId=068'), 'The ContentVersion URL should have been replaced');
        Assert.isTrue(updated.Event_Full_Text__c.contains('https://'), 'The replacement should be an absolute URL');
        Assert.isTrue(containsUrl(updated.Event_Full_Text__c, cd.ContentDownloadUrl),
            'RTF should contain the ContentDownloadUrl but was: ' + updated.Event_Full_Text__c);
    }

    @IsTest
    static void shouldQueueNothing_WhenEventsHaveNoImages() {

        List<Summit_Events__c> events = new List<Summit_Events__c>();
        for(Integer i = 0; i < 251; i++) {
            events.add(buildEvent('Plain ' + i, '<p>No images here</p>'));
        }
        insert events;

        Test.startTest();
        new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>(events)).run();
        Integer queued = Limits.getQueueableJobs();
        Test.stopTest();

        Assert.areEqual(0, queued, 'No Queueable should be enqueued when there are no rich text editor images');
        Assert.areEqual(0, [SELECT COUNT() FROM ContentDistribution], 'No distributions should be created');
    }

    // ---------------------------------------------------------------------------------------
    // Rich text editor images (rtaImage, via Queueable + REST callout)
    //
    // The platform strips rtaImage tags it cannot tie to a real upload, so these tests stage the
    // field contents through SummitEventsRtfLinkPipeline.eventOverrides instead of saving them.
    // ---------------------------------------------------------------------------------------

    @IsTest
    static void shouldPublishImage_WhenRtaImageFetchSucceeds() {

        Summit_Events__c se = stageRtaEvent('RTA Event', rtaTag(1));
        ImageMock mock = new ImageMock(200, 'image/jpeg');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        Test.stopTest();

        Summit_Events__c updated = getEvent(se.Id);
        ContentDistribution cd = [SELECT Id, ContentDownloadUrl, ContentVersionId FROM ContentDistribution];
        Assert.isFalse(updated.Event_Full_Text__c.contains('rtaImage'), 'The rtaImage URL should have been replaced');
        Assert.isTrue(containsUrl(updated.Event_Full_Text__c, cd.ContentDownloadUrl),
            'RTF should contain the ContentDownloadUrl but was: ' + updated.Event_Full_Text__c);
        Assert.areEqual(1, mock.callCount, 'The image should be fetched exactly once');
        Assert.isTrue(mock.lastEndpoint.contains('/sobjects/Summit_Events__c/' + se.Id + '/richTextImageFields/' + SOURCE_FIELD + '/' + refId(1)),
            'The REST request should target the event, field and image reference: ' + mock.lastEndpoint);
        Assert.areEqual(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :se.Id],
            'The new file should be linked to the event so it appears in its Files related list');
        ContentVersion created = [SELECT PathOnClient, VersionData FROM ContentVersion WHERE Id = :cd.ContentVersionId];
        Assert.areEqual(refId(1) + '.jpg', created.PathOnClient, 'File extension should come from the response content type');
        Assert.areEqual(mock.body.size(), created.VersionData.size(), 'The fetched bytes should be stored');
    }

    @IsTest
    static void shouldFetchOnce_WhenSameImageAppearsTwice() {

        Summit_Events__c se = stageRtaEvent('Duplicate Event', rtaTag(1) + '<p>again</p>' + rtaTag(1));
        ImageMock mock = new ImageMock(200, 'image/png');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        Test.stopTest();

        Assert.areEqual(1, mock.callCount, 'A repeated image should only be fetched once');
        Assert.areEqual(1, [SELECT COUNT() FROM ContentDistribution], 'A repeated image should only get one distribution');
        String updated = getEvent(se.Id).Event_Full_Text__c;
        Assert.isFalse(updated.contains('rtaImage'), 'Both occurrences should be replaced');
        Assert.areEqual(2, updated.split('<img').size() - 1, 'Both images should still be present');
    }

    @IsTest
    static void shouldLeaveFieldUnchanged_WhenContentTypeIsNotAnImage() {

        Summit_Events__c se = stageRtaEvent('HTML Event', rtaTag(1));
        ImageMock mock = new ImageMock(200, 'text/html');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        Test.stopTest();

        Assert.areEqual(1, mock.callCount, 'The fetch should have been attempted');
        Assert.areEqual(se.Event_Full_Text__c, getEvent(se.Id).Event_Full_Text__c, 'Non-image responses must never be made public');
        Assert.areEqual(0, [SELECT COUNT() FROM ContentDistribution], 'No distribution should be created');
        Assert.areEqual(1, [SELECT COUNT() FROM ContentVersion], 'No file should be created beyond the test setup file');
    }

    @IsTest
    static void shouldLeaveFieldUnchanged_WhenFetchReturnsNotFound() {

        Summit_Events__c se = stageRtaEvent('Missing Event', rtaTag(1));
        ImageMock mock = new ImageMock(404, 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        Test.stopTest();

        Assert.areEqual(1, mock.callCount, 'The fetch should have been attempted');
        Assert.areEqual(se.Event_Full_Text__c, getEvent(se.Id).Event_Full_Text__c, 'A failed fetch must not alter the field');
        Assert.areEqual(0, [SELECT COUNT() FROM ContentDistribution], 'No distribution should be created');
    }

    @IsTest
    static void shouldConvertUpToJobCap_WhenManyImagesAreQueued() {

        Map<Id, Summit_Events__c> eventsById = new Map<Id, Summit_Events__c>();
        for(Integer i = 1; i <= 25; i++) {
            Summit_Events__c se = stageRtaEvent('Bulk ' + i, rtaTag(i));
            eventsById.put(se.Id, se);
        }
        ImageMock mock = new ImageMock(200, 'image/jpeg');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        new SummitEventsRtfLinkPipeline(eventsById).run();
        Test.stopTest();

        // Chained jobs do not run in tests, so we see exactly one job's worth of work
        Assert.areEqual(20, mock.callCount, 'One job should fetch at most 20 images');
        Assert.areEqual(20, [SELECT COUNT() FROM ContentDistribution], 'One distribution per converted image');
    }

    @IsTest
    static void shouldConvertImageEndToEnd_WhenTriggerAutomationIsEnabled() {

        insert new Summit_Events_Settings__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Opt_Into_Link_Automation__c = true
        );
        Summit_Events__c se = stageRtaEvent('Trigger Event', rtaTag(1));
        ImageMock mock = new ImageMock(200, 'image/jpeg');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        update new Summit_Events__c(Id = se.Id, Event_Name__c = 'Trigger Event Renamed');
        Test.stopTest();

        ContentDistribution cd = [SELECT Id, ContentDownloadUrl FROM ContentDistribution];
        Summit_Events__c updated = getEvent(se.Id);
        Assert.isTrue(containsUrl(updated.Event_Full_Text__c, cd.ContentDownloadUrl), 'The field should hold the public URL');
        Assert.areEqual(1, mock.callCount, 'The job\'s own update must not trigger another fetch');
    }

    @IsTest
    static void shouldConvertVersionLinkEndToEnd_WhenTriggerAutomationIsEnabled() {

        insert new Summit_Events_Settings__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Opt_Into_Link_Automation__c = true
        );
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        String html = '<p><img src="https://example.force.com/sfc/servlet.shepherd/version/download/'
            + cv.Id + '?versionId=' + cv.Id + '" alt="test"></img></p>';

        Test.startTest();
        Summit_Events__c se = insertEvent('Trigger Link Event', html);
        Test.stopTest();

        ContentDistribution cd = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId = :cv.Id];
        Assert.isTrue(containsUrl(getEvent(se.Id).Event_Full_Text__c, cd.ContentDownloadUrl),
            'Saving an event should convert its ContentVersion link when automation is enabled');
    }

    @IsTest
    static void shouldDoNothing_WhenTriggerAutomationIsOff() {

        Summit_Events__c se = stageRtaEvent('Off Event', rtaTag(1));
        ImageMock mock = new ImageMock(200, 'image/jpeg');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        update new Summit_Events__c(Id = se.Id, Event_Name__c = 'Off Event Renamed');
        Test.stopTest();

        Assert.areEqual(0, mock.callCount, 'Nothing should be fetched unless the org opted in');
        Assert.areEqual(0, [SELECT COUNT() FROM ContentDistribution], 'No distribution should be created');
    }

    @IsTest
    static void shouldDoNothing_WhenUserCannotUpdateRichTextFields() {

        Summit_Events__c se = stageRtaEvent('No Access Event', rtaTag(1));
        ImageMock mock = new ImageMock(200, 'image/jpeg');
        Test.setMock(HttpCalloutMock.class, mock);
        User restricted = SummitEventsTestSharedDataFactory.userToRunWith('Standard User', null);

        Test.startTest();
        System.runAs(restricted) {
            new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        }
        Test.stopTest();

        Assert.areEqual(0, mock.callCount, 'Nothing should be fetched for a user who cannot edit the fields');
        Assert.areEqual(0, [SELECT COUNT() FROM ContentDistribution], 'No distribution should be created');
        Assert.areEqual(se.Event_Full_Text__c, getEvent(se.Id).Event_Full_Text__c, 'The field should be untouched');
    }

    // ---------------------------------------------------------------------------------------
    // Running as a real editor (standard profile + Summit_Events_Admin), in user mode
    // ---------------------------------------------------------------------------------------

    @IsTest
    static void shouldPublishRtaImage_WhenEditorOnlyHasAdminPermissionSet() {

        Summit_Events__c se = stageRtaEvent('Editor RTA Event', rtaTag(1));
        ImageMock mock = new ImageMock(200, 'image/jpeg');
        Test.setMock(HttpCalloutMock.class, mock);
        User editor = SummitEventsTestSharedDataFactory.userToRunWith('Minimum Access - Salesforce', 'Summit_Events_Admin');

        Test.startTest();
        System.runAs(editor) {
            new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        }
        Test.stopTest();

        Assert.areEqual(1, mock.callCount, 'The editor should be able to fetch the image');
        ContentDistribution cd = [SELECT Id, ContentDownloadUrl FROM ContentDistribution];
        Assert.isTrue(containsUrl(getEvent(se.Id).Event_Full_Text__c, cd.ContentDownloadUrl),
            'An editor with only the admin permission set should be able to publish the image');
    }

    @IsTest
    static void shouldPublishVersionLink_WhenEditorOwnsTheImageFile() {

        User editor = SummitEventsTestSharedDataFactory.userToRunWith('Minimum Access - Salesforce', 'Summit_Events_Admin');
        ContentVersion cv;
        System.runAs(editor) {
            cv = new ContentVersion(Title = 'Editor image', PathOnClient = 'editor.png', VersionData = Blob.valueOf('png'), IsMajorVersion = true);
            insert cv;
        }
        Summit_Events__c se = insertEvent('Editor Link Event', versionLinkTag(cv.Id));

        Test.startTest();
        System.runAs(editor) {
            new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        }
        Test.stopTest();

        ContentDistribution cd = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId = :cv.Id];
        Assert.isTrue(containsUrl(getEvent(se.Id).Event_Full_Text__c, cd.ContentDownloadUrl),
            'An editor should be able to publish an image file they own');
    }

    @IsTest
    static void shouldNotPublish_WhenEditorCannotReadTheLinkedFile() {

        // Owned by the test running user and private, so the editor cannot see it
        ContentVersion privateFile = new ContentVersion(
            Title = 'Private', PathOnClient = 'private.png', VersionData = Blob.valueOf('png'), IsMajorVersion = true
        );
        insert privateFile;
        Summit_Events__c se = insertEvent('Private Link Event', versionLinkTag(privateFile.Id));
        User editor = SummitEventsTestSharedDataFactory.userToRunWith('Minimum Access - Salesforce', 'Summit_Events_Admin');

        Test.startTest();
        System.runAs(editor) {
            new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        }
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM ContentDistribution], 'A file the editor cannot read must never be published');
        Assert.areEqual(se.Event_Full_Text__c, getEvent(se.Id).Event_Full_Text__c, 'The field should be untouched');
    }

    @IsTest
    static void shouldNotPublish_WhenLinkedFileIsNotAnImage() {

        ContentVersion document = new ContentVersion(
            Title = 'Secret plan', PathOnClient = 'plan.pdf', VersionData = Blob.valueOf('pdf'), IsMajorVersion = true
        );
        insert document;
        Summit_Events__c se = insertEvent('Document Link Event', versionLinkTag(document.Id));

        Test.startTest();
        new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM ContentDistribution], 'Only images may be published');
        Assert.areEqual(se.Event_Full_Text__c, getEvent(se.Id).Event_Full_Text__c, 'The field should be untouched');
    }

    @IsTest
    static void shouldFindNotificationType_WhenRunAsMinimumAccessEditor() {

        User editor = SummitEventsTestSharedDataFactory.userToRunWith('Minimum Access - Salesforce', 'Summit_Events_Admin');
        Id typeId;

        Test.startTest();
        System.runAs(editor) {
            typeId = SummitEventsRtfLinkPipeline.notificationTypeId();
        }
        Test.stopTest();

        Assert.isNotNull(typeId, 'The editor must be able to see the notification type, or failures would never be reported');
    }

    @IsTest
    static void shouldNeverThrow_WhenSendingNotifications() {

        Summit_Events__c se = insertEvent('Notify Event', '<p>x</p>');

        Test.startTest();
        SummitEventsRtfLinkPipeline.notifyUser(se.Id, new Set<String>{ 'Something needs attention' });
        SummitEventsRtfLinkPipeline.notifyUser(se.Id, new Set<String>());
        SummitEventsRtfLinkPipeline.notifyUser(null, null);
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM ContentDistribution], 'Notifying must not have side effects');
    }

    @IsTest
    static void shouldReturnWithoutError_WhenQueueableHasNoEvents() {
        Test.startTest();
        new SummitEventsRtaImageQueueable(new List<Id>()).execute(null);
        Test.stopTest();
        Assert.areEqual(0, [SELECT COUNT() FROM ContentDistribution], 'Nothing should be created');
    }

    // ---------------------------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------------------------

    private static Summit_Events__c buildEvent(String name, String fullText) {
        return new Summit_Events__c(
            Name = name,
            Event_Name__c = name,
            Event_Status__c = 'Active',
            Event_Full_Text__c = fullText
        );
    }

    private static Summit_Events__c insertEvent(String name, String fullText) {
        Summit_Events__c se = buildEvent(name, fullText);
        insert se;
        return getEvent(se.Id);
    }

    // Saves a placeholder event, and stages the real rich text for the pipeline to read
    private static Summit_Events__c stageRtaEvent(String name, String html) {
        Summit_Events__c saved = insertEvent(name, '<p>placeholder</p>');
        if(SummitEventsRtfLinkPipeline.eventOverrides == null) {
            SummitEventsRtfLinkPipeline.eventOverrides = new List<Summit_Events__c>();
        }
        SummitEventsRtfLinkPipeline.eventOverrides.add(
            new Summit_Events__c(Id = saved.Id, Name = name, Event_Full_Text__c = html)
        );
        return saved;
    }

    private static Summit_Events__c getEvent(Id eventId) {
        return [SELECT Id, Name, Event_Full_Text__c FROM Summit_Events__c WHERE Id = :eventId];
    }

    // Rich text fields store '&' as '&amp;', so accept either form of a URL
    private static Boolean containsUrl(String html, String url) {
        return html.contains(url) || html.contains(url.replace('&', '&amp;'));
    }

    private static String refId(Integer n) {
        return '0EM' + ('000000000000' + n).right(12);
    }

    private static String versionLinkTag(Id versionId) {
        return '<p><img src="https://example.force.com/sfc/servlet.shepherd/version/download/'
            + versionId + '?versionId=' + versionId + '" alt="test"></img></p>';
    }

    private static String rtaTag(Integer n) {
        return '<p><img src="https://example.file.force.com/servlet/rtaImage?eid=a00000000000001'
            + '&amp;feoid=00N000000000001&amp;refid=' + refId(n) + '" alt="test"></img></p>';
    }

    private class ImageMock implements HttpCalloutMock {
        private final Integer status;
        private final String contentType;
        public Integer callCount = 0;
        public String lastEndpoint;
        public Blob body = Blob.valueOf('fake-image-bytes');

        public ImageMock(Integer status, String contentType) {
            this.status = status;
            this.contentType = contentType;
        }

        public HttpResponse respond(HttpRequest request) {
            callCount++;
            lastEndpoint = request.getEndpoint();
            HttpResponse response = new HttpResponse();
            response.setStatusCode(status);
            response.setHeader('Content-Type', contentType);
            response.setBodyAsBlob(body);
            return response;
        }
    }
}
