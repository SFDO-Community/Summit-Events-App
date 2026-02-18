# Feature Requirements: Appointment Type Rules

## Overview
**Feature:** Appointment Type Rules  
**Component:** LWC/Apex/Custom Objects  
**Target Release:** TBD  
**Status:** Planning  
**Created:** January 27, 2026

## Executive Summary

Appointment Type Rules is a new feature that enables dynamic grouping, mutual exclusion, and conditional display of appointment types in Summit Events. Event organizers will be able to create reusable rule configurations that control when appointments appear and how they can be selected, without requiring custom code for each event.

### Key Capabilities
- **Mutual Exclusion Groups:** Group related appointments where only one can be selected (e.g., multiple time slots for campus tours)
- **Conditional Display:** Show/hide appointments based on registration field values (e.g., show "Admitted Student Tour" only if `Applicant_Status__c = 'Admitted'`)
- **Static Headings:** Add contextual instructions and section headers to appointment groups
- **Many-to-Many Relationships:** Assign multiple rules to appointment types for flexible configurations

---

## Business Context

### Current Limitations
The existing Summit Events appointment system (`Summit_Events_Appointment_Type__c` and `Summit_Events_Appointments__c`) allows event organizers to create appointment types and time slots, but lacks:

1. **Grouping Logic:** No way to indicate that certain appointments are mutually exclusive
2. **Dynamic Visibility:** Cannot show/hide appointments based on registrant attributes
3. **Contextual Guidance:** No mechanism to add explanatory text or section headings
4. **Business Rule Enforcement:** Must rely on post-registration validation rather than prevention

### Business Value
Event organizers frequently need to:
- Prevent double-booking across related appointment types (e.g., "Morning Tour" vs "Afternoon Tour")
- Show appointments only to qualified registrants (e.g., program-specific sessions)
- Provide clear instructions for complex appointment selection workflows
- Maintain consistent rules across multiple events

This feature enables these scenarios without custom development, reducing setup time and improving registrant experience.

### Use Cases

**Use Case 1: Campus Tour Time Slots**
- Event has 5 tour times (9 AM, 10 AM, 11 AM, 1 PM, 2 PM)
- Registrants should select exactly one tour time
- Rule groups all tour appointments and enforces mutual exclusion
- Heading displays: "Select ONE campus tour time:"

**Use Case 2: Program-Specific Sessions**
- Event has breakout sessions for different academic programs
- Session visibility depends on `Intended_Program__c` field
- Engineering session only shows if `Intended_Program__c = 'Engineering'`
- Business session only shows if `Intended_Program__c = 'Business'`

**Use Case 3: Admitted Student Activities**
- Event has general sessions (open to all) and admitted student sessions
- Admitted student sessions only visible if `Applicant_Status__c = 'Admitted'`
- Rule adds heading: "Admitted Students Only"

---

## User Stories

### Event Organizer Stories
1. **As an** event organizer, **I want to** group related appointment types together, **so that** registrants understand they're selecting from a set of mutually exclusive options
2. **As an** event organizer, **I want to** limit registrants to one appointment per group, **so that** I can prevent double-booking or conflicting selections
3. **As an** event organizer, **I want to** show appointments only when prerequisites are met, **so that** registrants see only relevant options based on their profile
4. **As an** event organizer, **I want to** add headings and instructions to appointment groups, **so that** registrants understand selection requirements and context
5. **As an** event organizer, **I want to** reuse rule configurations across multiple events, **so that** I maintain consistency and reduce setup time
6. **As an** event organizer, **I want to** assign multiple rules to a single appointment type, **so that** I can combine grouping and conditional logic

### Registrant Stories
1. **As a** registrant, **I want to** see clear groupings and instructions, **so that** I can make appropriate appointment selections
2. **As a** registrant, **I want to** see only appointments relevant to me, **so that** I'm not confused by options I'm not eligible for
3. **As a** registrant, **I want** immediate feedback when I select from a mutually exclusive group, **so that** I understand the impact of my selection

---

## Functional Requirements

### Core Functionality

