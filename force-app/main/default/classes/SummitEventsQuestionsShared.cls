// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 7/22/2023.

public with sharing class SummitEventsQuestionsShared {
    public static List<SelectOption> createLookupPicklist(String objectName, String filter, String fields) {
        List<SelectOption> pl = new List<SelectOption>();
        pl.add(new SelectOption('', 'Select...'));

        List<String> fieldNames = fields.split(',');

        String query = 'SELECT Id,' + fields;
        query += ' FROM ' + objectName;

        if (String.isNotBlank(filter)) {
            query += ' WHERE ' + filter;
        }

        query += ' ORDER BY ' + fieldNames.get(0);

        List<SObject> results = Database.query(query);

        for (SObject obj : results) {
            String name = '';

            for (Integer i = 0; i < fieldNames.size(); i++) {
                String field = fieldNames.get(i);

                if (i == 1 && fieldNames.size() > 0) {
                    name += ' - ';
                }
                if (i > 1) {
                    name += ', ';
                }
                if (String.isNotBlank((String) obj.get(field.trim()))) {
                    name += (String) obj.get(field.trim());
                } else {
                    name = name.removeEnd(', ');
                }
            }
            name = name.removeEnd(', ');
            SelectOption option = new SelectOption(obj.Id, name);
            pl.add(option);
        }

        return pl;
    }

    public static List<SelectOption> createPicklists(String returnSepStringList) {
        List<SelectOption> cpl = new List<SelectOption>();
        if (!String.isBlank(returnSepStringList)) {
            cpl.add(new SelectOption('', 'Select...'));
            returnSepStringList = returnSepStringList.trim();
            returnSepStringList = returnSepStringList.replace('\n\n', '\n');
            String[] splitList = returnSepStringList.split('\n');
            for (String p : splitList) {
                p = p.replaceAll('[^a-zA-Z0-9@<>?&;:\\[\\]!-. ]', '');
                cpl.add(new SelectOption(p, p));
            }
        }
        return cpl;
    }

    public static List<SelectOption> createExistingPicklist(String existingPicklist) {
        List<SelectOption> picklists = new List<SelectOption>();
        String namespace = SummitEventsNamespace.getNamespace();
        if (String.isNotBlank(namespace)) {
            namespace = namespace.toLowerCase() + '__';
        }

        String existingPicklistString = existingPicklist;
        if (!existingPicklistString.startsWith('c__')) {
            existingPicklistString = namespace + existingPicklistString;
        }

        Schema.DescribeSObjectResult registrationDescribe = ((SObject) Type.forName('Schema', namespace + 'Summit_Events_Registration__c').newInstance()).getSObjectType().getDescribe();

        List<Schema.PicklistEntry> PicklistValues = registrationDescribe.fields.getMap().get(existingPicklistString).getDescribe().getPicklistValues();
        picklists.add(new SelectOption('', 'Select...'));
        for (Schema.PicklistEntry PicklistValue : PicklistValues) {
            picklists.add(new SelectOption(PicklistValue.getValue(), PicklistValue.getLabel()));
        }
        return picklists;
    }

    public static String checkFieldGuestAccess(String objectApiName, String fieldName, String requiredFieldType, Boolean testCreatable, String qualifierLabel) {
        String returnError = '';
        DescribeFieldResult fieldDescribe;
        SObjectType schemaType;
        if (String.isBlank(qualifierLabel)) {
            qualifierLabel = '';
        }
        try {
            schemaType = ((SObject) Type.forName('Schema', objectApiName).newInstance()).getSObjectType();
        } catch (Exception ex) {
            returnError = qualifierLabel + objectApiName + ' may not exist or is inaccessible. ';
        }

        if (String.isBlank(returnError)) {
            if (!schemaType.getDescribe().isAccessible()) {
                returnError += qualifierLabel + objectApiName + ' is not accessible (check sharing rules and permissions). ';
            }
        }
        if (String.isNotBlank(fieldName) && String.isBlank(returnError)) {
            try {
                Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
                fieldDescribe = fields.get(fieldName).getDescribe();
            } catch (Exception ex) {
                returnError += qualifierLabel + 'Field ' + fieldName + ' may not exist. ';
            }

            if (String.isBlank(returnError)) {
                if (!fieldDescribe.isAccessible()) {
                    returnError += qualifierLabel + 'Field ' + fieldName + ' is not accessible by guest user.';
                }
            }
            if (String.isBlank(returnError) && testCreatable) {
                if (!fieldDescribe.isCreateable()) {
                    returnError += qualifierLabel + 'Field ' + fieldName + ' is not writable. ';
                }
            }
            if (String.isBlank(returnError) && String.isNotBlank(requiredFieldType)) {
                if (!String.valueOf(fieldDescribe.getType()).equalsIgnoreCase(requiredFieldType)) {
                    returnError += qualifierLabel + 'Field ' + fieldName + ' is not the required field type ' + requiredFieldType + '. ';
                }
            }
        }
        return returnError;
    }

}