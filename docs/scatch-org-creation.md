# Setting up Summit Events App for Scratch org Development

This project is designed to use CumulusCI. So your first job is to make sure that you have the following installed on your development computer:

1. [Python 3+](https://www.python.org/downloads/)
2. [Git](https://git-scm.com/downloads)
3. [Salesforce Command Line Interface (CLI)](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm#sfdx_setup_install_cli)
4. [CumulusCI](https://cumulusci.readthedocs.io/en/latest/install.html#installing-cumulusci)

A complete set of general instructions on setting up CumulusCI can be found in the [CumulusCI Documentation](https://cumulusci.readthedocs.io/en/latest/tutorial.html).

## Connect a dev hub

1. [Enable Dev Hub in Your Org](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_enable_devhub.htm). This is used to authenticate your rights to spin up scratch orgs.
This should not effect anything in your org.

2.  Connect your command line to the dev org you turned on. This will require you to log in to the org you identify as your dev hub. Use the following command to initiate this authentication:

```bash
sfdx force:auth:web:login --setdefaultdevhubusername --setalias my-hub-org
```

*"my-hub-org" above is an alias. You can choose whatever alias you wish as it is used to identify this
particular dev hub if you have multiple*

## Gitting the code (Get it?)

1. Log in to GitHub.

2. Go to the [Summit Events repository](https://summitevt.org).

3. Fork a copy of the repository to your own account by clicking the "Fork" button at the top of the
GitHub page. This will copy all the code from the repository into your personal account. Code in your
own repository will not affect the main repository in any way.

4. Navigate to your forked copy of the repository. The path at the top of the page should include your
GitHub username in it.

5. Click on the "Clone or download" green drop-down near the top left of the page. Copy the URL to clone
your forked repository.

6. On your computer navigate to the folder that you wish to put your cloned code in. Remember that
cloning will create a directory for the code for you. You may also wish to use GitHub desktop to 
make this whole process prettier and less intimidating. This documentation will outline command 
line usage of git, but both are acceptable.

1. Get a copy of the Event App code from GIT. If you are not directly collaborating with the 
 project you may want to fork the project into your own GIT repository:

    ```git
    git clone <the URL you copied from your forked repository>
    ```

2. In your terminal, in the code directory check and see if the project is already 
set up with CumulusCI:

    ```bash
    cci project info
    ```
   
   If the project is not set up you will get this message:
   
   ```bash
   The file cumulusci.yml was not found in the repo root. Are you in a CumulusCI project directory?
   ```
   
   If you get the above message use the following command to init the project into cumulusCI:
   
   ```bash
   cci project init
   ```

3. Connect Github and and Cumulus to this project:

   ```bash
   cci service connect github
   ```

## Spinning up a scratch or with the events app installed

1. Create a dev configured scratch org for 7 days
    ```bash 
    cci org scratch dev <org_name> --days 7
    ```

2. Confirm your dev configured scratch org was created
    ```bash 
    cci org list
    ```

3. Run a flow to deploy the project and install dependencies into your dev configured scratch org
    ```bash 
    cci flow run dev_org --org <org_name>
    ```

Normally you would be done with a cumulusCI project scratch org at this point, but the Event app requires a salesforce site domain
be set up. You will need to do this in the next step and then run one final command to complete the site set up.

## Create a site

1. Open your new scratch org you are working on in the browser

   ```bash 
   cci org browser <org_name> 
   ```
   *<org_name> for development is dev*
   
2. In Setup go to User Interface -> Sites and Domains -> Sites

3. Select a subdomain that is available. Since you are spinning up scratch orgs you may want to start incrementing a subdomain on a theme (myevents0001...myevents0002).

4. Click "Register My Salesforce Site Domain"

## Automated site set-up

Back in the command line. Use the following command to allow CumulusCI to complete the set-up of the public site:
```bash
cci flow run config_site --org <org_name>
```

*<org_name> for development is dev*

## Set Sharing Rules

Salesforce Winter '20 and Spring '20 releases will begin to severely limit Guest User access to objects.
Sharing rules will limit the Guest User to insert access only by default. The Summit Events application requires
that the Guest user be able to read, and upsert to it's custom objects. In order to align this application with 
the new security rules we need to set a sharing rule to allow the application to read it's objects. Code has also
been adjust to allow for the required upserts. The following instructions will help you set up the required sharing rules.
Unfortunately, we are not able to automate these steps yet due to limitations in SFDX.

### Set Sharing Object Access

1. Open your new scratch org you are working on in the browser (if it is not already open)

   ```bash 
   cci org browser <org_name> 
   ```
   *<org_name> for development is dev*
   
2. Go to Setup in your scratch org 

3. Type "Sharing" in the quick-find box and click on "Sharing Settings".

4. Click "Edit" to expose sharing option settings for editing

5. Set the Summit Events object and make sure it is set to "Public Read/Write"

6. Make sure the "Secure guest user record access" is also checked. This will be checked by default in the future and will soon not be optional.

7. Click "Save" (You will get an alert. Click "Ok")

### Set Summit Events Sharing Rule

1. Follow setups 1-3 in the instructions above to get into "Sharing Settings"

2. Find the "Summit Events Sharing Rules" section of the page (you can use the "Manage sharing settings for" dropdown on the top or scroll to it)

3. Click the "New" button in the "Summit Events Sharing Rules" section

4. Label your rule "Guest User Read Access" with rule name "Guest_User_Read_Access"

5. Set the radio button for "Rule Type" to "Guest user access, based on criteria"

6. Set "Criteria" to Field => Event Name, Operator => "not equal to", Value => null  (type the world null for the value)

7. Share with can only be set to "Summit Events Site Guest User"

8. Set Access Level to "Read Only"

9. Click "Save"

## Your org is ready!

Your new scratch org is created and ready for you to develop against/with/for! Remember you can open your org with this command once it has been created:

```bash
cci org browser <org_name>
```
