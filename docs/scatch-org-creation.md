# Setting up Summit Events App for Scratch org Development

This project is designed to use CumulusCI. So your first job is to make sure that you have the following installed on your development computer:

1. [Python 3+](https://www.python.org/downloads/)
2. [Git](https://git-scm.com/downloads)
3. [Salesforce Command Line Interface (CLI)](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm#sfdx_setup_install_cli)
4. [CumulusCI](https://cumulusci.readthedocs.io/en/latest/install.html#installing-cumulusci)

A complete set of general instructions on setting up CumulusCI can be found in the [CumulusCI Documentation](https://cumulusci.readthedocs.io/en/latest/tutorial.html).

## Gitting the code (Get it?)

**To Fork or Branch. That is the question?**

If you are not a direct contributer to the Summit Events App that has requested and recieved access to the main repository you will be forking the code. Forked code is a copy of the Summit Events App code that lives under your own GitHub account. Nothing you do to forked code can harm or improve the main repository of the Summit Events App. This means you can play with the code all you want so have fun! If you do come up with some ground breaking improvement in your forked code you can, and are encouraged, to contribute to the main repository by requestion something called a Pull Request from your forked code.

Here is how you fork that code:

1. Log in to [GitHub](https://github.com).

2. Go to the [Summit Events repository](https://summitevt.org).

3. Fork a copy of the repository to your own account by clicking the "Fork" button at the top of the
GitHub page. This will copy all the code from the repository into your personal account. Code in your
own repository will not affect the main repository in any way.

4. Navigate to your forked copy of the repository. The path at the top of the page should include your
GitHub username in it.

5. Click on the "Clone or download" green drop-down near the top left of the page. Copy the URL to clone
your forked repository. This is the URL you will use to copy the code down to your local computer.

6. On your computer navigate to the folder that you wish to put your cloned code in. Remember that
cloning will create a directory for the code for you. 

*You may also wish to use GitHub desktop to make this whole process prettier and less intimidating. **

7. Copy your code to your computer with this command:

```git
git clone <the URL you copied from your forked repository>
```

8. Navigate into the newly created directory that contains the Summit Events App code. Check to make sure a proper CumulusCI project has been established by typing this command into your terminal:

```bash
cci project info
```
   
Your Summit Events App is a pre-configured CumulusCI project. If you get the following after the above comman something is wrong with your copy of the Summit Events App (seek help):

```bash
The file cumulusci.yml was not found in the repo root. Are you in a CumulusCI project directory?
```
   
## Connect a dev hub

1. [Enable Dev Hub in Your Org](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_enable_devhub.htm). This is used to authenticate your rights to spin up scratch orgs. This will not affect anyting in the authenticating org.

2. Navigate to the directory that contains the Summit Events App code.

3. Connect your command line to the same dev hub authenticating org you turned on in step one. This will require you to log in using your credentials for the org in step one:

```bash
sfdx force:auth:web:login --setdefaultdevhubusername --setalias my-hub-org
```

*"my-hub-org" above is an alias. You can choose whatever alias you wish as it is used to identify this
particular dev hub if you have multiple*


## Spinning up a scratch or with the events app installed

Now you have the groundork done in the future you should only need these steps to spin up a scratch org.

1. Navigate to the directory that contains the Summit Events App code.

2. Run a CumulusCI flow to deploy the project and install dependencies into your dev configured scratch org

```bash 
cci flow run dev_org --org dev
```
    
**What happens when this flow is run?**

1. A scratch org is created (Your personal copy of saleforce with no data in it).

2. A community site is created with a random sub domain..

3. Summit Event App is installed. This inclueds Apex code, Visualforce pages, objects, fields, layouts, permission Sets, sharing rules, and sites.

4. Permission Sets are assigned for admin use of the Summit Events App as well as the guest site user.

5. Sample event data is inserted.


## Your org is ready!

Your new scratch org is created and ready for you to develop against/with/for! You can now see that CumulusCI has created a dev org that will last seven days by entering the floowing command:

```bash
cci org list
```

You can open up your new scratch org with Summit Events App installed by entering the following command:

```bash
cci org browser dev
```