| ID | Requirement | Priority | Status | Notes |
|----|-------------|----------|--------|-------|
| FR-001 | Create `Appointment_Type_Rule__c` object with rule type, configuration, and display settings | Must Have | Pending | Foundation object |
| FR-002 | Support "Mutual Exclusion" rule type (one per group) | Must Have | Pending | Primary use case |
| FR-003 | Support "Conditional Display" rule type (show/hide based on registration field) | Must Have | Pending | Primary use case |
| FR-004 | Support static heading/instruction text per rule (rich text) | Must Have | Pending | User guidance |
| FR-005 | Many-to-many relationship between Rules and Appointment Types via junction object | Must Have | Pending | Flexibility requirement |
| FR-006 | Enforce mutual exclusion in UI (disable other group members when one selected) | Must Have | Pending | Real-time enforcement |
| FR-007 | Evaluate conditional display rules against current registration data | Must Have | Pending | Dynamic visibility |
| FR-008 | Display headings/instructions above grouped appointments in registration flow | Must Have | Pending | User experience |
| FR-009 | Support multiple rules per appointment type | Must Have | Pending | Complex scenarios |
| FR-010 | Admin UI for rule management and appointment assignment | Should Have | Pending | User-friendly setup |
| FR-011 | Validate mutual exclusion at save time (server-side) | Must Have | Pending | Data integrity |
| FR-012 | Visual grouping indicators in LWC (cards/sections) | Should Have | Pending | Enhanced UX |
| FR-013 | Order rules and appointments within rules via `Display_Order__c` | Should Have | Pending | Presentability |
| FR-014 | Active/Inactive toggle for rules (`Active__c` checkbox) | Should Have | Pending | Rule lifecycle |
| FR-015 | Support for ungrouped appointments (no rules assigned) | Must Have | Pending | Backward compatibility |

### User Interface Requirements

**Placement:** Event registration appointment selection page (`summitEventsAppointmentsPage` LWC)

**Layout Requirements:**
- Responsive design (desktop/mobile)
- Clear visual separation between rule groups
- Headings styled to stand out from appointment options
- Real-time enable/disable state changes for mutual exclusion
- Loading state during conditional rule evaluation

**Component Structure:**
```
summitEventsAppointmentsPage
  └── For each Appointment Type Rule
       ├── Display heading/instructions
       └── Group of appointment types
            └── Individual appointment selection (radio/checkbox)
  └── Ungrouped appointments section (if any)
```

**Interaction Patterns:**
- **Mutual Exclusion:** Radio button behavior within group
- **Conditional Display:** Appointments fade in/out or appear/disappear based on rule evaluation
- **Selection Feedback:** Visual indication when selection affects other appointments
- **Validation Messages:** Clear error if user attempts to violate rules

### Data Requirements

#### New Objects

**1. Appointment_Type_Rule__c**

Master object that defines rule configurations.

| Field API Name | Type | Required | Description |
|----------------|------|----------|-------------|
| `Name` | Text(80) | Yes | Rule name (e.g., "Campus Tour Time Selection") |
| `Event__c` | Master-Detail(Summit_Events__c) | Yes | Parent event for this rule |
| `Rule_Type__c` | Picklist | Yes | Values: "Mutual Exclusion", "Conditional Display" |
| `Active__c` | Checkbox | No | Default: TRUE. Controls if rule is evaluated |
| `Display_Heading__c` | Rich Text Area | No | Heading/instructions displayed above grouped appointments |
| `Display_Order__c` | Number(3,0) | No | Order to display rule groups (ascending) |
| `Description__c` | Long Text Area | No | Admin notes about rule purpose |

**Conditional Display Specific Fields:**
| Field API Name | Type | Required | Description |
|----------------|------|----------|-------------|
| `Dependent_Question_Field__c` | Text(120) | Conditional* | API name of field on `Summit_Events_Registration__c` (e.g., "Applicant_Status__c") |
| `Dependent_Question_Value__c` | Text(255) | Conditional* | Expected value to show appointments (e.g., "Admitted") |
| `Match_Type__c` | Picklist | Conditional* | Values: "Equals", "Not Equals", "Contains", "Starts With", "Is Blank", "Is Not Blank" |

*Required if `Rule_Type__c = 'Conditional Display'`

**2. Appointment_Type_Rule_Assignment__c (Junction Object)**

Connects appointment types to rules in a many-to-many relationship.

| Field API Name | Type | Required | Description |
|----------------|------|----------|-------------|
| `Name` | Auto Number | Yes | Auto-generated (format: AT-{0000}) |
| `Appointment_Type_Rule__c` | Master-Detail(Appointment_Type_Rule__c) | Yes | Parent rule |
| `Appointment_Type__c` | Lookup(Summit_Events_Appointment_Type__c) | Yes | Appointment type to include in rule |
| `Display_Order__c` | Number(3,0) | No | Order within rule group (ascending) |

