# AI Tools Configuration - Summit Events App

**Last Updated**: January 2, 2026  
**Project**: Summit Events App - LWC Migration  
**Primary Developer**: Thaddaeus Dahlberg

---

## Project Overview

### Mission
Migrate Summit Events App from Visualforce to Lightning Web Components (LWC) while maintaining complete feature parity with the existing registration system.

### Architecture
- **Frontend**: Lightning Web Components (LWC)
- **Backend**: Apex controllers with "Apex-First" data loading pattern
- **Platform**: Salesforce Experience Cloud (Communities)
- **Build Tool**: CumulusCI (Python-based)
- **Org Type**: Scratch orgs (NOT production)

---

## SEA Access Model (Critical for Testing & BackstopJS)

Understanding who can access what is essential before writing any test URLs or BackstopJS scenarios.

### Public Guest Access (No Login Required)
- **SEA registration pages are fully public** — guest users can register without any authentication
- This applies to all registration flow pages: Register, Additional Questions, Appointments, Guests, Donation, Submit, Confirmation
- VF URL pattern: `https://<org>/apex/SummitEventsRegister?instanceId=<id>`
- LWC URL pattern: `https://<org>/s/<page-slug>?instanceId=<id>` (Experience Cloud)
- **BackstopJS implication: NO login script needed** for registration page screenshots

### Authenticated Community Access (Optional Enhancement)
- When a user is logged in via an Experience Cloud community, SEA detects the session
- SEA will **pre-fill contact information** on the registration form from the authenticated user's Contact record
- This is an enhancement — the same pages work for both guest and logged-in users
- BackstopJS can test both scenarios: one scenario set without auth, one with auth

### Admin / Event Management (Login Required)
- Creating and configuring events requires Salesforce org login
- Administrators manipulate Summit Events objects (`Summit_Events__c`, `Summit_Events_Instance__c`, etc.)
- Completed registrations are recorded on `Summit_Events_Registration__c` — only viewable by admins when logged in
- Not relevant to the public-facing LWC registration pages we're building/comparing

### Scratch Org Test Data
- Scratch orgs come with **pre-defined sample events** at varying stages of configuration
- **Not all events activate all pages** — some events have additional questions, appointments, donations, guests enabled; others don't
- When setting up BackstopJS scenarios, find an event instance that has ALL features enabled to maximize page coverage
- Query to find event instances: `SELECT Id, Name, Event__r.Event_Name__c FROM Summit_Events_Instance__c`
- To check which pages are active for an instance, look at the `config` flags in `SummitEventWrapper` returned by `SummitEventsLWCController`

---

## Critical Deployment Rules

### ⚠️ NEVER DO THIS
```powershell
# DON'T - This rebuilds the entire org and loses all setup!
cci flow run dev_org --org dev
```

### ✅ ALWAYS DO THIS
```powershell
# Targeted deploy for LWC changes
cci task run deploy --path force-app/main/default/lwc --org dev

# Targeted deploy for Apex changes
cci task run deploy --path force-app/main/default/classes --org dev

# Single component deploy
cci task run deploy --path force-app/main/default/lwc/componentName --org dev
```

**Why**: Full org rebuilds delete all data, settings, and test configurations. Use targeted deploys to preserve the working environment.

---

## LWC Implementation - Critical Patterns

### 1. Reactivity (Most Important!)

**Problem**: LWC doesn't detect deep object mutations
```javascript
// ❌ WRONG - Won't trigger re-render
this.eventData.pages[0].isActive = true;
this.data.array[0].property = 'value';
```

**Solution**: Create new objects/arrays
```javascript
// ✅ CORRECT - Triggers reactivity
this.eventData = {
    ...this.eventData,
    pages: this.eventData.pages.map((page, idx) => ({
        ...page,
        isActive: idx === newIndex
    }))
};
```

### 2. Template Expressions

**Problem**: Computed property access not allowed in LWC templates
```html
<!-- ❌ WRONG - LWC1038 error -->
<template for:each={questions} for:item="question">
    <div>{answers[question.field]}</div>
</template>
```

**Solution**: Use object properties or getters
```html
<!-- ✅ CORRECT -->
<template for:each={questions} for:item="question">
    <div>{question.currentValue}</div>
</template>
```

### 3. Reserved Keywords

**Avoid these as class names**:
- `Page` (Visualforce namespace)
- `User` (System namespace)
- `Account`, `Contact`, etc. (Standard objects)

**Use instead**: `PageInfo`, `UserData`, etc.

### 4. @track vs @api

