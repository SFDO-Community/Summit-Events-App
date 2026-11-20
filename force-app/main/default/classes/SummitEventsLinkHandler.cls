public with sharing class SummitEventsLinkHandler {
    /**
     * Makes images in the saved records' public-facing rich text fields public.
     * Called from the event, appointment type and email triggers.
     *
     * @param newMap Trigger.newMap of a supported object (see SummitEventsRtfLinkPipeline)
     */
    public static void run(Map<Id,SObject> newMap) {
        new SummitEventsRtfLinkPipeline(newMap).run();
    }

    // Future consideration: add async logic here

}