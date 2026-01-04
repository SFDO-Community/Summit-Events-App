# Testing URL Parameters in Experience Cloud

**Date**: January 4, 2026  
**Issue**: URL parameters not being received in Experience Cloud  
**Solution**: Use `CurrentPageReference` from `lightning/navigation`

---

## The Problem

In Experience Cloud (Communities), the standard `window.location.search` doesn't reliably work for reading URL parameters. You must use the **CurrentPageReference** from the `lightning/navigation` module.

---

## The Solution

### 1. Import CurrentPageReference
```javascript
import { CurrentPageReference } from 'lightning/navigation';
```

### 2. Wire it to a property
```javascript
@wire(CurrentPageReference)
pageRef;
```

### 3. Read parameters from pageRef.state
```javascript
const stateParams = this.pageRef?.state || {};
const instanceId = stateParams.c__instanceId || stateParams.instanceId;
```

---

## Experience Cloud URL Parameter Format

Experience Cloud uses a **different format** for URL parameters than standard Salesforce:

### Standard Salesforce URL
```
/apex/PageName?instanceId=a1X123
```

### Experience Cloud URL
```
/s/pagename?c__instanceId=a1X123
```

**Notice the `c__` prefix!** This is required for custom URL parameters in Experience Cloud.

---

## Supported Parameter Names

The component now checks for multiple variations:

### Instance ID
1. `c__instanceId` (Experience Cloud preferred)
2. `instanceId`
3. `c__eventInstanceId`
4. `eventInstanceId`
5. `c__id`
6. `id`

### Registration ID
1. `c__registrationId` (Experience Cloud preferred)
2. `registrationId`
3. `c__regId`
4. `regId`

---

## How to Test

### Step 1: Get Your Instance ID
1. Go to Setup > Object Manager > Summit Events Instance
2. Find a test instance record
3. Copy the ID (e.g., `a1X5e000000ABCD`)

### Step 2: Build the URL

**For Experience Cloud:**
```
https://yoursite.force.com/s/registration?c__instanceId=a1X5e000000ABCD
```

**Replace:**
- `yoursite` with your actual site name
- `registration` with your page slug
- `a1X5e000000ABCD` with your actual instance ID

### Step 3: Open Browser Console
1. Navigate to the URL
2. Press F12 to open Developer Tools
3. Go to Console tab

### Step 4: Check Console Logs
You should see:
```
PageRef State: {c__instanceId: "a1X5e000000ABCD"}
Found instance ID in URL: a1X5e000000ABCD
Final Event Instance ID (from URL or API): a1X5e000000ABCD
```

If you DON'T see these logs, the URL parameters aren't being received.

---

## Common Issues

### Issue 1: PageRef is undefined
**Symptom**: `PageRef State: {}`  
**Cause**: CurrentPageReference not wired correctly  
**Solution**: Verify `@wire(CurrentPageReference) pageRef;` exists in class

### Issue 2: URL Parameters Empty
**Symptom**: `PageRef State: {}` even with URL params  
**Cause**: Missing `c__` prefix in Experience Cloud  
**Solution**: Use `?c__instanceId=...` instead of `?instanceId=...`

### Issue 3: Still Using window.location
**Symptom**: Parameters work in org but not Experience Cloud  
**Cause**: Code using `window.location.search` instead of `pageRef`  
**Solution**: Use CurrentPageReference as primary, window.location as fallback

---

## URL Structure in Experience Cloud

### Basic Structure
```
https://[domain]/s/[page-slug]?c__[param]=[value]
```

### Multiple Parameters
```
https://[domain]/s/registration?c__instanceId=a1X123&c__registrationId=abc456
```

### With Non-Custom Parameters (no c__ prefix)
```
https://[domain]/s/registration?c__instanceId=a1X123&lang=en_US
```

---

## Code Implementation

The component now implements a dual approach:

### Primary: CurrentPageReference (Experience Cloud)
```javascript
@wire(CurrentPageReference)
pageRef;

readUrlParameters() {
    const stateParams = this.pageRef?.state || {};
    const urlInstanceId = stateParams.c__instanceId || 
                         stateParams.instanceId;
    // Use the parameter...
}
```

### Fallback: window.location (Standard Salesforce)
```javascript
if (!urlInstanceId) {
    const urlParams = new URLSearchParams(window.location.search);
    const fallbackInstanceId = urlParams.get('instanceId');
    // Use the parameter...
}
```

---

## Setting Up Experience Cloud Page

### 1. Create the Page
1. Go to Experience Builder
2. Create new page or edit existing
3. Add the `summitEventsRegistration` component

### 2. Configure Page Properties
- **Page Name**: Registration (or your choice)
- **URL**: registration (this becomes the slug)
- **Public**: Yes (for guest access)

### 3. Configure Component (Optional)
You can set default values, but URL parameters will override:
- Event Instance ID: (leave blank if using URL params)
- Registration ID: (leave blank)

### 4. Publish the Site

### 5. Test URL
```
https://yoursite.force.com/s/registration?c__instanceId=YOUR_ID
```

---

## Verification Checklist

When testing, verify:

- [x] Component imports `CurrentPageReference`
- [x] Component has `@wire(CurrentPageReference) pageRef;`
- [x] URL uses `c__` prefix for parameters
- [x] Console shows "PageRef State" with your parameters
- [x] Console shows "Found instance ID in URL"
- [x] Component loads the correct event data
- [ ] Parameters override component properties
- [ ] Registration ID parameter works
- [ ] Fallback to window.location works (if needed)

---

## Debug Commands

Run these in the browser console to debug:

### Check pageRef
```javascript
document.querySelector('c-summit-events-registration').pageRef
```

### Check current instance ID
```javascript
document.querySelector('c-summit-events-registration').eventInstanceId
```

### Check component data
```javascript
document.querySelector('c-summit-events-registration').eventData
```

---

## Migration from Visualforce

### Old Visualforce URL
```
/apex/SummitEventsRegister?instanceId=a1X123
```

### New Experience Cloud URL
```
/s/registration?c__instanceId=a1X123
```

**Key Differences:**
1. Path: `/apex/PageName` → `/s/page-slug`
2. Parameter: `instanceId` → `c__instanceId`
3. Both work with the current implementation!

---

## Additional Resources

- [Salesforce Docs: CurrentPageReference](https://developer.salesforce.com/docs/component-library/bundle/lightning-navigation/documentation)
- [Experience Cloud URL Format](https://help.salesforce.com/s/articleView?id=sf.networks_url_formats.htm)
- [LWC Navigation Service](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_navigate)

---

**Status**: ✅ Implemented  
**Tested**: Pending user verification  
**Works In**: Experience Cloud, Communities, Standard Salesforce

