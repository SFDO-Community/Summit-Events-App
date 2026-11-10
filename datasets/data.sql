BEGIN TRANSACTION;
CREATE TABLE "Account" (
	id VARCHAR(255) NOT NULL, 
	"Created_with_Summit_Events__pc" VARCHAR(255), 
	"FirstName" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"RecordTypeId" VARCHAR(255), 
	"IsPersonAccount" VARCHAR(255), 
	"ParentId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Account" VALUES('Account-1','False','','','Sample Account for Entitlements','','False','');
CREATE TABLE "Account_rt_mapping" (
	record_type_id VARCHAR(18) NOT NULL, 
	developer_name VARCHAR(255), 
	is_person_type BOOLEAN, 
	PRIMARY KEY (record_type_id)
);
INSERT INTO "Account_rt_mapping" VALUES('012di000001BpQ1AAK','Business_Account',0);
INSERT INTO "Account_rt_mapping" VALUES('012di000001BpQ2AAK','PersonAccount',1);
CREATE TABLE "Contact" (
	id VARCHAR(255) NOT NULL, 
	"Created_with_Summit_Events__c" VARCHAR(255), 
	"DoNotCall" VARCHAR(255), 
	"FirstName" VARCHAR(255), 
	"HasOptedOutOfEmail" VARCHAR(255), 
	"HasOptedOutOfFax" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"IsPersonAccount" VARCHAR(255), 
	"AccountId" VARCHAR(255), 
	"ReportsToId" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Lead" (
	id VARCHAR(255) NOT NULL, 
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
	id VARCHAR(255) NOT NULL, 
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
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-1','Attend A Class','','','1','Active','','','False','','','','','','','<p>See what a classroom experience is like.  You don&#39;t have to participate, but why not show your future peers was you&#39;re all about.</p>','False','','False','99.0','Attend a Class','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-2','Faculty Visit','','','2','Active','','','False','','','','','','','<p>Spend time with a Faculty Member and learn about their program.</p>','False','','False','30.0','Meet with Faculty','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-3','','','','1','Active','','10:00:00.000Z','True','Office of Admissions','Added and Required','','','','','<p>Campus Tour</p>','False','','False','10.0','Campus Tour','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-4','','','','1','Active','','09:45:00.000Z','True','Office of Admissions','Added but not shown','','','','','<p>Check-In at Admissions</p>','False','','False','20.0','Check-In','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-5','','','','1','Active','','','False','','','','','','','<p>Enjoy lunch in the main cafeteria and get the full experience of visiting campus!</p>','False','','False','40.0','Lunch (on us!)','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-6','','','','1','Active','','','True','','','S

M

L

XL

XXL

XXXL

Save the S.W.A.G for someone else.','','','','<p><span style="font-size: 16px;">Get some Sprinty S.W.A.G!  Let us know what size you&#39;d like and we&#39;ll come with it for a Sprint Pic!</span></p><p><br></p><p><span style="font-size: 16px;">All sizes are Uni-Sex Adult.</span></p>','False','Required custom pick list','False','20.0','Swag Item','','','','Summit_Events__c-3');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-7','','','','1','Active','','13:30:00.000Z','True','','','Master of Science in Data Science and Analytics

Master of Business Administration (MBA) in Technology Management

Doctor of Psychology (Psy.D.) in Clinical Neuropsychology

Master of Fine Arts (MFA) in Creative Writing

Master of Public Health (MPH) in Global Health Policy

Master of Engineering (M.Eng) in Sustainable Energy Systems

Master of Arts (MA) in International Relations

Doctor of Education (Ed.D.) in Educational Technology Leadership','','','','<p>Choose a program of interest and we will have a professor talk to you!</p>','False','Required custom pick list','False','15.0','Program of Interest','','','','Summit_Events__c-4');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-8','','','','1','Active','','12:00:00.000Z','True','','','','','','','<p><span style="font-size: 14px;">Coming in early and join us for lunch at noon and talk with current students, faculty and staff.</span></p>','False','','False','5.0','Lunch','','','','Summit_Events__c-4');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-9','','','','1','Active','','14:30:00.000Z','True','Office of Admissions','','','','','','<p>Campus Tour post Open House Sessions.</p>','False','','False','30.0','Campus Tour (Optional)','','','','Summit_Events__c-4');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-10','','','','1','Active','','13:00:00.000Z','True','','Added and Required','','','','','<p>Welcome &amp; Introduction to Connected University!</p>','False','','False','10.0','Welcome & Intro','','','','Summit_Events__c-4');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-11','','','','1','Active','','14:00:00.000Z','True','','Added and Required','','','','','<p>Understanding how individuals can afford a graduate degree!</p>','False','','False','20.0','Financing a Graduate Degree','','','','Summit_Events__c-4');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-12','','','','1','Active','','14:15:00.000Z','True','','Added and Required','','','','','<p>Open Questions &amp; Answers</p>','False','','False','25.0','Open Questions & Answers','','','','Summit_Events__c-4');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-13','','','','1','Active','','','False','','','','','','','<ul><li><span style="font-size: 14px;">Prominent logo placement and recognition in event materials and pre-event marketing w/full page in program</span></li><li><span style="font-size: 14px;">16 tickets (2 tables) with preferred seating</span></li><li><span style="font-size: 14px;">Table sign and emcee announcements</span></li><li><span style="font-size: 14px;">Logo on TCOA website and social media</span></li><li><span style="font-size: 14px;">Listed in TCOA’s Annual Report</span></li></ul>','False','','False','10.0','EVENT SPONSOR - $10,000','','','','Summit_Events__c-8');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-14','','','','1','Active','','','False','','','','','','','<ul><li>Corporate table including 8 dinner tickets</li><li>Table sign and emcee announcements</li><li>Logo in event program</li><li>Listed in TCOA’s Annual Report</li></ul>','False','','False','60.0','TABLE SPONSOR - $1,000','','','','Summit_Events__c-8');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-15','','','','1','Active','','','False','','','','','','','<ul><li>Company logo in auction program &amp; materials</li><li>8 tickets (1 table) with preferred seating</li><li>Table sign and emcee announcements</li><li>Logo in event program</li><li>Logo on TCOA website and social media</li><li>Listed in TCOA’s Annual Report</li></ul>','False','','False','40.0','AUCTION SPONSOR - $2,000','','','','Summit_Events__c-8');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-16','','','','1','Active','','','False','','','','','','','<ul><li>Company logo at stage area 8 tickets (1 table) with preferred seating</li><li>Table sign and emcee announcements</li><li>Logo in event program</li><li>Logo on TCOA website and social media</li><li>Listed in TCOA’s Annual Report</li></ul>','False','','False','30.0','ENTERTAINMENT SPONSOR - $2,000','','','','Summit_Events__c-8');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-17','','','','1','Active','','','False','','','','','','','<ul><li>8 tickets (1 table) with preferred seating</li><li>Table sign and emcee announcements</li><li>Logo in event program</li><li>Logo on TCOA website</li><li>Listed in TCOA’s Annual Report</li></ul>','False','','False','50.0','MENU SPONSOR - $1,500','','','','Summit_Events__c-8');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-18','','','','1','Active','','','False','','','','','','','<ul><li>Corporate half table including 4 dinner tickets</li><li>Shared table sign and in emcee announcements</li><li>Recognition in event program</li><li>Listed in TCOA’s Annual Report</li></ul>','False','','False','70.0','CO-TABLE SPONSOR - $500','','','','Summit_Events__c-8');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-19','','','','1','Active','','','False','','','','','','','<ul><li>Prominent logo placement and recognition in event materials </li><li>8 tickets (1 table) with preferred seating</li><li>Table sign and emcee announcements</li><li>Logo on TCOA website and social media</li><li>Listed in TCOA’s Annual Report</li></ul>','False','','False','20.0','PRESENTING SPONSOR - $5,000','','','','Summit_Events__c-8');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-20','','','','1','Active','','','False','','','','','','','<ul><li><span style="font-size: 16px;">Logo placement on the official event scorecard.</span></li><li><span style="font-size: 16px;">Recognition in event programs.</span></li><li><span style="font-size: 16px;">Opportunity to provide branded items with the scorecards</span></li></ul><p><br></p>','False','','False','40.0','Scorecard Sponsor - $500','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-21','','','','1','Active','','12:00:00.000Z','True','','Added but not shown','','','','','','False','','False','85.0','Lunch Break','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-22','','','','1','Active','','','False','','','','','','','<ul><li><span style="font-size: 16px;">Recognition as the sponsor of the pre-event lunch or post-event dinner.</span></li><li><span style="font-size: 16px;">Logo placement during the meal and in event materials.</span></li><li><span style="font-size: 16px;">Opportunity to address participants during the meal.</span></li></ul><p><br></p>','False','','False','15.0','Lunch/Dinner Sponsor - $5,000','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-23','','','','1','Active','','','False','','','','','','','<ul><li><span style="font-size: 16px;">Sponsorship of specific golf contests (e.g., longest drive, closest to the pin).</span></li><li><span style="font-size: 16px;">Recognition during award ceremonies.</span></li><li><span style="font-size: 16px;">Logo placement on contest-related materials.</span></li></ul><p><br></p>','False','','False','25.0','Prize or Contest Sponsor - $750','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-24','','','','1','Active','','','False','','','','','','','<ul><li><span style="font-size: 16px;">Logo placement on golf balls or tees provided to participants.</span></li><li><span style="font-size: 16px;">Recognition in event materials.</span></li><li><span style="font-size: 16px;">Opportunity to distribute branded golf accessories.</span></li></ul><p><br></p>','False','','False','17.0','Golf Ball or Tee Sponsor - $5,000','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-25','','','','1','Active','','09:30:00.000Z','True','','Added but not shown','','','','','','False','','False','80.0','Shotgun Start','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-26','','','','1','Active','','16:00:00.000Z','True','','Added but not shown','','','','','','False','','False','90.0','Happy Hour Social & Silent Auction','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-27','','','','1','Active','','09:00:00.000Z','True','','Added but not shown','','','','','','False','','False','75.0','Welcome & Briefing','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-28','','','','1','Active','','','False','','','','','','','<ul><li><span style="font-size: 16px;">Logo placement on beverage carts that circulate throughout the course.</span></li><li><span style="font-size: 16px;">Recognition in event programs and promotional materials.</span></li><li><span style="font-size: 16px;">Option to provide branded items to be distributed from the cart.</span></li></ul><p><br></p>','False','','False','30.0','Beverage Cart Sponsor - $500','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-29','','','','1','Active','','08:00:00.000Z','True','','Added but not shown','','','','','','False','','False','70.0','Registration','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-30','','','','1','Active','','','False','','','','','','','<ul><li><span style="font-size: 16px;">Exclusive naming rights for the event (e.g., &quot;Presented by [Title Sponsor]&quot;).</span></li><li><span style="font-size: 16px;">Prominent logo placement on all event materials, including banners, promotional materials, and the event website.</span></li><li><span style="font-size: 16px;">Recognition during opening and closing ceremonies.</span></li></ul><p><br></p>','False','','False','10.0','Title Sponsor - $10,000','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-31','','','','5','Active','','','False','','','','','','','<ul><li><span style="font-size: 16px;">Logo and signage at a specific golf hole.</span></li><li><span style="font-size: 16px;">Opportunity to set up a booth or tent at the sponsored hole.</span></li><li><span style="font-size: 16px;">Verbal recognition during the event.</span></li></ul><p><br></p>','False','','False','20.0','Hole Sponsorship - $1,000','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-32','','','','1','Active','','17:00:00.000Z','True','','Added but not shown','','','','','','False','','False','95.0','Award Ceremony & Dinner','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Appointment_Type__c" VALUES('Summit_Events_Appointment_Type__c-33','','','','1','Active','','17:00:00.000Z','True','','','','','','','<p><span style="font-size: 16px;">Kindly confirm the availability for the specified date and time, as well as any additional information or requirements we need to be aware of for a successful reservation.</span></p><p><br></p><p><span style="font-size: 16px;">Details:</span></p><p><span style="font-size: 16px;">Chicago Restaurant</span></p><p><span style="font-size: 16px;">123 Food St.</span></p><p><span style="font-size: 16px;">Chicago, IL 60646</span></p><p><br></p><p><span style="font-size: 16px;">Drinks and Food on us!</span></p>','False','Text box','False','10.0','Day 1 Dinner','','','Summit_Events_Instance__c-20','Summit_Events__c-3');
CREATE TABLE "Summit_Events_Appointments__c" (
	id VARCHAR(255) NOT NULL, 
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
	id VARCHAR(255) NOT NULL, 
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
INSERT INTO "Summit_Events_Email__c" VALUES('Summit_Events_Email__c-1','Registered','','','THIS IS TEXT','<p><span style="font-size: 14px;">Dear {!Registrant_First_Name__c},</span></p><p><br></p><p><span style="font-size: 14px;">Thank you for registering for the ArcticGrapple Games, the ultimate wrestling experience! We are thrilled to have you on board for this exciting event.</span></p><p><br></p><p><strong style="font-size: 14px;">Event Details:</strong></p><ul><li><span style="font-size: 14px;">Date: {!Event_Instance_Date_Time_Formatted__c}</span></li><li><span style="font-size: 14px;">Time: {!Event_Instance_Start_Time__c}</span></li><li><span style="font-size: 14px;">Location: {!Location_Title__c}</span></li><li><span style="font-size: 14px;">Registration ID: {!Name}</span></li></ul><p><br></p><p><strong style="font-size: 14px;">Important Information:</strong></p><p><span style="font-size: 14px;">Please keep this email for your records as it serves as confirmation of your successful registration. Closer to the event date, you will receive a comprehensive email containing additional details such as rules, check-in procedures, and any other pertinent information to ensure a smooth and enjoyable experience.</span></p><p><br></p><p><strong style="font-size: 14px;">Next Steps:</strong></p><ul><li><strong style="font-size: 14px;">Payment Confirmation</strong><span style="font-size: 14px;">: Your payment of </span><strong style="font-size: 14px;">$200</strong><span style="font-size: 14px;"> has been successfully processed.</span></li><li><strong style="font-size: 14px;">Athlete Information</strong><span style="font-size: 14px;">: If you have registered athletes, please be ready to provide their details on the check-in page.</span></li><li><strong style="font-size: 14px;">Stay Connected</strong><span style="font-size: 14px;">: Follow us on [Social Media Links] for event updates, behind-the-scenes content, and more.</span></li></ul><p><span style="font-size: 14px;">We&#39;re looking forward to hosting you at the ArcticGrapple Games! If you have any questions or concerns in the meantime, feel free to reach out to our event organizers at </span></p><p><span style="font-size: 14px;">[Organizer&#39;s Email] or [Organizer&#39;s Phone Number].</span></p><p><br></p><p><span style="font-size: 14px;">Best Regards,</span></p><p><span style="font-size: 14px;">[Your Organization Name]</span></p><p><span style="font-size: 14px;">ArcticGrapple Games Organizing Team</span></p>','','Thank you for registering for the ArticGrapple Games','','','','','','','Summit_Events__c-7');
INSERT INTO "Summit_Events_Email__c" VALUES('Summit_Events_Email__c-2','Registered','','','THIS IS TEXT','<p><span style="font-size: 16px;">Dear {!Registrant_First_Name__c},</span></p><p><br></p><p><span style="font-size: 16px;">We are thrilled to confirm your registration for the upcoming taking place on {!Event_Instance_Start_Date__c} at the </span><span style="font-size: 16px; color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);">{!</span><span style="font-size: 16px;">Location_Title__c</span><span style="font-size: 16px; color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);">}</span><span style="font-size: 16px;">. Thank you for choosing to be a part of this exciting event!</span></p><p><br></p><p><strong style="font-size: 16px;">Registration Details:</strong></p><p><span style="font-size: 16px;">Event Name: {!Event_Name__c}</span></p><p><span style="font-size: 16px;">Event Date: {!Event_Instance_Start_Date__c}</span></p><p><span style="font-size: 16px;">Event Location: </span><span style="font-size: 16px; color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);">{!Location_Title__c}</span></p><p><span style="font-size: 16px;">Registration ID: </span><span style="font-size: 16px; color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);">{!Name}</span></p><p><br></p><p><br></p><p><span style="font-size: 16px;">We have received your registration information and you are all set to join us. We can&#39;t wait to see you at the event. Here are a few important details to keep in mind:</span></p><p><br></p><p><span style="font-size: 16px;">Event Date: </span><span style="font-size: 16px; background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);">{!Event_Instance_Start_Date__c}</span></p><p><span style="font-size: 16px;">Event Time: </span><span style="font-size: 16px; background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);">{!Event_Instance_Start_Time__c}</span></p><p><span style="font-size: 16px;">Location: </span><span style="font-size: 16px; background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);">{!Location_Title__c}</span></p><p><span style="font-size: 16px;">Registration ID: </span><span style="font-size: 16px; background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);">{!Name}</span></p><p><br></p><p><span style="font-size: 16px;">Please arrive a little early to ensure a smooth check-in process. If you have any questions or need further assistance, don&#39;t hesitate to contact our event support team.</span></p><p><br></p><p><span style="font-size: 16px;">We have an exciting agenda planned with amazing speakers and valuable content. Get ready for an enriching experience!</span></p><p><br></p><p><span style="font-size: 16px;">Thank you for choosing to be a part of this event. We look forward to meeting you and hope you have a fantastic time.</span></p><p><br></p><p><span style="font-size: 16px;">Warm regards,</span></p><p><span style="font-size: 16px;">The Common Team!</span></p>','','Thank you for Registering! - Commons Open Source Sprint','','','','','','','Summit_Events__c-3');
INSERT INTO "Summit_Events_Email__c" VALUES('Summit_Events_Email__c-3','Registered','','','THIS IS TEXT','<p><span style="font-size: 16px;">Dear {!Registrant_First_Name__c},</span></p><p><br></p><p><span style="font-size: 16px;">Thank you for registering for the Connected University Graduate Programs Open House on </span><span style="font-size: 16px; background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);">{!Event_Instance_Start_Date__c}</span><span style="font-size: 16px;">! We&#39;re delighted that you&#39;ll be joining us for this exciting exploration of our diverse and innovative graduate programs.</span></p><p><br></p><p><strong style="font-size: 16px;">Registration Details:</strong></p><p><span style="font-size: 16px;">Event Date: </span><span style="font-size: 16px; color: rgb(68, 68, 68);">{!Event_Instance_Date_Time_Formatted__c}</span></p><p><span style="font-size: 16px;">Event Location: </span><span style="font-size: 16px; background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);">{!Location_Title__c}</span></p><p><span style="font-size: 16px;">Registration ID: </span><span style="font-size: 16px; background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);">{!Name}</span></p><p><br></p><p><strong style="font-size: 16px;">Itinerary</strong></p><p><span style="font-size: 16px;">{!Generated_Itinerary__c}</span></p><p><br></p><p><br></p><p><strong style="font-size: 16px;">Spread the Word:</strong></p><p><span style="font-size: 16px;">Invite your friends and colleagues who may also be interested in exploring graduate opportunities at Connected University. The more, the merrier!</span></p><p><br></p><p><span style="font-size: 16px;">Thank you once again for registering. We can&#39;t wait to welcome you to the Connected University Graduate Programs Open House and showcase the possibilities that await you.</span></p><p><br></p><p><span style="font-size: 16px;">Best regards,</span></p><p><span style="font-size: 16px;">[Your Organization&#39;s Name]</span></p><p><span style="font-size: 16px;">[Your Organization&#39;s Contact Information]</span></p>','','Thank you for Registering! - Open House Connected University','','','','','','','Summit_Events__c-4');
INSERT INTO "Summit_Events_Email__c" VALUES('Summit_Events_Email__c-4','Registered','','','THIS IS TEXT','<p style="text-align: center;"><strong style="font-size: 16px;">Add to Calendar</strong></p><p style="text-align: center;"><span style="font-size: 16px;">{!Add_To_Google_Calendar_Link__c} | {!Add_To_Outlook_Web_Calendar__c}</span></p><p><br></p><p><br></p><p><span style="font-size: 16px;">Dear {!Registrant_First_Name__c},</span></p><p><br></p><p><span style="font-size: 16px;">Thank you for registering for the 2024 AR Fundraising Golf Event. We are excited to have you on board! Your support will directly contribute to the AR scholarship fund, making a positive impact.</span></p><p><br></p><p><strong style="font-size: 16px;">Event Details:</strong></p><ul><li><span style="font-size: 16px;">Date: </span><span style="font-size: 16px; color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);">{!Event_Instance_Date_Time_Formatted__c}</span></li><li><span style="font-size: 16px;">Location: </span><span style="font-size: 16px; color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);">{!Location_Title__c}</span></li></ul><p><strong style="font-size: 16px;">Registration Information:</strong></p><ul><li><span style="font-size: 16px;">Full Name: {!Registrant_First_Name__c} {!Registrant_Last_Name__c}</span></li><li><span style="font-size: 16px;">Email Address: {Registrant_Email__c}</span></li></ul><p><strong style="font-size: 16px;">Golf Event Details:</strong></p><ul><li><span style="font-size: 16px;">Handicap: {!Add_Info_Answer_1__c}</span></li><li><span style="font-size: 16px;">Shirt Size: {!Add_Info_Answer_2__c}</span></li></ul><p><strong style="font-size: 16px;">Itinerary:</strong></p><p><span style="font-size: 16px;">{!Generated_Itinerary__c}</span></p><p><br></p><p><span style="font-size: 16px;">Please retain this email for your records. If you have any questions or need assistance, feel free to reach out to us at [Your Contact Email/Phone].</span></p><p><br></p><p><span style="font-size: 16px;">Thank you once again for your support!</span></p><p><br></p><p><span style="font-size: 16px;">Best Regards,</span></p><p><span style="font-size: 16px;">[Your Organization Name]</span></p>','','Confirmation of Your Registration for the 2024 AR Fundraising Golf Event','','','','','','','Summit_Events__c-9');
CREATE TABLE "Summit_Events_Fee_Allocation__c" (
	id VARCHAR(255) NOT NULL, 
	"Name" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES('Summit_Events_Fee_Allocation__c-1','Event Operations');
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES('Summit_Events_Fee_Allocation__c-2','Event Operations');
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES('Summit_Events_Fee_Allocation__c-3','Annual Golf Operations');
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES('Summit_Events_Fee_Allocation__c-4','Gala General Donations');
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES('Summit_Events_Fee_Allocation__c-5','General Fund');
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES('Summit_Events_Fee_Allocation__c-6','Gala Ticket Sales');
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES('Summit_Events_Fee_Allocation__c-7','Meals on Wheels');
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES('Summit_Events_Fee_Allocation__c-8','Organization Operations & Technology');
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES('Summit_Events_Fee_Allocation__c-9','Tournament Operations');
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES('Summit_Events_Fee_Allocation__c-10','General Donation Fund');
INSERT INTO "Summit_Events_Fee_Allocation__c" VALUES('Summit_Events_Fee_Allocation__c-11','AR Scholarship Fund');
CREATE TABLE "Summit_Events_Fee__c" (
	id VARCHAR(255) NOT NULL, 
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
	id VARCHAR(255) NOT NULL, 
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
	is_person_type BOOLEAN, 
	PRIMARY KEY (record_type_id)
);
CREATE TABLE "Summit_Events_Instance__c" (
	id VARCHAR(255) NOT NULL, 
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
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-1','Active','','False','','Registrants plus Guests','300.0','','','','','2025-11-24','20:00:00.000Z','2-day Wrestling Event','2025-11-23','07:00:00.000Z','Central Daylight Time (America/Chicago)','ArcticGrapple Games','','','','','False','','','','','Summit_Events__c-7');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-2','Active','','False','','Registrants plus Guests','20.0','','','','','2025-12-17','20:30:00.000Z','December 2023 Caregiver Support','2025-12-17','19:00:00.000Z','Eastern Standard Time (America/Panama)','December 2023 Caregiver Support','','','','','False','','','','','Summit_Events__c-6');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-3','Active','','False','','Registrants plus Guests','20.0','','','','','2026-03-18','20:30:00.000Z','March 2024 Caregiver Support','2026-03-18','19:00:00.000Z','Eastern Standard Time (America/Panama)','March 2024 Caregiver Support','','','','','False','','','','','Summit_Events__c-6');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-4','Active','','False','','Registrants plus Guests','20.0','','','','','2026-02-18','20:30:00.000Z','February 2024 Caregiver Support','2026-02-18','19:00:00.000Z','Eastern Standard Time (America/Panama)','February 2024 Caregiver Support','','','','','False','','','','','Summit_Events__c-6');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-5','Active','','False','','Registrants plus Guests','20.0','','','','','2026-01-21','20:30:00.000Z','December 2024 Caregiver Support','2026-01-21','19:00:00.000Z','Eastern Standard Time (America/Panama)','January 2024 Caregiver Support','','','','','False','','','','','Summit_Events__c-6');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-6','Active','','False','','Registrants plus Guests','20.0','','','','','2026-05-20','20:30:00.000Z','May 2024 Caregiver Support','2026-05-20','19:00:00.000Z','Eastern Standard Time (America/Panama)','May 2024 Caregiver Support','','','','','False','','','','','Summit_Events__c-6');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-7','Active','','False','','Registrants plus Guests','20.0','','','','','2026-04-22','20:30:00.000Z','April 2024 Caregiver Support','2026-04-22','19:00:00.000Z','Eastern Standard Time (America/Panama)','April 2024 Caregiver Support','','','','','False','','','','','Summit_Events__c-6');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-8','Active','','False','','Individual Registrants','40.0','','','','','2026-06-24','23:59:00.000Z','Operated by Orbridge Travel','2026-06-19','00:00:00.000Z','Central Daylight Time (America/Chicago)','Cruise to Japan','','','','','False','','','','','Summit_Events__c-1');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-9','Active','','False','','Registrants plus Guests','25.0','','','','','2025-11-18','16:00:00.000Z','Tour @ 2pm','2025-11-18','12:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Afternoon','','','','','False','','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-10','Active','','False','','Registrants plus Guests','25.0','','','','','2025-11-16','12:00:00.000Z','Tour @ 10am','2025-11-16','08:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Morning','','','','','False','','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-11','Active','','False','','Registrants plus Guests','25.0','','','','','2025-11-15','12:00:00.000Z','Tour @ 10am','2025-11-15','08:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Morning','','','','','False','','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-12','Active','','False','','Registrants plus Guests','25.0','','','','','2025-11-19','16:00:00.000Z','Tour @ 2pm','2025-11-19','12:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Afternoon','','','','','False','','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-13','Active','','False','','Registrants plus Guests','25.0','','','','','2025-12-19','12:00:00.000Z','Tour @ 10am','2025-12-19','08:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Morning','','','','','False','','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-14','Active','','False','','Registrants plus Guests','25.0','','','','','2025-11-17','12:00:00.000Z','Tour @ 10am','2025-11-17','08:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Morning','','','','','False','','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-15','Active','','False','','Registrants plus Guests','25.0','','','','','2025-11-15','16:00:00.000Z','Tour @ 2pm','2025-11-15','12:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Afternoon','','','','','False','','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-16','Active','','False','','Registrants plus Guests','25.0','','','','','2025-11-16','16:00:00.000Z','Tour @ 2pm','2025-11-16','12:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Afternoon','','','','','False','','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-17','Active','','False','','Registrants plus Guests','25.0','','','','','2025-11-17','16:00:00.000Z','Tour @ 2pm','2025-11-17','12:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Afternoon','','','','','False','','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-18','Active','','False','','Registrants plus Guests','25.0','','','','','2025-11-18','12:00:00.000Z','Tour @ 10am','2025-11-18','08:00:00.000Z','Central Daylight Time (America/Chicago)','Campus Tour - Morning','','','','','False','','','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-19','Active','','False','','Registrants plus Guests','150.0','','','','','2025-12-01','17:00:00.000Z','Can''t be there in-person, we have an option for you!','2025-11-30','08:30:00.000Z','Central Daylight Time (America/Chicago)','Virtual','Sent via Email closer to date','https://trailhead.salesforce.com/trailblazer-community/groups/0F94S000000GwVK?tab=discussion&sort=LAST_MODIFIED_DATE_DESC#discussion?icid=SFORG:resource-page-hero:','Virtual/Zoom','Online','False','','https://www.meetinglink.demo','','','Summit_Events__c-3');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-20','Active','','False','','Registrants plus Guests','150.0','','','','','2025-11-30','17:00:00.000Z','Come join us in person!','2025-11-30','08:30:00.000Z','Central Daylight Time (America/Chicago)','In-Person','','','New York Salesforce Tower','On-Site','False','','','','','Summit_Events__c-3');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-21','Active','','False','','Registrants plus Guests','25.0','','','','','2025-11-16','14:30:00.000Z','','2025-11-16','13:00:00.000Z','Central Daylight Time (America/Chicago)','First Date','','','','','False','','','','','Summit_Events__c-4');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-22','Active','','False','','Registrants plus Guests','25.0','','','','','2025-11-30','14:30:00.000Z','','2025-11-30','13:00:00.000Z','Central Daylight Time (America/Chicago)','Third Date','','','','','False','','','','','Summit_Events__c-4');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-23','Active','','False','','Registrants plus Guests','25.0','','','','','2025-11-23','14:30:00.000Z','','2025-11-23','13:00:00.000Z','Central Daylight Time (America/Chicago)','Second Date','','','','','False','','','','','Summit_Events__c-4');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-24','Active','','False','','Registrants plus Guests','900.0','','','','','2026-03-11','23:00:00.000Z','','2026-03-11','19:00:00.000Z','Central Daylight Time (America/Chicago)','A Night of Giving Hope 2024','','','','','False','','','','','Summit_Events__c-10');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-25','Active','','False','','Registrants plus Guests','150.0','','','','','2025-12-20','17:00:00.000Z','','2025-12-20','08:30:00.000Z','Central Daylight Time (America/Chicago)','In-Person','','','','','False','','','','','Summit_Events__c-5');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-26','Active','','False','','Registrants plus Guests','500.0','','','','','2025-12-25','23:00:00.000Z','Annual Dinner & Auction','2025-12-25','18:00:00.000Z','Central Daylight Time (America/Mexico_City)','Annual Dinner & Auction','','','','','False','','','','','Summit_Events__c-8');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-27','Active','','False','','Registrants plus Guests','72.0','','','150.0','','2026-06-14','15:00:00.000Z','2024 Fundraising Golf Event','2026-06-14','09:00:00.000Z','Eastern Standard Time (America/Panama)','2024 Fundraising Golf Event (Individual Registration)','','','','','True','','','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Instance__c" VALUES('Summit_Events_Instance__c-28','Active','','False','','Registrants plus Guests','72.0','','','','','2026-06-14','15:00:00.000Z','2024 Fundraising Golf Event','2026-06-14','09:00:00.000Z','Eastern Standard Time (America/Panama)','2024 Fundraising Golf Event','','','','','False','','','','','Summit_Events__c-9');
CREATE TABLE "Summit_Events_Payment__c" (
	id VARCHAR(255) NOT NULL, 
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
	id VARCHAR(255) NOT NULL, 
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
	"Lookup_Order_By__c" VARCHAR(255), 
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
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-1','','','10.0','Half width','','','','','True','','','','','','','','','','Registrant_First_Name__c','First Name','','','Textbox','First Name','Guest','True','','','Summit_Events__c-7');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-2','','','100.0','','','','','','True','','','','','','','','','','Add_Info_Answer_4__c','Reference','','','Textbox','How did you hear about us?','Registrant','False','','','Summit_Events__c-7');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-3','','Freestyle','50.0','','','','','This is required for Wrestlers.','True','','','','','','','','','','Add_Info_Answer_3__c','Style','Freestyle

