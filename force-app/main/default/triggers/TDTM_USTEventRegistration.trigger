// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 4/29/2019.

trigger TDTM_USTEventRegistration on UST_Event_Registration__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    hed.TDTM_Global_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.UST_Event_Registration__c);
}