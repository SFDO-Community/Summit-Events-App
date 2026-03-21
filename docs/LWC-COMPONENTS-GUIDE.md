# Summit Events LWC Components - Implementation Guide

## Overview
This document describes the Lightning Web Component (LWC) implementation for the Summit Events registration flow, built to replace the existing Visualforce pages.

## Component Architecture

### 1. Controller Component: `summitEventsRegistration`
**Purpose**: Main controller that manages the registration flow

**Key Features**:
- Loads all event data with a single Apex call
- Manages page navigation and flow
- Handles validation and data persistence
- Displays progress indicator
- Manages state across all pages
- **Reads URL parameters for instance ID and registration ID** (matches Visualforce behavior)

**URL Parameters Supported**:
- `instanceId`, `eventInstanceId`, or `id` → Event Instance ID
- `registrationId` or `regId` → Encrypted Registration ID

**Example URLs**:
```
/registration?instanceId=a1X5e000000ABCD
/registration?id=a1X5e000000ABCD&registrationId=abc123encrypted
```

**Public Properties** (Optional if using URL params):
- `eventInstanceId` - The Summit Events Instance ID (can be read from URL)
- `registrationId` - Encrypted ID for existing registrations (can be read from URL)

**Usage in Experience Cloud**:
```html
<!-- Option 1: With URL parameters (no properties needed) -->
URL: /registration?instanceId=a1X5e000000ABCD

<!-- Option 2: With component properties -->
<c-summit-events-registration
    event-instance-id="a1X..."
    registration-id="">
</c-summit-events-registration>

<!-- Option 3: Mix (URL takes precedence if API prop not set) -->
URL: /registration?id=a1X...
Component with optional registrationId property
```

### 2. Page Components

#### a. `summitEventsRegisterPage`
**Status**: ✅ Fully Implemented

**Features**:
- Dynamic field rendering based on event configuration
- Uses standard Lightning Address component for addresses
- Validates all required fields
- Supports all configured registration fields:
  - Basic info (First Name, Last Name, Email)
  - Preferred Name
  - Date of Birth
  - Gender & Pronouns
  - Title & Company/Organization
  - Phone
  - Mailing Address
  - Dietary Restrictions
  - Accessibility Needs

#### b. `summitEventsQuestionsPage`
**Status**: ✅ Fully Implemented

**Features**:
- Renders all additional questions for registrants
- Supports controlling question logic
- Uses dynamic question field component
- Validates required questions
- Stores answers in registration record

#### c. `summitEventsQuestionField`
**Status**: ✅ Fully Implemented (except Lookup)

**Supported Field Types**:
- ✅ Text
- ✅ Text Area
- ✅ Email
- ✅ Phone
- ✅ Number
- ✅ Date
- ✅ Checkbox
- ✅ Picklist
- ✅ Multi-Select Picklist
- ✅ Radio Group
- ⚠️ Lookup (placeholder - needs custom implementation)

**Features**:
- Dynamic rendering based on field type
- Required field validation
- Help text and instructions
- Error messages
- Default values
- Text limits

#### d. `summitEventsAppointmentsPage`
**Status**: ✅ Fully Implemented (March 2026)

**Features**:
- Two-column layout: available types (left) → selected appointments (right)
- Auto-adds types with `Chosen_State__c = 'Added'` or `'Added and Required'` on load
- Types with `Chosen_State__c = 'Added but not shown'` silently included (not rendered)
- Per-type input based on `Registrant_Input__c`: text box or custom picklist
- Required appointments validated; cannot be removed; blocks Next if missing
- `validate()` shows error banner if required type not selected
- `getData()` returns `{ primaryRegistration: { appointments: [...] } }`

**⚠️ Key Pattern**: `appointmentTypes` from Apex is a Map (JS object), not an Array.
Use `Object.values(this.eventData.appointmentTypes || {})` to iterate.

#### e. `summitEventsGuestsPage`
**Status**: ✅ Fully Implemented (March 2026)

**Features**:
- Two-column layout: 4/12 form (left) + 8/12 guest list (right)
- Fallback form (First Name, Last Name, Email) when no `guestQuestions` configured
- Renders `c-summit-events-question-field` for each guest question when configured
- Max guest limit enforced via `eventInfo.Guest_Max_Amount__c`
- Unsaved guest modal: blocks navigation if form has unflushed data
- `validate()` returns false and shows modal if form data exists but not yet added
- `getData()` returns `{ guestRegistrations: [...] }` for Apex serialization

#### f. `summitEventsDonationPage`
**Status**: ✅ Fully Implemented (March 2026)

**Features**:
- Suggested amounts combobox parsed from `Donation_Suggested_Amount_List__c` (newline-delimited)
- "Other Amount" option triggers custom `lightning-input type="number"`
- Designation combobox from `Donation_Allocation_1__c` through `5__c` (conditional on allocations existing)
- `getData()` returns `{ donationSelection: { amount, allocationId, existingFeeId } }`

#### g. `summitEventsSubmitPage`
**Status**: ✅ Fully Implemented (March 2026)

**Features**:
- Read-only review page (no user input)
- Guest summary section (names of all added guests)
- Appointment summary (filters out `'Added but not shown'` types)
- Fees table: event base fee + donation + total
- All amounts formatted as currency via `_formatCurrency()` helper
- `validate()` returns true trivially; `getData()` returns empty object