- `@track` - For internal reactive state (use for arrays/objects that change)
- `@api` - For public properties (parent can set, use for simple types)

**Example**:
```javascript
export default class MyComponent extends LightningElement {
    @api eventInstanceId;  // Public property (parent sets this)
    @track eventData;      // Internal state (component manages this)
    @track currentPageIndex = 0;  // Internal state
}
```

---

## Apex-First Pattern

### Single Data Load Strategy

**Don't**: Make multiple server calls
```javascript
// ❌ WRONG - Multiple round trips
connectedCallback() {
    getEvent().then(event => this.event = event);
    getQuestions().then(questions => this.questions = questions);
    getAppointments().then(appts => this.appointments = appts);
    // 3+ server round trips!
}
```

**Do**: Load everything in one call
```javascript
// ✅ CORRECT - Single server call
connectedCallback() {
    getSummitEventData({ eventInstanceId: this.eventInstanceId })
        .then(result => {
            this.eventData = result; // Contains everything!
            // event, questions, appointments, fees, etc.
        });
}
```

### Wrapper Class Pattern

See `SummitEventsLWCController.cls` for the complete implementation:
- Single `@AuraEnabled` method returns all data
- Wrapper classes for type safety
- Normalized data structure for easy consumption
- Encrypted IDs for security

---

## File Creation Best Practices

### Issue: File Corruption
When creating JavaScript files, they sometimes get scrambled/reversed during generation.

### Prevention
1. **Create files directly** - Don't use multiple edit operations
2. **Verify immediately** - Check first 10 lines after creation
3. **Delete and recreate** if corrupted - Don't try to fix scrambled content

### Detection
```powershell
# Check first 3 lines of all JS files
Get-ChildItem -Recurse -Filter "*.js" | ForEach-Object { 
    Write-Host $_.Name
    Get-Content $_.FullName -TotalCount 3 
}
```

If you see reversed/scrambled code, delete and recreate the file.

---

## Component Architecture

### Current Implementation

```
summitEventsRegistration (Controller)
├── summitEventsRegisterPage ✅ COMPLETE
│   └── Uses lightning-input-address for addresses
├── summitEventsQuestionsPage ✅ COMPLETE
│   └── summitEventsQuestionField ✅ COMPLETE (11+ field types)
├── summitEventsAppointmentsPage ✅ COMPLETE (March 2026)
├── summitEventsGuestsPage ✅ COMPLETE (March 2026)
│   └── summitEventsQuestionField ✅ (reused for guest questions)
├── summitEventsDonationPage ✅ COMPLETE (March 2026)
├── summitEventsSubmitPage ✅ COMPLETE (March 2026)
└── summitEventsConfirmationPage ✅ COMPLETE
```

**Deep technical reference**: See `docs/SEA-REGISTRATION-ARCHITECTURE.md` for:
- VF architecture and patterns (cookies, page-by-page flow, UI details)
- LWC architecture and page component contract
- Complete `SummitEventWrapper` data structure
- Object & field reference (appointments, guests, donations)
- VF vs LWC differences table

### Controller Pattern

**Main Controller** (`summitEventsRegistration`):
- Manages page flow and navigation
- Validates current page before advancing
- Saves data from child components
- Handles submission to Apex
- **Reads URL parameters for instance ID and registration ID**

**URL Parameters Supported**:
- `instanceId`, `instanceID` (capital D), `eventInstanceId`, or `id` - The Summit Events Instance ID
- `registrationId`, `registrationID` (capital D), or `regId` - Encrypted registration ID for resuming

**⚠️ Case Sensitivity**:
- JavaScript URL parameters are **case-sensitive**
- Visualforce uses `instanceID` (capital D)
- Component supports BOTH `instanceID` and `instanceId`

**Example URLs**:
```
/registration?instanceId=a1X5e000000ABCD
/registration?instanceID=a1X5e000000ABCD  (capital D - Visualforce backward compatibility)
/registration?id=a1X5e000000ABCD&registrationId=abc123encrypted
```

**Component Properties** (Optional):
- Can still set via `@api eventInstanceId` and `@api registrationId`
- **URL parameters OVERRIDE component properties** (for dynamic navigation)
- Matches Visualforce behavior

**Page Components**:
- Must implement `@api validate()` method
- Must implement `@api getData()` method
- Return data in format that merges with `eventData`

