/**
 * Created by dahl3702 on 4/30/2019.
 */

global class USTEventAppointmentItinerary_TDTM extends hed.TDTM_Runnable {
    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        hed.TDTM_Runnable.dmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();

        if (triggerAction == hed.TDTM_Runnable.Action.AfterInsert || triggerAction == hed.TDTM_Runnable.Action.AfterUpdate
                || triggerAction == hed.TDTM_Runnable.Action.AfterDelete || triggerAction == hed.TDTM_Runnable.Action.AfterUndelete ) {

            //Create a mapped list of unique ids
            List<UST_Event_Appointments__c> AllAppts = new List<UST_Event_Appointments__c>();
            Map<String, String> uniqueRegIds = new Map<String, String>();

            if (newlist != null) {
                for (UST_Event_Appointments__c na : (List<UST_Event_Appointments__c>) newlist) {
                    uniqueRegIds.put(na.Event_Registration__c, na.Event_Registration__c);
                }
            }

            if (oldlist != null) {
                for (UST_Event_Appointments__c oa : (List<UST_Event_Appointments__c>)oldlist) {
                    if (String.isNotBlank(oa.Event_Registration__c) && !uniqueRegIds.containsKey(oa.Event_Registration__c)) {
                        uniqueRegIds.put(oa.Event_Registration__c, oa.Event_Registration__c);
                    }
                }
            }


            AllAppts = [
                    SELECT Id, Name, Appointment_Time__c, Appointment_Time_Formatted__c, Event_Registration__r.Id, Event_Registration__r.Event_Name__c, Appointment_Status__c,
                            Faculty_Staff_Member__c, Appointment_Title__c, Event_Host__c, Host_Name__c, Event_Host__r.Assigned__c,
                            Host_Location__c, Building__c, Room__c, Event_Host__r.Time__c, Event_Host__r.Course_Name__c, Event_Host__r.RecordType.Name,
                            Chosen_State__c, Event_Registration__r.Event__r.RecordType.Name, Description__c, Do_Not_Show_Time__c
                    FROM UST_Event_Appointments__c
                    WHERE Event_Registration__r.Id IN :uniqueRegIds.values()
                    ORDER BY Appointment_Time__c ASC, Event_Host__r.Time__c ASC, Appointment_Title__c ASC

                    //TODO: If there is no time on the appointment and there is host time use the host time.
            ];

            List<UST_Event_Registration__c> newItineraryRegs = new List<UST_Event_Registration__c>();

            String generatedItinerary = '';
            String generatedAppts = '';
            String tableHead = '';
            String tableHead2 = '';
            Boolean isOvernight = false;


            if (AllAppts.size() > 0) {

                //check if this is an undergrad overnight
                if (AllAppts[0].Event_Registration__r.Event_Name__c.contains('Overnight') &&
                        (AllAppts[0].Event_Registration__r.Event__r.RecordType.Name == 'Undergraduate' || String.isBlank(AllAppts[0].Event_Registration__r.Event__r.RecordType.Name))) {

                    isOvernight = true;
                }
                // Generate itinaries

                //Is there time in any of the itinerary so we should show the time column?
                Boolean appointmentsHaveTime = false;
                Boolean appointmentsHaveLocation = false;
                Boolean appointmentsHaveHost = false;
                for (UST_Event_Appointments__c apptTime : AllAppts) {
                    if (!String.isBlank(apptTime.Appointment_Time_Formatted__c) && !apptTime.Do_Not_Show_Time__c) {
                        appointmentsHaveTime = true;
                    }
                    if (!String.isBlank(apptTime.Building__c) ||
                            !String.isBlank(apptTime.Room__c)) {
                        appointmentsHaveLocation = true;
                    }
                    if (!String.isBlank(apptTime.Host_Name__c) || !String.isBlank(apptTime.Host_Location__c)) {
                        appointmentsHaveHost = true;
                    }
                }


                if (appointmentsHaveTime) {
                    tableHead += '<th align="left" style="text-align:left; font-family:arial; font-size:12pt; color:#000000;">Time</th>';
                }
                tableHead += '<th align="left" style="text-align:left; font-family:arial; font-size:12pt; color:#000000;">Description</th>';
                if (appointmentsHaveHost) {
                    tableHead2 += '<th align="left" style="text-align:left; font-family:arial; font-size:12pt; color:#000000;">Host</th>';
                }
                if (appointmentsHaveLocation) {
                    tableHead2 += '<th align="left" style="text-align:left; font-family:arial; font-size:12pt; color:#000000;">Location</th>';
                }

                String lastID = AllAppts[0].Id;
                for (Integer i = 0; i < AllAppts.size(); i++) {

                    // add all confirmed appointments
                    if (allAppts[i].Appointment_Status__c == 'Confirmed') {
                        generatedItinerary += '<tr>';

                        //Appointment Time
                        if (appointmentsHaveTime) {
                            generatedItinerary += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000; padding-top:5px; padding-bottom:10px; padding-right:15px;">';
                            if (!AllAppts[i].Do_Not_Show_Time__c) {
                                if (!String.isBlank(AllAppts[i].Appointment_Time_Formatted__c)) {
                                    generatedItinerary += AllAppts[i].Appointment_Time_Formatted__c.replace(' ', '&nbsp;');
                                }
                            }
                            generatedItinerary += '</td>';
                        }

                        //Appointment Description
                        generatedItinerary += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; padding-top:5px; padding-bottom:10px; color:#000000;">';
                        generatedItinerary += AllAppts[i].Appointment_Title__c + ' - ';
                        if (!String.isBlank(AllAPpts[i].Description__c) && !isOvernight) {
                            generatedItinerary += AllAPpts[i].Description__c + ' - ';
                        }
                        generatedItinerary = generatedItinerary.removeEnd(' - ');
                        generatedItinerary += '</td>';

                        //Appointment Host
                        if (isOvernight) {
                            if (appointmentsHaveHost || appointmentsHaveLocation) {
                                generatedItinerary += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000; padding-top:5px; padding-bottom:10px; padding-left:15px;">';
                                if (appointmentsHaveHost) {
                                    if (!String.isBlank(AllAppts[i].Event_Host__r.Course_Name__c)) {
                                        generatedItinerary += AllAppts[i].Event_Host__r.Course_Name__c + '<br/>';
                                    }
                                    if (!String.isBlank(AllAppts[i].Host_Name__c)) {
                                        generatedItinerary += AllAppts[i].Host_Name__c + '<br/>';
                                    }
                                    if (!String.isBlank(AllAppts[i].Host_Location__c)) {
                                        generatedItinerary += AllAppts[i].Host_Location__c + '<br/>';
                                    }
                                    generatedItinerary = generatedItinerary.removeEnd('<br/>');
                                }

                                //Appointment Location
                                if (appointmentsHaveLocation && !appointmentsHaveHost) {
                                    if (!String.isBlank(AllAppts[i].Building__c)) {
                                        generatedItinerary += AllAppts[i].Building__c + '<br/>';
                                    }
                                    if (!String.isBlank(AllAppts[i].Room__c)) {
                                        generatedItinerary += AllAppts[i].Room__c + '<br/>';
                                    }
                                    generatedItinerary = generatedItinerary.removeEnd('<br/>');
                                }
                                generatedItinerary += '</td>';
                            }
                        } else {
                            if (appointmentsHaveHost) {
                                generatedItinerary += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000; padding-top:5px; padding-bottom:10px; padding-left:15px;">';

                                if (!String.isBlank(AllAppts[i].Event_Host__r.Course_Name__c)) {
                                    generatedItinerary += AllAppts[i].Event_Host__r.Course_Name__c + '<br/>';
                                }
                                if (!String.isBlank(AllAppts[i].Host_Name__c)) {
                                    generatedItinerary += AllAppts[i].Host_Name__c + '<br/>';
                                }
                                if (!String.isBlank(AllAppts[i].Host_Location__c)) {
                                    generatedItinerary += AllAppts[i].Host_Location__c + '<br/>';
                                }
                                generatedItinerary = generatedItinerary.removeEnd('<br/>');
                                generatedItinerary = generatedItinerary += '</td>';
                            }

                            //Appointment Location
                            if (appointmentsHaveLocation) {
                                generatedItinerary += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000; padding-top:5px; padding-bottom:10px; padding-left:15px;">';
                                if (!String.isBlank(AllAppts[i].Building__c)) {
                                    generatedItinerary += AllAppts[i].Building__c + '<br/>';
                                }
                                if (!String.isBlank(AllAppts[i].Room__c)) {
                                    generatedItinerary += AllAppts[i].Room__c + '<br/>';
                                }
                                generatedItinerary = generatedItinerary.removeEnd('<br/>');
                                generatedItinerary += '</td>';
                            }
                        }
                        generatedItinerary += '</tr>';
                    }


                    // add all requested appointments
                    if (AllAppts[i].Chosen_State__c != 'Added but not shown') {
                        generatedAppts += '<tr>';

                        if (appointmentsHaveTime) {
                            generatedAppts += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000; padding-top:5px; padding-bottom:10px; padding-right:15px; ">';
                            if (!AllAppts[i].Do_Not_Show_Time__c) {
                                if (!String.isBlank(AllAppts[i].Appointment_Time_Formatted__c)) {
                                    generatedAppts += AllAppts[i].Appointment_Time_Formatted__c.replace(' ', '&nbsp;');
                                }
                            }
                            generatedAppts += '</td>';
                        }

                        //Appointment Description
                        generatedAppts += '<td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000;  padding-top:5px; padding-bottom:10px; ">';

                        if (isOvernight) {
                            generatedAppts += AllAppts[i].Appointment_Title__c;
                        } else {
                            generatedAppts += AllAppts[i].Appointment_Title__c;
                            /* + ' - ';
                            if (!String.isBlank(AllAPpts[i].Description__c)) {
                                generatedAppts += AllAPpts[i].Description__c + ' - ';
                            }
                            generatedAppts = generatedAppts.removeEnd(' - ');
                            */
                        }

                        generatedAppts += '</td>';

                        generatedAppts += '</tr>';


                        lastId = AllAppts[i].Event_Registration__r.Id;
                    }

                }


                if (!String.isBlank(generatedItinerary)) {
                    if (isOvernight) {
                        generatedItinerary = '<table border="0" cellpadding="10" cellspacing="0">' + generatedItinerary + '</table>';
                    } else {
                        generatedItinerary = '<table border="0" cellpadding="10" cellspacing="0"><tr>' + tableHead + tableHead2 + '</tr>' + generatedItinerary + '</table>';
                    }

                }

                if (!String.isBlank(generatedAppts)) {
                    generatedAppts = '<table>' + generatedAppts + '</table>';
                }

                newItineraryRegs.add(new UST_Event_Registration__c(id = AllAppts[AllAppts.size() - 1].Event_Registration__r.Id, Generated_Itinerary__c = generatedItinerary, Generated_Requested_Appointments__c = generatedAppts));
            }

            upsert newItineraryRegs;
        }

        return dmlWrapper;
    }
}