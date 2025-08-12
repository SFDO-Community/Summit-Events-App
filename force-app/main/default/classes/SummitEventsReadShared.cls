/**
 * Created by Thad-PC-2019 on 8/11/2025.
 */

public without sharing class SummitEventsReadShared {
    public static Summit_Events_Instance__c getInstanceById(Id instanceId) {
        return [
                SELECT Id, Name, Event__r.Name, Event__r.Event_Name__c, Event__r.Id, Instance_Title__c, Active_Status__c, Capacity__c,
                        Event__r.Event_description__c, Event__r.Audience__c, Current_Available_Capacity__c,
                        Location_Type_Override__c, Location_Address_Override__c, Event__r.Close_Event_Days_Before__c, Location_Map_Link_Override__c, Location_Title_Override__c,
                        Event_Fee_Additional_Allocation_Override__c, Event_Fee_Additional_Override__c, Event_Fee_Override__c, Event_Fee_Allocation_Override__c,
                        Instance_Start_Date__c, Instance_Start_Time__c, Instance_End_Date__c, Instance_End_Time__c, Instance_Time_Zone__c, Registration_Close_Date__c,
                        Registration_Close_Time__c, Event__r.Event_Home_Link_URL__c
                FROM Summit_Events_Instance__c
                WHERE Id = :instanceId
                WITH SECURITY_ENFORCED
        ];
    }

    public static Summit_Events__c getEventById(Id eventId) {
        return [
                SELECT Name, Id, Event_Name__c, Event_description__c, Event_Footer__c, Event_Full_Text__c, Audience__c, Include_Time_frame_List__c,
                        Max_Other_Attendees__c, Allow_Other_Attendees__c, College_High_School_Ask__c, Ask_Gender__c, Template__c,
                        Event_Home_Link_Title__c, Event_Home_Link_URL__c, Ask_If_Parent__c, Ask_Registrant_Program_Of_Interest__c,
                        Add_Info_Question_Pick_List_1__c, Add_Info_Question_Text_1__c, Add_Info_Question_Type_1__c,
                        Add_Info_Question_Pick_List_2__c, Add_Info_Question_Text_2__c, Add_Info_Question_Type_2__c,
                        Add_Info_Question_Pick_List_3__c, Add_Info_Question_Text_3__c, Add_Info_Question_Type_3__c,
                        Add_Info_Question_Pick_List_4__c, Add_Info_Question_Text_4__c, Add_Info_Question_Type_4__c,
                        Add_Info_Question_Pick_List_5__c, Add_Info_Question_Text_5__c, Add_Info_Question_Type_5__c,
                        Academic_Program_List__c, Ask_Mailing_Address__c, Ask_Phone__c, Event_Sponsor__c, Ask_Relationship_To_Institution__c,
                        Ask_Last_Name_As_Student__c, Ask_Preferred_Class_Year__c, Ask_Preferred_First_Name__c,
                        Ask_Applicant_Type__c, Location_Type__c, Location_Title__c, Location_Address__c, Location_Map_Link__c,
                        Tracking_Event_Registration__c, Ask_Date_Of_Birth__c, Event_Type__c, Contact_Creation__c, Contact_Matching_Rules__c,
                        Ask_Third_Party_Registrant__c, Registration_Email_Restriction__c, Ask_Pronoun__c, Keep_Registration_Open_During_Event__c,
                        Close_Event_Days_Before__c, Ask_Title__c, Ask_Company_Organization__c, Event_Fee__c, Event_Fee_Additional__c,
                        Event_Fee_Additional_Allocation__c, Event_Fee_Allocation__c, Display_Optional_Donation__c,
                        Applicant_Type_Label__c, Company_Organization_Label__c, Date_Of_Birth_Label__c, Email_Label__c,
                        First_Name_Label__c, Gender_Label__c, Last_Name_As_Student_Label__c, Last_Name_Label__c, Mailing_Address_Label__c,
                        Phone_Label__c, Phone_Type_Label__c, Preferred_First_Name_Label__c, Pronouns_Label__c, Registrant_Receive_Texts_Label__c,
                        Relationship_To_Institution_Label__c, Third_Party_Registrant_Label__c, Title_Label__c, Preferred_Class_Year_Label__c,
                        Registrant_Relationship_Label__c, Event_Fee_Label__c, Event_Fee_Total_Label__c, Event_Fee_Submit_List_Label__c, Account__r.Name,
                        Filter_Category__c, Do_not_show_receive_text_question__c, Add_Info_Question_Pick_List_Long_1__c, Add_Info_Question_Pick_List_Long_2__c,
                        Add_Info_Question_Pick_List_Long_3__c, Add_Info_Question_Pick_List_Long_4__c, Add_Info_Question_Pick_List_Long_5__c, Event_Status__c,
                        reCAPTCHA_v3_Score_Fail_Text__c, reCAPTCHA__c, Ask_Dietary_Restrictions__c, Dietary_Restrictions_Label__c, Accessibility_Detail_Label__c,
                        Accessibility_Label__c, Ask_Accessibility_Needs__c, Display_Guest_Registration__c, Payment_Gateway__c, Event_Additional_Question_Title__c,
                        Event_Additional_Questions_Description__c
                FROM Summit_Events__c
                WHERE Id = :eventId
                WITH SECURITY_ENFORCED
        ];
    }

    public static Summit_Events_Registration__c getRegistrationById(Id registrationId) {
        return [
                SELECT Registrant_First_Name__c, Registrant_Last_Name__c, Registrant_Email__c, Number_of_Guests__c, Registrant_Applicant_Type__c,
                        Registrant_Gender__c, Registrant_Street_1__c, Registrant_Street_2__c, Registrant_State__c, Registrant_City__c, Preferred_Visit_Time__c,
                        Registrant_Zip__c, Registrant_Phone__c, Registrant_Mobile_Phone__c, Registrant_College__c, Registrant_College_Code__c, Registrant_College_Year__c,
                        Registrant_High_School__c, Registrant_High_School_Code__c, Registrant_Receive_Texts__c, Registrant_High_School_Grad_Year__c, Registrant_High_School_Not_Found__c,
                        Registrant_College_Not_Found__c, Registrant_Parent_First_Name__c, Registrant_Parent_Last_Name__c, Registrant_Parent_Email__c, Registrant_Parent_Phone__c,
                        Add_Info_Answer_1__c, Add_Info_Answer_2__c, Add_Info_Answer_3__c, Add_Info_Answer_4__c, Add_Info_Answer_5__c, Registrant_Program_Interest__c, Registrant_Preferred_First_Name__c,
                        Registrant_Date_of_Birth__c, Last_Name_as_Student__c, Preferred_Class_Year__c, Relationship_To_Institution__c, Registrant_Other_Email__c, Registrant_Other_First_Name__c, Registrant_Other_Last_Name__c,
                        Registrant_Other_Phone__c, Registrant_Other_Relationship__c, Registrant_Country__c, Registrant_State_Province__c, Registrant_Postal_Code__c, Registrant_Third_Party_Status__c,
                        Registrant_Pronouns__c, Registrant_Title__c, Registrant_Company_Organization__c, Event_Website__c, Event_Website_Referrer__c, gclid__c, utm_campaign__c, utm_content__c,
                        utm_creative_format__c, utm_id__c, utm_marketing_tactic__c, utm_medium__c, utm_source__c, utm_source_platform__c, utm_term__c, Dietary_Ristrictions__c,
                        Accessibility_Need__c, Accessibility_Need_Detail__c, reCAPTCHA_Score__c, Registrant_Date_of_Birth_Text__c
                FROM Summit_Events_Registration__c
                WHERE Id = :registrationId
                WITH SECURITY_ENFORCED
        ];
    }

    public static List<Summit_Events_Question__c> getAdditionalQuestionsByEventId(Id eventId) {
        return [
                SELECT Name, Question_Label__c, Question_Field_Type__c, Default_Value__c, Registrant_Type__c, Instructions__c, Help_Text__c, Display_Order__c,
                        Map_to_Field__c, Picklist_Values__c, Text_Limit__c, Controlling_Question__c, Controlling_Logic__c, Required__c, Is_Visible__c, Error_Assist_Text__c,
                        Lookup_Object__c, Lookup_Fields__c, Lookup_Where_Clause__c, Lookup_No_Results_Label__c, Lookup_Secondary_Input_Link_Text__c, Lookup_Secondary_Value_Field__c,
                        Lookup_Secondary_Input_Instructions__c, Lookup_Results_Icon__c, Existing_Picklist_Values__c, Display_Style__c, Picklist_Values_Long__c,
                        Lookup_Order_By__c
                FROM Summit_Events_Question__c
                WHERE Event__c = :eventId
                AND (Registrant_Type__c = 'Registrant' OR Registrant_Type__c = 'Registrant and Guest')
                WITH SECURITY_ENFORCED
                ORDER BY Display_Order__c NULLS LAST
        ];
    }

    public static Integer getAppointmentTypeCount(Id eventId, String instanceTitle, Date startDate, Date endDate, String dayOfWeek) {
        return [
                SELECT COUNT()
                FROM Summit_Events_Appointment_Type__c
                WHERE Summit_Events__c = :eventId
                AND (
                        Chosen_State__c = 'Added'
                        OR (Chosen_State__c = 'Added and Required' AND Auto_Confirm_Appointment__c = FALSE)
                        OR Chosen_State__c = NULL
                )
                AND (
                        Restrict_To_Instance_Title__r.Instance_Title__c = :instanceTitle
                        OR Restrict_To_Instance_Title__r.Instance_Title__c = NULL)
                AND (Date_Available_Start__c <= :startDate OR Date_Available_Start__c = NULL)
                AND (Date_Available_End__c >= :endDate OR Date_Available_End__c = NULL)
                AND (Day_of_Week_Availability__c INCLUDES (:dayOfWeek) OR Day_of_Week_Availability__c = NULL)
                AND (Appointment_Type_Status__c = 'Active' OR Appointment_Type_Status__c = NULL)
                WITH SECURITY_ENFORCED
        ];
    }

    public static Integer getAdditionalQuestionsCount(Id eventId) {
        return [
                SELECT COUNT()
                FROM Summit_Events_Question__c
                WHERE Event__c = :eventId
                AND (Registrant_Type__c = 'Registrant' OR Registrant_Type__c = 'Registrant and Guest')
                WITH SECURITY_ENFORCED
        ];
    }

    public static Integer getGuestQuestionsCount(Id eventId) {
        return [
                SELECT COUNT()
                FROM Summit_Events_Question__c
                WHERE Event__c = :eventId
                AND (Registrant_Type__c = 'Guest' OR Registrant_Type__c = 'Registrant and Guest')
                WITH SECURITY_ENFORCED
        ];
    }

}