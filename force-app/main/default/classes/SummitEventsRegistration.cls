public class SummitEventsRegistration {
    public static void run(List<SObject> newlist, List<SObject> oldlist) {

        Map<Id, Id> affectedIds = new Map<Id, Id>();
        Map<Id, Id> affectedContactIds = new Map<Id, Id>();
        List<Summit_Events_Registration__c> affectedRegs = new List<Summit_Events_Registration__c>();

        Map<Id, Summit_Events_Registration__c> oldListMap = new Map<Id, Summit_Events_Registration__c>();
        if (oldlist != null) {
            for (Summit_Events_Registration__c ol : (List<Summit_Events_Registration__c>) oldlist) {
                oldListMap.put(ol.Id, ol);
            }
        }

        for (Summit_Events_Registration__c r : (List<Summit_Events_Registration__c>) newlist) {

            //Get old Summit_Events_Registration__c by current ID
            Summit_Events_Registration__c oldReg = new Summit_Events_Registration__c(Status__c = 'new', Substatus__c = 'new');
            if (oldListMap.size() > 0) {
                if (r.Id != null) {
                    oldReg = oldListMap.get(r.Id);
                }
            }

            //Get all new trigger Summit_Events_Registration__c that have a status change by comparing old map
            if (String.isNotBlank(oldReg.Id)) {
                if (r.Status__c != oldReg.Status__c || r.Substatus__c != oldReg.Substatus__c) {
                    affectedIds.put(r.Event__c, r.Event__c);
                    affectedRegs.add(r);
                    if (r.Status__c == 'Confirmed' && r.Substatus__c == 'Attended') {
                        affectedContactIds.put(r.Id, r.Id);
                    }
                }
            } else {
                affectedIds.put(r.Event__c, r.Event__c);
                affectedRegs.add(r);
                if (r.Status__c == 'Confirmed' && r.Substatus__c == 'Attended') {
                    affectedContactIds.put(r.Id, r.Id);
                }
            }
        }

        //Get any templates for events that have restistration status changes
        List<Summit_Events_Email__c> matchEmail = [
                SELECT Action_Status__c, Action_Sub_status__c, Event__c, Letterhead_HTML__c, Email_Subject__c,
                        Email_Content__c, Letterhead_Id__c, Org_Email_Id__c, BCC_Email__c
                FROM Summit_Events_Email__c
                WHERE Event__r.Id IN :affectedIds.values()
                AND Action_Status__c != NULL
                AND Action_Status__c != '--Inactive--'
                WITH SECURITY_ENFORCED
        ];

        List<Task> activityUpdates = new List<Task>();

        //loop through affected event registrations - have status change from old
        for (Summit_Events_Registration__c areg : affectedRegs) {
            //Loop through gather email templates to get template and use registration fields to fill in hooks
            for (Summit_Events_Email__c em : matchEmail) {
                Boolean statusMatch = false;

                if (em.Event__c.equals(areg.Event__c)) {

                    statusMatch = false;

                    if (!String.isBlank(em.Action_Sub_status__c) && !String.isBlank(areg.Substatus__c)) {
                        if (em.Action_Sub_status__c.equals(areg.Substatus__c) && em.Action_Status__c.equalsIgnoreCase(areg.Status__c)) {
                            statusMatch = true;
                        }
                    } else if (em.Action_Status__c.equals(areg.Status__c) && String.isBlank(em.Action_Sub_status__c) && String.isBlank(areg.Substatus__c)) {
                        statusMatch = true;
                    }

                    if (statusMatch) {
                        //Get email template
                        String emailContent = em.Email_Content__c;
                        String originalTemplate = '[[DONT_DELETE_CONTENT_HERE]]';
                        if (!String.isBlank(em.Letterhead_HTML__c)) {
                            originalTemplate = em.Letterhead_HTML__c;
                        }

                        emailContent = emailContent.replace('$', '\\$');
                        //Regex to find all Apex delineators {! }
                        Pattern TAG_REGEX = Pattern.compile('\\{!(.+?)\\}');
                        Matcher matcher = TAG_REGEX.matcher(emailContent);
                        Map<String, String> foundTags = new Map<String, String>();

                        //loop through found hocks and add only unique
                        while (matcher.find()) {
                            foundTags.put(matcher.group(1), matcher.group(1));
                        }

                        for (String ft : foundTags.values()) {
                            //add only found hooks and recreate regex with more percise
                            Pattern TAG_REGEX2 = Pattern.compile('\\{!(' + ft + ')\\}');
                            Matcher matcher2 = TAG_REGEX2.matcher(emailContent);
                            while (matcher2.find()) {

                                //Get the value for hook from registration have to remove any registration object names since we are already in the object
                                String found = matcher2.group(1).replace('Summit_Events_Registration__c.', '');
                                try {
                                    found = String.valueOf(areg.get(found));
                                } catch (Exception e) {
                                    found = '';
                                }

                                //replaceAll doesn't like nulls
                                if (String.isBlank(found)) {
                                    found = '';
                                }
                                //replace all hooks with found values from regstration

                                if (matcher2.group(1) == 'UG_Parking_Pass_Link__c' || matcher2.group(1) == 'Add_To_Calendar_Link__c' || matcher2.group(1) == 'Event_Registration_Cancel_Link__c' || matcher2.group(1) == 'Add_to_Apple_Calendar__c' || matcher2.group(1) == 'Add_To_Google_Calendar_Link__c' || matcher2.group(1) == 'Add_to_Outlook_Calendar__c' || matcher2.group(1) == 'Add_To_Outlook_Web_Calendar__c' || matcher2.group(1) == 'Add_To_Yahoo_Calendar__c') {
                                    found = found.replace('_HL_ENCODED_', '<a href="');
                                    found = found.replace('_HL__blank_HL_', '</a>');
                                    found = found.replace('_HL_', ' target="_blank">');
                                    found = found.replace(' target=', '');
                                }

                                emailContent = matcher2.replaceAll(found);
                            }
                        }

                        //put email content (after hooks have been replaced with values) into the email template
                        originalTemplate = originalTemplate.replaceAll('\\[\\[DONT_DELETE_CONTENT_HERE\\]\\]', emailContent);

                        //send the message
                        sendEmail2(areg.Registrant_Email__c, originalTemplate, emailContent, em.Email_Subject__c, em.Org_Email_Id__c, em.BCC_Email__c);

                        //Create an activity task
                        Task nt = new Task();
                        nt.WhatId = areg.Id;
                        nt.WhoId = areg.Contact__c;
                        nt.Type = 'Email';
                        nt.ActivityDate = Date.today();
                        nt.Subject = 'Event status email: ' + em.Action_Status__c + ' - ' + em.Email_Subject__c;
                        nt.Status = 'Completed';
                        nt.Priority = 'Low';

                        nt.Description = emailContent.replaceAll('</p>', '\n'); // Replaces </p> (the paragraph closing tag) with a line break, since it is functionally identical to a line break
                        nt.Description = nt.Description.replaceAll('<(.*?)>', ''); // Replaces angled brackets and everything between with an empty string
                        nt.Description += '\n\n' + 'Registrant Email: ' + areg.Registrant_Email__c;

                        activityUpdates.add(nt);
                    }

                }
            }
        }


        if (activityUpdates.size() > 0) {
            insert activityUpdates;
        }
    }

    public static void sendEmail2(String EmailTo, String HTMLBody, String plainBody, String Subject, Id OrgEmailId, String BCCString) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{
                EmailTo
        });
        mail.setSubject(Subject);
        if (!String.isBlank(BCCString)) {
            BCCString = BCCString.replaceAll('\\s+', '');
            BCCString = BCCString.replaceAll(';', ',');
            List<String> bccList = BCCString.split(',');
            if (bccList.size() > 0) {
                mail.setBccAddresses(bccList);
            }
        }
        mail.setPlainTextBody(plainBody);
        if (String.isBlank(HTMLBody)) {
            mail.setHtmlBody(plainBody);
        } else {
            mail.setHtmlBody(HTMLBody);
        }
        mail.setOrgWideEmailAddressId(OrgEmailId);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }
}