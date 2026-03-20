-- ApparenceKit Supabase Schema
-- Initial migration: creates all tables, indexes, and RLS policies
-- Run with: supabase db push

-- ============================================================================
-- USERS TABLE
-- Stores user profile data. The id references auth.users(id) from Supabase Auth.
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  email TEXT,
  avatar_path TEXT,
  onboarded BOOLEAN DEFAULT FALSE,
  locale TEXT DEFAULT 'en',
  creation_date TIMESTAMPTZ DEFAULT NOW(),
  last_update_date TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can delete their own profile"
  ON users FOR DELETE
  USING (auth.uid() = id);

-- ============================================================================
-- SUBSCRIPTIONS TABLE
-- Tracks user subscription state (synced from RevenueCat or managed manually).
-- ============================================================================
CREATE TABLE IF NOT EXISTS subscriptions (
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

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own subscriptions"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own subscriptions"
  ON subscriptions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own subscriptions"
  ON subscriptions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- NOTIFICATIONS TABLE
-- Stores notification history per user.
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
-- Admin-created feature requests that users can vote on.
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

-- All authenticated users can read active feature requests
CREATE POLICY "Authenticated users can read feature requests"
  ON feature_requests FOR SELECT
  USING (auth.role() = 'authenticated');

-- ============================================================================
-- FEATURE_VOTES TABLE
-- Tracks which users voted on which feature requests.
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
-- Feature requests submitted by users (not admin-created).
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
-- Key-value store for user metadata (onboarding answers, preferences).
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
-- Stores device/push notification tokens for each user.
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
-- HELPER: Auto-create user profile on auth signup
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, creation_date, last_update_date)
  VALUES (NEW.id, NEW.email, NOW(), NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- HELPER: Update last_update_date on user profile changes
-- ============================================================================
CREATE OR REPLACE FUNCTION public.update_last_update_date()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_update_date = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER users_update_timestamp
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION public.update_last_update_date();

-- ============================================================================
-- STORAGE: Create avatar bucket
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
