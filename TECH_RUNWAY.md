# Tech Runway Assessment - ApparenceKit Firebase Template

**Assessment Date:** February 20, 2026
**Template:** ApparenceKit (Flutter/Firebase starter template)
**Purpose:** Evaluate how long this codebase remains viable before requiring significant updates

---

## For Non-Technical Readers

This document answers a simple question: **"How long can I build on this template before the technology underneath it becomes a problem?"** Think of it like a car inspection -- everything might run fine today, but some parts will need attention before others. The good news is that right now, this template is almost entirely current. The items below tell you what to watch and when, so you are never surprised by a forced upgrade.

---

## Current Stack Snapshot

| Component | In Project | Latest Available | Status |
|---|---|---|---|
| **Dart SDK** | ^3.11.0 | 3.11 (Feb 9 2026) | :green_circle: Green |
| **Flutter** | >=3.38.4 (lock) | 3.41 (Feb 2026) | :yellow_circle: Yellow |
| **firebase_core** | 4.4.0 | 4.4.0 | :green_circle: Green |
| **firebase_auth** | 6.1.4 | 6.1.4 | :green_circle: Green |
| **cloud_firestore** | 6.1.2 | 6.1.2 | :green_circle: Green |
| **cloud_functions** | 6.0.6 | 6.0.6 | :green_circle: Green |
| **firebase_storage** | 13.0.6 | 13.0.6 | :green_circle: Green |
| **firebase_messaging** | 16.1.1 | 16.1.1 | :green_circle: Green |
| **firebase_remote_config** | 6.1.4 | 6.1.4 | :green_circle: Green |
| **go_router** | 17.1.0 | 17.1.0 | :green_circle: Green |
| **flutter_riverpod** | 3.1.0 | 3.2.1 | :yellow_circle: Yellow |
| **riverpod_annotation** | 4.0.0 | 4.0.2 | :yellow_circle: Yellow |
| **riverpod_generator** | 4.0.0+1 | 4.0.3 | :yellow_circle: Yellow |
| **freezed** | 3.2.3 | 3.2.5 | :green_circle: Green |
| **freezed_annotation** | 3.1.0 | 3.1.0 | :green_circle: Green |
| **purchases_flutter** (RevenueCat) | 9.12.0 | 9.12.1 | :green_circle: Green |
| **sentry_flutter** | 9.13.0 | 9.14.0 | :green_circle: Green |
| **google_sign_in** | 7.2.0 | 7.2.0 | :green_circle: Green |
| **slang** (i18n) | 4.12.1 | 4.12.1 | :green_circle: Green |
| **dio** | 5.9.1 | 5.9.1 | :green_circle: Green |
| **flutter_animate** | 4.5.2 | 4.5.2 | :green_circle: Green |
| **shared_preferences** | 2.5.4 | 2.5.4 | :green_circle: Green |

**Legend:** :green_circle: Green = current or within one patch release. :yellow_circle: Yellow = minor version behind, easy to update. :red_circle: Red = major version behind or security concern.

**Bottom line:** As of February 20, 2026, this template is overwhelmingly up-to-date. Every Firebase package is at its latest version. The only packages slightly behind are Riverpod (minor patch versions) and the Flutter SDK lock file pinned to 3.38.4 while 3.41 is now available.

---

## Runway Summary

### 0-3 Months (Now through May 2026) -- Smooth sailing

- **Everything works.** All dependencies are at or very near their latest versions.
- **Immediate to-do:** Run `flutter pub upgrade` to pick up the Riverpod patch releases (3.1.0 to 3.2.1, riverpod_annotation 4.0.0 to 4.0.2, riverpod_generator 4.0.0+1 to 4.0.3). This is a 5-minute task with no code changes expected.
- **Immediate to-do:** Upgrade Flutter SDK to 3.41 (`flutter upgrade`). The lockfile currently pins to 3.38.4. This is straightforward since your pubspec already allows `^3.11.0` for Dart.
- **Watch for:** Apple's April 28, 2026 deadline -- all App Store submissions must be built with iOS 26 SDK (Xcode 26). This does NOT mean your app must require iOS 26 to run, just that you must compile with the new tools. Make sure your Mac development machine can run Xcode 26 before April.

### 3-6 Months (May through August 2026) -- Minor maintenance needed