**Unique Constraint:** `Appointment_Type_Rule__c` + `Appointment_Type__c` (prevent duplicate assignments)

#### Object Relationships

```
Summit_Events__c (existing)
  └── Appointment_Type_Rule__c (new, Master-Detail)
       └── Appointment_Type_Rule_Assignment__c (new, Master-Detail)
            └── Summit_Events_Appointment_Type__c (existing, Lookup)
                 └── Summit_Events_Appointments__c (existing)

Summit_Events_Registration__c (existing)
  └── Referenced by Conditional Display rules for field evaluation
```

#### Integration with Existing Objects

**Summit_Events_Appointment_Type__c (existing):**
- No structural changes required
- Maintains existing relationships to `Summit_Events__c` and `Summit_Events_Appointments__c`
- Can participate in zero, one, or multiple rules via junction object

**Summit_Events_Registration__c (existing):**
- No structural changes required
- Fields referenced by `Dependent_Question_Field__c` for conditional logic
- Supports standard and custom fields

**Summit_Events_Appointments__c (existing):**
- No structural changes required
- Validation logic enhanced to check rule compliance

### Business Rules

#### Mutual Exclusion Rules

1. **Selection Enforcement:**
   - When registrant selects appointment from a mutual exclusion group, all other appointments in same group become disabled/unselectable
   - When registrant deselects appointment, other appointments in group become enabled again
   - Selection state persists across page navigation (stored in registration data)

2. **Multiple Groups:**
   - Single appointment type can belong to multiple mutual exclusion groups
   - Each group enforces independently (e.g., appointment could be in "Morning Activities" group AND "Campus Tour" group)

3. **UI Behavior:**
   - Radio button behavior within each mutual exclusion group
   - Clear visual indication of which appointments are in same group

#### Conditional Display Rules

1. **Evaluation Timing:**
   - Rules evaluated on page load based on current registration data
   - Re-evaluated when dependent field value changes (if on same page or via real-time update)
   - Hidden appointments cannot be selected

2. **Field References:**
   - `Dependent_Question_Field__c` must reference valid field API name on `Summit_Events_Registration__c`
   - Supports standard and custom fields
   - Field must be accessible to guest/community user context

3. **Match Types:**
   - **Equals:** Exact string match (case-insensitive)
   - **Not Equals:** Field value does not match (case-insensitive)
   - **Contains:** Field value contains substring (case-insensitive)
   - **Starts With:** Field value begins with substring (case-insensitive)
   - **Is Blank:** Field is null or empty string
   - **Is Not Blank:** Field has any value

4. **Selection Impact:**
   - If selected appointment becomes hidden due to rule change, selection is cleared and user notified
   - Warning message: "Your selection for [appointment name] has been removed because you no longer meet the requirements."

#### Display Rules

1. **Grouping:**
   - Appointments grouped by rule according to `Display_Order__c` on rule
   - Appointments ordered within group by `Display_Order__c` on assignment
   - Ungrouped appointments (no rules) appear in separate section at end

2. **Headings:**
   - `Display_Heading__c` rendered above first appointment in rule group
   - Supports basic rich text formatting (bold, italic, lists)
   - No scripts or images allowed (security)

3. **Multiple Rules per Appointment:**
   - If appointment belongs to multiple rules, it appears in each rule's section
   - Each appearance behaves according to its group's rules
   - Selection in one location affects all locations (same appointment instance)

#### Validation Rules

1. **Rule Configuration Validation:**
   - Conditional Display rules must have `Dependent_Question_Field__c`, `Dependent_Question_Value__c`, and `Match_Type__c` populated
   - Mutual Exclusion rules do not require conditional fields
   - Field name validation: `Dependent_Question_Field__c` must be valid API name (letters, numbers, underscores only)

2. **Assignment Validation:**
   - Cannot assign inactive appointment types to rules
   - Cannot create duplicate assignments (same rule + same appointment type)
   - Must have at least 2 appointments in a mutual exclusion group (warning, not hard error)

3. **Selection Validation (Server-Side):**
   - On registration save, validate mutual exclusion rules are not violated
   - Error message: "You have selected multiple appointments from the [rule name] group. Please select only one."
   - Validate conditional display rules (ensure hidden appointments not selected)

---

## Technical Requirements

### Architecture

#### Frontend (LWC)

**Component:** `summitEventsAppointmentsPage.js` (existing, to be enhanced)

