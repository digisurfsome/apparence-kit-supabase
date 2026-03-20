# ApparenceKit Overview

> Source: https://apparencekit.dev/docs/start/overview/

ApparenceKit is a production-ready Flutter starter kit that provides a complete app foundation with authentication, subscriptions, notifications, onboarding, feedback, and settings modules.

## What You Get

- **Authentication** — Email/password, Google, Apple, Facebook, phone sign-in
- **Subscriptions** — RevenueCat integration for in-app purchases
- **Push Notifications** — Firebase Cloud Messaging (FCM) for iOS and Android
- **Onboarding** — Configurable user onboarding flow
- **Feedback** — Feature request voting board
- **Settings** — User settings and admin panel
- **Internationalization** — Multi-language support via slang

## Stack

- **Flutter** — Cross-platform UI framework
- **Riverpod** — State management (with code generation)
- **Freezed** — Immutable data models (with code generation)
- **go_router** — Declarative routing with guards
- **build_runner** — Code generation for .g.dart and .freezed.dart files

## Backend Options

ApparenceKit supports multiple backend configurations:
1. **Firebase** — Full Firebase (Auth, Firestore, Storage, FCM, Remote Config)
2. **Supabase** — Supabase for auth/database/storage + Firebase for FCM and remote config
3. **HTTP** — Custom HTTP backend + Firebase for FCM

The backend is selected during `apparence_cli setup .` and determines which API implementations are generated.

## Architecture

3-layer architecture per module:

```
API Layer (data source) → Repository Layer (business logic) → UI Layer (presentation)
```

Each module follows this pattern:
- `api/` — Data source classes and entity models
- `repositories/` or `providers/` — Business logic and state management
- `ui/` — Pages and widgets

## CLI Commands

```bash
# Initial setup — generates app with selected backend and features
apparence_cli setup .

# Supabase-specific setup — configures Supabase tables, RLS, etc.
apparence_cli supabase .
```
