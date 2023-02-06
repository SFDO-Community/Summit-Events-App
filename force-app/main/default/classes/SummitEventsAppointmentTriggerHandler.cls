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

            if (allAppointments.size() > 0) {

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
                                    Itinerary_Item_Style_1__c, Itinerary_Item_Style_2__c, Itinerary_Item_Style_3__c, Itinerary_Item_Style_4__c, Itinerary_Item_Style_5__c,
                                    Itinerary_Table_Head_Or_Title_1__c, Itinerary_Table_Head_Or_Title_2__c, Itinerary_Table_Head_Or_Title_3__c,
                                    Itinerary_Table_Head_Or_Title_4__c, Itinerary_Table_Head_Or_Title_5__c
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

                    Boolean openTd = false;
                    String tableHead = '';
                    Boolean tableEvaluated = false;

                    for (Summit_Events_Appointments__c apt : apptList) {

                        Summit_Events__c itineraryStyle = eventItinerarySetup.get(apt.Event_Appointment_Type__r.Summit_Events__c);

                        if (!tableEvaluated) {
                            for (Integer i = 1; i < 6; i++) {
                                if (itineraryStyle.get(namespace + 'itinerary_Item_Style_' + i + '__c') != null) {
                                    String headerCheck = (String) itineraryStyle.get(namespace + 'itinerary_Item_Style_' + i + '__c');
                                    if (headerCheck.equalsIgnoreCase('Has table row header')) {
                                        String headText = '';
                                        if (itineraryStyle.get(namespace + 'itinerary_Table_Head_Or_Title_' + i + '__c') != null) {
                                            headText = (String) itineraryStyle.get(namespace + 'itinerary_Table_Head_Or_Title_' + i + '__c');
                                        }
                                        tableHead += '<th align="left" style="text-align:left; font-family:arial; font-size:12pt; color:#000000;">' + headText + '</th>';
                                    }
                                }
                            }
                            if (String.isNotBlank(tableHead)) {
                                tableHead = '<tr>' + tableHead + '</tr>';
                            }
                            tableEvaluated = true;
                        }


                        for (Integer i = 1; i < 6; i++) {

                            String appointmentField = '';
                            if (itineraryStyle.get(namespace + 'itinerary_Item_' + i + '__c') != null) {
                                appointmentField = (String) itineraryStyle.get(namespace + 'itinerary_Item_' + i + '__c');
                            }
                            String appointmentStyle = '';
                            if (itineraryStyle.get(namespace + 'itinerary_Item_Style_' + i + '__c') != null) {
                                appointmentStyle = (String) itineraryStyle.get(namespace + 'itinerary_Item_Style_' + i + '__c');
                            }
                            String appointmentHead = '';
                            if (itineraryStyle.get(namespace + 'itinerary_Table_Head_Or_Title_' + i + '__c') != null) {
                                appointmentHead = (String) itineraryStyle.get(namespace + 'itinerary_Table_Head_Or_Title_' + i + '__c');
                            }
                            String fieldValue = '';
                            if (apt.get(appointmentField) != null) {
                                fieldValue = String.valueOf(apt.get(appointmentField));

                            }

                            if (appointmentStyle.equalsIgnoreCase('Has table row header')) {
                                if (openTd) {
                                    fieldValue = '</td><td style="vertical-align:top; text-align:left; font-family:arial,sans-serif; font-size:12pt; color:#000000; padding-top:5px; padding-bottom:10px; padding-left:15px;"> ' + fieldValue;
                                } else {
                                    fieldValue = '<td style="vertical-align:top; text-align:left; font-family:arial,sans-serif; font-size:12pt; color:#000000; padding-top:5px; padding-bottom:10px; padding-left:15px;"> ' + fieldValue;
                                }
                                openTd = true;
                            }

                            requestedAppointments += fieldValue;

                            //Get field type to cast correctly
//                            SObjectType r = ((SObject) (Type.forName('Schema.' + namespace + 'Summit_Events_Appointments__c').newInstance())).getSObjectType();
//                            DescribeSObjectResult d = r.getDescribe();
//                            Schema.DisplayType fieldDataType = d.fields.getMap().get(appointmentField).getDescribe().getType();
                            if (i == 5 && String.isNotBlank(tableHead)) {
                                if (openTd) {
                                    requestedAppointments = requestedAppointments + '</td>';
                                    openTd = false;
                                }
                                requestedAppointments = '<tr>' + requestedAppointments + '</tr>';
                            }
                        }

                    }


                    if (String.isNotBlank(tableHead)) {
                        requestedAppointments = '<table border="0" cellpadding="10" cellspacing="0">' + tableHead + requestedAppointments + '</table>';
                    }
                    registration.Generated_Itinerary__c = confirmedAppointments;
                    registration.Generated_Requested_Appointments__c = requestedAppointments;
                    registrationsWithItineraries.add(registration);
                }

                if (registrationsWithItineraries.size() > 0) {
                    doCRUD CRUDtoDo = new doCRUD();
                    CRUDtoDo.updateRegistration(registrationsWithItineraries);
                }

