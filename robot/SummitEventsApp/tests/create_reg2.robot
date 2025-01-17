*** Settings ***

Resource        cumulusci/robotframework/Salesforce.robot
Suite Setup     Open test browser
Suite Teardown    Close Browser

*** Variables ***
${instance_id}

*** Test Cases ***
Create_SEA_reg

    #Query for the an SEA instance Id to test upon
    @{records}=  Salesforce Query  Summit_Events_Instance__c  select=Id,Name
    ...          Event__r.Name=Sample - Open Source Sprint Event - Single Step
    ...          Instance_Title__c=In-Person
    ...          limit=1
    FOR  ${record}  IN  @{records}
        log  Name: ${record['Name']} Id: ${record['Id']}
    END

    #Assign found instance Id to global variable
    ${instance_id}    Set Variable    ${record}[Id]

    #Open the registration page for the instance
    Go To Registration Page For Instance    ${instance_id}
    
    #Create fake data for the registration form
    ${first_name}=       Get fake data    first_name
    ${last_name}=        Get fake data    last_name
    ${email}=            Get fake data    ascii_email
    ${phone}=            Get fake data    phone_number
    ${day_of_week}=      Get fake data    day_of_week

    #Fill out the registration form
    Input form data
    ...    First Name         ${first_name}
    ...    Last Name          ${last_name}
    ...    Email              ${email}
    ...    Please provide either a home or mobile number       ${phone}
    ...    What is your GitHub username?    GITHUB_${last_name}
    ...    What is your Slack email - to stay connected?    SLACK_${last_name}

    #Submit the registration form
    SeleniumLibrary.Click Link   Register

    @{reg_record}=  Salesforce Query  Summit_Events_Registration__c  select=Id,Name,Registrant_First_Name__c,Registrant_Last_Name__c,Registrant_Email__c
    ...          Event_Instance__c=${Record}[Id]
    ...          Registrant_First_Name__c=${first_name}
    ...          Registrant_Last_Name__c=${last_name}
    ...          Registrant_Email__c=${email}
    ...          limit=1
    FOR  ${reg_record}  IN  @{reg_record}
        log  Name: ${reg_record['Name']} Id: ${reg_record['Id']}
    END

    #Validate the registration record
    Should Be Equal As Strings  ${reg_record}[Registrant_First_Name__c]  ${first_name}
    Should Be Equal As Strings  ${reg_record}[Registrant_Last_Name__c]  ${last_name}
    Should Be Equal As Strings  ${reg_record}[Registrant_Email__c]  ${email}

*** Keywords ***
Go To Registration Page For Instance
    [Arguments]      ${instance_id}
    &{instance}=     Salesforce Get  Summit_Events_Instance__c  ${instance_id}
    &{event}=        Salesforce Get  Summit_Events__c  ${instance}[Event__c]
    ${url}=          Catenate        SEPARATOR=  ${event}[Community_Base_URL__c]  SummitEventsRegister?instanceID=  ${instance_id}
    Go To            ${url}