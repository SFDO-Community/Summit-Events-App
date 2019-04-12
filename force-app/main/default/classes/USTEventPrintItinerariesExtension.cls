/**
 * Created by dahl3702 on 11/28/2018.
 */

public with sharing class USTEventPrintItinerariesExtension {
    public UST_Event_Instance__c USTi;
    public List<UST_Event_Registration__c> eventRegs { get; set; }
    public String docName { get; set; }
    public String docTypeIn { get; set; }

    public USTEventPrintItinerariesExtension(ApexPages.StandardController stdController) {

        if (!String.isBlank(ApexPages.currentPage().getParameters().get('docName'))) {
            docName = ApexPages.currentPage().getParameters().get('docName');
        }
        if (!String.isBlank(ApexPages.currentPage().getParameters().get('docType'))) {
            docTypeIn = ApexPages.currentPage().getParameters().get('docType');
        }

        USTi = (UST_Event_Instance__c) stdController.getRecord();

        eventRegs = [
                SELECT Instance__c, Id, Generated_Itinerary__c, Registrant_First_Name__c, Registrant_Last_Name__c,Event_Instance_Date__c, Event_Name__c, Preferred_First_Name_Formatted__c
                FROM UST_Event_Registration__c
                WHERE Event_Instance__c = :USTi.Id
                ORDER BY Registrant_Last_Name__c
        ];
    }


    public String getChooseRender() {
        if (!String.isBlank(ApexPages.currentPage().getParameters().get('docType'))) {
            if (ApexPages.currentPage().getParameters().get('docType') == 'pdf') {
                return 'pdf';
            }
        }
        return null;
    }

    public String getIsItWord() {
        String filename = fileName();
        if (!String.isBlank(ApexPages.currentPage().getParameters().get('docType'))) {
            if (ApexPages.currentPage().getParameters().get('docType') == 'word') {
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
            fileName += String.valueOf(date.today());
        }
        return fileName;
    }
}