Folkstyle

Both - YOU MAY NOT RECIEVE THE SUGGESTED 30MIN REST TIME','','Picklist','Which Style Bracket?','Registrant and Guest','False','','','Summit_Events__c-7');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-4','','','30.0','','','','','','True','','','','','','','','','','Registrant_Date_of_Birth__c','Birthday','','','Date','Birthday','Registrant and Guest','True','','','Summit_Events__c-7');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-5','','','60.0','','','','W = Women; M = Men - an incorrect selection will be assuming the next level up in the matching gender class.','This is required for Wrestlers.  Leaving blank will result in a canceled registration.','True','','','','','','','','','','Add_Info_Answer_2__c','Weight Class','W - 110 lbs

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

M - 276 lbs','','Picklist','What Weight Class will you compete in?','Registrant and Guest','False','','','Summit_Events__c-7');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-6','','','20.0','','','','','','True','','','','','','','','','','Registrant_Last_Name__c','Last Name','','','Textbox','Last Name','Guest','True','','','Summit_Events__c-7');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-7','','Wrestler','1.0','','','','','','True','','','','','','','','','','Add_Info_Answer_1__c','Attendee','Wrestler

Coach

Parent

Trainer

Referee','','Picklist','What kind of registration?','Registrant and Guest','True','','','Summit_Events__c-7');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-8','','','40.0','Half width','','','','','True','','','','','','','','','','Registrant_Gender__c','Gender','Male

