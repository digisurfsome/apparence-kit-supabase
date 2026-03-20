# Tech Runway Assessment: apparence-kit-supabase

**Assessment Date:** March 20, 2026
**Project:** apparence-kit-supabase (Flutter Boilerplate)
**Assessed by:** Engineering Review
**Dart SDK:** ^3.11.0

---

## Executive Summary

This project is named "apparence-kit-supabase" but runs entirely on Firebase. **Zero Supabase code or dependencies exist in the codebase.** All 19 Dart files that import Firebase packages must be rewritten. The Firebase dependencies themselves are current and pose no immediate risk, but every day of development on Firebase increases the eventual migration cost. The architecture mitigates this somewhat: abstract interfaces exist for auth, storage, and notifications, enabling implementation swaps without touching UI or business logic.

---

## 1. Current Stack Snapshot

| Component | In-Project Version | Latest Available (Mar 2026) | Status |
|---|---|---|---|
| Dart SDK | ^3.11.0 | 3.11.x | :green_circle: Green |
| firebase_core | ^4.4.0 | 4.x | :green_circle: Green |
| firebase_auth | ^6.1.4 | 6.x | :green_circle: Green |
| cloud_firestore | ^6.1.2 | 6.x | :green_circle: Green |
| cloud_functions | ^6.0.6 | 6.x | :green_circle: Green |
| firebase_storage | ^13.0.6 | 13.x | :green_circle: Green |
| firebase_messaging | ^16.1.1 | 16.x | :green_circle: Green |
| firebase_remote_config | ^6.1.4 | 6.x | :green_circle: Green |
| go_router | ^17.1.0 | 17.x | :green_circle: Green |
| flutter_riverpod | ^3.1.0 | 3.x | :green_circle: Green |
| riverpod_annotation | ^4.0.0 | 4.x | :green_circle: Green |
| riverpod_generator | 4.0.0+1 | 4.x | :green_circle: Green |
| freezed | 3.2.3 | 3.x | :green_circle: Green |
| freezed_annotation | ^3.1.0 | 3.x | :green_circle: Green |
| purchases_flutter (RevenueCat) | ^9.12.0 | 9.x | :green_circle: Green |
| sentry_flutter | ^9.13.0 | 9.x | :green_circle: Green |
| google_sign_in | ^7.2.0 | 7.x | :green_circle: Green |
| dio | ^5.9.1 | 5.x | :green_circle: Green |
| slang (i18n) | ^4.12.1 | 4.x | :green_circle: Green |
| shared_preferences | ^2.5.4 | 2.x | :green_circle: Green |
| flutter_local_notifications | ^20.1.0 | 20.x | :green_circle: Green |
| mixpanel_flutter | ^2.5.0 | 2.x | :green_circle: Green |
| json_serializable | 6.11.2 | 6.x | :green_circle: Green |
| image_picker | ^1.2.1 | 1.x | :green_circle: Green |
| permission_handler | ^12.0.1 | 12.x | :green_circle: Green |
| flutter_secure_storage | ^10.0.0 | 10.x | :green_circle: Green |
| facebook_app_events | ^0.24.0 | 0.x | :yellow_circle: Yellow |
| supabase_flutter | **Not installed** | 2.x | :red_circle: Red -- Migration target, not yet added |

**Legend:** :green_circle: Green = current or within one patch. :yellow_circle: Yellow = minor concern or pre-1.0. :red_circle: Red = action required.

---

## 2. Runway Summary

### 0--3 Months (March -- June 2026): Stable but misaligned

- All Firebase dependencies are current. No breakage risk from dependency rot.
- Riverpod 3 + code generation stack (riverpod_generator, freezed) is up to date.
- **No blockers for continued development** on the Firebase stack, but no progress toward the stated Supabase migration goal.
- `facebook_app_events` is pre-1.0 (0.24.0). Low risk but worth monitoring.
- **Strategic concern:** Every Firebase feature built now becomes migration debt later. The codebase name implies Supabase intent that the code does not reflect.

### 3--6 Months (June -- September 2026): Migration window opens

- Firebase packages may release new major versions following Google's annual cadence. Caret constraints absorb minor/patch updates automatically.
- **Supabase migration should begin in this window** if the project intends to ship on Supabase. The `supabase_flutter` 2.x line is stable and mature.
- `go_router` may see a new major version. Current v17 API is stable; migration effort is typically moderate.
- CocoaPods-to-SPM transition matters for iOS builds. Firebase and Supabase Flutter plugins should both support SPM by this point.

### 6--12 Months (September 2026 -- March 2027): Increasing inertia risk

