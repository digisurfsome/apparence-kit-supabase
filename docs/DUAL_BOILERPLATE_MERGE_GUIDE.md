# Boilerplate Strategy: Three Repos

## The System

Three GitHub repos, each independently clonable:

| Repo | When to use | What's inside |
|------|------------|---------------|
| `apparence-kit-supabase` | Mobile-only app | Flutter + Supabase + Firebase (FCM) + RevenueCat |
| `Web-BoilerPlate-D2D` | Web-only app | Next.js + Supabase + Stripe + PostHog |
| `fullstack-boilerplate` | Mobile + Web app | Both merged into one monorepo, shared Supabase |

**User flow in your SaaS:**
1. User enters app name, provides GitHub token
2. User picks: Mobile / Web / Dual
3. System clones the correct repo → renames → pushes to user's GitHub
4. Agent runs setup checklist (env vars, Supabase project, etc.)

---

## Why Three Repos (Not Two + Merge Script)

- **Reliability**: Clone-and-go. No merge logic to break.
- **Speed**: Dual app setup is instant, same as mobile or web.
- **Testability**: The dual repo is a real, tested, working app. Not a runtime merge.
- **Simplicity**: Your SaaS clone logic is identical for all three cases.
- **Trade-off**: When you update mobile or web, you also update the dual. Worth it.

---

## Maintenance Workflow

```
You update the mobile boilerplate (apparence-kit-supabase)
    │
    ├── 1. Push changes to apparence-kit-supabase
    └── 2. Port the same changes into fullstack-boilerplate/flutter/
           (cherry-pick, or just manually apply — it's the same code)

You update the web boilerplate (Web-BoilerPlate-D2D)
    │
    ├── 1. Push changes to Web-BoilerPlate-D2D
    └── 2. Port the same changes into fullstack-boilerplate/nextjs/
           (same deal)

You update Supabase schema
    │
    ├── If mobile-only table → update apparence-kit-supabase + fullstack-boilerplate
    ├── If web-only table → update Web-BoilerPlate-D2D + fullstack-boilerplate
    └── If shared table → update all three
```

This is manageable because:
- Schema changes are infrequent
- The changes are the same code, just in different locations
- An agent can automate this ("sync mobile changes to dual repo")

---

## Creating the Dual Repo (One-Time Setup)

Run this script on a machine with `gh` CLI and git access to both repos.

### `create_dual_repo.sh`

