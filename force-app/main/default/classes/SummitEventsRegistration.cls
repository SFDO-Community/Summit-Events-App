public class SummitEventsRegistration {

// create String formula field Summit_Events_Registration__c.Email_Key__c = EventId + '|' + Status + '|'' Substatus
// and similar for Summit_Events_Email__c.Email_Key__c

    public static void addToRegistrationsMap(Map<String,List<Summit_Events_Registration__c>> mapOfLists,
            Summit_Events_Registration__c itemToAdd) {
        String key = itemToAdd.Email_Key__c;
        if (! mapOfLists.containsKey(key)) {
            mapOfLists.put(key, new List<Summit_Events_Registration__c>{ itemToAdd });
        } else {
        (mapOfLists.get(key)).add(itemToAdd);
        }
    }

    public static void handleIsAfterInsertOrUpdateTrigger(List<Summit_Events_Registration__c> newRegistrations, Map<Id,Summit_Events_Registration__c> oldRegistrationsMap) {

        Map<String,List<Summit_Events_Registration__c>> registrationsByEmailKey = new Map<String,List<Summit_Events_Registration__c>>();
        Boolean isInsert = oldRegistrationsMap == null;

        for (Summit_Events_Registration__c r : newRegistrations) {
            if (isInsert) { 
                addToRegistrationsMap(registrationsByEmailKey, r);
            }
            else { // updates; check for status or substatus changes
                Summit_Events_Registration__c oldReg = oldRegistrationsMap.get(r.Id);
                // might need to recalculate formula fields before comparing them
                if (r.Email_Key__c != oldReg.Email_Key__c) {
                    addToRegistrationsMap(registrationsByEmailKey, r);
                }
            }
        }

        //Get any templates for events that have restistration status changes
        List<Summit_Events_Email__c> matchEmail = [
                SELECT Email_Key__c, Email_Template__c, Org_Email_Id__c, BCC_Email__c
                FROM Summit_Events_Email__c
                WHERE Email_Key__c IN :registrationsByEmailKey.keySet()
                AND Action_status__c != null
                AND Action_Status__c != '--Inactive--'
        ];

        Map<String,List<Summit_Events_Email__c>> emailsByEmailKey = new Map<String,List<Summit_Events_Email__c>>();
        for (Summit_Events_Email__c itemToAdd : matchEmail) {
            String key = itemToAdd.Email_Key__c;
            if (! emailsByEmailKey.containsKey(key)) {
                emailsByEmailKey.put(key, new List<Summit_Events_Email__c>{ itemToAdd });
            } else {
            (emailsByEmailKey.get(key)).add(itemToAdd);
            }
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        //loop through affected event registrations - have status change from old
        for (String emailKey : registrationsByEmailKey.keySet()) {

            for (Summit_Events_Email__c em : emailsByEmailKey.get(emailKey)) {
                List<String> bccList = new List<String>();
                if (!String.isBlank(em.BCC_Email__c)) {
                    String BCCString = em.BCC_Email__c.deleteWhitespace().replace(';',',');
                    bccList = BCCString.split(',');
                }
                Boolean hasBCC = bccList.size() > 0;
                for (Summit_Events_Registration__c areg : registrationsByEmailKey.get(emailKey)) {
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(areg.Contact__c); // only used for activity
                    message.setTreatTargetObjectAsRecipient(false);
                    message.setWhatId(areg.Id); //This is important for the merge fields in template to work
                    message.setTemplateId(em.Email_Template__c); 
                    message.setOrgWideEmailAddressId(em.Org_Email_Id__c);
                    message.setUseSignature(false); 
                    message.setBccSender(false); 
                    message.setSaveAsActivity(areg.Contact__c != null); // saves email on Contact
                    message.setToAddresses(new String[] { areg.Registrant_Email__c });
                    if (hasBCC) {
                        message.setBccAddresses(bccList);
                    }
                    /* another approach:
                    Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(em.Email_Template__c, null, areg.Id);
                    message.toAddresses = toAddressList;
                    NOTE: you can't use setSaveAsActivity(true) if you set whoId to null
                    */
                    emails.add(message);
                }
            }
        }

        if(emails.size() > 0) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails,false);
            // System.debug any errors?
        }
    }

    private without sharing class doCRUD {

        public void savTask(List<Task> taskToSave) {
            try {
                insert taskToSave;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}