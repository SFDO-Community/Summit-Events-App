public with sharing class SummitEventsRtfLinkHandler {
    public static void run(List<Summit_Events__c> newList) {
        new SummitEventsRtfLinkPipeline(newList).run();
    }

    // Future consideration: add async logic here

}