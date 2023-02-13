/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 2/1/2023.
 */


public with sharing class SummitEventsAppointmentTriggerHandler {

    public static void generateItineraries(List<SObject> newList, List<SObject> oldList) {

        //Create a mapped list of unique ids
        List<Summit_Events_Appointments__c> allAppointments = new List<Summit_Events_Appointments__c>();
        Set<Id> uniqueRegistrationIds = new Set<Id>();

        if (newList != null) {
            for (Summit_Events_Appointments__c na : (List<Summit_Events_Appointments__c>) newList) {
                uniqueRegistrationIds.add(na.Event_Registration__c);
            }
        }

        if (oldList != null) {
            for (Summit_Events_Appointments__c oa : (List<Summit_Events_Appointments__c>) oldList) {
                uniqueRegistrationIds.add(oa.Event_Registration__c);
            }
        }

        if (uniqueRegistrationIds.size() > 0) {

            String namespace = SummitEventsNamespace.getNamespace();
            if (String.isNotBlank(namespace)) {
                namespace = namespace.toLowerCase() + '__';
            }

            //Get the all query fields from global picklist
            String appointmentFields = getAppointmentQueryFields();

            try {
                String query = 'SELECT Id, Name, ';
                query += namespace + 'Appointment_Time__c,';
                query += namespace + 'Event_Registration__r.Id, ';
                query += namespace + 'Event_Registration__r.' + namespace + 'Event_Name__c, ';
                query += namespace + 'Appointment_Status__c, ';
                query += namespace + 'Chosen_State__c,  ';
                query += namespace + 'Do_Not_Show_Time__c, ';
                query += namespace + 'Sort_Order__c, ';
                query += namespace + 'Event_Appointment_Type__r.' + namespace + 'Summit_Events__c, ';
                query += namespace + 'Event_Registration__r.' + namespace + 'Event__c,';
                //TODO: Maybe surface up host information on appointment record with formula
                query += namespace + 'Event_Host__c, ';
                query += namespace + 'Event_Host__r.' + namespace + 'Assigned__c, ';
                query += namespace + 'Event_Host__r.' + namespace + 'Time__c, ';
                query += namespace + 'Event_Host__r.' + namespace + 'Course_Name__c, ';
                query += namespace + 'Event_Host__r.RecordType.Name, ';
                query += appointmentFields + ' ';
                query += 'FROM ' + namespace + 'Summit_Events_Appointments__c ';
                query += 'WHERE ' + namespace + 'Event_Registration__r.Id IN :uniqueRegistrationIds ';
                //TODO: Order by date before time
                query += 'ORDER BY ' + namespace + 'Appointment_Time__c ASC, ';
                query += namespace + 'Event_Host__r.' + namespace + 'Time__c ASC, ';
                query += namespace + 'Sort_Order__c, ';
                query += namespace + 'Appointment_Title__c ASC ';
                allAppointments = Database.query(query);
            } catch (DmlException dmlExc) {
                System.debug(dmlExc.getMessage());
            } catch (Exception e) {
                System.debug(e.getMessage());
            }

            System.debug(JSON.serializePretty(allAppointments));
            if (allAppointments.size() > 0) {


                SummitEventsShared seaShared = new SummitEventsShared();
                Map<Id, List<Summit_Events_Appointments__c>> appointmentListByRegistration = new Map<Id, List<Summit_Events_Appointments__c>>();
                //Get event itinerary generating parameters
                Set<Id> eventIds = new Set<Id>();
                for (Summit_Events_Appointments__c appointment : allAppointments) {
                    eventIds.add(appointment.Event_Appointment_Type__r.Summit_Events__c);
                }

                Map<Id, Summit_Events__c> eventItinerarySetup = new Map<Id, Summit_Events__c>();
                if (eventIds.size() > 0) {
                    eventItinerarySetup = new Map<Id, Summit_Events__c>([
                            SELECT Id, Itinerary_Item_1__c, Itinerary_Item_2__c, Itinerary_Item_3__c, Itinerary_Item_4__c, Itinerary_Item_5__c,
                                    Itinerary_Label_1__c, Itinerary_Label_2__c, Itinerary_Label_3__c, Itinerary_Label_4__c, Itinerary_Label_5__c,
                                    Itinerary_Display_Options__c
                            FROM Summit_Events__c
                            WHERE Id IN :eventIds
                    ]);
                }

                for (Summit_Events_Appointments__c appointment : allAppointments) {
                    if (appointmentListByRegistration.containsKey(appointment.Event_Registration__r.Id)) {
                        List<Summit_Events_Appointments__c> preexistingAppointments = appointmentListByRegistration.get(appointment.Event_Registration__r.Id);
                        preexistingAppointments.add(appointment);
                        appointmentListByRegistration.put(appointment.Event_Registration__c, preexistingAppointments);

                    } else {
                        List<Summit_Events_Appointments__c> newAppointments = new List<Summit_Events_Appointments__c>();
                        newAppointments.add(appointment);
                        appointmentListByRegistration.put(appointment.Event_Registration__r.Id, newAppointments);
                    }
                }

                List<Summit_Events_Registration__c> registrationsWithItineraries = new List<Summit_Events_Registration__c>();
                for (Id eventRegKey : appointmentListByRegistration.keySet()) {

                    List<Summit_Events_Appointments__c> apptList = appointmentListByRegistration.get(eventRegKey);
                    Summit_Events_Registration__c registration = new Summit_Events_Registration__c(Id = eventRegKey);
                    String requestedAppointments = '';
                    String confirmedAppointments = '';

                    for (Summit_Events_Appointments__c apt : apptList) {

                        Summit_Events__c itineraryStyle = eventItinerarySetup.get(apt.Event_Appointment_Type__r.Summit_Events__c);

                        String appointmentDisplayType = itineraryStyle.Itinerary_Display_Options__c;

                        if (apt.Appointment_Status__c.equalsIgnoreCase('Confirmed')) {
                            for (Integer i = 1; i < 6; i++) {

                                //Confirmed appointments styled by event definition
                                String appointmentField = '';
                                if (itineraryStyle.get(namespace + 'itinerary_Item_' + i + '__c') != null) {
                                    appointmentField = (String) itineraryStyle.get(namespace + 'itinerary_Item_' + i + '__c');
                                }

                                String appointmentLabel = '';
                                if (itineraryStyle.get(namespace + 'Itinerary_Label_' + i + '__c') != null) {
                                    appointmentLabel = (String) itineraryStyle.get(namespace + 'Itinerary_Label_' + i + '__c');
                                }

                                String fieldValue = '';
                                if (String.isNotBlank(appointmentField) && apt.get(appointmentField) != null) {
                                    fieldValue = String.valueOf(apt.get(appointmentField));
                                }

                                if (String.isNotBlank(fieldValue) && String.isNotBlank(appointmentLabel)) {
                                    if (String.isNotBlank(appointmentDisplayType)) {
                                        if (appointmentDisplayType.equalsIgnoreCase('Labels as headers')) {
                                            confirmedAppointments += '<b>' + appointmentLabel + '</b><br/>';
                                        }

                                        if (appointmentDisplayType.equalsIgnoreCase('Labels inline with colon')) {
                                            confirmedAppointments += '<i><b>' + appointmentLabel + ': </b></i>';
                                        }
                                    } else {
                                        confirmedAppointments += '<i>' + appointmentLabel + ': </i>';
                                    }
                                }

                                if (String.isNotBlank(fieldValue)) {
                                    confirmedAppointments += fieldValue;
                                    if (!fieldValue.endsWithIgnoreCase('</p>')) {
                                        confirmedAppointments += '<br/>';
                                    }
                                }

                                if (i == 5 && String.isNotBlank(confirmedAppointments)) {
                                    confirmedAppointments += '<br/>';
                                }
                            }
                        }

                        //Create requested itinerary
                        String currentRegAppointment = '';
                        if (String.isNotBlank(apt.Appointment_Title__c)) {
                            currentRegAppointment += '<b>' + apt.Appointment_Title__c.trim() + '</b><br/>';
                        }
                        if (String.isNotBlank(apt.Description__c)) {
                            currentRegAppointment += seaShared.removeHTMLandEscape(apt.Description__c, false).trim() + '<br/>';
                        }
                        if (String.isNotBlank(apt.Registrant_Input__c)) {
                            currentRegAppointment += seaShared.removeHTMLandEscape(apt.Registrant_Input__c, false).trim() + '<br/>';
                        }
                        if (String.isNotBlank(currentRegAppointment)) {
                            requestedAppointments += currentRegAppointment + '<br/>';
                        }

                    }
                    confirmedAppointments = confirmedAppointments.removeEnd('<br/><br/>');
                    requestedAppointments = requestedAppointments.removeEnd('<br/><br/>');

                    registration.Generated_Itinerary__c = confirmedAppointments;
                    registration.Generated_Requested_Appointments__c = requestedAppointments;
                    registrationsWithItineraries.add(registration);
                }

                if (registrationsWithItineraries.size() > 0) {
                    doCRUD CRUDtoDo = new doCRUD();
                    System.debug(JSON.serializePretty(registrationsWithItineraries));
                    CRUDtoDo.updateRegistration(registrationsWithItineraries);
                }

            }
        }

    }

    public static String getAppointmentQueryFields() {
        List<String> picklists = new List<String>();

        List<String> packagedItineraryFields = new List<String>{
                'Appointment_Category__c', 'Appointment_Date__c', 'Appointment_Detail__c', 'Appointment_Time_Formatted__c', 'Appointment_Title__c',
                'Appointment_Type__c', 'Appointment_Virtual_Meeting_URL__c', 'Building__c', 'Class_Title__c', 'Description__c', 'Faculty_Staff_Member__c',
                'Host_Location__c', 'Host_Name__c', 'Registrant_Input__c', 'Room__c'
        };

        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace.toLowerCase() + '__';
        }

        List<Schema.PicklistEntry> PicklistValues = Schema.getGlobalDescribe().get(namespace + 'Summit_Events__c').getDescribe().fields.getMap().get(namespace + 'Itinerary_Item_1__c').getDescribe().getPicklistValues();
        for (Schema.PicklistEntry PicklistValue : PicklistValues) {
            if (PicklistValue.getValue().endsWithIgnoreCase('__c')) {
                if (packagedItineraryFields.contains(PicklistValue.getValue())) {
                    picklists.add(namespace + PicklistValue.getValue());
                } else {
                    picklists.add(PicklistValue.getValue());
                }
            }
        }
        String queryFields = String.join(picklists, ', ');
        return queryFields;
    }

    private without sharing class doCRUD {
        private void updateRegistration(List<Summit_Events_Registration__c> uRegs) {
            try {
                upsert uRegs;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }

    }

}