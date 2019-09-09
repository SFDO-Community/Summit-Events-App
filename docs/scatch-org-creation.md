# Setting up UST Event App for Scratch org Development

## Create a site

1. Open the org you are working on in the browser

   ```bash 
   cci org browser <org_name> 
   ```
   
2. In Setup go to User Interface -> Sites and Domains -> Sites
3. Select a subdomain that is available. Since you are spinning up scratch orgs you may want to start incrementing a subdomain on a theme (myevents0001...myevents0002).
4. Click "Register My Salesforce Site Domain"

## Automate the rest of setup
If you are spinning up a **scratch org for development** setup just became easy for you. Just enter the following command:

```bash
cci flow run config_site --org <org_name>
```

For **production environments** you may want to manually set up your org to finely tune your permissions and sites. Use the following instructions.
