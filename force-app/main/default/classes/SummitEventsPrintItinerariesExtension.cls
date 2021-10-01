// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 11/28/2018.

public with sharing class SummitEventsPrintItinerariesExtension {
    public Summit_Events_Instance__c SEInstance;
    public List<Summit_Events_Registration__c> eventRegs { get; set; }
    public String docName { get; set; }
    public String docTypeIn { get; set; }

    public SummitEventsPrintItinerariesExtension(ApexPages.StandardController stdController) {

        if (!String.isBlank(ApexPages.currentPage().getParameters().get('docName'))) {
            docName = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('docName'));
        }
        if (!String.isBlank(ApexPages.currentPage().getParameters().get('docType'))) {
            docTypeIn = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('docType'));
        }

        SEInstance = (Summit_Events_Instance__c) stdController.getRecord();

        eventRegs = [
                SELECT Id, Generated_Itinerary__c, Registrant_First_Name__c, Registrant_Last_Name__c,Event_Instance_Date__c, Event_Name__c, Preferred_First_Name_Formatted__c
                FROM Summit_Events_Registration__c
                WHERE Event_Instance__c = :SEInstance.Id
                WITH SECURITY_ENFORCED
                ORDER BY Registrant_Last_Name__c
        ];
    }


    public String getChooseRender() {
        if (!String.isBlank(ApexPages.currentPage().getParameters().get('docType'))) {
            docTypeIn = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('docType'));
            if (docTypeIn.equalsIgnoreCase('pdf')) {
                return 'pdf';
            }
        }
        return null;
    }

    public String getIsItWord() {
        String filename = fileName();
        if (!String.isBlank(ApexPages.currentPage().getParameters().get('docType'))) {
            docTypeIn = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('docType'));
            if (docTypeIn.equalsIgnoreCase('word')) {
                return 'application/msword#' + filename + '.doc';
            }
        }
        return null;
    }

    public PageReference generatePDF() {
        PageReference pr = ApexPages.currentPage();
        String filename = fileName();
        pr.getHeaders().put('content-disposition', 'attachment; filename=' + filename + '.pdf');
        pr.getParameters().put('docType', 'pdf');
        docTypeIn = 'pdf';
        pr.getParameters().put('docName', docName);
        return pr;
    }

    public PageReference generateDoc() {
        PageReference pr = ApexPages.currentPage();
        docTypeIn = 'word';
        pr.getParameters().put('docType', 'word');
        pr.getParameters().put('docName', docName);
        return pr;
    }

    public String fileName() {
        String fileName = 'eventItineraries_';
        if (!String.isBlank(eventRegs[0].Event_Name__c)) {
            fileName = eventRegs[0].Event_Name__c;
            Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
            Matcher matcher = nonAlphanumeric.matcher(fileName);
            fileName = matcher.replaceAll('_');
            fileName = fileName + '_';
        }
        if (!String.isBlank(String.valueOf(eventRegs[0].Event_Instance_Date__c))) {
            fileName += String.valueOf(eventRegs[0].Event_Instance_Date__c);
        } else {
            fileName += String.valueOf(Date.today());
        }
        return fileName;
    }
}