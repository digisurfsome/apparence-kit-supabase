# ApparenceKit Boilerplate

Flutter/Dart boilerplate project built with ApparenceKit CLI.

## Tech Stack

- **Framework:** Flutter (Dart)
- **Backend:** Firebase (`sugarless-252ae`)
- **State Management:** Riverpod (with code generation)
- **Code Generation:** freezed, json_serializable, riverpod_generator, build_runner
- **CLI:** ApparenceKit CLI v5.0.16

## Requirements

- **Dart SDK:** ^3.11.0
- **Flutter:** Latest stable (must bundle Dart >= 3.11.0)
- **Firebase CLI:** installed via npm
- **FlutterFire CLI:** installed via `dart pub global activate flutterfire_cli`

## Setup

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed setup instructions.

### Quick Start

```bash
# 1. Install dependencies
flutter pub get

# 2. Run code generation
dart run build_runner build --delete-conflicting-outputs

# 3. Run on Chrome
flutter run -d chrome
```

## Known Issues

See [KNOWN_ISSUES.md](KNOWN_ISSUES.md) for a detailed analysis of current blockers and recommendations.

## Project Structure

```
lib/
  core/
    network/         # API client, error handling
  modules/
    authentication/  # Sign in, sign up, phone auth, password recovery
      ui/            # Page widgets
      providers/     # Riverpod state notifiers
    subscription/    # Premium/subscription features
      ui/
  firebase_options.dart      # Firebase config (default)
  firebase_options_dev.dart  # Firebase config (dev)
  main.dart                  # App entry point
```
