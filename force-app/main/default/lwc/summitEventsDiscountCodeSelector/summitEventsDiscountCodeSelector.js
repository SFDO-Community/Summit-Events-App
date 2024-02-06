/**
 * Created by dahl3702 on 2/6/2024.
 */

import {api, LightningElement, wire} from 'lwc';
import {getRecord} from "lightning/uiRecordApi";
//import apex
import getDiscountCodes from "@salesforce/apex/SummitEventsDiscountCodeShared.getDiscountCodes";
// import all the fields from the summit_events_discount_code__c object
import CODE_ACTIVE_FIELD from "@salesforce/schema/Summit_Events_Discount_Code__c.ACTIVE__c";
import CODE_DESCRIPTION_FIELD from "@salesforce/schema/Summit_Events_Discount_Code__c.Description__c";
import CODE_DISCOUNT_FIELD from "@salesforce/schema/Summit_Events_Discount_Code__c.Discount__c";
import CODE_CODE_FIELD from "@salesforce/schema/Summit_Events_Discount_Code__c.Discount_Code__c";
import CODE_END_DATE_FIELD from "@salesforce/schema/Summit_Events_Discount_Code__c.End_Date__c";
import CODE_STATUS_FIELD from "@salesforce/schema/Summit_Events_Discount_Code__c.Status__c";
import CODE_TYPE_FIELD from "@salesforce/schema/Summit_Events_Discount_Code__c.Type__c";

const CODE_FIELDS = [
    CODE_ACTIVE_FIELD,
    CODE_DESCRIPTION_FIELD,
    CODE_DISCOUNT_FIELD,
    CODE_CODE_FIELD,
    CODE_END_DATE_FIELD,
    CODE_STATUS_FIELD,
    CODE_TYPE_FIELD
];


export default class SummitEventsDiscountCodeSelector extends LightningElement {
    columns = [
        {
            label: 'Question',
            fieldName: 'questionLabel',
            type: 'text',
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Question Type',
            fieldName: 'questionType',
            type: 'text',
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Field to Apply to',
            fieldName: 'fieldToApplyTo',
            type: 'text',
            wrapText: true,
            hideDefaultActions: true
        },
        {
            label: 'Picklist Values',
            fieldName: 'picklistValuesFlat',
            type: 'text',
            wrapText: true,
            hideDefaultActions: true
        },
        {
            type: "button-icon",
            initialWidth: 45,
            wrapText: true,
            typeAttributes: {
                name: 'up',
                title: 'Move Up',
                value: 'up',
                iconPosition: 'center',
                iconName: 'utility:arrowup'
            }
        },
        {
            type: "button-icon",
            initialWidth: 45,
            wrapText: true,
            typeAttributes: {
                name: 'down',
                title: 'Move Down',
                value: 'down',
                iconPosition: 'center',
                iconName: 'utility:arrowdown',
            }
        },
        {
            type: "button-icon",
            initialWidth: 45,
            wrapText: true,
            typeAttributes: {
                name: 'delete',
                title: 'Delete Item',
                value: 'delete',
                iconPosition: 'center',
                iconName: 'utility:delete',
            }
        }
    ];

    @api recordId;

    @wire(getDiscountCodes) discountCodes;


}