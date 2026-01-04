# URL Parameter Case Sensitivity Fix

**Date**: January 4, 2026  
**Issue**: Visualforce uses `instanceID` (capital D) but component checked for `instanceId` (lowercase d)

---

## Problem Identified

Your Visualforce URL uses:
```
?instanceID=a06Em00000YEHM1
```

But the LWC was checking for:
```
instanceId (lowercase d)
```

JavaScript URL parameter reading is **case-sensitive**, so `instanceID` ≠ `instanceId`.

---

## Solution Implemented

Updated the component to check for **both variations**:

### In CurrentPageReference (Experience Cloud)
```javascript
const urlInstanceId = stateParams.c__instanceId ||   // Experience Cloud custom
                     stateParams.c__instanceID ||   // Experience Cloud custom (capital D)
                     stateParams.instanceId ||       // Standard (lowercase)
                     stateParams.instanceID ||       // Standard (capital D) ✅ YOUR URL
                     stateParams.c__eventInstanceId ||
                     stateParams.eventInstanceId ||
                     stateParams.c__id ||
                     stateParams.id;
```

### In window.location fallback
```javascript
const fallbackInstanceId = urlParams.get('instanceId') ||
                          urlParams.get('instanceID') ||  // Capital D ✅ YOUR URL
                          urlParams.get('eventInstanceId') ||
                          urlParams.get('id');
```

---

## Your URLs

### Current Visualforce (Working)
```
https://customer-ability-8761-dev-ed.scratch.my.site.com/SummitEventsRegister?instanceID=a06Em00000YEHM1
```

### New LWC URL (Should work after deployment)
```
https://customer-ability-8761-dev-ed.scratch.my.site.com/s/?instanceID=a06Em00000YEHM1
```

**OR with page slug (better):**
```
https://customer-ability-8761-dev-ed.scratch.my.site.com/s/registration?instanceID=a06Em00000YEHM1
```

---

## Supported Parameter Variations

The component now supports all these variations:

### Instance ID
- `instanceID` ✅ (capital D - **matches your Visualforce**)
- `instanceId` (lowercase d)
- `c__instanceID` (Experience Cloud custom with capital D)
- `c__instanceId` (Experience Cloud custom with lowercase d)
- `eventInstanceId`
- `id`

### Registration ID
- `registrationID` (capital D)
- `registrationId` (lowercase d)
- `c__registrationID`
- `c__registrationId`
- `regId`

---

## Testing Instructions

### 1. Navigate to your URL
```
https://customer-ability-8761-dev-ed.scratch.my.site.com/s/?instanceID=a06Em00000YEHM1
```

### 2. Open Browser Console (F12)

### 3. Expected Console Output
```
PageRef State: {instanceID: "a06Em00000YEHM1"}
Found instance ID in URL: a06Em00000YEHM1
Final Event Instance ID (from URL or API): a06Em00000YEHM1
```

### 4. If Still Not Working

Check these console logs:
- **PageRef State**: Should show `{instanceID: "a06Em00000YEHM1"}`
- If empty `{}`, the parameter isn't being passed to the component
- If shows parameter but not detected, there may be a different issue

---

## Note About Your Experience Cloud URL

Your URL is:
```
/s/?instanceID=a06Em00000YEHM1
```

This is the **home page** (`/s/`) with a parameter. You may want to:

1. **Create a dedicated page** in Experience Builder:
   - Page Name: "Registration" or "Event Registration"
   - URL Slug: `registration`
   - Add the `summitEventsRegistration` component

2. **Update your URL to**:
   ```
   /s/registration?instanceID=a06Em00000YEHM1
   ```

This gives you:
- Better URL structure
- Dedicated page for registration
- Easier to track in analytics
- Matches the Visualforce pattern

---

## Migration Checklist

When switching from Visualforce to LWC:

- [x] Component supports `instanceID` (capital D) ✅ DONE
- [x] Component supports both CurrentPageReference and window.location
- [x] Component deployed to org
- [ ] Create dedicated Experience Cloud page
- [ ] Update email templates with new URL
- [ ] Update QR codes with new URL
- [ ] Test complete registration flow
- [ ] Verify data saves correctly
- [ ] Test with multiple events

---

**Status**: ✅ Fixed and Deployed  
**Your URL Should Now Work**: `/s/?instanceID=a06Em00000YEHM1`  
**Recommended Next Step**: Create dedicated `/s/registration` page

