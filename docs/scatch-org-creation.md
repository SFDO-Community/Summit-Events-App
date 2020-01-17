# Setting up UST Event App for Scratch org Development

This project is designed to use CumulusCI. So your first job is to make sure that you have the following installed on your development computer:

1. [Python 3+](https://www.python.org/downloads/)
2. [Git](https://git-scm.com/downloads)
3. [Salesforce Command Line Interface (CLI)](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm#sfdx_setup_install_cli)
4. [CumulusCI](https://cumulusci.readthedocs.io/en/latest/install.html#installing-cumulusci)

## Setting up CumulusCI

A complete set of general instructions on setting up CumulusCI can be found in the [CumulusCI Documentation](https://cumulusci.readthedocs.io/en/latest/tutorial.html)

1. Get a copy of the Event App code from GIT. If you are not directly collaborating with the 
 project you may want to fork the project into your own GIT repository:

    ```git
    git clone https://github.com/tcdahlberg/USTEventsDX.git
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

## Set up Saleforce DX Scratch Orgs
1. [Enable Dev Hub in Your Org](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_enable_devhub.htm)
2. [Connect SFDX to Your Dev Hub Org](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_auth_web_flow.htm>) (be sure to use the ``--setdefaultdevhubusername`` option).

## Spinning Up A Scratch Dev Org

For **production environments** you will want to manually set up your org to finely tune your permissions and sites. Use the following instructions for [installation in production Orgs](set-up.md).

### Create a dev configured scratch org for 7 days
```bash 
cci org scratch dev <org_name> --days 7
```

### Confirm your dev configured scratch org was created
```bash 
cci org list
```

### Run a flow to deploy the project and install dependencies into your dev configured scratch org

```bash 
cci flow run dev_org --org <org_name>
```

Normally you would be done with a project at this point, but the Event app requires a salesforce site domain
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

##Set Sharing Rules

Salesforce winter '20 and Spring '20 releases will begin to severely limit Guest User access to objects.
Sharing rules will limit the Guest User to insert access only by default. The UST Event application requires
that the Guest user be able to read, and upsert to it's custom objects. In order to align this application with 
the new security rules we need to set a sharing rule to allow the application to read it's objects. Code has also
been adjust to allow for the required upserts. The following instructions will help you set up the required sharing rules.
Unfortunately, we are not able to automate these steps yet due to limitations in SFDX.

###Set Sharing Object Access

1. Open your new scratch org you are working on in the browser (if it is not already open)

   ```bash 
   cci org browser <org_name> 
   ```
   *<org_name> for development is dev*
   
2. Go to Setup in your scratch org 

3. Type "Sharing" in the quick-find box and click on "Sharing Settings".

4. Click "Edit" to expose sharing option settings for editing

5. Set the UST Event object and make sure it is set to "Public Read/Write"

6. Make sure the "Secure guest user record access" is also checked. This will be checked by default in the future and will soon not be optional.

7. Click "Save" (You will get an alert. Click "Ok")

### Set UST Event Sharing Rule

1. Follow setups 1-3 in the instructions above to get into "Sharing Settings"

2. Find the "UST Event Sharing Rules" section of the page (you can use the "Manage sharing settings for" dropdown on the top or scroll to it)

3. Click the "New" button in the "UST Event Sharing Rules" section

4. Label your rule "Guest User Read Access" with rule name "Guest_User_Read_Access"

5. Set the radio button for "Rule Type" to "Guest user access, based on criteria"

6. Set "Criteria" to Field => Event Name, Operator => "not equal to", Value => null  (type the world null for the value)

7. Share with can only be set to "UST Event Site Guest User"

8. Set Access Level to "Read Only"

9. Click "Save"

## Automate the Rest of the Site Setup
If you are spinning up a **scratch org for development purposes** then setup just got easier for you. Just enter the following command:

```bash
cci flow run config_site --org <org_name>
```

*<org_name> for development is dev*

## Open Up Your Newly Created Dev Scratch Org

Your new scratch org is created and ready for you to develop against!

```bash
cci org browser <org_name>` to open the org in your browser.
```