- **CocoaPods transition begins to matter.** Google will stop releasing new Firebase iOS SDK versions via CocoaPods after Q2 2026. Flutter is migrating to Swift Package Manager (SPM). You will need to ensure your iOS build uses SPM. The template may need its iOS project structure updated.
- **Google Play API level bump.** Expect Google to require targetSdkVersion 36 (Android 16) for new app submissions by late August 2026, following their annual pattern. The template's Android configuration will need its `targetSdkVersion` bumped.
- **Android Gradle Plugin (AGP) 9 compatibility.** Flutter 3.41 is working toward AGP 9 support but it is not fully ready. Some Firebase plugins (analytics, performance) have known conflicts with AGP 9. By mid-2026 this should be resolved, but you will need to update your Gradle files when it is.
- **Riverpod may release 4.x.** The Riverpod ecosystem moves fast. Minor version upgrades are usually painless; a major version would require code changes.

### 6-12 Months (August 2026 through February 2027) -- Plan a refresh

- **CocoaPods goes read-only on December 2, 2026.** After this date, no new pod versions can be published. Any Flutter plugin that has not migrated to SPM will be frozen at its last CocoaPods version. This is a hard deadline for the iOS ecosystem.
- **Firebase may release a new major version** of the Flutter SDK. They have been on the 4.x series for firebase_core since mid-2025. A jump to 5.x would require migration work, though Firebase provides migration guides.
- **Flutter 4.0 speculation.** The Flutter team has hinted that Flutter 4.0 could arrive once core goals (design library decoupling, Impeller completion) are met. A major Flutter version bump historically brings significant breaking changes (like null safety did). There is no confirmed date, but late 2026 or 2027 is plausible.
- **flutter_animate has not been updated in 15 months** (last release: November 2024). If it is not updated for Flutter 4.0 or later SDK changes, you may need to replace it with native Flutter animation APIs or a maintained alternative.

### 12+ Months (After February 2027) -- Significant refresh required

- **Dart 4.0 / Flutter 4.0.** If these ship, the template will need a comprehensive update. Historically, major Flutter versions break 10-30% of code in an average project.
- **Firebase SDK lifecycle.** Firebase deprecates APIs within one major version and removes them in the next. If firebase_core jumps two major versions (currently 4.x, to theoretical 6.x), migration effort climbs significantly.
- **RevenueCat SDK.** They iterate rapidly (currently 9.x). A jump to 10.x could change subscription handling APIs. For a subscription-based sugar app, this is critical infrastructure.
- **Unmaintained packages become liabilities.** Packages like `flutter_animate`, `another_flushbar`, `better_skeleton`, and `bart` are smaller community packages. If they stop receiving updates, you'll need to find replacements or fork them.

---

## Critical Dependencies to Watch

### 1. Firebase Suite (firebase_core, firebase_auth, cloud_firestore, firebase_messaging)

**What it is:** Firebase is the entire backend of your app -- user accounts, database, push notifications, file storage, and remote configuration. It is like the engine of your car.

**Why it matters:** If Firebase packages break or become outdated, your app cannot talk to its backend. Nothing works without Firebase.

**What triggers an upgrade:** A new major Firebase iOS or Android native SDK release. Google releases these roughly annually. The Flutter wrappers follow within weeks.

**Difficulty of upgrade:** Medium. Firebase provides migration guides, but major version bumps (e.g., 4.x to 5.x of firebase_core) typically require touching every file that imports Firebase.

### 2. Flutter SDK + Dart SDK

**What it is:** Flutter is the framework that makes the entire app run on both iPhone and Android from one codebase. Dart is the programming language.

**Why it matters:** Everything depends on Flutter. When Flutter releases a major version, every package in the project must be compatible with it.

**What triggers an upgrade:** Apple/Google requiring newer build tools (Xcode 26 deadline in April 2026, Android API level bumps in August). You cannot submit to the App Store or Play Store without meeting their requirements.

**Difficulty of upgrade:** Easy for minor versions (3.38 to 3.41). Hard for major versions (3.x to 4.0) -- expect 1-3 days of developer work.

### 3. CocoaPods to Swift Package Manager Migration

**What it is:** CocoaPods is the tool that currently manages iOS-side code libraries. It is being shut down and replaced by Swift Package Manager (SPM).

**Why it matters:** After December 2, 2026, CocoaPods will stop accepting new package updates. If any of your iOS dependencies have not migrated to SPM by then, those dependencies are frozen in time.

**What triggers an upgrade:** The December 2026 read-only deadline and Google stopping CocoaPods releases after Q2 2026.

**Difficulty of upgrade:** Medium. Flutter is handling much of this automatically, but some plugins may need manual intervention or replacement.

### 4. RevenueCat (purchases_flutter)

**What it is:** RevenueCat handles in-app subscriptions and purchases. If you plan to charge money for premium features in your sugar app, this is your payment system.