Female','','Picklist','Gender','Guest','False','','','Summit_Events__c-7');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-9','','','','','','','','If you will be traveling with someone who is not included on this registration, please provide their name and we will match up your itineraries. If you are traveling solo, do not include a name and you will be contact separately about your single supplement fee.','True','','','','','','','','','','event_cotraveler__c','Travel Companion Name','','','Textbox','Co-traveler name (optional)','Registrant','False','','','Summit_Events__c-1');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-10','','','10.0','Half width','','','','What High School or College do you go to?','True','','','','','','','','','','Registrant_High_School__c','High School/College','','','Textbox','High School/College','Registrant','True','100.0','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-11','','','','Half width','','','This is just to drive conversation, not holding you to anything!','If you don''t know, leave it blank and we can talk about it more later.','True','','','','','','','','','','Add_Info_Answer_1__c','College Credits','','','Textbox','Are you intended to transfer in credits? If so, How many?','Registrant','False','','','Summit_Events__c-2');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-12','','','10.0','Half width','Please enter a valid email address.','','','Please share your the email address associated to your Slack account.  Don''t have a Slack account, you''re about to!','True','','','','','','','','','','Registrant_Other_Email__c','Other Email','','','Email','Other Email (for Slack purposes during the sprint if different to the above).','Registrant','False','100.0','','Summit_Events__c-3');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-13','','','20.0','Half width','','','Example: https://github.com/USERNAME. *','','True','','','','','','','','','','Add_Info_Answer_4__c','Github User','','','Textbox','What is your GitHub Username?','Registrant','True','100.0','','Summit_Events__c-3');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-14','','','','','','','','','True','','','','','','','','','','Registrant_First_Name__c','Guest First Name','','','Textbox','Guest First Name','Guest','True','','','Summit_Events__c-10');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-15','','','','','','','','','True','','','','','','','','','','Registrant_Last_Name__c','Guest Last Name','','','Textbox','Guest Last Name','Guest','True','','','Summit_Events__c-10');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-16','','','','','Please enter a valid email address.','','','','True','','','','','','','','','','Registrant_Email__c','Guest Email','','','Email','Guest Email','Guest','True','','','Summit_Events__c-10');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-17','','','20.0','','','','','','True','','','','','','','','','','Registrant_Last_Name__c','Guest Last Name','','','Textbox','Guest Last Name','Guest','True','','','Summit_Events__c-8');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-18','','','30.0','','Please enter a valid email address.','','','','True','','','','','','','','','','Registrant_Email__c','Guest Email','','','Email','Guest Email','Guest','True','','','Summit_Events__c-8');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-19','','','10.0','','','','','','True','','','','','','','','','','Registrant_First_Name__c','Guest First Name','','','Textbox','Guest First Name','Guest','True','','','Summit_Events__c-8');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-20','','','20.0','','','','','','True','','','','','','','','','','Registrant_Last_Name__c','Guest Last Name','','','Textbox','Last Name','Guest','True','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-21','','','30.0','','','','','','True','','','','','','','','','','Registrant_Email__c','Guest Email','','','Email','Email','Guest','False','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-22','','','10.0','','','','','','True','','','','','','','','','','Registrant_First_Name__c','Guest First Name','','','Textbox','First Name','Guest','True','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-23','','','60.0','','','','','','True','','','','','','','','','','Add_Info_Answer_2__c','Golfer T-Shirt Size','','S

M

L

XL

XXL

XXXL','Picklist','Golfer T-Shirt Size','Guest','True','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-24','','','40.0','','','','','','True','','','','','','','','','','Add_Info_Answer_5__c','Golfer/Guest','','Golfer

