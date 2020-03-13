BEGIN TRANSACTION;
CREATE TABLE "Account" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"CEEB_Code__c" VARCHAR(255), 
	"Inactive_School__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	parent_id VARCHAR(255), 
	hed__current_address__c VARCHAR(255), 
	hed__primary_contact__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Account" VALUES('0013F00000VUyJAQA1','University of St. Thomas','006110','false','0123F000001Yju4QAC','','','');
INSERT INTO "Account" VALUES('0013F00000VUyfQQAT','Stillwater Area Senior High School','242450','false','0123F000001Yju4QAC','','','');
INSERT INTO "Account" VALUES('0013F00000VUATzQAP','Dahlberg Account','','false','0123F000001Yju2QAC','','','0033F00000N8ntdQAB');
CREATE TABLE "Account_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Account_rt_mapping" VALUES('0123F000001Yju1QAC','Academic_Program');
INSERT INTO "Account_rt_mapping" VALUES('0123F000001Yju2QAC','Administrative');
INSERT INTO "Account_rt_mapping" VALUES('0123F000001Yju3QAC','Business_Organization');
INSERT INTO "Account_rt_mapping" VALUES('0123F000001Yju4QAC','Educational_Institution');
INSERT INTO "Account_rt_mapping" VALUES('0123F000001Yju5QAC','HH_Account');
INSERT INTO "Account_rt_mapping" VALUES('0123F000001Yju6QAC','Sports_Organization');
INSERT INTO "Account_rt_mapping" VALUES('0123F000001Yju7QAC','University_Department');
CREATE TABLE "Contact" (
	sf_id VARCHAR(255) NOT NULL, 
	"FirstName" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"DoNotCall" VARCHAR(255), 
	"Do_Not_Text__c" VARCHAR(255), 
	"Foot_On_Campus__c" VARCHAR(255), 
	"HasOptedOutOfEmail" VARCHAR(255), 
	"HasOptedOutOfFax" VARCHAR(255), 
	"Initial_Foot_on_Campus__c" VARCHAR(255), 
	"Last_Time_on_Campus__c" VARCHAR(255), 
	"Personal_Email__c" VARCHAR(255), 
	"Preferred_Class_Year__c" VARCHAR(255), 
	"Preferred_First_Name__c" VARCHAR(255), 
	"Previous_Last_Name__c" VARCHAR(255), 
	"Special_Athlete_Sport_1__c" VARCHAR(255), 
	"Special_Athlete_Sport_2__c" VARCHAR(255), 
	"Special_Athlete_Sport_3__c" VARCHAR(255), 
	"University_Banner_PIDM__c" VARCHAR(255), 
	"hed__AlternateEmail__c" VARCHAR(255), 
	"hed__Chosen_Full_Name__c" VARCHAR(255), 
	"hed__Citizenship__c" VARCHAR(255), 
	"hed__Country_of_Origin__c" VARCHAR(255), 
	"hed__Deceased__c" VARCHAR(255), 
	"hed__Do_Not_Contact__c" VARCHAR(255), 
	"hed__Dual_Citizenship__c" VARCHAR(255), 
	"hed__Ethnicity__c" VARCHAR(255), 
	"hed__Exclude_from_Household_Formal_Greeting__c" VARCHAR(255), 
	"hed__Exclude_from_Household_Informal_Greeting__c" VARCHAR(255), 
	"hed__Exclude_from_Household_Name__c" VARCHAR(255), 
	"hed__FERPA__c" VARCHAR(255), 
	"hed__Financial_Aid_Applicant__c" VARCHAR(255), 
	"hed__Gender__c" VARCHAR(255), 
	"hed__HIPAA_Detail__c" VARCHAR(255), 
	"hed__HIPAA__c" VARCHAR(255), 
	"hed__Military_Background__c" VARCHAR(255), 
	"hed__Military_Service__c" VARCHAR(255), 
	"hed__Naming_Exclusions__c" VARCHAR(255), 
	"hed__PreferredPhone__c" VARCHAR(255), 
	"hed__Preferred_Email__c" VARCHAR(255), 
	"hed__Primary_Address_Type__c" VARCHAR(255), 
	"hed__Race__c" VARCHAR(255), 
	"hed__Religion__c" VARCHAR(255), 
	"hed__Secondary_Address_Type__c" VARCHAR(255), 
	"hed__Social_Security_Number__c" VARCHAR(255), 
	"hed__UniversityEmail__c" VARCHAR(255), 
	"hed__WorkEmail__c" VARCHAR(255), 
	"hed__WorkPhone__c" VARCHAR(255), 
	"hed__is_Address_Override__c" VARCHAR(255), 
	account_id VARCHAR(255), 
	primary_academic_program__c VARCHAR(255), 
	primary_department__c VARCHAR(255), 
	primary_educational_institution__c VARCHAR(255), 
	primary_sports_organization__c VARCHAR(255), 
	reports_to_id VARCHAR(255), 
	hed__current_address__c VARCHAR(255), 
	hed__primary_household__c VARCHAR(255), 
	hed__primary_language__c VARCHAR(255), 
	hed__primary_organization__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Contact" VALUES('0033F00000N8ntdQAB','Thaddaeus','Dahlberg','false','false','false','false','false','','','','','','','','','','','thad@valleyhilldesign.com','','','','false','false','','','false','false','false','false','false','','','false','','false','','','Alternate Email','','','','','','','','','false','0013F00000VUATzQAP','','','','','','','','','');
CREATE TABLE "Summit_Events_Appointment_Type_Group__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"Appointment_Group_Description__c" VARCHAR(255), 
	"Appointment_Group_Heading__c" VARCHAR(255), 
	"Choosable_Appointment_Amount__c" VARCHAR(255), 
	summit_events__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "Summit_Events_Appointment_Type__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Appointment_Category__c" VARCHAR(255), 
	"Appointment_Fee_Additional__c" VARCHAR(255), 
	"Appointment_Fee__c" VARCHAR(255), 
	"Appointment_Limits__c" VARCHAR(255), 
	"Appointment_Type_Status__c" VARCHAR(255), 
	"Appointment_Type__c" VARCHAR(255), 
	"Auto_Add_Time__c" VARCHAR(255), 
	"Auto_Confirm_Appointment__c" VARCHAR(255), 
	"Auto_add_building__c" VARCHAR(255), 
	"Chosen_State__c" VARCHAR(255), 
	"Custom_Picklist__c" VARCHAR(255), 
	"Date_Available_End__c" VARCHAR(255), 
	"Date_Available_Start__c" VARCHAR(255), 
	"Day_of_Week_Availability__c" VARCHAR(255), 
	"Description__c" VARCHAR(255), 
	"Do_Not_Show_Time__c" VARCHAR(255), 
	"Registrant_Input__c" VARCHAR(255), 
	"Required_Appointment__c" VARCHAR(255), 
	"Sort_Order__c" VARCHAR(255), 
	"Title__c" VARCHAR(255), 
	appointment_fee_additional_attribute__c VARCHAR(255), 
	appointment_fee_attribute__c VARCHAR(255), 
	appointment_group__c VARCHAR(255), 
	restrict_to_instance_title__c VARCHAR(255), 
	summit_events__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('a0U3F000001XoqHUAS','','','','1','Active','','','false','','','Chocolate
Vanilla
Strawberry
Lactose Free','','','','Choose the ice cream you could prefer to consume during your visit','false','Custom pick list','false','10.0','Demo Appointment 1 - Ice Cream with Counselor','','','','','a0e3F0000027n00QAA');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('a0U3F000001XoqIUAS','','','','2','Active','','','false','','','','','','','What is your definition of the meaning of life?','false','Required text box','false','20.0','Demo Appointment 2 - Meaning of life','','','','','a0e3F0000027n00QAA');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('a0U3F000001XoqJUAS','','','','1','Active','','','false','','','','','','','Get yourself some quite time in our library.','false','','false','1.0','Demo Appointment 0 - Quite time','','','','','a0e3F0000027n00QAA');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('a0U3F000001XoqKUAS','','','','1','Active','','','true','','','','','','','There is such a thing!','false','','false','30.0','Demo Appointment 3 - Free Lunch','','','','','a0e3F0000027n00QAA');
CREATE TABLE "Summit_Events_Appointments__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Appointment_Category__c" VARCHAR(255), 
	"Appointment_Contact_Email__c" VARCHAR(255), 
	"Appointment_Contact_Name__c" VARCHAR(255), 
	"Appointment_Date_Time__c" VARCHAR(255), 
	"Appointment_Date__c" VARCHAR(255), 
	"Appointment_Detail__c" VARCHAR(255), 
	"Appointment_Status__c" VARCHAR(255), 
	"Appointment_Time_Options__c" VARCHAR(255), 
	"Appointment_Time__c" VARCHAR(255), 
	"Appointment_Title__c" VARCHAR(255), 
	"Appointment_Type__c" VARCHAR(255), 
	"Building__c" VARCHAR(255), 
	"Chosen_State__c" VARCHAR(255), 
	"Class_Title__c" VARCHAR(255), 
	"Client_Created_Appointment__c" VARCHAR(255), 
	"Description__c" VARCHAR(255), 
	"Do_Not_Show_Time__c" VARCHAR(255), 
	"Faculty_Staff_Member__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"Registrant_Input__c" VARCHAR(255), 
	"Room__c" VARCHAR(255), 
	"Sort_Order__c" VARCHAR(255), 
	event_appointment_type__c VARCHAR(255), 
	event_host__c VARCHAR(255), 
	event_registration__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Summit_Events_Appointments__c" VALUES('a0V3F000001GO5wUAG','','','','','','','Registered','','','Demo Appointment 0 - Quite time','','','','','true','','false','','','','','1.0','a0U3F000001XoqJUAS','','a0c3F000003TykdQAC');
INSERT INTO "Summit_Events_Appointments__c" VALUES('a0V3F000001GO5xUAG','','','','','','','Registered','','','Demo Appointment 1 - Ice Cream with Counselor','','','','','true','Strawberry','false','','','','','10.0','a0U3F000001XoqHUAS','','a0c3F000003TykdQAC');
CREATE TABLE "Summit_Events_Appointments__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Summit_Events_Appointments__c_rt_mapping" VALUES('0123F000001YkfBQAS','Daily_Visit');
CREATE TABLE "Summit_Events_Email__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Action_Status__c" VARCHAR(255), 
	"Action_Sub_status__c" VARCHAR(255), 
	"BCC_Email__c" VARCHAR(255), 
	"Email_Content_Instructions__c" VARCHAR(255), 
	"Email_Content__c" VARCHAR(255), 
	"Email_From__c" VARCHAR(255), 
	"Email_Subject__c" VARCHAR(255), 
	"Letterhead_HTML__c" VARCHAR(255), 
	"Letterhead_Id__c" VARCHAR(255), 
	"Letterhead_Name__c" VARCHAR(255), 
	"Letterhead__c" VARCHAR(255), 
	"Org_Email_Id__c" VARCHAR(255), 
	"Org_Email__c" VARCHAR(255), 
	event__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "Summit_Events_Fee_Attribute__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"Banner_Index__c" VARCHAR(255), 
	"FOAPAL__c" VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Summit_Events_Fee_Attribute__c" VALUES('a0X3F000005dPXiUAM','Green Fund','1111111','');
INSERT INTO "Summit_Events_Fee_Attribute__c" VALUES('a0X3F000005dPXdUAM','Basketball Team','123455','');
INSERT INTO "Summit_Events_Fee_Attribute__c" VALUES('a0X3F000005dPXYUA2','Football Team','123456','');
CREATE TABLE "Summit_Events_Fee__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Description__c" VARCHAR(255), 
	"Event_Fee__c" VARCHAR(255), 
	"Fee_Type__c" VARCHAR(255), 
	event_appointment_type__c VARCHAR(255), 
	event_fee_attribute__c VARCHAR(255), 
	event_registration__c VARCHAR(255), 
	summit_events_payment__c VARCHAR(255), 
	summit_events__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Summit_Events_Fee__c" VALUES('a0Y3F000001rBJnUAM','','20.0','Optional Donation','','a0X3F000005dPXdUAM','a0c3F000003TykdQAC','','a0e3F0000027n00QAA');
CREATE TABLE "Summit_Events_Host__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Additional_Comments__c" VARCHAR(255), 
	"Assigned__c" VARCHAR(255), 
	"Building__c" VARCHAR(255), 
	"Course_Name__c" VARCHAR(255), 
	"Department__c" VARCHAR(255), 
	"First_Name__c" VARCHAR(255), 
	"Gender__c" VARCHAR(255), 
	"Last_Name__c" VARCHAR(255), 
	"Location__c" VARCHAR(255), 
	"Max_Available__c" VARCHAR(255), 
	"Preferred_Title__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"Time__c" VARCHAR(255), 
	"Undergrad_Major__c" VARCHAR(255), 
	contact__c VARCHAR(255), 
	event_instance__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "Summit_Events_Host__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
CREATE TABLE "Summit_Events_Instance__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Active_Status__c" VARCHAR(255), 
	"Alternate_Registration_URL_Override__c" VARCHAR(255), 
	"Attendee_List__c" VARCHAR(255), 
	"Banner_Event_Code__c" VARCHAR(255), 
	"Banner_Event_Function_Code__c" VARCHAR(255), 
	"Building_Override__c" VARCHAR(255), 
	"Capacity__c" VARCHAR(255), 
	"Category__c" VARCHAR(255), 
	"End_Date_Time__c" VARCHAR(255), 
	"Event_Instance_Fee_Additional__c" VARCHAR(255), 
	"Event_Instance_Fee__c" VARCHAR(255), 
	"Feed_Registration_Button_Text_Override__c" VARCHAR(255), 
	"Instance_Short_Description__c" VARCHAR(255), 
	"Instance_Title__c" VARCHAR(255), 
	"Location_Address_Override__c" VARCHAR(255), 
	"Location_Map_Link_Override__c" VARCHAR(255), 
	"Location_Title_Override__c" VARCHAR(255), 
	"Location_Type_Override__c" VARCHAR(255), 
	"Start_Date_Time__c" VARCHAR(255), 
	event_instance_fee_additional_attribute__c VARCHAR(255), 
	event_instance_fee_attribute__c VARCHAR(255), 
	event__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Summit_Events_Instance__c" VALUES('a0a3F000003JblGQAS','Active','','false','','','','100.0','','2020-02-18T08:00:00.000Z','','','','','','','','','','2020-02-18T12:00:00.000Z','','','a0e3F0000027n00QAA');
INSERT INTO "Summit_Events_Instance__c" VALUES('a0a3F000003JblHQAS','Active','','false','','','','100.0','','2020-02-25T08:00:00.000Z','','','','','','','','','','2020-02-25T12:00:00.000Z','','','a0e3F0000027n00QAA');
CREATE TABLE "Summit_Events_Payment__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Account_Number__c" VARCHAR(255), 
	"Address_1__c" VARCHAR(255), 
	"Address_2__c" VARCHAR(255), 
	"Card_Type__c" VARCHAR(255), 
	"City__c" VARCHAR(255), 
	"Country__c" VARCHAR(255), 
	"Email_Address__c" VARCHAR(255), 
	"GatewayApprovalCode__c" VARCHAR(255), 
	"Gateway_Session_Identifier__c" VARCHAR(255), 
	"Method_of_Payment__c" VARCHAR(255), 
	"Name_On_Account__c" VARCHAR(255), 
	"Payment_Amount__c" VARCHAR(255), 
	"Payment_Defer_Date__c" VARCHAR(255), 
	"Payment_Dispute__c" VARCHAR(255), 
	"Payment_Email_Address__c" VARCHAR(255), 
	"Payment_Forfeit_Date__c" VARCHAR(255), 
	"Payment_Method_Expiration_Date__c" VARCHAR(255), 
	"Payment_Method__c" VARCHAR(255), 
	"Payment_Received_Date__c" VARCHAR(255), 
	"Payment_Refund_Date__c" VARCHAR(255), 
	"Payment_Returned_Date__c" VARCHAR(255), 
	"Payment_Status__c" VARCHAR(255), 
	"Phone__c" VARCHAR(255), 
	"State__c" VARCHAR(255), 
	"TouchnetReceiptNumber__c" VARCHAR(255), 
	"Zip__c" VARCHAR(255), 
	event_registration__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "Summit_Events_Registration__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Actual_Number_of_Guests__c" VARCHAR(255), 
	"Add_Info_Answer_1__c" VARCHAR(255), 
	"Add_Info_Answer_2__c" VARCHAR(255), 
	"Add_Info_Answer_3__c" VARCHAR(255), 
	"Add_Info_Answer_4__c" VARCHAR(255), 
	"Add_Info_Answer_5__c" VARCHAR(255), 
	"Appointment_Table__c" VARCHAR(255), 
	"Campus_Tour_Location__c" VARCHAR(255), 
	"Campus_Tour_Time__c" VARCHAR(255), 
	"Confirmation_Call_Result__c" VARCHAR(255), 
	"Contact_Soft_Match_Email__c" VARCHAR(255), 
	"Contact_Soft_Match_First_Last_Zip__c" VARCHAR(255), 
	"Date_All_Appointments_Confirmed_del__c" VARCHAR(255), 
	"Date__c" VARCHAR(255), 
	"Display_Attendance_Publicly__c" VARCHAR(255), 
	"Generated_Itinerary__c" VARCHAR(255), 
	"Generated_Requested_Appointments__c" VARCHAR(255), 
	"Instance__c" VARCHAR(255), 
	"Last_Name_as_Student__c" VARCHAR(255), 
	"Matching_Log__c" VARCHAR(255), 
	"New_Contact_Created__c" VARCHAR(255), 
	"Number_of_Guests__c" VARCHAR(255), 
	"Participation_Type__c" VARCHAR(255), 
	"Preferred_St_Thomas_Class_Year__c" VARCHAR(255), 
	"Preferred_Visit_Time__c" VARCHAR(255), 
	"Presentation_Location__c" VARCHAR(255), 
	"Presentation_Time__c" VARCHAR(255), 
	"Registrant_Applicant_Type__c" VARCHAR(255), 
	"Registrant_City__c" VARCHAR(255), 
	"Registrant_College_Code__c" VARCHAR(255), 
	"Registrant_College_Not_Found__c" VARCHAR(255), 
	"Registrant_College_Year__c" VARCHAR(255), 
	"Registrant_College__c" VARCHAR(255), 
	"Registrant_Country__c" VARCHAR(255), 
	"Registrant_Date_of_Birth__c" VARCHAR(255), 
	"Registrant_Do_Not_Call__c" VARCHAR(255), 
	"Registrant_Email__c" VARCHAR(255), 
	"Registrant_First_Name__c" VARCHAR(255), 
	"Registrant_Gender__c" VARCHAR(255), 
	"Registrant_High_School_Code__c" VARCHAR(255), 
	"Registrant_High_School_Grad_Year__c" VARCHAR(255), 
	"Registrant_High_School_Not_Found__c" VARCHAR(255), 
	"Registrant_High_School__c" VARCHAR(255), 
	"Registrant_Last_Name__c" VARCHAR(255), 
	"Registrant_Mobile_Phone__c" VARCHAR(255), 
	"Registrant_Other_Email__c" VARCHAR(255), 
	"Registrant_Other_First_Name__c" VARCHAR(255), 
	"Registrant_Other_Last_Name__c" VARCHAR(255), 
	"Registrant_Other_Phone__c" VARCHAR(255), 
	"Registrant_Other_Relationship__c" VARCHAR(255), 
	"Registrant_Parent_Email__c" VARCHAR(255), 
	"Registrant_Parent_First_Name__c" VARCHAR(255), 
	"Registrant_Parent_Last_Name__c" VARCHAR(255), 
	"Registrant_Parent_Phone__c" VARCHAR(255), 
	"Registrant_Parent_Status__c" VARCHAR(255), 
	"Registrant_Phone__c" VARCHAR(255), 
	"Registrant_Postal_Code__c" VARCHAR(255), 
	"Registrant_Preferred_First_Name__c" VARCHAR(255), 
	"Registrant_Program_Interest__c" VARCHAR(255), 
	"Registrant_Receive_Texts__c" VARCHAR(255), 
	"Registrant_State_Global__c" VARCHAR(255), 
	"Registrant_State_Province__c" VARCHAR(255), 
	"Registrant_State__c" VARCHAR(255), 
	"Registrant_Street_1__c" VARCHAR(255), 
	"Registrant_Street_2__c" VARCHAR(255), 
	"Registrant_Zip__c" VARCHAR(255), 
	"Relationship_to_St_Thomas__c" VARCHAR(255), 
	"Reminder_Call_Complete__c" VARCHAR(255), 
	"Session__c" VARCHAR(255), 
	"Status__c" VARCHAR(255), 
	"Substatus__c" VARCHAR(255), 
	contact__c VARCHAR(255), 
	event_instance__c VARCHAR(255), 
	event__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Summit_Events_Registration__c" VALUES('a0c3F000003TykdQAC','','Green','','','','','','','','','','','','2020-02-18','false','','<table><tr><td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000;  padding-top:5px; padding-bottom:10px; ">Demo Appointment 0 - Quite time</td></tr><tr><td style="vertical-align:top; text-align:left; font-family:arial; font-size:12pt; color:#000000;  padding-top:5px; padding-bottom:10px; ">Demo Appointment 1 - Ice Cream with Counselor</td></tr></table>','','','<div class="slds-text-heading_small slds-m-vertical_medium">New contact created!</div><table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered slds-size_1-of-1"><thead><tr class="slds-line-height_reset"><th colspan="1" rowspan="1" class=""><div class="slds-truncate" title="Last Name">Last Name</div></th><th colspan="1" rowspan="1" class=""><div class="slds-truncate" title="First Name">First Name</div></th><th colspan="1" rowspan="1" class=""><div class="slds-truncate" title="Email">Email</div></th><th colspan="1" rowspan="1" class=""><div class="slds-truncate" title="Zip">Zip</div></th><th colspan="1" rowspan="1" class=""><div class="slds-truncate" title="Action">Action</div></th></tr></thead><tbody><tr class="slds-hint-parent"><td colspan="1" rowspan="1"><div class="slds-truncate"><a href="/0033F00000N8ntdQAB" target="_blank">Dahlberg</a></div></td><td colspan="1" rowspan="1"><div class="slds-truncate"><a href="/0033F00000N8ntdQAB" target="_blank">Thaddaeus</a></div></td><td colspan="1" rowspan="1"><div class="slds-truncate">thad@valleyhilldesign.com</div></td><td colspan="1" rowspan="1"><div class="slds-truncate">null</div></td><td colspan="1" rowspan="1"><div class="slds-truncate"> --- </div></td></tr></tbody></table>','true','','','','','','','First-Year','Minneapolis','','','','','United States','','false','thad@valleyhilldesign.com','Thaddaeus','','','','','','Dahlberg','','','','','','','','','','','','','','Thad','','true','','','MN','123 Electric Ave','','55418','','false','','Started','','0033F00000N8ntdQAB','a0a3F000003JblGQAS','a0e3F0000027n00QAA');
CREATE TABLE "Summit_Events__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"Academic_Program_List_Selected__c" VARCHAR(255), 
	"Academic_Program_List__c" VARCHAR(255), 
	"Academic_Program_Selected__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_1__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_2__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_3__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_4__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_5__c" VARCHAR(255), 
	"Add_Info_Question_Text_1__c" VARCHAR(255), 
	"Add_Info_Question_Text_2__c" VARCHAR(255), 
	"Add_Info_Question_Text_3__c" VARCHAR(255), 
	"Add_Info_Question_Text_4__c" VARCHAR(255), 
	"Add_Info_Question_Text_5__c" VARCHAR(255), 
	"Add_Info_Question_Type_1__c" VARCHAR(255), 
	"Add_Info_Question_Type_2__c" VARCHAR(255), 
	"Add_Info_Question_Type_3__c" VARCHAR(255), 
	"Add_Info_Question_Type_4__c" VARCHAR(255), 
	"Add_Info_Question_Type_5__c" VARCHAR(255), 
	"Allow_Other_Attendees__c" VARCHAR(255), 
	"Alternate_Registration_URL__c" VARCHAR(255), 
	"Applicant_Type__c" VARCHAR(255), 
	"Ask_Date_Of_Birth__c" VARCHAR(255), 
	"Ask_Gender__c" VARCHAR(255), 
	"Ask_If_Parent__c" VARCHAR(255), 
	"Ask_Mailing_Address__c" VARCHAR(255), 
	"Ask_Phone__c" VARCHAR(255), 
	"Ask_Program_Interest__c" VARCHAR(255), 
	"Ask_Registrant_Program_Of_Interest__c" VARCHAR(255), 
	"Audience__c" VARCHAR(255), 
	"Building__c" VARCHAR(255), 
	"Close_Event_Days_Before__c" VARCHAR(255), 
	"College_High_School_Ask__c" VARCHAR(255), 
	"Contact_Creation__c" VARCHAR(255), 
	"Display_Optional_Donation__c" VARCHAR(255), 
	"Donation_Description__c" VARCHAR(255), 
	"Donation_Suggested_Amount_List__c" VARCHAR(255), 
	"End_Date__c" VARCHAR(255), 
	"Event_Appointment_Description__c" VARCHAR(255), 
	"Event_Appointment_Title__c" VARCHAR(255), 
	"Event_Cancel_Review_Description__c" VARCHAR(255), 
	"Event_Cancel_Review_Title__c" VARCHAR(255), 
	"Event_Cancelled_Notification_Text__c" VARCHAR(255), 
	"Event_Confirmation_Description__c" VARCHAR(255), 
	"Event_Confirmation_Title__c" VARCHAR(255), 
	"Event_Fee_Additional__c" VARCHAR(255), 
	"Event_Fee__c" VARCHAR(255), 
	"Event_Footer__c" VARCHAR(255), 
	"Event_Full_Text__c" VARCHAR(255), 
	"Event_Home_Link_Title__c" VARCHAR(255), 
	"Event_Home_Link_URL__c" VARCHAR(255), 
	"Event_Name__c" VARCHAR(255), 
	"Event_Short_Listing_Description__c" VARCHAR(255), 
	"Event_Sponsor__c" VARCHAR(255), 
	"Event_Status__c" VARCHAR(255), 
	"Event_Submit_Description__c" VARCHAR(255), 
	"Event_Submit_Title__c" VARCHAR(255), 
	"Event_Type__c" VARCHAR(255), 
	"Event_description__c" VARCHAR(255), 
	"Feed_Registration_Button_Text__c" VARCHAR(255), 
	"Hand_Raise_Action__c" VARCHAR(255), 
	"Include_Time_frame_List__c" VARCHAR(255), 
	"Location_Address__c" VARCHAR(255), 
	"Location_Map_Link__c" VARCHAR(255), 
	"Location_Title__c" VARCHAR(255), 
	"Location_Type__c" VARCHAR(255), 
	"Max_Other_Attendees__c" VARCHAR(255), 
	"Portal_Login_Required__c" VARCHAR(255), 
	"Private_Event__c" VARCHAR(255), 
	"Program_Filter_2__c" VARCHAR(255), 
	"Program_Filter_3__c" VARCHAR(255), 
	"Program_Filter__c" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"Start_Date__c" VARCHAR(255), 
	"Template__c" VARCHAR(255), 
	"Tracking_Cancel_Registration__c" VARCHAR(255), 
	"Tracking_Confirmation_Registration__c" VARCHAR(255), 
	"Tracking_Event_Registration__c" VARCHAR(255), 
	"Tracking_Options_Registration__c" VARCHAR(255), 
	"Tracking_Submit_Registration__c" VARCHAR(255), 
	donation_recipient_1__c VARCHAR(255), 
	donation_recipient_2__c VARCHAR(255), 
	donation_recipient_3__c VARCHAR(255), 
	donation_recipient_4__c VARCHAR(255), 
	donation_recipient_5__c VARCHAR(255), 
	event_fee_additional_attribute__c VARCHAR(255), 
	event_fee_attribute__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "Summit_Events__c" VALUES('a0e3F0000027n00QAA','Test Event','','','','Red
Yellow
Green
Blue','','','','','What is your favorite color?','','','','','Pick-list','','','','','false','','','false','','false','true','true','false','','High School Senior','','0.0','','Full matching contact creation with duplicate management','true','<p>Hey, How about donating extra?</p>','10
20
30
40
50
$100
500
1,000',date('now', 'start of day', '+30 day'),'Body text for the appointment/options page explains what these appointments are about.','This is the header of the appointment/options page.','What does it mean to cancel a event.','Online Cancel of Registration Heading','The event has been cancelled.','Explain the registration has been received from the client at this point and is complete','Registration has been received title.','','','This footer appears on every event registration page in the footer.','Explain here that the event has reached capacity and is closed.','Event Home','','Test Event','This description appears in feed and should be concise','','Active','Description of submission being the final act in the registration play.','Heading for the Submit Page','Admissions Event','<p><strong>Rich Text</strong> description of the event that appears on the first registration page.</p>','Register','Touchpoint','false','','','','','','false','false','','','','',date('now', 'start of day', '-30 day'),'CastorTemplate2017','','','','','','a0X3F000005dPXYUA2','a0X3F000005dPXdUAM','a0X3F000005dPXiUAM','','','','');
CREATE TABLE "Summit_Events__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Summit_Events__c_rt_mapping" VALUES('0123F000001YkfHQAS','Graduate');
INSERT INTO "Summit_Events__c_rt_mapping" VALUES('0123F000001YkfIQAS','UDAR');
INSERT INTO "Summit_Events__c_rt_mapping" VALUES('0123F000001YkfJQAS','Undergraduate');
CREATE TABLE "hed__Address__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"hed__Address_Type__c" VARCHAR(255), 
	"hed__Default_Address__c" VARCHAR(255), 
	"hed__Latest_End_Date__c" VARCHAR(255), 
	"hed__Latest_Start_Date__c" VARCHAR(255), 
	"hed__MailingCity__c" VARCHAR(255), 
	"hed__MailingCountry__c" VARCHAR(255), 
	"hed__MailingPostalCode__c" VARCHAR(255), 
	"hed__MailingState__c" VARCHAR(255), 
	"hed__MailingStreet2__c" VARCHAR(255), 
	"hed__MailingStreet__c" VARCHAR(255), 
	"hed__Seasonal_End_Day__c" VARCHAR(255), 
	"hed__Seasonal_End_Month__c" VARCHAR(255), 
	"hed__Seasonal_End_Year__c" VARCHAR(255), 
	"hed__Seasonal_Start_Day__c" VARCHAR(255), 
	"hed__Seasonal_Start_Month__c" VARCHAR(255), 
	"hed__Seasonal_Start_Year__c" VARCHAR(255), 
	hed__parent_account__c VARCHAR(255), 
	hed__parent_contact__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Facility__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	"hed__Capacity__c" VARCHAR(255), 
	"hed__Description__c" VARCHAR(255), 
	"hed__Facility_Type__c" VARCHAR(255), 
	hed__account__c VARCHAR(255), 
	hed__parent_facility__c VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
CREATE TABLE "hed__Language__c" (
	sf_id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S0R000001ygZDUAY','Summit Events Appointment for Sports Contact Receipt','true','false','SummitEventsAppointmentSports_TDTM','','','','Summit_Events_Appointments__c','','AfterInsert','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S0R000001ygZ8UAI','Summit Events Transactional Emails','true','false','SummitEventsRegistration_TDTM','','','','Summit_Events_Registration__c','','AfterInsert;AfterUpdate','false','');
INSERT INTO "hed__Trigger_Handler__c" VALUES('a0S0R000001ygZ9UAI','Summit Events Appointment Itinerary','true','false','SummitEventsAppointmentItinerary_TDTM','','','','Summit_Events_Appointments__c','','AfterInsert;AfterUpdate;AfterDelete;AfterUndelete','false','');
COMMIT;
