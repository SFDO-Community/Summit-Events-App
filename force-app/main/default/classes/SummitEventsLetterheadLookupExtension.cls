// Copyright (c) 2020, Salesforce.org. All rights reserved.
// Use of this source code is governed by a BSD 3-Clause.
// License can be found found in the LICENSE file in this repository.
// Created by Thaddaeus Dahlberg on 10/11/2018.

public with sharing class SummitEventsLetterheadLookupExtension {
    public Summit_Events_Email__c summitEventsEmail { get; set; }
    public Map<Id, BrandTemplate> brandTemplates;
    public Map<Id, OrgWideEmailAddress> oweList;

    public SummitEventsLetterheadLookupExtension(ApexPages.StandardController stdController) {
        summitEventsEmail = [
                SELECT Id, Org_Email__c, Org_Email_Id__c, Letterhead__c,
                        Letterhead_HTML__c, Letterhead_Id__c, Letterhead_Name__c
                FROM Summit_Events_Email__c
                WHERE Id = :stdController.getRecord().Id
        ];
    }


    public List<SelectOption> getOrgWideEmail() {
        oweList = new Map<Id, OrgWideEmailAddress>(
        [
                SELECT Id, Address, DisplayName, IsAllowAllProfiles
                FROM OrgWideEmailAddress
                WHERE IsAllowAllProfiles = TRUE
        ]);
        List<SelectOption> owe = new List<SelectOption>();
        owe.add(new SelectOption('', 'Select...'));
        for (OrgWideEmailAddress e : oweList.values()) {
            owe.add(new SelectOption(e.Id, e.DisplayName + ' (' + e.Address + ')'));
        }
        return owe;
    }

    public List<SelectOption> getLetterheads() {
        brandTemplates = new Map<Id, BrandTemplate>(
        [
                SELECT Id, Name, Value
                FROM BrandTemplate
                WHERE IsActive = TRUE
        ]
        );
        List<SelectOption> brandOptions = new List<SelectOption>();
        brandOptions.add(new SelectOption('', 'Select...'));
        for (BrandTemplate bo : brandTemplates.values()) {
            brandOptions.add(new SelectOption(bo.Id, bo.Name));
        }
        return brandOptions;
    }

    public class styleObject {
        String backgroundColor { get; set; }
        String location { get; set; }
        String height { get; set; }
        String color { get; set; }
        String fontSize { get; set; }
        String fontFam { get; set; }
    }

    public PageReference save() {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your letterhead settings have been saved.'));
        if (!String.isBlank(summitEventsEmail.Org_Email_Id__c)) {
            summitEventsEmail.Org_Email__c = String.valueOf(oweList.get(summitEventsEmail.Org_Email_Id__c).Address);
        }
        String LHTemplate = '';
        if (!String.isBlank(summitEventsEmail.Letterhead_Id__c)) {
            LHTemplate = brandTemplates.get(summitEventsEmail.Letterhead_Id__c).Value;
            summitEventsEmail.Letterhead_Name__c = brandTemplates.get(summitEventsEmail.Letterhead_Id__c).Name;
        }
        String headerImg = '';
        String footerImg = '';

        //rebuilding the letterhead into a template - Why so hard Salesforce?

        // <img*[\w\d\s\n="<>!\[\/\.\?\&\]]*<\/img> -- image regex
        // \<\!\[CDATA\[*[\w\s\/\.\?=&]*]]> -- CDATA regex
        // img and cdata regex combined below
        Pattern TAG_REGEX2 = Pattern.compile('<img*[\\w\\d\\s\\n="<>!\\[\\/\\.\\?\\&\\]]*\\<\\!\\[CDATA\\[(.+?)]]>*<\\/img>');
        Matcher matcher2 = TAG_REGEX2.matcher(LHTemplate);
        Integer matchCounter = 0;
        String imgUrl = 'https://' + Url.getCurrentRequestUrl().getHost();
        while (matcher2.find() == true) {
            if (matchCounter == 0) {
                headerImg = '<img src="' + imgUrl + matcher2.group(1) + '"/>';
            } else if (matchCounter == 1) {
                footerImg = '<img src="' + imgUrl + matcher2.group(1) + '"/>';
            }
            matchCounter++;
        }

        //Get all styles
        // <style*[\s\w\d-="#]*> - style reg ex dosen't grab ending
        Map<String, styleObject> styles = new Map<String, styleObject>();
        Pattern styleRegex = Pattern.compile('<style*[\\s\\w\\d-="#]*>');
        Pattern backgroundStyleRegex = Pattern.compile('background-color="(.+?)"');
        Pattern locationStyleRegex = Pattern.compile('bLabel="(.+?)"');
        Pattern fontSizeStyleRegex = Pattern.compile('font-size="(.+?)"');
        Pattern fontFamilyStyleRegex = Pattern.compile('font-family="(.+?)"');
        Pattern fontColorStyleRegex = Pattern.compile('color="(.+?)"');
        Pattern heightStyleRegex = Pattern.compile('height="(.+?)"');

        Matcher styleMatcher = styleRegex.matcher(LHTemplate);
        while (styleMatcher.find() == true) {
            styleObject so = new styleObject();
            String styleFound = styleMatcher.group();
            //Get background color
            Matcher styleMatcher2 = backgroundStyleRegex.matcher(styleFound);
            while (styleMatcher2.find() == true) {
                so.backgroundColor = styleMatcher2.group(1);
            }
            //get location of style
            styleMatcher2 = locationStyleRegex.matcher(styleFound);
            while (styleMatcher2.find() == true) {
                so.location = styleMatcher2.group(1);
            }
            //get font-size of style
            styleMatcher2 = fontSizeStyleRegex.matcher(styleFound);
            while (styleMatcher2.find() == true) {
                so.fontSize = styleMatcher2.group(1);
            }
            //get font-family of style
            styleMatcher2 = fontFamilyStyleRegex.matcher(styleFound);
            while (styleMatcher2.find() == true) {
                so.fontFam = styleMatcher2.group(1);
            }

            //get font color of style
            styleMatcher2 = fontColorStyleRegex.matcher(styleFound);
            while (styleMatcher2.find() == true) {
                so.color = styleMatcher2.group(1);
            }

            //get font color of style
            styleMatcher2 = heightStyleRegex.matcher(styleFound);
            while (styleMatcher2.find() == true) {
                so.height = styleMatcher2.group(1);
            }
            if (!String.isBlank(so.location)) {
                styles.put(so.location, so);
            }
        }

        String generatedLH = '<html>\n';
        generatedLH += '<style> p { margin-top: 0px; margin-bottom: 0px;} </style>\n';
        generatedLH += '<body ';
        if (styles.get('body') != null) {
            generatedLH += generateStyles(styles.get('body'), true);
        }
        generatedLH += '>\n';
        generatedLH += '<center>\n';
        generatedLH += '<table cellpadding="0" width="500" cellspacing="0" height="450">\n';

        //Generate the header and image
        generatedLH += '    <tr valign="top">\n';
        generatedLH += '        <td ';
        if (styles.get('header') != null) {
            generatedLH += generateStyles(styles.get('header'), true);
        }
        generatedLH += '>\n';
        if (!String.isBlank(headerImg)) {
            generatedLH += headerImg;
        }
        generatedLH += '        </td>\n';
        generatedLH += '    </tr>\n';

        //generate accent1
        generatedLH += '<tr valign="top">\n';
        generatedLH += '<td ';
        if (styles.get('accent1') != null) {
            generatedLH += generateStyles(styles.get('accent1'), true);
        }
        generatedLH += '>\n';
        generatedLH += '</tr>\n';

        //generate main content area
        generatedLH += '<tr valign="top">\n';
        generatedLH += '<td height="300" ';
        if (styles.get('main') != null) {
            generatedLH += generateStyles(styles.get('main'), false);
        }
        generatedLH += '>\n';
        generatedLH += '<table border="0" cellpadding="5" width="550" cellspacing="5" height="400">\n';
        generatedLH += '<tr valign="top" height="400">\n';
        generatedLH += '<td ';
        if (styles.get('main') != null) {
            generatedLH += generateStyles(styles.get('main'), true);
        }
        generatedLH += '>\n';
        generatedLH += '[[DONT_DELETE_CONTENT_HERE]]\n';
        generatedLH += '</td>\n</tr>\n</table>\n</td>\n</tr>';

        //generate accent2
        generatedLH += '<tr valign="top">\n';
        generatedLH += '<td ';
        if (styles.get('accent2') != null) {
            generatedLH += generateStyles(styles.get('accent2'), true);
        }
        generatedLH += '>\n';
        generatedLH += '</tr>\n';

        //Generate the footer and image
        generatedLH += '    <tr valign="top">\n';
        generatedLH += '        <td ';
        if (styles.get('footer') != null) {
            generatedLH += generateStyles(styles.get('footer'), true);
        }
        generatedLH += '>\n';
        if (!String.isBlank(footerImg)) {
            generatedLH += footerImg;
        }
        generatedLH += '        </td>\n';
        generatedLH += '    </tr>\n';

        //generate accent3
        generatedLH += '<tr valign="top">\n';
        generatedLH += '<td ';
        if (styles.get('accent3') != null) {
            generatedLH += generateStyles(styles.get('accent3'), true);
        }
        generatedLH += '>\n';
        generatedLH += '</tr>\n';

        generatedLH += '</table>\n';
        generatedLH += '</center>\n';
        generatedLH += '</body>';

        summitEventsEmail.Letterhead_HTML__c = generatedLH;
        update summitEventsEmail;

        return ApexPages.currentPage();
    }

    public String generateStyles(styleObject stylesIn, Boolean includeID) {
        String sOut = '';
        if (!String.isBlank(stylesIn.location) && includeID) {
            sOut += ' id="' + stylesIn.location + '" ';
        }
        sOut += ' style="';
        if (!String.isBlank(stylesIn.backgroundColor)) {
            sOut += ' background-color:' + stylesIn.backgroundColor + '; ';
        }
        if (!String.isBlank(stylesIn.fontFam)) {
            sOut += ' font-family:' + stylesIn.fontFam + '; ';
        }
        if (!String.isBlank(stylesIn.fontSize)) {
            sOut += ' font-size:' + stylesIn.fontSize + '; ';
        }
        if (!String.isBlank(stylesIn.color)) {
            sOut += ' color:' + stylesIn.color + '; ';
        }
        if (!String.isBlank(stylesIn.height)) {
            sOut += ' height:' + stylesIn.height + 'px; ';
        }
        sOut += '" ';
        return sOut;
    }

}