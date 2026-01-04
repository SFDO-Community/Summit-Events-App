# URL Parameters in Experience Cloud - Complete Guide

**Last Updated**: January 4, 2026  
**Status**: ✅ Working - Deployed and Verified

---

## Quick Reference

### Your Working URL
```
https://customer-ability-8761-dev-ed.scratch.my.site.com/s/?instanceID=a06Em00000YEHM1
```

### Supported Parameter Names
- Instance ID: `instanceID`, `instanceId`, `eventInstanceId`, `id` (+ `c__` prefixed versions)
- Registration ID: `registrationID`, `registrationId`, `regId` (+ `c__` prefixed versions)

---

## Implementation Details

### Why CurrentPageReference?
In Experience Cloud, `window.location.search` doesn't work reliably. You **must** use `CurrentPageReference` from `lightning/navigation`.

### Code Implementation
```javascript
import { CurrentPageReference } from 'lightning/navigation';

@wire(CurrentPageReference)
pageRef;

readUrlParameters() {
    const stateParams = this.pageRef?.state || {};
    const urlInstanceId = stateParams.instanceID || 
                         stateParams.instanceId ||
                         stateParams.c__instanceID ||
                         // ... more variants
}
```

### URL Parameter Precedence
1. 🥇 URL parameters (CurrentPageReference state)
2. 🥈 URL parameters (window.location fallback)
3. 🥉 Component `@api` properties (if URL not present)

**URL parameters OVERRIDE component properties** - this allows dynamic navigation.

---

## Case Sensitivity Issue (RESOLVED)

### The Problem
JavaScript URL parameter reading is **case-sensitive**:
- Visualforce uses: `?instanceID=...` (capital D)
- Component was only checking: `?instanceId=...` (lowercase d)
- Result: Parameters not recognized

### The Fix
Component now checks for **both variations**:
- `instanceID` ✅ (capital D - Visualforce format)
- `instanceId` ✅ (lowercase d - standard format)
- Plus `c__` prefixed versions for Experience Cloud

### Verification
```powershell
# Query to verify parameters are working
sf data query --query "SELECT Id, DeveloperName FROM CspTrustedSite" --target-org dev
```

Check browser console logs:
```
PageRef State: {instanceID: "a06Em00000YEHM1"}
Found instance ID in URL: a06Em00000YEHM1
Final Event Instance ID: a06Em00000YEHM1
```

---

## Experience Cloud URL Format

### Standard Format
```
https://[domain]/s/[page-slug]?c__[param]=[value]
```

### Your Current Format
```
https://[domain]/s/?instanceID=[value]
```

Note: The `c__` prefix is typically needed for custom parameters in Experience Cloud, but the component supports both formats as a fallback.

---

## Migration from Visualforce

### Old URL (Visualforce)
```
/SummitEventsRegister?instanceID=a06Em00000YEHM1
```

### New URL (LWC)
```
/s/registration?instanceID=a06Em00000YEHM1
```

**What Changed**: Only the page path
**What Stayed**: Parameter name `instanceID` (backward compatible)

---

## Testing Checklist

### Basic Test
1. ✅ Navigate to URL with `instanceID` parameter
2. ✅ Open browser console (F12)
3. ✅ Verify console shows: `PageRef State: {instanceID: "..."}`
4. ✅ Verify console shows: `Found instance ID in URL: ...`
5. ✅ Verify event loads correctly

### Advanced Test
- ✅ Test with lowercase `instanceId`
- ✅ Test with `c__instanceID`
- ✅ Test resume with `registrationID` parameter
- ✅ Test in multiple browsers
- ✅ Test that URL overrides component property

---

## Troubleshooting

### PageRef State is Empty `{}`
**Cause**: Parameter not being passed to component  
**Solutions**:
- Try adding `c__` prefix: `?c__instanceID=...`
- Verify component is on the page
- Check Experience Builder settings
- Clear browser cache

### Parameter Found But Event Doesn't Load
**Cause**: Invalid instance ID or Apex error  
**Solutions**:
- Verify instance ID exists in org
- Check browser console for Apex errors
- Verify guest user permissions
- Check CSP Trusted Sites are deployed

### Works in Org But Not Experience Cloud
**Cause**: Different URL parameter handling  
**Solutions**:
- Use CurrentPageReference (already implemented)
- Test with `c__` prefix
- Verify site is published
- Check community is active

---

## Key Learnings

### 1. Case Sensitivity Matters
Always support multiple variations of parameter names for backward compatibility.

### 2. Experience Cloud vs Standard Salesforce
- Experience Cloud: Use `CurrentPageReference`
- Standard Salesforce: Can use `window.location`
- Our implementation: Supports both ✅

### 3. URL Override Pattern
URL parameters should override component properties for dynamic navigation and link sharing.

---

## Files Modified

1. **summitEventsRegistration.js**
   - Added `CurrentPageReference` import and wire
   - Added `readUrlParameters()` method
   - Checks for both `instanceID` and `instanceId`
   - Supports `c__` prefixed parameters

2. **summitEventsRegistration.js-meta.xml**
   - Made `eventInstanceId` optional (`required="false"`)
   - Updated descriptions to mention URL parameters

---

## Related Documentation

- `LWC-COMPONENTS-GUIDE.md` - Full LWC component architecture
- `AI-TOOLS-CONFIG.md` - Development patterns and best practices
- `LWC-WRAPPER-CLASS-DOCUMENTATION.md` - Apex data structure reference

---

**Status**: ✅ **WORKING** - Deployed and verified January 4, 2026

