List<Site> sites = [SELECT Id, Name, UrlPathPrefix, Status, SiteType FROM Site LIMIT 10];
for (Site s : sites) {
    System.debug('SITE:' + s.Id + '|' + s.Name + '|' + s.UrlPathPrefix + '|' + s.Status + '|' + s.SiteType);
}
String orgUrl = URL.getOrgDomainURL().toExternalForm();
System.debug('ORGURL:' + orgUrl);
