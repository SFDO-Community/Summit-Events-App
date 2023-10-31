BEGIN TRANSACTION;
CREATE TABLE "Account" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"ParentId" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Contact" (
	id INTEGER NOT NULL, 
	"Created_with_Summit_Events__c" VARCHAR(255), 
	"DoNotCall" VARCHAR(255), 
	"FirstName" VARCHAR(255), 
	"HasOptedOutOfEmail" VARCHAR(255), 
	"HasOptedOutOfFax" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"AccountId" VARCHAR(255), 
	"ReportsToId" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Lead" (
	id INTEGER NOT NULL, 
	"Company" VARCHAR(255), 
	"DoNotCall" VARCHAR(255), 
	"FirstName" VARCHAR(255), 
	"HasOptedOutOfEmail" VARCHAR(255), 
	"HasOptedOutOfFax" VARCHAR(255), 
	"IsConverted" VARCHAR(255), 
	"IsUnreadByOwner" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"Status" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Summit_Events_Appointment_Type__c" (
	id INTEGER NOT NULL, 
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
	"Appointment_Fee_Additional_Allocation__c" VARCHAR(255), 
	"Appointment_Fee_Allocation__c" VARCHAR(255), 
	"Restrict_To_Instance_Title__c" VARCHAR(255), 
	"Summit_Events__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(1,'','','','1','Active','','','False','','','','','','','<p>Get yourself some quiet time in our library.</p>','False','','False','1.0','Demo Appointment 0 - Quiet Time','','','','2');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(2,'','','','1','Active','','','False','','','','','','','There is such a thing!','False','','False','30.0','Demo Appointment 3 - Free Lunch','','','','2');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(3,'','','','1','Active','','','False','','','Chocolate

Vanilla

Strawberry

