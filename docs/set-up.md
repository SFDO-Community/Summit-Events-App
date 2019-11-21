# Setting up UST Event app in salesforce

## Create a site

If your org does not already have a site to display public visual force pages you will need to set one up.

1. Open the org you are working on in the browser

   ```bash 
   cci org browser <org_name> 
   ```
   
2. In Setup go to User Interface -> Sites and Domains -> Sites
3. Select a subdomain that is available. Since you are spinning up scratch orgs you may want to start incrementing a subdomain on a theme (myevents0001...myevents0002).
4. Click "Register My Salesforce Site Domain"

## Automate the Rest of the Site Setup
If you are spinning up a **scratch org for development purposes** then setup just got easier for you. Just enter the following command:

```bash
cci flow run config_site --org <org_name>
```

For **production environments** you may want to manually set up your org to finely tune your permissions and sites. Use the following instructions.

## Create a site record

After the subdomain is finished registering create a new site record, by clicking the "New" button next to the site header. Fill in the following data and then click "Save."

1. In Setup go to User Interface -> Sites and Domains -> Sites
2. Click the "New" button next to the site header
3. Enter the following data in the form
    * Site Label: UST Events
    * Site Name: UST_Events
    * Active Site Home Page:
        * Select the magnifying glass look-up icon and in the dialog select USTEvent
    * Leave all other settings at their defaults
4. Click "Save"
5. Click the "Active" link under Action next to the site you just created
6. Right click on the site URL and copy the URL to your clipboard. You will need it in the next stage of installation.

## Set Custom Settings

Since each installation can have a different site URL we need to define that URL for the event application to use as it's root web presence. This is used for feed URLs for external sites to access and a host of other things.

1. In Setup go to User Custom Code -> Custom Settings

2. Click on the "Manage" link for the custom setting "UST Event Settings"

3. Click "New" button just before the "Default Organization Level Value." There are two "New" buttons on the page. You will know you are on the wrong one if you are asked to assign a user or a profile. You should only need to enter the URL in the follow step.

4. From step 6 in the "Create a site record" use the URL you copied there and enter it into the Community Based URL field.

5. Click "Save"

6. Once you hit "Save" the "New" button will be replaced with "Edit." This is what you will need to hit to make future adjustments to this setting.

## Setting up site permissions

