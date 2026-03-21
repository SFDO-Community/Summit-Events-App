# SEA Registration Flow — Visualforce & LWC Architecture

**Last Updated**: March 21, 2026  
**Purpose**: Deep technical reference documenting both the original Visualforce (VF) implementation and the LWC replacement. Use this when building, debugging, or extending any part of the registration flow.

---

## Table of Contents
1. [High-Level Overview](#1-high-level-overview)
2. [Visualforce Architecture](#2-visualforce-architecture)
3. [LWC Architecture](#3-lwc-architecture)
4. [Apex Controller — SummitEventsLWCController](#4-apex-controller--summiteventslwccontroller)
5. [Complete Data Structures](#5-complete-data-structures)
6. [Object & Field Reference](#6-object--field-reference)
7. [Page-by-Page Implementation Details](#7-page-by-page-implementation-details)
8. [Authentication, Cookies & State](#8-authentication-cookies--state)
9. [Security Model](#9-security-model)
10. [Known Differences VF vs LWC](#10-known-differences-vf-vs-lwc)

---

## 1. High-Level Overview

Summit Events App (SEA) is a multi-step event registration system. A registrant moves through a series of pages, each collecting data, before submitting. All pages are **publicly accessible** — no login required — because they run under the Salesforce Guest User via Experience Cloud.

### Registration Page Flow

```
Register (basic info)
  └→ Additional Questions  [if hasAdditionalQuestions]
       └→ Appointments      [if hasAppointments]
            └→ Guests        [if hasGuestRegistration]
                 └→ Donation  [if hasDonations]
                      └→ Submit (review)
                           └→ Confirmation
```

The exact pages shown depend on event configuration (`hasAdditionalQuestions`, `hasAppointments`, etc.) and are determined at load time by the Apex controller.

---

## 2. Visualforce Architecture

### VF Pages

| VF Page | Purpose |
|---|---|
| `SummitEventsRegister.page` | Basic registrant info |
| `SummitEventsRegisterAdditional.page` | Additional/custom questions |
| `SummitEventsRegisterAppointments.page` | Appointment selection |
| `SummitEventsRegisterGuests.page` | Guest additions |
| `SummitEventsDonation.page` | Optional donation |
| `SummitEventsSubmit.page` | Review & submit |
| `SummitEventsRegisterConfirm.page` | Confirmation |

### VF Controllers

- **`SummitEventsRegistrationController`** — main register page
- **`SummitEventsRegisterAdditionalController`** — additional questions
- **`SummitEventsRegisterAppointmentController`** — appointments (separate Apex class)
- **`SummitEventsRegisterGuestsController`** — guests
- **`SummitEventsDonationController`** — donation
- **`SummitEventsSubmitController`** — submit/review
- **`SummitEventsRegisterConfirmController`** — confirmation

### VF State & Session Management (Critical!)

VF pages maintain state through a **client cookie** (`SummitEventsRegistrant`). The cookie stores an **encrypted registration ID**. On every page load, the controller reads the cookie, decrypts the ID, and loads the registration record.

**Why this matters**: The Salesforce Guest User has no persistent server-side session context — it only has **insert** access on certain objects. The cookie is the only way to link page 1 to page 2 to page 3. Without the cookie (e.g., navigating directly to a later page), the controller gets no registration context and redirects to a generic error/login page.

**Implication for testing**: You CANNOT directly browse to an inner page (Appointments, Guests, etc.) in a new browser session. You must start at the Register page, fill out the form, and click Next. Each "Next" writes/updates the cookie and saves a draft registration.

**Cookie details**:
- Name: `SummitEventsRegistrant`
- Value: AES256-encrypted registration ID
- Encryption key: stored in org custom setting (`Summit_Events_Settings__c.Encryption_Key__c`)
- Key must be exactly 32 characters/bytes

### VF URL Pattern

```
https://<org-domain>/apex/SummitEventsRegister?instanceId=<Summit_Events_Instance__c.Id>
```

Going to the next page:
```
https://<org-domain>/apex/SummitEventsRegisterAdditional?instanceId=<id>
```

The `instanceId` is re-passed in the URL on every page. The registration record is found via the cookie, not the URL.

### VF Appointments Page Patterns (Key UI Details)

The VF appointments page (`SummitEventsRegisterAppointments.page`) uses:
- **Accordion cards** — one card per appointment type
- **Two-column layout**: Left column = available types with "Add" button; Right column = currently selected appointments
- **Input per type** based on `Registrant_Input__c`:
  - `"Text box"` → `<apex:inputTextarea>` (not required)
  - `"Required text box"` → `<apex:inputTextarea>` (required)
  - `"Custom pick list"` → custom `<apex:selectList>` from `Available_Appointments__c` (not required)
  - `"Required custom pick list"` → same but required
- **Auto-add behavior** based on `Chosen_State__c`:
  - `"Added"` or `"Added and Required"` → auto-added to selections on page load
  - `"Added but not shown"` → silently included; not displayed in UI
- Types with no remaining slots (capacity exhausted) are hidden from available list

### VF Guests Page Patterns

`SummitEventsRegisterGuests.page`:
- **Two-column layout**: 4/12 form on left, 8/12 guest list on right
- Guest data is stored as **JSON in `Guest_JSON__c`** on the primary registration record
- Format: `[{"firstName":"...", "lastName":"...", "email":"..."}]`
- Optional `guestQuestionJSON` field — when guest-specific questions are configured, answers are embedded in the JSON alongside the guest data
- **Max guests**: enforced via `Guest_Max_Amount__c` on `Summit_Events__c`
- **Unsaved guest modal**: VF shows an alert if the user tries to navigate away with form data that hasn't been added yet

### VF Donation Page Patterns

`SummitEventsDonation.page` (controlled by `SummitEventsDonationController.cls`):
- **Suggested amounts**: Parsed from `Donation_Suggested_Amount_List__c` (newline-delimited text field on `Summit_Events__c`). Each line becomes a dropdown option.
- **Allocation designations**: Up to 5 allocation lookups on `Summit_Events__c`: `Donation_Allocation_1__c` through `Donation_Allocation_5__c`, each pointing to `Summit_Events_Fee_Allocation__c`. The `__r.Name` of each gives the label.
- **"Other Amount"**: A custom text input shown when no preset amount is selected or user wants to enter manually
- **Storage**: Donation is saved as a `Summit_Events_Fee__c` record with `Event_Fee_Type__c = 'Optional Donation'`

### VF Submit Page Patterns

`SummitEventsSubmit.page`:
- Shows full read-only summary of everything collected:
  - Registrant info
  - Guest list (from `Guest_JSON__c`)
  - Chosen appointments (filtered by `Chosen_State__c` — "Added but not shown" types are hidden)
  - Fees table:
    - Row 1: Event base fee (`Event_Fee__c` from instance)
    - Row 2: Individual appointment fees (sum)
    - Row 3: Donation amount (if any)
    - Total row at bottom
- reCAPTCHA widget rendered before the Submit button
- Submitting triggers the actual `Summit_Events_Registration__c.Status__c` update and sends confirmation email

---

## 3. LWC Architecture

### Component Tree

```
summitEventsRegistration (Controller - manages all state & flow)
├── summitEventsRegisterPage         ✅ COMPLETE
│   └── (uses lightning-input-address for mailing address)
├── summitEventsQuestionsPage        ✅ COMPLETE
│   └── summitEventsQuestionField    ✅ COMPLETE (11+ field types)
├── summitEventsAppointmentsPage     ✅ IMPLEMENTED (March 2026)
├── summitEventsGuestsPage           ✅ IMPLEMENTED (March 2026)
├── summitEventsDonationPage         ✅ IMPLEMENTED (March 2026)
├── summitEventsSubmitPage           ✅ IMPLEMENTED (March 2026)
└── summitEventsConfirmationPage     ✅ COMPLETE
```

### Page Component Contract (MUST FOLLOW!)

Every page component that participates in navigation **must implement both methods**:

```javascript
// Returns true if page is valid (all required fields filled), false otherwise.
// Must call reportValidity() on inputs to show error messages.
@api
validate() { ... }   // → Boolean

// Returns a partial eventData object that will be deep-merged into
// the main eventData in the controller (via updateEventData()).
@api
getData() { ... }    // → Partial<SummitEventWrapper>
```

The controller calls `validate()` first; if it returns `false`, navigation is blocked. If it returns `true`, `getData()` is called and the result is merged into `eventData`.

**Deep merge**: The controller merges the partial result using spread operators at each level. Missing keys are preserved from the original `eventData`. See `updateEventData()` in `summitEventsRegistration.js`.

### URL & State Management (LWC vs VF)

**No cookie in LWC**. The LWC controller uses a **JavaScript variable** (`this.eventData`) to hold all state client-side. The Apex `saveRegistration()` is called on each "Next" click and returns an **encrypted registration ID** that is stored back in `eventData.primaryRegistration.registrationRecord.Id`.

When resuming: pass `registrationId=<encryptedId>` in the URL. Apex decrypts it and loads the existing registration.

**URL parameters supported** (all case variants handled):
```
?instanceId=<id>       (preferred)
?instanceID=<id>       (VF backward compat — capital D)
?eventInstanceId=<id>  (alternate)
?id=<id>               (shorthand)
?registrationId=<enc>  (resume existing)
?regId=<enc>           (shorthand resume)
```

### LWC Multi-Step Flow

1. `connectedCallback` fires → reads URL params → calls `getSummitEventData()`
2. Apex returns complete `SummitEventWrapper` with all pages, data, config
3. Controller renders the active page via `{currentPageType}` conditional in template
4. User fills form → clicks "Next" → `handleNext()` fires:
   a. `currentPage.validate()` → if false, stop
   b. `currentPage.getData()` → merge into `this.eventData`
   c. `saveRegistration(JSON.stringify(this.eventData))` Apex call
   d. Advance page index
5. On "Submit": same flow but Apex finalizes registration status
6. Navigate to confirmation page with encrypted ID

---

## 4. Apex Controller — SummitEventsLWCController

**File**: `force-app/main/default/classes/SummitEventsLWCController.cls`

### Key Methods

| Method | Description |
|---|---|
| `getSummitEventData(String eventInstanceId, String registrationId)` | Loads everything in one call. Returns `SummitEventWrapper`. |
| `saveRegistration(String wrapperJson)` | Persists the full registration state. Returns encrypted registration ID. |
| `buildPageInfo(...)` | Determines which pages to show and in what order |
| `buildEventConfiguration(...)` | Builds `EventConfiguration` config flags |

### `getSummitEventData` — What It Loads

1. Queries `Summit_Events_Instance__c` with all Event fields via relationship
2. Queries `Summit_Events_Question__c` for registrant and guest questions
3. Queries `Summit_Events_Appointment_Type__c` for all types available for this instance
4. If `registrationId` provided: loads existing registration record + appointments + fees
5. Builds `SummitEventWrapper` with all above data
6. Calls `buildPageInfo()` to determine page sequence
7. Calls `buildEventConfiguration()` to set config flags
8. Initializes `donationSelection` from existing fee records (if resuming)

### `saveRegistration` — What It Persists

1. **Guests**: Serializes `guestRegistrations` array into `Guest_JSON__c` JSON string on the registration record
2. **Primary registration**: Upserts `Summit_Events_Registration__c`
3. **Appointments**: Upserts `Summit_Events_Appointments__c` records; links to `Summit_Events_Registration__c.Id` and `Summit_Events_Appointment_Type__c.Id`
4. **Donation fee**: If `donationSelection.amount > 0`, upserts a `Summit_Events_Fee__c` record with `Event_Fee_Type__c = 'Optional Donation'`
5. Returns `SummitEventsShared.encryptString(registrationId)`

### DML Isolation — `RegistrationCRUD` Inner Class

All DML runs inside `without sharing class RegistrationCRUD`. This is **required** because the Guest User has restricted access, and the registration operations must succeed even when the running user has minimal permissions.

```apex
private without sharing class RegistrationCRUD {
    public String saveRegistration(Summit_Events_Registration__c reg) { ... }
    public void upsertAppointments(List<Summit_Events_Appointments__c> apts) { ... }
    public void upsertFee(Summit_Events_Fee__c fee) { ... }
}
```

---

## 5. Complete Data Structures

### SummitEventWrapper (Apex → JS)

```javascript
{
    // Page flow (built by buildPageInfo)
    pages: [PageInfo, ...],
    currentPageIndex: 0,

    // Primary registrant
    primaryRegistration: {
        registrationRecord: {},   // Summit_Events_Registration__c SObject
        appointments: [],         // Summit_Events_Appointments__c[] (selected)
        isGuest: false
    },

    // Guest registrants (each is a Registration object)
    guestRegistrations: [
        {
            registrationRecord: { FirstName__c, LastName__c, Email__c, ... },
            appointments: [],
            isGuest: true
        }
    ],

    // Event/instance data
    instance: {},                 // Summit_Events_Instance__c
    eventInfo: {                  // Summit_Events__c
        // Includes ALL lookup relationship fields via __r:
        Donation_Allocation_1__c: 'recordId',
        Donation_Allocation_1__r: { Name: 'General Fund' },
        Donation_Allocation_2__c: ...,
        // through Donation_Allocation_5__c / __r
        Donation_Suggested_Amount_List__c: '10\n25\n50\n100',
        Guest_Max_Amount__c: 5,
        Event_Fee__c: 50.00,
    },

    // Appointment types map (KEY: appointment type Id → VALUE: type record)
    // ⚠️ Comes from Apex as Map<Id, SObject> — serializes to a JS OBJECT, not Array!
    // Access in JS: Object.values(eventData.appointmentTypes)
    appointmentTypes: {
        'a0X...' : {
            Id: 'a0X...',
            Title__c: 'Campus Tour',
            Description__c: '...',
            Appointment_Category__c: 'Tour',
            Registrant_Input__c: 'Text box',   // or 'Required text box', 'Custom pick list', 'Required custom pick list', null
            Chosen_State__c: 'Added',           // or 'Added and Required', 'Added but not shown', null
            Available_Appointments__c: '9:00 AM\n10:00 AM\n11:00 AM',  // newline-delimited
            // Appointment_Capacity fields, etc.
        }
    },

    // Questions
    registrantQuestions: [SummitEventsQuestionWrapper, ...],
    guestQuestions: [SummitEventsQuestionWrapper, ...],

    // Config flags (from buildEventConfiguration)
    config: {
        hasAdditionalQuestions: Boolean,
        hasAppointments: Boolean,
        hasGuestRegistration: Boolean,
        hasDonations: Boolean,
        hasEventFee: Boolean,
        askThirdPartyRegistrant: Boolean,
        showDietaryRestrictions: Boolean,
        showAccessibilityNeeds: Boolean,
        showGenderPronouns: Boolean,
        // ... more display flags
    },

    // Fees loaded from org (existing fee records for this registration)
    fees: [Summit_Events_Fee__c, ...],
    totalEventCost: 0.00,

    // Donation selection (set by summitEventsDonationPage.getData())
    donationSelection: {
        amount: 25.00,            // Decimal
        allocationId: 'a1Y...',   // Id of Summit_Events_Fee_Allocation__c
        existingFeeId: 'a2Z...'   // Id of existing Summit_Events_Fee__c (for upsert)
    },

    // reCAPTCHA
    recaptcha: {
        enabled: Boolean,
        siteKey: 'xxx'
    }
}
```

### PageInfo Object

```javascript
{
    pageType: 'register',      // 'register' | 'questions' | 'appointments' | 'guests' | 'donation' | 'submit' | 'confirmation'
    pageIndex: 0,
    pageName: 'Registration',
    pageMetaTitle: 'Event Registration',
    pageHeading: 'Register for Event',
    pageSubheading: 'Spring 2026 Open House',
    pageDescription: '<p>Welcome to our event...</p>',
    isActive: true             // only one page is active at a time
}
```

### SummitEventsQuestionWrapper

```javascript
{
    Id: 'a3A...',
    fieldName: 'Registrant_Answer_1__c',
    questionText: 'What is your major?',
    questionType: 'Registrant',            // or 'Guest'
    questionFieldType: 'Picklist',         // matches lightning-combobox etc.
    questionPicklistValues: ['Biology', 'Chemistry', ...],
    required: true,
    helpText: '...',
    instructions: '...',
    currentValue: '',                      // populated when resuming
    controllingQuestion: 'Registrant_Answer_2__c',   // null if standalone
    controllingValues: ['Biology', 'Chemistry']       // show only when controlling q = one of these
}
```

### DonationSelection (new — added March 2026)

```javascript
// Lives at eventData.donationSelection
{
    amount: Decimal,          // 0 means no donation
    allocationId: String,     // Id of Summit_Events_Fee_Allocation__c (null if no allocation chosen)
    existingFeeId: String     // Id of Summit_Events_Fee__c if already saved (for upsert, not insert)
}
```

---

## 6. Object & Field Reference

### Summit_Events__c (Event)

| Field | Type | Notes |
|---|---|---|
| `Donation_Suggested_Amount_List__c` | LongTextArea | Newline-delimited list: `10\n25\n50\n100` |
| `Donation_Allocation_1__c` through `5__c` | Lookup(Summit_Events_Fee_Allocation__c) | Up to 5 designations |
| `Guest_Max_Amount__c` | Number | Max guests per registration |
| `Event_Fee__c` | Currency | Base registration fee |
| `Event_Name__c` | Text | Display name |

### Summit_Events_Appointment_Type__c

| Field | Type | Values/Notes |
|---|---|---|
| `Title__c` | Text | Display title |
| `Description__c` | LongTextArea | Description shown to registrant |
| `Appointment_Category__c` | Text | Category label |
| `Registrant_Input__c` | Picklist | `null` (no input), `'Text box'`, `'Required text box'`, `'Custom pick list'`, `'Required custom pick list'` |
| `Chosen_State__c` | Picklist | `null`, `'Added'`, `'Added and Required'`, `'Added but not shown'` |
| `Available_Appointments__c` | LongTextArea | Newline-delimited option list (for picklist input types) |

**`Chosen_State__c` behavior**:
- `null` — shown as available, not pre-selected
- `'Added'` — auto-added to selections on page load; user can remove
- `'Added and Required'` — auto-added; user cannot remove; blocked until selected
- `'Added but not shown'` — silently added to submission; not rendered in UI

### Summit_Events_Appointments__c

| Field | Notes |
|---|---|
| `Summit_Events_Registration__c` | Lookup to registration |
| `Event_Appointment_Type__c` | Lookup to appointment type |
| `Appointment_Title__c` | Copied from type title |
| `Appointment_Category__c` | Copied from type category |
| `Chosen_State__c` | Copied from type |
| `Registrant_Input__c` | The user's text input or selected picklist value |

### Summit_Events_Registration__c

| Field | Notes |
|---|---|
| `Summit_Events_Instance__c` | Lookup to instance |
| `Status__c` | Picklist: `'Started'`, `'Submitted'` (set on final submit) |
| `Guest_JSON__c` | LongTextArea — serialized JSON array of guest data |
| `Registrant_Answer_1__c` through `8__c` | Answers to additional questions |
| `FirstName__c`, `LastName__c`, `Email__c` | Basic registrant info |
| (many more fields) | See object definition |

### Summit_Events_Fee__c

| Field | Notes |
|---|---|
| `Summit_Events_Registration__c` | Lookup to registration |
| `Event_Fee_Type__c` | Picklist: `'Event Registration'`, `'Optional Donation'`, `'Appointment'` |
| `Event_Fee_Allocation__c` | Lookup to `Summit_Events_Fee_Allocation__c` (for donations) |
| `Event_Fee__c` | Currency amount |

### Summit_Events_Fee_Allocation__c

Used for donation designations (e.g., "General Fund", "Scholarship Fund").

---

## 7. Page-by-Page Implementation Details

### summitEventsRegisterPage ✅

**File**: `force-app/main/default/lwc/summitEventsRegisterPage/`  
**Status**: Complete  
**VF equivalent**: `SummitEventsRegister.page`

- Dynamic field rendering based on `config` flags
- Uses `lightning-input-address` for mailing address
- Validates all required fields via `lightning-input` native validation
- `getData()` returns updated `registrationRecord` fields

---

### summitEventsQuestionsPage ✅

**File**: `force-app/main/default/lwc/summitEventsQuestionsPage/`  
**Status**: Complete  
**VF equivalent**: `SummitEventsRegisterAdditional.page`

- Renders `c-summit-events-question-field` for each question in `registrantQuestions`
- Controlling question logic (show/hide based on other answer)
- Listens to `questionchange` events from child components
- `getData()` returns answers mapped to `Registrant_Answer_N__c` fields

---

### summitEventsQuestionField ✅

**File**: `force-app/main/default/lwc/summitEventsQuestionField/`  
**Status**: Complete  
**Dispatches**: `questionchange` event with `{ fieldName, value }`

Supported `questionFieldType` values:
- `'Text'` → `lightning-input type="text"`
- `'Text Area'` → `lightning-textarea`
- `'Email'` → `lightning-input type="email"`
- `'Phone'` → `lightning-input type="phone"`
- `'Number'` → `lightning-input type="number"`
- `'Date'` → `lightning-input type="date"`
- `'Checkbox'` → `lightning-input type="checkbox"`
- `'Picklist'` → `lightning-combobox`
- `'Multi-Select Picklist'` → `lightning-dual-listbox`
- `'Radio Group'` → `lightning-radio-group`
- `'Lookup'` → placeholder (not yet implemented)

---

### summitEventsAppointmentsPage ✅

**File**: `force-app/main/default/lwc/summitEventsAppointmentsPage/`  
**Status**: Implemented March 2026  
**VF equivalent**: `SummitEventsRegisterAppointments.page`

**HTML layout**:
- Two-column grid (SLDS `slds-grid slds-gutters`)
- Left column: available (not-yet-selected) types, each with "Add" button
- Right column: selected appointments, each with "Remove" button
- Required types show asterisk and cannot be removed
- Validation error banner appears above columns if required type missing

**JS patterns**:
- `connectedCallback`: converts `appointmentTypes` Map (`Object.values()`) to flat array `_allTypes`
- Auto-adds types where `Chosen_State__c === 'Added'` or `'Added and Required'`
- `availableTypes` getter: filters `_allTypes` to exclude already-selected
- `handleAdd(event)`: reads `data-type-id` from button, adds to `_selections`
- `handleRemove(event)`: reads `data-selection-id` from button, removes from `_selections`
- `handleInputChange(event)`: for text/picklist inputs on selected appointments
- `validate()`: checks all required types are selected; shows banner if not
- `getData()`: returns `{ primaryRegistration: { ...eventData.primaryRegistration, appointments: [...] } }`

**⚠️ appointmentTypes is a Map — not an Array**:
```javascript
// ❌ WRONG — cannot iterate a Map serialized to JS object
this.eventData.appointmentTypes.forEach(...)

// ✅ CORRECT
const allTypes = Object.values(this.eventData.appointmentTypes || {});
```

---

### summitEventsGuestsPage ✅

**File**: `force-app/main/default/lwc/summitEventsGuestsPage/`  
**Status**: Implemented March 2026  
**VF equivalent**: `SummitEventsRegisterGuests.page`

**HTML layout**:
- Two-column layout (4/12 form + 8/12 list) using SLDS grid
- When no `guestQuestions` configured: simple First Name, Last Name, Email inputs
- When `guestQuestions` configured: renders `c-summit-events-question-field` for each
- Guest list on right: shows each added guest with Remove button
- "Add Guest" button validates form first
- **Unsaved modal**: `lwc:if={showUnsavedModal}` — appears when user tries to navigate away with unsaved form data

**JS patterns**:
- `_guests` — tracked array of guest objects `{ id, firstName, lastName, email, questionAnswers: {} }`
- `_nextGuestId` — counter for unique local IDs
- `connectedCallback`: restores `_guests` from `eventData.guestRegistrations`
- `_formHasData()`: checks whether any form field has a value (unsaved data detection)
- `_clearForm()`: resets `_currentGuest` tracked state and calls `reset()` on question field children
- `handleAddGuest()`: validates form, pushes to `_guests`, clears form
- `handleRemoveGuest(event)`: removes by `data-guest-id`
- `handleGuestQuestionChange(event)`: stores answers in `_currentGuest.questionAnswers`
- `validate()`: if `_formHasData()`, sets `showUnsavedModal = true` and returns `false`
- `getData()`: builds `guestRegistrations` array for `SummitEventWrapper`

**Max guests enforcement**:
```javascript
get canAddMore() {
    const max = this.eventData?.eventInfo?.Guest_Max_Amount__c;
    return !max || this._guests.length < max;
}
```

---

### summitEventsDonationPage ✅

**File**: `force-app/main/default/lwc/summitEventsDonationPage/`  
**Status**: Implemented March 2026  
**VF equivalent**: `SummitEventsDonation.page`

**HTML layout**:
- Amount combobox (suggested amounts + "Other Amount" option)
- When "Other Amount" selected: `lightning-input type="number"` appears
- Designation combobox (rendered only when `hasAllocations` — at least one allocation field populated)

**JS getters**:
```javascript
get suggestedAmounts() {
    // Parses Donation_Suggested_Amount_List__c (newline-delimited)
    // Returns array of { label, value } combobox options
    // Appends "Other Amount" option at end
}

get donationAllocations() {
    // Iterates Donation_Allocation_1__c through 5__c
    // Returns array of { label: allocation.__r.Name, value: allocation.Id }
    // Only includes populated allocation slots
}

get hasAllocations() {
    return this.donationAllocations.length > 0;
}

get showCustomAmount() {
    return this._selectedAmount === 'other';
}
```

**getData()**:
```javascript
getData() {
    const amount = this._selectedAmount === 'other'
        ? parseFloat(this._customAmount) || 0
        : parseFloat(this._selectedAmount) || 0;
    return {
        donationSelection: {
            amount,
            allocationId: this._selectedAllocationId || null,
            existingFeeId: this.eventData?.donationSelection?.existingFeeId || null
        }
    };
}
```

---

### summitEventsSubmitPage ✅

**File**: `force-app/main/default/lwc/summitEventsSubmitPage/`  
**Status**: Implemented March 2026  
**VF equivalent**: `SummitEventsSubmit.page`

**HTML layout** (read-only review):
- Guest summary section (if any guests added)
- Appointments summary (dotted list; filters out `'Added but not shown'` types)
- Fees table:
  - Event base fee row (if `totalEventCost > 0`)
  - Donation row (if `donationAmount > 0`)
  - **Total row** (sum)

**Key getters**:
```javascript
get guestSummary() {
    return (this.eventData?.guestRegistrations || [])
        .map(g => `${g.registrationRecord?.FirstName__c} ${g.registrationRecord?.LastName__c}`);
}

get appointmentSummary() {
    // Filters out 'Added but not shown' types — user never saw them, don't show in review
    return (this.eventData?.primaryRegistration?.appointments || [])
        .filter(a => a.Chosen_State__c !== 'Added but not shown')
        .map(a => a.Appointment_Title__c);
}

get donationAmount() {
    return this.eventData?.donationSelection?.amount || 0;
}

get totalAmount() {
    return (this.eventData?.totalEventCost || 0) + this.donationAmount;
}
```

**validate() and getData()**: Both return trivially true/empty — submit page is read-only, no user input.

---

### summitEventsConfirmationPage ✅

**File**: `force-app/main/default/lwc/summitEventsConfirmationPage/`  
**Status**: Complete  
**VF equivalent**: `SummitEventsRegisterConfirm.page`

- Terminal page — no Next/Previous buttons
- Shows success message and registration details
- Displays content from page description/heading configured on the event

---

## 8. Authentication, Cookies & State

### VF Cookie Flow

```
Page 1 (Register):
  - Form submitted → saveRegistration() → new Registration record created
  - Cookie "SummitEventsRegistrant" = encryptedId set on HTTP response
  - Redirect to Page 2

Page 2+ (Any subsequent page):
  - Request arrives → readCookie("SummitEventsRegistrant")
  - Decrypt → get Registration Id → load record
  - On save: update record, update cookie, redirect to next page

Direct navigation to Page 2:
  - No cookie → controller gets null registration → redirects to error/login
  - ⚠️ This is why you can't deep-link into inner pages!
```

### LWC State Flow

```
Initial load:
  - URL contains ?instanceId=<id>
  - connectedCallback → getSummitEventData({ eventInstanceId, registrationId: null })
  - eventData populated in memory

Each "Next" click:
  - validate() → getData() → merge → saveRegistration(JSON) → returns encryptedId
  - encryptedId stored in eventData.primaryRegistration.registrationRecord.Id

Resuming a registration:
  - URL contains ?registrationId=<encryptedId>
  - getSummitEventData({ eventInstanceId, registrationId: encryptedId })
  - Apex decrypts, loads existing record + all related data
```

---

## 9. Security Model

### Guest User Context

- All registration pages are accessible to the Salesforce Guest User (no login)
- Guest User has limited DML capabilities configured via Profile
- All Apex DML runs in `without sharing class RegistrationCRUD` to bypass sharing rules
- SOQL uses `WITH USER_MODE` for SELECT queries (respects FLS)
- ⚠️ `WITH USER_MODE` must come BEFORE `ORDER BY`, `LIMIT`, `OFFSET` in dynamic SOQL

### Encryption

- Registration IDs encrypted/decrypted via `SummitEventsShared.encryptString()` / `decryptString()`
- Uses AES256 with a 32-character key stored in `Summit_Events_Settings__c.Encryption_Key__c`
- Encrypted IDs are passed in URLs and cookies — prevents direct ID manipulation

### Apex Security Checklist

- `@AuraEnabled` methods callable from Experience Cloud LWC
- All `@AuraEnabled` methods must have CRUD/FLS guards (ApexCRUDViolation prevention)
- Never expose internal Salesforce record IDs unencrypted in URLs

---

## 10. Known Differences VF vs LWC

| Behavior | Visualforce | LWC |
|---|---|---|
| **State persistence** | HTTP cookie per page | In-memory JS object, Apex save on each Next |
| **Page navigation** | Full HTTP redirect | Client-side render swap (no page reload) |
| **Progress indicator** | Custom VF markup | SLDS `slds-progress-indicator` (LWC) |
| **Address input** | Custom VF address fields | `lightning-input-address` (LWC) |
| **Appointment input (textbox)** | `<apex:inputTextarea>` | `lightning-textarea` (LWC) |
| **Appointment input (picklist)** | `<apex:selectList>` with `<apex:selectOptions>` | `lightning-combobox` (LWC) |
| **Guest questions** | `guestQuestionJSON` VF variable | `c-summit-events-question-field` reused (LWC) |
| **Donation amounts** | VF `<apex:selectList>` | `lightning-combobox` (LWC) |
| **Fee calculation display** | VF page (with server refresh) | Client-side getters in `summitEventsSubmitPage` |
| **reCAPTCHA** | Native VF integration | Not yet implemented (LWC) |
| **Confirmation email** | Triggered by Apex on submit | Same Apex path — works identically |
| **Direct URL deep-linking** | Blocked by cookie requirement | Works when `registrationId` in URL |

---

*This document was written from deep source code analysis of `SummitEventsLWCController.cls`, all 7 VF registration pages, all 4 new LWC page components, and supporting Apex classes. Update it when any page component, Apex controller, or data structure changes.*

