# CSP Trusted Sites Package.xml Fix

**Date**: January 4, 2026  
**Issue**: `deploy_trusted_site_settings` task not deploying CSP Trusted Sites  
**Root Cause**: Incorrect metadata type in package.xml

---

## Problem

The `package.xml` had:
```xml
<name>CustomSite</name>
```

But it should be:
```xml
<name>CspTrustedSite</name>
```

**Why it failed**: The metadata files use `.cspTrustedSite-meta.xml` extension, which corresponds to the `CspTrustedSite` metadata type, not `CustomSite`.

---

## Fix Applied

Updated `unpackaged/config/cspTrustedSites/package.xml`:

### Before (Incorrect)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>*</members>
        <name>CustomSite</name>  ❌ WRONG
    </types>
    <version>64.0</version>
</Package>
```

### After (Correct)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>*</members>
        <name>CspTrustedSite</name>  ✅ CORRECT
    </types>
    <version>64.0</version>
</Package>
```

---

## What Gets Deployed

With this fix, the following CSP Trusted Sites will deploy:

### 1. SEA_GitHub
- **URL**: `https://raw.githubusercontent.com`
- **Purpose**: Allow loading images from GitHub raw content
- **Applicable to**: `img-src` directive

### 2. SEA_QR_CODE
- **URL**: `https://api.qrserver.com`
- **Purpose**: Allow loading QR code images from QR Server API
- **Applicable to**: `img-src` directive

---

## Testing the Deployment

### Using CumulusCI
```powershell
cd C:\Users\thad\Documents\Repositories\Summit-Events-App
cci task run deploy --path unpackaged/config/cspTrustedSites --org dev
```

### Expected Output
```
Deploying metadata...
Processing Type: CspTrustedSite
[Success]: Succeeded
```

### Verify in Org
1. Go to **Setup**
2. Search for **CSP Trusted Sites**
3. Verify these sites are listed:
   - SEA_GitHub (`https://raw.githubusercontent.com`)
   - SEA_QR_CODE (`https://api.qrserver.com`)

---

## Why CSP Trusted Sites Matter

CSP (Content Security Policy) Trusted Sites allow your Salesforce org to load external resources securely:

- **Without CSP Trusted Sites**: External images/scripts blocked by browser security
- **With CSP Trusted Sites**: Whitelisted domains can load resources

**For Summit Events App**:
- GitHub images can be used in event descriptions
- QR codes can be generated for event registration links

---

## Common Metadata Type Confusions

| Metadata File Extension | Correct Metadata Type | Common Mistake |
|------------------------|----------------------|----------------|
| `.cspTrustedSite-meta.xml` | `CspTrustedSite` | `CustomSite` ❌ |
| `.site-meta.xml` | `CustomSite` | `Site` ❌ |
| `.remoteSiteSetting-meta.xml` | `RemoteSiteSetting` | `RemoteSite` ❌ |

**Rule**: Check the XML file extension to determine the correct metadata type name.

---

## Files Modified

- `unpackaged/config/cspTrustedSites/package.xml` - Fixed metadata type name

---

## Status

✅ **FIXED AND DEPLOYED SUCCESSFULLY**  
✅ **Package.xml corrected to use `CspTrustedSite`**  
✅ **Deployed 2 CSP Trusted Sites (GitHub, QR Server)** - Verified in org January 4, 2026
✅ **Both sites are Active and functioning**

### Verification Query Results
```
┌────────────────────┬───────────────┬───────────────────────────────────┬──────────┐
│ ID                 │ DEVELOPERNAME │ ENDPOINTURL                       │ ISACTIVE │
├────────────────────┼───────────────┼───────────────────────────────────┼──────────┤
│ 08yEm000000TNhBIAW │ SEA_GitHub    │ https://raw.githubusercontent.com │ true     │
│ 08yEm000000TNhCIAW │ SEA_QR_CODE   │ https://api.qrserver.com          │ true     │
└────────────────────┴───────────────┴───────────────────────────────────┴──────────┘
```

---

## Additional Notes

If you add more CSP Trusted Sites in the future:
1. Create a new `.cspTrustedSite-meta.xml` file
2. The `package.xml` with `<members>*</members>` will automatically include it
3. No need to update package.xml again

**Alternatively**, you can specify individual sites:
```xml
<types>
    <members>SEA_GitHub</members>
    <members>SEA_QR_CODE</members>
    <name>CspTrustedSite</name>
</types>
```

The wildcard `*` is easier to maintain when you have multiple sites.