**Enhancements Required:**
- Query and cache rule data on component initialization
- Evaluate conditional display rules client-side
- Enforce mutual exclusion through reactive property updates
- Render rule headings with proper formatting
- Group appointments by rule with visual separation
- Track selection state per rule group
- Disable/enable appointments based on mutual exclusion logic
- Display validation errors from server-side rule violations

**Key Reactive Properties:**
```javascript
@track appointmentGroups = []; // Array of rule groups with appointments
@track selectedAppointments = new Set(); // Track selections
@track ruleViolations = []; // Validation errors
```

**Methods:**
```javascript
// Evaluate conditional rules against current registration
evaluateConditionalRules(registrationData, rules)

// Handle mutual exclusion selection
handleAppointmentSelection(appointmentId, ruleId)

// Disable appointments in same mutual exclusion group
updateMutualExclusionState(selectedAppointmentId, ruleId)

// Validate selections before save
validateRuleCompliance()
```

#### Backend (Apex)

**New Classes:**

**1. AppointmentTypeRuleService.cls**

Service class for rule business logic.

```apex
public with sharing class AppointmentTypeRuleService {
    
    /**
     * Get all active rules for an event with appointment assignments
     * @param eventId The Summit_Events__c Id
     * @return List of AppointmentTypeRuleWrapper with nested data
     */
    public static List<AppointmentTypeRuleWrapper> getActiveRulesForEvent(Id eventId)
    
    /**
     * Evaluate if a conditional rule is satisfied for given registration
     * @param rule The Appointment_Type_Rule__c record
     * @param registration The Summit_Events_Registration__c record
     * @return Boolean true if rule condition is met
     */
    public static Boolean evaluateConditionalRule(
        Appointment_Type_Rule__c rule, 
        Summit_Events_Registration__c registration
    )
    
    /**
     * Get mutual exclusion groups for a set of appointment types
     * @param appointmentTypeIds Set of appointment type Ids
     * @return Map<Id, List<Id>> - Rule Id to list of appointment type Ids in that group
     */
    public static Map<Id, List<Id>> getMutualExclusionGroups(Set<Id> appointmentTypeIds)
    
    /**
     * Validate that appointment selections don't violate mutual exclusion rules
     * @param selectedAppointmentIds Set of selected appointment Ids
     * @param eventId The event being registered for
     * @return AppointmentRuleValidationResult with isValid and error messages
     */
    public static AppointmentRuleValidationResult validateMutualExclusion(
        Set<Id> selectedAppointmentIds,
        Id eventId
    )
}
```

**2. AppointmentTypeRuleController.cls**

Aura-enabled controller for LWC communication.

```apex
public with sharing class AppointmentTypeRuleController {
    
    /**
     * Get rule data for appointment page display
     * @param eventId The Summit_Events__c Id
     * @param registrationId The current registration Id
     * @return AppointmentPageData wrapper with rules, appointments, and current selections
     */
    @AuraEnabled(cacheable=true)
    public static AppointmentPageData getAppointmentRulesData(Id eventId, Id registrationId)
    
    /**
     * Validate appointment selections against rules before save
     * @param appointmentIds Selected appointment Ids
     * @param registrationId Current registration
     * @return ValidationResult with success/error details
     */
    @AuraEnabled
    public static ValidationResult validateAppointmentSelections(
        List<Id> appointmentIds,
        Id registrationId
    )
}
```

**Wrapper Classes:**

```apex
public class AppointmentTypeRuleWrapper {
    @AuraEnabled public Id ruleId { get; set; }
    @AuraEnabled public String ruleName { get; set; }
    @AuraEnabled public String ruleType { get; set; }
    @AuraEnabled public String displayHeading { get; set; }
    @AuraEnabled public Integer displayOrder { get; set; }
    @AuraEnabled public List<AppointmentTypeInfo> appointments { get; set; }
    @AuraEnabled public Boolean isVisible { get; set; } // Based on conditional evaluation
}

public class AppointmentTypeInfo {
    @AuraEnabled public Id appointmentTypeId { get; set; }
    @AuraEnabled public String title { get; set; }
    @AuraEnabled public Integer displayOrder { get; set; }
    @AuraEnabled public List<AppointmentSlot> slots { get; set; }
}

public class AppointmentRuleValidationResult {
    @AuraEnabled public Boolean isValid { get; set; }
    @AuraEnabled public List<String> errorMessages { get; set; }
    @AuraEnabled public Map<Id, String> ruleViolations { get; set; } // Rule Id -> Error message
}
```

