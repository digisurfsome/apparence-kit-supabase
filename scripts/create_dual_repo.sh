#!/bin/bash
# ============================================================================
# CREATE DUAL REPO: Merges mobile + web boilerplates into fullstack-boilerplate
# ============================================================================
# Prerequisites:
#   - git, gh (GitHub CLI) installed and authenticated
#   - Access to both source repos
#
# Usage:
#   chmod +x create_dual_repo.sh
#   ./create_dual_repo.sh
# ============================================================================
set -euo pipefail

# --- Configuration ---
GITHUB_ORG="digisurfsome"
DUAL_REPO="fullstack-boilerplate"
MOBILE_REPO="apparence-kit-supabase"
MOBILE_BRANCH="claude/prepare-reusable-boilerplate-lb6a9"
WEB_REPO="Web-BoilerPlate-D2D"
WORK_DIR=$(mktemp -d)

echo ""
echo "============================================"
echo "  Creating Fullstack Boilerplate"
echo "============================================"
echo ""
echo "  Mobile source: $GITHUB_ORG/$MOBILE_REPO"
echo "  Web source:    $GITHUB_ORG/$WEB_REPO"
echo "  Target:        $GITHUB_ORG/$DUAL_REPO"
echo "  Work dir:      $WORK_DIR"
echo ""

# --- Preflight checks ---
echo "[0/10] Checking prerequisites..."
command -v git >/dev/null 2>&1 || { echo "ERROR: git not found"; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "ERROR: gh CLI not found. Install from https://cli.github.com"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "ERROR: gh not authenticated. Run: gh auth login"; exit 1; }
echo "  All checks passed."

# ============================================================================
# STEP 1: Clone both source repos
# ============================================================================
echo ""
echo "[1/10] Cloning source repos..."
cd "$WORK_DIR"
git clone -b "$MOBILE_BRANCH" "https://github.com/$GITHUB_ORG/$MOBILE_REPO.git" mobile
git clone "https://github.com/$GITHUB_ORG/$WEB_REPO.git" web
echo "  Done."

# ============================================================================
# STEP 2: Create monorepo structure
# ============================================================================
echo ""
echo "[2/10] Building monorepo structure..."
mkdir -p dual
cd dual
git init

# --- flutter/ from mobile boilerplate (everything except supabase/, .git/, .github/) ---
cp -r ../mobile ./flutter
rm -rf ./flutter/.git ./flutter/supabase ./flutter/.github

# --- nextjs/ from web boilerplate ---
cp -r ../web/nextjs ./nextjs

# --- supabase/ starts with web's (has Stripe schema + edge functions) ---
cp -r ../web/supabase ./supabase

echo "  Done."

# ============================================================================
# STEP 3: Merge Supabase migrations
# ============================================================================
echo ""
echo "[3/10] Merging Supabase migrations..."

# The web boilerplate has: 20240717231009_init.sql (Stripe/users/products/prices/subscriptions)
# The mobile boilerplate has: 20260320000000_initial_schema.sql (users/subscriptions/notifications/etc)
#
# Strategy:
#   1. Keep web migration as-is (runs first, creates users + Stripe tables)
#   2. Add mobile-specific tables as a SECOND migration (skip users + subscriptions since web created them)
#   3. Add a THIRD migration that merges the conflicts (adds mobile columns to users, renames subscriptions)

# --- Extract mobile-only tables (everything except users and subscriptions which conflict) ---
cat > supabase/migrations/20260320000001_mobile_tables.sql << 'MOBILE_SQL'
-- ============================================================================
-- MOBILE-SPECIFIC TABLES (from apparence-kit-supabase)
-- Tables that don't conflict with the web boilerplate schema.
-- The web migration (20240717231009_init.sql) already created: users, subscriptions
-- ============================================================================

