# AGENTS.md — Summit Events App

## What this project is

Summit Events App (SEA) is an open-source, native-Salesforce event registration
solution built for EDUs and NGOs. It handles the full event lifecycle:
registration, receipting/payments, appointments, guest registration, donations,
confirmation, and reporting.

Its defining feature: registration is a **multi-step wizard that fully works
for unauthenticated Guest Users** on an Experience Cloud (Digital Experience)
site — no login required to register for an event. That guest-access
requirement drives almost every non-obvious pattern in this codebase (see
"Guest User Architecture" below).

Full documentation: https://sfdo-community-sprints.github.io/summit-events-app-documentation/

## Stack

- **Build tool:** CumulusCI (`cci`) — Python CLI, config in `cumulusci.yml`
- **Source format:** SFDX (`sfdx-project.json`), package namespace `summit`, API version 67.0
- **Org type:** Scratch orgs only — never production
- **Frontend (shipped/packaged):** Legacy Visualforce pages (`force-app/main/default/pages`) — this is what's actually in the managed package today
- **Frontend (in progress, not packaged):** Lightning Web Components (`force-app/main/default/lwc`) — an early-stage, work-in-progress rewrite of the registration flow, being developed on a dedicated branch. Not released, not part of the managed package, and not feature-complete. Treat LWC work as exploratory/future-focused unless told otherwise.
- **Backend:** Apex controllers (`force-app/main/default/classes`) — VF controllers are the current production path; the "Apex-First" single-call wrapper pattern (`SummitEventsLWCController`) is specific to the in-progress LWC flow
- **Platform:** Salesforce Experience Cloud (Digital Experience site)

## Scratch orgs

Defined in `cumulusci.yml` under `orgs.scratch`. We're a small team and only
actually use the two dev orgs day to day:

| Org | Config | Purpose |
|---|---|---|
| `dev` | `orgs/educloud.json` | Primary dev org (Education Cloud enabled, not namespaced) |
| `dev_namespaced` | `orgs/namespaced.json` | Namespaced package-context testing |

`beta`, `feature`, `qa`, `release` also exist in `cumulusci.yml` — that's
inherited boilerplate from the standard CumulusCI project structure, not
something this team maintains or uses. Ignore them unless specifically asked.

Relevant flows: `config_dev`, `config_dev_namespaced` build the Experience
Cloud site, guest sharing rules, and Guest User permission set on top of a
base org. `customer_org` / `install` are for managed-package installs, not
dev work.

## ⚠️ Critical Deployment Rule

**Never run a full org-rebuild flow (e.g. `cci flow run dev_org`) against
a scratch org that already has working setup.** It rebuilds everything and
**deletes existing data, guest sharing config, and site settings.**

Use targeted deploys instead:
```bash
cci task run deploy --path force-app/main/default/lwc --org dev
cci task run deploy --path force-app/main/default/classes --org dev
cci task run deploy --path force-app/main/default/lwc/summitEventsRegistration --org dev
```

## Guest User Architecture (read this before touching Apex)

SEA's guest-registration flow moves a Guest User through multiple pages while
occasionally losing normal record ownership context between steps (the guest
session has no persistent identity). The security model that makes this safe:

1. **State is carried client-side**, not via session/record ownership — via an
   encrypted cookie (VF) or encrypted ID passed through the LWC wrapper/URL
   (LWC), tracking registration id, event id, instance id, and audience.
2. **Every controller is split in two:**
   - An outer, normally-scoped class/section for read logic
   - An inner **`without sharing`** class (see `RegistrationCRUD`,
     `LookupCRUD` in `SummitEventsLWCController.cls`) that does the actual
     CRUD, because a Guest User's org-wide-defaults would otherwise block
     record creation/updates across steps.
3. **`SummitEventsReadShared.cls` is `without sharing`** by design — comment
   at the top of that file documents the pattern. Don't "fix" it back to
   `with sharing`.

### Known gotcha: `WITH SECURITY_ENFORCED` still blocks Guest Users

`without sharing` bypasses **record-level** sharing, but
`WITH SECURITY_ENFORCED` in a SOQL query still enforces **object CRUD and
field-level security (FLS)** for the running user. If the Guest User Profile
hasn't been granted Read/Create/Edit + FLS on the Summit Events objects, these
queries throw, get caught, and rethrown as `AuraHandledException` —
**and `ShowToastEvent` does not surface for Guest Users in Experience Cloud**,
so the failure is silent (blank page, "no data").

When guest-facing data isn't loading/saving, check in this order:
1. Guest User Profile FLS/CRUD on `Summit_Events__c`, `Summit_Events_Instance__c`,
   `Summit_Events_Question__c`, `Summit_Events_Appointment_Type__c` (read) and
   `Summit_Events_Registration__c`, `Summit_Events_Appointments__c`,
   `Summit_Events_Fee__c` (create/edit) — Setup → Digital Experiences → site → Administration → Guest User Profile.
