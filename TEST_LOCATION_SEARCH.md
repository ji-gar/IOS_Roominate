# Location Search Testing Guide

## Quick Start Testing

### Test 1: Blue Grotto Society Search ✅
**Fixes Defect B**

1. Open the app and navigate to Create Post
2. Tap on the location search field
3. Type: `Blue Grotto`
4. **Expected**: 
   - "Blue Grotto" appears in results with building icon (🏢)
   - Shows "Santacruz West, Mumbai" as secondary text
   - Result appears in **top 3** suggestions
   - Society icon is **blue** and text is **bold**

### Test 2: Typo Tolerance ✅
**Verifies fuzzy matching**

1. In location search, type: `blu groto`
2. **Expected**: 
   - Still returns "Blue Grotto" 
   - No crashes or empty results

### Test 3: Vapi City Search ✅
**Fixes Defect A - Tier 3 city**

1. In location search, type: `Vapi`
2. **Expected**: 
   - "Vapi" appears with city icon (🏛️)
   - Shows "India" as secondary text
   - Appears even if searching from Mumbai (170km away)

### Test 4: Santacruz Locality ✅
**Fixes Defect A - Mumbai locality**

1. Type: `Santacruz`
2. **Expected**: 
   - "Santacruz" appears (landmark icon)
   - "Santacruz East" appears
   - "Santacruz West" appears
   - All show "Mumbai, India" as secondary text

### Test 5: Kurla Locality ✅
**Fixes Defect A - Mumbai locality**

1. Type: `Kurla`
2. **Expected**: 
   - "Kurla" appears
   - "Kurla East" appears
   - "Kurla West" appears
   - All with landmark/locality icons

### Test 6: No Flicker Test ✅
**Verifies stale-response guard**

1. Type rapidly: `K` → `Ku` → `Kur` → `Kurl` → `Kurla`
2. **Expected**: 
   - Results update smoothly
   - **No flicker** where old results appear after new ones
   - Only see final "Kurla" results

### Test 7: Debounce Test ✅
**Verifies 250ms debounce**

1. Type slowly with pauses: `B` ... (wait) ... `a` ... (wait) ... `n`
2. **Expected**: 
   - Loading indicator appears briefly
   - Results appear ~250ms after stopping typing
   - No excessive API calls

## Visual Verification

### Icon Types
Check that results show correct icons:
- 🏢 **Societies**: `building.2.fill` (Blue Grotto, Hiranandani Gardens)
- 📍 **Landmarks**: `mappin.and.ellipse` (Santacruz, Kurla)
- 🗺️ **Localities**: `map` (other areas)
- 🏛️ **Cities**: `building.columns.fill` (Vapi, Mumbai, Delhi)

### Priority Order
When searching "pow" (Powai):
1. **First**: Any societies in Powai (if added to index)
2. **Second**: "Powai" as landmark
3. **Third**: Other localities/cities

## Other Societies to Test

Test these societies that are now in the local index:

- `Hiranandani Gardens` → Powai, Mumbai
- `Lokhandwala Complex` → Andheri West, Mumbai
- `Hiranandani Estate` → Thane West, Thane
- `Prestige Shantiniketan` → Whitefield, Bengaluru
- `DLF Park Place` → Golf Course Road, Gurugram
- `Brigade Gateway` → Rajajinagar, Bengaluru

## Performance Checks

### Response Time
- Type 3 characters
- **Expected**: Results appear in < 300ms (most should be < 250ms)

### Result Count
- **Expected**: Maximum 10 suggestions shown
- No more, no less (unless fewer matches exist)

### Deduplication
- Search for: `Blue Grotto`
- **Expected**: Only ONE "Blue Grotto" result
- Should not see "Blue Grotto" and "Blue Grotto CHS" as separate items (they should dedupe)

## Edge Cases

### Empty Query
1. Clear search field
2. **Expected**: No results, no crashes

### Single Character
1. Type: `M`
2. **Expected**: No results (min 2 characters required)

### No Results Query
1. Type: `zzxqwerty123`
2. **Expected**: 
   - Empty results
   - No crashes
   - No error messages (graceful empty state)

### Network Issues
1. Enable Airplane Mode
2. Search for: `Mumbai`
3. **Expected**: 
   - Local results still appear (Mumbai from cities array)
   - No crash, graceful degradation

## Google Places API Integration

### With API Key
If `APIConstants.googlePlacesAPIKey` is configured:
- Should see both local AND remote results
- Remote results merged with local results
- More comprehensive coverage

### Without API Key
If API key is empty:
- Should still see local results
- All sample societies still searchable
- Vapi, Santacruz, Kurla still appear

## Console Logs to Check

Look for these in Xcode console:

### Good Signs ✅
```
// (No error logs is good!)
```

### Bad Signs ❌
```
// These should NOT appear:
"MKLocalSearchCompleter failed: ..."
"Google Places API error: ..."
"Invalid API key"
"Rate limit exceeded"
```

## Troubleshooting

### Problem: No Results for Blue Grotto
**Check**: 
- Ensure `IndianLocationsService.swift` has `societies` array
- Verify you're searching in `.address` mode, not `.cities` mode

### Problem: Vapi Not Appearing
**Check**: 
- Confirm `Vapi` is in `IndianLocationsService.cities` array
- Verify Google Places API is not applying type restrictions

### Problem: UI Flickering
**Check**: 
- Verify `sequenceNumber` property exists in `GooglePlacesService`
- Check stale-response guard is in place

### Problem: No Icons Showing
**Check**: 
- Verify `PlaceSuggestion.EntityType` enum exists
- Confirm `entityType` computed property is implemented
- Check UI is using `suggestion.entityType.iconName`

## Success Criteria

All tests pass when:
- ✅ Blue Grotto searchable and in top 3
- ✅ Typos handled gracefully (blu groto works)
- ✅ Vapi appears from anywhere in India
- ✅ Santacruz and Kurla localities appear
- ✅ No UI flicker during rapid typing
- ✅ Results appear within 250-300ms
- ✅ Correct icons for each entity type
- ✅ Societies appear before cities in results
- ✅ Maximum 10 results displayed
- ✅ No crashes on edge cases

## Reporting Issues

If any test fails, note:
1. Which test failed
2. What was typed
3. What appeared (or didn't appear)
4. Any console error messages
5. Network status (online/offline)
6. Whether Google API key is configured

---

**Test Date**: ___________
**Tester**: ___________
**Build**: ___________
**Result**: ⬜ Pass ⬜ Fail
