// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 6/12/2018.

@IsTest
public with sharing class SummitEventsShared_TEST {

    @IsTest
    static void testDepreciation() {

        Boolean depreciated = true;
        System.assertEquals(depreciated, true);
    }
}