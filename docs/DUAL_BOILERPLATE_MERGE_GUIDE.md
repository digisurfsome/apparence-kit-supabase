# Dual Boilerplate Merge Guide

## Combining apparence-kit-supabase (Mobile) + Web-BoilerPlate-D2D (Web)

This guide explains how to combine both boilerplates into a single monorepo that gives you:
- **Flutter mobile app** (ApparenceKit — auth, subscriptions, notifications, onboarding, feedback, settings)
- **Next.js web app** (landing page, dashboard, Stripe checkout)
- **Shared Supabase backend** (merged schema, edge functions)
- **Firebase** (push notifications only — required for iOS FCM)

---

## Architecture Overview

```
your-app/
├── flutter/                 # ApparenceKit mobile app (from apparence-kit-supabase)
│   ├── lib/
│   │   ├── core/
│   │   ├── modules/
│   │   ├── i18n/
│   │   └── main.dart
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── pubspec.yaml
│   └── ...
├── nextjs/                  # Web app + landing page (from Web-BoilerPlate-D2D)
│   ├── app/
│   ├── components/
│   ├── lib/
│   ├── styles/
│   ├── package.json
│   └── ...
├── supabase/                # Shared backend (MERGED from both)
│   ├── migrations/
│   │   ├── 20240717231009_web_init.sql        # Web schema (Stripe)
│   │   └── 20260320000000_mobile_init.sql     # Mobile schema (ApparenceKit)
│   │   └── 20260320000001_merge_schemas.sql   # Merge conflict resolution
│   ├── functions/
│   │   ├── get_stripe_url/   # From web boilerplate
│   │   ├── on_user_modify/   # From web boilerplate
│   │   ├── stripe_webhook/   # From web boilerplate
│   │   └── _shared/
│   ├── config.toml
│   └── seed.sql
├── .github/workflows/       # CI for both apps
├── .claude/                 # AI agent instructions
├── docs/                    # Shared documentation
├── .env.example             # All env vars for both apps
└── README.md
```

---

## Schema Conflicts & Resolution

### 1. `users` table — MUST MERGE

**Web boilerplate columns:**
```sql
id uuid (PK, refs auth.users)
full_name text
avatar_url text
billing_address jsonb      -- Stripe billing
payment_method jsonb       -- Stripe payment
```

**Mobile boilerplate columns:**
```sql
id uuid (PK, refs auth.users)
email text
name text
avatar text
created_at timestamptz
last_update_date timestamptz
```

**Merged `users` table:**
```sql
create table users (
  id uuid references auth.users not null primary key,
  email text,
  name text,                    -- mobile uses "name", web uses "full_name" — pick one
  full_name text,               -- OR keep both and sync via trigger
  avatar_url text,
  billing_address jsonb,        -- from web (Stripe)
  payment_method jsonb,         -- from web (Stripe)
  created_at timestamptz default now(),
  last_update_date timestamptz default now()
);
```

### 2. `subscriptions` table — KEEP BOTH (different purposes)

The web boilerplate uses **Stripe** (subscription IDs like `sub_1234`, linked to prices/products).
The mobile boilerplate uses **RevenueCat** (SKU-based, app store purchases).

These are fundamentally different payment systems. **Keep both tables:**

| Table | Source | Purpose |
|-------|--------|---------|
| `subscriptions` | Web (Stripe) | Web payments, Stripe-synced via webhooks |
| `mobile_subscriptions` | Mobile (RevenueCat) | In-app purchases, RevenueCat-synced |

OR rename the web one to `stripe_subscriptions` for clarity.

### 3. `handle_new_user()` trigger — MUST MERGE

**Web version:**
```sql
insert into public.users (id, full_name, avatar_url)
values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
```

**Mobile version:**
```sql
insert into public.users (id, email, name)
values (new.id, new.email, coalesce(new.raw_user_meta_data->>'name', ''));
```

**Merged trigger:**
```sql
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, email, name, full_name, avatar_url, created_at)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', ''),
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url',
    now()
  );
  return new;
end;
$$ language plpgsql security definer;
```

### 4. Tables that DON'T conflict (just add both)

**From web boilerplate only:**
- `customers` (Stripe customer ID mapping)
- `products` (Stripe products)
- `prices` (Stripe prices)
- `checkout_sessions` (Stripe checkout)

