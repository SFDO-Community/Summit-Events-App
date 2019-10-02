/**
 * Created by dahl3702 on 9/17/2019.
 */

global class USTEventAppointmentSports_TDTM extends hed.TDTM_Runnable {

    global override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        hed.TDTM_Runnable.dmlWrapper dmlWrapper = new hed.TDTM_Runnable.DmlWrapper();

        Map<id, UST_Event_Appointments__c> newListMap = (newList != null) ? new Map<Id, UST_Event_Appointments__c>((List<UST_Event_Appointments__c>) newList) : new Map<Id, UST_Event_Appointments__c>() ;
        Map<id, UST_Event_Appointments__c> oldListMap = (oldlist != null) ? new Map<Id, UST_Event_Appointments__c>((List<UST_Event_Appointments__c>) oldList) : new Map<Id, UST_Event_Appointments__c>() ;

        if (triggerAction == hed.TDTM_Runnable.Action.AfterInsert) {
            List<Contact> sportsContacts = new List<Contact>();
            Map<Id, Id> athleticRegistrationIds = new Map<Id, Id>();
            for (Id nlm : newListMap.keySet()) {
                UST_Event_Appointments__c appointment = (UST_Event_Appointments__c) newListMap.get(nlm);
                //Get only appointments that are Athletic based
                if (appointment.Appointment_Category__c == 'Athletic Visit') {
                    athleticRegistrationIds.put(appointment.id, appointment.Event_Registration__c);
                }
            }
            if (athleticRegistrationIds.size() > 0) {
                Map<Id, UST_Event_Registration__c> sportsAffectedRegistrations = new Map<id, UST_Event_Registration__c>([
                        SELECT id, Contact__r.Id, Contact__r.Special_Athlete_Sport_1__c, Contact__r.Special_Athlete_Sport_2__c, Contact__r.Special_Athlete_Sport_3__c
                        FROM UST_Event_Registration__c
                        WHERE Id IN :athleticRegistrationIds.values()
                ]);
                if (sportsAffectedRegistrations.size() > 0) {

                    for (Id key : athleticRegistrationIds.keySet()) {
                        Id apptId = key;
                        Id regId = athleticRegistrationIds.get(key);
                        UST_Event_Appointments__c appt = (UST_Event_Appointments__c) newListMap.get(apptId);
                        UST_Event_Registration__c reg = (UST_Event_Registration__c) sportsAffectedRegistrations.get(regId);
                        if (reg.Contact__c != null) {
                            List<String> currentSports = new List<String>();
                            //put current sports into a List<String> so we can see if the array already contains the sport in question.
                            currentSports.add(reg.Contact__r.Special_Athlete_Sport_1__c);
                            currentSports.add(reg.Contact__r.Special_Athlete_Sport_2__c);
                            currentSports.add(reg.Contact__r.Special_Athlete_Sport_3__c);
                            if (!currentSports.contains(appt.Appointment_Type__c)) {
                                Boolean spaceFilled = false;
                                Contact sportContactIn = new Contact();
                                sportContactIn.Id = reg.Contact__r.Id;
                                if (String.isBlank(reg.Contact__r.Special_Athlete_Sport_1__c)) {
                                    sportContactIn.Special_Athlete_Sport_1__c = appt.Appointment_Type__c;
                                    spaceFilled = true;
                                } else if (String.isBlank(reg.Contact__r.Special_Athlete_Sport_2__c)) {
                                    sportContactIn.Special_Athlete_Sport_2__c = appt.Appointment_Type__c;
                                    spaceFilled = true;
                                } else if (String.isBlank(reg.Contact__r.Special_Athlete_Sport_3__c)) {
                                    sportContactIn.Special_Athlete_Sport_3__c = appt.Appointment_Type__c;
                                    spaceFilled = true;
                                }
                                if (spaceFilled) {
                                    sportsContacts.add(sportContactIn);
                                }
                            }
                        }
                    }
                }
                if (sportsContacts.size() > 0) {
                    upsert sportsContacts;
                }
            }
        }
        return dmlWrapper;
    }
}