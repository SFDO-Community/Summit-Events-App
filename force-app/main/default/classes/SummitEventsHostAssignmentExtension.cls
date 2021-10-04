// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 10/30/2018.

public with sharing class SummitEventsHostAssignmentExtension {
    public Summit_Events_Appointments__c SEApt;
    public Id instanceID { get; set; }
    public Id hostId { get; set; }
    public Id recordTypeId { get; set; }
    public String hostAction { get; set; }

    public SummitEventsHostAssignmentExtension(ApexPages.StandardController stdController) {
        SEApt = (Summit_Events_Appointments__c) stdController.getRecord();
        instanceID = SEApt.Event_Registration__r.Event_Instance__r.Id;
    }

    public List<Summit_Events_Host__c> getListHost() {
        List<Summit_Events_Host__c> listHost = new List<Summit_Events_Host__c>();
        if (String.isBlank(SEApt.Event_Host__c)) {
            listHost = [
                    SELECT Name, Last_Name__c, First_Name__c, Preferred_Title__c, RecordType.Name,
                            Gender__c, Undergrad_Major__c, Department__c, Contact__c, Formatted_Time__c,
                            Course_Name__c, Building__c, Location__c, Additional_Comments__c, Remaining__c,
                            Assigned__c
                    FROM Summit_Events_Host__c
                    WHERE Event_Instance__c = :instanceID
                    AND RecordType.Id = :recordTypeId
                    AND Remaining__c > 0
                    WITH SECURITY_ENFORCED
                    ORDER BY Last_Name__c, First_Name__c, Course_Name__c
            ];
        } else {
            listHost = [
                    SELECT Name, Last_Name__c, First_Name__c, Preferred_Title__c, RecordType.Name,
                            Gender__c, Undergrad_Major__c, Department__c, Contact__c, Formatted_Time__c,
                            Course_Name__c, Building__c, Location__c, Additional_Comments__c, Remaining__c,
                            Assigned__c
                    FROM Summit_Events_Host__c
                    WHERE Event_Instance__c = :instanceID
                    AND Id = :SEApt.Event_Host__c
                    WITH SECURITY_ENFORCED
                    ORDER BY Last_Name__c, First_Name__c, Course_Name__c
            ];
        }

        return listHost;
    }

    public PageReference assignHost() {
        SEApt.Event_Host__c = hostId;
        List<Summit_Events_Host__c> addedHostList = [SELECT Remaining__c, Assigned__c, Max_Available__c, Id FROM Summit_Events_Host__c WHERE Id = :hostId];
        if (addedHostList.size() > 0) {
            if (addedHostList[0].Remaining__c > 0) {
                Summit_Events_Host__c newHost = new Summit_Events_Host__c(Id = hostId);
                if (hostAction == 'assign') {
                    newHost.Assigned__c = Integer.valueOf(addedHostList[0].Assigned__c) + 1;
                }
                if (hostAction == 'unassign') {
                    SEApt.Event_Host__c = null;
                    newHost.Assigned__c = Integer.valueOf(addedHostList[0].Assigned__c) - 1;
                }
                upsert newHost;
                upsert SEApt;
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Looks like that host has run out of capacity.');
                ApexPages.addMessage(myMsg);
            }
        }
        return null;
    }

    public List<SelectOption> getRecordTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select...'));
        for (List<RecordType> rts : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Summit_Events_Host__c' ORDER BY Name]) {
            for (RecordType rt : rts) {
                options.add(new SelectOption(rt.Id, rt.Name));
            }
        }
        return options;
    }

}