**From mobile boilerplate only:**
- `notifications` (push notification history)
- `feature_requests` (admin feature requests)
- `feature_votes` (user votes)
- `user_feature_requests` (user-submitted ideas)
- `user_infos` (onboarding key-value data)
- `devices` (FCM device tokens)

---

## Step-by-Step Merge Process

### Phase 1: Create the monorepo

```bash
# Create new repo
mkdir my-app && cd my-app
git init

# Pull in mobile boilerplate as flutter/
git remote add mobile https://github.com/digisurfsome/apparence-kit-supabase.git
git fetch mobile main
git checkout -b main
# Copy mobile files into flutter/ subdirectory
git read-tree --prefix=flutter/ -u mobile/main

# Pull in web boilerplate
git remote add web https://github.com/digisurfsome/Web-BoilerPlate-D2D.git
git fetch web main
# Copy nextjs/ and supabase/ from web boilerplate
git read-tree --prefix=nextjs-tmp/ -u web/main
# Then manually move: nextjs-tmp/nextjs/ → nextjs/, nextjs-tmp/supabase/ → supabase/
```

**Alternative (simpler):**
```bash
mkdir my-app && cd my-app
git init

# Clone both as subdirectories (not git submodules)
git clone https://github.com/digisurfsome/apparence-kit-supabase.git flutter
rm -rf flutter/.git

git clone https://github.com/digisurfsome/Web-BoilerPlate-D2D.git web-tmp
cp -r web-tmp/nextjs ./nextjs
cp -r web-tmp/supabase ./supabase
cp -r web-tmp/.github ./.github
rm -rf web-tmp

git add -A && git commit -m "Initial monorepo: mobile + web boilerplates"
```

### Phase 2: Merge Supabase schemas

1. Keep the web migration as-is: `supabase/migrations/20240717231009_init.sql`
2. Move the mobile migration: copy `flutter/supabase/migrations/20260320000000_initial_schema.sql` → `supabase/migrations/20260320000000_mobile_schema.sql`
3. Create a merge migration: `supabase/migrations/20260320000001_merge_schemas.sql`

```sql
-- 20260320000001_merge_schemas.sql
-- Resolves conflicts between web and mobile schemas

-- 1. Add mobile columns to the users table (web migration created it first)
ALTER TABLE users ADD COLUMN IF NOT EXISTS email text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS name text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at timestamptz DEFAULT now();
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_update_date timestamptz DEFAULT now();

-- 2. Add missing RLS policies for mobile
CREATE POLICY "Users can insert own data" ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- 3. Update handle_new_user to populate all columns
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

-- 4. Rename mobile subscriptions table to avoid conflict
-- (The mobile migration should create mobile_subscriptions instead of subscriptions)
-- If already created as "subscriptions", rename:
-- ALTER TABLE subscriptions RENAME TO mobile_subscriptions;

-- 5. Update last_update_date trigger
CREATE OR REPLACE FUNCTION update_last_update_date()
RETURNS trigger AS $$
BEGIN
  NEW.last_update_date = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_last_update
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_last_update_date();
```

### Phase 3: Merge environment variables

Create a unified `.env.example`:

```bash
# === Supabase (shared) ===
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key  # server-side only

# === Stripe (web only) ===
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...

# === Firebase (mobile only — for push notifications) ===
# Generated by flutterfire configure, not stored in .env

# === RevenueCat (mobile only — in-app purchases) ===
RC_ANDROID_API_KEY=...
RC_IOS_API_KEY=...

# === Analytics ===
NEXT_PUBLIC_POSTHOG_KEY=...       # web
MIXPANEL_TOKEN=...                 # mobile

# === Error Reporting ===
SENTRY_DSN=...                     # mobile

# === Email (web only) ===
LOOPS_API_KEY=...
```

### Phase 4: Merge CI/CD

