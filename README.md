# UST Event App

## Build
Create a dev hub for your scratch org
sfdx force:auth:web:login -d -a DevHub
Always at the –a [UserAliasOfHub] as it makes things way easier later

If you need to open your devHub
sfdx force:org:open -u DevHub

Create a scratch org project

Create a scratch org

Create an account record type
A test account record type is in the project so try pushing that first.

Create a site

Get a list of installed packages on you Dev Hub
sfdx force:package:installed:list -u DevHub  
-u [alias of dev hub]
Find the package you want to install and copy the Package Version ID

Install managed package
sfdx force:package:install --package 04t1R00000126jPQAQ -u University_of_St_Thomas_Events
--package [package Id from above goes here]
-u [alias of your scratch org]

## Resources

## Description of Files and Directories

## Issues
