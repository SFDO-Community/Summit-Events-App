/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/15/2023.
 */


public with sharing class SummitEventsGeneratedItinerariesExt {
    public Summit_Events_Registration__c seaRegistration;
    public String generatedItinerary { get; set; }
    public String requestedItinerary { get; set; }

    public SummitEventsGeneratedItinerariesExt(ApexPages.StandardController stdController) {
        seaRegistration = (Summit_Events_Registration__c) stdController.getRecord();
        generatedItinerary = seaRegistration.Generated_Itinerary__c;
        requestedItinerary = seaRegistration.Generated_Requested_Appointments__c;
    }
}