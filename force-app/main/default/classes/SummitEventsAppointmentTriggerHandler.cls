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

        If (uniqueRegistrationIds.size() > 0) {
            allAppointments = [
                    SELECT Id, Name, Appointment_Time__c, Appointment_Time_Formatted__c, Event_Registration__r.Id, Event_Registration__r.Event_Name__c, Appointment_Status__c,
                            Faculty_Staff_Member__c, Appointment_Title__c, Event_Host__c, Host_Name__c, Event_Host__r.Assigned__c,
                            Host_Location__c, Building__c, Room__c, Event_Host__r.Time__c, Event_Host__r.Course_Name__c, Event_Host__r.RecordType.Name,
                            Chosen_State__c, Description__c, Do_Not_Show_Time__c, Sort_Order__c, Appointment_Virtual_Meeting_URL__c
                    FROM Summit_Events_Appointments__c
                    WHERE Event_Registration__r.Id IN :uniqueRegistrationIds
                    ORDER BY Appointment_Time__c ASC, Event_Host__r.Time__c ASC, Sort_Order__c, Appointment_Title__c ASC

                    //TODO: If there is no time on the appointment and there is host time use the host time.
            ];


            List<Summit_Events_Registration__c> newItineraryRegs = new List<Summit_Events_Registration__c>();

            String generatedItinerary = '';
            String generatedAppointment = '';
            String tableHead = '';
            String tableHead2 = '';
            //Is there time in any of the itinerary so we should show the time column?
            Boolean appointmentsHaveTime = false;
            Boolean appointmentsHaveLocation = false;
            Boolean appointmentsHaveHost = false;
            Boolean appointmentsHaveMeet = false;


            if (allAppointments.size() > 0) {
                Map<Id, List<Summit_Events_Appointments__c>> appointmentListByRegistration = new Map<Id, List<Summit_Events_Appointments__c>>();
                for (Summit_Events_Appointments__c appointment : allAppointments) {
                    if (appointmentListByRegistration.containsKey(appointment.Event_Registration__r.Id)) {
                        List<Summit_Events_appointments__c> preexistingAppointments = appointmentListByRegistration.get(appointment.Event_Registration__c);
                        preexistingAppointments.add(appointment);
                        appointmentListByRegistration.put(appointment.Event_Registration__c, preexistingAppointments);

                    } else {
                        List<Summit_Events_Appointments__c> newAppointments = new List<Summit_Events_Appointments__c>();
                        newAppointments.add(appointment);
                        appointmentListByRegistration.put(appointment.Event_Registration__c, newAppointments);
                    }
                }

                if(appointmentListByRegistration.size() > 0) {
                    List<Summit_Events_Registration__c> registrationsWithItineraries = new List<Summit_Events_Registration__c>();
                    for(List<Summit_Events_Appointments__c> registrationAppointments : appointmentListByRegistration.values()) {
                        if (registrationAppointments.size() >0) {
                            Summit_Events_Registration__c registration = new Summit_Events_Registration__c();
                            registration.Id = registrationAppointments[0].Event_Registration__c;
                            String requestedAppointments = '';
                            String confirmedAppointments = '';
                            for (Summit_Events_Appointments__c apt : registrationAppointments) {

                            }
                            registration.Generated_Itinerary__c = confirmedAppointments;
                            registration.Generated_Requested_Appointments__c = requestedAppointments;
                            registrationsWithItineraries.add(registration);
                        }
                    }

                }


                // Generate itinaries

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
                        /* + ' - ';
                    if (!String.isBlank(AllAPpts[i].Description__c)) {
                        generatedAppts += AllAPpts[i].Description__c + ' - ';
                    }
                    generatedAppts = generatedAppts.removeEnd(' - ');
                    */


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
        }

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