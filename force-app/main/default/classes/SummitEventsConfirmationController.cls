// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 5/1/2018.

public with sharing class SummitEventsConfirmationController {
    public SummitEventsShared seaShared = new SummitEventsShared();
    public SummitEventsShared.SummitEventsInfo eventInformation { get; set; }
    public Summit_Events__c eventPage { get; set; }
    public Summit_Events_Instance__c eventInstance { get; set; }
    public String templateSelected { get; set; }
    public String formattedNavDate { get; set; }
    public Boolean eventIsClosed { get; set; }
    public Boolean adminOpen { get; set; }

    public class guestJSONMap {
        String First_name { get; set; }
        String Last_name { get; set; }
        String Email { get; set; }
        String Relationship { get; set; }
        String Address { get; set; }
        String City { get; set; }
        String State { get; set; }
        String Zip { get; set; }
        String Country { get; set; }
        String Preferred_first_name { get; set; }
        String Name_tag { get; set; }
    }

    public SummitEventsConfirmationController() {
        eventIsClosed = false;
        eventInformation = seaShared.getSummitEventsInfo();

        if (!String.isEmpty(eventInformation.eventId)) {
            eventPage = [
                    SELECT Event_Confirmation_Title__c, Event_Name__c, Template__c, Event_Confirmation_Description__c, Event_Footer__c,
                            Event_Home_Link_Title__c, Event_Home_Link_URL__c, Tracking_Confirmation_Registration__c, Event_Full_Text__c,
                            Close_Event_Days_Before__c, Keep_Registration_Open_During_Event__c,
                            Hand_Raise_Action__c
                    FROM Summit_Events__c
                    WHERE Id = :eventInformation.eventId
                    WITH SECURITY_ENFORCED
            ];

            templateSelected = seaShared.getTemplate(eventPage.Template__c);

            eventInstance = [
                    SELECT Instance_Title__c, Event__r.Event_Name__c, Instance_Time_Zone__c, Instance_Start_Time__c, Instance_End_Time__c,
                            Instance_Start_Date__c, Instance_End_Date__c, Current_Available_Capacity__c, Active_Status__c
                    FROM Summit_Events_Instance__c
                    WHERE Id = :eventInformation.instanceId
                    LIMIT 1
            ];

            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('adminopen'))) {
                adminOpen = Boolean.valueOf(ApexPages.currentPage().getParameters().get('adminopen'));
                eventIsClosed = adminOpen;
            } else {
                eventIsClosed = seaShared.isEventClosed(eventPage, eventInstance);
            }

            formattedNavDate = seaShared.navBreadcrumbBuilder(eventInstance);
        }

    }

    public void checkEventDetails() {
        eventInformation = seaShared.getSummitEventsInfo();

        if (!eventIsClosed) {
            String eventTitle = '';
            if (!String.isBlank(eventInformation.registrationId)) {
                Summit_Events_Registration__c eventsRegistration = [
                        SELECT Id, Status__c, Event_Name__c, Event_Instance_Title__c, Guest_JSON__c
                        FROM Summit_Events_Registration__c
                        WHERE Id = :eventInformation.registrationId
                        WITH SECURITY_ENFORCED
                ];

                if (!String.isBlank(eventsRegistration.Event_Instance_Title__c)) {
                    eventTitle = eventsRegistration.Event_Name__c + ' - ' + eventsRegistration.Event_Instance_Title__c ;
                } else {
                    eventTitle = eventsRegistration.Event_Name__c;
                }
                eventsRegistration.Status__c = 'Registered';


                List<Summit_Events_Registration__c> guestRegistrations = new List<Summit_Events_Registration__c>();
                if (String.isNotBlank(eventsRegistration.Guest_JSON__c)) {
                    List<guestJSONMap> guests = (List<guestJSONMap>) JSON.deserialize(eventsRegistration.Guest_JSON__c, List<guestJSONMap>.class);
                    for (guestJSONMap guest : guests) {
                        Summit_Events_Registration__c guestRegistration = new Summit_Events_Registration__c();
                        guestRegistration.Event__c = eventInformation.eventId;
                        guestRegistration.Event_Instance__c = eventInformation.instanceId;
                        guestRegistration.Status__c = 'Registered';
                        guestRegistration.Guest_Host_Status__c = 'Hosted registrant';
                        guestRegistration.Guest_Host__c = eventInformation.registrationId;
                        if (String.isNotBlank(guest.First_name)) {
                            guestRegistration.Registrant_First_Name__c = String.escapeSingleQuotes(guest.First_name.unescapeHtml4());
                        }
                        if (String.isNotBlank(guest.Last_name)) {
                            guestRegistration.Registrant_Last_Name__c = String.escapeSingleQuotes(guest.Last_name.unescapeHtml4());
                        }
                        if (String.isNotBlank(guest.Email)) {
                            String emailIn = String.escapeSingleQuotes(guest.Email.unescapeHtml4());
                            if (validateEmail(emailIn)) {
                                guestRegistration.Registrant_Email__c = emailIn;
                            }
                        }
                        if (String.isNotBlank(guest.Relationship)) {
                            guestRegistration.Registrant_Other_Relationship__c = String.escapeSingleQuotes(guest.Relationship.unescapeHtml4());
                        }
                        if (String.isNotBlank(guest.Address)) {
                            guestRegistration.Registrant_Street_1__c = String.escapeSingleQuotes(guest.Address.unescapeHtml4());
                        }

                        if (String.isNotBlank(guest.City)) {
                            guestRegistration.Registrant_City__c = String.escapeSingleQuotes(guest.City.unescapeHtml4());
                        }

                        if (String.isNotBlank(guest.Zip)) {
                            guestRegistration.Registrant_Zip__c = String.escapeSingleQuotes(guest.Zip.unescapeHtml4());
                        }

                        if (String.isNotBlank(guest.Name_tag)) {
                            guestRegistration.Registrant_Name_Tag__c = String.escapeSingleQuotes(guest.Name_tag.unescapeHtml4());
                        }

                        if(String.isNotBlank(guest.Preferred_first_name)) {
                            guestRegistration.Registrant_Preferred_First_Name__c = String.escapeSingleQuotes(guest.Preferred_first_name.unescapeHtml4());
                        }

                        if(String.isNotBlank(guest.State)) {
                            guestRegistration.Registrant_State__c = String.escapeSingleQuotes(guest.State.unescapeHtml4());
                        }

                        guestRegistrations.add(guestRegistration);
                    }
                }

                String encryptedString = SEAShared.createEncryptedCookie(eventInformation.audience, eventInformation.instanceId, eventInformation.eventId, eventInformation.registrationId);

                System.debug(encryptedString);
                if (encryptedString.length() > 255) {
                    System.debug('bigger than 255');
                    eventsRegistration.Encrypted_Registration_Id_1__c = encryptedString.substring(0, 255);
                    eventsRegistration.Encrypted_Registration_Id_2__c = encryptedString.substring(255, encryptedString.length());
                } else {
                    System.debug('less than 255');
                    eventsRegistration.Encrypted_Registration_Id_1__c = encryptedString;
                }

                registrationCRUD regCRUD = new registrationCRUD();
                eventsRegistration = regCRUD.updateRegistration(eventsRegistration);

                if (guestRegistrations.size() > 0) {
                    regCRUD.addGuestRegistration(guestRegistrations);
                }

                SummitEventsShared SEAShared = new SummitEventsShared();

                //Remove the registration ID from the cookie so back button will redirect to the correct page.
                seaShared.createEncryptedCookie(eventInformation.audience, eventInformation.instanceId, eventInformation.eventId, '');


            }
        }
    }

    public static Boolean validateEmail(String email) {
        Boolean isEmail = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        if (!MyMatcher.matches()) {
            isEmail = false;
        }
        return isEmail;
    }


    /**
     * Summit Events is a multi-step, guest user, registration solution so CRUD work needs to be done on records where guest record ownership is lost between steps.
     * The security aspects of guest record updating is achieved by:
     * - Using an encrypted cookie on the client browser to keep track of registration id, event id, instance id, and audience
     * - Dividing each controller class into a "with sharing" logic area and a sub "without sharing" CRUD area for purposeful CRUD
     * - When the encrypted cookie is not available as in the cancel registration link an encrypted string is provided through the URL to not expose the SF ID related to the record
     **/

    private without sharing class registrationCRUD {

        public Summit_Events_Registration__c updateRegistration(Summit_Events_Registration__c newEvtReg) {
            try {
                update newEvtReg;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }
            return newEvtReg;
        }

        public void addGuestRegistration(List<Summit_Events_Registration__c> guestRegistrations) {
            try {
                insert guestRegistrations;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage()));
            }

        }
    }
}