- **Dart 4.0 / Flutter 4.0 cycle** may land, potentially introducing breaking language changes (macros stabilization, null-safety evolution). This cascades to most dependencies.
- **Riverpod ecosystem** may see a major version if macros become stable, changing code generation patterns significantly.
- **Firebase dependency inertia:** if migration has not started, the project accumulates more Firebase-coupled feature code, compounding technical debt.

### 12+ Months (March 2027+): Structural debt

- Unmigrated Firebase code becomes entrenched structural debt. The project name creates confusion for contributors and users who expect Supabase.
- Dependency rot risk increases across the board if the project is not actively maintained, especially for fast-moving packages (Riverpod, go_router, Firebase SDKs).
- If `supabase_flutter` advances to 3.x, migration guides may not cover jumping from zero to 3.x as cleanly.

---

## 3. Critical Dependencies to Watch

| Dependency | Why It Matters | Watch For |
|---|---|---|
| **flutter_riverpod / riverpod_generator** | Core state management. Macro-based future could force a rewrite of all providers. | Riverpod 4.0 announcements, Dart macros stabilization |
| **go_router** | Core navigation. Tightly integrated with guards and route definitions. | Major version bumps (historically 1--2 per year) |
| **freezed / freezed_annotation** | Pervasive in model layer (user, subscription, notification, onboarding models). Macro-based replacement is planned upstream. | freezed 4.0 or a macros-based successor |
| **firebase_messaging** | Push notification backbone. No direct Supabase equivalent exists. Must decide whether to retain or replace. | Decision on FCM retention vs. alternative (OneSignal, etc.) |
| **purchases_flutter (RevenueCat)** | Subscription/paywall logic. Backend-agnostic but auth token integration matters. | Compatibility with Supabase auth tokens |
| **Dart SDK** | ^3.11.0 is current but Dart 4.0 is on the horizon. | Breaking changes in upcoming Dart releases |
| **supabase_flutter** | Migration target. Must be added to pubspec.yaml. | Stable 2.x release line; watch for 3.0 announcement |

---

## 4. Supabase Migration Considerations

### 4.1 Current State

The codebase has **19 Dart files** that directly import Firebase packages:

- **Authentication:** `authentication_api.dart`, `authentication_repository.dart`, `phone_auth_notifier.dart`
- **Database:** `user_api.dart`, `notifications_api.dart`, `feature_request_api.dart`, `feature_vote_api.dart`, `user_feature_request_api.dart`, `user_infos_api.dart`, `subscription_api.dart`, `device_api.dart`
- **Storage:** `storage_api.dart`
- **Messaging:** `notifications_api.dart`, `notifications_repository.dart`, `background_notification_handler.dart`
- **Remote Config:** `remote_config_api.dart`
- **Initialization:** `main.dart`, `firebase_options.dart`, `firebase_options_dev.dart`, `user_state_notifier.dart`

### 4.2 Target Package

