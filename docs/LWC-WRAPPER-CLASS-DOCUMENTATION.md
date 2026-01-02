# Summit Events LWC Wrapper Class Documentation

## Overview
The `SummitEventsLWCController` class is a comprehensive Apex controller designed to support the Lightning Web Component (LWC) version of the Summit Events registration flow. It provides a single, normalized data structure that eliminates the need for multiple server calls during the registration process.

## Key Design Principles

1. **Apex-First Approach**: All data normalization happens in Apex, reducing client-side complexity
2. **Single Data Load**: One call to `getSummitEventData()` provides all necessary information
3. **Feature Parity**: Maintains all functionality from the original Visualforce implementation
4. **Security**: Uses `with sharing` for main class and `without sharing` for specific CRUD operations
5. **Guest Registration Support**: Handles both primary registrant and guest registrations
6. **Appointment Management**: Supports appointment selection for both primary and guest registrants

## Main Method

### `getSummitEventData(Id eventInstanceId, String registrationId)`
**Purpose**: Retrieves all event and registration data in a single call

**Parameters**:
- `eventInstanceId`: The Summit Events Instance ID
- `registrationId`: (Optional) Encrypted registration ID for existing registrations

**Returns**: `SummitEventWrapper` containing:
- Event instance details
- Event configuration
- Page flow information
- Questions for registrants and guests
- Existing registration data (if provided)
- Appointment types
- Fees and cost information
- reCAPTCHA configuration

## Data Structures

### SummitEventWrapper
The main wrapper containing all event registration data:
```apex
- List<Page> pages                                    // Registration flow pages
- Integer currentPageIndex                            // Current page in flow
- Registration primaryRegistration                    // Primary registrant data
- List<Registration> guestRegistrations               // Guest registrations
- Summit_Events_Instance__c instance                  // Event instance
- Summit_Events__c eventInfo                          // Event configuration
- Map<Id, Summit_Events_Appointment_Type__c> appointmentTypes  // Available appointments
- List<SummitEventsQuestionWrapper> registrantQuestions        // Questions for registrant
- List<SummitEventsQuestionWrapper> guestQuestions             // Questions for guests
- EventConfiguration config                           // Event settings flags
- String encryptedRegistrationId                      // Encrypted ID for security
- List<Summit_Events_Fee__c> fees                     // Fee records
- Decimal totalEventCost                              // Total cost
- RecaptchaInfo recaptcha                             // reCAPTCHA settings
```

### EventConfiguration
Boolean flags for what features are enabled:
```apex
- hasAdditionalQuestions
- hasAppointments
- hasGuestRegistration
- hasDonations
- hasEventFee
- askThirdPartyRegistrant
- askPreferredName
- askDateOfBirth
- askGender
- askPronoun
- askMailingAddress
- askPhone
- askCompanyOrganization
- askTitle
- askDietaryRestrictions
- askAccessibilityNeeds
- maxGuests
```

### SummitEventsQuestionWrapper
Normalized question data with all field types supported:
```apex
- questionId (encrypted)
- questionLabel
- questionFieldType
- helpText
- instructions
- errorAssistText
- mapToField
- defaultValue
- required
- isVisible
- displayOrder
- textLimit
- displayStyle
- registrantType

// Picklist support
- List<PicklistOption> picklistValues
- existingPicklistField

// Lookup support
- lookupObject
- lookupFields
- lookupWhereClause
- lookupOrderBy
- lookupIcon
- lookupNoResultsLabel
- lookupSecondaryInputLinkText
- lookupSecondaryInputInstructions
- lookupSecondaryValueField

// Conditional logic
- controllingQuestion
- controllingLogic

// Current value
- currentValue
```

### Registration
Container for registration data:
```apex
- Summit_Events_Registration__c registrationRecord
- List<Summit_Events_Appointments__c> appointments
- Boolean isGuest
- Integer guestIndex
```

### PageInfo
Information about each page in the registration flow:
```apex
- pageType ('register', 'questions', 'appointments', 'guests', 'donation', 'submit', 'confirmation')
- pageIndex
- pageName
- pageMetaTitle
- pageHeading
- pageSubheading
- pageDescription
- isActive
```

## Additional Methods

### `saveRegistration(String wrapperJson)`
Saves registration data from the LWC

**Parameters**:
- `wrapperJson`: JSON serialized SummitEventWrapper

**Returns**: Encrypted registration ID

### `lookupSearch(String questionId, String searchTerm)`
Performs lookup searches for lookup-type questions

**Parameters**:
- `questionId`: Encrypted question ID
- `searchTerm`: Search string

