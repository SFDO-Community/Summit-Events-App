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
    static void shouldConvertDownloadUrl_WhenThereIsNoVersionIdParameter() {

        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        String html = '<p><img src="https://example.force.com/sfc/servlet.shepherd/version/download/' + cv.Id + '" alt="test"></img></p>';
        Summit_Events__c se = insertEvent('Download Path Event', html);

        Test.startTest();
        new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        Test.stopTest();

        ContentDistribution cd = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId = :cv.Id];
        String updated = getEvent(se.Id).Event_Full_Text__c;
        Assert.isFalse(updated.contains('/sfc/servlet.shepherd/'), 'The authenticated download URL should have been replaced');
        Assert.isTrue(containsUrl(updated, cd.ContentDownloadUrl), 'The field should hold the public URL');
    }

    @IsTest
    static void shouldKeepConcurrentEdit_WhenFieldChangesBetweenScanAndWrite() {

        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        Summit_Events__c se = insertEvent('Concurrent Event', versionLinkTag(cv.Id));
        SummitEventsRtfLinkPipeline pipeline = new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se });

        // Run the stages by hand so an editor can save in the gap the async job would have
        pipeline.filter();
        pipeline.scan();
        update new Summit_Events__c(Id = se.Id, Event_Full_Text__c = se.Event_Full_Text__c + '<p>edited meanwhile</p>');
        pipeline.prepare();
        pipeline.create();
        pipeline.push();

        ContentDistribution cd = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId = :cv.Id];
        String updated = getEvent(se.Id).Event_Full_Text__c;
        Assert.isTrue(updated.contains('edited meanwhile'), 'An edit saved while the job ran must not be overwritten');
        Assert.isTrue(containsUrl(updated, cd.ContentDownloadUrl), 'The image should still be converted');
        Assert.isFalse(updated.contains('versionId=068'), 'The old URL should be gone');
    }

    @IsTest
    static void shouldReuseDistribution_WhenExistingLinkIsUsable() {

        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        ContentDistribution existing = new ContentDistribution(
            ContentVersionId = cv.Id, Name = 'Existing usable link',
            PreferencesAllowOriginalDownload = true, PreferencesAllowViewInBrowser = true
        );
        insert existing;
        Summit_Events__c se = insertEvent('Reuse Event', versionLinkTag(cv.Id));

        Test.startTest();
        new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        Test.stopTest();

        Assert.areEqual(1, [SELECT COUNT() FROM ContentDistribution], 'A usable link should be reused, not duplicated');
        existing = [SELECT ContentDownloadUrl FROM ContentDistribution WHERE Id = :existing.Id];
        Assert.isTrue(containsUrl(getEvent(se.Id).Event_Full_Text__c, existing.ContentDownloadUrl), 'The existing link should be used');
    }

    @IsTest
    static void shouldNeverUseOrChangeBlockedLink_WhenEditorsOwnLinkBlocksDownload() {

        // An expiring link still has a working download URL (download-blocked and password links have
        // none), so reusing it would put an image on the page that breaks when the link expires
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        ContentDistribution blocked = new ContentDistribution(
            ContentVersionId = cv.Id, Name = 'Existing expiring link',
            PreferencesAllowOriginalDownload = true, PreferencesAllowViewInBrowser = true,
            PreferencesExpires = true, ExpiryDate = System.now().addDays(1)
        );
        insert blocked;
        Summit_Events__c se = insertEvent('Blocked Link Event', versionLinkTag(cv.Id));

        Test.startTest();
        new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        Test.stopTest();

        assertBlockedLinkRespected(cv.Id, blocked.Id, getEvent(se.Id).Event_Full_Text__c);
    }

    @IsTest
    static void shouldAddUsableLink_WhenAnotherUsersLinkBlocksDownload() {

        User editor = SummitEventsTestSharedDataFactory.userToRunWith('Minimum Access - Salesforce', 'Summit_Events_Admin');
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        insert new ContentDocumentLink(ContentDocumentId = cv.ContentDocumentId, LinkedEntityId = editor.Id, ShareType = 'C');
        ContentDistribution blocked = new ContentDistribution(
            ContentVersionId = cv.Id, Name = 'Someone else\'s view-only link',
            PreferencesAllowOriginalDownload = false, PreferencesAllowViewInBrowser = true
        );
        insert blocked;
        Summit_Events__c se = insertEvent('Other User Link Event', versionLinkTag(cv.Id));

        Test.startTest();
        System.runAs(editor) {
            new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        }
        Test.stopTest();

        List<ContentDistribution> addedLinks = [
            SELECT ContentDownloadUrl, PreferencesAllowOriginalDownload
            FROM   ContentDistribution
            WHERE  ContentVersionId = :cv.Id AND Id != :blocked.Id
        ];
        Assert.areEqual(1, addedLinks.size(), 'The editor should add their own link next to someone else\'s unusable one');
        ContentDistribution added = addedLinks[0];
        Assert.isTrue(added.PreferencesAllowOriginalDownload, 'The added link must let guests load the image');
        Assert.isTrue(containsUrl(getEvent(se.Id).Event_Full_Text__c, added.ContentDownloadUrl),
            'The image should use the editor\'s new link');
        Assert.isFalse([SELECT PreferencesAllowOriginalDownload FROM ContentDistribution WHERE Id = :blocked.Id].PreferencesAllowOriginalDownload,
            'Someone else\'s link must not be modified');
    }

    @IsTest
    static void shouldStillConvertOtherImages_WhenOneLinkIsBlocked() {

        ContentVersion good = [SELECT Id FROM ContentVersion LIMIT 1];
        ContentVersion bad = new ContentVersion(Title = 'Bad', PathOnClient = 'bad.png', VersionData = Blob.valueOf('png'), IsMajorVersion = true);
        insert bad;
        ContentDistribution blocked = new ContentDistribution(
            ContentVersionId = bad.Id, Name = 'Blocked', PreferencesAllowOriginalDownload = false, PreferencesAllowViewInBrowser = true
        );
        insert blocked;
        Summit_Events__c se = insertEvent('Mixed Event', versionLinkTag(bad.Id) + versionLinkTag(good.Id));

        Test.startTest();
        new SummitEventsRtfLinkPipeline(new Map<Id, Summit_Events__c>{ se.Id => se }).run();
        Test.stopTest();

        ContentDistribution goodLink = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId = :good.Id];
        String updated = getEvent(se.Id).Event_Full_Text__c;
        Assert.isTrue(containsUrl(updated, goodLink.ContentDownloadUrl), 'The good image should still be converted');
        assertBlockedLinkRespected(bad.Id, blocked.Id, updated);
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
        ContentDistribution prefs = [
            SELECT PreferencesNotifyOnVisit, PreferencesAllowViewInBrowser, PreferencesAllowOriginalDownload,
                   PreferencesPasswordRequired, PreferencesExpires
            FROM   ContentDistribution
            WHERE  Id = :cd.Id
        ];
        Assert.isFalse(prefs.PreferencesNotifyOnVisit, 'Guest views must not email the person who created the link');
        Assert.isTrue(prefs.PreferencesAllowViewInBrowser, 'The image must be viewable in the browser');
        Assert.isTrue(prefs.PreferencesAllowOriginalDownload, 'The direct download URL requires original download');
        Assert.isFalse(prefs.PreferencesPasswordRequired, 'Guests cannot enter a password');
        Assert.isFalse(prefs.PreferencesExpires, 'The link must not expire out from under a live event page');
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
    static void shouldReuseStoredFileDuringSave_WhenStalePageSavesConvertedUploadAgain() {

        // An earlier job stored image 1 and rewrote the field, but the editor's page still held the
        // old upload URL and they kept their value in Lightning's conflict dialog, adding image 2
        insert new Summit_Events_Settings__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Opt_Into_Link_Automation__c = true
        );
        Summit_Events__c se = stageRtaEvent('Stale Save Event', rtaTag(1) + rtaTag(2));
        ContentVersion stored = storedUpload(se.Id, 1);
        ImageMock mock = new ImageMock(200, 'image/jpeg');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        update new Summit_Events__c(Id = se.Id, Event_Name__c = 'Stale Save Event Renamed');
        Integer queued = Limits.getQueueableJobs();
        String afterSave = getEvent(se.Id).Event_Full_Text__c;
        Test.stopTest();

        Assert.areEqual(1, [SELECT COUNT() FROM ContentVersion WHERE PathOnClient LIKE :(refId(1) + '.%')],
            'The stored image must not be stored again');
        Assert.areEqual(1, mock.callCount, 'Only the new image should be fetched');
        Assert.isTrue(mock.lastEndpoint.endsWith(refId(2)), 'The fetch should be for the new image: ' + mock.lastEndpoint);
        Assert.areEqual(1, queued, 'Only the new image should need a job');
        List<ContentDistribution> storedLinks = [SELECT ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId = :stored.Id];
        Assert.areEqual(1, storedLinks.size(), 'The stored file should have been published');
        Assert.isTrue(containsUrl(afterSave, storedLinks[0].ContentDownloadUrl), 'The stored image should be converted within the save itself');
    }

    @IsTest
    static void shouldReuseStoredFileInJob_WhenUploadWasAlreadyStored() {

        Summit_Events__c se = stageRtaEvent('Stored Upload Event', rtaTag(1));
        ContentVersion stored = storedUpload(se.Id, 1);
        ImageMock mock = new ImageMock(200, 'image/jpeg');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        new SummitEventsRtaImageQueueable(new List<Id>{ se.Id }).execute(null);
        Test.stopTest();

        Assert.areEqual(0, mock.callCount, 'An image already stored as a file should not be fetched again');
        List<ContentDistribution> storedLinks = [SELECT ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId = :stored.Id];
        Assert.areEqual(1, storedLinks.size(), 'The stored file should have been published');
        Assert.isTrue(containsUrl(getEvent(se.Id).Event_Full_Text__c, storedLinks[0].ContentDownloadUrl), 'The stored file should be used');
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
    static void shouldChainAnotherJob_WhenJobPublishedImagesAndMoreRemain() {

        List<Id> eventIds = stageManyRtaEvents(25);
        Test.setMock(HttpCalloutMock.class, new ImageMock(200, 'image/jpeg'));

        Test.startTest();
        new SummitEventsRtaImageQueueable(eventIds).execute(null);
        Integer queued = Limits.getQueueableJobs();
        Test.stopTest();

        Assert.areEqual(1, queued, 'A job that published images should chain another for the rest');
    }

    @IsTest
    static void shouldNotChainAnotherJob_WhenJobPublishedNothing() {

        // Can edit events and create files, but cannot create public links, so every link insert fails
        User editor = editorWithoutPublicLinks();
        List<Id> eventIds = stageManyRtaEvents(25);
        ImageMock mock = new ImageMock(200, 'image/jpeg');
        Test.setMock(HttpCalloutMock.class, mock);
        Integer queued;

        Test.startTest();
        System.runAs(editor) {
            new SummitEventsRtaImageQueueable(eventIds).execute(null);
            queued = Limits.getQueueableJobs();
        }
        Test.stopTest();

        Assert.areEqual(0, queued, 'A job that published nothing must not chain, or the next job stores the same images again');
        Assert.areEqual(20, mock.callCount, 'Only the first job\'s batch should have been fetched');
        Assert.areEqual(0, [SELECT COUNT() FROM ContentDistribution], 'No link could be created');
    }

    @IsTest
    static void shouldQueueOneJob_WhenSavingEventWithVersionLinkAndRtaImage() {

        insert new Summit_Events_Settings__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Opt_Into_Link_Automation__c = true
        );
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        // Converting the version link updates the event, which fires the trigger again inside the save
        Summit_Events__c se = stageRtaEvent('Both Kinds Event', versionLinkTag(cv.Id) + rtaTag(1));
        ImageMock mock = new ImageMock(200, 'image/jpeg');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        update new Summit_Events__c(Id = se.Id, Event_Name__c = 'Both Kinds Event Renamed');
        Integer queued = Limits.getQueueableJobs();
        Test.stopTest();

        Assert.areEqual(1, queued, 'The nested trigger run must not queue a second job for the same image');
        Assert.areEqual(1, mock.callCount, 'The image should be fetched once');
        Assert.areEqual(2, [SELECT COUNT() FROM ContentVersion], 'Only one file should be stored for the uploaded image');
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

    // The editor's own blocked link must never be changed or used. The platform usually rejects their
    // second link to the file (DUPLICATE_VALUE), so the image stays as written, but in parallel test
    // runs it sometimes accepts it (measured), and then the image must use that new usable link.
    private static void assertBlockedLinkRespected(Id versionId, Id blockedId, String html) {
        ContentDistribution blocked = [
            SELECT ContentDownloadUrl, PreferencesAllowOriginalDownload, PreferencesPasswordRequired, PreferencesExpires
            FROM   ContentDistribution
            WHERE  Id = :blockedId
        ];
        Assert.isTrue(!blocked.PreferencesAllowOriginalDownload || blocked.PreferencesPasswordRequired || blocked.PreferencesExpires,
            'The existing link must not be modified');
        Assert.isTrue(blocked.ContentDownloadUrl == null || !containsUrl(html, blocked.ContentDownloadUrl),
            'The blocked link must never be used: ' + html);
        List<ContentDistribution> added = [
            SELECT ContentDownloadUrl, PreferencesAllowOriginalDownload
            FROM   ContentDistribution
            WHERE  ContentVersionId = :versionId AND Id != :blockedId
        ];
        if(added.isEmpty()) {
            Assert.isTrue(html.contains(versionId), 'With no usable link the image must be left as written: ' + html);
        } else {
            Assert.isTrue(added[0].PreferencesAllowOriginalDownload, 'Any added link must let guests load the image');
            Assert.isTrue(containsUrl(html, added[0].ContentDownloadUrl), 'The image must use the usable link, never the blocked one: ' + html);
        }
    }

    // A file stored for an upload the way an earlier job does it: on the event, named refId.extension
    private static ContentVersion storedUpload(Id eventId, Integer n) {
        ContentVersion stored = new ContentVersion(
            Title = 'Stored ' + refId(n), PathOnClient = refId(n) + '.jpg', VersionData = Blob.valueOf('stored-image'),
            FirstPublishLocationId = eventId, IsMajorVersion = true
        );
        insert stored;
        return stored;
    }

    private static List<Id> stageManyRtaEvents(Integer count) {
        List<Id> eventIds = new List<Id>();
        for(Integer i = 1; i <= count; i++) {
            eventIds.add(stageRtaEvent('Bulk ' + i, rtaTag(i)).Id);
        }
        return eventIds;
    }

    // Minimum access user who can edit events and their rich text, but lacks Create Public Links
    private static User editorWithoutPublicLinks() {
        User editor = SummitEventsTestSharedDataFactory.userToRunWith('Minimum Access - Salesforce', null);
        String objectName = Summit_Events__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            PermissionSet editing = new PermissionSet(Name = 'Event_Editing_Without_Links', Label = 'Event Editing Without Links');
            insert editing;
            insert new ObjectPermissions(
                ParentId = editing.Id, SobjectType = objectName,
                PermissionsRead = true, PermissionsEdit = true, PermissionsDelete = true,
                PermissionsViewAllRecords = true, PermissionsModifyAllRecords = true
            );
            insert new FieldPermissions(
                ParentId = editing.Id, SobjectType = objectName,
                Field = objectName + '.' + Summit_Events__c.Event_Full_Text__c.getDescribe().getName(),
                PermissionsRead = true, PermissionsEdit = true
            );
            insert new PermissionSetAssignment(AssigneeId = editor.Id, PermissionSetId = editing.Id);
        }
        return editor;
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