**Enhancements to Existing Classes:**

**SummitEventsLWCController.cls:**
- Integrate rule data into main registration wrapper
- Include rule validation in `saveRegistration()` method

#### SOQL Queries

**Query Rules with Assignments:**
```sql
SELECT Id, Name, Rule_Type__c, Active__c, Display_Heading__c, Display_Order__c,
       Dependent_Question_Field__c, Dependent_Question_Value__c, Match_Type__c,
       (SELECT Id, Appointment_Type__c, Display_Order__c,
               Appointment_Type__r.Title__c, Appointment_Type__r.Description__c
        FROM Appointment_Type_Rule_Assignments__r
        WHERE Appointment_Type__r.Active__c = true
        ORDER BY Display_Order__c ASC NULLS LAST)
FROM Appointment_Type_Rule__c
WHERE Event__c = :eventId
  AND Active__c = true
ORDER BY Display_Order__c ASC NULLS LAST
```

**Query Appointments with Rule Assignments:**
```sql
SELECT Id, Title__c, Description__c,
       (SELECT Id, Appointment_Type_Rule__c, Appointment_Type_Rule__r.Rule_Type__c,
               Appointment_Type_Rule__r.Name
        FROM Appointment_Type_Rule_Assignments__r
        WHERE Appointment_Type_Rule__r.Active__c = true)
FROM Summit_Events_Appointment_Type__c
WHERE Event__c = :eventId
  AND Active__c = true
```

### Data Model Diagram

```
┌─────────────────────────────┐
│   Summit_Events__c          │
│   (Existing)                │
└──────────┬──────────────────┘
           │ 1
           │
           │ *
┌──────────▼──────────────────┐
│ Appointment_Type_Rule__c    │
│ (New)                       │
│ ─────────────────────────   │
│ - Name                      │
│ - Rule_Type__c              │
│ - Active__c                 │
│ - Display_Heading__c        │
│ - Display_Order__c          │
│ - Dependent_Question_Field  │
│ - Dependent_Question_Value  │
│ - Match_Type__c             │
└──────────┬──────────────────┘
           │ 1
           │
           │ *
┌──────────▼────────────────────────┐
│ Appointment_Type_Rule_Assignment  │
│ (Junction - New)                  │
│ ───────────────────────────────   │
│ - Appointment_Type_Rule__c (MD)   │
│ - Appointment_Type__c (Lookup)    │
│ - Display_Order__c                │
└──────────┬────────────────────────┘
           │ *
           │
           │ 1
┌──────────▼──────────────────────────┐
│ Summit_Events_Appointment_Type__c   │
│ (Existing)                          │
└─────────────────────────────────────┘

Reference for Conditional Rules:
┌──────────────────────────────────┐
│ Summit_Events_Registration__c    │
│ (Existing)                       │
│ - Field values evaluated by      │
│   Dependent_Question_Field__c    │
└──────────────────────────────────┘
```

### Performance Considerations

**Load Time Targets:**
- Rule query and evaluation: < 500ms
- Conditional rule re-evaluation (client-side): < 100ms
- Visual grouping render: < 200ms

**Data Volume Support:**
- Up to 50 rules per event
- Up to 100 appointment types per event
- Up to 1,000 rule assignments (total)

**Optimization Strategies:**
- Cache rule data with `@wire(cacheable=true)` in LWC
- Single SOQL query to fetch rules with nested assignments
- Client-side conditional evaluation (no server round-trips during form interaction)
- Lazy load appointment slots (not part of initial rule query)

### Security

**Object Permissions:**

Update `Summit_Events_Admin.permissionset-meta.xml`:
```xml
<objectPermissions>
    <object>Appointment_Type_Rule__c</object>
    <allowCreate>true</allowCreate>
    <allowRead>true</allowRead>
    <allowEdit>true</allowEdit>
    <allowDelete>true</allowDelete>
</objectPermissions>
<objectPermissions>
    <object>Appointment_Type_Rule_Assignment__c</object>
    <allowCreate>true</allowCreate>
    <allowRead>true</allowRead>
    <allowEdit>true</allowEdit>
    <allowDelete>true</allowDelete>
</objectPermissions>
```