```bash
#!/bin/bash
set -euo pipefail

GITHUB_ORG="digisurfsome"
DUAL_REPO="fullstack-boilerplate"
MOBILE_REPO="apparence-kit-supabase"
WEB_REPO="Web-BoilerPlate-D2D"

echo "=== Step 1: Create GitHub repo ==="
gh repo create "$GITHUB_ORG/$DUAL_REPO" --private \
  --description "Flutter mobile + Next.js web + Supabase backend — unified boilerplate"

echo "=== Step 2: Clone both source repos ==="
WORK_DIR=$(mktemp -d)
cd "$WORK_DIR"

git clone "https://github.com/$GITHUB_ORG/$MOBILE_REPO.git" mobile
git clone "https://github.com/$GITHUB_ORG/$WEB_REPO.git" web

echo "=== Step 3: Build monorepo structure ==="
mkdir dual && cd dual
git init

# --- Flutter (from mobile boilerplate) ---
# Copy everything except supabase/ (we'll merge that separately)
rsync -a --exclude='.git' --exclude='supabase/' ../mobile/ ./flutter/

# --- Next.js (from web boilerplate) ---
cp -r ../web/nextjs ./nextjs

# --- Supabase (merged from both) ---
# Start with web's supabase (has Stripe schema + edge functions)
cp -r ../web/supabase ./supabase

# Copy mobile migrations (rename to avoid conflicts)
for f in ../mobile/supabase/migrations/*.sql; do
  filename=$(basename "$f")
  # Prefix with "mobile_" if there's a name collision
  if [ -f "./supabase/migrations/$filename" ]; then
    cp "$f" "./supabase/migrations/mobile_$filename"
  else
    cp "$f" "./supabase/migrations/$filename"
  fi
done

# --- CI/CD ---
mkdir -p .github/workflows

# --- Shared config ---
cp -r ../web/.github/workflows/* .github/workflows/ 2>/dev/null || true
cp ../web/.env.example .env.example 2>/dev/null || true

echo "=== Step 4: Create merge migration ==="
cat > supabase/migrations/99999999999999_merge_schemas.sql << 'MIGRATION_EOF'
-- ============================================================
-- MERGE MIGRATION: Resolves conflicts between web and mobile schemas
-- ============================================================

-- 1. Extend users table with mobile columns
ALTER TABLE users ADD COLUMN IF NOT EXISTS email text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS name text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at timestamptz DEFAULT now();
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_update_date timestamptz DEFAULT now();

-- 2. RLS: allow users to insert their own row (mobile needs this)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'Users can insert own data'
  ) THEN
    CREATE POLICY "Users can insert own data" ON users FOR INSERT WITH CHECK (auth.uid() = id);
  END IF;
END $$;

-- 3. Merged handle_new_user trigger (handles both web and mobile signups)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, name, full_name, avatar_url, created_at)
  VALUES (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', ''),
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url',
    now()
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Auto-update last_update_date
CREATE OR REPLACE FUNCTION update_last_update_date()
RETURNS trigger AS $$
BEGIN
  NEW.last_update_date = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'update_users_last_update'
  ) THEN
    CREATE TRIGGER update_users_last_update
      BEFORE UPDATE ON users
      FOR EACH ROW
      EXECUTE FUNCTION update_last_update_date();
  END IF;
END $$;

-- 5. Unified entitlements view (combines Stripe web + RevenueCat mobile)
CREATE OR REPLACE VIEW user_entitlements AS
SELECT user_id, 'stripe' AS source, status::text, current_period_end AS expires_at
FROM subscriptions WHERE status = 'active'
UNION ALL
SELECT user_id, 'revenuecat' AS source, status::text, expiration_date AS expires_at
FROM mobile_subscriptions WHERE status = 'active';
MIGRATION_EOF

echo "=== Step 5: Create unified .env.example ==="
cat > .env.example << 'ENV_EOF'
# ========================================
# Fullstack Boilerplate — Environment Variables
# ========================================

# --- Supabase (SHARED — both apps use the same project) ---
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# --- Stripe (web) ---
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...

# --- RevenueCat (mobile) ---
RC_ANDROID_API_KEY=
RC_IOS_API_KEY=

# --- Firebase (mobile — FCM push notifications only) ---
# Run: cd flutter && flutterfire configure

# --- Analytics ---
NEXT_PUBLIC_POSTHOG_KEY=           # web
# MIXPANEL_TOKEN configured in flutter/lib/environments.dart

# --- Error Reporting ---
# SENTRY_DSN configured in flutter/lib/environments.dart

# --- Email ---
LOOPS_API_KEY=                     # web transactional emails
ENV_EOF

echo "=== Step 6: Create CI workflow ==="
cat > .github/workflows/ci.yml << 'CI_EOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  flutter:
    name: Flutter (mobile)
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./flutter
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze lib test
      - run: flutter test

  nextjs:
    name: Next.js (web)
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./nextjs
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npm run build
CI_EOF

echo "=== Step 7: Create CLAUDE.md for the dual repo ==="
mkdir -p .claude
cat > .claude/CLAUDE.md << 'CLAUDE_EOF'
## Project: Fullstack Boilerplate (Mobile + Web)

Monorepo with Flutter mobile app + Next.js web app sharing a single Supabase backend.

### Structure
- `flutter/` — Flutter mobile app (ApparenceKit architecture: API → Repository → Provider/UI)
- `nextjs/` — Next.js web app (App Router, TypeScript, Tailwind)
- `supabase/` — Shared Supabase backend (migrations, edge functions)

### Key rules
- Both apps share ONE Supabase project. All schema changes go in `supabase/migrations/`.
- Auth is Supabase Auth for both platforms.
- Payments: Stripe (web, `subscriptions` table) + RevenueCat (mobile, `mobile_subscriptions` table).
- Firebase is mobile-only (FCM push notifications).
- Use `user_entitlements` view to check if a user has an active subscription from either platform.

### Flutter conventions
- Package imports: `import 'package:apparence_kit/...'`
- State management: Riverpod
- Routing: go_router
- Models: Freezed
- API classes: see `.claude/rules/supabase_api.mdc` in flutter/

### Next.js conventions
- TypeScript, Tailwind CSS
- App Router (not Pages Router)
- Supabase client via `@supabase/ssr`

### Commands
- Flutter: `cd flutter && flutter pub get && dart run build_runner build --delete-conflicting-outputs`
- Next.js: `cd nextjs && npm ci && npm run build`
- Supabase: `cd supabase && supabase db push && supabase functions deploy`
- Tests: `cd flutter && flutter test` / `cd nextjs && npm test`
CLAUDE_EOF

echo "=== Step 8: Create setup script ==="
cat > setup.sh << 'SETUP_EOF'
#!/bin/bash
set -euo pipefail

echo "========================================"
echo "  Fullstack Boilerplate Setup"
echo "========================================"
echo ""

# Check prerequisites
command -v flutter >/dev/null 2>&1 || { echo "ERROR: flutter not found. Install from https://flutter.dev"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "ERROR: node not found. Install from https://nodejs.org"; exit 1; }
command -v supabase >/dev/null 2>&1 || { echo "ERROR: supabase CLI not found. Install from https://supabase.com/docs/guides/cli"; exit 1; }

echo "[1/4] Setting up Flutter..."
cd flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cd ..

echo "[2/4] Setting up Next.js..."
cd nextjs
npm install
cd ..

echo "[3/4] Starting Supabase (local)..."
cd supabase
supabase start
cd ..

echo "[4/4] Applying migrations..."
cd supabase
supabase db push
cd ..

echo ""
echo "========================================"
echo "  Setup complete!"
echo "========================================"
echo ""
echo "Run the apps:"
echo "  Flutter:  cd flutter && flutter run"
echo "  Next.js:  cd nextjs && npm run dev"
echo "  Supabase: cd supabase && supabase status"
echo ""
echo "Next steps:"
echo "  1. Copy .env.example → .env and fill in your keys"
echo "  2. Create a Supabase project at https://supabase.com"
echo "  3. Run 'supabase link --project-ref YOUR_PROJECT_ID'"
echo "  4. For mobile: run 'cd flutter && flutterfire configure'"
echo "  5. For web: set up Stripe webhook → your Supabase edge function URL"
SETUP_EOF
chmod +x setup.sh

echo "=== Step 9: Remove redundant flutter/supabase/ ==="
# The Flutter repo has its own supabase/ dir — remove it since we merged into root
rm -rf flutter/supabase

echo "=== Step 10: Create README ==="
cat > README.md << 'README_EOF'
# Fullstack Boilerplate

Flutter mobile app + Next.js web app + shared Supabase backend.

## Quick Start

```bash
cp .env.example .env
# Fill in your keys in .env
./setup.sh
```

## Structure

```
├── flutter/    # Mobile app (iOS, Android)
├── nextjs/     # Web app (landing page, dashboard)
├── supabase/   # Shared backend (database, auth, edge functions)
└── setup.sh    # One-command setup
```

## What You Need

- [ ] Supabase project (URL + anon key)
- [ ] Stripe account (for web payments)
- [ ] RevenueCat account (for mobile in-app purchases)
- [ ] Firebase project (for mobile push notifications only)

## Detailed Guide

See [docs/DUAL_BOILERPLATE_MERGE_GUIDE.md](docs/DUAL_BOILERPLATE_MERGE_GUIDE.md) for the full merge documentation, schema details, and payment strategy options.
README_EOF

echo "=== Step 11: Commit and push ==="
git add -A
git commit -m "Initial dual boilerplate: Flutter mobile + Next.js web + shared Supabase"
git remote add origin "https://github.com/$GITHUB_ORG/$DUAL_REPO.git"
git branch -M main
git push -u origin main

echo ""
echo "=== DONE ==="
echo "Repo created at: https://github.com/$GITHUB_ORG/$DUAL_REPO"
echo ""
echo "To use as a template for new apps:"
echo "  gh repo create my-new-app --template $GITHUB_ORG/$DUAL_REPO --private"
```

