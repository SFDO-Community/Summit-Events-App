List<Site> sites = [SELECT Id, Name, UrlPathPrefix, Status, SiteType FROM Site LIMIT 10];
for (Site s : sites) {
    System.debug('SITE:' + s.Id + '|' + s.Name + '|' + s.UrlPathPrefix + '|' + s.Status + '|' + s.SiteType);
}
List<SiteDetail> details = [SELECT SecureURL FROM SiteDetail LIMIT 5];
for (SiteDetail sd : details) {
    System.debug('SITEDETAIL:' + sd.SecureURL);
}
