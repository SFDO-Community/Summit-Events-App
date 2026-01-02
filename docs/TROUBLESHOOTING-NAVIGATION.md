# Troubleshooting Page Navigation Issue

## Changes Made

### 1. Fixed `navigateToPage()` Reactivity Issue
**Problem**: LWC doesn't detect deep object mutations  
**Solution**: Create new arrays/objects to trigger reactivity

**Before**:
```javascript
this.eventData.pages[this.currentPageIndex].isActive = false;
this.currentPageIndex = pageIndex;
this.eventData.pages[this.currentPageIndex].isActive = true;
```

**After**:
```javascript
// Create new pages array to trigger reactivity
const updatedPages = this.eventData.pages.map((page, index) => {
    return {
        ...page,
        isActive: index === pageIndex
    };
});

// Update eventData with new pages array
this.eventData = {
    ...this.eventData,
    pages: updatedPages
};

// Update current page index
this.currentPageIndex = pageIndex;
```

### 2. Added Debug Logging
Added console.log statements to:
- `handleNext()` - Track when Next is clicked
- `validateCurrentPage()` - See validation results
- `saveCurrentPageData()` - Track data saving
- `updateEventData()` - See data updates
- `currentPage` getter - Track which page is active
- `isRegisterPage/isQuestionsPage` getters - Track page type checks

## How to Debug

### Step 1: Open Browser Console
1. Open your Experience Cloud page with the component
2. Press F12 to open Developer Tools
3. Go to Console tab

### Step 2: Test Navigation
1. Fill out the registration form
2. Click "Next"
3. Watch the console output

### Expected Console Output
```
handleNext called, currentPageIndex: 0
Validating page component: <c-summit-events-register-page>
Page validation result: true
Validation passed
Saving data from page component: <c-summit-events-register-page>
Retrieved page data: {primaryRegistration: {...}}
Updating event data with: {primaryRegistration: {...}}
Getting currentPage, index: 1, page: {pageType: 'questions', ...}
isRegisterPage: false, pageType: questions
isQuestionsPage: true, pageType: questions
```

### Step 3: Check for Errors
Look for any of these issues in the console:

**Issue 1: Validation Failing**
```
handleNext called, currentPageIndex: 0
Validating page component: <c-summit-events-register-page>
Page validation result: false
Validation failed
```
**Solution**: Check which fields are invalid, add better error messages

**Issue 2: Page Component Not Found**
```
Validating page component: null
No validate method found, returning true
```
**Solution**: Check that the `current-page-component` class is correctly applied

**Issue 3: eventData Not Updating**
```
Getting currentPage, index: 1, page: undefined
```
**Solution**: Check that eventData.pages array exists and has multiple pages

## Manual Test

To manually verify the fix works, you can run this in the browser console after the component loads:

```javascript
// Get the component instance
const comp = document.querySelector('c-summit-events-registration');

// Check current state
console.log('Current page index:', comp.currentPageIndex);
console.log('Event data pages:', comp.eventData?.pages);
console.log('Current page:', comp.currentPage);

// Try to navigate manually
comp.navigateToPage(1);

// Check if it worked
console.log('After navigate - Current page index:', comp.currentPageIndex);
console.log('After navigate - Current page:', comp.currentPage);
```

## Common Issues & Solutions

### Issue: Page Doesn't Change Visually
**Symptoms**: Console shows page index changing but UI doesn't update  
**Cause**: Template conditionals not re-evaluating  
**Solution**: Verify getters are properly reactive (already fixed)

### Issue: Validation Blocks Navigation
**Symptoms**: "Validation failed" in console  
**Cause**: Required fields not filled, or validation method has bug  
**Solution**: 
1. Check registerPage.validate() method
2. Add console.log in validate method
3. Check all required fields have values

### Issue: Data Not Saving
**Symptoms**: Navigation works but data lost when going back  
**Cause**: getData() method not returning proper structure  
**Solution**: Check that getData() returns correct format

## Next Steps

1. **Deploy the fix** (currently deploying)
2. **Test in Experience Cloud** with console open
3. **Share console output** if issue persists
4. **Check validation** - might need to make some fields optional for testing

## Files Modified

- `summitEventsRegistration.js` - Fixed navigation and added logging
  - Line ~113: navigateToPage() method
  - Line ~95: handleNext() method
  - Line ~133: validateCurrentPage() method
  - Line ~144: saveCurrentPageData() method
  - Line ~15: currentPage getter
  - Line ~41: isRegisterPage getter
  - Line ~47: isQuestionsPage getter

---

**Status**: Deployed with debug logging  
**Next**: Test and review console output

