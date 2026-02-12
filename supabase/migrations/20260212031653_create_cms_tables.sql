/*
  # Create CMS Content Management Tables

  1. New Tables
    - `page_content_sections`
      - `id` (uuid, primary key) - Unique section identifier
      - `page_type` (text) - Type of page: credit_card, category, homepage, article, lender
      - `page_id` (uuid) - Reference to the specific page
      - `section_type` (text) - Component type: rich_text, faq_accordion, checklist, etc.
      - `title` (text, nullable) - Section heading
      - `content` (text, nullable) - Markdown/HTML for simple sections
      - `content_data` (jsonb) - Structured data for complex sections
      - `sort_order` (integer) - Display ordering
      - `is_active` (boolean) - Soft delete / visibility toggle
      - `created_at` (timestamptz) - Creation timestamp
      - `updated_at` (timestamptz) - Last update timestamp

    - `page_seo_content`
      - `id` (uuid, primary key) - Unique identifier
      - `page_type` (text) - Type of page
      - `page_id` (uuid) - Reference to the specific page
      - `intro_text` (text, nullable) - Opening paragraph for SEO
      - `main_content` (text, nullable) - Main body content
      - `bottom_content` (text, nullable) - Closing SEO text
      - `created_at` (timestamptz) - Creation timestamp
      - `updated_at` (timestamptz) - Last update timestamp

    - `content_templates`
      - `id` (uuid, primary key) - Unique identifier
      - `template_name` (text) - Name of the template
      - `page_type` (text) - Target page type
      - `sections` (jsonb) - Array of section configurations
      - `description` (text, nullable) - Template description
      - `is_public` (boolean) - Whether template is publicly accessible
      - `created_at` (timestamptz) - Creation timestamp

  2. Security
    - Enable RLS on all tables
    - Public read access for active content sections (for static site generation at build time)
    - Public read access for SEO content
    - Authenticated users can manage all content
    - Service role has full bypass

  3. Indexes
    - Composite index on page_type + page_id for fast lookups
    - Index on page_id + sort_order for ordered retrieval
    - Index on is_active for filtering

  4. Important Notes
    - page_content_sections uses sort_order in increments of 10 for easy reordering
    - content_data is JSONB for flexible structured data per section type
    - page_seo_content has a unique constraint on (page_type, page_id) - one SEO entry per page
    - is_active defaults to true for new sections
*/

-- 1. Flexible Content Sections
CREATE TABLE IF NOT EXISTS page_content_sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_type text NOT NULL CHECK (page_type IN ('credit_card', 'category', 'homepage', 'article', 'lender')),
  page_id uuid NOT NULL,
  section_type text NOT NULL,
  title text,
  content text,
  content_data jsonb DEFAULT '{}'::jsonb,
  sort_order integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_page_content_page ON page_content_sections(page_type, page_id);
CREATE INDEX IF NOT EXISTS idx_page_content_sort ON page_content_sections(page_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_page_content_active ON page_content_sections(is_active);

ALTER TABLE page_content_sections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read active sections"
  ON page_content_sections FOR SELECT
  USING (is_active = true);

CREATE POLICY "Authenticated users can insert sections"
  ON page_content_sections FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update sections"
  ON page_content_sections FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete sections"
  ON page_content_sections FOR DELETE
  TO authenticated
  USING (true);

-- 2. SEO Content
CREATE TABLE IF NOT EXISTS page_seo_content (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_type text NOT NULL,
  page_id uuid NOT NULL,
  intro_text text,
  main_content text,
  bottom_content text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(page_type, page_id)
);

ALTER TABLE page_seo_content ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read seo content"
  ON page_seo_content FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert seo content"
  ON page_seo_content FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update seo content"
  ON page_seo_content FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete seo content"
  ON page_seo_content FOR DELETE
  TO authenticated
  USING (true);

-- 3. Content Templates
CREATE TABLE IF NOT EXISTS content_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  template_name text NOT NULL,
  page_type text NOT NULL,
  sections jsonb DEFAULT '[]'::jsonb,
  description text,
  is_public boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE content_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read public templates"
  ON content_templates FOR SELECT
  USING (is_public = true);

CREATE POLICY "Authenticated users can insert templates"
  ON content_templates FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update templates"
  ON content_templates FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete templates"
  ON content_templates FOR DELETE
  TO authenticated
  USING (true);