**Why it matters:** Subscription handling must comply with Apple and Google payment policies, which change regularly. RevenueCat abstracts this complexity, but you need to stay current with their SDK to maintain compliance.

**What triggers an upgrade:** Apple/Google payment policy changes, or RevenueCat releasing a new major version with required backend changes.

**Difficulty of upgrade:** Medium. The jump from 8.x to 9.x required configuration changes. A future 10.x would likely be similar.

### 5. Riverpod (flutter_riverpod, riverpod_annotation, riverpod_generator)

**What it is:** Riverpod is the "state management" system -- it is how the app keeps track of data (like a user's food log or blood sugar reading) and shares it between different screens.

**Why it matters:** Riverpod code is woven throughout the entire app. A breaking change here touches almost every feature.

**What triggers an upgrade:** Riverpod releases a new major version. The author (Remi Rousselet) is active and pushes significant API changes between major versions.

**Difficulty of upgrade:** Hard. Riverpod 2.x to 3.x was a substantial migration. A future 4.x could be similar. Code generation (riverpod_generator) makes it somewhat easier but also adds complexity.

---

## Tipping Points

These are specific, concrete events that would force you to invest developer time in upgrading the template:

| Event | Expected When | Impact | What You Must Do |
|---|---|---|---|
| **Apple requires iOS 26 SDK (Xcode 26)** | April 28, 2026 | Cannot submit app updates to App Store | Upgrade Mac to Xcode 26, test build, fix any compiler warnings |
| **Google requires targetSdkVersion 36** | ~August 2026 | Cannot submit app updates to Play Store | Update `android/app/build.gradle` targetSdkVersion to 36 |
| **Google stops publishing Firebase iOS SDKs via CocoaPods** | Q2 2026 | Firebase upgrades stall on iOS if you are still on CocoaPods | Migrate iOS project to Swift Package Manager |
| **CocoaPods goes read-only** | December 2, 2026 | No more iOS dependency updates via CocoaPods at all | Must be on Swift Package Manager before this date |
| **Android Gradle Plugin 9 becomes required** | Mid-late 2026 | App will not build without AGP 9 support | Update Gradle files; wait for Firebase plugin fixes |
| **Riverpod 4.x releases** | Unknown (could be 2026) | Code using Riverpod annotations may break | Refactor provider definitions project-wide |
| **Flutter 4.0 releases** | Late 2026 or 2027 (speculative) | Potentially broad breaking changes | Full template refresh; budget 2-5 days of developer time |
| **Firebase major version bump (5.x)** | Unknown | Migration required across all Firebase imports | Follow FlutterFire migration guide; budget 1-2 days |
| **RevenueCat 10.x releases** | Unknown | Subscription code may need rewriting | Follow RevenueCat migration guide; budget 0.5-1 day |

---

## What "Out of Date" Actually Means

When people say a project is "out of date," it sounds scary. Here is what it actually means at different levels:

**Level 1 -- A few patch versions behind (Where you are now)**
Your app works perfectly. You are just missing small bug fixes. No action required immediately. This is normal.

**Level 2 -- One minor version behind (e.g., Riverpod 3.1 vs 3.2)**
Your app still works perfectly. You might miss out on performance improvements or new conveniences. Upgrading is easy and low-risk. You should do it during regular maintenance.

**Level 3 -- One major version behind (e.g., if firebase_core goes to 5.x and you are on 4.x)**
Your app still works. The old version still functions. But you can no longer get security patches or new features for the old version. You should plan an upgrade within 3-6 months.

**Level 4 -- Two or more major versions behind**
Your app still works for existing users, but you may not be able to submit updates to the app stores because the build tools no longer support your old dependencies. This is where "out of date" becomes an actual business problem. Developer time to catch up multiplies.

**Level 5 -- Build tools reject your project**
Apple or Google will not accept your app submission. Your build fails entirely. This happens when you miss a hard deadline like the Xcode 26 requirement or Android API level requirement. You cannot ship updates until you fix it.

**Security is rarely the immediate risk with Flutter apps** -- unlike web servers that are directly exposed to the internet, mobile apps run on the user's phone. The bigger risk is operational: you cannot ship bug fixes or new features because the app will not build or will not be accepted by the stores.

---

## Recommendation

### Concrete Timeline

1. **Now (February 2026):** Run `flutter pub upgrade` and `flutter upgrade` to pick up the latest patches. Test that the app builds cleanly. This takes 30 minutes. No code changes expected.

2. **Before April 28, 2026:** Ensure your development Mac runs Xcode 26. Build and test the app with it. Fix any deprecation warnings. Budget half a day.

3. **Before June 2026:** Migrate the iOS project from CocoaPods to Swift Package Manager. Flutter has guidance for this. Budget 1 day of developer time plus testing. Do not wait until December -- Google stops publishing Firebase pods via CocoaPods after Q2 2026.

4. **Before September 2026:** Update `targetSdkVersion` in `android/app/build.gradle` to meet the expected Android 16 (API 36) requirement from Google Play. Test the app on an Android 16 device or emulator. Budget half a day.

5. **November/December 2026:** Do a full dependency audit. Run `flutter pub outdated`. Update everything that has a new version. This is your "annual maintenance" cycle. Budget 1-2 days.

6. **If Flutter 4.0 is announced:** Start planning a template refresh. Do not rush to adopt on day one. Wait 2-4 weeks for the ecosystem to stabilize, then budget 2-5 days for the migration.

### Next Template Refresh Cycle

**Plan for a comprehensive refresh in Q4 2026 (October-December 2026).** This aligns with:
- The CocoaPods read-only deadline (December 2, 2026)
- The likely annual Firebase major release
- Post-summer Google Play API level requirements
- Having a stable, tested app going into the holiday season

**Total estimated developer cost for the year:** 3-5 days of maintenance spread across 2026, plus 2-5 days if Flutter 4.0 ships.

---

## For Your Sugar App Specifically

Your app (a sugar/glycemic index tracker for keto dieters and diabetics) will use these template features heavily:

### What Matters Most to You

1. **Firebase Auth + Google Sign-In (critical).** Users need to log in. These are at the latest version and will remain stable. Auth rarely has breaking changes. You are in great shape here.

2. **Cloud Firestore (critical).** This is where you will store food entries, blood sugar readings, glycemic index data, and user profiles. At the latest version. Firestore is one of Google's flagship products and receives long-term support.

3. **Firebase Messaging (important).** Push notifications -- reminding users to log meals, alerting on blood sugar trends, etc. At the latest version.

4. **RevenueCat / purchases_flutter (important if you monetize via subscription).** If you plan a freemium model (free basic tracking, paid premium features like meal suggestions, trends, etc.), this is your billing system. At the latest version. Keep it updated as Apple/Google change payment rules.

5. **Riverpod (important but invisible to users).** This manages how data flows through your app. It is like the plumbing -- users never see it, but if it breaks, nothing works. Slightly behind on patches. Update now.

6. **Sentry (nice to have).** Crash reporting. When a user's app crashes, you find out why. Important for quality but not a launch blocker.

### What You Probably Will Not Need

- **firebase_storage**: Unless you allow users to upload photos of meals. If you do, it is already there and current.
- **firebase_remote_config**: Useful for toggling features without app updates (e.g., turning on a "holiday recipes" section). Nice to have, not critical for launch.
- **cloud_functions**: Server-side processing. Useful later for things like "calculate my weekly average glycemic load" or sending weekly summary emails.
- **flutter_animate**: Pretty animations. Nice for onboarding screens and loading states but not core to your app's function.

### Your Specific Risk Profile

Your app is a **health/wellness data tracker with potential subscriptions**. Here is what that means for tech decisions:

- **Data integrity is paramount.** People are tracking health data. Firestore and Firebase Auth must be reliable. They are. Google stakes its reputation on Firebase.
- **Subscription billing must work perfectly.** A broken payment flow means lost revenue and angry users. Keep RevenueCat current. Test subscription flows on every OS update.
- **App Store compliance is non-negotiable.** Health apps sometimes face extra scrutiny. You must stay current with build tools (Xcode, Android SDK) to be able to ship fixes quickly.
- **Offline capability may matter.** Diabetics may need to log readings when they do not have signal. Firestore has built-in offline support. No extra work needed.
- **Accessibility matters for your audience.** Diabetics include elderly users. Flutter has good accessibility support built in. No additional dependencies needed.

### Bottom Line for Your Sugar App

**This template gives you a solid 6-9 month runway with zero code changes needed.** After that, you will need a maintenance cycle (the Q4 2026 refresh described above). The template covers everything your sugar app needs out of the box: authentication, database, push notifications, subscriptions, crash reporting, and analytics.

**Start building your app now.** Do not wait for a "perfect" time -- the template is as current as it can possibly be. Handle the maintenance items (Xcode 26, SPM migration, Play Store API level) as they come up on the timeline above. None of them require stopping development; they are small tasks you slot in alongside feature work.
