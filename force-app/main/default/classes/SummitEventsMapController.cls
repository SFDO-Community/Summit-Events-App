public with sharing class SummitEventsMapController {
    
	@AuraEnabled(cacheable=true)
	public static List<Summit_Events_Registration__c> getSummitEventsRegistrants(Id eventId) {
		List<Summit_Events_Registration__c> registrations;
		try {
			if (Schema.SObjectType.Summit_Events_Registration__c.isAccessible()) {
				registrations = [SELECT Id, 
						Preferred_First_Name_Formatted__c,
						Contact__r.MailingStreet, 
						Contact__r.MailingCity, 
						Contact__r.MailingState, 
						Contact__r.MailingPostalCode, 
						Contact__r.MailingCountry,
						Contact__r.MailingLongitude, 
						Contact__r.MailingLatitude
					FROM Summit_Events_Registration__c
					WHERE (Event_Instance__c =: eventId OR Event__c =: eventId)
					WITH SECURITY_ENFORCED
				];
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return registrations;
	}
}