/**
 * Created by thad on 1/3/2026.
 */

public with sharing class SummitEventsLookupController {
    @AuraEnabled
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {
        List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();

        if (inputWrapper != null) {
            if (string.isNotBlank(inputWrapper.fieldApiName)) {
                List<String> sanitizedOtherFields = new List<String>();
                //try {
                String fieldsToQuery = 'SELECT Id, ';
                //Check object accessibility
                fieldsToQuery = fieldsToQuery + inputWrapper.fieldApiName;
                SObjectType objectToQuery = Schema.getGlobalDescribe().get(inputWrapper.objectApiName);
                Map<String, SObjectField> fieldsMap = objectToQuery.getDescribe().fields.getMap();
                try {
                    if (string.isNotBlank(inputWrapper.otherFieldApiName)) {
                        //Can be comma separated
                        List<String> otherFields = inputWrapper.otherFieldApiName.split(',');

                        for (String oField : otherFields) {
                            oField = oField.replaceAll('\\s+', '');
                            DescribeFieldResult fieldDescribe = fieldsMap.get(oField).getDescribe();
                            if (fieldDescribe.isAccessible()) {
                                sanitizedOtherFields.add(oField);
                            }
                        }
                        if (sanitizedOtherFields.size() > 0) {
                            fieldsToQuery = fieldsToQuery + ', ' + String.join(sanitizedOtherFields, ',');
                        }
                    }
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }

                if(inputWrapper.searchString.trim().length() > 3) {
                    String searchString = '%' + inputWrapper.searchString.trim().escapeHtml4() + '%';
                    String recordTypeName = inputWrapper.recordTypeName.trim().escapeHtml4();
                    String type = inputWrapper.type.trim().escapeHtml4();
                    String query = fieldsToQuery + ' FROM ' + inputWrapper.objectApiName;
                    String filterCriteria = inputWrapper.fieldApiName + ' LIKE :searchString ';
                    if (String.isNotBlank(inputWrapper.selectedRecordId)) {
                        query += ' WHERE Id = : inputWrapper.selectedRecordId ';
                    } else if (String.isNotBlank(inputWrapper.parentFieldApiName) && String.isNotBlank(inputWrapper.parentRecordId)) {
                        query += ' WHERE ' + inputWrapper.parentFieldApiName + ' = \'' + inputWrapper.parentRecordId + '\'';
                        query += ' AND ' + filterCriteria;
                    } else {
                        query += ' WHERE ' + filterCriteria;
                    }
                    //TODO receive and use additional WHERE filters. Check if it stats with AND or WHERE
                    if (String.isNotBlank(recordTypeName)) {
                        query += ' AND RecordType.Name = :recordTypeName';
                    }
                    if (String.isNotBlank(type)) {
                        query += ' AND Type = :type';
                    }
                    query += ' LIMIT 50';
                    System.debug(query);

                    for (SObject s : Database.query(query)) {
                        ResultWrapper wrap = new ResultWrapper();
                        wrap.mainField = (String) s.get(inputWrapper.fieldApiName);
                        List<String> fieldValues = new List<String>();
                        for (String otherField : sanitizedOtherFields) {
                            if (String.isNotBlank((String) s.get(otherField))) {
                                fieldValues.add((String) s.get(otherField));
                            }
                        }
                        wrap.subField = String.join(fieldValues, ', ');
                        wrap.id = (String) s.get('id');
                        returnWrapperList.add(wrap);
                    }
                }
                return returnWrapperList;

                // } catch (Exception err) {
                //      System.debug(err.getMessage());
                //      throw new AuraHandledException(err.getMessage());
                //  }
            }

        }
        return returnWrapperList;
    }

    public class ResultWrapper {
        @AuraEnabled public String mainField { get; set; }
        @AuraEnabled public String subField { get; set; }
        @AuraEnabled public String id { get; set; }
    }

    public class SearchWrapper {
        @AuraEnabled public String objectApiName { get; set; }
        @AuraEnabled public String fieldApiName { get; set; }
        @AuraEnabled public String otherFieldApiName { get; set; }
        @AuraEnabled public String searchString { get; set; }
        @AuraEnabled public String selectedRecordId { get; set; }
        @AuraEnabled public String parentRecordId { get; set; }
        @AuraEnabled public String parentFieldApiName { get; set; }
        @AuraEnabled public String recordTypeName { get; set; }
        @AuraEnabled public String type { get; set; }
    }
}