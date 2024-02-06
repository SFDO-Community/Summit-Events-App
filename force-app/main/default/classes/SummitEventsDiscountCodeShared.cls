// Copyright (c) 2024, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 2/06/2024.


public with sharing class SummitEventsDiscountCodeShared {

    @AuraEnabled(Cacheable=true)
    public static List<Summit_Events_Discount_Code__c> discountCodes() {
        // Get the discount codes
        List<Summit_Events_Discount_Code__c> discountCodes = [
                SELECT
                        Id,
                        Name,
                        Active__c,
                        Description__c,
                        Discount__c,
                        Discount_Code__c,
                        Discount_End_Date__c,
                        Discount_End_Time__c,
                        Discount_Start_Date__c,
                        Discount_Start_Time__c,
                        Discount_Status__c,
                        Discount_Type__c
                FROM Summit_Events_Discount_Code__c
                WHERE Active__c = TRUE
                AND (Discount_Start_Date__c = NULL OR Discount_Start_Date__c <= TODAY)
                AND (Discount_End_Date__c = NULL OR Discount_End_Date__c >= TODAY)
        ];
        return discountCodes;
    }

}