Lactose Free','','','','Choose the ice cream you could prefer to consume during your visit','False','Custom pick list','False','10.0','Demo Appointment 1 - Ice Cream with Counselor','','','','2');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(4,'','','','2','Active','','','False','','','','','','','What is your definition of the meaning of life?','False','Required text box','False','20.0','Demo Appointment 2 - Meaning of life','','','','2');
CREATE TABLE "Summit_Events_Appointments__c" (
	id INTEGER NOT NULL, 
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
	"Appointment_Virtual_Meeting_URL__c" VARCHAR(255), 
	"Building__c" VARCHAR(255), 
	"Chosen_State__c" VARCHAR(255), 
	"Class_Title__c" VARCHAR(255), 
	"Client_Created_Appointment__c" VARCHAR(255), 
	"Description__c" VARCHAR(255), 
	"Do_Not_Show_Time__c" VARCHAR(255), 
	"Faculty_Staff_Member__c" VARCHAR(255), 
	"Registrant_Input__c" VARCHAR(255), 
	"Room__c" VARCHAR(255), 
	"Sort_Order__c" VARCHAR(255), 
	"Event_Appointment_Type__c" VARCHAR(255), 
	"Event_Host__c" VARCHAR(255), 
	"Event_Registration__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Summit_Events_Email__c" (
	id INTEGER NOT NULL, 
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
	"Event__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Summit_Events_Fee_Allocation__c" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Summit_Events_Fee__c" (
	id INTEGER NOT NULL, 
	"Description__c" VARCHAR(255), 
	"Event_Fee_Type__c" VARCHAR(255), 
	"Event_Fee__c" VARCHAR(255), 
	"Event_Appointment_Type__c" VARCHAR(255), 
	"Event_Fee_Allocation__c" VARCHAR(255), 
	"Event_Registration__c" VARCHAR(255), 
	"Summit_Events_Payment__c" VARCHAR(255), 
	"Summit_Events__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Summit_Events_Fee__c" VALUES(1,'','Event','0.0','','','5','','');
CREATE TABLE "Summit_Events_Host__c" (
	id INTEGER NOT NULL, 
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
	"Contact__c" VARCHAR(255), 
	"Event_Instance__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Summit_Events_Host__c_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	PRIMARY KEY (record_type_id)
);
CREATE TABLE "Summit_Events_Instance__c" (
	id INTEGER NOT NULL, 
	"Active_Status__c" VARCHAR(255), 
	"Alternate_Registration_URL_Override__c" VARCHAR(255), 
	"Attendee_List__c" VARCHAR(255), 
	"Building_Override__c" VARCHAR(255), 
	"Capacity_Control__c" VARCHAR(255), 
	"Capacity__c" VARCHAR(255), 
	"Category__c" VARCHAR(255), 
	"Event_Fee_Additional_Override__c" VARCHAR(255), 
	"Event_Fee_Override__c" VARCHAR(255), 
	"Feed_Registration_Button_Text_Override__c" VARCHAR(255), 
	"Instance_End_Date__c" VARCHAR(255), 
	"Instance_End_Time__c" VARCHAR(255), 
	"Instance_Short_Description__c" VARCHAR(255), 
	"Instance_Start_Date__c" VARCHAR(255), 
	"Instance_Start_Time__c" VARCHAR(255), 
	"Instance_Time_Zone__c" VARCHAR(255), 
	"Instance_Title__c" VARCHAR(255), 
	"Location_Address_Override__c" VARCHAR(255), 
	"Location_Map_Link_Override__c" VARCHAR(255), 
	"Location_Title_Override__c" VARCHAR(255), 
	"Location_Type_Override__c" VARCHAR(255), 
	"Private_Instance__c" VARCHAR(255), 
	"Virtual_Appointment_Link__c" VARCHAR(255), 
	"Virtual_Meeting_Link__c" VARCHAR(255), 
	"Event_Fee_Additional_Allocation_Override__c" VARCHAR(255), 
	"Event_Fee_Allocation_Override__c" VARCHAR(255), 
	"Event__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Summit_Events_Instance__c" VALUES(1,'Active','','False','','Registrants plus Guests','100.0','','','','','2023-11-12','12:30:00.000Z','Testing additional questions with this event.','2023-11-12','08:00:00.000Z','Central Daylight Time (America/Chicago)','Secondary Title','','','','','False','','','','','1');
INSERT INTO "Summit_Events_Instance__c" VALUES(2,'Active','','False','','Registrants plus Guests','100.0','','','','','2023-11-03','15:30:00.000Z','A short description','2023-11-03','08:00:00.000Z','Central Daylight Time (America/Chicago)','Secondary Title','','','','','False','','','','','2');
INSERT INTO "Summit_Events_Instance__c" VALUES(3,'Active','','False','','Registrants plus Guests','100.0','','','','','2023-11-10','13:15:00.000Z','A short description','2023-11-10','09:00:00.000Z','Central Daylight Time (America/Chicago)','A special Title','','','','','False','','','','','2');
INSERT INTO "Summit_Events_Instance__c" VALUES(4,'Active','','False','','Registrants plus Guests','1000.0','','','','','2023-11-16','16:00:00.000Z','Test event for gathering guest registrations from registrant.','2023-11-16','12:00:00.000Z','Central Daylight Time (America/Chicago)','Secondary Title','','','','','False','','','','','3');
INSERT INTO "Summit_Events_Instance__c" VALUES(5,'Active','','False','','Registrants plus Guests','500.0','','','','','2023-11-16','23:00:00.000Z','Annual Dinner & Auction','2023-11-16','18:00:00.000Z','Central Daylight Time (America/Mexico_City)','Annual Dinner & Auction','','','','','False','','','','','4');
INSERT INTO "Summit_Events_Instance__c" VALUES(6,'Active','','False','','Registrants plus Guests','20.0','','','','','2023-12-08','20:30:00.000Z','December 2023 Caregiver Support','2023-12-08','19:00:00.000Z','Eastern Standard Time (America/Panama)','December 2023 Caregiver Support','','','','','False','','','','','5');
INSERT INTO "Summit_Events_Instance__c" VALUES(7,'Active','','False','','Registrants plus Guests','20.0','','','','','2024-03-08','20:30:00.000Z','March 2024 Caregiver Support','2024-03-08','19:00:00.000Z','Eastern Standard Time (America/Panama)','March 2024 Caregiver Support','','','','','False','','','','','5');
INSERT INTO "Summit_Events_Instance__c" VALUES(8,'Active','','False','','Registrants plus Guests','20.0','','','','','2024-02-09','20:30:00.000Z','February 2024 Caregiver Support','2024-02-09','19:00:00.000Z','Eastern Standard Time (America/Panama)','February 2024 Caregiver Support','','','','','False','','','','','5');
INSERT INTO "Summit_Events_Instance__c" VALUES(9,'Active','','False','','Registrants plus Guests','20.0','','','','','2024-01-12','20:30:00.000Z','December 2024 Caregiver Support','2024-01-12','19:00:00.000Z','Eastern Standard Time (America/Panama)','January 2024 Caregiver Support','','','','','False','','','','','5');
INSERT INTO "Summit_Events_Instance__c" VALUES(10,'Active','','False','','Registrants plus Guests','20.0','','','','','2024-05-10','20:30:00.000Z','May 2024 Caregiver Support','2024-05-10','19:00:00.000Z','Eastern Standard Time (America/Panama)','May 2024 Caregiver Support','','','','','False','','','','','5');
INSERT INTO "Summit_Events_Instance__c" VALUES(11,'Active','','False','','Registrants plus Guests','20.0','','','','','2024-04-12','20:30:00.000Z','April 2024 Caregiver Support','2024-04-12','19:00:00.000Z','Eastern Standard Time (America/Panama)','April 2024 Caregiver Support','','','','','False','','','','','5');
INSERT INTO "Summit_Events_Instance__c" VALUES(12,'Active','','False','','Registrants plus Guests','72.0','','','','','2024-06-04','15:00:00.000Z','2024 Fundraising Golf Event','2024-06-04','09:00:00.000Z','Eastern Standard Time (America/Panama)','2024 Fundraising Golf Event','','','','','False','','','','','6');
CREATE TABLE "Summit_Events_Payment__c" (
	id INTEGER NOT NULL, 
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
	"Event_Registration__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Summit_Events_Question__c" (
	id INTEGER NOT NULL, 
	"Controlling_Logic__c" VARCHAR(255), 
	"Default_Value__c" VARCHAR(255), 
	"Display_Order__c" VARCHAR(255), 
	"Display_Style__c" VARCHAR(255), 
	"Error_Assist_Text__c" VARCHAR(255), 
	"Existing_Picklist_Values__c" VARCHAR(255), 
	"Help_Text__c" VARCHAR(255), 
	"Instructions__c" VARCHAR(255), 
	"Is_Visible__c" VARCHAR(255), 
	"Lookup_Fields__c" VARCHAR(255), 
	"Lookup_No_Results_Label__c" VARCHAR(255), 
	"Lookup_Object__c" VARCHAR(255), 
	"Lookup_Results_Icon__c" VARCHAR(255), 
	"Lookup_Secondary_Input_Instructions__c" VARCHAR(255), 
	"Lookup_Secondary_Input_Link_Text__c" VARCHAR(255), 
	"Lookup_Secondary_Value_Field__c" VARCHAR(255), 
	"Lookup_Where_Clause__c" VARCHAR(255), 
	"Map_to_Field__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Picklist_Values_Long__c" VARCHAR(255), 
	"Picklist_Values__c" VARCHAR(255), 
	"Question_Field_Type__c" VARCHAR(255), 
	"Question_Label__c" VARCHAR(255), 
	"Registrant_Type__c" VARCHAR(255), 
	"Required__c" VARCHAR(255), 
	"Text_Limit__c" VARCHAR(255), 
	"Controlling_Question__c" VARCHAR(255), 
	"Event__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Summit_Events_Question__c" VALUES(1,'','','3.0','','State is a required field.','Registrant_State_Global__c','Ask your State representative what state you live in.','Enter the state your home is resides,','True','','','','','','','','','Registrant_State_Global__c','State','','','Picklist','State','Registrant','True','','','1');
INSERT INTO "Summit_Events_Question__c" VALUES(2,'','','2.0','','City is a required field','','If you can''t find your home city consult google maps.','Enter the city where your home resides.','True','','','','','','','','','Registrant_City__c','City','','','Textbox','City','Registrant','True','','','1');
INSERT INTO "Summit_Events_Question__c" VALUES(3,'','','10.0','','A pet type is required. Please choose one.','','If you don''t like pets than choose the on you dislike the least.','','True','','','','','','','','','Add_Info_Answer_1__c','Test Registrant Favorite Pet','','Dog

Cat

Hamster

Chicken

Snake','Picklist','What is your favorite pet?','Registrant','True','','','1');
INSERT INTO "Summit_Events_Question__c" VALUES(4,'','','1.0','','Street address is a required field','','This address should include house number and the street you live on.','Please enter your home address','True','','','','','','','','','Registrant_Street_1__c','Street Address','','','Textbox','Street Address','Registrant','True','','','1');
INSERT INTO "Summit_Events_Question__c" VALUES(5,'','','6.0','','State is a required field.','Registrant_State_Global__c','Ask your State representative what state you live in.','Enter the state your home is resides,','True','','','','','','','','','Registrant_State_Global__c','Guest Registrant State','','','Picklist','State','Guest','False','','','3');
INSERT INTO "Summit_Events_Question__c" VALUES(6,'','','20.0','','A pet type is required. Please choose one.','','If you don''t like pets than choose the on you dislike the least.','','True','','','','','','','','','Add_Info_Answer_1__c','Guest Registrant Favorite Pet','','Dog

Cat

Hamster

Chicken

Snake','Picklist','What is your favorite pet?','Guest','False','','','3');
INSERT INTO "Summit_Events_Question__c" VALUES(7,'','','4.0','','Street address is a required field','','This address should include house number and the street you live on.','Please enter your home address','True','','','','','','','','','Registrant_Street_1__c','Guest Registrant Street Address','','','Textbox','Street Address','Guest','False','','','3');
INSERT INTO "Summit_Events_Question__c" VALUES(8,'','','5.0','','City is a required field','','If you can''t find your home city consult google maps.','Enter the city where your home resides.','True','','','','','','','','','Registrant_City__c','Guest Registrant City','','','Textbox','City','Guest','False','','','3');
INSERT INTO "Summit_Events_Question__c" VALUES(9,'','','1.0','','','','','','True','','','','','','','','','Registrant_First_Name__c','Guest Registrant First Name','','','Textbox','First Name','Guest','False','','','3');
INSERT INTO "Summit_Events_Question__c" VALUES(10,'','','3.0','','','','','','True','','','','','','','','','Registrant_Email__c','Guest Registrant Email','','','Email','Email','Guest','False','','','3');
INSERT INTO "Summit_Events_Question__c" VALUES(11,'','','2.0','','','','','','True','','','','','','','','','Registrant_Last_Name__c','Guest Registrant Last Name','','','Textbox','Last Name','Guest','False','','','3');
INSERT INTO "Summit_Events_Question__c" VALUES(12,'','','','','','','','','True','','','','','','','','','Registrant_Last_Name__c','Golfer 1 Last Name','','','Textbox','Last Name','Guest','False','','','6');
INSERT INTO "Summit_Events_Question__c" VALUES(13,'','','','','','','','','True','','','','','','','','','Registrant_First_Name__c','Golfer email','','','Email','email','Guest','False','','','6');
INSERT INTO "Summit_Events_Question__c" VALUES(14,'','','','','','','','','True','','','','','','','','','Registrant_First_Name__c','Golfer 1 First Name','','','Textbox','First Name','Guest','False','','','6');
CREATE TABLE "Summit_Events_Registration__c" (
	id INTEGER NOT NULL, 
	"Actual_Number_of_Guests__c" VARCHAR(255), 
	"Add_Info_Answer_1__c" VARCHAR(255), 
	"Add_Info_Answer_2__c" VARCHAR(255), 
	"Add_Info_Answer_3__c" VARCHAR(255), 
	"Add_Info_Answer_4__c" VARCHAR(255), 
	"Add_Info_Answer_5__c" VARCHAR(255), 
	"Answer_1_Numeric__c" VARCHAR(255), 
	"Answer_2_Numeric__c" VARCHAR(255), 
	"Answer_3_Numeric__c" VARCHAR(255), 
	"Answer_4_Numeric__c" VARCHAR(255), 
	"Answer_5_Numeric__c" VARCHAR(255), 
	"Appointment_Table__c" VARCHAR(255), 
	"BCC_Transactional_Email_Statuses__c" VARCHAR(255), 
	"BCC_Transactional_Emails__c" VARCHAR(255), 
	"Campus_Tour_Location__c" VARCHAR(255), 
	"Campus_Tour_Time__c" VARCHAR(255), 
	"Confirmation_Call_Result__c" VARCHAR(255), 
	"Date_All_Appointments_Confirmed_del__c" VARCHAR(255), 
	"Display_Attendance_Publicly__c" VARCHAR(255), 
	"Encrypted_Registration_Id_1__c" VARCHAR(255), 
	"Encrypted_Registration_Id_2__c" VARCHAR(255), 
	"Event_Instance_Date_Time_Formatted__c" VARCHAR(255), 
	"Event_Registration_Requested_Date__c" VARCHAR(255), 
	"Event_Website_Referrer__c" VARCHAR(255), 
	"Event_Website__c" VARCHAR(255), 
	"Generated_Itinerary__c" VARCHAR(255), 
	"Generated_Requested_Appointments__c" VARCHAR(255), 
	"Guest_Host_Status__c" VARCHAR(255), 
	"Guest_JSON__c" VARCHAR(255), 
	"Hosted_Registrants__c" VARCHAR(255), 
	"Last_Name_as_Student__c" VARCHAR(255), 
	"Matching_Log__c" VARCHAR(255), 
	"New_Contact_Created__c" VARCHAR(255), 
	"New_Lead_Created__c" VARCHAR(255), 
	"Number_of_Guests__c" VARCHAR(255), 
	"Participation_Type__c" VARCHAR(255), 
	"Payment_Gateway_Status__c" VARCHAR(255), 
	"Preferred_Class_Year__c" VARCHAR(255), 
	"Preferred_Visit_Time__c" VARCHAR(255), 
	"Presentation_Location__c" VARCHAR(255), 
	"Presentation_Time__c" VARCHAR(255), 
	"Registrant_Applicant_Type__c" VARCHAR(255), 
	"Registrant_City__c" VARCHAR(255), 
	"Registrant_College_Code__c" VARCHAR(255), 
	"Registrant_College_Not_Found__c" VARCHAR(255), 
	"Registrant_College_Year__c" VARCHAR(255), 
	"Registrant_College__c" VARCHAR(255), 
	"Registrant_Company_Organization__c" VARCHAR(255), 
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
	"Registrant_Name_Tag__c" VARCHAR(255), 
	"Registrant_Other_Email__c" VARCHAR(255), 
	"Registrant_Other_First_Name__c" VARCHAR(255), 
	"Registrant_Other_Last_Name__c" VARCHAR(255), 
	"Registrant_Other_Phone__c" VARCHAR(255), 
	"Registrant_Other_Relationship__c" VARCHAR(255), 
	"Registrant_Parent_Email__c" VARCHAR(255), 
	"Registrant_Parent_First_Name__c" VARCHAR(255), 
	"Registrant_Parent_Last_Name__c" VARCHAR(255), 
	"Registrant_Parent_Phone__c" VARCHAR(255), 
	"Registrant_Phone__c" VARCHAR(255), 
	"Registrant_Postal_Code__c" VARCHAR(255), 
	"Registrant_Preferred_First_Name__c" VARCHAR(255), 
	"Registrant_Program_Interest__c" VARCHAR(255), 
	"Registrant_Pronouns__c" VARCHAR(255), 
	"Registrant_Receive_Texts__c" VARCHAR(255), 
	"Registrant_State_Global__c" VARCHAR(255), 
	"Registrant_State_Province__c" VARCHAR(255), 
	"Registrant_State__c" VARCHAR(255), 
	"Registrant_Street_1__c" VARCHAR(255), 
	"Registrant_Street_2__c" VARCHAR(255), 
	"Registrant_Third_Party_Status__c" VARCHAR(255), 
	"Registrant_Title__c" VARCHAR(255), 
	"Registrant_Zip__c" VARCHAR(255), 
	"Relationship_To_Institution__c" VARCHAR(255), 
	"Reminder_Call_Complete__c" VARCHAR(255), 
	"Session__c" VARCHAR(255), 
	"Status__c" VARCHAR(255), 
	"Substatus__c" VARCHAR(255), 
	gclid__c VARCHAR(255), 
	utm_campaign__c VARCHAR(255), 
	utm_content__c VARCHAR(255), 
	utm_creative_format__c VARCHAR(255), 
	utm_id__c VARCHAR(255), 
	utm_marketing_tactic__c VARCHAR(255), 
	utm_medium__c VARCHAR(255), 
	utm_source__c VARCHAR(255), 
	utm_source_platform__c VARCHAR(255), 
	utm_term__c VARCHAR(255), 
	"Contact__c" VARCHAR(255), 
	"Event_Instance__c" VARCHAR(255), 
	"Event__c" VARCHAR(255), 
	"Guest_Host__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Summit_Events_Registration__c" VALUES(1,'','','','','','','','','','','','','','','','','','','False','','','','','','','','','Hosted registrant','','','','','False','False','','','','','','','','','','','','','','','United States','','False','','last@email.com','','','','','','Last Name','','','','','','','','','','','','','','','','','False','','','','','','','','','','False','','Registered','','','','','','','','','','','','','12','6','6');
INSERT INTO "Summit_Events_Registration__c" VALUES(2,'','','','','','','','','','','','','','','','','','','False','','','','','','','','','Hosted registrant','','','','','False','False','','','','','','','','','','','','','','','United States','','False','','test@email.com','','','','','','Last Name','','','','','','','','','','','','','','','','','False','','','','','','','','','','False','','Registered','','','','','','','','','','','','','12','6','6');
INSERT INTO "Summit_Events_Registration__c" VALUES(3,'','','','','','','','','','','','','','','','','','','False','','','','','','','','','Hosted registrant','','','','','False','False','','','','','','','','','','','','','','','United States','','False','','third@email.com','','','','','','Last Name','','','','','','','','','','','','','','','','','False','','','','','','','','','','False','','Registered','','','','','','','','','','','','','12','6','6');
INSERT INTO "Summit_Events_Registration__c" VALUES(4,'','','','','','','','','','','','','','','','','','','False','','','','','','','','','Hosted registrant','','','','','False','False','','','','','','','','','','','','','','','United States','','False','','fourth@email.com','','','','','','Last Name','','','','','','','','','','','','','','','','','False','','','','','','','','','','False','','Registered','','','','','','','','','','','','','12','6','6');
INSERT INTO "Summit_Events_Registration__c" VALUES(5,'','Yes','Spouse','Need help running errands','','','','','','','','','','','','','','','False','CCTvgm3Os1qbg1gySfhfJeGTBCkNOqrYLGslu%2F0%2BCzymsxfAy%2FzLejLWhi%2B5knyF6erXAKtKmDbT6SQfQB6D%2FBDWsK6VFVWq6WkbgqpnMRx8vLoVUYqSZ2q0HuynYlRDVtr6oZ7oEQQ0oJE7J7TlnWqTa%2FSmqCBEThAyWA6MDnMDukkhKj9LV2DQ0JyxoDWilP1%2BfnsnJYlxRkfWdUBJrcANr7kjj1VwH6apmlzCQ%2Bli1Di','sp7OSbIpguLenwyHA','Friday, December 08, 2023, 7:00 PM - 8:30 PM EST','','https://efficiency-customer-4698-dev-ed.scratch.my.salesforce-sites.com/','https://efficiency-customer-4698-dev-ed.scratch.my.salesforce-sites.com/apex/SummitEventsRegister?instanceID=a068G000001WZM6QAO','','','','','','','','False','False','0.0','','','','','','','','','','','','','','United States','','False','tomc@mail.com','Tom','','','','','','Caregiver','8326032795','','','','','','','','','','','','','Tom','','','True','','','','','','','','','','False','','Registered','','','','','','','','','','','','','6','5','');
INSERT INTO "Summit_Events_Registration__c" VALUES(6,'','','','','','','','','','','','','','','','','','','False','AF9aDSShV7QWicoojE6T5ZYeeIK3jK2GhJ8qu7KwC50XbhoUugpIJvl1PaKgOq%2FrcyT3WmvxDg1AS1cC%2B2c7eN6H7gzfMPsZfdDLXu%2BZLEdgKzOpd5aPXDJl%2BnF%2B3f2qdIupTZ0gZ%2FrlaopAj1ivk7KWxa9o6GVfJwZsGyst07VVluYtxrCaqt9yOWHzlTmK5X4XAXakQLVUoGjsSmCypjuv5NNoygARpGELKFRs9vRUlnqzqfi','41ofkHRhwKzl7','Tuesday, June 04, 2024, 9:00 AM - 3:00 PM EST','','https://efficiency-customer-4698-dev-ed.scratch.lightning.force.com/','https://efficiency-customer-4698-dev-ed.scratch.my.salesforce-sites.com/apex/SummitEventsRegister?instanceID=a068G000001WZMa','','','Host attending','[{"questions":[{"value":"Golfer","question":"First Name","id":"8DGzgAUlRxIEasq4ba%2Fs2J%2FvEi%2F6me7iSh3KKTqcYq6aOs%2Bpvqhzp%2BuAahnZKVo%2F"},{"value":"Last Name","question":"Last Name","id":"fb83q%2FDzAlQb3lWlCPNCZ2ht1RtEu5RT9n%2F0I9ThHxcLAXN%2FlAxST6bG5VU9t5Wc"},{"value":"last@email.com","question":"email","id":"%2FX9%2BAp62UaMtYBxM7qwtgCUCyz93XlQV%2FJFuS8WMakHf%2FF4qDqdfICw%2BZdSTqZEo"}],"guestId":"iztssssbi0n1b2qydmuhbgvk95vus2"},{"questions":[{"value":"Golfer2","question":"First Name","id":"8DGzgAUlRxIEasq4ba%2Fs2J%2FvEi%2F6me7iSh3KKTqcYq6aOs%2Bpvqhzp%2BuAahnZKVo%2F"},{"value":"Last Name","question":"Last Name","id":"fb83q%2FDzAlQb3lWlCPNCZ2ht1RtEu5RT9n%2F0I9ThHxcLAXN%2FlAxST6bG5VU9t5Wc"},{"value":"test@email.com","question":"email","id":"%2FX9%2BAp62UaMtYBxM7qwtgCUCyz93XlQV%2FJFuS8WMakHf%2FF4qDqdfICw%2BZdSTqZEo"}],"guestId":"10itweeek6mkdif419jz4z11u5ect7"},{"questions":[{"value":"Golfer 3","question":"First Name","id":"8DGzgAUlRxIEasq4ba%2Fs2J%2FvEi%2F6me7iSh3KKTqcYq6aOs%2Bpvqhzp%2BuAahnZKVo%2F"},{"value":"Last Name","question":"Last Name","id":"fb83q%2FDzAlQb3lWlCPNCZ2ht1RtEu5RT9n%2F0I9ThHxcLAXN%2FlAxST6bG5VU9t5Wc"},{"value":"third@email.com","question":"email","id":"%2FX9%2BAp62UaMtYBxM7qwtgCUCyz93XlQV%2FJFuS8WMakHf%2FF4qDqdfICw%2BZdSTqZEo"}],"guestId":"1h8q3lllfu3arjakzx0enm1g6748f"},{"questions":[{"value":"Golfer4","question":"First Name","id":"8DGzgAUlRxIEasq4ba%2Fs2J%2FvEi%2F6me7iSh3KKTqcYq6aOs%2Bpvqhzp%2BuAahnZKVo%2F"},{"value":"Last Name","question":"Last Name","id":"fb83q%2FDzAlQb3lWlCPNCZ2ht1RtEu5RT9n%2F0I9ThHxcLAXN%2FlAxST6bG5VU9t5Wc"},{"value":"fourth@email.com","question":"email","id":"%2FX9%2BAp62UaMtYBxM7qwtgCUCyz93XlQV%2FJFuS8WMakHf%2FF4qDqdfICw%2BZdSTqZEo"}],"guestId":"23weeeeek6x2tr6v1wu49a153ze8"}]','4.0','','','False','False','0.0','','','','','','','','','','','','','','United States','','False','matt@adlerrio.com','Matt','','','','','','Wilczek','','','','','','','','','','','','','','','','','False','','','','','','','','','','False','','Registered','','','','','','','','','','','','','12','6','');
INSERT INTO "Summit_Events_Registration__c" VALUES(7,'','','Yes','','','','','','','','','','','','','','','','False','QmkJS%2F5MEBugqmINk5PfibuzsTmGl%2FcjxG%2FkZvf6t6EsJEGxRISL0WaZL7%2F3GHl5JCM2qGQR2AClzZpT06iRcA0jIj2UDx5H7Z4HbiZd1pcgzr%2F2uy0NFn%2BUq%2Fli7Z6u2uyF0yba09h%2Bd6wLBGJXKluH5p%2BbwpjNZ5T5GGa6OkCJhVQ0c5EJfxpf8MhWbEDKYSc9MrSZVO32qKwJnoCudoYvic6NEc%2FvTggoogLkKso','G4iVWlc2e6H%2Fd53QA803Z','Thursday, November 16, 2023, 6:00 PM - 11:00 PM CST','','','https://efficiency-customer-4698-dev-ed.scratch.my.salesforce-sites.com/apex/SummitEventsRegister?instanceID=a068G000001WZMk','','','','','','','','False','False','','','','','','','','','','','','','','','United States','','False','matt@adlerrio.com','Matt','','','','','','Wilczek','(832) 603-2795','','','','','','','','','','','','','','','','False','','','','','','','','','','False','','Registered','','','','','','','','','','','','','5','4','');
CREATE TABLE "Summit_Events__c" (
	id INTEGER NOT NULL, 
	"Academic_Program_List_Selected__c" VARCHAR(255), 
	"Academic_Program_List__c" VARCHAR(255), 
	"Academic_Program_Selected__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_1__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_2__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_3__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_4__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_5__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_Long_1__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_Long_2__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_Long_3__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_Long_4__c" VARCHAR(255), 
	"Add_Info_Question_Pick_List_Long_5__c" VARCHAR(255), 
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
	"Applicant_Type_Label__c" VARCHAR(255), 
	"Ask_Applicant_Type__c" VARCHAR(255), 
	"Ask_Company_Organization__c" VARCHAR(255), 
	"Ask_Date_Of_Birth__c" VARCHAR(255), 
	"Ask_Gender__c" VARCHAR(255), 
	"Ask_If_Parent__c" VARCHAR(255), 
	"Ask_Last_Name_As_Student__c" VARCHAR(255), 
	"Ask_Mailing_Address__c" VARCHAR(255), 
	"Ask_Phone__c" VARCHAR(255), 
	"Ask_Preferred_Class_Year__c" VARCHAR(255), 
	"Ask_Preferred_First_Name__c" VARCHAR(255), 
	"Ask_Pronoun__c" VARCHAR(255), 
	"Ask_Registrant_Program_Of_Interest__c" VARCHAR(255), 
	"Ask_Relationship_To_Institution__c" VARCHAR(255), 
	"Ask_Third_Party_Registrant__c" VARCHAR(255), 
	"Ask_Title__c" VARCHAR(255), 
	"Audience__c" VARCHAR(255), 
	"Building__c" VARCHAR(255), 
	"Close_Event_Days_Before__c" VARCHAR(255), 
	"College_High_School_Ask__c" VARCHAR(255), 
	"Company_Organization_Label__c" VARCHAR(255), 
	"Contact_Creation_Duplicate_Rule__c" VARCHAR(255), 
	"Contact_Creation__c" VARCHAR(255), 
	"Contact_Matching_Multiple_Match_Behavior__c" VARCHAR(255), 
	"Contact_Matching_No_Match_Behavior__c" VARCHAR(255), 
	"Contact_Matching_Rules__c" VARCHAR(255), 
	"Custom_Metadata_Contact_Matching_Method__c" VARCHAR(255), 
	"Custom_Metadata_Lead_Matching_Method__c" VARCHAR(255), 
	"Date_Of_Birth_Label__c" VARCHAR(255), 
	"Display_Guest_Registration__c" VARCHAR(255), 
	"Display_Optional_Donation__c" VARCHAR(255), 
	"Do_not_show_receive_text_question__c" VARCHAR(255), 
	"Donation_Description__c" VARCHAR(255), 
	"Donation_Suggested_Amount_List__c" VARCHAR(255), 
	"Donation_Title__c" VARCHAR(255), 
	"Email_Label__c" VARCHAR(255), 
	"End_Date__c" VARCHAR(255), 
	"Event_Additional_Question_Title__c" VARCHAR(255), 
	"Event_Additional_Questions_Description__c" VARCHAR(255), 
	"Event_Appointment_Chosen_Label__c" VARCHAR(255), 
	"Event_Appointment_Description__c" VARCHAR(255), 
	"Event_Appointment_Next_Instructions__c" VARCHAR(255), 
	"Event_Appointment_Submit_List_Label__c" VARCHAR(255), 
	"Event_Appointment_Title__c" VARCHAR(255), 
	"Event_Appointment_Unchosen_Label__c" VARCHAR(255), 
	"Event_Cancel_Review_Description__c" VARCHAR(255), 
	"Event_Cancel_Review_Title__c" VARCHAR(255), 
	"Event_Cancelled_Notification_Text__c" VARCHAR(255), 
	"Event_Confirmation_Description__c" VARCHAR(255), 
	"Event_Confirmation_Title__c" VARCHAR(255), 
	"Event_Fee_Additional__c" VARCHAR(255), 
	"Event_Fee_Label__c" VARCHAR(255), 
	"Event_Fee_Submit_List_Label__c" VARCHAR(255), 
	"Event_Fee_Total_Label__c" VARCHAR(255), 
	"Event_Fee__c" VARCHAR(255), 
	"Event_Fees_Received_Label__c" VARCHAR(255), 
	"Event_Footer__c" VARCHAR(255), 
	"Event_Full_Text__c" VARCHAR(255), 
	"Event_Guest_Submit_List_Label__c" VARCHAR(255), 
	"Event_Home_Link_Title__c" VARCHAR(255), 
	"Event_Home_Link_URL__c" VARCHAR(255), 
	"Event_Name__c" VARCHAR(255), 
	"Event_Payment_Due_Description__c" VARCHAR(255), 
	"Event_Payment_Due_Heading_Label__c" VARCHAR(255), 
	"Event_Payment_Received_Description__c" VARCHAR(255), 
	"Event_Payment_Received_Heading_Label__c" VARCHAR(255), 
	"Event_Short_Listing_Description__c" VARCHAR(255), 
	"Event_Sponsor__c" VARCHAR(255), 
	"Event_Status__c" VARCHAR(255), 
	"Event_Submit_Description__c" VARCHAR(255), 
	"Event_Submit_Title__c" VARCHAR(255), 
	"Event_Type__c" VARCHAR(255), 
	"Event_description__c" VARCHAR(255), 
	"Feed_Registration_Button_Text__c" VARCHAR(255), 
	"Filter_Category__c" VARCHAR(255), 
	"Filter_Where_To_Display__c" VARCHAR(255), 
	"First_Name_Label__c" VARCHAR(255), 
	"Gender_Label__c" VARCHAR(255), 
	"Guest_Max_Amount__c" VARCHAR(255), 
	"Guest_Registration_Add_Button_Label__c" VARCHAR(255), 
	"Guest_Registration_Description__c" VARCHAR(255), 
	"Guest_Registration_Title__c" VARCHAR(255), 
	"Guest_Table_Size__c" VARCHAR(255), 
	"Guest_Tables_Available__c" VARCHAR(255), 
	"Guest_Unsaved_Cancel_Label__c" VARCHAR(255), 
	"Guest_Unsaved_Continue_Label__c" VARCHAR(255), 
	"Guest_Unsaved_Modal_Text__c" VARCHAR(255), 
	"Hand_Raise_Action__c" VARCHAR(255), 
	"Include_Time_frame_List__c" VARCHAR(255), 
	"Itinerary_Display_Options__c" VARCHAR(255), 
	"Itinerary_Item_1__c" VARCHAR(255), 
	"Itinerary_Item_2__c" VARCHAR(255), 
	"Itinerary_Item_3__c" VARCHAR(255), 
	"Itinerary_Item_4__c" VARCHAR(255), 
	"Itinerary_Item_5__c" VARCHAR(255), 
	"Itinerary_Label_1__c" VARCHAR(255), 
	"Itinerary_Label_2__c" VARCHAR(255), 
	"Itinerary_Label_3__c" VARCHAR(255), 
	"Itinerary_Label_4__c" VARCHAR(255), 
	"Itinerary_Label_5__c" VARCHAR(255), 
	"Itinerary_Table_Head_Or_Title_2__c" VARCHAR(255), 
	"Itinerary_Table_Head_Or_Title_3__c" VARCHAR(255), 
	"Itinerary_Table_Head_Or_Title_4__c" VARCHAR(255), 
	"Itinerary_Table_Head_Or_Title_5__c" VARCHAR(255), 
	"Keep_Registration_Open_During_Event__c" VARCHAR(255), 
	"Last_Name_As_Student_Label__c" VARCHAR(255), 
	"Last_Name_Label__c" VARCHAR(255), 
	"Lead_Creation_Duplicate_Rule__c" VARCHAR(255), 
	"Lead_Matching_Multiple_Match_Behavior__c" VARCHAR(255), 
	"Lead_Matching_No_Match_Behavior__c" VARCHAR(255), 
	"Lead_matching_rules__c" VARCHAR(255), 
	"Location_Address__c" VARCHAR(255), 
	"Location_Map_Link__c" VARCHAR(255), 
	"Location_Title__c" VARCHAR(255), 
	"Location_Type__c" VARCHAR(255), 
	"Mailing_Address_Label__c" VARCHAR(255), 
	"Max_Other_Attendees__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"No_Guest_Registrations_Added_Message__c" VARCHAR(255), 
	"Payment_Button_Label__c" VARCHAR(255), 
	"Payment_Gateway__c" VARCHAR(255), 
	"Phone_Label__c" VARCHAR(255), 
	"Phone_Type_Label__c" VARCHAR(255), 
	"Preferred_Class_Year_Label__c" VARCHAR(255), 
	"Preferred_First_Name_Label__c" VARCHAR(255), 
	"Private_Event__c" VARCHAR(255), 
	"Program_Filter_2__c" VARCHAR(255), 
	"Program_Filter_3__c" VARCHAR(255), 
	"Program_Filter__c" VARCHAR(255), 
	"Pronouns_Label__c" VARCHAR(255), 
	"Registrant_Receive_Texts_Label__c" VARCHAR(255), 
	"Registrant_Relationship_Label__c" VARCHAR(255), 
	"Registration_Email_Restriction__c" VARCHAR(255), 
	"Relationship_To_Institution_Label__c" VARCHAR(255), 
	"Start_Date__c" VARCHAR(255), 
	"Template__c" VARCHAR(255), 
	"Third_Party_Registrant_Label__c" VARCHAR(255), 
	"Title_Label__c" VARCHAR(255), 
	"Tracking_Cancel_Registration__c" VARCHAR(255), 
	"Tracking_Confirmation_Registration__c" VARCHAR(255), 
	"Tracking_Event_Registration__c" VARCHAR(255), 
	"Tracking_Options_Registration__c" VARCHAR(255), 
	"Tracking_Submit_Registration__c" VARCHAR(255), 
	"Account__c" VARCHAR(255), 
	"Donation_Allocation_1__c" VARCHAR(255), 
	"Donation_Allocation_2__c" VARCHAR(255), 
	"Donation_Allocation_3__c" VARCHAR(255), 
	"Donation_Allocation_4__c" VARCHAR(255), 
	"Donation_Allocation_5__c" VARCHAR(255), 
	"Event_Fee_Additional_Allocation__c" VARCHAR(255), 
	"Event_Fee_Allocation__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Summit_Events__c" VALUES(1,'','','','','','','','','','','','','','','','','','','','','','','','False','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','','Do not ask','General Public','','0.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','False','False','False','','','','Email','2023-11-26','Custom Questions','<p>These questions are defined in the custom questions object that looks up to your event object.</p>','Selected options','Body text for the appointment/options page explains what these appointments are about.','Once you have made your selections click next.','','This is the header of the appointment/options page.','Choose your options','What does it mean to cancel a event.','Online Cancel of Registration Heading','The event has been cancelled.','Explain the registration has been received from the client at this point and is complete','Registration has been received title.','','Event Cost','Event Charges','Total','','Payments Received','This footer appears on every event registration page in the footer.','Explain here that the event has reached capacity and is closed.','','Event Home','','Test Event Additional Questions for Registrant','','Payment Due','','Payment Received','This description appears in feed and should be concise','','Active','Description of submission being the final act in the registration play.','Heading for the Submit Page','Admissions Event','<p><b>Rich Text</b> description of the event that appears on the first registration page. This event will test the additional questions feature of Summit Events as applied to the registrant only.</p>','Register','','','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','123 Evergreen Blvd., St. Paul, MN','https://g.page/sociablecider?share','The best place in the World','','Registrant Address','','Test Event Additional Questions for Registrant','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-09-26','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(2,'','','','Red

Yellow

Green

Blue','','','','','','','','','','What is your favorite color?','What''s up?','What''s your favorite day of the week?','','','Pick-list','Text area','Text box required','','','True','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','True','Do not ask','Ask','Ask with type require','Do not ask','Do not ask','Ask','Ask but do not require','Do not ask','Parent/Guardian;Other','Do not ask','General Public','','0.0','Don''t ask','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','False','False','False','','','','Email','2023-11-26','','','Selected options','Body text for the appointment/options page explains what these appointments are about.','Once you have made your selections click next.','','This is the header of the appointment/options page.','Choose your options','What does it mean to cancel a event.','Online Cancel of Registration Heading','The event has been cancelled.','Explain the registration has been received from the client at this point and is complete','Registration has been received title.','','Event Cost','Event Charges','Total','','Payments Received','This footer appears on every event registration page in the footer.','Explain here that the event has reached capacity and is closed.','','Event Home','','Test Event','','Payment Due','','Payment Received','This description appears in feed and should be concise','','Active','Description of submission being the final act in the registration play.','Heading for the Submit Page','Admissions Event','<p><strong>Rich Text</strong> description of the event that appears on the first registration page.</p>','Register','','','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','123 Evergreen Blvd., St. Paul, MN','https://g.page/sociablecider?share','The best place in the World','','Registrant Address','5.0','Test Event','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-09-26','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(3,'','','','','','','','','','','','','','','','','','','','','','','','False','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','','Do not ask','General Public','','0.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','True','False','False','','','','Email','2023-11-26','Custom Questions','<p>These questions are defined in the custom questions object that looks up to your event object.</p>','Selected options','Body text for the appointment/options page explains what these appointments are about.','Once you have made your selections click next.','','This is the header of the appointment/options page.','Choose your options','What does it mean to cancel a event.','Online Cancel of Registration Heading','The event has been cancelled.','Explain the registration has been received from the client at this point and is complete','Registration has been received title.','','Event Cost','Event Charges','Total','','Payments Received','This footer appears on every event registration page in the footer.','Explain here that the event has reached capacity and is closed.','','Event Home','','Test Event for Additional Guest Registrations','','Payment Due','','Payment Received','This description appears in feed and should be concise','','Active','Description of submission being the final act in the registration play.','Heading for the Submit Page','Admissions Event','<p><b>Rich Text</b> description of the event that appears on the first registration page. This event will test gathering additional registrations for guests of the registrant.</p>','Register','','','First Name','Gender','5.0','Submit Guest Registration','<p>Please let us know who you are bringing so we can prepare the best possible event for your guests.</p>','Are you bringing additional guests','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','123 Evergreen Blvd., St. Paul, MN','https://g.page/sociablecider?share','The best place in the World','','Registrant Address','','Test Event for Additional Guest Registrations','Guest registrations will appear here once you add them. None have been added yet.','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-09-26','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(4,'','','','Yes

No','Yes

No','','','','','','','','','Table Sponsor, $1,000 (8 tickets)','Co-Table Sponsor, $500 (4 tickets)','Individual Ticket, $75 (1 ticket)','','','Pick-list','Pick-list','Pick-list','','','False','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Ask with type','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','','Do not ask','General Public','','7.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','False','False','False','','','','Email','2023-11-16','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','<p>Thank you for your registration - see you at the event</p>','Your Confirmed','','Event Cost','Event Charges','Total','','Payments Received','','','','Event Home','','Area on Aging Annual Dinner & Auction','','Payment Due','','Payment Received','Annual Dinner & Auction','','Active','','','Fundraising','<p><span style="color: rgb(0, 0, 0); background-color: initial;">The Local Area on Aging and Event Sponsor TBD Company® are pleased to host the 38th Annual Dinner and Auction on November 16, 2023 at the Kellogg Hotel and Conference Center in East Lansing to raise funds for Meals on Wheels and in-home services for older adults in Clinton, Eaton, and Ingham counties.</span></p><p> </p><p><span style="color: rgb(0, 0, 0); background-color: initial;">We expect over 350 people to join us for this evening of dining, live and silent auctions, raffle with cash prizes, games and entertainment, cash bar, and many opportunities to socialize in the name of a good cause.</span></p><p> </p><p><span style="color: rgb(0, 0, 0); background-color: initial;">All proceeds benefit local older adults and adults with disabilities to remain safe and independent as they age. TCOA connects with over 18,000 people each year who need help, and we are able to do this in part through support from community sponsors, individual attendees, and raffle ticket sales.</span></p><p> </p><p><span style="color: rgb(0, 0, 0); background-color: initial;">Please join us for a wonderful evening in support of keeping our aging neighbors, friends, and families safe and thriving in the community. </span></p><p> </p><p><strong><u>Sponsor:</u></strong> Options range from a $500 Co-Table (four seats) to $10,000.</p><p><a href="https://interland3.donorperfect.net/weblink/WebLink.aspx?name=tcoa&amp;id=28" target="_blank" style="color: rgb(17, 18, 18);"><strong>Purchase Individual Tickets for $75 Each</strong></a></p><p><br></p><p><br></p>','Register','All Websites','All Websites','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','219 S Harrison Rd, East Lansing, MI 48824','https://maps.app.goo.gl/bc1Mq98XyrqvsSjE8','Kellog Hotel & Convention Center','On-Site','Registrant Address','500.0','Area on Aging Annual Dinner & Auction','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-08-01','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(5,'','','','Yes

No

Other','Spouse

Family member (non-spouse)

Non-family member','','','','','','','','','Are you a caregiver of someone with Dementia','What is your relation to the individual suffering from dementia?','What is your biggest need of help or support?','','','Pick-list','Pick-list','Text area','','','True','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Ask with type','Do not ask','Ask','Do not ask','Do not ask','Do not ask','','Do not ask','General Public','','0.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','False','False','False','','','','Email','2024-10-01','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','<p>Confirmation of Registration</p>','Thank you for Registering','','Event Cost','Event Charges','Total','0.0','Payments Received','<p style="text-align: center;">Dementia Care Support Group is a non-profit dedicated to proving support to caregivers</p><p><br></p><p><img src="https://efficiency-customer-4698-dev-ed.scratch.file.force.com/servlet/rtaImage?eid=a0B8G000003HNFI&amp;feoid=00N8G00000MD3cI&amp;refid=0EM8G000000JEZd" alt="Image 10-31-23 at 11.25 AM.jpeg"></img></p>','<p>Sorry, this event is currently closed - please call our office for more information for caregivers.</p>','','Event Home','','Dementia Caregiver Support','','Payment Due','','Payment Received','Series of Events to support caregivers supporting those suffering from Dementia','Center for Common Good','Active','','','Info Session','<p style="text-align: center;"><strong style="font-size: 16px; color: rgb(14, 50, 234);">Dementia Care Giver Support Group</strong></p><p><br></p><p><span style="font-size: 16px; color: rgb(0, 0, 0);">Join this monthly meeting to connect with other Caregivers and learn from Dementia experts to hear the latest care tips, clinical research, and connect with support resources in our community.</span></p><p><br></p><p><strong style="font-size: 16px; color: rgb(0, 0, 0);">Who should attend?</strong></p><p>Anyone with a loved one suffering from Dementia or interested in learning more about how Dementia impacts individuals, families, and caregivers</p><p><br></p><p style="text-align: center;"><br></p><h2><br></h2><p><br></p>','Register','All Websites','All Websites','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','True','Last Name As Student','Last Name','','','','','4127 Okemos Rd, Okemos, MI 48864','https://maps.app.goo.gl/6G6GboVUU3sENzzj6','GLF Office','On-Site','Registrant Address','20.0','Dementia Caregiver Support','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-10-01','GeneralSLDS','I am...','Title','','','','','','2','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(6,'','','','','','','','','Hole sponsor - $1,000 (includes 4 golfers)

Team Sponsor - $400 (includes 4 golfers)

Twosome - $200 (includes 2 golfers)

Individual golfer - $100','','','','','Registration Type','','','','','Pick-list','','','','','True','','Application Type','Do not ask','Ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Do not ask','Do not ask','Ask','Do not ask','Do not ask','Do not ask','','Do not ask','General Public','','7.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','True','False','False','','','','Email','2024-06-04','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','','','','Event Cost','Event Charges','Total','','Payments Received','','','','Event Home','','2024 AR Golf Event','','Payment Due','','Payment Received','2024 Golf Event','','Active','','','Fundraising','<p style="text-align: center;"><strong style="font-size: 16px;">Annual Fundraising Golf Event</strong></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 16px;">2024 AR Fundraising Golf Event</span></p><p style="text-align: center;"><span style="font-size: 16px;">Proceeds to benefit AR scholarship fund</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 16px;">Shotgun start - 9AM - June 4, 2024</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><img src="https://efficiency-customer-4698-dev-ed.scratch.file.force.com/servlet/rtaImage?eid=a0B8G000003HNFc&amp;feoid=00N8G00000MD3cY&amp;refid=0EM8G000000JEa7" alt="Indian Boundary Golf Course | Golf Courses Chicago Illinois"></img></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p>','Register','All Websites','All Websites','First Name','Gender','4.0','','','Golf Team','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','2231 S Harrison Rd, East Lansing, MI 48823','https://maps.app.goo.gl/Fnq3GmPdETEYDR4m6','Forrest Akers East','','Registrant Address','3.0','2024 AR Golf Event','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','One registration per instance','Relationship (select all that apply)','2024-06-04','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
COMMIT;
