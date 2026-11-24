/**
 * Converts rich text editor images on event, appointment type and email records into public files.
 * Needs its own async transaction because reading the image bytes requires a REST
 * callout, which is not allowed in a trigger. See {@link SummitEventsRtfLinkPipeline}.
 */
public with sharing class SummitEventsRtaImageQueueable implements Queueable, Database.AllowsCallouts {

    private final List<Id> recordIds;

    /**
     * @param recordIds records of one supported object that have rich text editor images to convert
     */
    public SummitEventsRtaImageQueueable(List<Id> recordIds) {
        this.recordIds = recordIds;
    }

    public void execute(QueueableContext context) {
        if(recordIds == null || recordIds.isEmpty()) {
            return;
        }

        Boolean hasMore = new SummitEventsRtfLinkPipeline(recordIds).runAsync();

        // Each job is capped for limits; chain another for the remainder. Only chains when this
        // job published at least one image, so a permanent failure cannot loop forever or keep
        // storing duplicate copies of the same images.
        if(hasMore && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            try {
                System.enqueueJob(new SummitEventsRtaImageQueueable(recordIds));
            } catch(AsyncException e) {
                // Chain depth is capped in tests and in trial/developer orgs. The images already
                // converted are saved; the rest convert the next time the record is saved.
                SummitEventsRtfLinkPipeline.notifyUser(recordIds[0], new Set<String>{ Label.SummitEventsImageNotifMore });
            }
        }
    }
}