/*
                // Generate itinaries
                String generatedItinerary = '';
                String generatedAppointment = '';
                String tableHead = '';
                String tableHead2 = '';
                //Is there time in any of the itinerary so we should show the time column?
                Boolean appointmentsHaveTime = false;
                Boolean appointmentsHaveLocation = false;
                Boolean appointmentsHaveHost = false;
                Boolean appointmentsHaveMeet = false;

                //Is there time in any of the itinerary so we should show the time column?

                for (Summit_Events_Appointments__c appointmentTime : allAppointments) {
                    if (!String.isBlank(appointmentTime.Appointment_Time_Formatted__c) && !appointmentTime.Do_Not_Show_Time__c) {
                        appointmentsHaveTime = true;
                    }
                    if (!String.isBlank(appointmentTime.Building__c) ||
                            !String.isBlank(appointmentTime.Room__c)) {
                        appointmentsHaveLocation = true;
                    }
                    if (!String.isBlank(appointmentTime.Host_Name__c) || !String.isBlank(appointmentTime.Host_Location__c)) {
                        appointmentsHaveHost = true;
                    }
                    if (!String.isBlank(appointmentTime.Appointment_Virtual_Meeting_URL__c)) {
                        appointmentsHaveMeet = true;
                    }
                }


                if (appointmentsHaveTime) {
                    tableHead += '<th align="left" style="text-align:left; font-family:arial; font-size:12pt; color:#000000;">Time</th>';
                }
                tableHead += '<th align="left" style="text-align:left; font-family:arial; font-size:12pt; color:#000000;">Description</th>';
                if (appointmentsHaveHost) {
                    tableHead2 += '<th align="left" style="text-align:left; font-family:arial; font-size:12pt; color:#000000;">Host</th>';
                }
                if (appointmentsHaveMeet) {
                    tableHead2 += '<th align="left" style="text-align:left; font-family:arial; font-size:12pt; color:#000000;">Meeting Link</th>';
                }

                if (appointmentsHaveLocation) {
                    tableHead2 += '<th align="left" style="text-align:left; font-family:arial; font-size:12pt; color:#000000;">Location</th>';
                }

                String lastId = allAppointments[0].Id;
                for (Integer i = 0; i < allAppointments.size(); i++) {

                    // add all confirmed appointments
                    if (allAppointments[i].Appointment_Status__c == 'Confirmed') {
                        generatedItinerary += '<tr>';

                        //Appointment Time
                        if (appointmentsHaveTime) {
                            generatedItinerary += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000; padding-top:5px; padding-bottom:10px; padding-right:15px;">';
                            if (!allAppointments[i].Do_Not_Show_Time__c) {
                                if (!String.isBlank(allAppointments[i].Appointment_Time_Formatted__c)) {
                                    generatedItinerary += allAppointments[i].Appointment_Time_Formatted__c.replace(' ', '&nbsp;');
                                }
                            }
                            generatedItinerary += '</td>';
                        }

                        //Appointment Description
                        generatedItinerary += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; padding-top:5px; padding-bottom:10px; color:#000000;">';
                        generatedItinerary += allAppointments[i].Appointment_Title__c + ' - ';
                        generatedItinerary = generatedItinerary.removeEnd(' - ');
                        generatedItinerary += '</td>';

                        //Appointment Meeting Link
                        if (appointmentsHaveMeet) {
                            generatedItinerary += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; padding-top:5px; padding-bottom:10px; color:#000000;">';
                            generatedItinerary = generatedItinerary.removeEnd(' - ');
                            generatedItinerary += '</td>';
                        }

                        //Appointment Host

                        if (appointmentsHaveHost) {
                            generatedItinerary += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000; padding-top:5px; padding-bottom:10px; padding-left:15px;">';

                            if (!String.isBlank(allAppointments[i].Event_Host__r.Course_Name__c)) {
                                generatedItinerary += allAppointments[i].Event_Host__r.Course_Name__c + '<br/>';
                            }
                            if (!String.isBlank(allAppointments[i].Host_Name__c)) {
                                generatedItinerary += allAppointments[i].Host_Name__c + '<br/>';
                            }
                            if (!String.isBlank(allAppointments[i].Host_Location__c)) {
                                generatedItinerary += allAppointments[i].Host_Location__c + '<br/>';
                            }
                            generatedItinerary = generatedItinerary.removeEnd('<br/>');
                            generatedItinerary = generatedItinerary += '</td>';
                        }

                        //Appointment Location
                        if (appointmentsHaveLocation) {
                            generatedItinerary += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000; padding-top:5px; padding-bottom:10px; padding-left:15px;">';
                            if (!String.isBlank(allAppointments[i].Building__c)) {
                                generatedItinerary += allAppointments[i].Building__c + '<br/>';
                            }
                            if (!String.isBlank(allAppointments[i].Room__c)) {
                                generatedItinerary += allAppointments[i].Room__c + '<br/>';
                            }
                            generatedItinerary = generatedItinerary.removeEnd('<br/>');
                            generatedItinerary += '</td>';
                        }

                        generatedItinerary += '</tr>';
                    }


                    // add all requested appointments
                    if (allAppointments[i].Chosen_State__c != 'Added but not shown') {
                        generatedAppointment += '<tr>';

                        if (appointmentsHaveTime) {
                            generatedAppointment += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000; padding-top:5px; padding-bottom:10px; padding-right:15px; ">';
                            if (!allAppointments[i].Do_Not_Show_Time__c) {
                                if (!String.isBlank(allAppointments[i].Appointment_Time_Formatted__c)) {
                                    generatedAppointment += allAppointments[i].Appointment_Time_Formatted__c.replace(' ', '&nbsp;');
                                }
                            }
                            generatedAppointment += '</td>';
                        }

                        //Appointment Description
                        generatedAppointment += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000;  padding-top:5px; padding-bottom:10px; ">';


                        generatedAppointment += allAppointments[i].Appointment_Title__c;
                        *//* + ' - ';
                    if (!String.isBlank(AllAPpts[i].Description__c)) {
                        generatedAppts += AllAPpts[i].Description__c + ' - ';
                    }
                    generatedAppts = generatedAppts.removeEnd(' - ');
                    *//*


                        generatedAppointment += '</td>';

                        generatedAppointment += '</tr>';


                        lastId = allAppointments[i].Event_Registration__r.Id;
                    }

                }


                if (!String.isBlank(generatedItinerary)) {
                    generatedItinerary = '<table border="0" cellpadding="10" cellspacing="0"><tr>' + tableHead + tableHead2 + '</tr>' + generatedItinerary + '</table>';
                }

                if (!String.isBlank(generatedAppointment)) {
                    generatedAppointment = '<table>' + generatedAppointment + '</table>';
                }

                newItineraryRegs.add(new Summit_Events_Registration__c(Id = allAppointments[allAppointments.size() - 1].Event_Registration__r.Id, Generated_Itinerary__c = generatedItinerary, Generated_Requested_Appointments__c = generatedAppointment));
            }

            if (newItineraryRegs.size() > 0) {
                doCRUD CRUDtoDo = new doCRUD();
                CRUDtoDo.updateRegistration(newItineraryRegs);
            }

            */
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