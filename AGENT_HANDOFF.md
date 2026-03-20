# Agent Handoff Report

**Date:** March 20, 2026
**Repos:** `digisurfsome/apparence-kit-supabase` (Flutter) + `digisurfsome/fullstack-boilerplate` (dual)

---

## What Was Done

### 1. Flutter App (apparence-kit-supabase) — Audited & Documented

**Starting state:** Raw ApparenceKit template with Firebase backend. Named "supabase" but had zero Supabase code.

**Work completed:**
- Full code audit of ~490 files → `AUDIT_REPORT.md` (grade: B-)
- Tech runway assessment → `TECH_RUNWAY.md` (dependency health, migration timeline)
- Known issues tracker → `KNOWN_ISSUES.md`
- Fixed 7 bugs inherited from Firebase sister repo (auth state checks, copy-paste errors, password validation)
- Removed secrets from git tracking (google-services.json, firebase_options.dart)
- Removed 44 generated files (.g.dart, .freezed.dart) from git tracking
- Added `.gitignore` rules for all generated/secret files
- Wrote Supabase SQL migration: `supabase/migrations/20260320000000_initial_schema.sql` — full Postgres schema for all mobile tables (users, mobile_subscriptions, notifications, devices, feature_requests, feature_votes, user_feature_requests, user_infos, avatars bucket + RLS)
- Created `.claude/rules/` with `flutter.mdc`, `supabase_api.mdc`, `unit_tests.mdc` — conventions for future agents
- Created `docs/apparencekit/` with architecture, environment, notifications, phone-auth, overview, supabase-setup guides

**What was NOT done:**
- Firebase-to-Supabase code migration (Dart API layer still uses Firebase for auth, database, storage)
- The 19 Dart files that import Firebase packages still need rewriting — see TECH_RUNWAY.md section 4 for full list and per-file migration plan
- Test coverage is still thin (happy paths only)

### 2. Dual Boilerplate (fullstack-boilerplate) — Created & Pushed

**What it is:** Monorepo combining Flutter mobile + Next.js web + shared Supabase backend.

**Structure:**
```
fullstack-boilerplate/
├── flutter/          # Copy of apparence-kit-supabase (minus supabase/, .git/, .github/)
├── nextjs/           # Copy of Web-BoilerPlate-D2D/nextjs/
├── supabase/         # Merged from both repos
│   ├── migrations/
│   │   ├── 20240717231009_init.sql            # Web: users + Stripe tables
│   │   ├── 20260320000001_mobile_tables.sql   # Mobile: notifications, devices, etc.
│   │   └── 20260320000002_merge_schemas.sql   # Merge: adds mobile columns to users, creates user_entitlements view
│   └── functions/    # Web's Deno edge functions (Stripe webhook, etc.)
├── .claude/CLAUDE.md # Agent instructions for the monorepo
├── .github/workflows/ci.yml  # CI for both Flutter + Next.js
├── .env.example      # All env vars for both platforms
├── setup.sh          # One-command setup script
└── README.md         # Quick start + setup checklist
```

**How it was built:** The `scripts/create_dual_repo.sh` script (in apparence-kit-supabase) cloned both source repos and merged them. Key decisions:
- Web's Supabase schema runs first (creates users + Stripe tables)
- Mobile tables added as second migration (renamed `subscriptions` → `mobile_subscriptions` to avoid conflict)
- Third migration merges: adds mobile columns to users table, creates unified `handle_new_user` trigger, creates `user_entitlements` view
- Flutter's standalone `supabase/` and `.github/` removed (replaced by monorepo versions)

**Current branch state:**
- Branch `claude/prepare-reusable-boilerplate-lb6a9` was pushed
- No `main` branch exists yet

---

## What the Next Agent Needs to Do

### Priority 1: Repository Housekeeping

1. **Create `main` branch** from `claude/prepare-reusable-boilerplate-lb6a9` (or merge into main)
2. **Enable "Template repository"** in GitHub Settings (so `gh repo create --template` works)
3. **Verify the repo structure** — confirm flutter/, nextjs/, supabase/ all exist with correct contents

### Priority 2: Flutter Firebase→Supabase Migration

This is the big one. The Flutter app's Dart code still calls Firebase. It needs to call Supabase instead.

**Architecture advantage:** The app uses abstract interfaces (API → Repository → Provider/UI). Only the API layer needs rewriting. UI and business logic stay untouched.

**Files to rewrite (19 total):**

| File | Current | Target |
|------|---------|--------|
| `flutter/lib/modules/authentication/api/authentication_api.dart` | firebase_auth | supabase.auth |
| `flutter/lib/core/data/api/user_api.dart` | cloud_firestore | supabase.from('users') |
| `flutter/lib/modules/notifications/api/notifications_api.dart` | cloud_firestore | supabase.from('notifications') |
| `flutter/lib/modules/feedbacks/api/feature_request_api.dart` | cloud_firestore | supabase.from('feature_requests') |
| `flutter/lib/modules/feedbacks/api/feature_vote_api.dart` | cloud_firestore | supabase.from('feature_votes') |
| `flutter/lib/modules/feedbacks/api/user_feature_request_api.dart` | cloud_firestore | supabase.from('user_feature_requests') |
| `flutter/lib/modules/onboarding/api/user_infos_api.dart` | cloud_firestore | supabase.from('user_infos') |
| `flutter/lib/modules/subscription/api/subscription_api.dart` | cloud_firestore | supabase.from('mobile_subscriptions') |
| `flutter/lib/modules/notifications/api/device_api.dart` | cloud_firestore | supabase.from('devices') |
| `flutter/lib/core/data/api/storage_api.dart` | firebase_storage | supabase.storage |
| `flutter/lib/main.dart` | Firebase.initializeApp | Supabase.initialize |

