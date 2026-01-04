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
├── summitEventsAppointmentsPage 🔨 TODO
├── summitEventsGuestsPage 🔨 TODO
├── summitEventsDonationPage 🔨 TODO
├── summitEventsSubmitPage 🔨 TODO
└── summitEventsConfirmationPage ✅ COMPLETE
```

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
    guestRegistrations: [],       // Registration[]
    instance: {},                 // Summit_Events_Instance__c
    eventInfo: {},                // Summit_Events__c
    appointmentTypes: {},         // Map<Id, Summit_Events_Appointment_Type__c>
    registrantQuestions: [],      // SummitEventsQuestionWrapper[]
    guestQuestions: [],           // SummitEventsQuestionWrapper[]
    config: {                     // EventConfiguration
        hasAdditionalQuestions: Boolean,
        hasAppointments: Boolean,
        hasGuestRegistration: Boolean,
        hasDonations: Boolean,
        hasEventFee: Boolean,
        askThirdPartyRegistrant: Boolean,
        // ... more config flags
    },
    fees: [],                     // Summit_Events_Fee__c[]
    totalEventCost: 0,
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

### Priority 1: Appointments Page
**File**: `summitEventsAppointmentsPage`

**Requirements**:
- Display available appointment types from `eventData.appointmentTypes`
- Allow single/multiple selection based on config
- Handle time slots if configured
- Validate required appointments
- Support both primary and guest appointments

**Key Data**:
```javascript
appointmentTypes: Map<Id, {
    Name: String,
    Title: String,
    Description: String,
    Appointment_Type_Mode: String, // 'Multi-Option' | 'Single-Option'
    Required: Boolean,
    // ... more fields
}>
```

### Priority 2: Guests Page
**File**: `summitEventsGuestsPage`

**Requirements**:
- Add/remove guest registrations
- Guest form with same questions as primary
- Guest-specific questions if configured
- Max guests validation
- Guest appointments (NEW feature!)

### Priority 3: Donation Page
**File**: `summitEventsDonationPage`

**Requirements**:
- Display donation allocations
- Suggested amounts vs custom amount
- Multiple allocations support
- Update total cost

### Priority 4: Submit Page
**File**: `summitEventsSubmitPage`

**Requirements**:
- Display complete registration summary
- Show all data: registrant, guests, appointments, fees
- Allow navigation back to edit
- reCAPTCHA integration
- Submit to Apex

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

### v1.0 - January 2, 2026
- Initial LWC implementation
- ✅ Main controller with page flow
- ✅ Register page (all standard fields)
- ✅ Questions page (all field types)
- ✅ Question field renderer (11+ types)
- ✅ Confirmation page
- ✅ Apex wrapper class
- 🔨 Placeholder pages (Appointments, Guests, Donation, Submit)

### Known Issues
- None currently

### Technical Debt
- Add console logging for debugging (removed for deployment)
- Implement lookup component (port from other repo)
- Add reCAPTCHA integration
- Add payment gateway integration
- Email confirmation automation

---

**For Questions**: Review existing components in `force-app/main/default/lwc/` or check documentation in `docs/` folder.

