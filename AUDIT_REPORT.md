# ApparenceKit Boilerplate - Full Code Audit Report

**Date:** March 20, 2026
**Auditor:** Claude 4.6 (automated)
**Project:** ApparenceKit Flutter Boilerplate (apparence-kit-supabase)
**Files Reviewed:** ~490 across all modules
**Overall Grade: B-**

---

## Executive Summary

This boilerplate has a **solid architectural foundation** (clean 3-layer architecture, Riverpod, Freezed, proper module separation). Several critical bugs found in the Firebase sister repo have **already been fixed** in this version, showing that the codebase has been actively maintained. The remaining issues are primarily template-readiness concerns (hardcoded names, placeholder credentials, naming mismatches) rather than logic errors.

**Verdict:** Good architecture with most critical bugs already resolved. The main concerns are template-readiness issues that must be addressed per-app and one copy-paste UI text bug.

---

## Bugs Fixed Since Firebase Sister Repo

The following bugs that existed in the Firebase version have been **correctly fixed** in this codebase:

1. `signin_state_provider.dart` correctly checks `SigninStateSending` (was `SignupStateSending` in Firebase version)
2. `phone_auth_notifier.dart` correctly passes `state.phoneNumber` in the `verifyOtp` catch block (was passing the OTP string in Firebase version)
3. Error messages in `signin_state_provider.dart` correctly say "Error while signing in" (said "signing up" in Firebase version)
4. `RecoverPasswordException.toString()` correctly returns `'RecoverPasswordException'` (returned `'SigninException'` in Firebase version)
5. Exception classes correctly implement `Exception`
6. Password validation requires 8 characters (was 5 in Firebase version)
7. `checkPermission` correctly uses `permissions.contains(permissionToCheck)` (was always-true in Firebase version)

---

## CRITICAL BUGS (1) - Must fix before any app ships

### 1. Sign-in button text says "Create my account"
**File:** `lib/modules/authentication/ui/signin/signin_page.dart:132`
**Issue:** Copy-paste from signup page. The sign-in button displays "Create my account" instead of "Sign in".
**Impact:** Confusing UX on the sign-in page. Users may think they are creating a new account.

---

## HIGH PRIORITY (5) - Fix before production use

