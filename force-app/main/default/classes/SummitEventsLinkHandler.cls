public with sharing class SummitEventsLinkHandler {
    public static void run(Map<Id,Summit_Events__c> newMap) {
        new SummitEventsRtfLinkPipeline(newMap).run();
    }

    // Future consideration: add async logic here

}