Update `Summit_Events_Registrant.permissionset-meta.xml`:
```xml
<objectPermissions>
    <object>Appointment_Type_Rule__c</object>
    <allowCreate>false</allowCreate>
    <allowRead>true</allowRead>
    <allowEdit>false</allowEdit>
    <allowDelete>false</allowDelete>
</objectPermissions>
<objectPermissions>
    <object>Appointment_Type_Rule_Assignment__c</object>
    <allowCreate>false</allowCreate>
    <allowRead>true</allowRead>
    <allowEdit>false</allowEdit>
    <allowDelete>false</allowDelete>
</objectPermissions>
```

**Field-Level Security:**
- All fields readable by `Summit_Events_Registrant` (guest user context)
- All fields read/write by `Summit_Events_Admin`
- No sensitive data stored in rule configurations

**Sharing Rules:**
- Inherit from `Summit_Events__c` via Master-Detail relationship
- No additional sharing rules needed

**Validation:**
- Server-side validation in Apex (cannot be bypassed)
- Client-side validation for UX only (not security boundary)

---

## Testing Requirements

### Unit Tests

**Apex Test Classes:**

**AppointmentTypeRuleServiceTest.cls:**
- Test `getActiveRulesForEvent()` with various rule types
- Test `evaluateConditionalRule()` with all match types (Equals, Contains, etc.)
- Test mutual exclusion group calculations
- Test validation of rule violations
- Negative tests: invalid field names, null values, inactive rules
- Test coverage target: ≥ 85%

**AppointmentTypeRuleControllerTest.cls:**
- Test `@AuraEnabled` methods with valid/invalid inputs
- Test cacheable data retrieval
- Test error handling and exception scenarios
- Mock data for various rule configurations
- Test coverage target: ≥ 85%

**LWC Jest Tests:**

**summitEventsAppointmentsPage.test.js:**
- Test rule group rendering
- Test mutual exclusion UI enforcement
- Test conditional display evaluation
- Test heading display
- Test selection state management
- Test validation error display
- Mock Apex responses with `@salesforce/apex` test utilities

### Integration Tests

**End-to-End Scenarios:**
1. **Mutual Exclusion Flow:**
   - Create event with 3 appointment types in mutual exclusion group
   - Start registration, navigate to appointment page
   - Select appointment A → verify B and C are disabled
   - Deselect A → verify B and C are enabled
   - Select B, proceed to next page, navigate back → verify B still selected and A/C disabled

2. **Conditional Display Flow:**
   - Create event with conditional rule based on `Applicant_Status__c`
   - Start registration, set status to "Prospect" → verify conditional appointment hidden
   - Change status to "Admitted" → verify conditional appointment appears
   - Complete registration with admitted-only appointment → verify save succeeds

3. **Multiple Rules Flow:**
   - Create appointment type assigned to both mutual exclusion rule AND conditional rule
   - Verify appointment appears in correct group when condition met
   - Verify mutual exclusion enforced within group
   - Verify appointment hidden when condition not met

4. **Validation Flow:**
   - Manually create registration with multiple appointments from same mutual exclusion group (via API/data loader)
   - Attempt to edit registration → verify validation error displayed
   - Remove violating selection → verify save succeeds

### Test Data

**Snowfakery Recipe:**

`datasets/snowfakery/appointment_rules_test.yml`:
```yaml
- object: Summit_Events__c
  fields:
    Name: Test Event with Rules
    Event_Name__c: Rules Test Event
  friends:
    - object: Appointment_Type_Rule__c
      fields:
        Name: Campus Tour Time Selection
        Rule_Type__c: Mutual Exclusion
        Display_Heading__c: "<p><strong>Select ONE campus tour time:</strong></p>"
        Display_Order__c: 1
        Active__c: true
      friends:
        - object: Appointment_Type_Rule_Assignment__c
          fields:
            Appointment_Type__c:
              reference: morning_tour
            Display_Order__c: 1
        - object: Appointment_Type_Rule_Assignment__c
          fields:
            Appointment_Type__c:
              reference: afternoon_tour
            Display_Order__c: 2
    
    - object: Appointment_Type_Rule__c
      fields:
        Name: Admitted Student Sessions
        Rule_Type__c: Conditional Display
        Display_Heading__c: "<p><em>For Admitted Students Only</em></p>"
        Dependent_Question_Field__c: Applicant_Status__c
        Dependent_Question_Value__c: Admitted
        Match_Type__c: Equals
        Display_Order__c: 2
        Active__c: true

- object: Summit_Events_Appointment_Type__c
  nickname: morning_tour
  fields:
    Title__c: Morning Campus Tour (9 AM)
    Active__c: true

- object: Summit_Events_Appointment_Type__c
  nickname: afternoon_tour
  fields:
    Title__c: Afternoon Campus Tour (2 PM)
    Active__c: true
```

