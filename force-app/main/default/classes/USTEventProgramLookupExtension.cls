// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 10/22/2018.

public class USTEventProgramLookupExtension {

    public UST_Event__c USTEvt;
    public List<SelectOption> SelectedPrograms { get; set; }

    public USTEventProgramLookupExtension(ApexPages.StandardController stdController) {
        USTEvt = (UST_Event__c) stdController.getRecord();

        //get currently selected programs and fill in selected list
        SelectedPrograms = new List<SelectOption>();

      /*  List<String> currentSelected = new List<String>();
        if (!String.isBlank(USTevt.Academic_Program_List_Selected__c)) {
            currentSelected = USTevt.Academic_Program_List_Selected__c.split(';');
            for (String acPrg : currentSelected) {
                SelectedPrograms.add(new SelectOption(acPrg, acPrg));
            }
        } else if (!String.isBlank(USTevt.Academic_Program_List__c)) {
            currentSelected = USTevt.Academic_Program_List__c.split(';');
            for (Integer xx = currentSelected.size() - 1; xx > -1; xx--) {
                SelectedPrograms.add(new SelectOption(currentSelected[xx], currentSelected[xx]));
            }
        } else {
            USTevt.Academic_Program_List__c = '';
        }
*/
    }
/*
    //Fake object to replace Major__c in function below. Replace with new HEDA based object when defined.
    private class Major {
        private Id Id {get;set;}
    }

    public List<SelectOption> getPrograms() {
        // Get a list of programs
        List<SelectOption> programs = new List<SelectOption>();
        List<Major> schoolProgs = new List<Major>();
         if (!String.isBlank(USTEvt.School__c)) {
             Id schoolId = USTEvt.School__c;
             schoolProgs = [
                     SELECT Id,Name, Major_Display_Name__c, Major_Name__c, Major_Code__c, Program_Offered__r.Program_Code__c
                     FROM Major__c
                     WHERE Status__c = 'Active'
                     AND Program_Offered__r.EnrollmentrxRx__Program_Catalog__r.Name != 'Undergraduate'
                     AND Program_Offered__r.Program_Code__c != NULL
                     AND Program_Offered__r.School__c = :schoolId
                     ORDER BY Major_Name__c
             ];
         } else {
             schoolProgs = [
                     SELECT Id,Name, Major_Display_Name__c, Major_Name__c, Major_Code__c, Program_Offered__r.Program_Code__c
                     FROM Major__c
                     WHERE Status__c = 'Active'
                     AND Program_Offered__r.EnrollmentrxRx__Program_Catalog__r.Name != 'Undergraduate'
                     AND Program_Offered__r.Program_Code__c != NULL
                     ORDER BY Major_Name__c
             ];
         }
         For (Major__c prog : schoolProgs) {
             String progName = prog.Major_Display_Name__c + ' (' + prog.Program_Offered__r.Program_Code__c;
             if (!String.isBlank(prog.Major_Code__c)) {
                 progName += '|' + prog.Major_Code__c;
             }
             progName += ')';
             if (USTevt.Academic_Program_List__c.indexOf(progName) == -1) {
                 programs.add(new SelectOption(progName, progName));
             }
         }
        return programs;
    }

    public void save() {
        USTEvt.Academic_Program_List__c = null;
        USTEvt.Program_Filter__c = '';
        update USTEvt;
        // build a ; seperated string of selected Programs to insert into Academic_Program_List__c
        String selectString = '';
        String progCodeString = '';
        for (SelectOption p : SelectedPrograms) {
            selectString += p.getValue() + ';';
        }
        if (!String.isBlank(selectString)) {
            Pattern TAG_REGEX = Pattern.compile('\\((\\w+|\\w+\\|\\w+)\\)');
            Matcher matcher = TAG_REGEX.matcher(selectString);
            //loop through found hocks and add only unique
            while (matcher.find()) {
                progCodeString += matcher.group(1) + ';';
            }
            USTEvt.Academic_Program_List__c = selectString;
            USTEvt.Academic_Program_List_Selected__c = selectString;
            USTEvt.Program_Filter__c = progCodeString;

            update USTEvt;
        }
    }*/
}