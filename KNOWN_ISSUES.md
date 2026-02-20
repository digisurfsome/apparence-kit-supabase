# Known Issues and Code Review

Analysis of the ApparenceKit boilerplate project based on setup sessions (February 2025).

---

## Critical Blockers

### 1. Dart SDK Version Mismatch
- **Status:** BLOCKING all builds and code generation
- **Issue:** Installed Dart SDK is 3.8.1, project requires ^3.11.0
- **Impact:** `build_runner`, `flutter run`, and all compilation is completely blocked
- **Fix:** `flutter channel stable && flutter upgrade` then verify `dart --version` >= 3.11.0

### 2. Project Located in System-Protected Directory
- **Status:** BLOCKING file writes
- **Issue:** Project is at `C:\WINDOWS\myproject` - a system-protected path
- **Impact:** Any tool that writes files (build_runner, IDE, PowerShell scripts) gets "Access denied"
- **Fix:** Move project to `C:\Users\lober\myproject` or `C:\dev\myproject`

### 3. Missing Generated Code Files
- **Status:** BLOCKING compilation (18+ errors)
- **Issue:** `.g.dart` and `.freezed.dart` files have not been generated
- **Impact:** Every file that imports generated code fails to compile
- **Files affected:**
  - `lib/core/network/api_error.dart` and related `.g.dart` files
  - Authentication module providers and models
  - Subscription module models
- **Fix:** After resolving blockers 1 and 2, run:
  ```
  dart run build_runner build --delete-conflicting-outputs
  ```

---

## Non-Critical Issues

### 4. PATH Not Permanently Configured
- **Status:** Will break on terminal restart
- **Issue:** `firebase` and `flutterfire` CLI tools were added to PATH with session-only `$env:PATH +=` commands
- **Impact:** Every new terminal requires re-adding paths manually
- **Fix:** See SETUP_GUIDE.md Step 1c

### 5. Switch Exhaustiveness Fixes May Not Have Applied
- **Status:** UNCERTAIN
- **Issue:** PowerShell `Fix-Switch` commands reported both "Access denied" and "Fixed" for each file
- **Impact:** 6 Dart files may still have non-exhaustive switch statement errors
- **Files to check:**
  - `lib/modules/authentication/ui/phone_auth_page.dart`
  - `lib/modules/authentication/ui/recover_password_page.dart`
  - `lib/modules/authentication/ui/signin_page.dart`
  - `lib/modules/authentication/ui/signup_page.dart`
  - `lib/modules/subscription/ui/premium_page.dart`
  - `lib/modules/authentication/providers/phone_auth_notifier.dart`
- **Fix:** After code generation succeeds, try building. If switch errors appear, add `_ => const SizedBox(),` (or appropriate default) to each non-exhaustive switch

### 6. 20 Outdated Packages
- **Status:** LOW priority
- **Issue:** `flutter pub get` flagged 20 packages with newer versions
- **Impact:** Potential security patches and bug fixes not applied
- **Fix:** After project builds successfully:
  ```
  flutter pub outdated
  flutter pub upgrade
  ```

---

## Code Quality Observations

Based on the project structure and error patterns, here are observations about the boilerplate quality:

### Positives
- **Modern architecture:** Uses Riverpod for state management with code generation (riverpod_generator) - this is current best practice in the Flutter ecosystem
- **Type safety:** Uses freezed for immutable data classes and sealed unions - reduces runtime errors
- **Modular structure:** Code is organized into modules (authentication, subscription) with clear separation of UI and business logic
- **Multiple environments:** Separate Firebase configs for default and dev environments

### Concerns
1. **SDK constraint is aggressive:** Requiring Dart ^3.11.0 limits compatibility. Many developers won't have this SDK version yet. The boilerplate should either lower the constraint or clearly document the requirement.

2. **Heavy reliance on code generation:** The project uses freezed, riverpod_generator, json_serializable, and build_runner. This means:
   - First-time setup is complex (must run build_runner before anything works)
   - Build times are slower
   - New developers often get stuck on the "missing .g.dart" errors

3. **Switch exhaustiveness issues in boilerplate code:** The fact that 6 files had non-exhaustive switch statements out of the box suggests the boilerplate was either:
   - Generated for an older Dart version with different exhaustiveness rules
   - Not fully tested before distribution
   - This is a quality issue with the ApparenceKit template itself

4. **Firebase credentials in project:** The `firebase_options.dart` files contain API keys and project IDs. While Firebase client-side API keys aren't secret per se, it's still good practice to keep them out of version control via `.gitignore` (which we've now added).

---

## Recommended Fix Order

1. Move project out of `C:\WINDOWS` (fixes permission errors)
2. Upgrade Flutter SDK (fixes Dart version blocker)
3. Apply permanent PATH fixes (fixes CLI availability)
4. Run `flutter pub get` (resolve dependencies)
5. Run `dart run build_runner build --delete-conflicting-outputs` (generate code)
6. Build and check for remaining switch errors
7. Fix any remaining switch exhaustiveness issues
8. Run `flutter pub outdated` and update packages