-- ============================================================================
-- MOBILE SUBSCRIPTIONS TABLE (RevenueCat)
-- Renamed from "subscriptions" to avoid conflict with Stripe subscriptions.
-- Tracks in-app purchase state synced from RevenueCat.
-- ============================================================================
CREATE TABLE IF NOT EXISTS mobile_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  offer_id TEXT,
  product_id TEXT NOT NULL,
  creation_date TIMESTAMPTZ DEFAULT NOW(),
  last_activity TIMESTAMPTZ DEFAULT NOW(),
  expiration_date TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'ACTIVE'
    CHECK (status IN ('ACTIVE', 'PAUSED', 'EXPIRED', 'LIFETIME', 'CANCELLED'))
);

CREATE INDEX idx_mobile_subscriptions_user_id ON mobile_subscriptions(user_id);
CREATE INDEX idx_mobile_subscriptions_status ON mobile_subscriptions(status);

ALTER TABLE mobile_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own mobile subscriptions"
  ON mobile_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own mobile subscriptions"
  ON mobile_subscriptions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own mobile subscriptions"
  ON mobile_subscriptions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- NOTIFICATIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  creation_date TIMESTAMPTZ DEFAULT NOW(),
  seen_date TIMESTAMPTZ,
  type TEXT DEFAULT 'OTHER'
    CHECK (type IN ('WELCOME', 'OTHER', 'LINK')),
  data JSONB
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_creation_date ON notifications(creation_date DESC);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- FEATURE_REQUESTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS feature_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title JSONB NOT NULL DEFAULT '{}',
  description JSONB NOT NULL DEFAULT '{}',
  votes INTEGER NOT NULL DEFAULT 0,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  creation_date TIMESTAMPTZ DEFAULT NOW(),
  last_update_date TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_feature_requests_active ON feature_requests(active);
CREATE INDEX idx_feature_requests_votes ON feature_requests(votes DESC);

ALTER TABLE feature_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read feature requests"
  ON feature_requests FOR SELECT
  USING (auth.role() = 'authenticated');

-- ============================================================================
-- FEATURE_VOTES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS feature_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  feature_id UUID NOT NULL REFERENCES feature_requests(id) ON DELETE CASCADE,
  creation_date TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, feature_id)
);

CREATE INDEX idx_feature_votes_user_id ON feature_votes(user_id);
CREATE INDEX idx_feature_votes_feature_id ON feature_votes(feature_id);

ALTER TABLE feature_votes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own votes"
  ON feature_votes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own votes"
  ON feature_votes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own votes"
  ON feature_votes FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- USER_FEATURE_REQUESTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_feature_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  creation_date TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_feature_requests_user_id ON user_feature_requests(user_id);

ALTER TABLE user_feature_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own feature requests"
  ON user_feature_requests FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own feature requests"
  ON user_feature_requests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- USER_INFOS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_infos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  UNIQUE(user_id, key)
);

CREATE INDEX idx_user_infos_user_id ON user_infos(user_id);
CREATE INDEX idx_user_infos_key ON user_infos(user_id, key);

ALTER TABLE user_infos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own infos"
  ON user_infos FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own infos"
  ON user_infos FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own infos"
  ON user_infos FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- DEVICES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  installation_id TEXT NOT NULL,
  token TEXT NOT NULL,
  operating_system TEXT NOT NULL CHECK (operating_system IN ('ios', 'android')),
  extra_data JSONB,
  creation_date TIMESTAMPTZ DEFAULT NOW(),
  last_update_date TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, installation_id)
);

CREATE INDEX idx_devices_user_id ON devices(user_id);
CREATE INDEX idx_devices_token ON devices(token);

ALTER TABLE devices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own devices"
  ON devices FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own devices"
  ON devices FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own devices"
  ON devices FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own devices"
  ON devices FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- STORAGE: Avatar bucket
-- ============================================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Users can upload their own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update their own avatar"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Anyone can read avatars"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');
MOBILE_SQL

echo "  Created mobile tables migration."

# ============================================================================
# STEP 4: Create merge migration (resolves conflicts)
# ============================================================================
echo ""
echo "[4/10] Creating merge migration..."