Why is there so many permissions to set? After setting up the Salesforce Site a public profile is created for that site to moderate all access by users not logged into a community (The guest public). Unfortunately, it is [not possible to apply a permission set to a public user](https://success.salesforce.com/ideaView?id=08730000000akDJAAY). If this were possible much of the headache below could be mitigated so up-vote the previous link.

1. In Setup go to User Interface -> Sites and Domains -> Sites

2. Click on the site label of the active site you defined earlier and using as the base for the Event App. (example: "UST Events")

3. Click on the "Public Access Settings" button at the top of the record.

### Setup Visualforce Page and Apex Classes Public Access

1. Go to the "Enabled Visual Force Pages" (or Visualforce Page Access depending on your Admin view) heading and click on the "Edit" button. Make sure the following pages are enabled and then click "Save":
    > USTEvent
    > USTEventAddToCalendar
    > USTEventCancelReview
    > USTEventConfirmation
    > USTEventParkingPass
    > USTEventRegister
    > USTEventRegistrationOptions
    > USTEventSubmit

2. Got to the "Enabled Apex Class Access" heading and click on the "Edit" button. Make sure the following Apex Classes are in the "Enabled Apex Classes" list and then click "Save":
    > USTEventFeed
    > USTRestAdmissions

### Setup Object Field Permissions for Public Access

1. Find the "Field-Level Security" header and then find the **UST Event** object. You will need to set up permissions for each field in the object to allow public users (non-logged in) to be able to register and see events. Set the following field level permissions:

    Object permissions should have "Read" and "View All" enabled.

    | Field Name                         |  Field Type      | Read | Edit |
    |------------------------------------|:----------------:|:----:|-----:|
    | Academic Program List              | Picklist         |      |      |
    | Academic Program List Selected     | Long Text Area   |      |      |
    | Add Info Question Pick List 1      | Text Area        | X    |      |
    | Add Info Question Pick List 2      | Text Area        | X    |      |
    | Add Info Question Pick List 3      | Text Area        | X    |      |
    | Add Info Question Pick List 4      | Text Area        | X    |      |
    | Add Info Question Pick List 5      | Text Area        | X    |      |
    | Add Info Question Text 1           | Text Area        | X    |      |
    | Add Info Question Text 2           | Text Area        | X    |      |
    | Add Info Question Text 3           | Text Area        | X    |      |
    | Add Info Question Text 4           | Text Area        | X    |      |
    | Add Info Question Text 5           | Text Area        | X    |      |
    | Add Info Question Type 1           | Picklist         | X    |      |
    | Add Info Question Type 2           | Picklist         | X    |      |
    | Add Info Question Type 3           | Picklist         | X    |      |
    | Add Info Question Type 4           | Picklist         | X    |      |
    | Add Info Question Type 5           | Picklist         | X    |      |
    | Allow Other Attendees              | Checkbox         | X    |      |
    | Alternate Registration             | URL              | X    |      |
    | Applicant Type                     | Picklist         | X    |      |
    | Ask Date Of Birth                  | Checkbox         | X    |      |
    | Ask Gender                         | Picklist         | X    |      |
    | Ask Gender                         | Picklist         | X    |      |
    | Ask If Parent                      | Checkbox         | X    |      |
    | Ask Mailing Address                | Checkbox         | X    |      |
    | Ask Phone                          | Checkbox         | X    |      |
    | Ask Program Interest               | Checkbox         | X    |      |
    | Ask Registrant Program Of Interest | Picklist         | X    |      |
    | Audience                           | Multi-Select     | X    |      |
    | Building                           | Picklist         | X    |      |
    | Close Event Days Before            | Number           | X    |      |
    | College High School Ask            | Picklist         | X    |      |
    | Community Base URL                 | Text             | X    |      |
    | Created By                         | Lookup           | X    |      |
    | End Date                           | Date             | X    |      |
    | Event Appointment Description      | Rich Text Area   | X    |      |
    | Event Appointment Title            | Text Area        | X    |      |
    | Event Cancelled Notification Text  | Text Area        | X    |      |
    | Event Cancel Review Description    | Rich Text Area   | X    |      |
    | Event Cancel Review Title          | Text             | X    |      |
    | Event Confirmation Description     | Rich Text Area   | X    |      |
    | Event Confirmation Title           | Text             | X    |      |
    | Event Description                  | Rich Text Area   | X    |      |
    | Event Footer                       | Rich Text Area   | X    |      |
    | Event Home Link Title              | Text             | X    |      |
    | Event Home Link URL                | Text             | X    |      |
    | Event Instance Feed URL            | Text             | X    |      |
    | Event Is Full Display Text         | Rich Text Area   | X    |      |
    | Event Label                        | Text             | X    |      |
    | Event Name                         | Text             | X    |      |
    | Event Short Listing Description    | Long Text Area   | X    |      |
    | Event Sponsor                      | Multi-Select     | X    |      |
    | Event Status                       | Picklist         | X    |      |
    | Event Submit Description           | Rich Text Area   | X    |      |
    | Event Submit Title                 | Text             | X    |      |
    | Event Type                         | Picklist         | X    |      |
    | Feed Registration Button Text      | Text             | X    |      |
    | Include Time frame List            | Checkbox         | X    |      |
    | Last Modified By                   | Lookup           | X    |      |
    | Location Address                   | Text             | X    |      |
    | Location Map Link                  | Text             | X    |      |
    | Location Title                     | Text             | X    |      |
    | Location Type                      | Picklist         | X    |      |
    | Max Other Attendees                | Number           | X    |      |
    | Owner                              | Lookup           | X    |      |
    | Portal Login Required              | Checkbox         | X    |      |
    | Private Event                      | Checkbox         | X    |      |
    | Program Filter                     | Text Area        | X    |      |
    | Program Filter 2                   | Text             | X    |      |
    | Program Filter 3                   | Text             | X    |      |
    | Record Type                        | Record Type      | X    |      |
    | Start Date                         | Date             | X    |      |
    | Template                           | Picklist         | X    |      |
    | Tracking Cancel Registration       | Long Text Area   | X    |      |
    | Tracking Confirmation Registration | Long Text Area   | X    |      |
    | Tracking Event Registration        | Long Text Area   | X    |      |
    | Tracking Options Registration      | Long Text Area   | X    |      |
    | Tracking Submit Registration       | Long Text Area   | X    |      |

2. Find the "Field-Level Security" header and then find the **UST Event Instance** object. Set the following field level permissions:
    
    Object permissions should have "Read" and "View All" enabled.
    
    | Field Name                             |  Field Type   | Read | Edit |
    |----------------------------------------|:-------------:|:----:|-----:|
    | Active Status                          | Picklist      | X    |      |
    | Admin Open Registration Link           | Text          | X    |      |
    | Admin Open Registration Link           | Text          | X    |      |
    | Alternate Registration URL Override    | URL           | X    |      |
    | Attendee List                          | Checkbox      | X    |      |
    | Banner Event Code                      | Text          |      |      |
    | Banner Event Function Code             | Text          |      |      |
    | Building Override                      | Picklist      | X    |      |
    | Capacity                               | Number        | X    |      |
    | Category                               | Multi-Select  | X    |      |
    | Confirmed Attendees                    | Number        |      |      |
    | Count of Attendees                     | Number        |      |      |
    | Created By                             | Lookup        | X    |      |
    | Current Available Capacity             | Number        | X    |      |
    | End Date/Time                          | Date/Time     | X    |      |
    | Event                                  | Lookup        | X    |      |
    | Event Instance                         | Auto Number   | X    |      |
    | Event Name                             | Text          | X    |      |
    | Feed Registration Button Text Override | Text          | X    |      |
    | Instance Short Description             | Text          | X    |      |
    | Instance Title                         | Text          | X    |      |
    | Last Modified By                       | Lookup        | X    |      |
    | Location Address Override              | Text          | X    |      |
    | Location Map Link Override             | Text          | X    |      |
    | Location Title Override                | Text          | X    |      |
    | Location Type Override                 | Picklist      | X    |      |
    | Primary Attendees                      | Number        |      |      |
    | Primary Confirmed Attendees            | Number        |      |      |
    | Registration Link                      | Text          | X    |      |
    | Start Date/Time                        | Date/Time     | X    |      |

3. Find the "Field-Level Security" header and then find the **UST Event Registration** object. Set the following field level permissions

    Object permissions should have "Read," "Create," and "Edit" enabled.

    | Field Name                             |  Field Type    | Read | Edit |
    |----------------------------------------|:--------------:|:----:|:----:|
    | Actual Number of Guests                | Number         | X    | X    |
    | Add Info Answer 1                      | Long Text Area | X    | X    |
    | Add Info Answer 2                      | Long Text Area | X    | X    |
    | Add Info Answer 3                      | Long Text Area | X    | X    |
    | Add Info Answer 4                      | Long Text Area | X    | X    |
    | Add Info Answer 5                      | Long Text Area | X    | X    |
    | Add Info Question 1                    | Text           | X    | X    |
    | Add Info Question 2                    | Text           | X    | X    |
    | Add Info Question 3                    | Text           | X    | X    |
    | Add Info Question 4                    | Text           | X    | X    |
    | Add Info Question 5                    | Text           | X    | X    |
    | Add To Calendar Link                   | Text           | X    | X    |
    | Appointment Table                      | Long Text Area | X    |      |
    | Campus Event Registration              | Auto Number    | X    | X    |
    | Campus Tour Location                   | Picklist       |      |      |
    | Campus Tour Time                       | Text           |      |      |
    | Confirmation Call Result               | Picklist       |      |      |
    | Contact                                | Lookup         |      |      |
    | Contact Name                           | Text           |      |      |
    | Contact PIDM                           | Number         |      |      |
    | Contact Soft Match Email               | Text           |      |      |
    | Contact Soft Match First Last Zip      | Text           |      |      |
    | Created By                             | Lookup         | X    |      |
    | Date                                   | Date           | X    |      |
    | Date/Time Text                         | Text           | X    |      |
    | Date All Appointments Confirmed        | Date           |      |      |
    | Display Attendance Publicly            | Checkbox       | X    |      |
    | End Time Text                          | Text           | X    |      |
    | Event                                  | Lookup         | X    |      |
    | Event Instance                         | Lookup         | X    |      |
    | Event Instance Date                    | Date           | X    |      |
    | Event Instance Name                    | Text           | X    |      |
    | Event Instance Title                   | Text           | X    |      |
    | Event Name                             | Text           | X    |      |
    | Event Registration Cancel Link         | Text           | X    |      |
    | Generated Itinerary                    | Long Text Area | X    |      |
    | Generated Requested Appointments       | Long Text Area | X    |      |
    | Instance                               | Picklist       | X    |      |
    | Instance Title                         | Text           | X    |      |
    | Last Modified By                       | Lookup         | X    |      |
    | Last Name as Student                   | Text           | X    | X    |
    | Location Address                       | Text           | X    |      |
    | Location Map Link                      | Text           | X    |      |
    | Location Title                         | Text           | X    |      |
    | Matching Log                           | Rich Text Area |      |      |
    | New Contact Created                    | Checkbox       |      |      |
    | Number of Guests                       | Number         | X    | X    |
    | Participation Type                     | Multi-Select   |      |      |
    | Preferred First Name Formatted         | Text           | X    |      |
    | Preferred St. Thomas Class Year        | Text           | X    | X    |
    | Preferred Visit Time                   | Picklist       | X    | X    |
    | Presentation Location                  | Picklist       | X    | X    |
    | Presentation Time                      | Text           | X    |      |
    | Registrant Applicant Type              | Picklist       | X    | X    |
    | Registrant City                        | Text           | X    | X    |
    | Registrant College                     | Text           | X    | X    |
    | Registrant College Code                | Text           | X    | X    |
    | Registrant College Not Found           | Text           | X    | X    |
    | Registrant College Year                | Text           | X    | X    |
    | Registrant Date of Birth               | Date           | X    | X    |
    | Registrant Do Not Call                 | Checkbox       | X    | X    |
    | Registrant Email                       | Email          | X    | X    |
    | Registrant First Name                  | Text           | X    | X    |
    | Registrant Gender                      | Picklist       | X    | X    |
    | Registrant High School                 | Text           | X    | X    |
    | Registrant High School Code            | Text           | X    | X    |
    | Registrant High School Grad Year       | Text           | X    | X    |
    | Registrant High School Not Found       | Text           | X    | X    |
    | Registrant Last Name                   | Text           | X    | X    |
    | Registrant Mobile Phone                | Phone          | X    | X    |
    | Registrant Parent Email                | Email          | X    | X    |
    | Registrant Parent First Name           | Text           | X    | X    |
    | Registrant Parent Last Name            | Text           | X    | X    |
    | Registrant Parent Phone                | Phone          | X    | X    |
    | Registrant Parent Status               | Picklist       | X    | X    |
    | Registrant Phone                       | Phone          | X    | X    |
    | Registrant Preferred First Name        | Text Area      | X    | X    |
    | Registrant Program Interest            | Multi-Select   | X    | X    |
    | Registrant Receive Texts               | Checkbox       | X    | X    |
    | Registrant State                       | Text           | X    | X    |
    | Registrant Street 1                    | Text           | X    | X    |
    | Registrant Street 2                    | Text           | X    | X    |
    | Registrant Zip                         | Text           | X    | X    |
    | Relationship to St. Thomas             | Multi-Select   | X    | X    |
    | Reminder Call Complete?                | Checkbox       | X    | X    |
    | Session                                | Picklist       | X    | X    |
    | Start Time Text                        | Text           | X    |      |
    | Status                                 | Picklist       |      |      |
    | Substatus                              | Picklist       |      |      |
    | Total Appointments                     | Number         |      |      |
    | Total Confirmed Appointments           | Number         |      |      |
    | Total Number of Guests                 | Number         |      |      |
    | UG Parking Pass Link                   | Text           | X    |      |

4. Find the "Field-Level Security" header and then find the **UST Event Appointments** object. Set the following field level permissions:

    Object permissions should have "Read," "Create," "Edit," and "Delete" enabled.
    
    | Field Name                       |  Field Type    | Read | Edit |
    |----------------------------------|:--------------:|:----:|:----:|
    | Appointment Category             | Picklist       | X    | X    |
    | Appointment Contact Email        | Email          | X    | X    |
    | Appointment Contact Name         | Text           | X    | X    |
    | Appointment Date                 | Date           | X    | X    |
    | Appointment Date/Time            | Date/Time      | X    | X    |
    | Appointment Detail               | Long Text Area | X    | X    |
    | Appointment Status               | Picklist       | X    | X    |
    | Appointment Time                 | Time           | X    | X    |
    | Appointment Time Formatted       | Text           | X    | X    |
    | Appointment Time Options         | Multi-Select   | X    | X    |
    | Appointment Title                | Text           | X    | X    |
    | Appointment Type                 | Picklist       | X    | X    |
    | Building                         | Picklist       | X    | X    |
    | Chosen State                     | Picklist       | X    | X    |
    | Class Title                      | Text           | X    | X    |
    | Client Created Appointment       | Checkbox       | X    | X    |
    | Contact                          | Text           | X    |      |
    | Created By                       | Lookup         | X    |      |
    | Description                      | Rich Text Area | X    | X    |
    | Do Not Show Time                 | Checkbox       | X    | X    |
    | Event Appointments Name          | Auto Number    | X    | X    |
    | Event Appointment Type           | Lookup         | X    | X    |
    | Event Host                       | Lookup         | X    |      |
    | Event Reg ID                     | Text           | X    |      |
    | Event Registration               | Lookup         | X    | X    |
    | Event Registration Date          | Text           | X    |      |
    | Faculty/Staff Member             | Text           | X    |      |
    | Host Location                    | Text           | X    |      |
    | Host Name                        | Text           | X    |      |
    | Last Modified By                 | Lookup         | X    |      |
    | Record Type                      | Record Type    | X    | X    |
    | Registrant Input                 | Text           | X    | X    |
    | Room                             | Text           | X    |      |
    | Sort Order                       | Number         | X    | X    |
    | UG Appointment Category Order    | Number         | X    |      |

5. Find the "Field-Level Security" header and then find the **UST Event Appointment Types** object. Set the following field level permissions:
    
    Object permissions should have "Read" and "View All" enabled.
    
    | Field Name                 |  Field Type    | Read | Edit |
    |----------------------------|:--------------:|:----:|:----:|
    | Appointment Category       | Picklist       | X    |      |
    | Appointment Limits         | Picklist       | X    |      |
    | Appointment Type           | Picklist       | X    |      |
    | Appointment Type Status    | Picklist       | X    |      |
    | Auto add building          | Picklist       | X    |      |
    | Auto Add Time              | Time           | X    |      |
    | Auto Confirm Appointment   | Checkbox       | X    |      |
    | Chosen State               | Picklist       | X    |      |
    | Created By                 | Lookup         | X    |      |
    | Custom Picklist            | Long Text Area | X    |      |
    | Date Available End         | Date/Time      | X    |      |
    | Date Available Start       | Date/Time      | X    |      |
    | Day of Week Availability   | Multi-Select   | X    |      |
    | Description                | Rich Text Area | X    |      |
    | Do Not Show Time           | Checkbox       | X    |      |
    | Event	                     | Lookup         | X    |      |
    | Last Modified By           | Lookup         | X    |      |
    | Registrant Input           | Picklist       | X    |      |
    | Required Appointment       | Checkbox       | X    |      |
    | Restrict To Instance Title | Lookup         | X    |      |
    | Sort Order                 | Number         | X    |      |
    | Title                      | Text           | X    |      |
    | UG Event Appointment Type  | Auto Number    | X    |      |
    
6. Find the "Field-Level Security" header and then find the **UST Event Emails** object. Set the following field level permissions:

    Object permissions should have "Read" and "View All" enabled.
    
    | Field Name                 |  Field Type    | Read | Edit |
    |----------------------------|:--------------:|:----:|:----:|
    | Action Status              | Picklist       | X    |      |
    | Action Sub status          | Picklist       | X    |      |
    | BCC Email                  | Long Text Area | X    |      |
    | Created By                 | Lookup         | X    |      |
    | Email Content              | Rich Text Area | X    |      |
    | Email Content Instructions | Long Text Area | X    |      |
    | Email From                 | Text           | X    |      |
    | Email Subject              | Text           | X    |      |
    | Event                      | Lookup         | X    | X    |
    | Last Modified By           | Lookup         | X    |      |
    | Letterhead                 | Picklist       | X    |      |
    | Letterhead HTML            | Long Text Area | X    |      |
    | Letterhead Id              | Text           | X    |      |
    | Letterhead Name            | Text           | X    |      |
    | Org Email                  | Email          | X    |      |
    | Org Email Id               | Text           | X    |      |
    | UST Event Email Name       | Auto Number    | X    |      |
    
7. Find the "Field-Level Security" header and then find the **UST Event Hosts** object. Set the following field level permissions:

    Object permissions should have "Read" and "View All" enabled.
    
    | Field Name             |  Field Type | Read | Edit |
    |------------------------|:-----------:|:----:|:----:|
    | Additional Comments    | Text Area   | X    |      |
    | Assigned               | Number      | X    | X    |
    | Building               | Picklist    | X    |      |
    | Contact                | Lookup      | X    |      |
    | Course Name            | Text        | X    |      |
    | Created By             | Lookup      | X    |      |
    | Department             | Text        | X    |      |
    | First Name             | Text        | X    |      |
    | Formatted Time         | Text        | X    |      |
    | Gender                 | Picklist    | X    |      |
    | Last Modified By       | Lookup      | X    |      |
    | Last Name              | Text        | X    |      |
    | Location               | Text        | X    |      |
    | Max Available          | Number      | X    |      |
    | Preferred Title        | Text        | X    |      |
    | Record Type            | Record Type | X    | X    |
    | Remaining              | Number      | X    |      |
    | Time                   | Time        | X    |      |
    | Undergrad Major        | Picklist    | X    |      |
    | UST Event Host Name    | Auto Number | X    |      |
    | UST Event Instance     | Lookup      | X    | X    |
