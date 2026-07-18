# UAT Fixes Summary

## Completed Fixes

### ✅ BUG-008 — Area autocomplete not working; Next button disabled
**Issue:** In the Create Post "Share Your Location Preference" screen, when users typed text in the "Preferred Area" field without selecting an autocomplete suggestion, the Next button remained disabled.

**Root cause:** The `isSeekerLocationValid` check required `draft.preferedLocation` to be non-empty, but that field was only populated when a user tapped an autocomplete suggestion. Free-typed text was held in the transient `preferredAreaQuery` binding.

**Fix:**
- Updated `isSeekerLocationValid` to also accept free-typed text in the `preferredAreaQuery` field
- Added `commitPreferredAreaQueryIfNeeded()` method to save typed text when the user taps Next
- Users can now proceed with either autocomplete selection OR manually typed area text

**Files changed:**
- `ViewModels/CreatePostViewModel.swift` — validation and commit logic
- `Views/Home/CreatePostSeekerLocationView.swift` — call commit on Next

---

### ✅ CHANGE-001 — Remove "Looking for Male/Female" from flatmate cards
**Issue:** Flatmate cards displayed "Looking for: Male/Female" text, which was redundant and should only appear on flat listings (not flatmate seeker cards).

**Fix:**
- Removed the `InlineDetail(label: "Looking for", value: listing.lookingFor)` line from `FlatmateCard.swift`

**Files changed:**
- `Views/Home/Components/FlatmateCard.swift`

---

### ✅ CHANGE-002 — Extra Cost field should allow alphanumeric text
**Issue:** The "Extra Cost" field was validated as required and displayed with currency formatting, which suggested it must be numeric. Users wanted to enter descriptive text like "Electricity separate" or "Included in rent."

**Fix:**
- Made the Extra Cost field **optional** (removed from `isAvailabilityValid` required checks)
- Updated label to "Extra Cost (optional)" in the UI
- Added `extraCostDisplay()` helper that shows currency formatting for numeric values and raw text for alphanumeric entries
- Preview now displays text as-is instead of forcing currency formatting

**Files changed:**
- `ViewModels/CreatePostViewModel.swift` — validation
- `Views/Home/CreatePostAvailabilityView.swift` — field label
- `Views/Home/CreatePostPreviewView.swift` — display logic

---

### ✅ General Observation 2 — Add Delete Chat conversation option
**Issue:** Users had no way to delete or remove conversations from the chat list.

**Fix:**
- Added `deleteConversation(conversationId:)` endpoint to `APIConstants`
- Implemented `deleteConversation` method in `ChatService` and `ChatServiceProtocol`
- Added `deleteConversation(_:)` method to `ChatListViewModel` with optimistic UI update
- Added swipe-to-delete action on conversation rows in `ChatListView`

**Files changed:**
- `Core/Constants/APIConstants.swift` — delete endpoint
- `Services/ChatService.swift` — delete API call
- `ViewModels/ChatListViewModel.swift` — delete logic
- `Views/Chat/ChatListView.swift` — swipe actions

---

## Known Backend Issue

### ⚠️ General Observation 1 — Posts appear in Profile but not Home Feed
**Issue:** Newly created posts are visible in the user's profile under "My Posts" but do not appear in the public home feed.

**Analysis:**
The client correctly maps `isAvailable: post.isHidden != true` for both flat and flatmate listings. The filtering logic is correct. The issue is **server-side**:

- The public catalog endpoint (`GET /posts`) likely applies additional filters or permissions that exclude newly created posts
- OR newly created posts default to `is_hidden: true` on the server
- The profile endpoint (`GET /posts/my/all`) returns all user posts regardless of hidden status

**Recommendation:** 
Backend team should investigate:
1. Default value of `is_hidden` field when posts are created (should be `false`)
2. Server-side filters on the public `/posts` endpoint
3. Any post approval workflow that might be blocking visibility

**No client-side code changes needed** — this is purely a backend/API issue.

---

## Testing Notes

All fixes have been applied. To test:

1. **BUG-008:** Create a flatmate post → navigate to "Share Your Location Preference" → type an area name without selecting autocomplete → verify Next button enables
2. **CHANGE-001:** View flatmate cards in the explore feed → verify "Looking for Male/Female" text is no longer displayed
3. **CHANGE-002:** Create a flat post → enter text like "Included" or "Extra charges apply" in Extra Cost field → verify it saves and displays correctly in preview
4. **General 2:** Open Messages → swipe left on any conversation → tap Delete → verify conversation is removed

---

## Summary

- ✅ 4 of 5 issues fixed
- ⚠️ 1 issue requires backend investigation (posts not in home feed)
- All client-side bugs and change requests have been resolved