Dinner Guest','Picklist','Is this a Golfer or a Guest for Dinner?','Guest','True','','','Summit_Events__c-9');
INSERT INTO "Summit_Events_Question__c" VALUES('Summit_Events_Question__c-25','','','50.0','','','','','','True','','','','','','','','','','Add_Info_Answer_1__c','Handicap','','','Textbox','Golfer Handicap','Guest','True','','','Summit_Events__c-9');
CREATE TABLE "Summit_Events_Registration__c" (
	id VARCHAR(255) NOT NULL, 
	"Accessibility_Need_Detail__c" VARCHAR(255), 
	"Accessibility_Need__c" VARCHAR(255), 
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
	"Dietary_Ristrictions__c" VARCHAR(255), 
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
	"New_Person_Account_Created__c" VARCHAR(255), 
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
	"Registrant_Date_of_Birth_Text__c" VARCHAR(255), 
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
	"reCAPTCHA_Score__c" VARCHAR(255), 
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
	"Lead__c" VARCHAR(255), 
	"Person_Account__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Summit_Events__c" (
	id VARCHAR(255) NOT NULL, 
	"Academic_Program_List_Selected__c" VARCHAR(255), 
	"Academic_Program_List__c" VARCHAR(255), 
	"Academic_Program_Selected__c" VARCHAR(255), 
	"Accessibility_Detail_Label__c" VARCHAR(255), 
	"Accessibility_Label__c" VARCHAR(255), 
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
	"Ask_Accessibility_Needs__c" VARCHAR(255), 
	"Ask_Applicant_Type__c" VARCHAR(255), 
	"Ask_Company_Organization__c" VARCHAR(255), 
	"Ask_Date_Of_Birth__c" VARCHAR(255), 
	"Ask_Dietary_Restrictions__c" VARCHAR(255), 
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
	"Custom_Metadata_Person_Matching_Method__c" VARCHAR(255), 
	"Date_Of_Birth_Label__c" VARCHAR(255), 
	"Dietary_Restrictions_Label__c" VARCHAR(255), 
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
	"Person_Creation_Duplicate_Rule__c" VARCHAR(255), 
	"Person_Matching_Multiple_Match_Behavior__c" VARCHAR(255), 
	"Person_Matching_No_Match_Behavior__c" VARCHAR(255), 
	"Person_Matching_Rules__c" VARCHAR(255), 
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
	"Use_Matching_for_Guest_Registrations__c" VARCHAR(255), 
	"reCAPTCHA__c" VARCHAR(255), 
	"reCAPTCHA_v3_Score_Fail_Text__c" VARCHAR(255), 
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
INSERT INTO "Summit_Events__c" VALUES('Summit_Events__c-1','','','','Please indicate your accessibility request below.','Do you have any accessibility needs for this event?','None

Vegetarian

Vegan

Gluten-Free

Low Glycemic','','No

Yes, for long distances

Yes, at all times','No

Yes','No

Yes','','','','','','Dietary Restrictions/Preferences','Please list any food allergies:','Will you require mobility aids or accommodations?','Will you require handicapped-accessible lodgings?','Will you require passport/visa assistance (extra fees may apply)?','Pick-list required','Text area','Pick-list required','Pick-list required','Pick-list required','False','','Application Type','Do not ask','Do not ask','Do not ask','Ask and require','Do not ask','Ask and require','False','Do not ask','Ask and require','Ask with type require','Ask','Do not ask','Do not ask','Do not ask','Do not ask','','Do not ask','','','30.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','','Date of Birth','Do you have any dietary restrictions?','False','False','False','','','','Email','2027-01-10','Reservation Details','<p><strong style="font-size: 24px;">Demo Notes</strong></p><p><br></p><p><span style="font-size: 16px;">For a real event, this page would be extensively populated with questions about information needed by trip planners. The sample question below errors out because it is not mapped to a corresponding custom field; you would need to map these fields in your instance to make custom questions functional.</span></p><p><br></p><p><span style="font-size: 16px;">As a note on example process, the descriptive text related to the question below might read:</span></p><p class="ql-indent-2"><em style="font-size: 16px;">If you will be traveling with someone who is not included on this registration, please provide their name and we will match up your itineraries. If you are traveling solo, do not include a name and you will be contact separately about your single supplement fee.</em></p><p class="ql-indent-1"><br></p><p><span style="font-size: 16px;">This information would be used by org staff behind the scenes to match the registration records of individuals who will be traveling together but did not register at the same time. In the event that this procedure is used, the registrant should be clearly informed that if two individuals register on the same transaction </span><strong style="font-size: 16px;">and do not specify alternate traveling companions</strong><span style="font-size: 16px;">, the default assumption will be that the two registrants are traveling together. A workflow would also need to be developed/implemented for following up with solo travelers for any associated fees, if this is not otherwise built into the registration process (e.g., via a separate solo ticket type and pricing tier).</span></p><p><br></p><p><span style="font-size: 16px;">Other questions in this section might include passport number and expiration date, questions about pre-/post-trip supplements, excursion options. etc.</span></p>','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','<p>Thank you for registering! You will receive a registration number by email shortly, and a member of our travel concierge team will be in touch to confirm the details of your booking in 2-5 business days. Questions in the meantime? Just reply on your registration email and a customer service agent will get in touch.</p>','You''re going to Japan!','','Event Cost','Event Charges','Total','','Payments Received','<p><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Alumni-Events-Footer.png" alt="Picture of Japan Skyline"></img></p>','','','Event Home','','Sample - 2024 Alumni Tours','','Payment Due','','Payment Received','','','Inactive','','','Overnight','<h1><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Alumni-Travel-Home.jpg" alt="Travel On"></img></h1><h1><strong style="font-size: 28px; color: rgb(197, 5, 12);"><em>Cruise to Japan</em></strong></h1><p><span style="font-size: 18px;">Let the harmony of Japanese culture surround you as you immerse yourself in the deeply rooted customs and traditions of this majestic island nation on a 12-night cruise aboard Oceania Cruises’ </span><em style="font-size: 18px;">Riviera</em><span style="font-size: 18px;">.</span></p><p><br></p><p><span style="font-size: 18px;">From the simplest pleasures of a tea ceremony to the excitement of sumo spectating, this voyage offers a unique insight into the Japanese way of life. Begin your journey in metropolitan Tokyo and set sail with views of majestic Mount Fuji to the seaport of Shimizu. Continue to Japan’s old capital of Kyoto for an overnight stay and glimpse the sun glinting off the Golden Pavilion. Take a dip in the city of Beppu, a resort getaway that is home to more than 2,000 hot springs. Sail down the Kanmon Strait and see the flourishing art scene, renowned Buddha statues, and beautiful beaches of Busan, South Korea.</span></p><p><br></p><p><span style="font-size: 18px;">Discover a new side of Japan in the volcanoes and offshore islands of Nagasaki and the picturesque seaside cityscape of Kagoshima on Kyushu Island. Contemplate peace in historic Hiroshima with a stroll through the beautifully landscaped gardens and iconic Hiroshima Castle. Then head to the surfer’s paradise — quaint Kochi — where the blue Pacific waters meet green land. Explore the industrial side of Japan as you take in the newly reconstructed palace and many museums of Nagoya before you conclude your trip back in the bustling city of Tokyo.</span></p><p style="text-align: right;"><a href="https://www.uwalumni.com/travel/request-trip-information/?requested_trip=Denali%20National%20Park" target="_blank" style="font-size: 18px; color: rgb(197, 5, 12); background-color: rgb(255, 255, 255);">Request a Brochure &gt;&gt;</a></p><p style="text-align: right;"><br></p><p style="text-align: right;"><br></p>','Book Now','','','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','','','','On-Site','Registrant Address','','Sample - 2024 Alumni Tours','','Make Payment','No Gateway','','Match with most recently modified','Create Person Account','','Phone number','Type','Grad Year (UW Alumni)','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2025-09-10','GeneralSLDS','I am...','Title','','','','','','True','','We are sorry. Your registration cannot be completed at this time. Please try again using a different browser or device.','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES('Summit_Events__c-2','','','','Please indicate your accessibility request below.','Do you have any accessibility needs for this event?','','','','','','','','','','','','','','','','','','','','','True','','Application Type','Do not ask','Ask','Do not ask','Ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Ask','Do not ask','Do not ask','Parent/Guardian;Other','Do not ask','Prospective Student','Office of Admissions','3.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','','Date of Birth','Do you have any dietary restrictions?','False','False','False','','','','Email','2027-01-11','Additional Details Needed','<p><span style="font-size: 16px;">Please share the information below.  This information is supportive to us making your experience magical!</span></p>','Selected options','<p><span style="font-size: 16px;">You have options to make your day personalized.  Other than the Tour, what else can we accommodate for you?</span></p>','Once you have made your selections click next.','','Other than a Tour','Select your options','<p><span style="font-size: 16px;">We get it.  Sometimes you have to cancel.  We want to welcome you back to visit campus, so </span><a href="https://app-efficiency-8763-dev-ed.scratch.my.salesforce-sites.com/" target="_blank" style="font-size: 16px;">please find another date/time</a><span style="font-size: 16px;"> and we&#39;ll get things scheduled for you again!</span></p>','No!!! We want to see you!','','<p style="text-align: center;"><span style="font-size: 18px;">Thank you and we look forward to seeing you soon!  We&#39;ll ensure that your visit is special to you and your desired experience, which may required us to connect with other departments.  As soon as we&#39;ve confirmed all of your appointments we&#39;ll reach out with a full itinerary!</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/tour-with-coffee.jpg" alt="Photo of women in group with coffee in hand"></img></p>','Registration Received!','','Event Cost','Event Charges','Total','','Payments Received','<p><span style="font-size: 16px;">For more information about Summit Events University, contact us at summitevt@gmail.com or go to our </span><a href="" target="_blank" style="font-size: 16px;">website</a><span style="font-size: 16px;">.</span></p>','<p>This Tour Date is Close due to capacity or timing.  Check out our Events Calendar [Insert Link here] to find another date that may work for you!</p>','','Event Home','','Sample - Higher Ed/K12 Admissions Tours','','Payment Due','','Payment Received','','','Active','<p><span style="font-size: 16px;">Take a quick look and make sure you indicated everything you&#39;d like about your visit.</span></p>','Review your Requests','Admissions Event','<p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Tour-Image.jpg" alt="Tour Image.jpg"></img></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 22px;">Join Us for a Glimpse into Your Future at Summit Events University!</span></p><p style="text-align: center;"><br></p><p><span style="font-size: 16px;">Welcome to Summit Events University&#39;s Admissions Tour registration page. We&#39;re excited to have you join us for an exclusive look at what your journey with us could be like. Please fill out the following details to secure your spot.</span></p><p><br></p><p><span style="font-size: 20px;">Why Choose Summit Events University:</span></p><p><span style="font-size: 16px;">Summit Events University is your gateway to a rewarding career in event management and hospitality. Our innovative programs, expert faculty, and strong industry connections make us the perfect choice for your academic journey.</span></p><p><br></p><p><strong style="font-size: 16px;">What to Expect and Opportunities:</strong></p><ul><li><span style="font-size: 16px;">Campus Tour</span></li><li><span style="font-size: 16px;">Faculty Meet and Greet</span></li><li><span style="font-size: 16px;">Student Showcase</span></li><li><span style="font-size: 16px;">Admissions Information Session</span></li><li><span style="font-size: 16px;">Q&amp;A with Our Team</span></li><li><span style="font-size: 16px;">Networking Opportunities</span></li></ul><p><span style="font-size: 16px;">Don&#39;t miss out on this opportunity to explore your future and kickstart your dream career. Secure your spot for the Admissions Tour now, and get ready to embark on an exciting academic adventure.</span></p><p><br></p><p><span style="font-size: 16px;">By submitting this registration, you&#39;re taking your first step toward a future filled with endless possibilities. We can&#39;t wait to welcome you to Summit Events University.</span></p>','Register','All Websites','All Websites','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','415 Mission St, San Francisco, CA 94105','https://maps.app.goo.gl/QrHyvdSYkcEQ8fHD8','Summit Events University','On-Site','Registrant Address','4.0','Sample - Higher Ed/K12 Admissions Tours','','Make Payment','No Gateway','','Match with most recently modified','Create Person Account','','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','One registration per instance','Relationship (select all that apply)','2025-01-10','GeneralSLDS','I am...','Title','','','','','','True','','We are sorry. Your registration cannot be completed at this time. Please try again using a different browser or device.','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES('Summit_Events__c-3','','','','Please indicate your accessibility request below.','Do you have any accessibility needs for this event?','1 - 20 employees

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

No, I''m a first time Sprinter!','','','','','','','','Number of Employees','How do you categorize your organization?','Have you attended a community sprint before?','','','Pick-list required','Pick-list required','Pick-list required','','','False','','Application Type','Do not ask','Do not ask','Ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Ask mobile and require','Do not ask','Do not ask','Ask','Do not ask','Do not ask','','Ask','','','0.0','','Company or Organization','Standard Contact Duplicate Rule','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','Use Salesforce Duplicate Rule','Admissions','','','Date of Birth','Do you have any dietary restrictions?','False','False','True','','','','Email','2026-10-11','Additional Questions','<p><span style="font-size: 16px;">We&#39;re excited that you&#39;ve chosen to join us for the Commons Open Source Sprint! To ensure we can tailor your experience and provide you with all the necessary details, we kindly ask for a bit more information. Please take a moment to complete the following questions so we can make your experience meaningful!</span></p><p><br></p><p><br></p><p><span style="font-size: 16px;"><span class="ql-cursor">﻿</span></span></p>','Selected options','<p><span style="font-size: 16px;">We love the community and your sprinters!  Make all appropriate selections below and get ready to have an amazing time!</span></p>','Once you have made your selections click next.','','We want to treat you!','Choose your options','<p><span style="font-size: 16px;">We&#39;re saddened to hear about your cancellation for the upcoming sprint. We were really looking forward to having you with us, and your absence will be felt. If you ever decide to join us in the future, we&#39;d be thrilled to welcome you back. If you have any questions, feel free to reach out to us at commons@sprint.demo. </span></p><p><br></p><p><span style="font-size: 16px;"><span class="ql-cursor">﻿</span>Take care, and best wishes.</span></p>','Please don''t go!!!','','<p style="text-align: center;"><span style="font-size: 16px;">We&#39;re absolutely thrilled to have you join us for the Commons Open-Source Sprint! Your registration has been successfully confirmed, and we can&#39;t wait to see you in person or virtually, depending on your chosen attendance option.</span></p><p><br></p><p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Nov_2022_Community_Sprint.png" alt="Nov 2022 Community Sprint"></img></p><p><br></p><p><span style="font-size: 16px;">Get ready for an unforgettable experience filled with inspiration, knowledge, and networking opportunities. The Common Open Source Sprint is all about bringing like-minded individuals together, and we&#39;re excited to have you be a part of our community. Whether you&#39;re coming from near or far, or joining us from a different time zone, your presence will make this event even more special.</span></p><p><br></p><p><span style="font-size: 16px;">Stay tuned for further updates and details about the event, including the schedule, speakers, and any materials you might need. In the meantime, if you have any questions or specific requirements, please don&#39;t hesitate to reach out to our dedicated support team.</span></p><p><br></p><p><br></p><p><span style="font-size: 16px;">Hotel Recommendations close to the Salesforce Tower:</span></p><p><a href="https://www.salesforce.org/resources/commons/" target="_blank" style="font-size: 16px;">Holiday Inn</a></p><p><span style="font-size: 16px;">W. Wolf Point Plaza</span></p><p><span style="font-size: 16px;">(312) 555-1234</span></p><p><br></p><p><a href="https://www.salesforce.org/resources/commons/" target="_blank" style="font-size: 16px;">Hyatt Place</a></p><p><span style="font-size: 16px;">N. Palace Rd.</span></p><p><span style="font-size: 16px;">(312) 555-4321</span></p><p><br></p><p><br></p><p><span style="font-size: 16px;">Once again, thank you for registering, and get ready to be inspired, learn, and connect. We can&#39;t wait to welcome you to [Event Name] and share this incredible experience with you!</span></p><p><br></p><p><span style="font-size: 16px;">See you soon!</span></p>','Thank you for registering!','','Event Cost','Event Charges','Total','','Payments Received','<p><span style="font-size: 18px;">For additional Questions please reach out to us in </span><a href="https://trailhead.salesforce.com/trailblazer-community/groups/0F94S000000GwVK?tab=discussion&amp;sort=LAST_MODIFIED_DATE_DESC#discussion?icid=SFORG:resource-page-hero:" target="_blank" style="font-size: 18px;">the community</a><span style="font-size: 18px;"> or check out our </span><a href="https://sfdo-community-sprints.github.io/docs/sprints/" target="_blank" style="font-size: 18px;">GitHub Pages</a><span style="font-size: 18px;">.</span></p><p><br></p><p><br></p><p><span style="font-size: 16px;">&copy; Copyright 2023 Salesforce.com, inc. </span><a href="https://www.salesforce.com/company/legal/intellectual/?_gl=1*hrczfo*_ga*MTA1NDY0ODM3LjE2OTgxNjkzOTg.*_ga_J1M7TM7DGX*MTY5ODc2MzgxMC4xLjAuMTY5ODc2MzgxMC4wLjAuMA.." target="_blank" style="font-size: 16px;">All rights reserved</a><span style="font-size: 16px;">. Various trademarks held by their respective owners. Salesforce.com, inc. Salesforce Tower, 415 Mission Street, 3rd Floor, San Francisco, CA 94105, United States</span></p>','','','Event Home','','Sample - Open Source Sprint - Multi-Step','','Payment Due','','Payment Received','','','Active','','Please confirm your details below','Engagement','<p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 48px;">Nonprofit &amp; Education Community Sprint</span></p><p><br></p><p style="text-align: center;"><span style="color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Open-Source-Commons.png" alt="Open Source Commons.png"></img></span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><strong style="font-size: 36px; color: rgb(0, 0, 0);">Activating community to supercharge impact</strong></p><p style="text-align: center;"><br></p><p><br></p><p><strong style="font-size: 18px; color: rgb(0, 0, 0);">What is a Sprint?</strong><span style="font-size: 18px; color: rgb(0, 0, 0);"> </span></p><p><span style="font-size: 16px;">The Sprint is a hack-a-thon type event, where you will contribute your skills in small breakout groups and work with others, to discuss different Salesforce technology challenges.</span></p><p><span style="font-size: 16px;"> </span></p><p><span style="font-size: 16px;">Connect and collaborate with your peers to build solutions to common challenges prioritized by you and the community. </span></p><p><span style="font-size: 16px;"> </span></p><p><strong style="font-size: 18px;">Who should attend?</strong><span style="font-size: 18px;"> </span></p><p><span style="font-size: 16px;">Register if you&#39;re an Admin, Developer, Consultant, or End-User in the Nonprofit or Education Salesforce community.</span></p><p><span style="font-size: 16px;"> </span></p><p><span style="font-size: 16px;">The Sprint is a </span><strong style="font-size: 16px;">free </strong><span style="font-size: 16px;">event, and all are welcome. For more details, check out the event FAQs.</span></p><p><br></p><p style="text-align: center;"><span style="font-size: 16px;"> </span><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Open-Source-Image-Options.png" alt="Open Source Commons Project Logos - DLRS, Grassroots Mobile Survey, Summit Events App"></img></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;">﻿</p>','Register','','','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','True','Last Name As Student','Last Name','','','','','333 W Wolf Point','https://maps.app.goo.gl/wcvs7AduZ3oiu1k2A','Chicago Salesforce Tower','On-Site','Registrant Address','','Sample - Open Source Sprint - Multi-Step','','Make Payment','No Gateway','','Match with most recently modified','Create Person Account','','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2025-10-10','GeneralSLDS','I am...','Title','','','','','','True','','We are sorry. Your registration cannot be completed at this time. Please try again using a different browser or device.','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES('Summit_Events__c-4','','','','Please indicate your accessibility request below.','Do you have any accessibility needs for this event?','','','','','','','','','','','','','','','','','','','','','False','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Ask','Ask mobile and require','Do not ask','Ask','Do not ask','Do not ask','Do not ask','','Do not ask','Prospective Student','Office of Admissions','0.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','','Date of Birth','Do you have any dietary restrictions?','False','False','True','','','','Email','2026-01-06','','','Selected options','','Once you have made your selections click next.','','Please choose additional options!','Choose your options','','','','<p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 18px;">Congratulations! Your registration for the Connected University Graduate Programs Open House has been successfully received. We&#39;re thrilled that you&#39;ve chosen to explore our graduate programs and discover the exciting opportunities that await you.</span></p><p><span style="font-size: 18px;">﻿</span></p><p><strong style="font-size: 20px;">What&#39;s Next:</strong></p><p><em style="font-size: 18px;">Confirmation Email:</em><span style="font-size: 18px;"> In the next few minutes, you&#39;ll receive a confirmation email with all the event details and a summary of your registration.</span></p><p><em style="font-size: 18px;">Event Reminder</em><span style="font-size: 18px;">: As the event date approaches, we&#39;ll send you a friendly reminder to ensure you don&#39;t miss this fantastic opportunity.</span></p><p><em style="font-size: 18px;">Connect with Us</em><span style="font-size: 18px;">: Stay engaged with Connected University by following us on social media. We&#39;ll be sharing updates and exclusive content leading up to the Open House.</span></p><p><br></p><p><strong style="font-size: 20px;">Have Questions?</strong></p><p><span style="font-size: 18px;">If you have any questions or need further assistance, feel free to reach out to our event team at [Organizer&#39;s Contact Information]. We&#39;re here to make sure your experience with Connected University is seamless and informative.</span></p><p><br></p><p><span style="font-size: 18px;">Thank you for choosing Connected University. We look forward to meeting you at the Graduate Programs Open House and helping you explore the possibilities that await on your academic journey.</span></p><p><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 18px;">We look forward to telling you more about Connected University!</span></p>','Thank you for regisitering!','','Event Cost','Event Charges','Total','','Payments Received','<p><span style="font-size: 18px;">If you have any questions or need further information, please contact us at [Organizer&#39;s Contact Information].</span></p>','<p style="text-align: center;"><span style="font-size: 18px;">Thank you for your interest in the Connected University Graduate Programs Open House.</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 18px;">We regret to inform you that the event is currently at full capacity, and registration has been closed. Due to overwhelming interest, we have reached the maximum number of attendees we can accommodate.</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 18px;">We appreciate your enthusiasm and understanding. If you have any questions or would like information about future events, programs, or admissions, please feel free to reach out to our team at [Organizer&#39;s Contact Information].</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 18px;">Thank you for considering Connected University. We apologize for any inconvenience, and we hope to have the opportunity to connect with you in the future.</span></p>','','Event Home','','Sample - Open House for Prospective Graduate Students','','Payment Due','','Payment Received','','','Active','','Review your selected options and submit!','Admissions Event','<p style="text-align: center;"><span style="color: rgb(55, 93, 169); font-size: 28px;">Discover Your Future at Connected University</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Open-House-Event-Salesforce-U.png" alt="Salesforce U Logo"></img></p><p><br></p><p><span style="font-size: 18px;">Join us for a 90-minute open house and discover how Connected University can provide the graduate school experience you desire while equipping you with the skills needed for success.</span></p><p><br></p><p><strong style="font-size: 18px;">What to Expect:</strong></p><ul><li><span style="font-size: 18px;">Informative Sessions: Engage in insightful presentations that highlight the unique aspects of Connected University&#39;s graduate programs.</span></li><li><span style="font-size: 18px;">Interactive Workshops: Participate in hands-on workshops designed to showcase the practical skills you&#39;ll acquire during your studies.</span></li><li><span style="font-size: 18px;">Meet Faculty and Students: Connect with our experienced faculty members and current students to gain valuable insights into the Connected University community.</span></li><li><span style="font-size: 18px;">Campus Tour (if applicable): Explore our state-of-the-art facilities and get a feel for the vibrant campus life.</span></li></ul><p><strong style="font-size: 18px;">Why Connected University?</strong></p><ul><li><span style="font-size: 18px;">Tailored Graduate Experience: Discover how Connected University tailors its programs to meet the diverse needs and aspirations of its students.</span></li><li><span style="font-size: 18px;">Career-Focused Education: Learn about our commitment to providing education that aligns with current industry demands, ensuring you graduate with the skills employers seek.</span></li><li><span style="font-size: 18px;">Supportive Community: Explore the supportive and inclusive community that sets Connected University apart.</span></li></ul>','Register','','','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','Labels as headers','Appointment_Title__c','Appointment_Time_Formatted__c','Registrant_Input__c','Description__c','','Session','Time','Detail(s)','Description','','','','','','False','Last Name As Student','Last Name','','','','','123 University Avenue, Academic City, Imaginaria 54321','https://www.google.com/maps?q=123+University+Avenue,+Academic+City,+Imaginaria+54321','Connected U Graduate Campus','On-Site','Registrant Address','','Sample - Open House for Prospective Graduate Students','','Make Payment','No Gateway','','Match with most recently modified','Create Person Account','','Please provide either a mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2025-11-06','GeneralSLDS','I am...','Title','','','','','','True','','We are sorry. Your registration cannot be completed at this time. Please try again using a different browser or device.','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES('Summit_Events__c-5','','','','Please indicate your accessibility request below.','Do you have any accessibility needs for this event?','1-500 employees

501-1000 employees

1001-5000 employees

5001-10000 employees

10001+ employees','ISV

Consulting

Customer

Just Sprinting','','','','','','','','','Number of Employees','How do you categorize your organization?','What is your GitHub username?','What is your Slack email - to stay connected?','','Pick-list','Pick-list','Text area required','Text box required','','False','','Application Type','Do not ask','Do not ask','Ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Ask mobile and require','Do not ask','Ask','Ask','Do not ask','Do not ask','','Ask','General Public','','0.0','','Company or Organization','Standard Contact Duplicate Rule','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','Use Salesforce Duplicate Rule','Admissions','','','Date of Birth','Do you have any dietary restrictions?','False','False','False','','','','Email','2026-10-11','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','<p style="text-align: center;"><span style="font-size: 16px;">We&#39;re absolutely thrilled to have you join us for the Commons Open-Source Sprint! Your registration has been successfully confirmed, and we can&#39;t wait to see you in person or virtually, depending on your chosen attendance option.</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p><br></p><p><span style="font-size: 16px;">Get ready for an unforgettable experience filled with inspiration, knowledge, and networking opportunities. The Common Open Source Sprint is all about bringing like-minded individuals together, and we&#39;re excited to have you be a part of our community. Whether you&#39;re coming from near or far, or joining us from a different time zone, your presence will make this event even more special.</span></p><p><br></p><p><span style="font-size: 16px;">Stay tuned for further updates and details about the event, including the schedule, speakers, and any materials you might need. In the meantime, if you have any questions or specific requirements, please don&#39;t hesitate to reach out to our dedicated support team.</span></p><p><br></p>','Thank you for Registering','','Event Cost','Event Charges','Total','','Payments Received','<p><span style="color: rgb(68, 68, 68);"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Nirvik_Footer.jpg" alt="Salesforce logo"></img></span></p>','<p>This Event&#39;s Registration is now CLOSED. Get ready to Sprint on the next one! We&#39;ll miss you.</p>','','Event Home','','Sample - Open Source Sprint Event - Single Step','','Payment Due','','Payment Received','Open Source Sprint Event','','Active','','','Info Session','<p><span style="font-size: 16px;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Nirvik_Header.jpg" alt="image.png"></img></span></p><p><br></p><p><span style="font-size: 16px;">﻿Get ready to rock the Windy City with </span><strong style="font-size: 16px; color: rgb(0, 158, 219);">Salesforce</strong><span style="font-size: 16px;">&#39;s</span><strong style="font-size: 16px;"> </strong><span style="font-size: 16px;">tech extravaganza! &#127788;️ Join us at the </span><strong style="font-size: 16px;">Salesforce Commons Sprint </strong><span style="font-size: 16px;">event in the heart of Chicago. &#127961;️</span></p><p><br></p><p><span style="font-size: 16px; color: rgb(0, 0, 0);">The Sprint is not just another event – it&#39;s your ticket to tech-tastic fun, and it&#39;s totally free! Whether you&#39;re a beginner or a Salesforce ninja, there&#39;s something for everyone at the Sprint. &#128640; You&#39;ll learn from Salesforce experts, rub shoulders with like-minded tech enthusiasts, and even get</span><span style="font-size: 16px;"> a chance to create something that truly rocks! &#129302;&#127881;</span></p><p><br></p><p><span style="font-size: 16px;">Imagine a tech playground where innovation knows no bounds. Our Sprints are like community innovation parties (think hack-a-thon meets carnival) designed to unite Salesforce partners, customers, and our amazing employee volunteers. Together, we brainstorm, prioritize, and build solutions that make using Salesforce a breeze, especially for nonprofit &amp; education organizations. &#129504;&#127905;</span></p><p><br></p><p><span style="font-size: 16px;">Come for the knowledge, stay for the thrill! Connect, learn, and supercharge your Salesforce expertise with the coolest crowd in the industry. Whether you&#39;re a tech newbie or a seasoned pro, this sprint is your backstage pass to a tech party like no other. &#128378;&#128131;</span></p><p><br></p><p><span style="font-size: 16px;">Don&#39;t miss your chance to ride the innovation wave! &#127754;</span></p><p><span style="font-size: 16px;">Save the date, grab your tech gear, and stay tuned for more juicy details. See you in Chicago, where tech dreams come true! &#127880;&#127775;</span></p><p><br></p><p><span style="font-size: 16px;">Ready to have a blast and make a difference at the </span><strong style="font-size: 16px;">October Nonprofit &amp; Education Community Sprint</strong><span style="font-size: 16px;">? Register below, and let&#39;s get this tech party started! &#127882;&#128640;&#128187;</span></p><p><br></p><p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Nirvik_Mid-1.jpg" alt="Picture of Commons Director"></img> <img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Nirvik_Mid-2.jpg" alt="Salesforce Trailblazer Community logo"></img></p><p><strong style="font-size: 16px;">What is a Sprint?</strong><span style="font-size: 16px;"> The Sprint is a hack-a-thon type event, where you will contribute your skills in small breakout groups and work with others, to discuss different Salesforce technology challenges.</span></p><p><span style="font-size: 16px;"> </span></p><p><span style="font-size: 16px;">Connect and collaborate with your peers to build solutions to common challenges prioritised by you and the community. </span></p><p><span style="font-size: 16px;"> </span></p><p><strong style="font-size: 16px;">Who should attend?</strong><span style="font-size: 16px;"> Register if you&#39;re an </span><strong style="font-size: 16px;">Admin</strong><span style="font-size: 16px;">, </span><strong style="font-size: 16px;">Developer</strong><span style="font-size: 16px;">, </span><strong style="font-size: 16px;">Consultant</strong><span style="font-size: 16px;">, or </span><strong style="font-size: 16px;">End-User </strong><span style="font-size: 16px;">in the </span><u style="font-size: 16px;">Nonprofit</u><span style="font-size: 16px;"> or </span><u style="font-size: 16px;">Education</u><span style="font-size: 16px;"> Salesforce community.</span></p><p style="text-align: center;"><br></p><p style="text-align: center;"><br></p><p style="text-align: center;"><strong style="color: rgb(0, 158, 219); font-size: 16px;">Meet the Team</strong></p><p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Nirvik_Pre-Footer_1.jpg" alt="image.png"></img></p>','Register','','','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','True','Last Name As Student','Last Name','','','','','333 W Wolf Point Plaza','https://maps.app.goo.gl/ASZMg32hRja4a7vr7','Chicago','On-Site','Registrant Address','','Sample - Open Source Sprint Event - Single Step','','Make Payment','No Gateway','','Match with most recently modified','Create Person Account','','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2025-10-10','GeneralSLDS','I am...','Title','','','','','','True','','We are sorry. Your registration cannot be completed at this time. Please try again using a different browser or device.','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES('Summit_Events__c-6','','','','Please indicate your accessibility request below.','Do you have any accessibility needs for this event?','Yes

No

Other','Spouse

Family member (non-spouse)

Non-family member','','','','','','','','','Are you a caregiver of someone with Dementia','What is your relation to the individual suffering from dementia?','What is your biggest need of help or support?','','','Pick-list','Pick-list','Text area','','','True','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Ask with type','Do not ask','Ask','Do not ask','Do not ask','Do not ask','','Do not ask','General Public','','0.0','','Company or Organization','','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','','','','','Date of Birth','Do you have any dietary restrictions?','False','False','False','','','','Email','2026-10-11','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','<p><span style="font-size: 16px;">Thank you for registering for the Dementia Caregiver Support Group. Your commitment to being a part of this caring community is truly appreciated.</span></p><p><br></p><p><span style="font-size: 16px;">We are thrilled to have you join us and look forward to creating a supportive and understanding space where caregivers like yourself can share experiences and find solace.</span></p><p><br></p><p><span style="font-size: 16px;">If you have any questions or need further information before the event, feel free to reach out to us at [Organizer&#39;s Contact Information].</span></p>','Thank you for Registering','','Event Cost','Event Charges','Total','','Payments Received','<p style="text-align: center;"><span style="font-size: 16px;">Dementia Care Support Group is a non-profit dedicated to proving support to caregivers</span></p><p><br></p><p><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/dementia-support-banner.jpg" alt="We Support Caregivers Of Loved Ones With Dementia"></img></p>','<p style="text-align: center;"><span style="font-size: 16px;">Sorry, this session is currently closed - please call our office for more information for caregivers.</span></p>','','Event Home','','Sample - Dementia Caregiver Support','','Payment Due','','Payment Received','Series of Events to support caregivers supporting those suffering from Dementia','Center for Common Good','Active','','','Info Session','<p style="text-align: center;"><strong style="color: rgb(14, 50, 234); font-size: 26px;">Dementia Care Giver Support Group</strong></p><p><br></p><p><span style="background-color: rgb(255, 255, 255); color: rgb(68, 68, 68); font-size: 16px;">Caring for a loved one with dementia can be both rewarding and challenging. The Embracing Hope Dementia Caregiver Support Group provides a safe and understanding space for caregivers to share experiences, exchange advice, and find emotional support. This event aims to create a supportive community that empowers caregivers with knowledge and strength to navigate the journey of caring for someone with dementia.</span></p><p><br></p><p><span style="color: rgb(0, 0, 0); font-size: 16px;">Join this monthly meeting to connect with other Caregivers and learn from Dementia experts to hear the latest care tips, clinical research, and connect with support resources in our community.</span></p><p><br></p><p><br></p><p><strong style="font-size: 16px;">Agenda:</strong></p><ul><li><span style="font-size: 16px;">Welcome and Introduction: Get to know fellow caregivers and share your caregiving journey.</span></li><li><span style="font-size: 16px;">Expert Insights: Gain valuable insights from professionals in the field of dementia care.</span></li><li><span style="font-size: 16px;">Interactive Sharing: Share your experiences and learn from others facing similar challenges.</span></li><li><span style="font-size: 16px;">Q&amp;A Session: Have your questions addressed by our experienced facilitators.</span></li><li><span style="font-size: 16px;">Closing Reflection: A moment of reflection and encouragement.</span></li></ul><p><br></p><p><strong style="font-size: 16px;">Who Should Attend:</strong></p><ul><li><span style="font-size: 16px;">Family members caring for a loved one with dementia.</span></li><li><span style="font-size: 16px;">Professional caregivers.</span></li><li><span style="font-size: 16px;">Those with a loved one suffering from Dementia</span></li><li><span style="font-size: 16px;">Anyone interested in learning more about dementia care.</span></li></ul><p><br></p><p><strong style="font-size: 16px;">Registration:</strong></p><ul><li><span style="font-size: 16px;">To ensure a comfortable and intimate setting, pre-registration is required. Please fill out the registration form below.</span></li></ul><p style="text-align: center;"><br></p><h2><br></h2>','Register','All Websites','All Websites','First Name','Gender','','','','','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','True','Last Name As Student','Last Name','','','','','4127 Okemos Rd, Okemos, MI 48864','https://maps.app.goo.gl/6G6GboVUU3sENzzj6','GLF Office','On-Site','Registrant Address','20.0','Sample - Dementia Caregiver Support','','Make Payment','No Gateway','','Match with most recently modified','Create Person Account','','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2025-10-10','GeneralSLDS','I am...','Title','','','','','','True','','We are sorry. Your registration cannot be completed at this time. Please try again using a different browser or device.','','','','','','','','');
INSERT INTO "Summit_Events__c" VALUES('Summit_Events__c-7','','','','Please indicate your accessibility request below.','Do you have any accessibility needs for this event?','','','','','','','','','','','','','','','','','','','','','False','','Application Type','Do not ask','Do not ask','Ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Ask mobile and require','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','','Do not ask','','','2.0','','Do you belong to a team or other organization?','Standard Contact Duplicate Rule','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','Use Salesforce Duplicate Rule','Blue','','','Date of Birth','Do you have any dietary restrictions?','True','False','True','','','','Email','2025-12-14','Additional Registrant Details','<p><span style="font-size: 18px;">To ensure we provide the best experience for you at the ArticGrapple Games, we have a few additional questions to enhance your registration. Your responses will help us tailor the event to meet your needs and preferences. Please take a moment to identify how you&#39;re registering and provide the following information.</span></p><p><br></p><p><span style="font-size: 18px;">If you&#39;re a Coach, please identify that and complete a form for each athlete on the next page.</span></p>','Selected options','','Once you have made your selections click next.','','','Choose your options','<p><span style="font-size: 18px;">If you&#39;re needing to cancel your entire team&#39;s registration, please contact us at [Organizer&#39;s Email] or [Organizer&#39;s Phone Number]</span></p>','Cancel Registration','','<p><span style="font-size: 18px;">You will receive an event confirmation shortly. Please look to it for additional details relating to rules and check in procedures.</span></p>','Thank you for registering for this tournament!','','Event Cost','Event Charges','Total','200.0','Payments Received','<p><span style="font-size: 16px;">For inquiries or assistance, contact our event organizers at [Organizer&#39;s Email] or [Organizer&#39;s Phone Number].</span></p>','<p><span style="font-size: 20px;">Event is finished, see you next year!</span></p>','Confirm Wrestlers & Team','Event Home','','Sample - Summit Wrestling Tournament','','Payment Due','','Payment Received','Get ready for an exhilarating day of intense wrestling!','','Active','<p><span style="font-size: 18px;">If you&#39;ve registered a single or multiple athletes, please confirm all details below. For any changes, go back to the previous page and make appropriate edits.</span></p><p><br></p><p><span style="font-size: 18px;">﻿</span></p>','Review your Entries','Engagement','<p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Wrestling-Tournament-Header.png" alt="Screenshot 2023-10-31 135310.png"></img></p><p style="text-align: center;"><br></p><p style="text-align: center;"><strong style="font-size: 20px;">Outdoor Open Wrestling at Millennium Park!</strong></p><p style="text-align: center;"><span style="font-size: 18px;">Get ready for an exhilarating day of intense wrestling action amidst the beautiful surroundings of Millennium Park. Whether you&#39;re a seasoned wrestler or a fan of the sport, this event promises a thrilling experience for all.</span></p><p style="text-align: center;"><br></p><p><strong style="font-size: 18px;">Event Highlights:</strong></p><ul><li><span style="font-size: 18px;">Open Registration: All skill levels welcome! From beginners to seasoned pros, sign up and showcase your wrestling prowess.</span></li><li><span style="font-size: 18px;">Spectator Zone: Not a wrestler? No problem! Join us as a spectator and cheer for your favorite contenders. Enjoy the excitement from the designated viewing areas.</span></li><li><span style="font-size: 18px;">Scenic Venue: Millennium Park provides a picturesque backdrop for the wrestling event. Take in the action surrounded by greenery and the vibrant energy of the outdoors.</span></li><li><span style="font-size: 18px;">Family-Friendly: Bring the whole family for a day of fun! Food vendors, music, and a festive atmosphere make this event enjoyable for everyone.</span></li></ul><p><br></p><p><strong style="font-size: 18px;">Registration Information:</strong></p><ul><li><span style="font-size: 18px;">Participant Fee: $200</span></li><li><span style="font-size: 18px;">Registration Deadline: [Insert Deadline]</span></li><li><span style="font-size: 18px;">Age Groups: [Specify age groups if applicable]</span></li></ul><p><span style="font-size: 18px;">﻿</span></p><p><strong style="font-size: 18px;">How to Register:</strong></p><ol><li><span style="font-size: 18px;">Fill out the online registration form below. On the next page you&#39;ll be able to identify who you are.</span></li><li><span style="font-size: 18px;">Pay the registration fee securely through our payment portal.</span></li><li><span style="font-size: 18px;">Receive a confirmation email with event details and guidelines.</span></li></ol>','Register','','','First Name','Gender','15.0','Add Another Team Member','<p><span style="font-size: 18px;">Complete the below for each individual who&#39;ll be a part of the tournament. Registration is required for all participating individuals, wrestlers and staff alike. Complete the appropriate information based on their role and read the instructions.</span></p><p><br></p><p><em style="font-size: 18px;">NOTE: If you&#39;re a Wrestler registering and representing themselves, you can skip this page.  You&#39;re welcome to enter Coach information if they&#39;ll be accompanying you.</em></p>','Register Additional Wrestlers, Coaches and Support Staff','','False','Cancel','Continue','You have unsaved information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','201 E Randolph St, Chicago, IL 60602','https://maps.app.goo.gl/efKLkmwybwA61tMr8','Millennium Park','On-Site','Registrant Address','15.0','Sample - Summit Wrestling Tournament','No Members Added Yet','Make Payment','No Gateway','','Match with most recently modified','Create Person Account','','Please provide your mobile phone number.','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2025-10-12','GeneralSLDS','I am...','Title','','','','','','True','','We are sorry. Your registration cannot be completed at this time. Please try again using a different browser or device.','','','','','','','','Summit_Events_Fee_Allocation__c-9');
INSERT INTO "Summit_Events__c" VALUES('Summit_Events__c-8','','','','Please indicate your accessibility request below.','Do you have any accessibility needs for this event?','','','','','','','','','','','','','','','','','','','','','False','','Application Type','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Ask and require','Ask home and mobile require one','Do not ask','Ask','Do not ask','Do not ask','Do not ask','Company Representative','Do not ask','General Public','','7.0','','Company or Organization','Standard Contact Duplicate Rule','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','Use Salesforce Duplicate Rule','Yellow','','','Date of Birth','Do you have any dietary restrictions?','True','True','False','<p><span style="font-size: 18px;">The event will be filled with live and silent auction items! So come ready for that, but don&#39;t hesitate to give something ahead of the event!</span></p><p><br></p><p><span style="font-size: 18px;">Donors of $250 or more are acknowledged </span><span style="font-size: 18px; background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);">as a </span><span style="font-size: 18px;">BENEFACTOR in event materials and listed in TCOA’s Annual Report.</span></p>','100

250

500

1000','Proactive Giving Opportunity - Be a Benefactor','Email','2025-12-28','','','Selected options','<p><span style="font-size: 18px;">Interested Sponsors should select from the options below. You&#39;re welcome to select multiple and we&#39;ll work with you to ensure you&#39;re represented appropriately.</span></p><p><br></p><p><em style="font-size: 18px;">NOTE: You will not be asked for payment of this sponsorship at checkout, but will be provided with a paylink or details on other payment methods.</em></p>','Once you have made your selections click next.','Selected Sponsorship(s)','Sponsorship Opportunities','Select your sponsorship level','<p><span style="font-size: 18px;">We will cancel your related registration automatically and will refund your tickets if completed within 7 days of the event.  Any donation will not be refunded.</span></p>','Can''t Make it?','','<p><span style="font-size: 18px;">Thank you for registering for the Area on Aging Annual Dinner &amp; Auction. We are delighted that you will be joining us for this special event.</span></p><p><br></p><p><span style="font-size: 18px;">Your registration details have been received, and you are now officially part of the Area on Aging Annual Dinner &amp; Auction. Get ready for an evening filled with camaraderie, entertainment, and the chance to contribute to a meaningful cause.</span></p><p><br></p><p><strong style="font-size: 18px;">Important Information:</strong></p><ul><li><span style="font-size: 18px;">Ticket Confirmation:</span><span style="font-size: 18px;"> Your ticket(s) will be sent to the email address provided closer to the event date.</span></li><li><span style="font-size: 18px;">Updates:</span><span style="font-size: 18px;"> Stay tuned for event updates and announcements leading up to the Annual Dinner &amp; Auction.</span></li></ul><p><span style="font-size: 18px;">We appreciate your support and look forward to celebrating this special occasion with you.</span></p><p><br></p><p><span style="font-size: 18px;">If you have any questions or need further assistance, please feel free to contact us.</span></p>','You''re Registered!!!','','Ticket(s)','Total Due Today','Total','75.0','Payments Received','<p><span style="font-size: 16px;">For details about this event, contact us at [Organization&#39;s Email] or [Organization&#39;s Phone Number]</span></p>','','Additional Guest(s) Registered','Event Home','','Sample - Area on Aging Annual Dinner & Auction','','Payment Due','','Payment Received','Annual Dinner & Auction','','Active','<p><span style="font-size: 18px;">Please review the information below. Should you need to make changes, hit the previous button.</span></p>','Review your Registration','Fundraising','<p style="text-align: center;"><span style="background-color: initial; color: rgb(0, 0, 0); font-size: 18px;">The Local Area on Aging and Event Sponsor TBD Company® are pleased to host the 38th Annual Dinner and Auction on [Future Date] at the Kellogg Hotel and Conference Center in East Lansing to raise funds for Meals on Wheels and in-home services for older adults in Clinton, Eaton, and Ingham counties.</span></p><p><span style="font-size: 18px;"> </span></p><p><span style="background-color: initial; color: rgb(0, 0, 0); font-size: 18px;">We expect over 350 people to join us for this evening of dining, live and silent auctions, raffle with cash prizes, games and entertainment, cash bar, and many opportunities to socialize in the name of a good cause.</span></p><p><span style="font-size: 18px;"> </span></p><p><span style="background-color: initial; color: rgb(0, 0, 0); font-size: 18px;">All proceeds benefit local older adults and adults with disabilities to remain safe and independent as they age. </span><a href="https://www.tcoa.org/" target="_blank" style="background-color: initial; color: rgb(0, 0, 0); font-size: 18px;">TCOA </a><span style="background-color: initial; color: rgb(0, 0, 0); font-size: 18px;">connects with over 18,000 people each year who need help, and we are able to do this in part through support from community sponsors, individual attendees, and raffle ticket sales.</span></p><p><span style="font-size: 18px;"> </span></p><p><span style="background-color: initial; color: rgb(0, 0, 0); font-size: 18px;">Please join us for a wonderful evening in support of keeping our aging neighbors, friends, and families safe and thriving in the community. </span></p><p><span style="font-size: 18px;"> </span></p><p><span style="font-size: 18px;">Tickets are </span><strong style="font-size: 18px;">$75 per person</strong><span style="font-size: 18px;">. If you&#39;re planning to be a sponsor, cost per person you pay today will be deducted from your sponsorship total through a follow up process.</span></p>','Register','All Websites','All Websites','First Name','Gender','8.0','','<p><span style="font-size: 18px;">Please share information about your known Guests.  If you&#39;ll be sponsoring or purchasing a table (next page), we&#39;ll follow up with you for anticipated guests and you can skip this step.</span></p>','Guest Information','8.0','True','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guest details.','Touchpoint','False','','','','','','','','','','','','','','','','False','Last Name As Student','Last Name','','','','','219 S Harrison Rd, East Lansing, MI 48824','https://maps.app.goo.gl/bc1Mq98XyrqvsSjE8','Kellog Hotel & Convention Center','On-Site','Registrant Address','500.0','Sample - Area on Aging Annual Dinner & Auction','If you''re sponsoring a table, we''ll capture this later. If you''re coming solo, we''ll make sure you meet some great people with common interests!','Make Payment','No Gateway','','Match with most recently modified','Create Person Account','','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2025-08-10','GeneralSLDS','I am...','Title','','','','','','True','','We are sorry. Your registration cannot be completed at this time. Please try again using a different browser or device.','','Summit_Events_Fee_Allocation__c-10','Summit_Events_Fee_Allocation__c-7','Summit_Events_Fee_Allocation__c-1','Summit_Events_Fee_Allocation__c-8','','','Summit_Events_Fee_Allocation__c-2');
INSERT INTO "Summit_Events__c" VALUES('Summit_Events__c-9','','','','Please indicate your accessibility request below.','Do you have any accessibility needs for this event?','','S

M

L

XL

XXL

XXXL','','','','','','','','','Golf Handicap','T-Shirt Size','','Golfer/Guest','','Text box','Pick-list','','','','False','','Application Type','Do not ask','Do not ask','Ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Do not ask','Do not ask','Do not ask','Ask','Do not ask','Do not ask','Do not ask','','Do not ask','General Public','','5.0','','Company or Organization','Standard Contact Duplicate Rule','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','Use Salesforce Duplicate Rule','Green','','','Date of Birth','Do you have any dietary restrictions?','True','True','False','<p><span style="font-size: 18px;">As you register for the 2024 AR Fundraising Golf Event, we invite you to consider making an additional contribution to support the AR scholarship fund. Your generosity will directly impact the education and opportunities provided to students in the field of augmented reality.</span></p><p><br></p><p><strong style="font-size: 18px;">Why Donate?</strong></p><ul><li><span style="font-size: 18px;">Empower the next generation of AR innovators and leaders.</span></li><li><span style="font-size: 18px;">Foster education and research in the rapidly evolving field of augmented reality.</span></li><li><span style="font-size: 18px;">Make a lasting impact on the future of technology and innovation.</span></li></ul><p><strong style="font-size: 18px;">How Your Donation Helps:</strong></p><ul><li><span style="font-size: 18px;">Provides scholarships to students passionate about AR technology.</span></li><li><span style="font-size: 18px;">Supports educational programs and initiatives in the AR space.</span></li><li><span style="font-size: 18px;">Fuels research and development in augmented reality.</span></li></ul><p><br></p><p><br></p>','25

50

100

250','Give Before the Event','Email','2026-07-14','','','Selected options','<p><span style="font-size: 18px;">Do you have an organization or company wanting to sponsor this event? Check out the opportunities below. Interested Sponsors should select from the options below. You&#39;re welcome to select multiple and we&#39;ll work with you to ensure you&#39;re represented appropriately.</span></p><p><br></p><p><em style="font-size: 18px;">NOTE: You will not be asked for payment of this sponsorship at checkout, but will be provided with a paylink or details on other payment methods.</em></p>','Once you have made your selections click next.','Selected Sponsorship(s)','Sponsorship Opportunities','Select your sponsorship level','<p><span style="background-color: rgb(255, 255, 255); font-size: 18px; color: rgb(68, 68, 68);">We will cancel your related registration automatically and will refund your payment if you&#39;ve cancelled more than 5 days before the scramble. Any donation(s) will not be refunded.</span></p>','Can''t Make it?','','<p><span style="font-size: 18px;">Thank you for registering for the 2024 AR Fundraising Golf Event. Your support means a lot to us and will contribute to the AR scholarship fund. </span></p><p><br></p><p><span style="font-size: 18px;">We look forward to seeing you on the Golf Course!!</span></p><p><br></p><p><span style="font-size: 18px;">A confirmation email with the details of your registration has been sent to the provided email address. If you have any questions or need further assistance, please contact us at [Contact Email/Phone].</span></p>','Thank You for Registering!','','Event Cost','Event Charges','Total','500.0','Payments Received','<p><span style="font-size: 18px;">For inquiries, please contact [Your Contact Person] at [Your Contact Email/Phone].</span></p><p><br></p>','<p style="text-align: center;"><span style="font-size: 18px;">We would like to express our heartfelt gratitude to everyone who participated in and supported the 2024 AR Fundraising Golf Event. Your enthusiasm, generosity, and commitment have made this event a tremendous success.</span></p><p style="text-align: center;"><br></p><p><strong style="font-size: 18px;">Highlights of the Event:</strong></p><ul><li><span style="font-size: 18px;">A day filled with camaraderie, sportsmanship, and support for the AR scholarship fund.</span></li><li><span style="font-size: 18px;">[Insert any notable achievements, highlights, or special moments from the event.]</span></li></ul><p><br></p><p><strong style="font-size: 18px;">Fundraising Update:</strong></p><p><span style="font-size: 18px;">Thanks to your contributions, we have made significant strides towards our fundraising goal. Every dollar raised will directly impact the education and opportunities provided to students in the field of augmented reality.</span></p><p><br></p><p><strong style="font-size: 18px;">Acknowledgments:</strong></p><p><span style="font-size: 18px;">We extend our gratitude to our sponsors, volunteers, and all participants who dedicated their time and resources to make this event possible. Your involvement has a lasting impact on the future of augmented reality and the aspiring individuals we aim to support.</span></p><p><br></p><p><strong style="font-size: 18px;">Stay Connected:</strong></p><p><span style="font-size: 18px;">Although the event has come to a close, our commitment to the AR scholarship fund continues. Stay connected with us on [Your Social Media Channels] and our website for updates on the impact of your contributions and upcoming initiatives.</span></p><p><br></p><p><span style="font-size: 18px;">Once again, thank you for being an integral part of the 2024 AR Fundraising Golf Event. Your support is invaluable, and we look forward to seeing you again at future endeavors.</span></p><p><br></p>','Additional Guests/Golfers','Event Home','','Sample - 2024 AR Golf Event','','Payment Due','','Payment Received','2024 Golf Event','','Active','<p><span style="font-size: 18px; color: rgb(68, 68, 68);">Please review the information below. Should you need to make changes, hit the previous button.</span></p>','Review your Registration','Fundraising','<p style="text-align: center;"><strong style="font-size: 28px;">Annual Fundraising Golf Event</strong></p><p style="text-align: center;"><br></p><p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/golf1.jpg" alt="Indian Boundary Golf Course | Golf Courses Chicago Illinois"></img></p><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="font-size: 18px;">Join us for an exciting day of golf and philanthropy at the 2024 AR Fundraising Golf Event. This event is dedicated to raising funds for the AR (Augmented Reality) scholarship fund, supporting students who are passionate about the future of augmented reality technology.</span></p><p><br></p><p><strong style="font-size: 18px;">Agenda:</strong></p><ul><li><span style="color: rgb(68, 68, 68); background-color: rgb(255, 255, 255); font-size: 18px;">8:00 AM - </span><span style="font-size: 18px;">Registration</span></li><li><span style="color: rgb(68, 68, 68); background-color: rgb(255, 255, 255); font-size: 18px;">9:00 AM - </span><span style="font-size: 18px;">Welcome &amp; Briefing</span></li><li><span style="color: rgb(68, 68, 68); background-color: rgb(255, 255, 255); font-size: 18px;">9:30 AM - </span><span style="font-size: 18px;">Shotgun Start</span></li><li><span style="color: rgb(68, 68, 68); background-color: rgb(255, 255, 255); font-size: 18px;">12:00 PM - </span><span style="font-size: 18px;">Lunch Break</span></li><li><span style="color: rgb(68, 68, 68); background-color: rgb(255, 255, 255); font-size: 18px;">4:00 PM - </span><span style="font-size: 18px;">Happy Hour Social &amp; Silent Auction</span></li><li><span style="color: rgb(68, 68, 68); background-color: rgb(255, 255, 255); font-size: 18px;">5:00 PM - </span><span style="font-size: 18px;">Award Ceremony &amp; Dinner</span></li></ul><p><br></p><p><strong style="font-size: 18px;">Golf Format:</strong></p><p><span style="font-size: 18px;">The event will follow a [Insert Golf Format - e.g., Scramble] format, ensuring an enjoyable experience for golfers of all skill levels.</span></p><p><br></p><p><strong style="font-size: 18px;">Registration Fee:</strong></p><ul><li><span style="font-size: 18px;">Individual Player: $150 </span><a href="https://www.google.com/" target="_blank" style="font-size: 18px;">(Click Here for Individual Registration)</a><span style="font-size: 18px;">[Hyperlink to other instance]</span></li><li><span style="font-size: 18px;">Team (4 players): $500</span></li></ul><p><br></p><p><strong style="font-size: 18px;">What&#39;s Included:</strong></p><ul><li><span style="font-size: 18px;">18 Holes of Golf</span></li><li><span style="font-size: 18px;">Golf Cart</span></li><li><span style="font-size: 18px;">Event T-Shirt</span></li><li><span style="font-size: 18px;">Lunch and Dinner</span></li></ul><p><br></p><p><strong style="font-size: 18px;">Additional Activities:</strong></p><ul><li><span style="font-size: 18px;">Silent Auction: Bid on exclusive items and experiences.</span></li><li><span style="font-size: 18px;">Networking: Connect with professionals and enthusiasts in the AR industry.</span></li><li><span style="font-size: 18px;">Raffle: Exciting prizes up for grabs!</span></li></ul><p><br></p><p><strong style="font-size: 18px;">Dress Code:</strong></p><p><span style="font-size: 18px;">Please adhere to a golf-appropriate dress code. Collared shirts, golf shoes, and slacks are recommended.</span></p><p><br></p><p><strong style="font-size: 18px;">Contact Information:</strong></p><p><span style="font-size: 18px;">For inquiries, please contact [Your Contact Person] at [Your Contact Email/Phone].</span></p><p><br></p><p><em style="font-size: 18px;">Note: All proceeds from this event will go directly to the AR scholarship fund, fostering the education and innovation of future leaders in augmented reality.</em></p><p><br></p><p><span style="font-size: 18px;">We look forward to your participation and support in making the 2024 AR Fundraising Golf Event a memorable success!</span></p>','Register','All Websites','All Websites','First Name','Gender','3.0','Add Golfer','<p><strong style="font-size: 18px;">Adding Additional Golfers:</strong></p><ul><li><span style="font-size: 18px;">To register additional golfers, indicate their information below. You can add up to 3 additional golfers for the cost of a group registration. If you register less than 3, you&#39;ll be added to another team to equal 4 total players. We&#39;ll ensure they are included in the event communications and assigned to your team.</span></li></ul><p><strong style="font-size: 18px;">Adding Guests for Dinners:</strong></p><ul><li><span style="font-size: 18px;">If you&#39;ve registering as an individual and would like to bring guests for the dinner and award ceremony, please indicate and share that information below. This allows us to make the necessary arrangements for a memorable dining experience.</span></li><li><span style="font-size: 18px;">No additional cost for those attending dinner.</span></li></ul><p><span style="font-size: 18px;"><span class="ql-cursor">﻿</span></span></p><p><em style="font-size: 18px;">NOTE: All registered individuals are welcome to attend Dinner and the Award Ceremony at no additional cost.</em></p>','Register Additional Guests and Golfers','','False','Cancel','Continue','You have unsaved Golfer information entered. Select Cancel to finish adding your guests.','Touchpoint','False','Labels as headers','Appointment_Title__c','Appointment_Time_Formatted__c','','','','Agenda Item','Time','','','','','','','','False','Last Name As Student','Last Name','','','','','2231 S Harrison Rd, East Lansing, MI 48823','https://maps.app.goo.gl/Fnq3GmPdETEYDR4m6','Forrest Akers East','','Registrant Address','','Sample - 2024 AR Golf Event','No Additional Golfers Added','Make Payment','No Gateway','','Match with most recently modified','Create Person Account','','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','One registration per instance','Relationship (select all that apply)','2025-11-07','GeneralSLDS','I am...','Title','','','','','','True','','We are sorry. Your registration cannot be completed at this time. Please try again using a different browser or device.','','Summit_Events_Fee_Allocation__c-11','','','','','','Summit_Events_Fee_Allocation__c-3');
INSERT INTO "Summit_Events__c" VALUES('Summit_Events__c-10','','','','Please indicate your accessibility request below.','Do you have any accessibility needs for this event?','','','','','','','','','','','','','','','','','','','','','False','','Application Type','Do not ask','Do not ask','Ask','Do not ask','Do not ask','Do not ask','False','Do not ask','Ask','Ask mobile and require','Do not ask','Do not ask','Ask','Do not ask','Do not ask','','Ask','General Public','','0.0','','Company or Organization','Standard Contact Duplicate Rule','Full matching contact creation with duplicate management','Match with most recently modified','Create Contact','Use Salesforce Duplicate Rule','Green','','','Date of Birth','Do you have any dietary restrictions?','True','True','True','<p>If you&#39;d like to directly support our work before the gala, you can do so here. Thank you for helping us continue our mission!</p>','50','Additional Donation','Email','2026-11-10','','','Selected options','','Once you have made your selections click next.','','','Choose your options','','','','<p><span style="font-size: 16px;">You will receive an email confirmation. If you have any questions or concerns, please do not hesitate to reach out to </span><span style="color: rgb(3, 45, 96); font-size: 16px;">j.doe@givinghope.org.</span></p><p><br></p><p><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/e74b3a71bb11c14d7ea71da1a016e2a3bfc88d7d/evt-img/gala-thank-you.png" alt="12 Ways to Say “Thank You” With Examples | Grammarly"></img></p>','We look forward to seeing you at A Night of Giving Hope 2024!','','Event Cost','Event Charges','Total','200.0','Payments Received','<p>For Additional Details or questions, contacts us at gala@summit.demo</p>','','Register your guest(s).','Event Home','','Sample - Gala Fundraising Event','','Payment Due','','Payment Received','','','Active','<p><br></p><p><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Gala-Fundraising-event-Ticket.jpg" alt="Picture of a ticket"></img></p><p><br></p><p><strong style="font-size: 16px;">Ticket Information:</strong></p><ul><li><span style="font-size: 16px;">Individual Ticket: $200</span></li><li><span style="font-size: 16px;">Couple Ticket: $350</span></li><li><span style="font-size: 16px;">Corporate Table (Seats 5): $5,000</span></li><li><span style="font-size: 16px;">Corporate Table (Seats 10): $10,000</span></li></ul><p><span style="font-size: 16px;">﻿</span></p><p><span style="font-size: 16px;">Your ticket includes dinner, entertainment, and the chance to be a part of a night dedicated to making the world a better place. Reserve your place now, and together, let&#39;s create a future filled with hope, love, and opportunity for all. Your support can change lives, and this gala is your chance to make it happen.</span></p>','Complete your Registration','Fundraising','<p style="text-align: center;"><strong style="font-size: 18px;">We&#39;re very excited to invite you to join us for an enchanting evening of elegance, compassion, and generosity at our &quot;A Night of Giving Hope&quot; Gala Fundraising Event. This fun event is your opportunity to make a meaningful difference in the lives of those in need while enjoying an unforgettable night of entertainment, gourmet dining, and socializing!</strong></p><p><br></p><p style="text-align: center;"><img src="https://raw.githubusercontent.com/SFDO-Community-Sprints/summit-events-app-documentation/main/evt-img/Gala-Fundraising-Table.jpg" alt="galatable-2019-May15-1 (1).jpeg"></img></p><p><br></p><p><strong style="font-size: 18px;">Event Highlights:</strong></p><ul><li><span style="font-size: 18px;">Dining: Savor a variety of gourmet bites prepared by local fan-favorite restaurants, accompanied by an open bar with a variety of drink options (and a delicious cocktail of the night!).</span></li><li><span style="font-size: 18px;">Silent Auction: Bid on an array of exclusive items, including art, luxury experiences, and unique memorabilia, with all proceeds going toward our cause.</span></li><li><span style="font-size: 18px;">Fundraising Activities: Participate in various fundraising activities, from pledging to donation stations, to directly impact the lives of those we serve.</span></li><li><span style="font-size: 18px;">Impact Showcase: Witness firsthand how your contributions are making a difference through touching stories and presentations from our beneficiaries.</span></li><li><span style="font-size: 18px;">Networking Opportunities: Connect with fellow philanthropists, community leaders, and our dedicated team who share your passion for making a positive impact.</span></li></ul><p><strong style="font-size: 18px;">Dress Code: Cocktail Attire</strong></p><p><br></p><p><span style="font-size: 18px;">Your presence at this gala will not only make the evening extraordinary but will also help us continue our mission to impact the lives of youth all around Chicago. Every dollar raised during this event will go towards free extracurricular activities for Chicago schools that need them, bringing us one step closer to our vision of a better, brighter future.</span></p>','Register','','','First Name','Gender','','Register Guest','<p>It&#39;s even more fun with family and friends! Please fill out the information below for your guests. If you are interested in buying a table for 5 or 10 people, please email j.doe@givinghope.org.</p>','Bring a guest! Or even better, multiple guests.','','False','Cancel','Continue','You have unsaved Guest information entered. Select Cancel to finish adding your guests.','Touchpoint','False','','','','','','','','','','','','','','','','True','Last Name As Student','Last Name','','','','','3057 N Rockwell S','https://maps.app.goo.gl/PP4WNqeHwv7bGNFj9','Rockwell on the River','On-Site','Registrant Address','','Sample - Gala Fundraising Event','','Make Payment','No Gateway','','Match with most recently modified','Create Person Account','','Please provide either a home or mobile number','Type','Preferred Class Year','Preferred First Name','False','','','','Pronouns','I am willing to receive text messages on my mobile phone about this event','Your relationship to the participant','No limit','Relationship (select all that apply)','2025-10-10','GeneralSLDS','I am...','Title','','','','','','True','','We are sorry. Your registration cannot be completed at this time. Please try again using a different browser or device.','','Summit_Events_Fee_Allocation__c-4','','','','','','Summit_Events_Fee_Allocation__c-6');
COMMIT;