---

## SaaS Clone Logic (All Three Scenarios)

Your SaaS backend runs one of these depending on user selection:

### Mobile only
```bash
gh repo create "$USER_ORG/$APP_NAME" --template digisurfsome/apparence-kit-supabase --private
```

### Web only
```bash
gh repo create "$USER_ORG/$APP_NAME" --template digisurfsome/Web-BoilerPlate-D2D --private
```

### Dual (mobile + web)
```bash
gh repo create "$USER_ORG/$APP_NAME" --template digisurfsome/fullstack-boilerplate --private
```

All three are the same operation: `gh repo create --template`. No merge logic, no scripts, no risk.

---

## Schema Reference: What's Shared, What's Not

### Shared tables (both apps read/write)
| Table | Purpose |
|-------|---------|
| `users` | User profile (merged columns from both) |

### Web-only tables
| Table | Purpose |
|-------|---------|
| `customers` | Stripe customer ID mapping |
| `products` | Stripe products catalog |
| `prices` | Stripe pricing |
| `subscriptions` | Stripe subscriptions |
| `checkout_sessions` | Stripe checkout tracking |

### Mobile-only tables
| Table | Purpose |
|-------|---------|
| `mobile_subscriptions` | RevenueCat in-app purchases |
| `notifications` | Push notification history |
| `devices` | FCM device tokens |
| `feature_requests` | Admin feature ideas |
| `feature_votes` | User votes on features |
| `user_feature_requests` | User-submitted ideas |
| `user_infos` | Onboarding key-value data |

