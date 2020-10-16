public with sharing class SummitEventsEmailUtil {
    public SummitEventsEmailUtil() {}
    
    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getEmailTemplates(){
        return [SELECT Id, Name, FolderName FROM EmailTemplate 
        WHERE TemplateType='custom' AND RelatedEntityType='Summit_Events_Registration__c'];
    }

    @AuraEnabled(cacheable=true)
    public static List<OrgWideEmailAddress> getOrgWideEmailAddresses(){
        return [SELECT Id, Address,IsAllowAllProfiles,DisplayName FROM OrgWideEmailAddress];
    }
}
