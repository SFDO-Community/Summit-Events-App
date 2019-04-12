/**
 * Created by dahl3702 on 2/19/2019.
 */

public with sharing class USTEventReparentController {

    public Id reparentTo { get; set; }
    public Id regId { get; set; }
    public UST_Event_Registration__c registration {get;set;}
    public Contact reparentContact {get;set;}

    public USTEventReparentController() {
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('reparentTo'))) {
            reparentTo = (Id) ApexPages.currentPage().getParameters().get('reparentTo');
        }
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('regId'))) {
            regId = (Id) ApexPages.currentPage().getParameters().get('regId');
        }

        if (String.isNotBlank(regId)) {
            registration = [
                    SELECT Id, Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c, Event_Name__c, Event_Instance_Title__c,
                            Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.Id
                    FROM UST_Event_Registration__c
                    WHERE Id = :regId
                    LIMIT 1
            ];
            //query reg to get contact and registration information to display
        }

        if (String.isNotBlank(reparentTo)) {

            reparentContact = [
                    SELECT Id 
                    FROM Contact
                    WHERE Id = :reparentTo
                    LIMIT 1
            ];
            //query new contact that registration will be reparented to
        }
    }

    public pageReference reparentNow() {

        return new PageReference('/'+regId);
    }


    public pageReference reparentNowAndDeleteContact() {

        return new PageReference('/'+regId);
    }
}