2. Guest sharing rules deployed (`unpackaged/config/sharing`,
   `unpackaged/config/summit__sharing`) — deployed via `deploy_guest_sharing_rules`
   / `deploy_namespaced_guest_sharing_rules` cci tasks.
3. Whether the outer class enclosing a guest-facing `@AuraEnabled` method is
   `with sharing` when it shouldn't be, or a query unexpectedly uses
   `WITH SECURITY_ENFORCED` in a path Guest Users must hit.

## Data Model

Custom objects (`force-app/main/default/objects`):
- `Summit_Events__c` — event definition/config (labels, questions config, donation config, recaptcha, etc.)
- `Summit_Events_Instance__c` — a specific occurrence/date of an event
- `Summit_Events_Registration__c` — an attendee's registration record
- `Summit_Events_Question__c` — configurable additional question definitions
- `Summit_Events_Appointment_Type__c` / `Summit_Events_Appointments__c` — appointment scheduling
- `Summit_Events_Fee__c` / `Summit_Events_Fee_Allocation__c` — fees and donation allocations
- `Summit_Events_Payment__c` — payment/receipt records
- `Summit_Events_Host__c` — event hosts
- `Summit_Events_Email__c` — communications
- `Summit_Events_Settings__c` — org-wide custom settings (site URL, reCAPTCHA keys, etc.)
- `*_Matching_Mapping__mdt` (Contact / Lead / Person) — custom metadata driving contact/lead matching rules

Also extends the standard `Contact` object.

## LWC Implementation Patterns

> ⚠️ **Status: work in progress, not shipped.** This section documents the
> `sea_lwc` branch's in-progress rewrite of the registration flow. It is not
> part of the managed package, is not feature-complete, and should not be
> assumed to reflect production behavior — production registration still runs
> on the Visualforce pages. Don't reference the LWC flow when reasoning about
> what a live/customer org actually does.

### Apex-First single data load
The registration flow (`summitEventsRegistration` is the controller component)
calls `SummitEventsLWCController.getSummitEventData()` **once** and gets back a
`SummitEventWrapper` containing everything: event/instance, questions,
appointment types, config flags, existing registration + fees + guests. Don't
add follow-up round trips for data that could be included in this payload.

### Reactivity
LWC doesn't detect deep mutations — always spread into new objects/arrays:
```javascript
// ✅
this.eventData = { ...this.eventData, pages: this.eventData.pages.map(...) };
```

### Page component contract
Each page component (`summitEventsRegisterPage`, `summitEventsQuestionsPage`,
`summitEventsAppointmentsPage`, `summitEventsGuestsPage`,
`summitEventsDonationPage`, `summitEventsSubmitPage`,
`summitEventsConfirmationPage`) must implement:
- `@api validate()` → boolean
- `@api getData()` → partial object merged into `eventData`

### `appointmentTypes` is a Map, not an Array
It serializes from Apex `Map<Id, Summit_Events_Appointment_Type__c>` to a JS
object. Always `Object.values(eventData.appointmentTypes || {})` to iterate.

### URL parameters (case-sensitive)
Supports `instanceId`/`instanceID` (capital D, VF back-compat),
`eventInstanceId`, `id`, and `registrationId`/`registrationID`/`regId`. URL
params override `@api` component properties.

### Reserved names to avoid
Don't name classes/wrappers `Page`, `User`, or same as standard objects
(`Account`, `Contact`) — use `PageInfo`, `UserData`, etc.

## Testing

- Apex tests: `force-app/test/default/classes` (kept separate from
  `force-app/main/default/classes`)
- Follow PNB coverage per test class: Positive / Negative / Bulk
- Run via `cci task run run_tests --org dev` or `sf apex run test`
- BackstopJS available for visual regression on VF→LWC migration comparisons

## Available agent skills for this repo

Invoke proactively when the task matches:
- `cumulus-ci` — deploy strategy, Apex test execution, coverage, metadata gotchas
- `salesforce-education-cloud` — anything touching Education Cloud objects
- `salesforce-apex-quality` — bulk-safety, sharing model, CRUD/FLS, SOQL injection review
- `salesforce-component-standards` — LWC/Aura/VF quality and security review
- `salesforce-flow-design` — reviewing/designing any Flow
- `backstopjs-visual-testing` — VF vs LWC visual regression setup
- `terminal-commands` — `cci`/`sf`/`jq` command conventions on this machine

## Documentation in this repo

`docs/` contains project notes (`CumulusCI-notes.md`, `scatch-org-creation.md`,
`GIT-notes.md`, packaging notes, install docs). The canonical, actively
maintained docs are the external site linked above — prefer updating that
over creating new files in `docs/`.
