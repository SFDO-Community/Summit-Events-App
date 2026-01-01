// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on  1/1/2026.

public with sharing class SummitEventsLWCController {

    //Build wrapper classes to send to LWC
    public class SummitEventWrapper {
        @AuraEnabled public Summit_Events_Registration__c registration { get; set; }
        @AuraEnabled public Summit_Events_Instance__c instance { get; set; }
        @AuraEnabled public Summit_Events__c eventInfo { get; set; }
        @AuraEnabled public Map<Id, Summit_Events_Appointment_Type__c> appointmentTypes { get; set; }
        @AuraEnabled public List<Summit_Events_Appointments__c> appointments { get; set; }
        @AuraEnabled public List<SummitEventsQuestionWrapper> questions { get; set; }
    }

    public class SummitEventsQuestionWrapper {
        //Booleans for LWC to render correct question type
        @AuraEnabled public Boolean isTextArea { get; set; }
        @AuraEnabled public Boolean isTextBox { get; set; }
        @AuraEnabled public Boolean isRadio { get; set; }
        @AuraEnabled public Boolean isCheckbox { get; set; }
        @AuraEnabled public Boolean isPicklist { get; set; }
        @AuraEnabled public List<picklistOption> picklistValues { get; set; }
        @AuraEnabled public Boolean isMultiSelect { get; set; }
        @AuraEnabled public Boolean isAddress { get; set; }
        @AuraEnabled public Boolean isPhone { get; set; }
        @AuraEnabled public Boolean isEmail { get; set; }
        @AuraEnabled public Boolean isLookup { get; set; }
        @AuraEnabled public String mapToField { get; set; }
        @AuraEnabled public String questionText { get; set; }
        @AuraEnabled public String questionHelpText { get; set; }
    }

    public class picklistOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
    }

    @AuraEnabled(Cacheable=true)
    public static SummitEventWrapper getSummitEventData(Id eventInstanceId, Id registrationId) {
        SummitEventWrapper wrapper = new SummitEventWrapper();
        wrapper.registration = new Summit_Events_Registration__c();
        wrapper.appointments = new List<Summit_Events_Appointments__c>();
        wrapper.instance = SummitEventsReadShared.getInstanceById(eventInstanceId);
        Id eventId = wrapper.instance.Event__c;
        String dayOfWeek = SummitEventsShared.convertDateToDatetime(wrapper.instance.Instance_Start_Date__c, null, '').format('EEEE');
        wrapper.eventInfo = SummitEventsReadShared.getEventById(eventId);
        wrapper.appointmentTypes = SummitEventsReadShared.getAppointmentTypesByEventId(eventId,  wrapper.instance.Instance_Title__c, wrapper.instance.Instance_Start_Date__c, wrapper.instance.Instance_End_Date__c, dayOfWeek);

        //Get the question object questions
        List<String> registrantTypes = new List<String>{
                'Registrant', 'Registrant and Guest'
        };
        Map<Id, Summit_Events_Question__c> questions = SummitEventsReadShared.getAdditionalQuestionsByEventId(eventId, registrantTypes);




        return wrapper;
    }

}
