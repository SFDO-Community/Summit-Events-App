/**
 * Created by Thad-PC-2019 on 4/9/2025.
 */

import {LightningElement, wire, api, track} from 'lwc';
import {gql, graphql} from "lightning/uiGraphQLApi";

export default class UstMap extends LightningElement {

    @api recordId;

    @track mapMarkers;

    // Define the center of the map
    center = {
        location: {
            Latitude: 44.949642, // San Francisco Latitude
            Longitude: -93.093124 // San Francisco Longitude
        }
    };

    // Console log the recordId received
    connectedCallback() {
        //console.log('Record Id:', this.recordId);
    }

    //Use LWC graphQl to query all summit_event_registrations using registrant_city__c registrant_state__c registrant_country__c, registrant_postal_code__c to build out mapParkers
    @wire(graphql, {
        query: gql`
            query getRegistrations($recordId: ID) {
                uiapi {
                    query {
                        summit__Summit_Events_Registration__c(
                            where: {
                                and: [
                                    { summit__Event_Instance__c: { eq: $recordId } }
                                    { summit__Registrant_City__c: { ne: null } }
                                    { summit__Registrant_State__c: { ne: null } }
                                    { summit__Registrant_Zip__c: { ne: null } }
                                ]
                            }
                        ) {
                            edges {
                                node {
                                    Id
                                    summit__Registrant_Street_1__c {
                                        value
                                    }
                                    summit__Preferred_First_Name_Formatted__c {
                                        value
                                    }
                                    summit__Registrant_Street_2__c {
                                        value
                                    }
                                    summit__Registrant_City__c {
                                        value
                                    }
                                    summit__Registrant_State__c {
                                        value
                                    }
                                    summit__Registrant_Country__c {
                                        value
                                    }
                                    summit__Registrant_Zip__c {
                                        value
                                    }
                                }
                            }
                        }
                    }
                }
            }`,
        variables: "$variables",
    })
    summitEventRegistration({errors, data}) {
        if (data) {
            this.mapMarkers = data.uiapi.query.summit__Summit_Events_Registration__c.edges.map((edge) => ({
                location: {
                    City: edge.node.summit__Registrant_City__c.value || '',
                    Country: edge.node.summit__Registrant_Country__c.value || '',
                    PostalCode: edge.node.summit__Registrant_Zip__c.value || '',
                    State: edge.node.summit__Registrant_State__c.value || '',
                    Street:
                        (edge.node.summit__Registrant_Street_1__c?.value || '') +
                        (edge.node.summit__Registrant_Street_2__c?.value ? ' ' + edge.node.summit__Registrant_Street_2__c.value : '')
                },
                title: edge.node.summit__Preferred_First_Name_Formatted__c.value || 'Registrant',
                url: '/lightning/r/Account/' + edge.node.Id + '/view',
                description: 'Registration',
                value: edge.node.Id,
                icon: 'standard:location'
            }));
        } else if (errors) {
            console.error('Errors:', errors);
        }
    }

    get variables() {
        return {
            recordId: this.recordId,
            // dateFilter: this.dateFilter,
        }
    }

    handleMapClick(event) {

        const marker = event.detail;
        const markerId = marker.value;
        const url = `/lightning/r/Account/${markerId}/view`;
        window.open(url, '_blank');
    }

}