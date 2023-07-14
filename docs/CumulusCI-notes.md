# CumulusCI - ***Notes***

## Manage Packaging

Before packaging, make sure your master branch has everything in it you want to include in the package for installation. 

1. Deploy to scratch org. This will create a dev scratch org that installs all dependencies (EDA in this case).

    ```bash
    cci flow run dev_org
    ```

2. Check your dev org and make sure the app works

    ```bash
    cci org browser dev
    ```
   
3. Deploy your master to the packaging org

    ```bash
    cci flow run ci_master --org packaging
    ```
   
4. Release production in the packaging org

    ```bash
    cci flow run release_production --org packaging
    ```
5. Initially you will have to upload via the packaging org upload button to get your install link. This appears only to be done once and is a step I missed.


## Deploy meta data code - not managed or unmanaged

1. Connect the org you want to deploy to:

    ```bash
    cci org connect <org_name>
    ```
   
    Example staging:
    ```bash
    cci org connect staging
    ```
   
   Example production:
   
   ```bash
   cci org connect production
   ```

2. Deploy code straight to a defined org

    First rebuild the root src so it reflects any changes made.
   <br>
   *Note: The src directory should have been rebuilt if you have deployed to a scratch org like you should have.*

    ```bash
   cci task run dx_convert_from
    ```
   
   Now deploy the src directory to the org of your choice.
   
    ```bash
    cci task run deploy --org <org_name>
    ```

## Deploy Data to scratch of and set up sites
    
Anonymous Apex in run cci to add settings / data ? 

## Commands I keep using

**Run this command to list all orgs currently running:**

```bash
cci org list
```

**Run this command to delete a scratch org (in this case the dev org)**
<br>_Note: Deleting a scratch org will still leave the lazy configuration in the keychain so the scratch org can easily be created again by running the `dev_org` flow._

```bashcci 
cci org scratch_delete dev
```

**Run this command to remove a scratch org from the org listing (in this case the dev org)**

```bash
cci org remove dev
```

**Run this command to build a new dev org from your local repository**
<br>This cci command is a flow. A flow is a combination of tasks run in order. This flow will install all dependencies as well as your local repositories code.

```bash
cci flow run dev_org
```

**Run this command to update your package before running the dev_org flow**
<br> I ran into issues with the flow erroring out when I didn't do it. I ended up having to delete the dev org and running the following to update the package. Then it all worked!

```bash
cci task run update_package_xml
```

**Run this command if your package didn't install after running the `dev_org` flow**

```bash
cci task run deploy
```

**Run this command to open a scrach org in a browser (in this case dev)**
<br>If you did the above, your application should be installed:

```bash
cci org browser dev
```

**Run this command after you complete building your dev org and taking a snapshot of the changes (there should be none at this point)**

```bash
cci task run list_changes -o snapshot True
```

**Run this command to list out any new changes to your project**

```bash
cci task run list_changes
```

**Run this command when you are ready to pull down new changes**

```bash
cci task run retrieve_changes
```

## Issues I have run accross

### Multiple orgs created

Occasionally, especially if a org creation is interrupted or fails, multiple scratch orgs can be created. You will need to list using Salesforce CLI the orgs and then delete them using that CLI.

List the orgs:

```bash
sfdx force:org:list
```

Delete orgs stray orgs that aren't listed in CCI (cci list orgs):

```bash
sfdx force:org:delete -u me@my.org
```

The me@my.org should match the user of the org you are trying to delete.

### Code updates won't deploy

I found a typo in a field name.. gross! Since this is repository first coding I should be able to just globally change it and update my org. Your code can be 100% changed but then during org creation the directory .sfx/orgs/test-user-email@example.com (that last bit is different per org) the source path info will still be old and include the old field name. Why?!

## Ignore EDA package for this project

Not sure I need to do this. Is this for .gitignore or .forceignore

force-app/main/default/objects/Contact/fields/hed__**
