// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 6/18/2018.

@RestResource(urlMapping='/ustadmissionsrest/*')

global with sharing class USTRestAdmissions {

    private class programData {
        String majorId { get; set; }
        String programId { get; set; }
        String schoolId { get; set; }
        String title { get; set; }
        String link { get; set; }
        String learningStyle { get; set; }
        String school { get; set; }
        String degreeLevel { get; set; }
        String interest { get; set; }
        String programCode { get; set; }
        String programMajorCode { get; set; }
    }

    @HttpGet
    global static void getUstAdmissionsRest() {
        RestResponse res = RestContext.response;
        String callback = RestContext.request.params.get('callback');
        String serializedJSON = '';

        if (String.isBlank(callback)) {
            res.addHeader('Content-Type', 'application/json');
            callback = '';
        } else {
            res.addHeader('Content-Type', 'application/javascript');
        }

        String feedType = RestContext.request.params.get('type');
        if (!String.isBlank(feedType)) {
            if (feedType.toLowerCase() == 'highschool') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=highschool
                serializedJSON = JSON.serialize(getSchools('High School'));

            } else if (feedType.toLowerCase() == 'college') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=college
                serializedJSON = JSON.serialize(getSchools('College'));

            } else if (feedType.toLowerCase() == 'states') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=states
                serializedJSON = JSON.serialize(getObjDefMap(Contact.MailingState.getDescribe()));

            } else if (feedType.toLowerCase() == 'cities') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=cities
                serializedJSON = JSON.serialize(getCityList());

            } else if (feedType.toLowerCase() == 'countries') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/ustadmissionsrest.json?type=countries
                serializedJSON = JSON.serialize(getObjDefMap(Contact.MailingCountry.getDescribe()));

            } else if (feedType.toLowerCase() == 'gradschools') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=gradschools
                serializedJSON = JSON.serialize(getUSTSchools());

            } else if (feedType.toLowerCase() == 'gradprograms') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=gradprograms
                serializedJSON = JSON.serialize(getGradPrograms());

            } else if (feedType.toLowerCase() == 'ugmajors') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=ugmajors
                serializedJSON = JSON.serialize(getUGMajors());

            } else if (feedType.toLowerCase() == 'ugactivities') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=ugmajors
                serializedJSON = JSON.serialize(getActivities('Clubs and Organizations'));

            } else if (feedType.toLowerCase() == 'ugclubsports') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=ugclubsports
                serializedJSON = JSON.serialize(getActivities('Intramurals/Club Sports'));

            } else if (feedType.toLowerCase() == 'ugvarsitysports') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=ugvarsitysports
                serializedJSON = JSON.serialize(getActivities('Varsity Sports'));

            } else if (feedType.toLowerCase() == 'ugmusic') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=ugmusic
                serializedJSON = JSON.serialize(getActivities('Music'));

            } else if (feedType.toLowerCase() == 'areaofinterest') {
                /*serializedJSON = JSON.serialize(getObjDefMap(Major__c.Areas_of_Interest_for_program_finder__c.getDescribe()));*/
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=areaofinterest

            } else if (feedType.toLowerCase() == 'degree') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=degree
               /* serializedJSON = JSON.serialize(getObjDefMap(EnrollmentrxRx__Program_Offered__c.Degree_Level__c.getDescribe()));*/

            } else if (feedType.toLowerCase() == 'learningstyle') {
                // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=degree
                /*serializedJSON = JSON.serialize(getObjDefMap(Major__c.Learning_Style_for_program_finder__c.getDescribe()));*/
            } else if (feedType.toLowerCase() == 'programfinder') {
                serializedJSON = JSON.serialize(programFinder());
            }
        }
        if (!String.isBlank(callback)) {
            serializedJSON = callback + '(' + serializedJSON + ')';
        }
        res.responseBody = Blob.valueOf(serializedJSON);
    }

    private static List<programData> programFinder() {
        List<programData> programList = new List<programData>();
        /*List<Major__c> majorList = new List<Major__c>();
        String majorQuery = '';

        // Build the query as a string for flexibility
        majorQuery += ' SELECT Id,Display_on_Program_Finder__c, Display_on_RFI__c, Major_Display_Name__c, Prog_Major_Conc_Code__c, Program_Code__c, Status__c, ';
        majorQuery += ' Program_Offered__r.Degree_Level__c, Keyword_for_Program_Finder__c,Major_Web_URL__c, Program_Offered__r.Program_Code__c, ';
        majorQuery += ' Areas_of_Interest_for_program_finder__c,Learning_Style_for_program_finder__c, Program_Offered__r.School__r.Name, Program_Offered__r.School__c ';
        majorQuery += ' FROM Major__c ';
        majorQuery += ' WHERE Display_on_Program_Finder__c = true AND';

        // Possible URL variables
        // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=programfinder
        // any combination of the following parameters can be sent to the API request
        // &interest=  <- program of intereest  (Education,Engineering, etc)
        // &degree= <- Master of Science, Certificate,etc
        // &style= <- Learning Style (Traditional,Blended, etc)
        // &school= <- Name of the school (College of Arts and Sciences, Opus College of Business, etc)
        // &schoolId= <- Salesforce ID for a school
        // &filter= <- comma separate list of text that the query will test against the name of the program, major, degree, learning style, and area of interest
        // https://COMMUNITY_SUB_DOMAIN.force.comservices/apexrest/ustadmissionsrest.json?type=programfinder&interest=&degree=&style=&schoolId=&filter=


        if (!String.isBlank(RestContext.request.params.get('interest'))) {
            String majorInterest = String.valueOf(RestContext.request.params.get('interest'));
            majorQuery += ' Areas_of_Interest_for_program_finder__c  IN (\'' + majorInterest + '\') AND' ;
        }

        If (!String.isBlank(RestContext.request.params.get('degree'))) {
            String majorDegree = String.valueOf(RestContext.request.params.get('degree'));
            majorQuery += ' Program_Offered__r.Degree_Level__c = \'' + majorDegree + '\'  AND' ;
        }

        if (!String.isBlank(RestContext.request.params.get('style'))) {
            String majorStyle = String.valueOf(RestContext.request.params.get('style'));
            majorQuery += ' Learning_Style_for_program_finder__c IN (\'' + majorStyle + '\') AND' ;
        }

        if (!String.isBlank(RestContext.request.params.get('school'))) {
            String majorSchool = String.valueOf(RestContext.request.params.get('school'));
            majorQuery += ' Program_Offered__r.School__r.Name = \'' + majorSchool + '\' AND' ;
        }

        if (!String.isBlank(RestContext.request.params.get('schoolId'))) {
            String majorSchoolId = String.valueOf(RestContext.request.params.get('schoolId'));
            majorQuery += ' Program_Offered__r.School__c = \'' + majorSchoolId + '\' AND' ;
        }

        majorQuery = majorQuery.removeEnd('AND');

        //split apart the filter on commas and test against the fields in the query
        if (!String.isBlank(RestContext.request.params.get('filter'))) {
            String majorFilter = String.valueOf(RestContext.request.params.get('filter'));
            majorQuery += ' AND  (';
            List<String> filterList = majorFilter.split(',');
            for (String f : filterList) {
                majorQuery += ' Program_Offered__r.School__r.Name LIKE \'%' + f + '%\' OR ';
                majorQuery += ' Learning_Style_for_program_finder__c LIKE \'%' + f + '%\' OR ';
                majorQuery += ' Program_Offered__r.Degree_Level__c LIKE \'%' + f + '%\' OR ';
                majorQuery += ' Areas_of_Interest_for_program_finder__c IN (\'' + f + '\') OR ';
                majorQuery += ' Major_Display_Name__c LIKE \'%' + f + '%\' OR ';
            }
            majorQuery = majorQuery.removeEnd('OR ');
            majorQuery += ' ) ';
        }

        majorQuery = majorQuery.removeEnd('AND');

        majorQuery += ' ORDER BY Major_Display_Name__c';

        System.Debug('================================> ' + majorQuery);

        majorList = database.query(majorQuery);

        //load up the custom object class to send back to be parsed into JSON
        for (Major__c m : majorList) {
            programData pd = new programData();
            pd.title = m.Major_Display_Name__c;
            pd.link = (!String.isBlank(m.Major_Web_URL__c) ? m.Major_Web_URL__c : '');
            pd.degreeLevel = (!String.isBlank(m.Program_Offered__r.Degree_Level__c) ? m.Program_Offered__r.Degree_Level__c : '');
            pd.learningStyle = (!String.isBlank(m.Learning_Style_for_program_finder__c) ? m.Learning_Style_for_program_finder__c : '');
            pd.school = (!String.isBlank(m.Program_Offered__r.School__r.Name) ? m.Program_Offered__r.School__r.Name : '');
            pd.interest = (!String.isBlank(m.Areas_of_Interest_for_program_finder__c) ? m.Areas_of_Interest_for_program_finder__c : '');
            pd.majorId = (!String.isBlank(m.Id) ? m.Id : '');
            pd.schoolId = (!String.isBlank(String.valueOf(m.Program_Offered__r.School__c)) ? String.valueOf(m.Program_Offered__r.School__c) : '');
            pd.programId = (!String.isBlank(String.valueOf(m.Program_Offered__c)) ? String.valueOf(m.Program_Offered__c) : '');
            pd.programCode = (!String.isBlank(m.Program_Code__c) ? m.Program_Code__c : '');
            pd.programMajorCode = (!String.isBlank(m.Prog_Major_Conc_Code__c) ? m.Prog_Major_Conc_Code__c : '');
            programList.add(pd);
        }*/
        return programList;
    }

    global static Map<String, String> getActivities(String ActivityType) {
        Map<String, String> keyValOut = new Map<String, String>();
/*        List<Activities__c> Activities = [
                SELECT Club_Description__c, Id
                FROM Activities__c
                WHERE Display_on_Portal__c = 'Yes'
                AND Club_Type__c = :ActivityType
                ORDER BY Club_Description__c DESC
        ];
        For (Activities__c act : Activities) {
            keyValOut.put(act.Id, act.Club_Description__c);
        }*/
        return keyValOut;
    }

    global static Map<String, String> getUGMajors() {
        Map<String, String> keyValOut = new Map<String, String>();
        /*List<Major__c> UGMajors = [
                SELECT Major_Code__c, Major_Display_Name__c, Program_Offered__c, Id
                FROM Major__c
                WHERE Status__c = 'Active'
                AND Major_Code__c != NULL
                AND Major_Display_Name__c != NULL
                AND Major_Display_Name__c != 'Liberal Arts (DFC)'
                AND Program_Offered__c IN (SELECT Id FROM EnrollmentrxRx__Program_Offered__c WHERE Name = 'Undeclared BA')
                ORDER BY Major_Display_Name__c DESC
        ];
        For (Major__c maj : UGMajors) {
            keyValOut.put(String.valueOf(maj.Major_Code__c), maj.Major_Display_Name__c);
        }*/
        return keyValOut;
    }

    global static Map<String, String> getGradPrograms() {
        Map<String, String> keyValOut = new Map<String, String>();
        String schoolId = '';
        /*List<Major__c> schoolProgs = new List<Major__c>();
        if (!String.isBlank(RestContext.request.params.get('schoolid'))) {
            schoolId = RestContext.request.params.get('schoolid');
            schoolProgs = [
                    SELECT Id,Name, Major_Display_Name__c, Major_Name__c, Major_Code__c, Prog_Major_Conc_Code__c, Program_Offered__r.Program_Code__c
                    FROM Major__c
                    WHERE Status__c = 'Active'
                    AND Program_Offered__r.EnrollmentrxRx__Program_Catalog__r.Name != 'Undergraduate'
                    AND Program_Offered__r.Program_Code__c != NULL
                    AND Program_Offered__r.School__c = :schoolId
                    ORDER BY Major_Name__c
            ];
        } else {
            schoolProgs = [
                    SELECT Id,Name, Major_Display_Name__c, Major_Name__c, Major_Code__c, Prog_Major_Conc_Code__c, Program_Offered__r.Program_Code__c
                    FROM Major__c
                    WHERE Status__c = 'Active'
                    AND Program_Offered__r.EnrollmentrxRx__Program_Catalog__r.Name != 'Undergraduate'
                    AND Program_Offered__r.Program_Code__c != NULL
                    ORDER BY Major_Name__c
            ];
        }
        For (Major__c prog : schoolProgs) {
            keyValOut.put(prog.Prog_Major_Conc_Code__c, prog.Major_Display_Name__c);
        }*/
        return keyValOut;
    }

    global static Map<String, String> getUSTSchools() {
        Map<String, String> keyValOut = new Map<String, String>();
        /*List<EnrollmentrxRx__School__c> schoolList = [
                SELECT Name, Id
                FROM EnrollmentrxRx__School__c
                WHERE Active_Display_on_Portal__c = true
                AND Name != 'Undergraduate'
                ORDER BY Display_Order__c DESC
        ];
        For (EnrollmentrxRx__School__c schl : schoolList) {
            keyValOut.put(schl.Id, schl.Name);
        }*/
        return keyValOut;
    }

    global static Map<String, String> getCityList() {
        String state = '';
        Map<String, String> keyValOut = new Map<String, String>();
       /* if (!String.isBlank(RestContext.request.params.get('state'))) {
            state = RestContext.request.params.get('state').toUpperCase();
        }
        if (!String.isBlank(state)) {
            List<City__c> cityList = [SELECT Name FROM City__c WHERE State_Code__c = :state ORDER BY Name DESC];
            For (City__c city : cityList) {
                keyValOut.put(city.Name, city.Name);
            }
        }*/
        return keyValOut;
    }

    global static Map<String, String> getSchools(String recTypeName) {
        /*List<EnrollmentrxRx__High_School__c> schoolList = new List<EnrollmentrxRx__High_School__c>();*/
        Map<String, String> keyValOut = new Map<String, String>();
        //List<String> filter = new List<String>();

        /*String state = '';
        if (!String.isBlank(RestContext.request.params.get('state'))) {
            state = RestContext.request.params.get('state');
        }
        String city = '';
        if (!String.isBlank(RestContext.request.params.get('city'))) {
            city = '%' + RestContext.request.params.get('city') + '%';
        }

        String filter = '';
        if (!String.isBlank(RestContext.request.params.get('filter'))) {
            List<String> filterHolder = new List<String>();
            for (String fragment : RestContext.request.params.get('filter').split(' ')) {
                filterHolder.add('*' + fragment + '*');
            }
            filter = String.Join(filterHolder, ' ');
        }

        if (!String.isBlank(state) && String.isBlank(city)) {
            schoolList = [
                    SELECT Name, EnrollmentrxRx__CEEB_Code__c, EnrollmentrxRx__High_School_State__c, EnrollmentrxRx__High_School_City__c
                    FROM EnrollmentrxRx__High_School__c
                    WHERE EnrollmentrxRx__High_School_State__c = :state
                    AND RecordType.Name = :recTypeName
                    ORDER BY Name
            ];
        }
        if (!String.isBlank(state) && !String.isBlank(city)) {
            schoolList = [
                    SELECT Name, EnrollmentrxRx__CEEB_Code__c, EnrollmentrxRx__High_School_State__c, EnrollmentrxRx__High_School_City__c
                    FROM EnrollmentrxRx__High_School__c
                    WHERE EnrollmentrxRx__High_School_State__c = :state
                    AND EnrollmentrxRx__High_School_City__c LIKE :city
                    AND RecordType.Name = :recTypeName
                    ORDER BY Name
            ];
        }
        if (!String.isBlank(filter)) {
            schoolList = [
                    FIND :filter
                    IN ALL FIELDS
                            RETURNING EnrollmentrxRx__High_School__c(Name, EnrollmentrxRx__CEEB_Code__c, EnrollmentrxRx__High_School_State__c, EnrollmentrxRx__High_School_City__c WHERE RecordType.Name = :recTypeName)
            ][0];

            System.Debug('-=-=0-0-0--- SCHOOL LIST SIZE: ' + schoolList.size() + ' FILTER: ' + filter);
        }


        For (EnrollmentrxRx__High_School__c sch : schoolList) {
            keyValOut.put(sch.EnrollmentrxRx__CEEB_Code__c, sch.Name + ' - ' + sch.EnrollmentrxRx__High_School_City__c + ', ' + sch.EnrollmentrxRx__High_School_State__c);
        }*/

        return keyValOut;
    }


    global static Map<String, String> getObjDefMap(Schema.DescribeFieldResult fieldResult) {
        Map<String, String> keyValOut = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Integer ii = ple.size() - 1; ii >= 0; ii--) {
            keyValOut.put(ple[ii].getLabel(), ple[ii].getValue());
        }
        return keyValOut;
    }

}