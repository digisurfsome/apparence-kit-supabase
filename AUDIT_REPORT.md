# ApparenceKit Boilerplate - Full Code Audit Report

**Date:** February 20, 2026
**Auditor:** Claude 4.6 (automated)
**Project:** ApparenceKit Flutter Boilerplate
**Files Reviewed:** ~490 across all modules

---

## Executive Summary

This boilerplate has a **solid architectural foundation** (clean 3-layer architecture, Riverpod, Freezed, proper module separation) but suffers from **sloppy copy-paste errors, unfinished TODOs, and security oversights** that suggest it was shipped quickly without thorough QA. It's usable as a starting point, but you'll need to fix the critical bugs before deploying any real app from it.

**Verdict:** Good bones, bad finishing. Fix the 5 critical bugs and 8 high-priority issues below before using as a production template.

---

## CRITICAL BUGS (5) - Must fix before any app ships

### 1. Sign-in provider checks wrong type (copy-paste bug)
**File:** `lib/modules/authentication/providers/signin_state_provider.dart:42`
```dart
// BUG: checks SignupStateSending instead of SigninStateSending
if (state is SignupStateSending) {  // <-- WRONG TYPE
  return;
}
```
**Impact:** The "prevent double-submit" guard NEVER fires on sign-in. Users can spam the sign-in button causing duplicate auth requests. Same bug repeated on lines 61, 77, 94, 112.
**Fix:** Change all `SignupStateSending` to `SigninStateSending`.

---

### 2. Phone auth passes OTP as phone number (logic error)
**File:** `lib/modules/authentication/providers/phone_auth_notifier.dart:114`
```dart
on PhoneAlreadyLinkedException {
  state = state.copyWith(linkPhoneToUser: false);
  return sendOtp(otp);  // <-- BUG: passes OTP string, not phone number
}
```
**Impact:** When a phone number is already linked and the user retries, the OTP code gets sent to Firebase as the phone number. This will always fail with an invalid phone number error.
**Fix:** Change to `sendOtp(state.phoneNumber)`.

---

### 3. Wrong error messages everywhere (copy-paste from signup)
Multiple files have error messages copy-pasted from the signup provider:

| File | Line | Says | Should Say |
|------|------|------|------------|
| `signin_state_provider.dart` | 54 | "Error while signing up" | "Error while signing in" |
| `signin_state_provider.dart` | 71 | "Error while signing up" | "Error while signing in" |
| `signin_state_provider.dart` | 88 | "Error while signing up" | "Error while signing in" |
| `signin_state_provider.dart` | 105 | "Error while signing up" | "Error while signing in" |
| `signin_state_provider.dart` | 122 | "Error while signing up" | "Error while signing in" |
| `recover_provider.dart` | 39 | "Error while signing up" | "Error recovering password" |

---

### 4. RecoverPasswordException.toString() returns wrong class name
**File:** `lib/modules/authentication/repositories/exceptions/authentication_exceptions.dart:65`
```dart
class RecoverPasswordException {
  @override
  String toString() {
    return 'SigninException(code: $code, message: $message)';  // <-- WRONG
  }
}
```
**Impact:** Error logs/debugging for password recovery show "SigninException" making it impossible to diagnose issues correctly.

---

### 5. Firebase credentials committed to repo + dev/prod identical
**Files:** `lib/firebase_options.dart` and `lib/firebase_options_dev.dart`
- Both files contain **identical** API keys and project IDs
- Real Firebase API keys are hardcoded: `AIzaSyB0hISNv8DVu3rO0U-SzMp37RtZxyTJySE`, etc.
- Project ID `sugarless-252ae` is your personal Firebase project
- `main.dart:55` confirms prod environment also uses the dev config

**Impact for auto-forge:** Every app cloned from this template will point to YOUR Firebase project unless you replace these files. This is a showstopper for your use case.

---

## HIGH PRIORITY (8) - Fix before production use

### 6. 40+ generated files committed to git
The `.gitignore` does NOT exclude `.freezed.dart` or `.g.dart` files. 40+ generated files are tracked in git:
```
lib/core/ads/ads_provider.g.dart
lib/core/ads/ads_state.freezed.dart
lib/core/data/entities/user_entity.freezed.dart
lib/core/data/entities/user_entity.g.dart
... (40+ more)
```
**Impact for auto-forge:** These generated files may conflict with code generation after template modifications. They should be in `.gitignore` and regenerated per-project.

