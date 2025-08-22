*** Settings ***
Resource        cumulusci/robotframework/Salesforce.robot
Documentation   A simple Robot test

*** Test Cases ***
Create a Contact using the API

   ## Create a new Contact
   ${contact id}=   Salesforce Insert  Contact
   ...  FirstName=Eleanor
   ...  LastName=Rigby

   ## Get the new Contact and examine it
   &{contact}=      Salesforce Get  Contact  ${contact id}
   Should be equal  ${contact}[FirstName]    Eleanor
   Should be equal  ${contact}[LastName]     Rigby