### Example Page Component
```javascript
export default class SummitEventsMyPage extends LightningElement {
    @api eventData;
    
    @api
    validate() {
        const inputs = this.template.querySelectorAll('lightning-input');
        return Array.from(inputs).reduce((valid, input) => {
            input.reportValidity();
            return valid && input.checkValidity();
        }, true);
    }
    
    @api
    getData() {
        return {
            primaryRegistration: {
                ...this.eventData.primaryRegistration,
                registrationRecord: this.formData
            }
        };
    }
}
```

---

## Data Structures

### SummitEventWrapper (from Apex)
```javascript
{
    pages: [],                    // PageInfo objects
    currentPageIndex: 0,
    primaryRegistration: {
        registrationRecord: {},   // Summit_Events_Registration__c
        appointments: [],         // Summit_Events_Appointments__c[]
        isGuest: false
    },
    guestRegistrations: [],       // Registration[] (serialized to Guest_JSON__c on save)
    instance: {},                 // Summit_Events_Instance__c
    eventInfo: {                  // Summit_Events__c (includes __r relationship fields)
        Donation_Suggested_Amount_List__c: '10\n25\n50',  // newline-delimited
        Donation_Allocation_1__c: 'Id',  // through ..._5__c
        Donation_Allocation_1__r: { Name: 'General Fund' },
        Guest_Max_Amount__c: 5,
        Event_Fee__c: 50.00,
    },
    // ⚠️ appointmentTypes is a MAP — serializes to a JS OBJECT, not Array!
    // ALWAYS use Object.values(eventData.appointmentTypes || {}) to iterate
    appointmentTypes: {           // Map<Id, Summit_Events_Appointment_Type__c>
        'a0X...' : { Id, Title__c, Registrant_Input__c, Chosen_State__c, ... }
    },
    registrantQuestions: [],      // SummitEventsQuestionWrapper[]
    guestQuestions: [],           // SummitEventsQuestionWrapper[]
    config: {                     // EventConfiguration flags
        hasAdditionalQuestions: Boolean,
        hasAppointments: Boolean,
        hasGuestRegistration: Boolean,
        hasDonations: Boolean,
        hasEventFee: Boolean,
        // ... more display flags
    },
    fees: [],                     // Summit_Events_Fee__c[] (existing fees for this registration)
    totalEventCost: 0,
    donationSelection: {          // Set by summitEventsDonationPage.getData()
        amount: 0,                // Decimal — 0 means no donation
        allocationId: null,       // Id of Summit_Events_Fee_Allocation__c
        existingFeeId: null       // Id of existing Summit_Events_Fee__c (for upsert)
    },
    recaptcha: {}                 // RecaptchaInfo
}
```

### PageInfo Object
```javascript
{
    pageType: 'register',    // 'register' | 'questions' | 'appointments' | 'guests' | 'donation' | 'submit' | 'confirmation'
    pageIndex: 0,
    pageName: 'Registration',
    pageMetaTitle: 'Event Registration',
    pageHeading: 'Register for Event',
    pageSubheading: 'Spring 2026',
    pageDescription: '<p>Welcome...</p>',
    isActive: true
}
```

---

## Question Field Types Supported

The `summitEventsQuestionField` component supports:

1. ✅ Text
2. ✅ Text Area
3. ✅ Email
4. ✅ Phone
5. ✅ Number
6. ✅ Date
7. ✅ Checkbox
8. ✅ Picklist (from field or custom values)
9. ✅ Multi-Select Picklist
10. ✅ Radio Group
11. ⚠️ Lookup (placeholder - needs custom implementation)

### Adding a New Field Type

1. Add getter to check field type:
```javascript
get isMyNewType() {
    return this.question?.questionFieldType === 'My New Type';
}
```

2. Add template section:
```html
<template if:true={isMyNewType}>
    <lightning-my-component
        label={label}
        value={inputValue}
        required={isRequired}
        onchange={handleInputChange}>
    </lightning-my-component>
</template>
```

---

## Testing Checklist

Before declaring a component "done":

- [ ] Deploys without errors
- [ ] All required fields validate
- [ ] Optional fields work correctly
- [ ] Data saves when clicking Next
- [ ] Data persists when going back
- [ ] Conditional fields show/hide properly
- [ ] Error messages display correctly
- [ ] Works in Experience Cloud (not just org)
- [ ] Guest user can access (if applicable)

---

## Common Errors & Solutions

### Error: LWC1038 - Template expression doesn't allow computed property access
**Solution**: Don't use bracket notation in templates. Use object properties or create getters.

### Error: LWC1503 - Parsing error
**Solution**: File is corrupted/scrambled. Delete and recreate.

