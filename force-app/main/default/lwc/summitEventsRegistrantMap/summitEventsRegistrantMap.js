import { LightningElement, wire, api } from 'lwc';
import getSummitEventsRegistrants from '@salesforce/apex/SummitEventsMapController.getSummitEventsRegistrants';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

export default class SummitEventsRegistrantMap extends LightningElement {
	@api recordId;
    @api objectApiName;
    mapMarkers;
	selectedEventInstance = '';
	selectedMarkerValue;
	eventInstancesOptions = [
		{ label: 'All Event Instances', value: '' }
	];

	get selectedEventOrEventInstanceId() {
		return (this.selectedEventInstance === null || this.selectedEventInstance === '') ? this.recordId : this.selectedEventInstance;
	}

	get isEvent() {
		return this.objectApiName === 'Summit_Events__c';
	}

	@wire(getRelatedListRecords, {
		parentRecordId: '$recordId',
		relatedListId: 'Event_Instances__r',
		fields: ['Summit_Events_Instance__c.Id','Summit_Events_Instance__c.Event__c', 'Summit_Events_Instance__c.Name'],
		orderBy: 'Summit_Events_Instance__c.Name'
	})
	listInfo({ error, data }) {
		if (data) {
			data.records.forEach((childRecord) => {
				this.eventInstancesOptions.push({
					label: childRecord?.fields?.Name?.value,
					value: childRecord?.fields?.Id?.value
				})
			});
			this.eventInstancesOptions = JSON.parse(JSON.stringify(this.eventInstancesOptions));
		} else if (error) {
			if (this.isEvent) {
				console.error(JSON.stringify(error));
			}
		}
	}

	@wire(getSummitEventsRegistrants, {eventId: '$selectedEventOrEventInstanceId'})
	summitEventsRegistrants ({error, data}) {
		if (error) {
			console.error(JSON.stringify(error));
		} else if (data) {
			this.mapMarkers = data.map((registrant) => ({
				location: {
					Latitude: registrant?.Contact__r?.MailingLatitude,
					Longitude: registrant?.Contact__r?.MailingLongitude,
				},
				title: registrant?.Preferred_First_Name_Formatted__c || 'Registrant',
				description: registrant?.Contact__r?.MailingCity + ', ' + (registrant?.Contact__r?.MailingState === undefined ? registrant?.Contact__r?.MailingCountry : registrant?.Contact__r?.MailingState),
				value: registrant?.Id,
				icon: 'standard:location'
			}));
		}
	}
	handleSelectEventInstanceChange(event) {
		this.selectedEventInstance = event.target.value;
	}

	handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
	}
}