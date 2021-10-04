// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 8/9/2020.

public with sharing class SummitEventsController {

    public String feedURL { get; set; }
    public String communityBaseURL { get; set; }

    public SummitEventsController() {

        Summit_Events_Settings__c myUserSetting = Summit_Events_Settings__c.getInstance(UserInfo.getUserId());
        communityBaseURL = myUserSetting.Community_Base_URL__c;
        communityBaseURL = communityBaseURL.replaceAll('http:', 'https:');
        if (communityBaseURL.endsWith('/')) {
            communityBaseURL = communityBaseURL.removeEnd('/');
        }

        String namespace = SummitEventsNamespace.getNamespace();
        feedURL = communityBaseURL + '/services/apexrest/';

        if (String.isNotEmpty(namespace)) {
            feedURL += namespace + '/';
        }
        feedURL += 'summiteventsfeed';

    }
}