**Returns**: List<LookupSearchResult>

## Page Flow Logic

The `buildPageInfo()` method constructs the registration flow based on event configuration:

1. **Registration** (always present) - Primary registrant information
2. **Additional Questions** (conditional) - Custom questions for registrant
3. **Appointments** (conditional) - Appointment selection
4. **Guest Registration** (conditional) - Guest information entry
5. **Donation** (conditional) - Optional donation
6. **Submit/Review** (always present) - Review and submit
7. **Confirmation** (shown after submit) - Confirmation page

## Question Type Support

The class supports all question field types:
- Text
- Text Area
- Email
- Phone
- Date
- Number
- Checkbox
- Radio
- Picklist
- Multi-Select Picklist
- Lookup
- Lookup Picklist
- Address (use standard LWC address component)

## Security Model

### With Sharing
The main controller class uses `with sharing` to respect user permissions

### Without Sharing
Inner classes handle specific operations:
- `RegistrationCRUD`: Handles registration CRUD operations (guest users need write access)
- `LookupCRUD`: Handles lookup searches (may need to query restricted objects)

## Field Type Handling

### Picklist Fields
The class handles two types of picklists:
1. **Existing Picklist Values**: References Standard/Custom picklists on Summit_Events_Registration__c
2. **Custom Picklist Values**: Defined in the question record (supports label|value format)

### Lookup Fields
Lookup questions support:
- Dynamic object selection
- Multiple display fields
- Where clause filtering
- Custom ordering
- Secondary manual entry option
- Icon customization

## Integration Points

### For LWC Development
1. Import the `getSummitEventData` method in your controller LWC
2. Pass eventInstanceId and optional registrationId
3. Use the returned data to render appropriate components
4. Call `saveRegistration` to persist changes
5. Use `lookupSearch` for lookup field autocomplete

### Address Component
For address questions, use the standard Lightning Address component:
```html
<lightning-input-address
    address-label="Mailing Address"
    street-label="Street"
    city-label="City"
    province-label="State/Province"
    country-label="Country"
    postal-code-label="Postal Code"
    street={mailingStreet}
    city={mailingCity}
    province={mailingState}
    country={mailingCountry}
    postal-code={mailingPostalCode}
    required>
</lightning-input-address>
```

## Error Handling

All public methods include try-catch blocks and throw `AuraHandledException` for LWC consumption:
```javascript
try {
    const data = await getSummitEventData({ eventInstanceId, registrationId });
} catch (error) {
    // Handle error
    console.error(error.body.message);
}
```

## reCAPTCHA Integration

The class detects and configures reCAPTCHA based on:
- Event reCAPTCHA picklist value
- Summit Events Settings custom settings
- Version detection (v2 or v3)

## Next Steps

To complete the LWC implementation, you'll need to create:

1. **Controller LWC** (`summitEventsRegistration`)
   - Manages page flow
   - Loads data via getSummitEventData
   - Handles navigation between pages
   - Saves registration data

2. **Page Component LWCs**:
   - `summitEventsRegisterPage` - Primary registration form
   - `summitEventsQuestionsPage` - Additional questions
   - `summitEventsAppointmentsPage` - Appointment selection
   - `summitEventsGuestsPage` - Guest registration
   - `summitEventsDonationPage` - Optional donation
   - `summitEventsSubmitPage` - Review and submit
   - `summitEventsConfirmationPage` - Confirmation

3. **Utility Components**:
   - `summitEventsQuestionField` - Dynamic question renderer
   - `summitEventsLookup` - Lookup component (or port from your other repository)
   - `summitEventsAppointmentSelector` - Appointment selection UI

4. **Experience Cloud/Communities**:
   - Create a registration page
   - Add the controller LWC
   - Configure public access for guest users

## Testing Considerations

When testing:
1. Test with and without existing registrations
2. Test all question field types
3. Test with various event configurations
4. Test guest registration flows
5. Test appointment selection
6. Test with reCAPTCHA enabled
7. Test lookup fields with various objects
8. Test controlling question logic
9. Verify FLS and object permissions for guest users
10. Test fee calculations

## Migration Path

To migrate from Visualforce to LWC:
1. Keep existing Visualforce pages functional
2. Build LWC components incrementally
3. Test in parallel with VF pages
4. Use a custom setting or permission to control which users see LWC vs VF
5. Migrate gradually per event or instance
6. Deprecate VF pages after full migration

---

**Author**: Thaddaeus Dahlberg  
**Date**: January 2, 2026  
**Version**: 1.0

