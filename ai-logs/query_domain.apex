// Find the Force.com Site URL for VF pages
List<Site> sites = [SELECT Id, Name, UrlPathPrefix, Status, SiteType, GuestUserId FROM Site LIMIT 10];
for (Site s : sites) {
    System.debug('SITE:' + s.Name + '|' + s.UrlPathPrefix + '|' + s.SiteType + '|' + s.GuestUserId);
}
// Get domain info
List<Domain> domains = [SELECT Id, Domain, DomainType FROM Domain LIMIT 5];
for (Domain d : domains) {
    System.debug('DOMAIN:' + d.Domain + '|' + d.DomainType);
}
