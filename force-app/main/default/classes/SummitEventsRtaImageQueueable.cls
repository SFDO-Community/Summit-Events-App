/**
 * Converts rich text editor images on Summit_Events__c records into public files.
 * Needs its own async transaction because reading the image bytes requires a REST
 * callout, which is not allowed in a trigger. See {@link SummitEventsRtfLinkPipeline}.
 */
public with sharing class SummitEventsRtaImageQueueable implements Queueable, Database.AllowsCallouts {

    private final List<Id> eventIds;

    /**
     * @param eventIds Summit_Events__c records that have rich text editor images to convert
     */
    public SummitEventsRtaImageQueueable(List<Id> eventIds) {
        this.eventIds = eventIds;
    }

    public void execute(QueueableContext context) {
        if(eventIds == null || eventIds.isEmpty()) {
            return;
        }

        Boolean hasMore = new SummitEventsRtfLinkPipeline(eventIds).runAsync();

        // Each job is capped for limits; chain another for the remainder. Only chains
        // when this job made progress, so a permanent failure cannot loop forever.
        if(hasMore && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            try {
                System.enqueueJob(new SummitEventsRtaImageQueueable(eventIds));
            } catch(AsyncException e) {
                // Chain depth is capped in tests and in trial/developer orgs. The images already
                // converted are saved; the rest convert the next time the event is saved.
                SummitEventsRtfLinkPipeline.notifyUser(eventIds[0], new Set<String>{ Label.SummitEventsImageNotifMore });
            }
        }
    }
}
