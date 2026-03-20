# Setup ApparenceKit with Supabase

> Source: https://apparencekit.dev/docs/start/supabase-setup/

**IMPORTANT:** Even if you use Supabase, Firebase is still required for push notifications and remote config, as Supabase doesn't provide these services.

## Architecture

- **Supabase** = authentication, database, user data, storage
- **Firebase** = Cloud Messaging (push notifications), Remote Config (A/B testing)

---

## 1. Generate Your App

```bash
apparence_cli setup .
```

Select Supabase during setup. Choose optional features (Sentry, Firebase Remote Config, Mixpanel, internationalization, introduction screens).

Then run:

```bash
apparence_cli supabase .
```

This automates the remaining configuration steps.

---

## 2. Setup Supabase (Manual)

Requirements: Active Supabase account and project.

You need:
1. Supabase project URL
2. Supabase anon key (token)

### VSCode Configuration

Edit `.vscode/launch.json`:

```json
{
  "args": [
    "--dart-define=ENV=dev",
    "--dart-define=BACKEND_URL=YOUR_SUPABASE_PROJECT_URL",
    "--dart-define=SUPABASE_TOKEN=YOUR_SUPABASE_ANON_KEY"
  ]
}
```

### Command Line

```bash
flutter run --dart-define=ENV=dev \
  --dart-define=BACKEND_URL=YOUR_SUPABASE_PROJECT_URL \
  --dart-define=SUPABASE_TOKEN=YOUR_SUPABASE_PROJECT_TOKEN
```

### Code Implementation

In `lib/main.dart`:

```dart
await env.map(
  dev: (_) => Supabase.initialize(
    url: env.backendUrl,
    anonKey: const String.fromEnvironment('SUPABASE_TOKEN'),
  ),
  ...
);
```

---

## 3. Authentication Providers

In Supabase dashboard > Authentication > Providers:
- Enable email and password provider
- **Disable email confirmation** (improves user experience and retention)

---

## 4. Database Setup

1. Access the Supabase SQL Editor
2. Paste the content from `supabase/migrations/` (or the setup SQL from the ApparenceKit-supabase repo)
3. Execute — this creates all tables AND Row Level Security policies

Without RLS policies, users cannot access their data.

---

## 5. Firebase Setup (for Notifications + Remote Config)

Firebase Cloud Messaging is required for push notifications on Android and iOS.

### Install Firebase CLI

```bash
# Mac
brew install firebase-cli

# Or via npm
npm install -g firebase-tools
```

### Login

```bash
firebase login
```

### Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Configure

```bash
flutterfire configure --project=YOUR_PROJECT_NAME --out lib/firebase_options_dev.dart
```

**IMPORTANT:** Remove the auto-generated Firebase files from native folders:
- Delete `google-services.json` from `android/app/`
- Delete `GoogleService-Info.plist` from `ios/Runner/`

Use Dart-only Firebase configuration instead.

### Firebase Initialization in Code

```dart
import 'package:apparence_kit/firebase_options_dev.dart' as firebase_dev;

void main() async {
  ...
  await env.when(
    dev: (_) => Firebase.initializeApp(
      options: firebase_dev.DefaultFirebaseOptions.currentPlatform,
    ),
    ...
  );
}
```

---

## 6. RevenueCat Webhook (for In-App Purchases)

ApparenceKit uses RevenueCat for in-app purchases. A webhook must be deployed to sync purchases with the Supabase database. See the ApparenceKit-supabase repository for the webhook implementation.