cat > supabase/migrations/20260320000002_merge_schemas.sql << 'MERGE_SQL'
-- ============================================================================
-- MERGE MIGRATION: Unifies web + mobile user schemas
-- ============================================================================
-- The web migration created users with: id, full_name, avatar_url, billing_address, payment_method
-- The mobile app needs: email, name, avatar_path, onboarded, locale, creation_date, last_update_date
-- This migration adds the missing mobile columns and merges the triggers.
-- ============================================================================

-- 1. Add mobile-needed columns to the web users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_path TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS onboarded BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS locale TEXT DEFAULT 'en';
ALTER TABLE users ADD COLUMN IF NOT EXISTS creation_date TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_update_date TIMESTAMPTZ DEFAULT NOW();

-- 2. Create index on email (mobile needs this)
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- 3. Add RLS policies the mobile app needs (web only had SELECT + UPDATE)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'Users can insert their own profile') THEN
    CREATE POLICY "Users can insert their own profile" ON users FOR INSERT WITH CHECK (auth.uid() = id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'Users can delete their own profile') THEN
    CREATE POLICY "Users can delete their own profile" ON users FOR DELETE USING (auth.uid() = id);
  END IF;
END $$;

-- 4. Merged handle_new_user trigger (handles signups from both web and mobile)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name, full_name, avatar_url, creation_date, last_update_date)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'full_name', ''),
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url',
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Auto-update last_update_date on user changes
CREATE OR REPLACE FUNCTION public.update_last_update_date()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_update_date = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'users_update_timestamp') THEN
    CREATE TRIGGER users_update_timestamp
      BEFORE UPDATE ON users
      FOR EACH ROW
      EXECUTE FUNCTION public.update_last_update_date();
  END IF;
END $$;

-- 6. Unified entitlements view — check subscription from either platform
CREATE OR REPLACE VIEW user_entitlements AS
SELECT user_id, 'stripe' AS source, status::text AS status, current_period_end AS expires_at
FROM subscriptions WHERE status = 'active'
UNION ALL
SELECT user_id, 'revenuecat' AS source, status AS status, expiration_date AS expires_at
FROM mobile_subscriptions WHERE status = 'ACTIVE';
MERGE_SQL

echo "  Created merge migration."

# ============================================================================
# STEP 5: Update Flutter app to reference mobile_subscriptions
# ============================================================================
echo ""
echo "[5/10] Updating Flutter subscription references..."

# The Flutter app's Supabase API calls reference "subscriptions" table.
# In the dual repo, mobile subscriptions are in "mobile_subscriptions".
# Find and replace in the Flutter code.
if command -v grep >/dev/null 2>&1; then
  # Find files that reference the subscriptions table
  DART_FILES=$(grep -rl "from('subscriptions')" flutter/lib/ 2>/dev/null || true)
  if [ -n "$DART_FILES" ]; then
    for f in $DART_FILES; do
      sed -i "s/from('subscriptions')/from('mobile_subscriptions')/g" "$f"
      echo "  Updated: $f"
    done
  else
    echo "  No subscription table references found in Flutter code (will need manual update)."
  fi
fi

# ============================================================================
# STEP 6: Create unified .env.example
# ============================================================================
echo ""
echo "[6/10] Creating unified .env.example..."

cat > .env.example << 'ENV_EOF'
# ========================================
# Fullstack Boilerplate — Environment Vars
# ========================================

# --- Supabase (SHARED — both mobile + web use same project) ---
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# --- Stripe (web payments) ---
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...

# --- RevenueCat (mobile in-app purchases) ---
RC_ANDROID_API_KEY=
RC_IOS_API_KEY=

# --- Firebase (mobile push notifications only) ---
# Run: cd flutter && flutterfire configure

# --- Analytics ---
NEXT_PUBLIC_POSTHOG_KEY=
NEXT_PUBLIC_POSTHOG_HOST=https://us.i.posthog.com

