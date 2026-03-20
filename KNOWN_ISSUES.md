# Known Issues

**Project:** apparence-kit-supabase (Flutter boilerplate)
**Audit date:** March 20, 2026

---

## ARCHITECTURE NOTE

### Hybrid Backend: Supabase + Firebase

This boilerplate uses a **dual-backend architecture by design**:

- **Supabase** = main database, authentication, and storage
- **Firebase** = push notifications (FCM) and remote config only

This is because Supabase does not provide push notification or remote config services. Firebase is required for iOS push notifications via Flutter.

The Supabase database schema is defined in `supabase/migrations/`. Firebase dependencies (`firebase_core`, `firebase_messaging`, `firebase_remote_config`) must remain in the project for notifications and remote config to function.

The data layer (auth, Firestore, storage) still uses Firebase APIs in some modules and needs to be migrated to Supabase equivalents. The `supabase_api.mdc` rule in `.claude/rules/` shows the target pattern for Supabase API classes.

---

## CRITICAL

(No critical issues remain — the sign-in button text bug has been fixed.)

---

## HIGH

### 2. Firebase Credentials Not Included (By Design)

**Severity:** High
**Status:** Expected -- requires per-project setup

The following files are listed in `.gitignore` and must be generated before the app can run:

- `lib/firebase_options.dart`
- `lib/firebase_options_dev.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

**Fix:** Create a Firebase project, then run:

```
flutterfire configure
```

Dev and production environments should point to separate Firebase projects.

### 3. Code Generation Required Before Building

**Severity:** High
**Status:** Expected -- by design

All `.g.dart` and `.freezed.dart` files are excluded from version control via `.gitignore`. The project will not compile until code generation is run.

**Fix:**

```
dart run build_runner build --delete-conflicting-outputs
```

Requires Dart SDK ^3.11.0.

### 4. Force Unwraps Without Null Checks

**Severity:** High
**Status:** Bug -- potential runtime crashes

Two force-unwrap (`!`) operations in `lib/modules/subscription/repositories/subscription_repository.dart` can throw `Null check operator used on a null value` at runtime:

| Line | Expression |
|------|------------|
| 87   | `entity!.skuId` |
| 166  | `_prefs!.setInt(...)` |

**Impact:** If `entity` or `_prefs` is null when these lines execute, the app will crash with an unhandled exception.

**Fix:** Add null guards or early-return checks before these accesses.

---

## MEDIUM

### 5. Template Placeholder Values Must Be Replaced

**Severity:** Medium
**Status:** Expected -- requires customization before shipping

The following placeholder values are present and must be changed per-project:

| File | Placeholder | Value |
|------|-------------|-------|
| `android/app/src/main/AndroidManifest.xml` | App label | `flutter_base` |
| `android/app/build.gradle.kts` | Package / Application ID | `com.yourcompany.template` |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Package declaration | `com.yourcompany.template` |
| `android/app/src/main/res/values/strings.xml` | Facebook App ID | `000000000000` |
| `lib/environments.dart` | Terms URL | `''` (empty string) |
| `lib/environments.dart` | Privacy URL | `''` (empty string) |
| `lib/core/data/api/user_api.dart` | Firebase region | `us-central1` |
| `lib/modules/authentication/api/authentication_api.dart` | Firebase region | `us-central1` |

**Impact:** Shipping without replacing these will result in broken deep links, incorrect app naming, a non-functional Facebook login, and empty legal pages.

### 6. Artificial Delays in Auth and Notification Flows

**Severity:** Medium
**Status:** Intentional -- anti-spam UX pattern

Hardcoded `Future.delayed` calls are present throughout the authentication and notification modules:

- **1500ms** delays in sign-in, sign-up, and password recovery (`signin_state_provider.dart`, `signup_state_provider.dart`, `recover_provider.dart`)
- **2000ms** delay in phone auth (`phone_auth_notifier.dart`)
- **500ms** delay in authentication API (`authentication_api.dart`)

**Impact:** These add latency to every auth operation regardless of network speed. They are intended to prevent rapid repeated submissions but may frustrate users on fast connections.

**Fix:** Consider replacing fixed delays with debounce logic or server-side rate limiting.

### 7. Unfinished TODOs in Production Code

**Severity:** Medium
**Status:** Incomplete implementation

| File | Line | TODO |
|------|------|------|
| `lib/main.dart` | 54 | Replace with your own Firebase options for production |
| `lib/modules/notifications/api/device_api.dart` | 361 | Storage info for Android |
| `lib/modules/notifications/api/device_api.dart` | 369 | Carrier and storage info |
| `lib/core/rating/providers/rating_repository.dart` | 27-28 | Get delay values from env |
| `lib/core/rating/widgets/rate_banner.dart` | 55 | Create factory to get value from env |

---

## LOW

### 8. Thin Test Coverage

**Severity:** Low
**Status:** Known gap

The `test/` directory contains 34 test files covering happy-path scenarios only. There are:

- No error-case tests (network failures, invalid input, null states)
- No edge-case tests (boundary values, concurrent operations)
- No integration tests

**Impact:** Regressions and error-handling bugs are unlikely to be caught before production.
