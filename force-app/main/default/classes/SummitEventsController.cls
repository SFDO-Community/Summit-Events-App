/**
 * Created by Thad-PC-2019 on 8/9/2020.
 */

public with sharing class SummitEventsController {

    public String feedURL { get; set; }

    public SummitEventsController() {

        String namespace = SummitEventsNamespace.getNamespace();
        String headerdata = ApexPages.currentPage().getHeaders().get('Host');
        headerdata.replace('http://', 'https://');
        feedURL = 'https://' + headerdata + '/services/apexrest/';

        if (String.isNotEmpty(namespace)) {
            feedURL += namespace + '/';
        }
        feedURL += 'summiteventsfeed';

    }
}