### Unified views
| View | Purpose |
|------|---------|
| `user_entitlements` | Active subscriptions from either Stripe or RevenueCat |

---

## Schema Conflict Resolution (Reference)

### `users` table — MERGED

Both boilerplates create a `users` table. The dual repo keeps all columns:

```sql
create table users (
  id uuid references auth.users not null primary key,
  email text,                     -- from mobile
  name text,                      -- from mobile
  full_name text,                 -- from web
  avatar_url text,                -- from both (web: avatar_url, mobile: avatar)
  billing_address jsonb,          -- from web (Stripe)
  payment_method jsonb,           -- from web (Stripe)
  created_at timestamptz,         -- from mobile
  last_update_date timestamptz    -- from mobile
);
```

### `handle_new_user()` trigger — MERGED

Single trigger populates all columns regardless of signup source:

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, name, full_name, avatar_url, created_at)
  VALUES (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', ''),
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url',
    now()
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### `subscriptions` — NO CONFLICT (renamed)

- Web subscriptions stay as `subscriptions` (Stripe)
- Mobile subscriptions become `mobile_subscriptions` (RevenueCat)
- `user_entitlements` view unifies both

---

## Payment Strategy

**Recommended: Stripe (web) + RevenueCat (mobile)**

- Web users pay via Stripe Checkout → `subscriptions` table
- Mobile users pay via App Store/Play Store → RevenueCat → `mobile_subscriptions` table
- Both apps check `user_entitlements` view to see if user has active subscription
- User who subscribes on one platform is recognized on the other

```sql
CREATE OR REPLACE VIEW user_entitlements AS
SELECT user_id, 'stripe' AS source, status::text, current_period_end AS expires_at
FROM subscriptions WHERE status = 'active'
UNION ALL
SELECT user_id, 'revenuecat' AS source, status::text, expiration_date AS expires_at
FROM mobile_subscriptions WHERE status = 'active';
```

---

## Agent Checklist: After Cloning Dual Repo for New App

An AI agent setting up a new app from the dual boilerplate should:

1. **Rename the app**
   - Flutter: update `pubspec.yaml` name, `android/app/build.gradle` applicationId, iOS bundle ID
   - Next.js: update `package.json` name, page titles
   - Supabase: update `config.toml` project_id

2. **Create external services**
   - Supabase project → get URL + keys
   - Firebase project → `flutterfire configure`
   - Stripe account → get keys, create webhook
   - RevenueCat → connect to App Store / Play Store

3. **Configure environment**
   - Fill `.env` from `.env.example`
   - Flutter: update `lib/environments.dart`
   - Next.js: update `.env.local`

4. **Deploy backend**
   - `supabase link --project-ref <ID>`
   - `supabase db push`
   - `supabase functions deploy`

5. **Verify**
   - `cd flutter && flutter run` — app launches, auth works
   - `cd nextjs && npm run dev` — landing page loads, Stripe checkout works
   - Sign up on web → verify user appears in Supabase → sign in on mobile → same user
