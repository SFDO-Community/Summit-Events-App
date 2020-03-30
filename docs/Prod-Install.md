# Installing or Upgrading Summit Events App in Production, Sandbox or Dev Orgs

*Note: Summit Events is currently an unmanaged package, so installation needs to be done by a developer using the steps below*

Your first job is to make sure that you have the following installed on the computer you are using to install Summit Events to Salesforce:

1. [Python 3+](https://www.python.org/downloads/)
2. [Git](https://git-scm.com/downloads)
3. [Salesforce Command Line Interface (CLI)](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm#sfdx_setup_install_cli)

Note that Cumulus CI is only needed to install Summit Events in a scratch org, but not needed for production, sandbox or dev orgs

## Connect an org

Connect your command line to the org you want to install Summit Events in. Use the following command to initiate this authentication:

```bash
sfdx force:auth:web:login --setdefaultusername --setalias my-hub-org
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

7. Get a copy of the Event App code from GIT. If you are not directly collaborating with the 
 project you may want to fork the project into your own GIT repository:

    ```git
    git clone <the URL you copied from your forked repository>
    ```

## Installing the Summit Events app through the Salesforce Command Line Interface

You will need to use the Salesforce CLI (Command Line Interface) for this next part. If you prefer, you can do it through [Visual Studio Code](https://code.visualstudio.com/download) instead

1. On your computer, navigate to the installation folder in Command Prompt

2. Use Salesforce CLI to push the code into Salesforce

    ```sfdx
    sfdx force:source:deploy --json --loglevel fatal -l RunLocalTests
    ```

3. Verify that the installation is successful by logging into your org and going to Setup --> Deployment Status, then seeing if the deployment is marked as Succeeded. 

*Note: Since Summit Events is deployed in the same manner as a change set, it will not display as an installed package.*

## Your org is ready!

Your installation of Summit Events in your org is completed and ready for your admin to [begin setup](set-up.md)!