### 2. Hybrid architecture requires clear documentation
This boilerplate uses a **dual-backend architecture by design**: Supabase for auth + database + storage, and Firebase for push notifications (FCM) + remote config (since Supabase doesn't provide these). The current code still uses Firebase for some data operations (Firestore, Firebase Auth) that should be migrated to Supabase equivalents. The Firebase dependencies for notifications and remote config must remain.

### 3. google-services.json committed to repo
**File:** `android/app/google-services.json`
Firebase credentials (project ID: `sugarless-252ae`) were tracked in git. **Fixed:** removed from tracking.

### 4. firebase_options.dart and firebase_options_dev.dart committed
**Files:** `lib/firebase_options.dart`, `lib/firebase_options_dev.dart`
Both files contain API keys and are identical (dev config = prod config). Were in `.gitignore` but still tracked in git. **Fixed:** removed from tracking.

### 5. 44 generated files (.g.dart, .freezed.dart) committed to git
Generated files that should be produced at build time were tracked in git. `.gitignore` already had rules for these. **Fixed:** removed from tracking.

### 6. Duplicate import in device_api.dart
**File:** `lib/core/data/api/device_api.dart:12-13`
`import 'package:flutter/foundation.dart';` appears twice. Will cause linter warnings.

---

## MEDIUM PRIORITY (8) - Fix when time allows

### 7. Hardcoded app names in multiple locations
- `android/app/src/main/AndroidManifest.xml:11` - `flutter_base`
- `web/index.html:32` - `ApparenceKit`
- `web/manifest.json:2-3` - `ApparenceKit`
- `lib/modules/notifications/api/local_notifier.dart:24` - `kAppName = 'flutter_base'`
- `lib/main.dart:126` - `Flutter Pro Starter Kit`

### 8. Template package name com.yourcompany.template
Appears in AndroidManifest.xml, `MainActivity.kt`, `google-services.json`, and `firebase_options.dart`. Must be replaced per-app.

### 9. Empty terms/privacy URLs
**File:** `lib/environments.dart:23-24`
`kTermsUrl` and `kPrivacyUrl` are empty strings. Will result in broken links if users tap terms or privacy buttons.

### 10. Hardcoded Firebase region 'us-central1'
**Files:** `lib/core/data/api/user_api.dart:14`, `lib/modules/authentication/api/authentication_api.dart:18`
Region is hardcoded rather than configurable via environment. Must change per-project depending on Firebase deployment region.

### 11. Facebook placeholder values
**File:** `android/app/src/main/res/values/strings.xml:3-4`
`facebook_app_id=000000000000`, `facebook_client_token=000000`. Will cause Facebook SDK initialization failures.

### 12. Incomplete TODOs in production code
- `main.dart:54` - TODO to replace with prod firebase options
- `device_api.dart` - 2 TODOs for storage and carrier info

### 13. Arbitrary 1.5-second delays
**Files:** `signin_state_provider.dart:50`, `signup_state_provider.dart:50`, `recover_provider.dart:36`
Comment says "to prevent spamming". This is a UX-degrading workaround; proper debouncing or button-disable logic would be better.

### 14. Sentry trace sample rate at 20%
**File:** `lib/main.dart:69`
`tracesSampleRate: 0.2` - For a new app this should start at 1.0 (100%) to capture all traces during early development, then reduce later as traffic grows.

---

## LOW PRIORITY (4)

### 15. Force unwrap on entity!.skuId
**File:** `lib/modules/subscription/repositories/subscription_repository.dart:87`
No null check before force unwrap. Will crash if entity is null.

### 16. Force unwrap on _prefs!
**File:** `lib/modules/subscription/repositories/subscription_repository.dart:166`
No null check before force unwrap. Will crash if SharedPreferences was not initialized.

### 17. Artificial 500ms delays in notifications_provider.dart
**File:** `lib/modules/notifications/providers/notifications_provider.dart:20,90`
Unnecessary delays that slow down the notification UI.

### 18. Feedback error uses .first without null check
**File:** `lib/modules/feedback/providers/feedback_page_notifier.dart:85-87`
Uses `.first` on a filtered list without checking if the list is empty. Will throw a `StateError` if no matching vote is found.

---

## TEMPLATE-READINESS ISSUES

### Things that MUST change per-app clone:
1. **Firebase config** - `firebase_options.dart`, `firebase_options_dev.dart`, `google-services.json` (must regenerate per project)
2. **App name** - AndroidManifest.xml, `web/index.html`, `web/manifest.json`, `local_notifier.dart` kAppName, `main.dart` title, `pubspec.yaml`
3. **Bundle ID** - `com.yourcompany.template` in AndroidManifest, `MainActivity.kt`, build configs
4. **Facebook App ID and Client Token** - `strings.xml`
5. **RevenueCat API keys** - environment config
6. **Sentry DSN** - environment config
7. **Mixpanel token** - environment config
8. **Backend URL** - environment config
9. **Terms/Privacy URLs** - `environments.dart`
10. **Firebase region** - `user_api.dart`, `authentication_api.dart`
11. **kit_setup.json** - App name, bundle ID, backend provider

---

## ARCHITECTURE ASSESSMENT

### What's Good
- **Clean 3-layer architecture** (API -> Repository -> UI) consistently followed
- **Riverpod + Freezed** is modern best practice for Flutter state management
- **Module separation** is clean (auth, subscription, notifications, onboarding, settings, feedback)
- **Fake implementations for testing** instead of mocks - makes tests more reliable
- **Route guards** for authentication flow
- **Environment-based configuration** (dev/prod) via Dart defines
- **Previously-identified critical bugs have been fixed** - shows active maintenance

### What's Bad
- **Heavy code generation setup complexity** - requires `build_runner` to be run, no CI step for it
- **Thin test coverage** - only happy paths, no error case or edge case tests
- **Data layer still uses Firestore** - auth and data operations should be migrated to Supabase (Firebase kept for FCM + remote config only)

### Overall Grade: **B-**
Good architecture with most critical bugs from the Firebase sister repo already resolved. The remaining issues are primarily template-readiness concerns, one copy-paste UI bug, and some code quality nits. Usable as a solid foundation once per-app configuration is applied.

---

## RECOMMENDED FIX ORDER

### Phase 1: Critical (do before any app ships)
1. Fix sign-in button text ("Create my account" -> "Sign in")

### Phase 2: High Priority
2. Migrate data operations from Firestore to Supabase (keep Firebase for FCM + remote config)
3. Ensure Firebase credentials are removed from git tracking
4. Ensure generated files are removed from git tracking
5. Remove duplicate import in device_api.dart

### Phase 3: Template System Prep
6. Parameterize all hardcoded app names
7. Replace placeholder Facebook credentials
8. Make Firebase region configurable via environment
9. Fill in terms/privacy URLs or add validation
10. Set Sentry trace rate to 1.0 for new projects
11. Create a configuration script/checklist for per-app setup
12. Resolve remaining TODOs or document as known limitations
13. Add null safety checks for force unwraps
14. Replace artificial delays with proper debounce/disable logic
