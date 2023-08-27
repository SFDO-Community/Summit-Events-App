// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 7/22/2023.

public with sharing class SummitEventsInfo {
    public String audience { get; set; }
    public String instanceId { get; set; }
    public String eventId { get; set; }
    public String registrationId { get; set; }
    public String dt { get; set; }
}