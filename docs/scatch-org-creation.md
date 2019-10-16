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

Deploy sping up and install dependencies and code into your scratch org

```bash 
cci flow run dev_org --org <org_name>
```

Normally you would be done with a project at this point, but the Event app requires a salesforce site domain
be set up. You will need to do this in the next step and then run one final command to complete the site set up.

## Create a site

1. Open the org you are working on in the browser

   ```bash 
   cci org browser <org_name> 
   ```
   *<org_name> for development is dev*
   
2. In Setup go to User Interface -> Sites and Domains -> Sites

3. Select a subdomain that is available. Since you are spinning up scratch orgs you may want to start incrementing a subdomain on a theme (myevents0001...myevents0002).

4. Click "Register My Salesforce Site Domain"

## Automate the Rest of the Site Setup
If you are spinning up a **scratch org for development** setup just became easy for you. Just enter the following command:

```bash
cci flow run config_site --org <org_name>
```

*<org_name> for development is dev*

## Open Up Your Newly Created Dev Scratch Org

Your new scratch org is created and ready for you to develop against!

```bash
cci org browser <org_name>` to open the org in your browser.
```
