public static void setSiteURL() {

    String siteName = 'Summit_Events';

    Site site = [
            SELECT GuestUserId
            FROM Site
            WHERE Name = :siteName
    ];

    String path = '/sites/servlet.SiteDebugMode';
    PageReference pr = new PageReference(path);
    pr.getParameters().put('guid', site.GuestUserId);
    pr.getParameters().put('sitedebugmode', 'x');
    String url = pr.getContent().toString().substringAfter('URL=').substringBefore(path);

    Summit_Events_Settings__c eventSettings = Summit_Events_Settings__c.getOrgDefaults();
    eventSettings.Community_Base_URL__c = url;
    eventSettings.Managed_Package__c = false;
    upsert eventSettings;

}

public static void addingAdminPermissionSet() {
    //Add Permission set to all Admins
    List<PermissionSet> eventPermissionSets = [SELECT Name, Id FROM PermissionSet WHERE Name = 'Summit_Events_Admin'];

    List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
    if (!eventPermissionSets.isEmpty()) {
        for (User u : [SELECT ID FROM User WHERE Profile.Name = 'System Administrator']) {
            permissionSetList.add(new PermissionSetAssignment(PermissionSetId = eventPermissionSets[0].Id, AssigneeId = u.Id));
        }
    }
    if (!permissionSetList.isEmpty()) {
        upsert permissionSetList;
    }
}

public static void setGuestPermissionSet() {
    String siteName = 'Summit_Events';

    Site site = [
            SELECT GuestUserId
            FROM Site
            WHERE Name = :siteName
    ];

    //Add Permission set to all Admins
    List<PermissionSet> eventPermissionSets = [SELECT Name, Id FROM PermissionSet WHERE Name = 'Summit_Events_Registrant'];

    List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
    if (!eventPermissionSets.isEmpty()) {
            permissionSetList.add(new PermissionSetAssignment(PermissionSetId = eventPermissionSets[0].Id, AssigneeId = site.GuestUserId));
    }
    if (!permissionSetList.isEmpty()) {
        upsert permissionSetList;
    }

}