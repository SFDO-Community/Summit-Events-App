# Second Generation Packaging Summit Events

## Preferred CumulusCI method of 2gp packaging

Using CumulusCI commands much of the headache of manually releasing _(see below)_ a 2GP package is relieved.
CumulusCI will do the work of creating version numbers and creating a github release giving transparency
to the packaging process. You will no longer have to edit the sfdx-project file as this work is done on the fly.

**Create a pre release, beta package:**
```
cci flow run release_2gp_beta -o create_package_version__version_name 'October 2021' 
```
'October 2021' should be unique and be replaced with the month and year of time of release. Beta packages should
not be installed in production orgs.

**Test the pre-release, beta package in a scratch org:**
```
cci flow run ci_beta --org beta
```
This is optional. You could install the beta package in your own development org for testing as well
(rather than a scratch org).

**Promote the latest pre-realese, beta package to a full release package:**
```
cci flow run release_2gp_production 
```

**Test the full release package in a scratch org**
```
cci flow run ci_release --org release
```
This is optional. You could install the release package in your own development org/ testing production org for testing as well
(rather than a scratch org).

---

## Throw away package in CumulusCI
Need to build a mock package to test and throw away without worrying about ancestry. CumulusCI has you covered with
this command:

```
cci flow run build_feature_test_package
```

---

## ARCHIVED - Manual way of upgrading 2gp packages
**THIS METHOD SHOULD NOT BE USED.** The instructions are left here for archival purposes. 
The above CumulusCI method should be use as it automates everything listed below
and creates github releases.

### sfdx-project.json

The sfdx-project.json is the control center for package versioning and ancestry.

**versionNumber**: This is in major.minor.patch.build format. The NEXT just ups the 
build number on beta release builds until the package is promoted. 

**ancestorId**: This is the latest id of the release package you want to inherit 
ancestry from. This ***is not*** the id of first ever released package, but most 
often the id of the last package you created. For upgrade ability the last package 
will follow its ancestor, and so on until the original release package id is found (if ancestry 
has not been broken at some point). All packages in this chain of ancestors can be 
updated to the current package you are creating.

```json
{
    "packageDirectories": [
        {
            "path": "force-app",
            "default": true,
            "package": "Summit Events App",
            "versionName": "ver 0.11",
            "versionNumber": "0.8.0.NEXT",
            "definitionFile": "orgs/dev.json",
            "ancestorId": "04t4P000002T5aPQAS"
        }
    ],
    "namespace": "summit",
    "sfdcLoginUrl": "https://login.salesforce.com",
    "sourceApiVersion": "51.0",
    "packageAliases": {
        "Summit Events App": "0Ho4P000000fxYiSAI",
        "Summit Events App@0.4.0-1": "04t4P000002T5ZCQA0",
        "Summit Events App@0.5.0-1": "04t4P000002T5ZHQA0",
        "Summit Events App@0.6.0-1": "04t4P000002T5ZbQAK",
        "Summit Events App@0.6.0-2": "04t4P000002T5ZgQAK",
        "Summit Events App@0.6.0-3": "04t4P000002T5ZlQAK",
        "Summit Events App@0.7.0-1": "04t4P000002T5aPQAS"
    }
}
```

### Build a beta package

It is surprisingly simple to build a beta package:

```shell script
sfdx force:package:version:create --path force-app --codecoverage --installationkeybypass --wait 10
```
**--codecoverage**: Will run tests for code coverage during packaging.

**--installationkeybypass**: will eliminate the need for a key for installation by end users. 

Packaging seems to take about 10-15 minutes. Occasionally it will time out but give commands
to check on the build in the future.

### Promote a beta package

In order for a beta package to come out of beta to be a fully released version you need 
to promote the beta version with the following command:

```shell script
sfdx force:package:version:promote -p version_01_id -n
```

**version_01_id**: replace this with the beta version you wish to promote. 
You can consult the sfdx-project.json to see what version that might be as it updates
during beta package creation.

Promoted packages will use the same URL as the beta package. It may take several
minutes before the package will appear to not be in beta. If you followed the
installation URL and it still says that the package is beta wait on it until the beta
flag is removed. Simply refresh the package installation page until it no longer 
says beta.

### Installing a package

At the end of packaging you will get a URL to install the package. It will look like
this with the ***version_01_id*** replaced with the package id. Don't install beta packages 
in production orgs.

```
https://login.salesforce.com/packagingSetupUI/ipLanding.app?apvId=version_01_id
```
