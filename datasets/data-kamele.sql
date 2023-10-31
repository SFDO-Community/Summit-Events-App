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
INSERT INTO "Summit_Events_Appointments__c" VALUES(1,'','','','','','','Requested','','','Demo Appointment 0 - Quiet Time','','','','','','True','<p>Get yourself some quiet time in our library.</p>','False','','','','1.0','1','','7');
INSERT INTO "Summit_Events_Appointments__c" VALUES(2,'','','','','','','Requested','','','Demo Appointment 1 - Ice Cream with Counselor','','','','','','True','Choose the ice cream you could prefer to consume during your visit','False','','Lactose Free','','10.0','3','','7');
INSERT INTO "Summit_Events_Appointments__c" VALUES(3,'','','','','','','Requested','','','Demo Appointment 2 - Meaning of life','','','','','','True','What is your definition of the meaning of life?','False','','What''s yours?','','20.0','4','','7');
INSERT INTO "Summit_Events_Appointments__c" VALUES(4,'','','','','','','Requested','','','Demo Appointment 3 - Free Lunch','','','','','','True','There is such a thing!','False','','','','30.0','2','','7');
INSERT INTO "Summit_Events_Appointments__c" VALUES(5,'','','','','','','Requested','','','Demo Appointment 2 - Meaning of life','','','','','','True','What is your definition of the meaning of life?','False','','What''s yours? Part 2','','20.0','4','','7');
INSERT INTO "Summit_Events_Appointments__c" VALUES(6,'','','','','','','Requested','','','Demo Appointment 0 - Quiet Time','','','','','','True','<p>Get yourself some quiet time in our library.</p>','False','','','','1.0','1','','2');
INSERT INTO "Summit_Events_Appointments__c" VALUES(7,'','','','','','','Requested','','','Demo Appointment 1 - Ice Cream with Counselor','','','','','','True','Choose the ice cream you could prefer to consume during your visit','False','','Lactose Free','','10.0','3','','2');
INSERT INTO "Summit_Events_Appointments__c" VALUES(8,'','','','','','','Requested','','','Demo Appointment 2 - Meaning of life','','','','','','True','What is your definition of the meaning of life?','False','','42','','20.0','4','','2');
INSERT INTO "Summit_Events_Appointments__c" VALUES(9,'','','','','','','Requested','','','Demo Appointment 3 - Free Lunch','','','','','','True','There is such a thing!','False','','','','30.0','2','','10');
INSERT INTO "Summit_Events_Appointments__c" VALUES(10,'','','','','','','Requested','','','Demo Appointment 0 - Quiet Time','','','','','','True','<p>Get yourself some quiet time in our library.</p>','False','','','','1.0','1','','10');
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
INSERT INTO "Summit_Events_Instance__c" VALUES(1,'Active','','False','','Registrants plus Guests','1000.0','','','','','2023-11-16','16:00:00.000Z','Test event for gathering guest registrations from registrant.','2023-11-16','12:00:00.000Z','Central Daylight Time (America/Chicago)','Secondary Title','','','','','False','','','','','3');
INSERT INTO "Summit_Events_Instance__c" VALUES(2,'Active','','False','','Registrants plus Guests','100.0','','','','','2023-11-12','12:30:00.000Z','Testing additional questions with this event.','2023-11-12','08:00:00.000Z','Central Daylight Time (America/Chicago)','Secondary Title','','','','','False','','','','','1');
INSERT INTO "Summit_Events_Instance__c" VALUES(3,'Active','','False','','Registrants plus Guests','100.0','','','','','2023-11-03','15:30:00.000Z','A short description','2023-11-03','08:00:00.000Z','Central Daylight Time (America/Chicago)','Secondary Title','','','','','False','','','','','2');
INSERT INTO "Summit_Events_Instance__c" VALUES(4,'Active','','False','','Registrants plus Guests','100.0','','','','','2023-11-10','13:15:00.000Z','A short description','2023-11-10','09:00:00.000Z','Central Daylight Time (America/Chicago)','A special Title','','','','','False','','','','','2');
INSERT INTO "Summit_Events_Instance__c" VALUES(5,'Active','','False','','Registrants plus Guests','300.0','','','','','2023-11-04','20:00:00.000Z','Day 1','2023-11-04','07:00:00.000Z','Central Daylight Time (America/Chicago)','Saturday, November 4th 2023','','','','','False','','','','','4');
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
INSERT INTO "Summit_Events_Question__c" VALUES(12,'','','','Half width','','','','','True','','','','','','','','','Registrant_First_Name__c','First Name','','','Textbox','First Name','Registrant','True','','','4');
INSERT INTO "Summit_Events_Question__c" VALUES(13,'','','','','','','','','True','','','','','','','','','Add_Info_Answer_4__c','Reference','','','Textbox','How did you hear about us?','Registrant','False','','','4');
INSERT INTO "Summit_Events_Question__c" VALUES(14,'','','','','','','','If Applicable','True','','','','','','','','','Add_Info_Answer_3__c','Style','Freestyle

Folkstyle

Both - YOU MAY NOT RECIEVE THE SUGGESTED 30MIN REST TIME','','Picklist','Which Style Bracket?','Registrant and Guest','False','','','4');
INSERT INTO "Summit_Events_Question__c" VALUES(15,'','','','','','','','','True','','','','','','','','','Registrant_Date_of_Birth__c','Birthday','','','Date','Birthday','Registrant','False','','','4');
INSERT INTO "Summit_Events_Question__c" VALUES(16,'','','','','','','','','True','','','','','','','','','Add_Info_Answer_2__c','Weight Class','W - 110 lbs

W - 117 lbs

W - 121 lbs

W- 126 lbs

W - 130 lbs

W - 137 lbs

W - 143. lbs

W - 150 lbs

W - 159 lbs

W - 168 lbs

M - 100 lbs

M - 125 lbs

M - 134 lbs

M - 143 lbs

M - 154 lbs

M - 163 lbs

M - 174 lbs

M - 190 lbs

M - 203 lbs

M - 214 lbs

M - 276 lbs','','Picklist','What Weight Class will they compete in?','Registrant and Guest','False','','','4');
INSERT INTO "Summit_Events_Question__c" VALUES(17,'','','','','','','','','True','','','','','','','','','Registrant_Last_Name__c','Last Name','','','Textbox','Last Name','Registrant','True','','','4');
INSERT INTO "Summit_Events_Question__c" VALUES(18,'','','','','','','','','True','','','','','','','','','Add_Info_Answer_1__c','Attendee','Coach

Wrestler

Trainer

Referee','','Picklist','What kind of registration?','Registrant and Guest','True','','','4');
INSERT INTO "Summit_Events_Question__c" VALUES(19,'','','','Half width','','','','','True','','','','','','','','','Registrant_Gender__c','Gender','Male

Female','','Picklist','Gender','Guest','False','','','4');
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
INSERT INTO "Summit_Events_Registration__c" VALUES(1,'','','','','','','','','','','','','','','','','','','False','','','Saturday, November 04, 2023, 7:00 AM - 8:00 PM CDT','','https://data-innovation-8655-dev-ed.scratch.lightning.force.com/','https://data-innovation-8655-dev-ed.scratch.my.salesforce-sites.com/apex/SummitEventsRegister?instanceID=a067i000007ooWj','','','','','','','','False','False','','','','','','','','','','','','','','','United States','1997-06-11','False','kamele@gmail.com','KaMele','Female','','','','','Kopplin','(808) 557-9712','','','','','','','','','','','','','','','','False','','','','','','','','','','False','','Started','','','','','','','','','','','','','5','4','');
INSERT INTO "Summit_Events_Registration__c" VALUES(2,'','','','Today','','','','','','','','','','','','','','','False','CzwLqEFd4luU9sI335OhsPcBqrpTp12wEyaUnP9Kv4d80ufFlS3alIPTHZAOF1NlEB3WvQ2OsXZfDk9S%2BxB9TAxt580PTD9f7vA65ziiqM5iz4%2B0kdDU46MhoD36vk8hQl0yU01hdTsjxoU30uMc3%2Bji0tPNcOfuHM%2FrlE4kJN0F%2Ba%2FBmCHDph7v2B8kKN55ESHYnGpf8Pf1UhSF76yVhJ5ablPqvlflsnia7zOfsH9nVgoBcc8','AoI9DQOWlPRUP','Friday, November 03, 2023, 8:00 AM - 3:30 PM CDT','','https://data-innovation-8655-dev-ed.scratch.my.salesforce-sites.com/summiteventsregisterappointments','https://data-innovation-8655-dev-ed.scratch.my.salesforce-sites.com/apex/summiteventsregister?instanceID=a067i000007oncI','','<b>Demo Appointment 0 - Quiet Time</b><br/>Get yourself some quiet time in our library.<br/><br/><b>Demo Appointment 1 - Ice Cream with Counselor</b><br/>Choose the ice cream you could prefer to consume during your visit<br/>Lactose Free<br/><br/><b>Demo Appointment 2 - Meaning of life</b><br/>What is your definition of the meaning of life?<br/>42','','','','','','False','False','0.0','','','','','','','','','','','','','','United States','','False','thad@valleyhill.net','Thad','','','','','','Dahlberg','','','','','','','','','','','','(555) 555-5555','','','','','False','','','','123 Electric Ave','','Primary Registrant','','','','False','','Registered','','','','','','','','','','','','','3','2','');
INSERT INTO "Summit_Events_Registration__c" VALUES(3,'','','','','','','','','','','','','','','','','','','False','','','','','','','','','Hosted registrant','','','','','False','False','','','','','','','','','','','','','','','United States','','False','','','Male','','','','','','','','','','','','','','','','','','','','','','False','','','','','','','','','','False','','Registered','','','','','','','','','','','','','5','4','9');
INSERT INTO "Summit_Events_Registration__c" VALUES(4,'','Cat','','','','','','','','','','','','','','','','','False','','','','','','','','','Hosted registrant','','','','','False','False','','','','','','','','','','','','','','','United States','','False','thad+max@valleyhill.net','Max','','','','','','Headroom','','','','','','','','','','','','','','','','','False','DE','','','','','','','','','False','','Registered','','','','','','','','','','','','','1','3','11');
INSERT INTO "Summit_Events_Registration__c" VALUES(5,'','Hamster','','','','','','','','','','','','','','','','','False','','','','','','','','','Hosted registrant','','','','','False','False','','','','','','','','','','','','','','','United States','','False','thad+another@valleyhill.net','Another','','','','','','Guest','','','','','','','','','','','','','','','','','False','DE','','','','','','','','','False','','Registered','','','','','','','','','','','','','1','3','11');
INSERT INTO "Summit_Events_Registration__c" VALUES(6,'','','','Tuesday','','','','','','','','','','','','','','','False','21gZh2yBDmsul5jQLYaB9ge2hgp8JZeGegqp6rICsErEbAF3ZfaihaVq8AJ5jOZtpaRY%2BM%2BguOq%2BgkGJIkRurxRv3he8bsO4731O5lo3KVVPRFbAQfDRVi10sjix4XqV%2FYumolXaIw1F4eapmIm2CM%2Fy5xsf9WU3u1DyJ2%2BrqL6uS8RDZBg2nO%2F9eW1lMFEcG4GHdPxRP5E9CXVz5xrfBd0Kov5Hgmt0uJesbc4BfowR%2B0Z','Ny1FFX1iePx%2B3FhJE','Friday, November 03, 2023, 8:00 AM - 3:30 PM CDT','','','https://data-innovation-8655-dev-ed.scratch.my.salesforce-sites.com/apex/SummitEventsRegister?instanceID=a067i000007oncI','','','','','','','','False','False','0.0','','','','','','','','','','','','','','United States','','False','mwalter274@gmail.com','Sprinty','','','','','','Salesforce','(651) 242-2049','','','','','','','','','','','','','','','','False','','','','','','Primary Registrant','','','','False','','Registered','','','','','','','','','','','','','3','2','');
INSERT INTO "Summit_Events_Registration__c" VALUES(7,'','','Cheers!','Everyday','','','','','','','','','','','','','','','False','BlcKIXaIyMaJC5I9RUbDyINN7qTyXiGbGuo1X4XUJbVU%2FPe4IaqLuy8A9Pt5iG72eVVIL5nBQsq6DI5fBFi3raDBXHf7zkSHPx4ZObK%2FsDdqdKWyJ%2FZgMqk%2BjRKL%2BqyQY%2Bl8ucm06syalnU2lErn0Cckpk5H4OwdkiAMto73DKgpkwugOiVVwxR2nFjpMx9h2WZGSMeIGG3qJGDeNE3bKgwnhTfUDXf5uwPbIx8ppeNRK2sHxI6','1kaEhrPvmeigP','Friday, November 03, 2023, 8:00 AM - 3:30 PM CDT','','','https://data-innovation-8655-dev-ed.scratch.my.salesforce-sites.com/apex/SummitEventsRegister?instanceID=a067i000007oncI','','<b>Demo Appointment 0 - Quiet Time</b><br/>Get yourself some quiet time in our library.<br/><br/><b>Demo Appointment 1 - Ice Cream with Counselor</b><br/>Choose the ice cream you could prefer to consume during your visit<br/>Lactose Free<br/><br/><b>Demo Appointment 2 - Meaning of life</b><br/>What is your definition of the meaning of life?<br/>What''s yours?<br/><br/><b>Demo Appointment 2 - Meaning of life</b><br/>What is your definition of the meaning of life?<br/>What''s yours? Part 2<br/><br/><b>Demo Appointment 3 - Free Lunch</b><br/>There is such a thing!','','','','','','False','False','0.0','','','','','','','','','','','','','','United States','','False','mitter.nirvik@gmail.com','Nirvik','','','','','','Mitter','+919912625289','','','','','','','','','','','','','','','He/Him','True','','','','','','Primary Registrant','','','','False','','Registered','','','','','','','','','','','','','3','2','');
INSERT INTO "Summit_Events_Registration__c" VALUES(8,'','Coach','','','','','','','','','','','','','','','','','False','','','Saturday, November 04, 2023, 7:00 AM - 8:00 PM CDT','','https://data-innovation-8655-dev-ed.scratch.my.salesforce-sites.com/summiteventsadditionalquestions','https://data-innovation-8655-dev-ed.scratch.my.salesforce-sites.com/apex/summiteventsregister?instanceID=a067i000007ooWj','','','','[{"questions":[{"value":"Freestyle","question":"Which Style Bracket?","id":"sLhnIfhG%2B1OVF9Qb1fl1MHnC1TinFfZqJj7UJ9Eh%2FU0sFe85HbfDvoKnSXsR1m%2BF"},{"value":"W - 117 lbs","question":"What Weight Class will they compete in?","id":"k0izQVQjl4aV8GOEICVQfB0AZmOwm8Twz%2FmhE%2BqI763Q7BlDMrflSC%2BeGtjmRgct"},{"value":"Wrestler","question":"What kind of registration?","id":"Yjxvs9Rc6QZqmNpdtn%2BPuLka8owSlOgyvtl%2FmYjOUDy2rMn3G1BSMvjN1It1Mk8n"},{"value":"Male","question":"Gender","id":"%2FDP1gGBTafBVk9BT2xCr5ek931qKlPa7S%2BqRYkFX4UZMPoie2AauvoWbDl7WS%2BbQ"}],"guestId":"8mkeeeegk8x7potdo1drfufkyy69bd"}]','','','','False','False','','','','','','','','','','','','','','','United States','1997-06-11','False','kamele@gmail.com','KaMele','Female','','','','','Kopplin','(808) 557-9712','','','','','','','','','','','','','','','','False','','','','','','','','','','False','','Started','','','','','','','','','','','','','5','4','');
INSERT INTO "Summit_Events_Registration__c" VALUES(9,'','','','','','','','','','','','','','','','','','','False','XwjdVUt0mppKReR%2FtY5q2gGl33yBnqMo6F%2Fj2O90smIKRzX5%2Fc6tbYC77rU0L4qAEcJmrGZz%2FE1jqwht7oZkveTtJ7yOwk1GJkozfvCQicR5rKbz6i8B5UWePYe%2B9DEZMolRYr04PUQJzBopLJ0fvl12qAvEpjzzBND0YofVAkIbxs%2BEi7nAmF%2Fqe%2F0GLNhT%2BAbuVLIFjqmQdqSv0WHqlrmKAPcrrwnFGJ9Dakv9Hcame','P%2BU3t5J4zuG1wc1HHH0','Saturday, November 04, 2023, 7:00 AM - 8:00 PM CDT','','https://data-innovation-8655-dev-ed.scratch.lightning.force.com/','https://data-innovation-8655-dev-ed.scratch.my.salesforce-sites.com/apex/SummitEventsRegister?instanceID=a067i000007ooWj','','','Host attending','[{"questions":[{"value":"Coach","question":"What kind of registration?","id":"AEoIvPdcosnNyJ0W3kCZ3zsvj1BHpIYwQb12580ZxlpJ04%2FrsSIuGJIBZjU4WTeQ"},{"value":"W - 143. lbs","question":"What Weight Class will they compete in?","id":"RAXjOPep092tYL39OeHIblK99lCB4vor1ipV5cCkp0%2B75t1Ph3wYqKUmgyTX0r5M"},{"value":"Both - YOU MAY NOT RECIEVE THE SUGGESTED 30MIN REST TIME","question":"Which Style Bracket?","id":"Sr%2BQnyfX%2BFFWTmGBWigd4Om0pAFeNCInKLYEGMIZn1Xx498CL6Upfgflx9DgnvGj"},{"value":"Male","question":"Gender","id":"BwqZXv5wVffNnarpHvt6gTJSC3vXa4hqMkmISp4zqjr2Abgj%2Bky5%2B8gsNFLBWZBm"}],"guestId":"cvzi6xh4o2ubf65e3sdze"}]','1.0','','','False','False','','','','','','','','','','','','','','','United States','1997-06-11','False','kamele@gmail.com','KaMele','Female','','','','','Kopplin','(080) 557-9712','','','','','','','','','','','','','','','','False','','','','','','','','','','False','','Registered','','','','','','','','','','','','','5','4','');
INSERT INTO "Summit_Events_Registration__c" VALUES(10,'','Yellow','Updawg','Friday','','','','','','','','','','','','','','','False','9YVJfQq8ZY%2BYB0K2OLzoTeXOZOPF9FVibJbrhMPUVTj4Qrmx%2FrKqRG8%2FZog%2F5Ghc%2F73FVDDwY3phfTZhvgr53d7GtndbKY2F6RLyRpCmaxKenR3uxvrWYxrWqGi%2Fs67NHj%2Fw3Alhpd%2Fx3MTQw4GaEwKQrX4Pd7W0XgihiFfXTPiQpzOTkxnQyFG3d2zLHZMz7NP97oyH68TTHUQMURXRGY%2Bhnm5PA9iXIn9GF%2Bb1kJv','hzGSGsIbOG8l%2B7A26ZvcC','Friday, November 03, 2023, 8:00 AM - 3:30 PM CDT','','','https://data-innovation-8655-dev-ed.scratch.my.salesforce-sites.com/apex/SummitEventsRegister?instanceID=a067i000007oncI','','<b>Demo Appointment 0 - Quiet Time</b><br/>Get yourself some quiet time in our library.<br/><br/><b>Demo Appointment 3 - Free Lunch</b><br/>There is such a thing!','','','','','','False','False','0.0','','','','','','','','McFarland','','','','','','United States','','False','kelleyarowe@gmail.com','Kelley','','','','','','Rowe','(512) 785-1548','','','','','','','','','','','','','','','','True','','','WI','2368 County Road AB','','Primary Registrant','','53558','','False','','Registered','','','','','','','','','','','','','3','2','');
INSERT INTO "Summit_Events_Registration__c" VALUES(11,'','','','','','','','','','','','','','','','','','','False','mjZqEKpTOp5ez2T0XwQmRWu527AAjmo2G0XxsvL84OpKnwZU5liDnO9hfSJBTKRMLozLetsMXe446jX%2FpmF%2FnzYMb8BKDky%2Bg6wk4%2BNPijiLEsYkahWPpDnSufED2SIwl%2BREeqsoem1YnKWQMCJFlwj3KeXY%2BY%2F7WmjatH%2BOISg3sqwLMbr6ga2jDiGq7ygd1%2BKPpedhnvKNDPdbrL0UWaWmA06gAkgfYrte7SiyvmKrC','m55LVjKjU%2F93XJgRH6I','Thursday, November 16, 2023, 12:00 PM - 4:00 PM CDT','','https://data-innovation-8655-dev-ed.scratch.lightning.force.com/','https://data-innovation-8655-dev-ed.scratch.my.salesforce-sites.com/apex/SummitEventsRegister?instanceID=a067i000007oncK','','','Host attending','[{"questions":[{"value":"Max","question":"First Name","id":"t3%2BFam2paBuXeBfgq8SDnJQp407uNH6kqxygZGRAmvFtK9mqZ2u8LSCKEqYnCuep"},{"value":"Headroom","question":"Last Name","id":"v0XSDn7Vb2%2F%2FeCGXt1ADGy15GUAQ8JoS6WjnFDJBwLqS2LwsbJSjHRYT70lIuX48"},{"value":"thad+max@valleyhill.net","question":"Email","id":"R3XE5sfT4nPJ1cnilfTUrnlHLsVI7GHr9Tug4rW4zsIcHt3EE2daPGrv1PUIRY5a"},{"value":"","question":"Street Address","id":"TlhzHDqYiJo%2FQg%2FJnU%2FjM6DuOQpNJUMxo8cHNHTJp6StijriIKcMHJ1Yru%2F5v80%2F"},{"value":"","question":"City","id":"HlyCL3Cb3rF%2B%2FAMwUG0ubOU7JL8AH%2BKovkD%2BLlm4%2BJFratCxAM5dZMk4%2FSSgsou7"},{"value":"DE","question":"State","id":"0zIa7au4zdg2FlBQ%2Bcp1h4gVN8RTeJHLNOgHCwnC%2FDE5x9L2YS1eG1vqGyUywVRA"},{"value":"Cat","question":"What is your favorite pet?","id":"xejQtLcshNsIsz2uMRK2fFOshNz037oh68iD%2Frcx1N5S%2BEMLmtHXt%2Bj6G1VKo05E"}],"guestId":"imleeeecyi4g9vh910s2lzv169r245"},{"questions":[{"value":"Another","question":"First Name","id":"t3%2BFam2paBuXeBfgq8SDnJQp407uNH6kqxygZGRAmvFtK9mqZ2u8LSCKEqYnCuep"},{"value":"Guest","question":"Last Name","id":"v0XSDn7Vb2%2F%2FeCGXt1ADGy15GUAQ8JoS6WjnFDJBwLqS2LwsbJSjHRYT70lIuX48"},{"value":"thad+another@valleyhill.net","question":"Email","id":"R3XE5sfT4nPJ1cnilfTUrnlHLsVI7GHr9Tug4rW4zsIcHt3EE2daPGrv1PUIRY5a"},{"value":"","question":"Street Address","id":"TlhzHDqYiJo%2FQg%2FJnU%2FjM6DuOQpNJUMxo8cHNHTJp6StijriIKcMHJ1Yru%2F5v80%2F"},{"value":"","question":"City","id":"HlyCL3Cb3rF%2B%2FAMwUG0ubOU7JL8AH%2BKovkD%2BLlm4%2BJFratCxAM5dZMk4%2FSSgsou7"},{"value":"DE","question":"State","id":"0zIa7au4zdg2FlBQ%2Bcp1h4gVN8RTeJHLNOgHCwnC%2FDE5x9L2YS1eG1vqGyUywVRA"},{"value":"Hamster","question":"What is your favorite pet?","id":"xejQtLcshNsIsz2uMRK2fFOshNz037oh68iD%2Frcx1N5S%2BEMLmtHXt%2Bj6G1VKo05E"}],"guestId":"2vduassstir1o7uxl1pqbqtm1m3u4uf"}]','2.0','','','False','False','','','','','','','','','','','','','','','United States','','False','thad@valleyhill.net','Thad','','','','','','Dahlberg','','','','','','','','','','','','','','','','','False','','','','','','','','','','False','','Registered','','','','','','','','','','','','','1','3','');
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
INSERT INTO "Summit_Events__c" VALUES(4,'','','','','','','','','','','','','','','','','','','','','','','','False','','Application Type','Do not ask','Ask','Ask and require','Ask and require','False','Do not ask','Do not ask','Ask mobile and require','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','','Do not ask','','','2.0','','Do you belong to a team or other organization?','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','True','False','True','','','','Email','2023-11-05','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','<p>You will receive an event confirmation shortly (need to set up template). Please look to it for additional details relating to rules and check in procedures. </p>','Thank you for registering for this tournament!','','Event Cost','Event Charges','Total','200.0','Payments Received','','<p>Event is finished, see you next year!</p>','Confirm Wrestlers','Event Home','','Summit Wrestling Tournament 2023','','Payment Due','','Payment Received','Outdoor Open Wrestling at Millennium Park!','','Active','','','Admissions Event','<p style="text-align: center;"><img src="https://data-innovation-8655-dev-ed.scratch.file.force.com/servlet/rtaImage?eid=a0B7i00000Eoj8r&amp;feoid=00N7i00000atXPt&amp;refid=0EM7i000000M4z3" alt="Screenshot 2023-10-31 135310.png"></img>Outdoor Open Wrestling at Millennium Park!</p>','Register','','','First Name','Gender','15.0','Add Another Wrestler','<p>Add your team below. </p>','Register Additional Wrestlers','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','201 E Randolph St, Chicago, IL 60602','https://maps.app.goo.gl/efKLkmwybwA61tMr8','Millennium Park','On-Site','Registrant Address','15.0','Summit Wrestling Tournament','','Make Payment','No Gateway','Please provide your mobile phone number.','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-11-03','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
COMMIT;