### Browser/Device Testing

**Browsers:**
- Chrome (latest 2 versions)
- Firefox (latest 2 versions)
- Safari (latest 2 versions)
- Edge (latest 2 versions)

**Devices:**
- Desktop (1920x1080, 1366x768)
- Tablet (iPad, 1024x768)
- Mobile (iPhone, 375x667)

**Accessibility:**
- Screen reader compatibility (NVDA/JAWS)
- Keyboard navigation (no mouse)
- WCAG 2.1 AA compliance

---

## Documentation Requirements

### User Documentation

**1. Admin Guide:** `docs/APPOINTMENT-RULES-ADMIN-GUIDE.md`

Content:
- Introduction to appointment type rules
- Creating rules step-by-step
- Rule type explanations (Mutual Exclusion vs Conditional Display)
- Assigning appointment types to rules
- Using display headings effectively
- Common scenarios and examples
- Troubleshooting common issues
- Best practices

**2. Feature Overview:** Update `README.md`
- Add Appointment Type Rules to feature list
- Link to admin guide

**3. Changelog:** Update `CHANGELOG.md`
```markdown
## [Version X.X.X] - [Date]

### Added
- **Appointment Type Rules:** New feature for grouping, mutual exclusion, and conditional display of appointment types
  - Mutual Exclusion rule type
  - Conditional Display rule type
  - Static heading/instruction text
  - Many-to-many relationship between rules and appointment types
```

### Technical Documentation

