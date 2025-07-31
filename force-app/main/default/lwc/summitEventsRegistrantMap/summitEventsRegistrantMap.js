import { LightningElement, wire, api } from 'lwc';
import getSummitEventsRegistrants from '@salesforce/apex/SummitEventsMapController.getSummitEventsRegistrants';

export default class SummitEventsRegistrantMap extends LightningElement {
	@api recordId;
    @api objectApiName;
    mapMarkers;

	// Define the center of the map
    center = {
        location: {
            // Latitude: 44.949642, // San Francisco Latitude
            // Longitude: -93.093124 // San Francisco Longitude
        }
    };

	@wire(getSummitEventsRegistrants, {eventId: '$recordId'})
	summitEventsRegistrants ({error, data}) {
		if (error) {
			console.error(error);
		} else if (data) {
			console.log((JSON.stringify(data)));
			this.mapMarkers = data.map((registrant) => ({
				location: {
					Latitude: registrant?.Contact__r?.MailingLatitude,
					Longitude: registrant?.Contact__r?.MailingLongitude
				},
				title: registrant.Preferred_First_Name_Formatted__c || 'Registrant',
				url: '/lightning/r/Account/' + registrant.Id + '/view',
				description: 'Registration',
				value: registrant.Id,
				icon: 'standard:location'
			}));
		}
	}
}