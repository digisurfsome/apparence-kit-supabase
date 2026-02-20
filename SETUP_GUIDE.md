# Setup Guide: Pushing Your Local Project to GitHub

## Prerequisites

Before starting, make sure you have:
- Git installed (`git --version` to check)
- A GitHub account with access to the `digisurfsome/apparence-kit` repository

---

## Step 1: Fix Critical Blockers First

### 1a. Move the project out of C:\WINDOWS

Your project is at `C:\WINDOWS\myproject` which is a system-protected directory. This causes "Access denied" errors. Move it first:

```powershell
Move-Item -Path "C:\WINDOWS\myproject" -Destination "C:\Users\lober\myproject"
cd C:\Users\lober\myproject
```

### 1b. Upgrade Flutter/Dart SDK

Your Dart SDK (3.8.1) is too old. The project requires ^3.11.0:

```powershell
flutter channel stable
flutter upgrade
```

Verify:
```powershell
dart --version
# Must show >= 3.11.0
```

### 1c. Fix PATH permanently

Run this ONCE in PowerShell (as your regular user, NOT as admin):

```powershell
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$npmPath = "C:\Users\lober\AppData\Roaming\npm"
$pubPath = "C:\Users\lober\AppData\Local\Pub\Cache\bin"
$newPath = $currentPath + ";" + $npmPath + ";" + $pubPath
[Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
```

Then close and reopen ALL terminal windows.

---

## Step 2: Push Your Code to GitHub

Open PowerShell and navigate to your project:

```powershell
cd C:\Users\lober\myproject
```

### 2a. Initialize git (if not already a git repo)

```powershell
git init
```

### 2b. Add the GitHub remote

```powershell
git remote add origin https://github.com/digisurfsome/apparence-kit.git
```

If the remote already exists:
```powershell
git remote set-url origin https://github.com/digisurfsome/apparence-kit.git
```

### 2c. Pull the existing repo files (.gitignore, README, etc.)

```powershell
git fetch origin
git checkout -b main
git pull origin claude/setup-github-boilerplate-B5Y8G --allow-unrelated-histories
```

### 2d. Stage and commit your project files

```powershell
git add .
git status
```

Review the output of `git status` to make sure no secrets are being committed (the .gitignore should handle this). Then:

```powershell
git commit -m "Add ApparenceKit boilerplate project"
```

### 2e. Push to GitHub

```powershell
git push -u origin main
```

---

## Step 3: Build the Project

After pushing, run these commands to get the project building:

```powershell
cd C:\Users\lober\myproject

# Install dependencies
flutter pub get

# Generate code (freezed, riverpod, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Run on Chrome
flutter run -d chrome
```

---

## Troubleshooting

### "firebase is not recognized"
Your PATH doesn't include the npm directory. Either:
- Apply the permanent PATH fix from Step 1c, OR
- Run `$env:PATH += ";C:\Users\lober\AppData\Roaming\npm"` (temporary, per-session)

### "flutterfire is not recognized"
Same issue. Either:
- Apply the permanent PATH fix from Step 1c, OR
- Run `$env:PATH += ";C:\Users\lober\AppData\Local\Pub\Cache\bin"` (temporary, per-session)

### "Access denied" errors
You're probably still working inside `C:\WINDOWS\myproject`. Move the project per Step 1a.

### "SDK version ^3.11.0" error
Your Flutter/Dart SDK is too old. Upgrade per Step 1b.

### Missing .g.dart / .freezed.dart files
Run code generation: `dart run build_runner build --delete-conflicting-outputs`
