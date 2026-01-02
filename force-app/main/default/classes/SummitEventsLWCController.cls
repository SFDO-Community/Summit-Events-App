// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on  1/1/2026.

public with sharing class SummitEventsLWCController {

    //Build wrapper classes to send to LWC
    public class SummitEventWrapper {
        @AuraEnabled public List<page> pages { get; set; }
        @AuraEnabled public Integer currentPageIndex { get; set; }
        @AuraEnabled public registration primaryRegistration { get; set; }
        @AuraEnabled public List<registration> guestRegistrations { get; set; }
        @AuraEnabled public Summit_Events_Instance__c instance { get; set; }
        @AuraEnabled public Summit_Events__c eventInfo { get; set; }
        @AuraEnabled public Map<Id, Summit_Events_Appointment_Type__c> appointmentTypes { get; set; }
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
        @AuraEnabled public Boolean isStaticText { get; set; }
        @AuraEnabled public Boolean isStaticHeader { get; set; }
        @AuraEnabled public Boolean isStaticFooter { get; set; }
        @AuraEnabled public String mapToField { get; set; }
        @AuraEnabled public String questionText { get; set; }
        @AuraEnabled public String questionHelpText { get; set; }
    }

    public class registration {
        @AuraEnabled public Summit_Events_Registration__c registrationRecord { get; set; }
        @AuraEnabled public List<Summit_Events_Appointments__c> appointments { get; set; }
    }

    public class picklistOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
    }

    public class page {
        @AuraEnabled public Integer pageIndex { get; set; }
        @AuraEnabled public String pageName { get; set; }
        @AuraEnabled public String pageMetaTitle { get; set; }
        @AuraEnabled public String pageHeading { get; set; }
        @AuraEnabled public String pageSubheading { get; set; }
        @AuraEnabled public String pageContent { get; set; }
    }

    @AuraEnabled(Cacheable=true)
    public static SummitEventWrapper getSummitEventData(Id eventInstanceId, Id registrationId) {
        SummitEventWrapper wrapper = new SummitEventWrapper();

        wrapper.primaryRegistration = new registration();
        wrapper.primaryRegistration.registrationRecord = new Summit_Events_Registration__c();
        wrapper.primaryRegistration.appointments = new List<Summit_Events_Appointments__c>();

        wrapper.guestRegistrations = new List<registration>();

        wrapper.instance = SummitEventsReadShared.getInstanceById(eventInstanceId);
        Id eventId = wrapper.instance.Event__c;
        String dayOfWeek = SummitEventsShared.convertDateToDatetime(wrapper.instance.Instance_Start_Date__c, null, '').format('EEEE');
        wrapper.eventInfo = SummitEventsReadShared.getEventById(eventId);
        wrapper.appointmentTypes = SummitEventsReadShared.getAppointmentTypesByEventId(eventId, wrapper.instance.Instance_Title__c, wrapper.instance.Instance_Start_Date__c, wrapper.instance.Instance_End_Date__c, dayOfWeek);

        //Get the question object questions
        List<String> registrantTypes = new List<String>{
                'Registrant', 'Registrant and Guest'
        };
        Map<Id, Summit_Events_Question__c> questions = SummitEventsReadShared.getAdditionalQuestionsByEventId(eventId, registrantTypes);

        //Build question wrappers from both eventInfo and question object

        //Define pages
        wrapper.pages = new List<page>();
        page page1 = new page();
        page1.pageIndex = 0;
        page1.pageName = wrapper.eventInfo.Event_Name__c + ' Registration';
        page1.pageHeading = 'Event Registration';
        page1.pageContent = 'Please fill out the information below to register for the event.';
        wrapper.pages.add(page1);


        return wrapper;
    }

    private static List<page> buildPageInfo(Summit_Events__c eventInfo, Summit_Events_Instance__c eventInstance) {

        String dayOfWeek = SummitEventsShared.convertDateToDatetime(eventInstance.Instance_Start_Date__c, null, '').format('EEEE');
        Integer appointmentTypes = SummitEventsReadShared.getAppointmentTypeCount(eventInfo.Id, eventInstance.Instance_Title__c, eventInstance.Instance_Start_Date__c, eventInstance.Instance_End_Date__c, dayOfWeek);
        Integer additionalQuestions = SummitEventsReadShared.getAdditionalQuestionsCount(eventInfo.Id);
        Integer guestQuestions = SummitEventsReadShared.getGuestQuestionsCount(eventInfo.Id);

        List<page> pages = new List<page>();
        page page = new page();
        page.pageHeading = eventInfo.Event_Name__c;
        page.pageSubheading = eventInstance.Instance_Title__c;
        page.pageContent = eventInfo.Event_Full_Text__c;
        page.pageMetaTitle = eventInfo.Event_Home_Link_Title__c;

        return pages;
    }

}