### 7. Hardcoded Firebase region
**Files:** `lib/core/data/api/user_api.dart:15` and `lib/modules/authentication/api/authentication_api.dart:20`
```dart
FirebaseFunctions.instanceFor(region: 'europe-west1')
```
**Impact:** Every app will call Firebase Functions in Europe regardless of where the user's Firebase project is hosted. Must be configurable per-project.

### 8. Weak password validation
**File:** `lib/modules/authentication/providers/models/password.dart:10`
```dart
if (value.length < 5) {  // Only 5 characters required
```
**Impact:** Below industry standards. No uppercase/lowercase/number/symbol requirements. App store reviewers may flag this.

### 9. Non-exhaustive switch statements in subscription
**File:** `lib/core/data/models/subscription.dart`
- Line 190: `formattedPrice()` - missing `threeMonth`, `sixMonth` cases, falls through to empty string
- Line 203-208: `pricePerMonth()` - missing `month` case, returns `1` as price
- Line 226-231: `pricePerYear()` - missing `month` case, returns `1` as price

**Impact:** 3-month and 6-month subscriptions show blank or "$1.00" prices to users.

### 10. Hardcoded app name in multiple locations
- `web/index.html:32` - `<title>apparencekit</title>`
- `web/manifest.json:2-3` - `"name": "apparencekit_pro"`
- `lib/modules/notifications/api/local_notifier.dart:24` - `const kAppName = 'flutter_base'`
- `web/index.html:26` - `apple-mobile-web-app-title` = "apparencekit"
- `kit_setup.json:2` - `"appName": "flutter_base"`
- `kit_setup.json:3` - `"bundleId": "com.yourcompany.template"`

**Impact for auto-forge:** All of these need to be parameterized/replaced when cloning.

### 11. Empty catch blocks silently swallow errors
**Files:** `lib/core/data/api/tracking_api.dart` and others
```dart
} catch (_) {}  // Error completely swallowed
```
**Impact:** Bugs in analytics/tracking are invisible. You'll never know if Mixpanel/Facebook tracking is broken.

### 12. Exception classes don't extend Exception
**File:** `lib/modules/authentication/repositories/exceptions/authentication_exceptions.dart`
`SignupException`, `SigninException`, `RecoverPasswordException` are plain classes that don't extend or implement `Exception`. Only `PhoneAuthException` extends `ApiError`.
**Impact:** These can't be caught with `on Exception catch (e)` patterns, leading to uncaught error scenarios.

### 13. Subscription `checkPermission` always returns true
**File:** `lib/modules/subscription/repositories/subscription_repository.dart:125-131`
```dart
Future<bool> checkPermission(String permissionToCheck) async {
    final permissions = await _inAppSubscriptionApi.getPermissions();
    if (permissions.isEmpty) {
      throw Exception("Permission denied");
    }
    return permissions.isNotEmpty;  // <-- Always true if we get here
}
```
**Impact:** The `permissionToCheck` parameter is completely ignored. Any user with ANY permission passes ALL permission checks.

---

## MEDIUM PRIORITY (12) - Fix when time allows

### 14. Unfinished TODOs left in code
7 TODO comments found in production code:
- `main.dart:54` - "TODO replace with your own firebase options for production"
- `user_api.dart:15` - "TODO get region from environment"
- `device_api.dart` (2 TODOs) - Storage/Carrier device info incomplete
- `rating_repository.dart` (2 TODOs) - Rating delays hardcoded, should come from env
- `rate_banner.dart` - "TODO create factory that get value from env"

### 15. Polling loop in auth init
**File:** `lib/modules/authentication/api/authentication_api.dart`
Uses `Future.delayed()` in a while loop to wait for initialization - wasteful and fragile.

### 16. Arbitrary delays throughout codebase
- `phone_auth_notifier.dart:106` - 2-second delay after OTP verify
- `signin_state_provider.dart:51` - 1.5-second fake delay "to prevent spamming"
- `signup_state_provider.dart` - Same 1.5-second delay
- `recover_provider.dart:36` - Same 1.5-second delay
- `storage_api.dart:73` - 1-second delay before getting download URL

### 17. Guard widget doesn't handle loading/error states
**File:** `lib/core/guards/guard.dart:32-40`
Shows empty `Container()` while loading and silently ignores errors.