#### h. `summitEventsConfirmationPage`
**Status**: ✅ Fully Implemented

**Features**:
- Success message display
- Registration details
- Confirmation email notification
- No navigation buttons (end of flow)

## Data Flow

### Initial Load
1. User lands on Experience Cloud page
2. `summitEventsRegistration` receives `eventInstanceId`
3. Component calls `getSummitEventData()` Apex method
4. All data loaded in single call:
   - Event configuration
   - Instance details
   - Questions (registrant & guest)
   - Appointment types
   - Existing registration (if resuming)
   - Page flow structure
   - Fee information
   - reCAPTCHA settings

### Page Navigation
1. User fills out current page
2. Clicks "Next" button
3. Controller validates current page
4. Controller gets data from page component
5. Updates `eventData` object
6. Navigates to next page
7. Repeat until "Submit"

### Submission
1. User clicks "Submit Registration"
2. Controller validates submit page
3. Controller serializes entire `eventData` object
4. Calls `saveRegistration()` Apex method
5. Receives encrypted registration ID
6. Navigates to confirmation page

## Deployment Steps

### 1. Deploy Components
```powershell
# Deploy all LWC components
cci task run dx_push --org dev
```

### 2. Create Experience Cloud Page
1. Go to Experience Builder
2. Create new page: "Event Registration"
3. Add `summitEventsRegistration` component
4. Configure `eventInstanceId` property
5. Publish page

### 3. Test Registration Flow
1. Create test event and instance
2. Configure questions and appointments
3. Navigate to registration page
4. Test complete flow
5. Verify data saved correctly

## Guest User Permissions

Required permissions for guest users:
- **Read**: Summit_Events__c, Summit_Events_Instance__c, Summit_Events_Question__c, Summit_Events_Appointment_Type__c
- **Create/Update**: Summit_Events_Registration__c, Summit_Events_Appointments__c, Summit_Events_Fee__c
- **Field-Level Security**: All fields used in registration

## Next Steps

### Priority 1: Core Registration
- ✅ Register page (DONE)
- ✅ Questions page (DONE)
- ✅ Confirmation page (DONE)
- ⚠️ Test with real event data
- ⚠️ Deploy to test environment

### Priority 2: Appointments
- 🔨 Build appointment selection UI
- 🔨 Handle time slots
- 🔨 Validate capacity
- 🔨 Support required appointments

### Priority 3: Guests & Donations
- 🔨 Build guest registration flow
- 🔨 Guest appointments (new feature!)
- 🔨 Donation page
- 🔨 Fee calculation

### Priority 4: Submit & Review
- 🔨 Build review page
- 🔨 Summary display
- 🔨 Edit functionality
- 🔨 reCAPTCHA integration

### Priority 5: Advanced Features
- 🔨 Port lookup component from other repository
- 🔨 Payment gateway integration
- 🔨 Email confirmations
- 🔨 Calendar integration
- 🔨 Itinerary generation

## Component Dependencies

```
summitEventsRegistration (Controller)
├── summitEventsRegisterPage ✅
├── summitEventsQuestionsPage ✅
│   └── summitEventsQuestionField ✅
├── summitEventsAppointmentsPage ✅ (March 2026)
├── summitEventsGuestsPage ✅ (March 2026)
│   └── summitEventsQuestionField ✅ (reused for guest questions)
├── summitEventsDonationPage ✅ (March 2026)
├── summitEventsSubmitPage ✅ (March 2026)
└── summitEventsConfirmationPage ✅
```

**See also**: `docs/SEA-REGISTRATION-ARCHITECTURE.md` — deep technical reference for both VF and LWC implementations, all data structures, object/field reference, and VF vs LWC comparison table.

## Testing Checklist

### Registration Page
- [ ] First Name, Last Name, Email (required)
- [ ] All conditional fields display correctly
- [ ] Address component works
- [ ] Validation works for required fields
- [ ] Data saves when clicking Next

### Questions Page
- [ ] Questions display based on registrant type
- [ ] All field types render correctly
- [ ] Controlling logic works
- [ ] Required validation works
- [ ] Answers save to registration

### Confirmation Page
- [ ] Displays after successful submission
- [ ] Shows correct registration details
- [ ] No navigation buttons appear

### Overall Flow
- [ ] Progress indicator updates correctly
- [ ] Can navigate forward through pages
- [ ] Can navigate backward
- [ ] Data persists across pages
- [ ] Final submission creates registration
- [ ] Encrypted ID returned correctly

## Known Issues & Limitations

1. **Lookup Fields**: Placeholder implementation - needs custom lookup component
2. **Controlling Logic**: Simple eval() implementation - may need enhancement
3. **reCAPTCHA**: Not yet integrated in submit page
4. **Payment Gateway**: Not yet implemented
5. **Email Confirmations**: Relies on existing Apex/Process Builder

## Performance Considerations

- Single Apex call loads all data (reduces server round trips)
- Client-side validation before server submission
- Page navigation handled in JavaScript (no server calls)
- Data only saved on "Next" and "Submit" actions

## Security Considerations

- Encrypted registration IDs
- Guest user permission validation in Apex
- Input sanitization in all components
- WITH SECURITY_ENFORCED in all SOQL queries

---

**Created**: January 2, 2026  
**Version**: 1.0  
**Status**: Initial Implementation - Core Components Complete

