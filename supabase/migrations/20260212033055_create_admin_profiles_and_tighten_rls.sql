/*
  # Create Admin Profiles Table and Tighten RLS Policies

  1. New Tables
    - `admin_profiles`
      - `id` (uuid, primary key, references auth.users)
      - `email` (text, not null)
      - `display_name` (text)
      - `role` (text, default 'admin')
      - `created_at` (timestamptz)

  2. New Functions
    - `is_admin(user_id uuid)` - checks if a user exists in admin_profiles

  3. Security Changes
    - Enable RLS on `admin_profiles`
    - Admin can read their own profile
    - Replace overly permissive write policies on page_content_sections,
      page_seo_content, and content_templates so only admins can write
    - Public read policies remain unchanged

  4. Important Notes
    - Existing data is preserved; only policies are tightened
    - The is_admin() function is used in all write policies for consistency
*/

-- 1. Create admin_profiles table
CREATE TABLE IF NOT EXISTS admin_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  display_name text DEFAULT '',
  role text NOT NULL DEFAULT 'admin',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE admin_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can read own profile"
  ON admin_profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Admins can update own profile"
  ON admin_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 2. Create is_admin helper function
CREATE OR REPLACE FUNCTION is_admin(user_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM admin_profiles WHERE id = user_id
  );
$$;

-- 3. Tighten page_content_sections write policies
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can insert sections' AND tablename = 'page_content_sections') THEN
    DROP POLICY "Authenticated users can insert sections" ON page_content_sections;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can update sections' AND tablename = 'page_content_sections') THEN
    DROP POLICY "Authenticated users can update sections" ON page_content_sections;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can delete sections' AND tablename = 'page_content_sections') THEN
    DROP POLICY "Authenticated users can delete sections" ON page_content_sections;
  END IF;
END $$;

CREATE POLICY "Admins can insert sections"
  ON page_content_sections FOR INSERT
  TO authenticated
  WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can update sections"
  ON page_content_sections FOR UPDATE
  TO authenticated
  USING (is_admin(auth.uid()))
  WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can delete sections"
  ON page_content_sections FOR DELETE
  TO authenticated
  USING (is_admin(auth.uid()));

-- Also allow admins to read ALL sections (including inactive)
CREATE POLICY "Admins can read all sections"
  ON page_content_sections FOR SELECT
  TO authenticated
  USING (is_admin(auth.uid()));

-- 4. Tighten page_seo_content write policies
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can insert seo content' AND tablename = 'page_seo_content') THEN
    DROP POLICY "Authenticated users can insert seo content" ON page_seo_content;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can update seo content' AND tablename = 'page_seo_content') THEN
    DROP POLICY "Authenticated users can update seo content" ON page_seo_content;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can delete seo content' AND tablename = 'page_seo_content') THEN
    DROP POLICY "Authenticated users can delete seo content" ON page_seo_content;
  END IF;
END $$;

CREATE POLICY "Admins can insert seo content"
  ON page_seo_content FOR INSERT
  TO authenticated
  WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can update seo content"
  ON page_seo_content FOR UPDATE
  TO authenticated
  USING (is_admin(auth.uid()))
  WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can delete seo content"
  ON page_seo_content FOR DELETE
  TO authenticated
  USING (is_admin(auth.uid()));

-- 5. Tighten content_templates write policies
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can insert templates' AND tablename = 'content_templates') THEN
    DROP POLICY "Authenticated users can insert templates" ON content_templates;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can update templates' AND tablename = 'content_templates') THEN
    DROP POLICY "Authenticated users can update templates" ON content_templates;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can delete templates' AND tablename = 'content_templates') THEN
    DROP POLICY "Authenticated users can delete templates" ON content_templates;
  END IF;
END $$;

CREATE POLICY "Admins can insert templates"
  ON content_templates FOR INSERT
  TO authenticated
  WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can update templates"
  ON content_templates FOR UPDATE
  TO authenticated
  USING (is_admin(auth.uid()))
  WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can delete templates"
  ON content_templates FOR DELETE
  TO authenticated
  USING (is_admin(auth.uid()));

CREATE POLICY "Admins can read all templates"
  ON content_templates FOR SELECT
  TO authenticated
  USING (is_admin(auth.uid()));
