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
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(1,'','','','1','Active','','','False','','','','','','','<p>Get yourself some quiet time in our library.</p>','False','','False','1.0','Demo Appointment 0 - Quiet Time','','','','4');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(2,'','','','1','Active','','','False','','','','','','','There is such a thing!','False','','False','30.0','Demo Appointment 3 - Free Lunch','','','','4');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(3,'','','','1','Active','','','False','','','Chocolate

Vanilla

Strawberry

Lactose Free','','','','Choose the ice cream you could prefer to consume during your visit','False','Custom pick list','False','10.0','Demo Appointment 1 - Ice Cream with Counselor','','','','4');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(4,'','','','2','Active','','','False','','','','','','','What is your definition of the meaning of life?','False','Required text box','False','20.0','Demo Appointment 2 - Meaning of life','','','','4');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(5,'Attend A Class','','','1','Active','','','False','','','','','','','<p>See what a classroom experience is like.  You don&#39;t have to participate, but why not show your future peers was you&#39;re all about.</p>','False','','False','99.0','Attend a Class','','','','11');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(6,'Faculty Visit','','','2','Active','','','False','','','','','','','<p>Spend time with a Faculty Member and learn about their program.</p>','False','','False','30.0','Meet with Faculty','','','','11');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(7,'','','','1','Active','','10:00:00.000Z','True','Office of Admissions','Added and Required','','','','','<p>Campus Tour</p>','False','','False','10.0','Campus Tour','','','','11');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(8,'','','','1','Active','','09:45:00.000Z','True','Office of Admissions','Added but not shown','','','','','<p>Check-In at Admissions</p>','False','','False','20.0','Check-In','','','','11');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(9,'','','','1','Active','','','False','','','','','','','<p>Enjoy lunch in the main cafeteria and get the full experience of visiting campus!</p>','False','','False','40.0','Lunch (on us!)','','','','11');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES(10,'','','','1','Active','','17:00:00.000Z','True','','','','','','','<p><span style="font-size: 16px;">Are you planning on attending the community dinner at the end of Day 1?</span></p><p><br></p><p><span style="font-size: 16px;">Please share any special dietary or accessibility requirements.</span></p>','False','Text box','False','10.0','Day 1 Dinner','','','','12');
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
INSERT INTO "Summit_Events_Email__c" VALUES(1,'Registered','','','THIS IS TEXT','<p><span style="font-size: 16px;">Dear {!Registrant_First_Name__c},</span></p><p><br></p><p><span style="font-size: 16px;">We are thrilled to confirm your registration for the upcoming taking place on {!Event_Instance_Start_Date__c} at the </span><span style="font-size: 16px; color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);">{!</span><span style="font-size: 16px;">Location_Title__c</span><span style="font-size: 16px; color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);">}</span><span style="font-size: 16px;">. Thank you for choosing to be a part of this exciting event!</span></p><p><br></p><p><strong style="font-size: 16px;">Registration Details:</strong></p><p><span style="font-size: 16px;">Event Name: {!Event_Name__c}</span></p><p><span style="font-size: 16px;">Event Date: {!Event_Instance_Start_Date__c}</span></p><p><span style="font-size: 16px;">Event Location: </span><span style="font-size: 16px; color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);">{!Location_Title__c}</span></p><p><span style="font-size: 16px;">Registration ID: </span><span style="font-size: 16px; color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);">{!Name}</span></p><p><br></p><p><br></p><p><span style="font-size: 16px;">We have received your registration information and you are all set to join us. We can&#39;t wait to see you at the event. Here are a few important details to keep in mind:</span></p><p><br></p><p><span style="font-size: 16px;">Event Date: </span><span style="font-size: 16px; background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);">{!Event_Instance_Start_Date__c}</span></p><p><span style="font-size: 16px;">Event Time: </span><span style="font-size: 16px; background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);">{!Event_Instance_Start_Time__c}</span></p><p><span style="font-size: 16px;">Location: </span><span style="font-size: 16px; background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);">{!Location_Title__c}</span></p><p><span style="font-size: 16px;">Registration ID: </span><span style="font-size: 16px; background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);">{!Name}</span></p><p><br></p><p><span style="font-size: 16px;">Please arrive a little early to ensure a smooth check-in process. If you have any questions or need further assistance, don&#39;t hesitate to contact our event support team.</span></p><p><br></p><p><span style="font-size: 16px;">We have an exciting agenda planned with amazing speakers and valuable content. Get ready for an enriching experience!</span></p><p><br></p><p><span style="font-size: 16px;">Thank you for choosing to be a part of this event. We look forward to meeting you and hope you have a fantastic time.</span></p><p><br></p><p><span style="font-size: 16px;">Warm regards,</span></p><p><span style="font-size: 16px;">The Common Team!</span></p>','','Thank you for Registering! - Commons Open Source Sprint','','','','','','','12');
CREATE TABLE "Summit_Events_Fee_Allocation__c" (
                                                   id INTEGER NOT NULL,
                                                   "Name" VARCHAR(255),
                                                   PRIMARY KEY (id)
);
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES(1,'Gala Ticket Sales');
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES(2,'Gala General Donations');
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES(3,'General Fund');
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
INSERT INTO "Summit_Events_Instance__c" VALUES(1,'Active','','False','','Registrants plus Guests','150.0','','','','','2023-11-11','17:00:00.000Z','','2023-11-11','08:30:00.000Z','Central Daylight Time (America/Chicago)','In-Person','','','','','False','','','','','2');
INSERT INTO "Summit_Events_Instance__c" VALUES(2,'Active','','False','','Registrants plus Guests','900.0','','','','','2024-03-01','23:00:00.000Z','','2024-03-01','19:00:00.000Z','Central Daylight Time (America/Chicago)','A Night of Giving Hope 2024','','','','','False','','','','','1');
INSERT INTO "Summit_Events_Instance__c" VALUES(3,'Active','','False','','Registrants plus Guests','100.0','','','','','2023-11-12','12:30:00.000Z','Testing additional questions with this event.','2023-11-12','08:00:00.000Z','Central Daylight Time (America/Chicago)','Secondary Title','','','','','False','','','','','3');
INSERT INTO "Summit_Events_Instance__c" VALUES(4,'Active','','False','','Registrants plus Guests','100.0','','','','','2023-11-03','15:30:00.000Z','A short description','2023-11-03','08:00:00.000Z','Central Daylight Time (America/Chicago)','Secondary Title','','','','','False','','','','','4');
INSERT INTO "Summit_Events_Instance__c" VALUES(5,'Active','','False','','Registrants plus Guests','100.0','','','','','2023-11-10','13:15:00.000Z','A short description','2023-11-10','09:00:00.000Z','Central Daylight Time (America/Chicago)','A special Title','','','','','False','','','','','4');
INSERT INTO "Summit_Events_Instance__c" VALUES(6,'Active','','False','','Registrants plus Guests','1000.0','','','','','2023-11-16','16:00:00.000Z','Test event for gathering guest registrations from registrant.','2023-11-16','12:00:00.000Z','Central Daylight Time (America/Chicago)','Secondary Title','','','','','False','','','','','5');
INSERT INTO "Summit_Events_Instance__c" VALUES(7,'Active','','False','','Registrants plus Guests','500.0','','','','','2023-11-16','23:00:00.000Z','Annual Dinner & Auction','2023-11-16','18:00:00.000Z','Central Daylight Time (America/Mexico_City)','Annual Dinner & Auction','','','','','False','','','','','6');
INSERT INTO "Summit_Events_Instance__c" VALUES(8,'Active','','False','','Registrants plus Guests','72.0','','','','','2024-06-04','15:00:00.000Z','2024 Fundraising Golf Event','2024-06-04','09:00:00.000Z','Eastern Standard Time (America/Panama)','2024 Fundraising Golf Event','','','','','False','','','','','7');
INSERT INTO "Summit_Events_Instance__c" VALUES(9,'Active','','False','','Registrants plus Guests','20.0','','','','','2023-12-08','20:30:00.000Z','December 2023 Caregiver Support','2023-12-08','19:00:00.000Z','Eastern Standard Time (America/Panama)','December 2023 Caregiver Support','','','','','False','','','','','8');
INSERT INTO "Summit_Events_Instance__c" VALUES(10,'Active','','False','','Registrants plus Guests','20.0','','','','','2024-03-08','20:30:00.000Z','March 2024 Caregiver Support','2024-03-08','19:00:00.000Z','Eastern Standard Time (America/Panama)','March 2024 Caregiver Support','','','','','False','','','','','8');
INSERT INTO "Summit_Events_Instance__c" VALUES(11,'Active','','False','','Registrants plus Guests','20.0','','','','','2024-02-09','20:30:00.000Z','February 2024 Caregiver Support','2024-02-09','19:00:00.000Z','Eastern Standard Time (America/Panama)','February 2024 Caregiver Support','','','','','False','','','','','8');
INSERT INTO "Summit_Events_Instance__c" VALUES(12,'Active','','False','','Registrants plus Guests','20.0','','','','','2024-01-12','20:30:00.000Z','December 2024 Caregiver Support','2024-01-12','19:00:00.000Z','Eastern Standard Time (America/Panama)','January 2024 Caregiver Support','','','','','False','','','','','8');
INSERT INTO "Summit_Events_Instance__c" VALUES(13,'Active','','False','','Registrants plus Guests','20.0','','','','','2024-05-10','20:30:00.000Z','May 2024 Caregiver Support','2024-05-10','19:00:00.000Z','Eastern Standard Time (America/Panama)','May 2024 Caregiver Support','','','','','False','','','','','8');
INSERT INTO "Summit_Events_Instance__c" VALUES(14,'Active','','False','','Registrants plus Guests','20.0','','','','','2024-04-12','20:30:00.000Z','April 2024 Caregiver Support','2024-04-12','19:00:00.000Z','Eastern Standard Time (America/Panama)','April 2024 Caregiver Support','','','','','False','','','','','8');
INSERT INTO "Summit_Events_Instance__c" VALUES(15,'Active','','False','','Registrants plus Guests','300.0','','','','','2023-11-04','20:00:00.000Z','Day 1','2023-11-04','07:00:00.000Z','Central Daylight Time (America/Chicago)','Saturday, November 4th 2023','','','','','False','','','','','9');
INSERT INTO "Summit_Events_Instance__c" VALUES(16,'Active','','False','','Individual Registrants','40.0','','','','','2024-06-14','23:59:00.000Z','Operated by Orbridge Travel','2024-06-09','00:00:00.000Z','Central Daylight Time (America/Chicago)','Cruise to Japan','','','','','False','','','','','10');
INSERT INTO "Summit_Events_Instance__c" VALUES(17,'Active','','False','','Registrants plus Guests','25.0','','','','','2023-11-09','16:00:00.000Z','Tour @ 2pm','2023-11-09','12:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Afternoon','','','','','False','','','','','11');
INSERT INTO "Summit_Events_Instance__c" VALUES(18,'Active','','False','','Registrants plus Guests','25.0','','','','','2023-11-07','12:00:00.000Z','Tour @ 10am','2023-11-07','08:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Morning','','','','','False','','','','','11');
INSERT INTO "Summit_Events_Instance__c" VALUES(19,'Active','','False','','Registrants plus Guests','25.0','','','','','2023-11-06','12:00:00.000Z','Tour @ 10am','2023-11-06','08:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Morning','','','','','False','','','','','11');
INSERT INTO "Summit_Events_Instance__c" VALUES(20,'Active','','False','','Registrants plus Guests','25.0','','','','','2023-11-10','16:00:00.000Z','Tour @ 2pm','2023-11-10','12:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Afternoon','','','','','False','','','','','11');
INSERT INTO "Summit_Events_Instance__c" VALUES(21,'Active','','False','','Registrants plus Guests','25.0','','','','','2023-11-10','12:00:00.000Z','Tour @ 10am','2023-11-10','08:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Morning','','','','','False','','','','','11');
INSERT INTO "Summit_Events_Instance__c" VALUES(22,'Active','','False','','Registrants plus Guests','25.0','','','','','2023-11-08','12:00:00.000Z','Tour @ 10am','2023-11-08','08:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Morning','','','','','False','','','','','11');
INSERT INTO "Summit_Events_Instance__c" VALUES(23,'Active','','False','','Registrants plus Guests','25.0','','','','','2023-11-06','16:00:00.000Z','Tour @ 2pm','2023-11-06','12:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Afternoon','','','','','False','','','','','11');
INSERT INTO "Summit_Events_Instance__c" VALUES(24,'Active','','False','','Registrants plus Guests','25.0','','','','','2023-11-07','16:00:00.000Z','Tour @ 2pm','2023-11-07','12:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Afternoon','','','','','False','','','','','11');
INSERT INTO "Summit_Events_Instance__c" VALUES(25,'Active','','False','','Registrants plus Guests','25.0','','','','','2023-11-08','16:00:00.000Z','Tour @ 2pm','2023-11-08','12:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Afternoon','','','','','False','','','','','11');
INSERT INTO "Summit_Events_Instance__c" VALUES(26,'Active','','False','','Registrants plus Guests','25.0','','','','','2023-11-09','12:00:00.000Z','Tour @ 10am','2023-11-09','08:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Morning','','','','','False','','','','','11');
INSERT INTO "Summit_Events_Instance__c" VALUES(27,'Active','','False','','Registrants plus Guests','150.0','','','','','2023-11-22','17:00:00.000Z','Can''t be there in-person, we have an option for you!','2023-11-21','08:30:00.000Z','Central Daylight Time (America/Chicago)','Virtual','Sent via Email closer to date','https://trailhead.salesforce.com/trailblazer-community/groups/0F94S000000GwVK?tab=discussion&sort=LAST_MODIFIED_DATE_DESC#discussion?icid=SFORG:resource-page-hero:','Virtual/Zoom','Online','False','','https://www.meetinglink.demo','','','12');
INSERT INTO "Summit_Events_Instance__c" VALUES(28,'Active','','False','','Registrants plus Guests','150.0','','','','','2024-01-10','17:00:00.000Z','Come join us inperson!','2024-01-09','08:30:00.000Z','Central Daylight Time (America/Chicago)','In-Person','','','New York Salesforce Tower','On-Site','False','','','','','12');
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
INSERT INTO "Summit_Events_Question__c" VALUES(1,'','','','Third width','','','Please enter your Slack email - If you don''t have one use this hint (create a Slack account for yourself)','','True','','','','','','','','','Registrant_Other_Email__c','Slack Email Required','','','Email','What is your Slack email - to stay connected?','Registrant and Guest','True','','','2');
INSERT INTO "Summit_Events_Question__c" VALUES(2,'','','','','','','','','True','','','','','','','','','First_Name_Label__c','Guest First Name','','','Textbox','Guest First Name','Guest','True','','','1');
INSERT INTO "Summit_Events_Question__c" VALUES(3,'','','','','','','','','True','','','','','','','','','Last_Name_Label__c','Guest Last Name','','','Textbox','Guest Last Name','Guest','True','','','1');
INSERT INTO "Summit_Events_Question__c" VALUES(4,'','','','','Please enter a valid email address.','','','','True','','','','','','','','','Email_Label__c','Guest Email','','','Email','Guest Email','Guest','True','','','1');
INSERT INTO "Summit_Events_Question__c" VALUES(5,'','','3.0','','State is a required field.','Registrant_State_Global__c','Ask your State representative what state you live in.','Enter the state your home is resides,','True','','','','','','','','','Registrant_State_Global__c','State','','','Picklist','State','Registrant','True','','','3');
INSERT INTO "Summit_Events_Question__c" VALUES(6,'','','2.0','','City is a required field','','If you can''t find your home city consult google maps.','Enter the city where your home resides.','True','','','','','','','','','Registrant_City__c','City','','','Textbox','City','Registrant','True','','','3');
INSERT INTO "Summit_Events_Question__c" VALUES(7,'','','10.0','','A pet type is required. Please choose one.','','If you don''t like pets than choose the on you dislike the least.','','True','','','','','','','','','Add_Info_Answer_1__c','Test Registrant Favorite Pet','','Dog

Cat

Hamster

Chicken

Snake','Picklist','What is your favorite pet?','Registrant','True','','','3');
INSERT INTO "Summit_Events_Question__c" VALUES(8,'','','1.0','','Street address is a required field','','This address should include house number and the street you live on.','Please enter your home address','True','','','','','','','','','Registrant_Street_1__c','Street Address','','','Textbox','Street Address','Registrant','True','','','3');
INSERT INTO "Summit_Events_Question__c" VALUES(9,'','','6.0','','State is a required field.','Registrant_State_Global__c','Ask your State representative what state you live in.','Enter the state your home is resides,','True','','','','','','','','','Registrant_State_Global__c','Guest Registrant State','','','Picklist','State','Guest','False','','','5');
INSERT INTO "Summit_Events_Question__c" VALUES(10,'','','20.0','','A pet type is required. Please choose one.','','If you don''t like pets than choose the on you dislike the least.','','True','','','','','','','','','Add_Info_Answer_1__c','Guest Registrant Favorite Pet','','Dog

Cat

Hamster

Chicken

Snake','Picklist','What is your favorite pet?','Guest','False','','','5');
INSERT INTO "Summit_Events_Question__c" VALUES(11,'','','4.0','','Street address is a required field','','This address should include house number and the street you live on.','Please enter your home address','True','','','','','','','','','Registrant_Street_1__c','Guest Registrant Street Address','','','Textbox','Street Address','Guest','False','','','5');
INSERT INTO "Summit_Events_Question__c" VALUES(12,'','','5.0','','City is a required field','','If you can''t find your home city consult google maps.','Enter the city where your home resides.','True','','','','','','','','','Registrant_City__c','Guest Registrant City','','','Textbox','City','Guest','False','','','5');
INSERT INTO "Summit_Events_Question__c" VALUES(13,'','','1.0','','','','','','True','','','','','','','','','Registrant_First_Name__c','Guest Registrant First Name','','','Textbox','First Name','Guest','False','','','5');
INSERT INTO "Summit_Events_Question__c" VALUES(14,'','','3.0','','','','','','True','','','','','','','','','Registrant_Email__c','Guest Registrant Email','','','Email','Email','Guest','False','','','5');
INSERT INTO "Summit_Events_Question__c" VALUES(15,'','','2.0','','','','','','True','','','','','','','','','Registrant_Last_Name__c','Guest Registrant Last Name','','','Textbox','Last Name','Guest','False','','','5');
INSERT INTO "Summit_Events_Question__c" VALUES(16,'','','','','','','','','True','','','','','','','','','Registrant_Last_Name__c','Golfer 1 Last Name','','','Textbox','Last Name','Guest','False','','','7');
INSERT INTO "Summit_Events_Question__c" VALUES(17,'','','','','','','','','True','','','','','','','','','Registrant_First_Name__c','Golfer email','','','Email','email','Guest','False','','','7');
INSERT INTO "Summit_Events_Question__c" VALUES(18,'','','','','','','','','True','','','','','','','','','Registrant_First_Name__c','Golfer 1 First Name','','','Textbox','First Name','Guest','False','','','7');
INSERT INTO "Summit_Events_Question__c" VALUES(19,'','','','Half width','','','','','True','','','','','','','','','Registrant_First_Name__c','First Name','','','Textbox','First Name','Registrant','True','','','9');
INSERT INTO "Summit_Events_Question__c" VALUES(20,'','','','','','','','','True','','','','','','','','','Add_Info_Answer_4__c','Reference','','','Textbox','How did you hear about us?','Registrant','False','','','9');
INSERT INTO "Summit_Events_Question__c" VALUES(21,'','','','','','','','If Applicable','True','','','','','','','','','Add_Info_Answer_3__c','Style','Freestyle

Folkstyle

Both - YOU MAY NOT RECIEVE THE SUGGESTED 30MIN REST TIME','','Picklist','Which Style Bracket?','Registrant and Guest','False','','','9');
INSERT INTO "Summit_Events_Question__c" VALUES(22,'','','','','','','','','True','','','','','','','','','Registrant_Date_of_Birth__c','Birthday','','','Date','Birthday','Registrant','False','','','9');
INSERT INTO "Summit_Events_Question__c" VALUES(23,'','','','','','','','','True','','','','','','','','','Add_Info_Answer_2__c','Weight Class','W - 110 lbs

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

M - 276 lbs','','Picklist','What Weight Class will they compete in?','Registrant and Guest','False','','','9');
INSERT INTO "Summit_Events_Question__c" VALUES(24,'','','','','','','','','True','','','','','','','','','Registrant_Last_Name__c','Last Name','','','Textbox','Last Name','Registrant','True','','','9');
INSERT INTO "Summit_Events_Question__c" VALUES(25,'','','','','','','','','True','','','','','','','','','Add_Info_Answer_1__c','Attendee','Coach

Wrestler

Trainer

Referee','','Picklist','What kind of registration?','Registrant and Guest','True','','','9');
INSERT INTO "Summit_Events_Question__c" VALUES(26,'','','','Half width','','','','','True','','','','','','','','','Registrant_Gender__c','Gender','Male

Female','','Picklist','Gender','Guest','False','','','9');
INSERT INTO "Summit_Events_Question__c" VALUES(27,'','','','','','','','If you will be traveling with someone who is not included on this registration, please provide their name and we will match up your itineraries. If you are traveling solo, do not include a name and you will be contact separately about your single supplement fee.','True','','','','','','','','','event_cotraveler__c','Travel Companion Name','','','Textbox','Co-traveler name (optional)','Registrant','False','','','10');
INSERT INTO "Summit_Events_Question__c" VALUES(28,'','','10.0','Half width','','','','What High School or College do you go to?','True','','','','','','','','','Registrant_High_School__c','High School/College','','','Textbox','High School/College','Registrant','True','100.0','','11');
INSERT INTO "Summit_Events_Question__c" VALUES(29,'','','','Half width','','','This is just to drive conversation, not holding you to anything!','If you don''t know, leave it blank and we can talk about it more later.','True','','','','','','','','','Add_Info_Answer_1__c','College Credits','','','Textbox','Are you intended to transfer in credits? If so, How many?','Registrant','False','','','11');
INSERT INTO "Summit_Events_Question__c" VALUES(30,'','','10.0','Half width','Please enter a valid email address.','','','Please share your the email address associated to your Slack account.  Don''t have a Slack account, you''re about to!','True','','','','','','','','','Registrant_Other_Email__c','Other Email','','','Email','Other Email (for Slack purposes during the sprint if different to the above).','Registrant','False','100.0','','12');
INSERT INTO "Summit_Events_Question__c" VALUES(31,'','','20.0','Half width','','','Example: https://github.com/USERNAME. *','','True','','','','','','','','','Add_Info_Answer_4__c','Github User','','','Textbox','What is your GitHub Username?','Registrant','True','100.0','','12');
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
INSERT INTO "Summit_Events__c" VALUES(1,'','','','','','','','','','','','','','','','','','','','','','','','False','','Application Type','Do not ask','Ask','Do not ask','Do not ask','False','Do not ask','Ask','Ask mobile and require','Do not ask','Do not ask','Ask','Do not ask','Do not ask','','Ask','General Public','','0.0','','Company or Organization','Standard Contact Duplicate Rule','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','Use Salesforce Duplicate Rule','Green','','Date of Birth','True','True','True','<p>If you&#39;d like to directly support our work before the gala, you can do so here. Thank you for helping us continue our mission!</p>','50','Additional Donation','Email','2024-10-31','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','<p><span style="font-size: 16px;">You will receive an email confirmation. If you have any questions or concerns, please do not hesitate to reach out to </span><span style="color: rgb(3, 45, 96); font-size: 16px;">j.doe@givinghope.org.</span></p><p><br></p><p><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/e74b3a71bb11c14d7ea71da1a016e2a3bfc88d7d/evt-img/gala-thank-you.png" alt="12 Ways to Say “Thank You” With Examples | Grammarly"></img></p>','We look forward to seeing you at A Night of Giving Hope 2024!','','Event Cost','Event Charges','Total','200.0','Payments Received','','','Register your guest(s).','Event Home','','Gala Fundraising Event','','Payment Due','','Payment Received','','','Active','<p><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Gala-Fundraising-event-Ticket.jpg" alt="Picture of a ticket"></img></p><p><strong style="font-size: 16px;">Ticket Information:</strong></p><ul><li><span style="font-size: 16px;">Individual Ticket: $200</span></li><li><span style="font-size: 16px;">Couple Ticket: $350</span></li><li><span style="font-size: 16px;">Corporate Table (Seats 5): $5,000</span></li><li><span style="font-size: 16px;">Corporate Table (Seats 10): $10,000</span></li></ul><p><span style="font-size: 16px;">Your ticket includes dinner, entertainment, and the chance to be a part of a night dedicated to making the world a better place. Reserve your place now, and together, let&#39;s create a future filled with hope, love, and opportunity for all. Your support can change lives, and this gala is your chance to make it happen.</span></p>','Complete your Registration','Fundraising','<p><strong style="font-size: 18px;">We&#39;re very excited to invite you to join us for an enchanting evening of elegance, compassion, and generosity at our &quot;A Night of Giving Hope&quot; Gala Fundraising Event. This fun event is your opportunity to make a meaningful difference in the lives of those in need while enjoying an unforgettable night of entertainment, gourmet dining, and socializing!</strong></p><p><br></p><p><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Gala-Fundraising-Table.jpg" alt="galatable-2019-May15-1 (1).jpeg"></img></p><p><br></p><p><strong style="font-size: 16px;">Event Highlights:</strong></p><ul><li><span style="font-size: 16px;">Dining: Savor a variety of gourmet bites prepared by local fan-favorite restaurants, accompanied by an open bar with a variety of drink options (and a delicious cocktail of the night!).</span></li><li><span style="font-size: 16px;">Silent Auction: Bid on an array of exclusive items, including art, luxury experiences, and unique memorabilia, with all proceeds going toward our cause.</span></li><li><span style="font-size: 16px;">Fundraising Activities: Participate in various fundraising activities, from pledging to donation stations, to directly impact the lives of those we serve.</span></li><li><span style="font-size: 16px;">Impact Showcase: Witness firsthand how your contributions are making a difference through touching stories and presentations from our beneficiaries.</span></li><li><span style="font-size: 16px;">Networking Opportunities: Connect with fellow philanthropists, community leaders, and our dedicated team who share your passion for making a positive impact.</span></li></ul><p><strong style="font-size: 16px;">Dress Code: Cocktail Attire</strong></p><p><br></p><p><span style="font-size: 16px;">Your presence at this gala will not only make the evening extraordinary but will also help us continue our mission to impact the lives of youth all around Chicago. Every dollar raised during this event will go towards free extracurricular activities for Chicago schools that need them, bringing us one step closer to our vision of a better, brighter future.</span></p>','Register','','','First Name','Gender','','Register Guest','<p>It&#39;s even more fun with family and friends! Please fill out the information below for your guests. If you are interested in buying a table for 5 or 10 people, please email j.doe@givinghope.org.</p>','Bring a guest! Or even better, multiple guests.','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','True','Last Name As Student','Last Name','','','','','3057 N Rockwell S','https://maps.app.goo.gl/PP4WNqeHwv7bGNFj9','Rockwell on the River','On-Site','Registrant Address','','Gala Fundraising Event','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-10-01','GeneralSLDS','I am...','Title','','','','','','','2','','','','','','1');
INSERT INTO "Summit_Events__c" VALUES(2,'','','','1-500 employees

501-1000 employees

1001-5000 employees

5001-10000 employees

10001+ employees','ISV

Consulting

Customer

Just Sprinting','','','','','','','','','Number of Employees','How do you categorize your organization?','What is your GitHub username?','','','Pick-list','Pick-list','Text area required','','','False','','Application Type','Do not ask','Ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Ask mobile and require','Do not ask','Ask','Ask','Do not ask','Do not ask','','Ask','General Public','','0.0','','Company or Organization','Standard Contact Duplicate Rule','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','Use Salesforce Duplicate Rule','Admissions','','Date of Birth','False','False','False','','','','Email','2024-10-01','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','','','','Event Cost','Event Charges','Total','','Payments Received','<p><span style="color: rgb(68, 68, 68);"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Nirvik_Footer.jpg" alt="Salesforce logo"></img></span></p>','<p>This Event&#39;s Registration is now CLOSED. Get ready to Sprint on the next one! We&#39;ll miss you.</p>','','Event Home','','Open Source Sprint Event','','Payment Due','','Payment Received','Open Source Sprint Event','','','','','Info Session','<p><span style="font-size: 16px;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Nirvik_Header.jpg" alt="image.png"></img></span></p><p><br></p><p><span style="font-size: 16px;">﻿Get ready to rock the Windy City with </span><strong style="font-size: 16px; color: rgb(0, 158, 219);">Salesforce</strong><span style="font-size: 16px;">&#39;s</span><strong style="font-size: 16px;"> </strong><span style="font-size: 16px;">tech extravaganza! &#127788;️ Join us at the </span><strong style="font-size: 16px;">Salesforce Commons Sprint </strong><span style="font-size: 16px;">event in the heart of Chicago. &#127961;️</span></p><p><br></p><p><span style="font-size: 16px; color: rgb(0, 0, 0);">The Sprint is not just another event – it&#39;s your ticket to tech-tastic fun, and it&#39;s totally free! Whether you&#39;re a beginner or a Salesforce ninja, there&#39;s something for everyone at the Sprint. &#128640; You&#39;ll learn from Salesforce experts, rub shoulders with like-minded tech enthusiasts, and even get</span><span style="font-size: 16px;"> a chance to create something that truly rocks! &#129302;&#127881;</span></p><p><br></p><p><span style="font-size: 16px;">Imagine a tech playground where innovation knows no bounds. Our Sprints are like community innovation parties (think hack-a-thon meets carnival) designed to unite Salesforce partners, customers, and our amazing employee volunteers. Together, we brainstorm, prioritize, and build solutions that make using Salesforce a breeze, especially for nonprofit &amp; education organizations. &#129504;&#127905;</span></p><p><br></p><p><span style="font-size: 16px;">Come for the knowledge, stay for the thrill! Connect, learn, and supercharge your Salesforce expertise with the coolest crowd in the industry. Whether you&#39;re a tech newbie or a seasoned pro, this sprint is your backstage pass to a tech party like no other. &#128378;&#128131;</span></p><p><br></p><p><span style="font-size: 16px;">Don&#39;t miss your chance to ride the innovation wave! &#127754;</span></p><p><span style="font-size: 16px;">Save the date, grab your tech gear, and stay tuned for more juicy details. See you in Chicago, where tech dreams come true! &#127880;&#127775;</span></p><p><br></p><p><span style="font-size: 16px;">Ready to have a blast and make a difference at the </span><strong style="font-size: 16px;">October Nonprofit &amp; Education Community Sprint</strong><span style="font-size: 16px;">? Register below, and let&#39;s get this tech party started! &#127882;&#128640;&#128187;</span></p><p><br></p><p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Nirvik_Mid-1.jpg" alt="Picture of Commons Director"></img> <img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Nirvik_Mid-2.jpg" alt="Salesforce Trailblazer Community logo"></img></p><p><strong style="font-size: 16px;">What is a Sprint?</strong><span style="font-size: 16px;"> The Sprint is a hack-a-thon type event, where you will contribute your skills in small breakout groups and work with others, to discuss different Salesforce technology challenges.</span></p><p><span style="font-size: 16px;"> </span></p><p><span style="font-size: 16px;">Connect and collaborate with your peers to build solutions to common challenges prioritised by you and the community. </span></p><p><span style="font-size: 16px;"> </span></p><p><strong style="font-size: 16px;">Who should attend?</strong><span style="font-size: 16px;"> Register if you&#39;re an </span><strong style="font-size: 16px;">Admin</strong><span style="font-size: 16px;">, </span><strong style="font-size: 16px;">Developer</strong><span style="font-size: 16px;">, </span><strong style="font-size: 16px;">Consultant</strong><span style="font-size: 16px;">, or </span><strong style="font-size: 16px;">End-User </strong><span style="font-size: 16px;">in the </span><u style="font-size: 16px;">Nonprofit</u><span style="font-size: 16px;"> or </span><u style="font-size: 16px;">Education</u><span style="font-size: 16px;"> Salesforce community.</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><strong style="color: rgb(0, 158, 219); font-size: 16px;">Meet the Team</strong></p><p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Nirvik_Pre-Footer_1.jpg" alt="image.png"></img></p>','Register','','','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','True','Last Name As Student','Last Name','','','','','333 W Wolf Point Plaza','https://maps.app.goo.gl/ASZMg32hRja4a7vr7','Chicago','On-Site','Registrant Address','','Open Source Sprint Event','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-10-01','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(3,'','','','','','','','','','','','','','','','','','','','','','','','False','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','','Do not ask','General Public','','0.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','False','False','False','','','','Email','2023-11-26','Custom Questions','<p>These questions are defined in the custom questions object that looks up to your event object.</p>','Selected options','Body text for the appointment/options page explains what these appointments are about.','Once you have made your selections click next.','','This is the header of the appointment/options page.','Choose your options','What does it mean to cancel a event.','Online Cancel of Registration Heading','The event has been cancelled.','Explain the registration has been received from the client at this point and is complete','Registration has been received title.','','Event Cost','Event Charges','Total','','Payments Received','This footer appears on every event registration page in the footer.','Explain here that the event has reached capacity and is closed.','','Event Home','','Test Event Additional Questions for Registrant','','Payment Due','','Payment Received','This description appears in feed and should be concise','','Active','Description of submission being the final act in the registration play.','Heading for the Submit Page','Admissions Event','<p><b>Rich Text</b> description of the event that appears on the first registration page. This event will test the additional questions feature of Summit Events as applied to the registrant only.</p>','Register','','','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','123 Evergreen Blvd., St. Paul, MN','https://g.page/sociablecider?share','The best place in the World','','Registrant Address','','Test Event Additional Questions for Registrant','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-09-26','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(4,'','','','Red

Yellow

Green

Blue','','','','','','','','','','What is your favorite color?','What''s up?','What''s your favorite day of the week?','','','Pick-list','Text area','Text box required','','','True','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','True','Do not ask','Ask','Ask with type require','Do not ask','Do not ask','Ask','Ask but do not require','Do not ask','Parent/Guardian;Other','Do not ask','General Public','','0.0','Don''t ask','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','False','False','False','','','','Email','2023-11-26','','','Selected options','Body text for the appointment/options page explains what these appointments are about.','Once you have made your selections click next.','','This is the header of the appointment/options page.','Choose your options','What does it mean to cancel a event.','Online Cancel of Registration Heading','The event has been cancelled.','Explain the registration has been received from the client at this point and is complete','Registration has been received title.','','Event Cost','Event Charges','Total','','Payments Received','This footer appears on every event registration page in the footer.','Explain here that the event has reached capacity and is closed.','','Event Home','','Test Event','','Payment Due','','Payment Received','This description appears in feed and should be concise','','Active','Description of submission being the final act in the registration play.','Heading for the Submit Page','Admissions Event','<p><strong>Rich Text</strong> description of the event that appears on the first registration page.</p>','Register','','','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','123 Evergreen Blvd., St. Paul, MN','https://g.page/sociablecider?share','The best place in the World','','Registrant Address','5.0','Test Event','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-09-26','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(5,'','','','','','','','','','','','','','','','','','','','','','','','False','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','','Do not ask','General Public','','0.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','True','False','False','','','','Email','2023-11-26','Custom Questions','<p>These questions are defined in the custom questions object that looks up to your event object.</p>','Selected options','Body text for the appointment/options page explains what these appointments are about.','Once you have made your selections click next.','','This is the header of the appointment/options page.','Choose your options','What does it mean to cancel a event.','Online Cancel of Registration Heading','The event has been cancelled.','Explain the registration has been received from the client at this point and is complete','Registration has been received title.','','Event Cost','Event Charges','Total','','Payments Received','This footer appears on every event registration page in the footer.','Explain here that the event has reached capacity and is closed.','','Event Home','','Test Event for Additional Guest Registrations','','Payment Due','','Payment Received','This description appears in feed and should be concise','','Active','Description of submission being the final act in the registration play.','Heading for the Submit Page','Admissions Event','<p><b>Rich Text</b> description of the event that appears on the first registration page. This event will test gathering additional registrations for guests of the registrant.</p>','Register','','','First Name','Gender','5.0','Submit Guest Registration','<p>Please let us know who you are bringing so we can prepare the best possible event for your guests.</p>','Are you bringing additional guests','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','123 Evergreen Blvd., St. Paul, MN','https://g.page/sociablecider?share','The best place in the World','','Registrant Address','','Test Event for Additional Guest Registrations','Guest registrations will appear here once you add them. None have been added yet.','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-09-26','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(6,'','','','Yes

No','Yes

No','','','','','','','','','Table Sponsor, $1,000 (8 tickets)','Co-Table Sponsor, $500 (4 tickets)','Individual Ticket, $75 (1 ticket)','','','Pick-list','Pick-list','Pick-list','','','False','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Ask with type','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','','Do not ask','General Public','','7.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','False','False','False','','','','Email','2023-11-16','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','<p>Thank you for your registration - see you at the event</p>','Your Confirmed','','Event Cost','Event Charges','Total','','Payments Received','','','','Event Home','','Area on Aging Annual Dinner & Auction','','Payment Due','','Payment Received','Annual Dinner & Auction','','Active','','','Fundraising','<p><span style="color: rgb(0, 0, 0); background-color: initial;">The Local Area on Aging and Event Sponsor TBD Company® are pleased to host the 38th Annual Dinner and Auction on November 16, 2023 at the Kellogg Hotel and Conference Center in East Lansing to raise funds for Meals on Wheels and in-home services for older adults in Clinton, Eaton, and Ingham counties.</span></p><p> </p><p><span style="color: rgb(0, 0, 0); background-color: initial;">We expect over 350 people to join us for this evening of dining, live and silent auctions, raffle with cash prizes, games and entertainment, cash bar, and many opportunities to socialize in the name of a good cause.</span></p><p> </p><p><span style="color: rgb(0, 0, 0); background-color: initial;">All proceeds benefit local older adults and adults with disabilities to remain safe and independent as they age. TCOA connects with over 18,000 people each year who need help, and we are able to do this in part through support from community sponsors, individual attendees, and raffle ticket sales.</span></p><p> </p><p><span style="color: rgb(0, 0, 0); background-color: initial;">Please join us for a wonderful evening in support of keeping our aging neighbors, friends, and families safe and thriving in the community. </span></p><p> </p><p><strong><u>Sponsor:</u></strong> Options range from a $500 Co-Table (four seats) to $10,000.</p><p><a href="https://interland3.donorperfect.net/weblink/WebLink.aspx?name=tcoa&amp;id=28" target="_blank" style="color: rgb(17, 18, 18);"><strong>Purchase Individual Tickets for $75 Each</strong></a></p><p><br></p><p><br></p>','Register','All Websites','All Websites','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','219 S Harrison Rd, East Lansing, MI 48824','https://maps.app.goo.gl/bc1Mq98XyrqvsSjE8','Kellog Hotel & Convention Center','On-Site','Registrant Address','500.0','Area on Aging Annual Dinner & Auction','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-08-01','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(7,'','','','','','','','','Hole sponsor - $1,000 (includes 4 golfers)

Team Sponsor - $400 (includes 4 golfers)

Twosome - $200 (includes 2 golfers)

Individual golfer - $100','','','','','Registration Type','','','','','Pick-list','','','','','True','','Application Type','Do not ask','Ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Do not ask','Do not ask','Ask','Do not ask','Do not ask','Do not ask','','Do not ask','General Public','','7.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','True','False','False','','','','Email','2024-06-04','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','','','','Event Cost','Event Charges','Total','','Payments Received','','','','Event Home','','2024 AR Golf Event','','Payment Due','','Payment Received','2024 Golf Event','','Active','','','Fundraising','<p style="text-align: center;"><strong style="font-size: 16px;">Annual Fundraising Golf Event</strong></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 16px;">2024 AR Fundraising Golf Event</span></p><p style="text-align: center;"><span style="font-size: 16px;">Proceeds to benefit AR scholarship fund</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 16px;">Shotgun start - 9AM - June 4, 2024</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/golf1.jpg" alt="Indian Boundary Golf Course | Golf Courses Chicago Illinois"></img></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p>','Register','All Websites','All Websites','First Name','Gender','4.0','','','Golf Team','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','2231 S Harrison Rd, East Lansing, MI 48823','https://maps.app.goo.gl/Fnq3GmPdETEYDR4m6','Forrest Akers East','','Registrant Address','3.0','2024 AR Golf Event','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','One registration per instance','Relationship (select all that apply)','2024-06-04','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(8,'','','','Yes

No

Other','Spouse

Family member (non-spouse)

Non-family member','','','','','','','','','Are you a caregiver of someone with Dementia','What is your relation to the individual suffering from dementia?','What is your biggest need of help or support?','','','Pick-list','Pick-list','Text area','','','True','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Ask with type','Do not ask','Ask','Do not ask','Do not ask','Do not ask','','Do not ask','General Public','','0.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','False','False','False','','','','Email','2024-10-01','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','<p>Confirmation of Registration</p>','Thank you for Registering','','Event Cost','Event Charges','Total','0.0','Payments Received','<p style="text-align: center;">Dementia Care Support Group is a non-profit dedicated to proving support to caregivers</p><p><br></p><p><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/dementia-support-banner.jpg" alt="We Support Caregivers Of Loved Ones With Dementia"></img></p>','<p>Sorry, this event is currently closed - please call our office for more information for caregivers.</p>','','Event Home','','Dementia Caregiver Support','','Payment Due','','Payment Received','Series of Events to support caregivers supporting those suffering from Dementia','Center for Common Good','Active','','','Info Session','<p style="text-align: center;"><strong style="font-size: 16px; color: rgb(14, 50, 234);">Dementia Care Giver Support Group</strong></p><p><br></p><p><span style="font-size: 16px; color: rgb(0, 0, 0);">Join this monthly meeting to connect with other Caregivers and learn from Dementia experts to hear the latest care tips, clinical research, and connect with support resources in our community.</span></p><p><br></p><p><strong style="font-size: 16px; color: rgb(0, 0, 0);">Who should attend?</strong></p><p>Anyone with a loved one suffering from Dementia or interested in learning more about how Dementia impacts individuals, families, and caregivers</p><p><br></p><p style="text-align: center;"><br></p><h2><br></h2><p><br></p>','Register','All Websites','All Websites','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','True','Last Name As Student','Last Name','','','','','4127 Okemos Rd, Okemos, MI 48864','https://maps.app.goo.gl/6G6GboVUU3sENzzj6','GLF Office','On-Site','Registrant Address','20.0','Dementia Caregiver Support','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-10-01','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(9,'','','','','','','','','','','','','','','','','','','','','','','','False','','Application Type','Do not ask','Ask','Ask and require','Ask and require','False','Do not ask','Do not ask','Ask mobile and require','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','','Do not ask','','','2.0','','Do you belong to a team or other organization?','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','True','False','True','','','','Email','2023-11-05','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','<p>You will receive an event confirmation shortly (need to set up template). Please look to it for additional details relating to rules and check in procedures. </p>','Thank you for registering for this tournament!','','Event Cost','Event Charges','Total','200.0','Payments Received','','<p>Event is finished, see you next year!</p>','Confirm Wrestlers','Event Home','','Summit Wrestling Tournament 2023','','Payment Due','','Payment Received','Outdoor Open Wrestling at Millennium Park!','','Active','','','Admissions Event','<p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Wrestling-Tournament-Header.png" alt="Screenshot 2023-10-31 135310.png"></img>Outdoor Open Wrestling at Millennium Park!</p>','Register','','','First Name','Gender','15.0','Add Another Wrestler','<p>Add your team below. </p>','Register Additional Wrestlers','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','201 E Randolph St, Chicago, IL 60602','https://maps.app.goo.gl/efKLkmwybwA61tMr8','Millennium Park','On-Site','Registrant Address','15.0','Summit Wrestling Tournament','','Make Payment','No Gateway','Please provide your mobile phone number.','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-11-03','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(10,'','','','None

Vegetarian

Vegan

Gluten-Free

Low Glycemic','','No

Yes, for long distances

Yes, at all times','No

Yes','No

Yes','','','','','','Dietary Restrictions/Preferences','Please list any food allergies:','Will you require mobility aids or accommodations?','Will you require handicapped-accessible lodgings?','Will you require passport/visa assistance (extra fees may apply)?','Pick-list required','Text area','Pick-list required','Pick-list required','Pick-list required','False','','Application Type','Do not ask','Do not ask','Ask and require','Ask and require','False','Do not ask','Ask and require','Ask with type require','Ask','Do not ask','Do not ask','Do not ask','Do not ask','','Do not ask','','','30.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','False','False','False','','','','Email','2024-12-31','Reservation Details','<p><strong style="font-size: 24px;">Demo Notes</strong></p><p><br></p><p><span style="font-size: 16px;">For a real event, this page would be extensively populated with questions about information needed by trip planners. The sample question below errors out because it is not mapped to a corresponding custom field; you would need to map these fields in your instance to make custom questions functional.</span></p><p><br></p><p><span style="font-size: 16px;">As a note on example process, the descriptive text related to the question below might read:</span></p><p class="ql-indent-2"><em style="font-size: 16px;">If you will be traveling with someone who is not included on this registration, please provide their name and we will match up your itineraries. If you are traveling solo, do not include a name and you will be contact separately about your single supplement fee.</em></p><p class="ql-indent-1"><br></p><p><span style="font-size: 16px;">This information would be used by org staff behind the scenes to match the registration records of individuals who will be traveling together but did not register at the same time. In the event that this procedure is used, the registrant should be clearly informed that if two individuals register on the same transaction </span><strong style="font-size: 16px;">and do not specify alternate traveling companions</strong><span style="font-size: 16px;">, the default assumption will be that the two registrants are traveling together. A workflow would also need to be developed/implemented for following up with solo travelers for any associated fees, if this is not otherwise built into the registration process (e.g., via a separate solo ticket type and pricing tier).</span></p><p><br></p><p><span style="font-size: 16px;">Other questions in this section might include passport number and expiration date, questions about pre-/post-trip supplements, excursion options. etc.</span></p>','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','<p>Thank you for registering! You will receive a registration number by email shortly, and a member of our travel concierge team will be in touch to confirm the details of your booking in 2-5 business days. Questions in the meantime? Just reply on your registration email and a customer service agent will get in touch.</p>','You''re going to Japan!','','Event Cost','Event Charges','Total','','Payments Received','<p><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Alumni-Events-Footer.png" alt="Picture of Japan Skyline"></img></p>','','','Event Home','','2024 Alumni Tours','','Payment Due','','Payment Received','','','Active','','','Overnight','<h1><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Alumni-Travel-Home.jpg" alt="Travel On"></img></h1><h1><strong style="font-size: 28px; color: rgb(197, 5, 12);"><em>Cruise to Japan</em></strong></h1><p><span style="font-size: 18px;">Let the harmony of Japanese culture surround you as you immerse yourself in the deeply rooted customs and traditions of this majestic island nation on a 12-night cruise aboard Oceania Cruises’ </span><em style="font-size: 18px;">Riviera</em><span style="font-size: 18px;">.</span></p><p><br></p><p><span style="font-size: 18px;">From the simplest pleasures of a tea ceremony to the excitement of sumo spectating, this voyage offers a unique insight into the Japanese way of life. Begin your journey in metropolitan Tokyo and set sail with views of majestic Mount Fuji to the seaport of Shimizu. Continue to Japan’s old capital of Kyoto for an overnight stay and glimpse the sun glinting off the Golden Pavilion. Take a dip in the city of Beppu, a resort getaway that is home to more than 2,000 hot springs. Sail down the Kanmon Strait and see the flourishing art scene, renowned Buddha statues, and beautiful beaches of Busan, South Korea.</span></p><p><br></p><p><span style="font-size: 18px;">Discover a new side of Japan in the volcanoes and offshore islands of Nagasaki and the picturesque seaside cityscape of Kagoshima on Kyushu Island. Contemplate peace in historic Hiroshima with a stroll through the beautifully landscaped gardens and iconic Hiroshima Castle. Then head to the surfer’s paradise — quaint Kochi — where the blue Pacific waters meet green land. Explore the industrial side of Japan as you take in the newly reconstructed palace and many museums of Nagoya before you conclude your trip back in the bustling city of Tokyo.</span></p><p style="text-align: right;"><a href="https://www.uwalumni.com/travel/request-trip-information/?requested_trip=Denali%20National%20Park" target="_blank" style="font-size: 18px; color: rgb(197, 5, 12); background-color: rgb(255, 255, 255);">Request a Brochure &gt;&gt;</a></p><p style="text-align: right;"><br></p><p style="text-align: right;"><br></p>','Book Now','','','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','','','','On-Site','Registrant Address','','2024 Alumni Tours','','Make Payment','No Gateway','Phone number','Type','Grad Year (UW Alumni)','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-09-01','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(11,'','','','','','','','','','','','','','','','','','','','','','','','True','','Application Type','Ask','Do not ask','Ask','Do not ask','False','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Ask','Do not ask','Do not ask','Parent/Guardian;Other','Do not ask','Prospective Student','Office of Admissions','3.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','Date of Birth','False','False','False','','','','Email','2025-01-01','Additional Details Needed','<p><span style="font-size: 16px;">Please share the information below.  This information is supportive to us making your experience magical!</span></p>','Selected options','<p><span style="font-size: 16px;">You have options to make your day personalized.  Other than the Tour, what else can we accommodate for you?</span></p>','Once you have made your selections click next.','','Other than a Tour','Select your options','<p><span style="font-size: 16px;">We get it.  Sometimes you have to cancel.  We want to welcome you back to visit campus, so </span><a href="https://app-efficiency-8763-dev-ed.scratch.my.salesforce-sites.com/" target="_blank" style="font-size: 16px;">please find another date/time</a><span style="font-size: 16px;"> and we&#39;ll get things scheduled for you again!</span></p>','No!!! We want to see you!','','<p style="text-align: center;"><span style="font-size: 18px;">Thank you and we look forward to seeing you soon!  We&#39;ll ensure that your visit is special to you and your desired experience, which may required us to connect with other departments.  As soon as we&#39;ve confirmed all of your appointments we&#39;ll reach out with a full itinerary!</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/tour-with-coffee.jpg" alt="Photo of women in group with coffee in hand"></img></p>','Registration Received!','','Event Cost','Event Charges','Total','','Payments Received','<p><span style="font-size: 16px;">For more information about Summit Events University, contact us at summitevt@gmail.com or go to our </span><a href="" target="_blank" style="font-size: 16px;">website</a><span style="font-size: 16px;">.</span></p>','','','Event Home','','Higher Ed/K12 Admissions Tours','','Payment Due','','Payment Received','','','Active','<p><span style="font-size: 16px;">Take a quick look and make sure you indicated everything you&#39;d like about your visit.</span></p>','Review your Requests','Admissions Event','<p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Tour-Image.jpg" alt="Tour Image.jpg"></img></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 22px;">Join Us for a Glimpse into Your Future at Summit Events University!</span></p><p style="text-align: center;"><br></p><p><span style="font-size: 16px;">Welcome to Summit Events University&#39;s Admissions Tour registration page. We&#39;re excited to have you join us for an exclusive look at what your journey with us could be like. Please fill out the following details to secure your spot.</span></p><p><br></p><p><span style="font-size: 20px;">Why Choose Summit Events University:</span></p><p><span style="font-size: 16px;">Summit Events University is your gateway to a rewarding career in event management and hospitality. Our innovative programs, expert faculty, and strong industry connections make us the perfect choice for your academic journey.</span></p><p><br></p><p><strong style="font-size: 16px;">What to Expect and Opportunities:</strong></p><ul><li><span style="font-size: 16px;">Campus Tour</span></li><li><span style="font-size: 16px;">Faculty Meet and Greet</span></li><li><span style="font-size: 16px;">Student Showcase</span></li><li><span style="font-size: 16px;">Admissions Information Session</span></li><li><span style="font-size: 16px;">Q&amp;A with Our Team</span></li><li><span style="font-size: 16px;">Networking Opportunities</span></li></ul><p><span style="font-size: 16px;">Don&#39;t miss out on this opportunity to explore your future and kickstart your dream career. Secure your spot for the Admissions Tour now, and get ready to embark on an exciting academic adventure.</span></p><p><br></p><p><span style="font-size: 16px;">By submitting this registration, you&#39;re taking your first step toward a future filled with endless possibilities. We can&#39;t wait to welcome you to Summit Events University.</span></p>','Register','All Websites','All Websites','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','415 Mission St, San Francisco, CA 94105','https://maps.app.goo.gl/QrHyvdSYkcEQ8fHD8','Summit Events University','On-Site','Registrant Address','4.0','Higher Ed/K12 Admissions Tours','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','One registration per instance','Relationship (select all that apply)','2023-01-01','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES(12,'','','','1 - 20 employees

21 - 200 employees

201 - 10,000 employees

10,001+ employees','Nonproft Customer

Education Customer

Other Customer

Consulting Partner (SI)

App Partner (ISV)

Community Training Program

Unemployed

Salesforce Employee','Yes, I have been more than 2 times - can''t wait!

Yes, this is my second time joining a Sprint!

No, I''m a first time Sprinter!','','','','','','','','Number of Employees','How do you categorize your organization?','Have you attended a community sprint before?','','','Pick-list required','Pick-list required','Pick-list required','','','False','','Application Type','Do not ask','Ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Ask mobile and require','Do not ask','Do not ask','Ask','Do not ask','Do not ask','','Ask','','','0.0','','Company or Organization','Standard Contact Duplicate Rule','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','Use Salesforce Duplicate Rule','Admissions','','Date of Birth','False','False','True','','','','Email','2024-10-01','Additional Questions','<p><span style="font-size: 16px;">We&#39;re excited that you&#39;ve chosen to join us for the Commons Open Source Sprint! To ensure we can tailor your experience and provide you with all the necessary details, we kindly ask for a bit more information. Please take a moment to complete the following questions so we can make your experience meaningful!</span></p><p><br></p><p><br></p><p><span style="font-size: 16px;"><span class="ql-cursor">﻿</span></span></p>','Selected options','<p><span style="font-size: 16px;">Kindly confirm the availability for the specified date and time, as well as any additional information or requirements we need to be aware of for a successful reservation.</span></p><p><br></p><p><span style="font-size: 16px;">Details:</span></p><p><span style="font-size: 16px;">Chicago Restaurant</span></p><p><span style="font-size: 16px;">123 Food St.</span></p><p><span style="font-size: 16px;">Chicago, IL 60646</span></p><p><br></p><p><span style="font-size: 16px;">Drinks and Food on us!</span></p>','Once you have made your selections click next.','','Joining us for Dinner?','Choose your options','<p><span style="font-size: 16px;">We&#39;re saddened to hear about your cancellation for the upcoming sprint. We were really looking forward to having you with us, and your absence will be felt. If you ever decide to join us in the future, we&#39;d be thrilled to welcome you back. If you have any questions, feel free to reach out to us at commons@sprint.demo. </span></p><p><br></p><p><span style="font-size: 16px;"><span class="ql-cursor">﻿</span>Take care, and best wishes.</span></p>','Please don''t go!!!','','<p style="text-align: center;"><span style="font-size: 16px;">We&#39;re absolutely thrilled to have you join us for the Commons Open-Source Sprint! Your registration has been successfully confirmed, and we can&#39;t wait to see you in person or virtually, depending on your chosen attendance option.</span></p><p><br></p><p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Nov_2022_Community_Sprint.png" alt="Nov 2022 Community Sprint"></img></p><p><br></p><p><span style="font-size: 16px;">Get ready for an unforgettable experience filled with inspiration, knowledge, and networking opportunities. The Common Open Source Sprint is all about bringing like-minded individuals together, and we&#39;re excited to have you be a part of our community. Whether you&#39;re coming from near or far, or joining us from a different time zone, your presence will make this event even more special.</span></p><p><br></p><p><span style="font-size: 16px;">Stay tuned for further updates and details about the event, including the schedule, speakers, and any materials you might need. In the meantime, if you have any questions or specific requirements, please don&#39;t hesitate to reach out to our dedicated support team.</span></p><p><br></p><p><br></p><p><span style="font-size: 16px;">Hotel Recommendations close to the Salesforce Tower:</span></p><p><a href="https://www.salesforce.org/resources/commons/" target="_blank" style="font-size: 16px;">Holiday Inn</a></p><p><span style="font-size: 16px;">W. Wolf Point Plaza</span></p><p><span style="font-size: 16px;">(312) 555-1234</span></p><p><br></p><p><a href="https://www.salesforce.org/resources/commons/" target="_blank" style="font-size: 16px;">Hyatt Place</a></p><p><span style="font-size: 16px;">N. Palace Rd.</span></p><p><span style="font-size: 16px;">(312) 555-4321</span></p><p><br></p><p><br></p><p><span style="font-size: 16px;">Once again, thank you for registering, and get ready to be inspired, learn, and connect. We can&#39;t wait to welcome you to [Event Name] and share this incredible experience with you!</span></p><p><br></p><p><span style="font-size: 16px;">See you soon!</span></p>','Thank you for registering!','','Event Cost','Event Charges','Total','','Payments Received','<p><span style="font-size: 18px;">For additional Questions please reach out to us in </span><a href="https://trailhead.salesforce.com/trailblazer-community/groups/0F94S000000GwVK?tab=discussion&amp;sort=LAST_MODIFIED_DATE_DESC#discussion?icid=SFORG:resource-page-hero:" target="_blank" style="font-size: 18px;">the community</a><span style="font-size: 18px;"> or check out our </span><a href="https://sfdo-community-sprints.github.io/docs/sprints/" target="_blank" style="font-size: 18px;">GitHub Pages</a><span style="font-size: 18px;">.</span></p><p><br></p><p><br></p><p><span style="font-size: 16px;">&copy; Copyright 2023 Salesforce.com, inc. </span><a href="https://www.salesforce.com/company/legal/intellectual/?_gl=1*hrczfo*_ga*MTA1NDY0ODM3LjE2OTgxNjkzOTg.*_ga_J1M7TM7DGX*MTY5ODc2MzgxMC4xLjAuMTY5ODc2MzgxMC4wLjAuMA.." target="_blank" style="font-size: 16px;">All rights reserved</a><span style="font-size: 16px;">. Various trademarks held by their respective owners. Salesforce.com, inc. Salesforce Tower, 415 Mission Street, 3rd Floor, San Francisco, CA 94105, United States</span></p>','','','Event Home','','Open Source Sprint','','Payment Due','','Payment Received','','','Active','','Please confirm your details below','Engagement','<p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 48px;">Nonprofit &amp; Education Community Sprint</span></p><p><br></p><p style="text-align: center;"><span style="color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Open-Source-Commons.png" alt="Open Source Commons.png"></img></span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><strong style="font-size: 36px; color: rgb(0, 0, 0);">Activating community to supercharge impact</strong></p><p style="text-align: center;"><br></p><p><br></p><p><strong style="font-size: 18px; color: rgb(0, 0, 0);">What is a Sprint?</strong><span style="font-size: 18px; color: rgb(0, 0, 0);"> </span></p><p><span style="font-size: 16px;">The Sprint is a hack-a-thon type event, where you will contribute your skills in small breakout groups and work with others, to discuss different Salesforce technology challenges.</span></p><p><span style="font-size: 16px;"> </span></p><p><span style="font-size: 16px;">Connect and collaborate with your peers to build solutions to common challenges prioritized by you and the community. </span></p><p><span style="font-size: 16px;"> </span></p><p><strong style="font-size: 18px;">Who should attend?</strong><span style="font-size: 18px;"> </span></p><p><span style="font-size: 16px;">Register if you&#39;re an Admin, Developer, Consultant, or End-User in the Nonprofit or Education Salesforce community.</span></p><p><span style="font-size: 16px;"> </span></p><p><span style="font-size: 16px;">The Sprint is a </span><strong style="font-size: 16px;">free </strong><span style="font-size: 16px;">event, and all are welcome. For more details, check out the event FAQs.</span></p><p><br></p><p style="text-align: center;"><span style="font-size: 16px;"> </span><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Open-Source-Image-Options.png" alt="Open Source Commons Project Logos - DLRS, Grassroots Mobile Survey, Summit Events App"></img></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;">﻿</p>','Register','','','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','True','Last Name As Student','Last Name','','','','','333 W Wolf Point','https://maps.app.goo.gl/wcvs7AduZ3oiu1k2A','Chicago Salesforce Tower','On-Site','Registrant Address','','Open Source Sprint','','Make Payment','No Gateway','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2023-10-01','GeneralSLDS','I am...','Title','','','','','','','','','','','','','');
COMMIT;
