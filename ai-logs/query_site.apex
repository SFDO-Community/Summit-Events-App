// Get Experience Cloud site URL
List<Site> sites = [SELECT Id, Name, UrlPathPrefix, Status, SiteType FROM Site WHERE SiteType != 'ChatterNetwork' LIMIT 10];
for (Site s : sites) {
    System.debug('SITE:' + s.Id + '|' + s.Name + '|' + s.UrlPathPrefix + '|' + s.Status + '|' + s.SiteType);
}
// Get the site detail with guest user
List<SiteDetail> details = [SELECT SecureURL, TopLevelDomain FROM SiteDetail LIMIT 5];
for (SiteDetail sd : details) {
    System.debug('SITEDETAIL:' + sd.SecureURL + '|' + sd.TopLevelDomain);
}