**1. Architecture Documentation:** Add section to `docs/ARCHITECTURE.md` (or create if doesn't exist)

Content:
- Data model diagram
- Object relationship descriptions
- Apex class responsibilities
- LWC component architecture
- Rule evaluation algorithm
- Performance considerations

**2. API Documentation:** Inline Apex/JS comments
- ApexDoc comments for all public methods
- JSDoc comments for all LWC methods
- Parameter descriptions and return types
- Usage examples

**3. Release Notes:** For packaged release
- Feature summary
- Upgrade considerations
- Known limitations
- Migration path (if applicable)

---

## Acceptance Criteria

### Functional Acceptance
- [ ] Mutual Exclusion rules prevent multi-selection in UI (real-time)
- [ ] Mutual Exclusion rules prevent multi-selection at save time (validation)
- [ ] Conditional Display rules show/hide appointments based on registration field values
- [ ] Conditional Display rules evaluate all supported match types correctly
- [ ] Headings display correctly above grouped appointments
- [ ] Appointments can belong to multiple rules simultaneously
- [ ] Ungrouped appointments (no rules) still display correctly
- [ ] Rules respect `Active__c` checkbox (inactive rules ignored)
- [ ] Display order controls render sequence (rules and appointments within rules)

### Technical Acceptance
- [ ] All Apex classes have ≥ 85% test coverage
- [ ] All LWC components have Jest tests with ≥ 80% coverage
- [ ] No SOQL queries in loops
- [ ] No DML operations in loops
- [ ] Governor limit compliance (tested with bulk data)
- [ ] All `@AuraEnabled` methods have error handling
- [ ] Security review passed (FLS, CRUD, sharing)

### UX Acceptance
- [ ] Mobile-responsive design works on all target devices
- [ ] Visual grouping clear and intuitive
- [ ] Selection/deselection provides immediate feedback
- [ ] Error messages are user-friendly and actionable
- [ ] Headings render rich text correctly (bold, italic, lists)
- [ ] No console errors in browser developer tools
- [ ] Page load time < 2 seconds on typical network

### Documentation Acceptance
- [ ] Admin guide complete and reviewed
- [ ] Technical architecture documented
- [ ] Inline code comments complete
- [ ] CHANGELOG updated
- [ ] README updated with feature reference

### Deployment Acceptance
- [ ] Metadata deploys successfully to scratch org
- [ ] Permission sets include new objects/fields
- [ ] CumulusCI flow integration successful
- [ ] Package version created (if applicable)
- [ ] Uninstall/reinstall tested (no orphaned data)

---

## Known Limitations

### Phase 1 Limitations
1. **Conditional Logic Complexity:** Single field evaluation only (no AND/OR combinations)
2. **Field Type Support:** Text/picklist fields only (no date/number comparisons in Phase 1)
3. **Real-Time Re-Evaluation:** Conditional rules re-evaluate only on page load, not on field change across pages
4. **Rule Count:** Recommended maximum 10 rules per appointment type (UI complexity)
5. **Rich Text Security:** Display headings strip scripts/images for security
6. **Guest User Context:** Conditional field evaluation limited to fields accessible to guest users

### Backward Compatibility
- Existing appointments without rules continue to function identically
- No migration required for existing events
- Optional feature (events can ignore rules entirely)

### Future Enhancement Considerations
- Complex conditional expressions (AND/OR logic)
- Date/number field comparisons
- Cross-registration rule evaluation (e.g., "show if registered for Event X")
- Capacity-based conditional display
- Time-based availability rules
- Appointment dependencies (e.g., "Appointment B requires Appointment A")

---

## Implementation Phases

### Phase 1: MVP (Minimum Viable Product)
**Duration:** 4-6 weeks  
**Goal:** Core functionality for most common use cases

**Deliverables:**
- [ ] Object creation (`Appointment_Type_Rule__c`, `Appointment_Type_Rule_Assignment__c`)
- [ ] Mutual Exclusion rule type implementation
- [ ] Basic UI grouping in `summitEventsAppointmentsPage`
- [ ] Admin UI for rule management (standard record pages)
- [ ] Apex service and controller classes
- [ ] Unit tests (85% coverage)
- [ ] Basic admin documentation

**Acceptance:** Can create mutual exclusion groups and enforce in registration UI

### Phase 2: Conditional Display
**Duration:** 3-4 weeks  
**Goal:** Dynamic appointment visibility

**Deliverables:**
- [ ] Conditional Display rule type implementation
- [ ] Match type logic (Equals, Contains, etc.)
- [ ] Client-side rule evaluation
- [ ] Enhanced UI with headings/visual grouping
- [ ] Validation enhancements
- [ ] Integration tests
- [ ] Complete admin guide

**Acceptance:** Appointments show/hide based on registration field values

### Phase 3: Polish & Advanced Features
**Duration:** 2-3 weeks  
**Goal:** Production-ready quality

**Deliverables:**
- [ ] Multiple rule per appointment support
- [ ] Display order refinements
- [ ] Enhanced error messages
- [ ] Performance optimization
- [ ] Accessibility review
- [ ] Mobile device testing
- [ ] Rule templates (optional)
- [ ] Analytics tracking (optional)

**Acceptance:** Feature complete, documented, and production-ready

---

## References

### Related GitHub Issues
- [Issue #289: Migrate to Lightning Web Components](https://github.com/SFDO-Community/Summit-Events-App/issues/289) - Parent migration initiative

### Related Code Files
**Existing:**
- `force-app/main/default/objects/Summit_Events_Appointment_Type__c/`
- `force-app/main/default/objects/Summit_Events_Appointments__c/`
- `force-app/main/default/objects/Summit_Events_Registration__c/`
- `force-app/main/default/classes/SummitEventsRegisterAppointmentCtlr.cls` (Visualforce controller - reference for logic)
- `force-app/main/default/lwc/summitEventsAppointmentsPage/` (LWC to be enhanced)

**To Be Created:**
- `force-app/main/default/objects/Appointment_Type_Rule__c/`
- `force-app/main/default/objects/Appointment_Type_Rule_Assignment__c/`
- `force-app/main/default/classes/AppointmentTypeRuleService.cls`
- `force-app/main/default/classes/AppointmentTypeRuleController.cls`

### Salesforce Documentation
- [Custom Objects](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/)
- [LWC Conditional Rendering](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.create_conditional)
- [Lightning Web Security](https://developer.salesforce.com/docs/platform/lwc/guide/security-lwsec-intro.html)
- [Apex Design Patterns](https://developer.salesforce.com/wiki/apex_design_patterns)

### Design References
- Summit Events App Documentation: https://sfdo-community-sprints.github.io/summit-events-app-documentation/
- Salesforce Lightning Design System: https://www.lightningdesignsystem.com/

---

## Approval & Sign-Off

**Requirements Author:** [AI Assistant]  
**Date Created:** January 27, 2026  
**Status:** Draft - Pending Review

**Reviewers:**
- [ ] Product Owner: ___________________ Date: ___________
- [ ] Technical Lead: ___________________ Date: ___________
- [ ] UX Designer: ___________________ Date: ___________

**Approval:**
- [ ] Approved to proceed to design phase
- [ ] Approved to proceed to development

**Notes:**
_[Space for reviewer comments and approval conditions]_
