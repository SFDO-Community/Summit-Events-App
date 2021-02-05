// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 6/12/2018.

@IsTest
public with sharing class SummitEventsShared_TEST {

    @IsTest
    static void testDepreciation() {

        Boolean depreciated = true;
        System.assertEquals(depreciated, true);
    }
}