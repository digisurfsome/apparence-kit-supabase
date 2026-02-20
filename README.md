# apparence_kit

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



# ApparenceKit CLI + Firebase Setup Worksheet

> **Purpose**: Chronological reconstruction of all terminal sessions from an ApparenceKit (Flutter boilerplate) CLI project setup with Firebase. Every command is listed in order with context on what happened before, during, and after execution. Repetitive error spam has been stripped out and distilled to key takeaways.

---

## Table of Contents

1. [Phase 1: Installing ApparenceKit CLI](#phase-1-installing-apparencekit-cli)
2. [Phase 2: Firebase Login and PATH Issues](#phase-2-firebase-login-and-path-issues)
3. [Phase 3: FlutterFire CLI Setup](#phase-3-flutterfire-cli-setup)
4. [Phase 4: FlutterFire Configure (Wrong Directory)](#phase-4-flutterfire-configure-wrong-directory)
5. [Phase 5: FlutterFire Configure (Success)](#phase-5-flutterfire-configure-success)
6. [Phase 6: FlutterFire Configure for Dev Environment](#phase-6-flutterfire-configure-for-dev-environment)
7. [Phase 7: Flutter Run Attempt (Debug Mode)](#phase-7-flutter-run-attempt-debug-mode)
8. [Phase 8: Build Runner Attempt (SDK Version Mismatch)](#phase-8-build-runner-attempt-sdk-version-mismatch)
9. [Phase 9: Flutter Run Release Mode Attempt](#phase-9-flutter-run-release-mode-attempt)
10. [Phase 10: File Fix Attempt (VS Code Terminal)](#phase-10-file-fix-attempt-vs-code-terminal)
11. [Key Issues Identified](#key-issues-identified)
12. [Recommended Next-Time Procedure (Clean Roadmap)](#recommended-next-time-procedure-clean-roadmap)

---

## Chronological Reconstruction of All Sessions

---

### Phase 1: Installing ApparenceKit CLI

**Terminal**: Fresh PowerShell

| Detail | Value |
|--------|-------|
| Command | `irm https://tinyurl.com/kitwindows \| iex` |
| Result | SUCCESS |
| Version | ApparenceKit CLI v5.0.16 |
| Installed to | `C:\Users\lober\.apparencekit\bin\apparence_cli.exe` |
| PATH status | Already in PATH -- no manual fix needed |

**What happened**: The one-liner downloaded and executed the ApparenceKit CLI installer for Windows. It placed the binary at `C:\Users\lober\.apparencekit\bin\apparence_cli.exe` and the installer automatically added that directory to PATH, so the CLI was immediately usable.

---

### Phase 2: Firebase Login and PATH Issues

**Terminal**: PowerShell from `C:\WINDOWS\system32`

#### Command 1: `firebase login` (FAILED)

```
firebase login
```

- **Result**: FAILED
- **Error**: `firebase: The term 'firebase' is not recognized as the name of a cmdlet, function, script file, or operable program.`
- **Root cause**: The npm global bin directory (`C:\Users\lober\AppData\Roaming\npm`) was not in the current session's PATH. Firebase CLI had been installed via npm (`npm install -g firebase-tools`) previously, but PowerShell could not find it.

#### Command 2: Fix PATH for Firebase (session-only)

```powershell
$env:PATH += ";C:\Users\lober\AppData\Roaming\npm"
```

- **Result**: SUCCESS -- PATH updated for this session only
- **Important**: This is a SESSION-ONLY fix. Closing and reopening the terminal will lose this change. See the [Permanent Fix](#issue-1-path-not-persistent-firebase-cli-not-found) section below.

#### Command 3: `firebase login` (SUCCESS)

```
firebase login
```

- **Result**: SUCCESS
- **Output**: `Already logged in as dux8bevo@gmail.com`
- **Context**: The user had previously authenticated with Firebase, so no browser-based login flow was needed.

---

### Phase 3: FlutterFire CLI Setup

**Terminal**: Same PowerShell session (still in `C:\WINDOWS\system32`)

#### Command 1: `flutterfire configure --project=sugarless-252ae` (FAILED)

```
flutterfire configure --project=sugarless-252ae
```

- **Result**: FAILED
- **Error**: `flutterfire: The term 'flutterfire' is not recognized`
- **Root cause**: FlutterFire CLI was not installed yet.

#### Command 2: Install FlutterFire CLI

```
dart pub global activate flutterfire_cli
```

- **Result**: SUCCESS -- Activated flutterfire_cli 1.3.1
- **WARNING from Dart**: `Pub installs executables into C:\Users\lober\AppData\Local\Pub\Cache\bin, which is not on your path.`
- **Meaning**: The `flutterfire` command still won't be found until PATH is updated.

#### Command 3: Fix PATH for FlutterFire (session-only)

```powershell
$env:PATH += ";$env:LOCALAPPDATA\Pub\Cache\bin"
```

- **Result**: SUCCESS -- PATH updated for this session only
- **Expands to**: `$env:PATH += ";C:\Users\lober\AppData\Local\Pub\Cache\bin"`
- **Important**: Another session-only fix. See the [Permanent Fix](#issue-1-path-not-persistent-firebase-cli-not-found) section below.

---

### Phase 4: FlutterFire Configure (Wrong Directory)

**Terminal**: Same session, still in `C:\WINDOWS\system32`

#### Command 1: `flutterfire configure --project=sugarless-252ae` (FAILED)

```
flutterfire configure --project=sugarless-252ae
```

- **Result**: FAILED
- **Error**: `FlutterAppRequiredException: The current directory does not appear to be a Flutter application project.`
- **Root cause**: The working directory was `C:\WINDOWS\system32`, not a Flutter project directory. FlutterFire needs to be run from the root of a Flutter project (a directory containing `pubspec.yaml`).

#### Command 2: Navigate to project directory

```powershell
cd C:\WINDOWS\myproject
```

- **Result**: Changed directory to the Flutter project location
- **Note**: The project was located inside `C:\WINDOWS\`, which is a protected system directory. This will cause permission issues later (see [Phase 10](#phase-10-file-fix-attempt-vs-code-terminal)).

---

### Phase 5: FlutterFire Configure (Success)

**Terminal**: Same session, now in `C:\WINDOWS\myproject`

#### Command: `flutterfire configure --project=sugarless-252ae`

```
flutterfire configure --project=sugarless-252ae
```

- **Result**: SUCCESS
- **Platforms selected**: web, android, ios
- **Firebase apps registered**:

| Platform | App ID |
|----------|--------|
| Web | `1:91333191859:web:1b192e74a0aa2b6017a8c6` |
| Android | `1:91333191859:android:30ff8af0930ed7cd17a8c6` |
| iOS | `1:91333191859:ios:798b13ff8ee8793e17a8c6` |

- **File generated**: `lib\firebase_options.dart`
- **What this did**: Registered the Flutter app with the Firebase project `sugarless-252ae` for all three platforms and generated the default Firebase configuration file used at app startup.

---

### Phase 6: FlutterFire Configure for Dev Environment

**Terminal**: Same session, same directory

#### Command: `flutterfire configure --project=sugarless-252ae --out lib/firebase_options_dev.dart`

```
flutterfire configure --project=sugarless-252ae --out lib/firebase_options_dev.dart
```

- **Result**: SUCCESS
- **File generated**: `lib\firebase_options_dev.dart`
- **Same Firebase apps**: Reused the same app registrations from Phase 5
- **Purpose**: This creates a separate configuration file for the "dev" flavor/environment. In a multi-environment setup (dev, staging, prod), each environment has its own `firebase_options_*.dart` file so the app can connect to different Firebase projects or app registrations depending on the build configuration.

---

### Phase 7: Flutter Run Attempt (Debug Mode)

**Terminal**: Same session

#### Command: `flutter run -d chrome`

```
flutter run -d chrome
```

- **Result**: FAILED -- Compilation errors
- **Key errors** (distilled from hundreds of lines of output):
  1. **Missing generated files** (`.g.dart`, `.freezed.dart`): `The system cannot find the file specified`
  2. These are **code-generation files** that need `build_runner` to generate them
  3. Massive cascade of errors because `freezed` and `riverpod_generator` output files don't exist yet

- **What went wrong**: The ApparenceKit boilerplate uses code generation heavily (via packages like `freezed`, `json_serializable`, `riverpod_generator`). These packages produce `.g.dart` and `.freezed.dart` files at build time. The command `dart run build_runner build` must be run BEFORE the app can compile. Without those generated files, every file that imports them fails, creating a cascade of hundreds of errors.

---

### Phase 8: Build Runner Attempt (SDK Version Mismatch)

**Terminal**: Same session

#### Command: `dart run build_runner build --delete-conflicting-outputs`

```
dart run build_runner build --delete-conflicting-outputs
```

- **Result**: FAILED
- **Error**: `The current Dart SDK version is 3.8.1. Because apparence_kit requires SDK version ^3.11.0, version solving failed.`
- **Breakdown**:
  - Installed Dart SDK: **3.8.1** (ships with Flutter 3.41.0)
  - Required Dart SDK: **^3.11.0** (as specified in the project's `pubspec.yaml`)
  - The `^` means "3.11.0 or higher, but less than 4.0.0"

**THIS IS THE CRITICAL BLOCKER.** The project template was generated for a newer version of Flutter/Dart than what is installed. Until the Dart SDK is upgraded to 3.11.0+, `build_runner` cannot run, generated files cannot be created, and the app cannot compile.

---

### Phase 9: Flutter Run Release Mode Attempt

**Terminal**: Same session

#### Command: `flutter run -d chrome --release`

```
flutter run -d chrome --release
```

- **Result**: FAILED
- **Errors**: Same missing generated files as Phase 7
- **Additional note**: Output included a deprecation warning about `--pwa-strategy`
- **Root cause**: Identical to Phase 7 -- `build_runner` has not been run (and cannot be, due to the SDK mismatch from Phase 8). Release mode does not bypass the need for generated code files.

---

### Phase 10: File Fix Attempt (VS Code Terminal)

**Terminal**: VS Code integrated PowerShell, working directory `C:\WINDOWS\myproject`

An AI coding agent provided a PowerShell function to fix switch statement exhaustiveness errors by adding default/wildcard cases to Dart switch expressions.

#### Step 1: Define the Fix-Switch function

```powershell
function Fix-Switch {
    # Multi-line PowerShell function to:
    # 1. Read a Dart file
    # 2. Find switch statements missing a default/wildcard case
    # 3. Add a specified default case (e.g., "_ => const SizedBox()," or "_ => throw StateError('Unknown state'),")
    # 4. Write the modified file back
}
```

- **Purpose**: Address compiler errors about non-exhaustive switch statements in the Dart code

#### Step 2: Apply fixes to 6 files

Each command below was run individually:

| # | Command | Target File | Default Case Added |
|---|---------|-------------|-------------------|
| 1 | `Fix-Switch "lib\modules\authentication\ui\phone_auth_page.dart" "_ => const SizedBox(),"` | phone_auth_page.dart | Widget fallback |
| 2 | `Fix-Switch "lib\modules\authentication\ui\recover_password_page.dart" "_ => const SizedBox(),"` | recover_password_page.dart | Widget fallback |
| 3 | `Fix-Switch "lib\modules\authentication\ui\signin_page.dart" "_ => const SizedBox(),"` | signin_page.dart | Widget fallback |
| 4 | `Fix-Switch "lib\modules\authentication\ui\signup_page.dart" "_ => const SizedBox(),"` | signup_page.dart | Widget fallback |
| 5 | `Fix-Switch "lib\modules\subscription\ui\premium_page.dart" "_ => const SizedBox(),"` | premium_page.dart | Widget fallback |
| 6 | `Fix-Switch "lib\modules\authentication\providers\phone_auth_notifier.dart" "_ => throw StateError('Unknown state'),"` | phone_auth_notifier.dart | Error throw |

- **Result for ALL 6**: Each command printed "Fixed" but then threw `UnauthorizedAccessException: Access to the path ... is denied.`
- **What actually happened**: The function read each file and found the switch statements to fix, but **failed to write the modified content back** because `C:\WINDOWS\myproject` is inside a protected system directory. The files were NOT actually modified despite the "Fixed" message appearing.

#### Step 3: Completion message

```powershell
Write-Host "Done! All files fixed."
```

- **Reality**: None of the files were actually fixed due to the permission errors.

---

## Key Issues Identified

---

### Issue 1: PATH Not Persistent (Firebase CLI Not Found)

| Detail | Value |
|--------|-------|
| **Problem** | `firebase` and `flutterfire` commands not found in new terminal sessions |
| **Root cause** | npm and Pub Cache bin directories not in the persistent user PATH |
| **Session-only workarounds used** | See below |

**Session-only workarounds** (must be re-run every time a new terminal is opened):

```powershell
$env:PATH += ";C:\Users\lober\AppData\Roaming\npm"
$env:PATH += ";$env:LOCALAPPDATA\Pub\Cache\bin"
```

**Permanent fix** (run once, persists across all future terminal sessions):

```powershell
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\Users\lober\AppData\Roaming\npm", "User")
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$env:LOCALAPPDATA\Pub\Cache\bin", "User")
```

> **Note**: The permanent fix commands were suggested during the session but were never actually executed. The user continued using the session-only workarounds.

---

### Issue 2: Dart SDK Version Mismatch (CRITICAL BLOCKER)

| Detail | Value |
|--------|-------|
| **Problem** | Project requires Dart ^3.11.0, but installed Dart is 3.8.1 |
| **Installed Flutter** | 3.41.0 (ships with Dart 3.8.1) |
| **Required Dart** | ^3.11.0 (specified in project's `pubspec.yaml`) |
| **Impact** | Blocks `build_runner`, which blocks code generation, which blocks compilation |
| **Solution** | Upgrade Flutter to a version that ships with Dart 3.11.0+ |

This is the single most important issue. Everything downstream (missing generated files, compilation errors) traces back to this SDK version mismatch.

---

### Issue 3: Missing Code-Generated Files

| Detail | Value |
|--------|-------|
| **Problem** | `.g.dart` and `.freezed.dart` files do not exist |
| **Caused by** | `build_runner` has never been run successfully |
| **Blocked by** | Issue 2 (Dart SDK version mismatch) |
| **Solution** | After upgrading SDK, run `dart run build_runner build --delete-conflicting-outputs` |

The ApparenceKit template relies heavily on code generation from packages like `freezed`, `json_serializable`, and `riverpod_generator`. These packages produce companion files (e.g., `my_model.freezed.dart`, `my_model.g.dart`) that are imported throughout the codebase. Without them, nothing compiles.

---

### Issue 4: File Permission Errors (Project in System Directory)

| Detail | Value |
|--------|-------|
| **Problem** | Project located at `C:\WINDOWS\myproject` -- a protected system directory |
| **Impact** | PowerShell scripts cannot write to files; potential issues with build tools |
| **Error** | `UnauthorizedAccessException: Access to the path ... is denied.` |
| **Solution** | Move project to a user-writable location like `C:\Users\lober\projects\myproject` |

The `C:\WINDOWS` directory tree is protected by Windows. Even with normal admin privileges, write operations can be blocked or require elevated permissions. This is not a suitable location for development projects.

---

### Issue 5: Switch Statement Exhaustiveness Errors

| Detail | Value |
|--------|-------|
| **Problem** | Multiple Dart files have switch expressions without default/wildcard cases |
| **Compiler behavior** | Dart's exhaustiveness checking flags these as errors |
| **Attempted fix** | PowerShell `Fix-Switch` function |
| **Fix result** | FAILED due to Issue 4 (permission errors) |

**Files that need default cases added**:

1. `lib\modules\authentication\ui\phone_auth_page.dart` -- needs `_ => const SizedBox(),`
2. `lib\modules\authentication\ui\recover_password_page.dart` -- needs `_ => const SizedBox(),`
3. `lib\modules\authentication\ui\signin_page.dart` -- needs `_ => const SizedBox(),`
4. `lib\modules\authentication\ui\signup_page.dart` -- needs `_ => const SizedBox(),`
5. `lib\modules\subscription\ui\premium_page.dart` -- needs `_ => const SizedBox(),`
6. `lib\modules\authentication\providers\phone_auth_notifier.dart` -- needs `_ => throw StateError('Unknown state'),`

> **Note**: Once Issue 2 (SDK mismatch) is resolved and `build_runner` generates the `.freezed.dart` files, some or all of these exhaustiveness errors may resolve automatically because the generated sealed class subtypes will be available for the compiler to check against.

---

## Recommended Next-Time Procedure (Clean Roadmap)

This is the ideal sequence of steps for setting up the same project from scratch, avoiding all the issues encountered in the sessions above.

---

### Step 0: Permanent PATH Fix (DO THIS FIRST)

Run this **once** in any PowerShell window to permanently add both the npm and Pub Cache bin directories to your user PATH:

```powershell
[Environment]::SetEnvironmentVariable(
    "PATH",
    [Environment]::GetEnvironmentVariable("PATH", "User") + ";C:\Users\lober\AppData\Roaming\npm;C:\Users\lober\AppData\Local\Pub\Cache\bin",
    "User"
)
```

Then **close and reopen** your terminal for the change to take effect.

**Verify it worked**:

```powershell
firebase --version
flutterfire --version
```

Both should return version numbers without "not recognized" errors.

---

### Step 1: Upgrade Flutter/Dart SDK

```powershell
flutter upgrade
```

Or, if a specific version is needed:

```powershell
flutter version <version-with-dart-3.11.0+>
```

**Verify**:

```powershell
dart --version
# Should output 3.11.0 or higher
```

---

### Step 2: Install CLI Tools

```powershell
# Install ApparenceKit CLI
irm https://tinyurl.com/kitwindows | iex

# Activate FlutterFire CLI
dart pub global activate flutterfire_cli
```

---

### Step 3: Create Project in a User-Writable Directory (NOT C:\WINDOWS)

```powershell
# Create a projects directory in your user folder
mkdir C:\Users\lober\projects -ErrorAction SilentlyContinue

# Navigate there
cd C:\Users\lober\projects

# Use the ApparenceKit CLI to create/scaffold the project here
apparence_cli.exe create <project-name>
# (or whatever the actual CLI command is for project creation)
```

---

### Step 4: Firebase Setup

```powershell
# Login to Firebase (skip if already logged in)
firebase login

# Navigate to the project directory
cd C:\Users\lober\projects\<project-name>

# Configure Firebase for production
flutterfire configure --project=sugarless-252ae

# Configure Firebase for dev environment
flutterfire configure --project=sugarless-252ae --out lib/firebase_options_dev.dart
```

---

### Step 5: Generate Code Files

```powershell
# Get all dependencies first
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs
```

This generates all the `.g.dart` and `.freezed.dart` files that the project needs to compile.

---

### Step 6: Fix Any Remaining Switch Exhaustiveness Errors

If the compiler still reports non-exhaustive switch statements after code generation, manually add default cases:

- For **UI widget switches** (returning widgets): add `_ => const SizedBox(),`
- For **logic/state switches** (not returning widgets): add `_ => throw StateError('Unknown state'),`

---

### Step 7: Run the App

```powershell
flutter run -d chrome
```

If successful, the app should launch in Chrome.

---

## Summary of Session Timeline

| Phase | Action | Result | Blocker |
|-------|--------|--------|---------|
| 1 | Install ApparenceKit CLI | SUCCESS | -- |
| 2 | Firebase login | SUCCESS (after PATH fix) | PATH not set |
| 3 | Install FlutterFire CLI | SUCCESS (after PATH fix) | PATH not set |
| 4 | FlutterFire configure | FAILED | Wrong directory |
| 5 | FlutterFire configure | SUCCESS | -- |
| 6 | FlutterFire configure (dev) | SUCCESS | -- |
| 7 | Flutter run (debug) | FAILED | Missing generated files |
| 8 | Build runner | FAILED | **Dart SDK 3.8.1 < required 3.11.0** |
| 9 | Flutter run (release) | FAILED | Missing generated files |
| 10 | Fix-Switch file edits | FAILED | File permissions (C:\WINDOWS) |

**Bottom line**: The project was correctly set up with Firebase, but cannot compile because (a) the Dart SDK is too old for the project template, and (b) the project is located in a protected system directory. Upgrading the SDK and moving the project to a user directory will unblock everything.