**`supabase_flutter` (latest: ~2.x)** -- single package that replaces `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, and partially `cloud_functions`.

### 4.3 Authentication Migration (`firebase_auth` -> `supabase_auth`)

| Firebase Feature In Use | Supabase Equivalent | Effort |
|---|---|---|
| Email/password sign-in & sign-up | `supabase.auth.signInWithPassword()` / `signUp()` | Low |
| Anonymous sign-in | Supabase anonymous auth (supported in supabase_flutter 2.x) | Low |
| Google OAuth (native + web) | `supabase.auth.signInWithOAuth(OAuthProvider.google)` or pass native ID token via `signInWithIdToken()` | Medium |
| Apple sign-in | `supabase.auth.signInWithOAuth(OAuthProvider.apple)` | Medium |
| Phone/OTP auth | `supabase.auth.signInWithOtp(phone: ...)` | Medium |
| Password reset | `supabase.auth.resetPasswordForEmail()` | Low |
| Auth state changes stream | `supabase.auth.onAuthStateChange` | Low |
| Anonymous-to-permanent account linking | **No direct equivalent.** Requires custom implementation via Supabase Edge Function or manual user merging. | **High** |
| `google_sign_in` package | Retained for native Google sign-in flow; pass ID token to Supabase | Low |

**Key risk:** The `signupFromAnonymousWithGoogle()` and `signupFromAnonymousWithApple()` methods use Firebase's first-class `linkWithCredential()` / `linkWithProvider()` APIs. Supabase does not have an equivalent account-linking mechanism. This is the highest-effort auth migration item and may require an Edge Function that merges anonymous user data into the permanent account.

**Files affected:**
- `lib/modules/authentication/api/authentication_api.dart` (full rewrite of `FirebaseAuthenticationApi`)
- `lib/modules/authentication/api/authentication_api_interface.dart` (interface may need minor adjustments)
- `lib/modules/authentication/providers/phone_auth_notifier.dart`

### 4.4 Database Migration (`cloud_firestore` -> PostgREST / Supabase Client)

| Firebase Pattern In Use | Supabase Equivalent | Notes |
|---|---|---|
| `collection().doc().get()` | `supabase.from('table').select().eq('id', id).single()` | Requires upfront schema design -- Firestore is schemaless, Postgres is not |
| `.withConverter()` typed reads | Manual JSON deserialization (works with existing freezed `fromJson`/`toJson`) | Low effort |
| `.update()` / `.set()` | `.upsert()` / `.update().eq()` | API is similar |
| `.where().snapshots()` (realtime) | Supabase Realtime channels: `supabase.from('table').stream(primaryKey: ['id'])` | Different API shape but functionally equivalent |
| Sub-collections (e.g., `users/{id}/notifications`) | Separate tables with foreign keys (e.g., `notifications` table with `user_id` column) | **Requires schema redesign** |
| `cloud_functions` callable functions (e.g., `deleteUserAccount`) | Supabase Edge Functions (Deno/TypeScript) | Complete rewrite of server-side logic |
| Firestore converters with `snapshot.id` | Postgres row with `id` column included in the result | Minor mapping change |

**Key risk:** Firestore sub-collections are used for notifications (`users/{userId}/notifications`), feedbacks, and feature requests. These must be flattened into relational tables with proper foreign keys. This is a schema design exercise, not just a code swap.

**Files affected:**
- `lib/core/data/api/user_api.dart` (full rewrite)
- `lib/modules/notifications/api/notifications_api.dart` (full rewrite)
- `lib/modules/feedbacks/api/feature_request_api.dart`
- `lib/modules/feedbacks/api/feature_vote_api.dart`
- `lib/modules/feedbacks/api/user_feature_request_api.dart`
- `lib/modules/onboarding/api/user_infos_api.dart`
- `lib/modules/subscription/api/subscription_api.dart`

### 4.5 Storage Migration (`firebase_storage` -> Supabase Storage)

| Firebase Pattern | Supabase Equivalent |
|---|---|
| `ref.putData()` with upload progress | `supabase.storage.from('bucket').uploadBinary()` with `onUploadProgress` callback |
| `ref.getDownloadURL()` | `supabase.storage.from('bucket').getPublicUrl()` or `.createSignedUrl()` |
| `ref.delete()` | `supabase.storage.from('bucket').remove([path])` |
| `ref.writeToFile()` | `supabase.storage.from('bucket').download()` + manual file write |

**Migration effort: Medium.** The existing `StorageApi` abstract class provides a clean interface. Only the `FirebaseStorageApi` implementation needs replacement. Upload progress tracking has a slightly different API shape in Supabase.

**Files affected:** `lib/core/data/api/storage_api.dart`

### 4.6 Push Notifications (`firebase_messaging` -> ???)

**This is the most problematic migration area.** Supabase does not provide a push notification service. Options:

1. **Keep FCM for push only** -- retain `firebase_messaging` and `firebase_core` solely for push. Pragmatic but retains Firebase dependency.
2. **Switch to OneSignal or Pusher** -- third-party push services independent of Firebase.
3. **Use Supabase Edge Functions + FCM/APNs directly** -- server-side calls to FCM/APNs APIs, but client-side still needs a push SDK.
4. **Use `flutter_local_notifications` (already in project) for local-only** -- not a replacement for server-triggered push.

**Recommendation:** Retain `firebase_messaging` for push notifications in the short term. Push notification infrastructure is orthogonal to the backend migration. Many production Supabase apps use FCM for push.

**Files affected:**
- `lib/modules/notifications/api/notifications_api.dart`
- `lib/modules/notifications/api/device_api.dart`
- `lib/modules/notifications/repositories/notifications_repository.dart`
- `lib/modules/notifications/repositories/background_notification_handler.dart`

### 4.7 Remote Config (`firebase_remote_config` -> alternatives)

Supabase has no direct Remote Config equivalent. Options:

1. **Use a Supabase Postgres table** as a key-value config store queried at app start. Simple, no extra dependencies.
2. **Use a third-party service** (LaunchDarkly, ConfigCat, Unleash).
3. **Keep Firebase Remote Config** -- lightweight, minimal coupling.

The existing `RemoteConfigApi` class is well-abstracted behind interfaces (`RemoteConfigData<T>`, `RemoteConfigWrapper`). Swapping the implementation is straightforward regardless of the chosen alternative.

**Files affected:** `lib/core/data/api/remote_config_api.dart`

### 4.8 Migration Effort Summary

| Area | Estimated Effort | Risk Level |
|---|---|---|
| Auth (basic email/password/OAuth) | 1--2 weeks | Low |
| Auth (anonymous linking, phone) | 1 week | High |
| Database (Postgres schema design + API rewrite) | 2--3 weeks | Medium |
| Storage | 3--5 days | Low |
| Cloud Functions -> Edge Functions | 1--2 weeks | Medium |
| Push notifications | 1 week (keep FCM) / 3 weeks (replace) | High |
| Remote config | 2--3 days | Low |
| `main.dart` initialization rewrite | 1--2 days | Low |
| Testing and integration | 1--2 weeks | Medium |
| **Total estimated effort** | **8--12 weeks** (1 developer) | -- |

---

## 5. Tipping Points

| Trigger | Impact | When to Act |
|---|---|---|
| **First production deployment on Firebase** | Creates user data in Firestore that must be data-migrated, not just code-migrated | **Before launch** -- migrate code before any production data exists |
| **Firebase SDK major version bump (v5 core, v7 auth, etc.)** | Forces upgrade work on code destined for deletion during Supabase migration -- wasted effort | Pause Firebase upgrades once migration begins |
| **`supabase_flutter` 3.0 release** | Could change client API surface; better to migrate on a stable major version | Start migration while 2.x is current and well-documented |
| **Dart 4.0 / Flutter 4.0 release** | May break freezed, riverpod_generator, and build_runner simultaneously | Upgrade Dart/Flutter first, then continue Supabase migration |
| **Riverpod macros migration** | Will require rewriting all providers regardless of backend | Coordinate with Supabase migration to avoid double-rewrite |
| **Team scaling beyond 2 developers** | Firebase/Supabase naming ambiguity creates onboarding confusion and architectural debt | Resolve backend alignment before scaling the team |
| **CocoaPods goes read-only (Dec 2, 2026)** | iOS dependency management must be on SPM | Migrate iOS project to SPM before this deadline |
| **Apple requires Xcode 26 (April 28, 2026)** | Cannot submit to App Store without it | Update development environment before deadline |

---

## 6. Recommendation

### Immediate Actions (Now -- April 2026)

1. **Add `supabase_flutter: ^2.0.0` to pubspec.yaml.** Begin with it alongside Firebase; do not remove Firebase yet.
2. **Design the Postgres schema.** Map Firestore collections to relational tables: `users`, `notifications`, `feature_requests`, `feature_votes`, `subscriptions`. Design foreign keys for what are currently sub-collections.
3. **Set up a Supabase project** with auth providers (email, Google, Apple, phone) configured.
4. **Do not build new features on Firebase.** Any new API layer code should target Supabase from the start.

### Phase 1: Auth Migration (April -- May 2026, ~2 weeks)

- Create `SupabaseAuthenticationApi` implementing the existing `AuthenticationApi` interface.
- Swap the `authenticationApiProvider` to use the Supabase implementation.
- Defer anonymous-to-permanent account linking to Phase 4 (requires Edge Function).
- Retain `google_sign_in` package; pass native ID token to Supabase.

### Phase 2: Database Migration (May -- June 2026, ~3 weeks)

- Rewrite `UserApi` against Supabase PostgREST.
- Rewrite `NotificationsApi` (notification storage/queries only; push remains FCM).
- Rewrite feedback and feature request APIs.
- Leverage existing freezed models -- `fromJson`/`toJson` works with Supabase's JSON responses.

### Phase 3: Storage Migration (June 2026, ~1 week)

- Create `SupabaseStorageApi` implementing the existing `StorageApi` interface.
- Create Supabase storage buckets with appropriate RLS policies.

### Phase 4: Edge Functions & Cleanup (July -- August 2026, ~2 weeks)

- Rewrite `deleteUserAccount` Cloud Function as a Supabase Edge Function.
- Implement anonymous-to-permanent account linking via Edge Function.
- Replace `RemoteConfigApi` with a Supabase table-backed implementation or retain Firebase Remote Config.

### Phase 5: Firebase Removal (August 2026, ~1 week)

- Remove all Firebase dependencies from `pubspec.yaml` except `firebase_messaging` (if retaining for push).
- Delete `firebase_options.dart` and `firebase_options_dev.dart`.
- Remove Firebase initialization from `main.dart`; replace with `Supabase.initialize()`.
- Remove Firebase project configuration files (GoogleService-Info.plist, google-services.json) if FCM is not retained.

### Target Completion: Q3 2026

**Total timeline: 8--12 weeks of engineering effort.** The single biggest risk is delay. Every feature built on Firebase before migration increases the migration cost. If the project has not yet launched to production, now is the optimal time -- before user data exists in Firestore that would require a data migration on top of the code migration.

### Architectural Advantage

The project's use of abstract interfaces (`AuthenticationApi`, `StorageApi`, `NotificationsApi`) and provider-based dependency injection via Riverpod is a significant advantage. Most Firebase implementations can be swapped at the API layer without touching UI components, state management, or business logic. The migration is primarily an API-layer concern, not a full-stack rewrite.