**Keep Firebase for:**
- `firebase_messaging` (push notifications — Supabase has no equivalent)
- `firebase_remote_config` (optional — can replace with Supabase table)

**Supabase API pattern** (defined in `flutter/.claude/rules/supabase_api.mdc`):
```dart
class UserApi {
  final SupabaseClient _client;
  UserApi(this._client);

  Future<UserModel> getUser(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromJson(response);
  }
}
```

**High-risk migration items:**
- Anonymous-to-permanent account linking (`linkWithCredential` has no Supabase equivalent — needs Edge Function)
- Phone/OTP auth (different API shape)
- Firestore sub-collections → flat Postgres tables (schema already designed in migrations)

### Priority 3: Next.js Verification

The Next.js app came from `Web-BoilerPlate-D2D` which is already Supabase-native. It should work with minimal changes:
- Verify it builds: `cd nextjs && npm ci && npm run build`
- Verify Supabase client config points to shared project
- Verify Stripe webhook edge function matches the schema

### Priority 4: Integration Testing

- Sign up on web → verify user row created in `users` table
- Sign up on mobile → verify same `users` table, `handle_new_user` trigger populates all columns
- Subscribe on web (Stripe) → check `user_entitlements` view
- Subscribe on mobile (RevenueCat) → check `user_entitlements` view
- Cross-platform: user subscribes on web, opens mobile app → entitlement recognized

### Priority 5: Template Readiness

Per-app customization checklist (for when this template is cloned for a real app):
- App name in pubspec.yaml, AndroidManifest.xml, web/index.html, web/manifest.json
- Bundle ID: `com.yourcompany.template` → real bundle ID
- Firebase: `flutterfire configure` for push notifications
- Stripe keys in .env
- RevenueCat keys in flutter/lib/environments.dart
- Supabase URL + anon key in .env
- Terms/Privacy URLs in flutter/lib/environments.dart
- Facebook App ID in android strings.xml (or remove if not using)

---

## Schema Reference

### Migration Order
1. `20240717231009_init.sql` — Web: users, customers, products, prices, subscriptions (Stripe)
2. `20260320000001_mobile_tables.sql` — Mobile: mobile_subscriptions, notifications, devices, feature_requests, feature_votes, user_feature_requests, user_infos, avatars bucket
3. `20260320000002_merge_schemas.sql` — Merge: adds mobile columns to users, creates user_entitlements view, merges handle_new_user trigger

### Users Table (Merged)
```sql
users (
  id uuid PK,           -- auth.users FK
  email text,            -- mobile
  name text,             -- mobile
  full_name text,        -- web
  avatar_url text,       -- web
  avatar_path text,      -- mobile
  onboarded boolean,     -- mobile
  locale text,           -- mobile
  billing_address jsonb, -- web (Stripe)
  payment_method jsonb,  -- web (Stripe)
  creation_date timestamptz,
  last_update_date timestamptz
)
```

### Subscription Architecture
- `subscriptions` — Stripe (web), synced via stripe_webhook edge function
- `mobile_subscriptions` — RevenueCat (mobile), synced from Flutter app
- `user_entitlements` — View that UNIONs both, query this to check if user has active sub

---

## Three-Repo Strategy

| Repo | Use Case | Status |
|------|----------|--------|
| `apparence-kit-supabase` | Mobile-only apps | Audited, documented, Firebase code not yet migrated |
| `Web-BoilerPlate-D2D` | Web-only apps | Already Supabase-native, working |
| `fullstack-boilerplate` | Mobile + Web apps | Created, structure correct, Flutter code needs Supabase migration |

SaaS clone logic for all three is identical:
```bash
gh repo create "$USER_ORG/$APP_NAME" --template digisurfsome/<repo> --private
```

---

## Known Bugs Still Open

1. **Force unwraps** in `subscription_repository.dart:87,166` — potential null crashes
2. **Hardcoded app names** in 5+ locations — must be parameterized per-app
3. **Empty terms/privacy URLs** in `environments.dart` — broken links
4. **Placeholder Facebook credentials** in `strings.xml` — SDK init failure
5. **Artificial delays** (1.5s) in auth flows — should be debounce logic
6. **Thin test coverage** — happy paths only, no error/edge cases

---

## File Map for Reference

### This repo (apparence-kit-supabase)
```
AUDIT_REPORT.md                  # Full code audit
TECH_RUNWAY.md                   # Dependency health + migration plan
KNOWN_ISSUES.md                  # Bug tracker
SETUP_GUIDE.md                   # Local dev setup
AGENT_HANDOFF.md                 # THIS FILE
docs/DUAL_BOILERPLATE_MERGE_GUIDE.md  # Three-repo strategy + schema docs
docs/apparencekit/               # Architecture, auth, notifications docs
scripts/create_dual_repo.sh      # Script that built fullstack-boilerplate
supabase/migrations/             # Mobile Postgres schema
.claude/CLAUDE.md                # Agent instructions
.claude/rules/                   # Coding conventions (flutter, supabase_api, unit_tests)
```

### fullstack-boilerplate (the dual repo)
```
flutter/                         # Mobile app (needs Firebase→Supabase migration)
nextjs/                          # Web app (already Supabase-native)
supabase/migrations/             # 3 migrations (web init + mobile tables + merge)
supabase/functions/              # Deno edge functions (Stripe, analytics)
.claude/CLAUDE.md                # Agent instructions for monorepo
.github/workflows/ci.yml         # CI for both apps
.env.example                     # All env vars
setup.sh                         # One-command setup
README.md                        # Quick start
```