# --- Email (web) ---
LOOPS_API_KEY=
ENV_EOF

echo "  Done."

# ============================================================================
# STEP 7: Create CI workflow
# ============================================================================
echo ""
echo "[7/10] Creating CI workflow..."

mkdir -p .github/workflows

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

echo "  Done."

# ============================================================================
# STEP 8: Create CLAUDE.md for AI agents
# ============================================================================
echo ""
echo "[8/10] Creating .claude/CLAUDE.md..."

mkdir -p .claude

cat > .claude/CLAUDE.md << 'CLAUDE_EOF'
## Project: Fullstack Boilerplate (Mobile + Web)

Monorepo: Flutter mobile app + Next.js web app + shared Supabase backend.

### Structure
- `flutter/` — Flutter mobile app (ApparenceKit: API → Repository → Provider/UI, Riverpod, go_router, Freezed)
- `nextjs/` — Next.js web app (App Router, TypeScript, Tailwind CSS, Radix UI)
- `supabase/` — Shared backend (PostgreSQL migrations, Deno edge functions)

### Database
- Both apps share ONE Supabase project.
- All schema changes → new migration in `supabase/migrations/`.
- `users` table has columns for both platforms (merged).
- `subscriptions` = Stripe (web). `mobile_subscriptions` = RevenueCat (mobile).
- `user_entitlements` view unifies both subscription systems.

### Auth
- Supabase Auth for both platforms.
- Web: email/password + OAuth (Google, GitHub).
- Mobile: email/password + Apple Sign-In.

### Payments
- Web: Stripe Checkout → `subscriptions` table (synced via stripe_webhook edge function).
- Mobile: RevenueCat → `mobile_subscriptions` table (synced from app).
- Check entitlements via `user_entitlements` view.

### Edge Functions (Deno)
- `get_stripe_url/` — generates Stripe checkout/portal URLs
- `on_user_modify/` — triggers on user changes (analytics, email)
- `stripe_webhook/` — syncs Stripe events to DB

### Key Commands
- Flutter: `cd flutter && flutter pub get && dart run build_runner build --delete-conflicting-outputs`
- Next.js: `cd nextjs && npm ci`
- Supabase local: `cd supabase && supabase start`
- Deploy DB: `cd supabase && supabase db push`
- Deploy functions: `cd supabase && supabase functions deploy`
- Flutter tests: `cd flutter && flutter test`
- Flutter analysis: `cd flutter && flutter analyze lib test`

### Coding Standards
- Flutter: package imports (`import 'package:apparence_kit/...'`), English only
- Next.js: TypeScript strict mode, Tailwind for styling
- SQL: Use migrations, never modify DB directly
CLAUDE_EOF

echo "  Done."

# ============================================================================
# STEP 9: Create setup script + README
# ============================================================================
echo ""
echo "[9/10] Creating setup.sh and README.md..."

cat > setup.sh << 'SETUP_EOF'
#!/bin/bash
set -euo pipefail

echo "========================================"
echo "  Fullstack Boilerplate Setup"
echo "========================================"

command -v flutter >/dev/null 2>&1 || { echo "ERROR: flutter not found"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "ERROR: node not found"; exit 1; }
command -v supabase >/dev/null 2>&1 || { echo "ERROR: supabase CLI not found"; exit 1; }

echo ""
echo "[1/4] Flutter..."
cd flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cd ..

echo "[2/4] Next.js..."
cd nextjs
npm install
cd ..

echo "[3/4] Supabase local..."
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
echo "  Flutter:   cd flutter && flutter run"
echo "  Next.js:   cd nextjs && npm run dev"
echo "  Supabase:  cd supabase && supabase status"
echo ""
echo "  Next: copy .env.example → .env and fill in your keys"
SETUP_EOF
chmod +x setup.sh

cat > README.md << 'README_EOF'
# Fullstack Boilerplate

Flutter mobile app + Next.js web app + shared Supabase backend.

## Quick Start

