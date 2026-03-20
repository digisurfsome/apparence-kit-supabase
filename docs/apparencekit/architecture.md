# ApparenceKit Architecture

> Source: https://apparencekit.dev/docs/start/overview/

## 3-Layer Architecture

Every module follows the same pattern:

```
lib/
├── core/                    # Shared infrastructure
│   ├── data/api/            # Base API classes, exceptions
│   ├── guards/              # Route guards (auth, subscription)
│   ├── states/              # Global state (user state)
│   ├── theme/               # App theme
│   └── widgets/             # Shared widgets
├── modules/
│   ├── authentication/
│   │   ├── api/             # Auth API (Firebase/Supabase)
│   │   ├── repositories/    # Auth repository + exceptions
│   │   ├── providers/       # Riverpod state providers
│   │   └── ui/              # Sign-in, sign-up, recover pages
│   ├── subscription/
│   │   ├── api/             # RevenueCat API
│   │   ├── repositories/    # Subscription repository
│   │   ├── providers/       # Premium state providers
│   │   └── ui/              # Paywall pages
│   ├── notifications/
│   │   ├── api/             # Device API (FCM), notification API
│   │   ├── providers/       # Notification state
│   │   └── ui/              # Notification list page
│   ├── onboarding/
│   │   ├── api/             # User info API
│   │   ├── providers/       # Onboarding state
│   │   └── ui/              # Onboarding pages
│   ├── feedbacks/
│   │   ├── api/             # Feature request API
│   │   ├── providers/       # Feedback state
│   │   └── ui/              # Feedback pages
│   ├── settings/
│   │   └── ui/              # Settings pages
│   └── home/
│       └── ui/              # Home page
├── i18n/                    # Translations (slang)
└── main.dart                # App entry point
```

## State Management

- **Riverpod** with code generation (`riverpod_generator`)
- Providers are generated in `.g.dart` files
- State classes use **Freezed** for immutability

## Navigation

- **go_router** with declarative route definitions
- Route guards for authentication and subscription checks
- Deep linking support

## Code Generation

Required before building:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generates:
- `.g.dart` files — Riverpod providers, JSON serialization
- `.freezed.dart` files — Immutable state/model classes

These files are NOT committed to git.

## Environment Configuration

Uses `--dart-define` at compile time:

```bash
flutter run \
  --dart-define=ENV=dev \
  --dart-define=BACKEND_URL=https://your-supabase-url.supabase.co \
  --dart-define=SUPABASE_TOKEN=your-anon-key
```

Environment switching is handled in `lib/environments.dart` with dev/prod variants.
