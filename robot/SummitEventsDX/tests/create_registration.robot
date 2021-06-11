*** Settings ***

Resource        cumulusci/robotframework/Salesforce.robot

Suite Setup     Open Summit Test Browser
# Suite Teardown  Delete Records and Close Browser

*** Variables ***
${instance_id} =    a061700000AjxFw

*** Test Cases ***

Via UI
    ${first_name}=       Get fake data    first_name
    ${last_name}=        Get fake data    last_name
    ${email}=            Get fake data    ascii_email
    ${phone}=            Get fake data    phone_number
    ${day_of_week}=      Get fake data    day_of_week
    Go To Registration Page For Instance    ${instance_id}
    Select From List By Label    summit:I am...    Primary Registrant
# Very difficult pattern break here: the phone "Type" select list has a label for attribute that doesn't match the SELECT
    Select From List By Label     summitx:Type    Mobile
    Input Text           summit:First Name    ${first_name}
    Input Text           summit:Last Name    ${last_name}
    Input Text           summit:Email    ${email}
# Mobile Phone is not visible when the page is loaded. When "Mobile" is selected for "Type", it
# dynamically is made visible
    Wait Until Element Is Visible    summit:Mobile Phone    5 seconds
    Input Text           summit:Mobile Phone    ${phone}
# What's your favorite day of the week? has a single quote that can't be matched with Robot's xpath syntax
# Current approach uses "contains" text matching because "equals" was problematic - so do a partial match
# TODO: try jquery or css locator syntax - maybe more robust for matching arbitrary label text
    Input Text           summitx:your favorite day of the week    ${day_of_week}
#    Click Button    Next

*** Keywords ***

# TODO Move the locators and Suite Setup keywords into a Resource file for reuse.

Go To Registration Page For Instance 
    [Arguments]      ${instance_id}
    &{instance}=     Salesforce Get  Summit_Events_Instance__c  ${instance_id}
    &{event}=        Salesforce Get  Summit_Events__c  ${instance}[Event__c]
    ${url}=          Catenate        SEPARATOR=  ${event}[Community_Base_URL__c]  SummitEventsRegister?instanceID=  ${instance_id}
    Go To            ${url}

Locate Element By Summit VisualForce Label
    [Arguments]    ${browser}    ${locator}    ${tag}    ${constraints}
    ${label}=    Get WebElement    //label[contains(text(),'${locator}')]
    ${id}=    SeleniumLibrary.Get Element Attribute    ${label}    for
    ${element}=    Get WebElement    //*[@id='${id}']
    [Return]    ${element}

Locate Dynamic Element By Summit VisualForce Label
    [Arguments]    ${browser}    ${locator}    ${tag}    ${constraints}
    ${element}=    Get WebElement    //label[contains(text(),'${locator}')]/..//*[self::select or self::input or self::textarea]
    [Return]    ${element}

Open Summit Test Browser
    Open Test Browser
    Add Location Strategy    summit    Locate Element By Summit VisualForce Label
    Add Location Strategy    summitx    Locate Dynamic Element By Summit VisualForce Label