### Error: Cannot resolve symbol PageInfo
**Solution**: File has `Page` instead of `PageInfo` (reserved keyword issue).

### Error: Illegal assignment from List<PageInfo> to List<Page>
**Solution**: Duplicate class definitions or incorrect type references.

### Error: Method does not exist or incorrect signature
**Solution**: Check method signature in Apex class. May need additional parameters.

---

## Guest User Permissions

For Experience Cloud registration to work:

### Objects (Read)
- Summit_Events__c
- Summit_Events_Instance__c
- Summit_Events_Question__c
- Summit_Events_Appointment_Type__c

### Objects (Create/Update)
- Summit_Events_Registration__c
- Summit_Events_Appointments__c
- Summit_Events_Fee__c

### Field-Level Security
Grant access to all fields used in registration on above objects.

**Configure in**: Setup > Users > Profiles > [Site Guest User Profile]

---

## Documentation References

### Project Docs
- `docs/LWC-WRAPPER-CLASS-DOCUMENTATION.md` - Apex wrapper class details
- `docs/LWC-COMPONENTS-GUIDE.md` - Component implementation guide
- `docs/LWC-QUICK-START.md` - Quick reference
- `docs/TROUBLESHOOTING-NAVIGATION.md` - Debug navigation issues

### External Resources
- [LWC Dev Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- [CumulusCI Docs](https://cumulusci.readthedocs.io/)
- [SLDS Components](https://www.lightningdesignsystem.com/components/)

---

## Next Development Tasks

### Priority 1: Deploy & Verify (In Progress)
- Fix `<apiVersion>` in all 4 new component `-meta.xml` files (should be `64.0`)
- Deploy to scratch org: `cci task run deploy --path force-app/main/default --org dev`
- Verify all components render and flow works end-to-end
- Run BackstopJS test to compare VF vs LWC screenshots

### Priority 2: reCAPTCHA
- Integrate reCAPTCHA on submit page (VF had native integration)
- `summitEventsSubmitPage` has a placeholder; needs recaptcha widget rendering

### Priority 3: Lookup Component
- Port custom lookup component from other repository
- Replace placeholder in `summitEventsQuestionField` for `'Lookup'` field type

### Priority 4: Guest Appointments (New Feature)
- VF did not support guest appointments
- LWC architecture supports it via `guestRegistrations[].appointments[]`
- Requires new UX in `summitEventsGuestsPage` and Apex save logic

---

## Code Snippets

### Standard Input Change Handler
```javascript
handleInputChange(event) {
    const field = event.target.dataset.field;
    const value = event.target.value;
    this.formData[field] = value;
}
```

### Standard Validation Pattern
```javascript
@api
validate() {
    const allInputs = this.template.querySelectorAll(
        'lightning-input, lightning-combobox, lightning-textarea, lightning-input-address'
    );
    return Array.from(allInputs).reduce((valid, input) => {
        input.reportValidity();
        return valid && input.checkValidity();
    }, true);
}
```

### Standard getData Pattern
```javascript
@api
getData() {
    return {
        primaryRegistration: {
            ...this.eventData.primaryRegistration,
            registrationRecord: {
                ...this.eventData.primaryRegistration.registrationRecord,
                ...this.formData
            }
        }
    };
}
```

---

## Version History

### v1.1 - March 21, 2026
- ✅ Implemented `summitEventsAppointmentsPage` (two-column UI, auto-add, required validation)
- ✅ Implemented `summitEventsGuestsPage` (guest form, max limit, unsaved modal)
- ✅ Implemented `summitEventsDonationPage` (suggested amounts, allocation designations)
- ✅ Implemented `summitEventsSubmitPage` (read-only review, fees table)
- ✅ Updated `SummitEventsLWCController.cls`: added `DonationSelection` inner class, full `saveRegistration` (appointments, guests, donation fee)
- ✅ Added `docs/SEA-REGISTRATION-ARCHITECTURE.md` — comprehensive VF + LWC architecture reference
- 🔄 Pending: deploy to scratch org, BackstopJS visual comparison, reCAPTCHA

### v1.0 - January 2, 2026
- ✅ Main controller with page flow
- ✅ Register page (all standard fields)
- ✅ Questions page (all field types)
- ✅ Question field renderer (11+ types)
- ✅ Confirmation page
- ✅ Apex wrapper class
- 🔨 Placeholder pages (Appointments, Guests, Donation, Submit)


---

**For Questions**: Review existing components in `force-app/main/default/lwc/` or check documentation in `docs/` folder.