Create `.github/workflows/` with separate jobs:

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  flutter:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./flutter
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze lib test
      - run: flutter test

  nextjs:
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
```

### Phase 5: Update Flutter app to use shared Supabase

In the Flutter app, update the Supabase URL to point to the same project:
- `flutter/lib/environments.dart` — `BACKEND_URL` points to shared Supabase project
- The Flutter app's `supabase/` directory can be deleted (migrations live at root `/supabase/`)

### Phase 6: Configure shared Supabase project

```bash
cd supabase
supabase link --project-ref YOUR_PROJECT_ID
supabase db push   # applies all migrations in order
supabase functions deploy   # deploys edge functions
```

---

## Payment Strategy Decision

You need to decide how payments work across platforms:

### Option A: Stripe everywhere (simpler)
- Web: Stripe Checkout (already set up)
- Mobile: Stripe in-app (replace RevenueCat with Stripe)
- Single subscription table, single webhook
- **Pro:** One payment system, unified billing
- **Con:** Apple/Google take 30% cut on mobile app store payments; Stripe mobile requires more setup

### Option B: Stripe (web) + RevenueCat (mobile) — dual system
- Web: Stripe Checkout
- Mobile: RevenueCat (handles App Store / Play Store billing)
- Two subscription tables (`subscriptions` for Stripe, `mobile_subscriptions` for RevenueCat)
- Need a `user_entitlements` view that unifies both
- **Pro:** Native app store experience on mobile, avoids app store payment policy issues
- **Con:** Two systems to maintain, need to sync entitlements

### Option C: RevenueCat everywhere
- RevenueCat supports web via Stripe integration
- Single entitlement system
- **Pro:** One system, handles all platforms
- **Con:** RevenueCat takes a cut, less control over web checkout UX

**Recommendation:** Option B for most apps. Keep Stripe for web (better UX, lower fees) and RevenueCat for mobile (required for App Store compliance). Create a unified entitlements view:

```sql
CREATE VIEW user_entitlements AS
SELECT user_id, 'stripe' as source, status, current_period_end
FROM subscriptions WHERE status = 'active'
UNION ALL
SELECT user_id, 'revenuecat' as source, status, expiration_date
FROM mobile_subscriptions WHERE status = 'active';
```

---

## Creating the Third Repo

To create the combined monorepo on GitHub:

```bash
# 1. Create repo on GitHub
gh repo create digisurfsome/fullstack-boilerplate --private --description "Flutter mobile + Next.js web + Supabase backend"

# 2. Clone and set up
git clone https://github.com/digisurfsome/fullstack-boilerplate.git
cd fullstack-boilerplate

# 3. Copy in both boilerplates (using the simple method above)
# ... follow Phase 1 steps ...

# 4. Push
git push -u origin main
```

### Automated Setup Script

Create a `setup.sh` in the third repo:

```bash
#!/bin/bash
set -e

echo "=== Fullstack Boilerplate Setup ==="

# Flutter
echo "Setting up Flutter..."
cd flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cd ..

# Next.js
echo "Setting up Next.js..."
cd nextjs
npm install
cd ..

# Supabase
echo "Setting up Supabase..."
cd supabase
supabase start   # local dev
supabase db push # apply migrations
supabase functions serve  # start edge functions locally
cd ..

echo "=== Done! ==="
echo "Flutter:  cd flutter && flutter run --dart-define=ENV=dev --dart-define=BACKEND_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_TOKEN=<local-anon-key>"
echo "Next.js:  cd nextjs && npm run dev"
echo "Supabase: cd supabase && supabase status"
```

---

## What Each Agent Needs to Know

When an AI agent works on the combined repo, it should understand:

1. **Flutter code** lives in `flutter/` — uses ApparenceKit architecture (API → Repo → Provider)
2. **Next.js code** lives in `nextjs/` — uses App Router, TypeScript, Tailwind
3. **Supabase** lives in `supabase/` — shared by both apps, single source of truth
4. **Payments** are split: Stripe (web) + RevenueCat (mobile) unless you chose otherwise
5. **Firebase** is mobile-only, exclusively for push notifications (FCM)
6. **Auth** is Supabase Auth — shared across web and mobile
7. **Database changes** require a new migration in `supabase/migrations/`
8. **Edge functions** are Deno/TypeScript in `supabase/functions/`

---

## Checklist for New App from Combined Boilerplate

- [ ] Create new GitHub repo from this template
- [ ] Create Supabase project → get URL + anon key
- [ ] Create Firebase project → `flutterfire configure` (for mobile FCM only)
- [ ] Create Stripe account → get keys, set up webhooks
- [ ] Set up RevenueCat → connect to App Store / Play Store
- [ ] Replace all placeholder values (see README.md "What You Need to Replace")
- [ ] Run `supabase db push` to apply all migrations
- [ ] Deploy edge functions: `supabase functions deploy`
- [ ] Set up PostHog / Mixpanel / Sentry / Loops.so as needed
- [ ] Update app name, bundle ID, Facebook App ID
- [ ] Update terms/privacy URLs
- [ ] Run both apps locally to verify
