# Connected Apps and External Client Apps Security Requirements

The Summit Events App (SEA) team would like to address the notification regarding the updated security requirements for Connected Apps and External Client Apps in Salesforce managed packages.

Since we are an open-source solution our code base is available for review in our [GitHub repository](https://github.com/SFDO-Community/Summit-Events-App). Documentation on how to use the SEA can be found on our [documentation site](https://sfdo-community-sprints.github.io/summit-events-app-documentation/).

After thoroughly reviewing our SEA solution and its codebase, we have determined that these requirements do not apply to our application for the following reasons:

1. No Connected Apps or External Client Apps: SEA is a native Salesforce application built entirely with Apex, Visualforce, and Lightning Web Components. Our repository contains no Connected App or External Client App metadata or configurations that are distributed to customers.

2. No OAuth Flows: The application does not implement any OAuth flows (device flow, implicit flow, username/password flow, or client-credentials flow). All authentication is handled through standard Salesforce user sessions and Communities (Experience Cloud) guest user access.

3. Native Salesforce Architecture: The application operates entirely within the Salesforce platform using:

   - Apex classes and triggers
   - Visualforce pages
   - Lightning Web Components 
   - Experience Cloud sites for public event registration 
   - Standard Salesforce permission sets and sharing rules

4. No External Integrations: There are no backend services, external APIs, middleware, or third-party integrations that would require Connected App credentials, OAuth tokens, or secret management beyond Salesforce's native security model.

5. No Packaged Secrets: The application does not store or distribute any client keys, secrets, JWT private keys, or OAuth credentials in Custom Settings, Custom Metadata, or any other form.

6. Public REST API: Our application includes a public REST API (/services/apexrest/summit/summiteventsfeed) that provides read-only access to event instance information. This endpoint:

   - Does not require OAuth or Connected App authentication 
   - Uses standard Salesforce site guest user permissions 
   - Returns only publicly available event data already accessible through the registration site 
   - Does not expose any sensitive customer data or secrets

7. Cookie Encryption Key: The application stores an encryption key in Custom Settings for securing registration IDs in browser cookies. This key:

   - Is used solely for client-side cookie encryption/decryption within the same Salesforce org 
   - Is not an OAuth secret, JWT private key, or Connected App credential 
   - Does not facilitate authentication or authorization between systems 
   - Is managed through standard Salesforce Custom Settings with field-level security

SEA uses deployment tooling (CumulusCI) that is used solely for development, testing, and package deployment automation and does not create any Connected Apps that are distributed to customers.

We will continue to monitor our application architecture and will immediately address these requirements should we introduce any Connected Apps or External Client Apps in future releases.

Please let us know if you need any additional information regarding our application's architecture.