```bash
cp .env.example .env    # Fill in your keys
./setup.sh              # Installs deps, starts Supabase, applies migrations
```

## Structure

| Directory | What | Tech |
|-----------|------|------|
| `flutter/` | Mobile app (iOS, Android) | Flutter, Riverpod, go_router |
| `nextjs/` | Web app + landing page | Next.js, TypeScript, Tailwind |
| `supabase/` | Shared backend | PostgreSQL, Deno edge functions |

## What You Need

| Service | Purpose | Where to get it |
|---------|---------|-----------------|
| Supabase | Auth, DB, edge functions | https://supabase.com |
| Stripe | Web payments | https://stripe.com |
| RevenueCat | Mobile in-app purchases | https://revenuecat.com |
| Firebase | Mobile push notifications | https://console.firebase.google.com |

## Database Schema

Both apps share one Supabase project with these tables:

**Shared:** `users`
**Web (Stripe):** `customers`, `products`, `prices`, `subscriptions`, `checkout_sessions`
**Mobile (RevenueCat):** `mobile_subscriptions`, `notifications`, `devices`, `feature_requests`, `feature_votes`, `user_feature_requests`, `user_infos`
**Unified:** `user_entitlements` (view combining both subscription systems)

## Payments

- **Web:** Stripe Checkout → webhooks sync to `subscriptions` table
- **Mobile:** RevenueCat → syncs to `mobile_subscriptions` table
- **Both:** Query `user_entitlements` view to check if user has active sub

## Setup Checklist

- [ ] Create Supabase project → get URL + anon key
- [ ] `supabase link --project-ref <ID>` then `supabase db push`
- [ ] `supabase functions deploy`
- [ ] Create Stripe account → set up webhook to edge function URL
- [ ] Set up RevenueCat → connect App Store / Play Store
- [ ] `cd flutter && flutterfire configure` (Firebase for push only)
- [ ] Fill `.env` with all keys
- [ ] Update app name, bundle ID, metadata in both apps
- [ ] Test: sign up on web → same user appears on mobile
README_EOF

echo "  Done."

# ============================================================================
# STEP 10: Remove redundant files, commit, push
# ============================================================================
echo ""
echo "[10/10] Committing and pushing..."

# Remove flutter's standalone supabase dir (merged into root)
rm -rf flutter/supabase

# Remove flutter's standalone .github (using monorepo CI)
rm -rf flutter/.github

# Remove any .claude from flutter (monorepo has its own)
rm -rf flutter/.claude

# Add gitignore
cat > .gitignore << 'GI_EOF'
# Dependencies
flutter/.dart_tool/
flutter/.packages
flutter/build/
nextjs/node_modules/
nextjs/.next/

# Environment
.env
.env.local
.env.*.local
nextjs/.env.local

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Generated
flutter/**/*.g.dart
flutter/**/*.freezed.dart
GI_EOF

git add -A
git commit -m "Initial fullstack boilerplate: Flutter mobile + Next.js web + shared Supabase

Merged from:
- $GITHUB_ORG/$MOBILE_REPO (Flutter mobile app)
- $GITHUB_ORG/$WEB_REPO (Next.js web app)

Schema merges:
- users table: combined web (Stripe) + mobile columns
- subscriptions: Stripe (web) + mobile_subscriptions (RevenueCat)
- user_entitlements view: unified subscription check
- handle_new_user trigger: handles both signup flows"

git remote add origin "https://github.com/$GITHUB_ORG/$DUAL_REPO.git"
git branch -M main
git push -u origin main

echo ""
echo "============================================"
echo "  SUCCESS!"
echo "============================================"
echo ""
echo "  Repo: https://github.com/$GITHUB_ORG/$DUAL_REPO"
echo ""
echo "  Next steps:"
echo "    1. Go to repo Settings → check 'Template repository'"
echo "    2. Clone it and run ./setup.sh"
echo ""

# Cleanup
rm -rf "$WORK_DIR"