### 18. Typo in user-facing string
**File:** `lib/main.dart:236` - Says "developper" instead of "developer"

### 19. `pubspec.lock` committed (debatable for apps vs libraries)
The `pubspec.lock` is committed which is fine for reproducible builds but means dependency updates require manual lock file updates.

### 20. Sentry trace rate at 20%
**File:** `lib/main.dart:69`
`tracesSampleRate: 0.2` - For a new app you want this at 1.0 (100%) and decrease later.

### 21. No token refresh mechanism
**File:** `lib/core/security/secured_storage.dart`
Tokens are stored and read but never refreshed. If a Firebase token expires, the app fails silently.

### 22. Inconsistent naming - "environnements" (French spelling)
**File:** `lib/environnements.dart` - French spelling "environnements" instead of English "environments". The `.claude/rules/flutter.mdc` specifically says "use English for code".

### 23. Comments saying "prevent spamming signup button" on SIGN-IN page
More evidence of copy-paste without review.

### 24. `main.dart:110` - ErrorWidget.builder set inside build()
Setting `ErrorWidget.builder` inside `Widget build()` means it runs on every rebuild. Should be in `main()` or `initState()`.

### 25. Missing null safety
- `subscription_repository.dart:87` - Force unwraps `entity!.skuId` without null check
- `subscription_repository.dart:169` - Force unwraps `_prefs!` without null check

---

## TEMPLATE-READINESS ISSUES (for auto-forge system)

### Things that MUST change per-app clone:
1. `firebase_options.dart` / `firebase_options_dev.dart` - Firebase config (must regenerate per project)
2. `kit_setup.json` - App name, bundle ID, backend provider settings
3. `web/index.html` - App title, meta descriptions
4. `web/manifest.json` - App name
5. `android/` - Package name, signing configs
6. `pubspec.yaml` - Project name, description
7. `lib/environnements.dart` - Backend URL, RevenueCat keys, Sentry DSN, Mixpanel token
8. `lib/modules/notifications/api/local_notifier.dart:24` - `kAppName`
9. Firebase region in `user_api.dart` and `authentication_api.dart`

### Things to add to `.gitignore`:
```
*.g.dart
*.freezed.dart
firebase_options.dart
firebase_options_dev.dart
```

---

## ARCHITECTURE ASSESSMENT

### What's Good
- **Clean 3-layer architecture** (API -> Repository -> UI) consistently followed
- **Riverpod + Freezed** is modern best practice for Flutter state management
- **Module separation** is clean (auth, subscription, notifications, onboarding, settings, feedback)
- **Fake implementations for testing** instead of mocks - makes tests more reliable
- **Route guards** for authentication flow
- **Environment-based configuration** (dev/prod) via Dart defines
- **CI/CD pipelines** for both GitHub Actions and GitLab CI
- **Strict linting** with `package:lint/strict.yaml`

### What's Bad
- **Heavy copy-paste** across providers with bugs propagated
- **No input sanitization** on user-facing forms beyond basic email/password validation
- **Test coverage is thin** - only basic happy paths, no error cases, no edge cases
- **7 unfinished TODOs** in production code
- **French naming** mixed with English (environnements)
- **Generated code in git** - should be generated at build time
- **No CI step for code generation** - `build_runner` must be run manually

### Overall Grade: **C+**
Good architecture, poor execution. The French agency clearly knew Flutter patterns but shipped this boilerplate without proper QA. Usable as a foundation if you fix the critical bugs first.

---

## RECOMMENDED FIX ORDER

### Phase 1: Critical (do before any app ships)
1. Fix sign-in type check bug (5 occurrences)
2. Fix phone auth OTP/phone number swap
3. Fix all copy-paste error messages
4. Fix RecoverPasswordException toString
5. Add firebase_options files to .gitignore, set up per-project regeneration

### Phase 2: High Priority
6. Add generated files to .gitignore
7. Make Firebase region configurable
8. Strengthen password validation
9. Fix non-exhaustive switch statements
10. Fix empty catch blocks
11. Fix exception class hierarchy
12. Fix checkPermission logic
13. Replace hardcoded app names with config values

### Phase 3: Template System Prep
14. Create a configuration script/checklist for auto-forge
15. Parameterize all per-app values
16. Add build_runner to CI/CD pipeline
17. Resolve all TODOs or document as known limitations
