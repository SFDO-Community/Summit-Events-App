Site mySite = [SELECT Id FROM Site WHERE Name = 'Summit_Events'];
SiteDetail mySiteDetail = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :mySite.Id];
System.debug('VF_SITE_URL:' + mySiteDetail.SecureURL);
// Also get the LWC experience cloud site URL  
Site lwcSite = [SELECT Id FROM Site WHERE Name = 'Summit_Events1'];
SiteDetail lwcDetail = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :lwcSite.Id];
System.debug('LWC_SITE_URL:' + lwcDetail.SecureURL);
