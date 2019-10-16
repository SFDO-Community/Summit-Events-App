// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 10/30/2018.

public with sharing class USTEventHostAssignmentExtension {
    public UST_Event_Appointments__c USTApt;
    public Id instanceID { get; set; }
    public Id hostId { get; set; }
    public Id recordTypeId { get; set; }
    public String hostAction { get; set; }

    public USTEventHostAssignmentExtension(ApexPages.StandardController stdController) {
        USTApt = (UST_Event_Appointments__c) stdController.getRecord();
        instanceID = USTApt.Event_Registration__r.Event_Instance__r.Id;
    }

    public List<UST_Event_Host__c> getListHost() {
        List<UST_Event_Host__c> listHost = new List<UST_Event_Host__c>();
        if (String.isBlank(USTApt.Event_Host__c)) {
            listHost = [
                    SELECT Name, Last_Name__c, First_Name__c, Preferred_Title__c, RecordType.Name,
                            Gender__c, Undergrad_Major__c, Department__c, Contact__c, Formatted_Time__c,
                            Course_Name__c, Building__c, Location__c, Additional_Comments__c, Remaining__c,
                            Assigned__c
                    From UST_Event_Host__c
                    WHERE Event_Instance__c = :instanceID
                    AND RecordType.Id = :recordTypeId
                    AND Remaining__c > 0
                    ORDER BY Last_Name__c, First_Name__c, Course_Name__c
            ];
        } else {
            listHost = [
                    SELECT Name, Last_Name__c, First_Name__c, Preferred_Title__c, RecordType.Name,
                            Gender__c, Undergrad_Major__c, Department__c, Contact__c, Formatted_Time__c,
                            Course_Name__c, Building__c, Location__c, Additional_Comments__c, Remaining__c,
                            Assigned__c
                    From UST_Event_Host__c
                    WHERE Event_Instance__c = :instanceID
                    AND Id = :USTApt.Event_Host__c
                    ORDER BY Last_Name__c, First_Name__c, Course_Name__c
            ];
        }

        return listHost;
    }

    public PageReference assignHost() {
        USTApt.Event_Host__c = hostId;
        List<UST_Event_Host__c> addedHostList = [SELECT Remaining__c, Assigned__c, Max_Available__c, Id FROM UST_Event_Host__c WHERE Id = :hostId];
        if (addedHostList.size() > 0) {
            if (addedHostList[0].Remaining__c > 0) {
                UST_Event_Host__c newHost = new UST_Event_Host__c(Id = hostId);
                if (hostAction == 'assign') {
                    newHost.Assigned__c = Integer.valueOf(addedHostList[0].Assigned__c) + 1;
                }
                if (hostAction == 'unassign') {
                    USTApt.Event_Host__c = null;
                    newHost.Assigned__c = Integer.valueOf(addedHostList[0].Assigned__c) - 1;
                }
                upsert newHost;
                upsert USTApt;
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Looks like that host has run out of capacity.');
                ApexPages.addMessage(myMsg);
            }
        }
        return null;
    }

    public list<SelectOption> getRecordTypes() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', 'Select...'));
        for (list<RecordType> rts : [SELECT ID, name FROM RecordType WHERE SObjectType = 'UST_Event_Host__c' ORDER BY name]) {
            for (RecordType rt : rts) {
                options.add(new SelectOption(rt.ID, rt.Name));
            }
        }
        return options;
    }

}