import { supabase } from './supabase';

export interface ContentSection {
  id: string;
  page_type: string;
  page_id: string;
  section_type: string;
  title: string | null;
  content: string | null;
  content_data: Record<string, any>;
  sort_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface SeoContent {
  id: string;
  page_type: string;
  page_id: string;
  intro_text: string | null;
  main_content: string | null;
  bottom_content: string | null;
  created_at: string;
  updated_at: string;
}

export async function getPageSections(pageType: string, pageId: string): Promise<ContentSection[]> {
  const { data, error } = await supabase
    .from('page_content_sections')
    .select('*')
    .eq('page_type', pageType)
    .eq('page_id', pageId)
    .eq('is_active', true)
    .order('sort_order');

  if (error) {
    console.error('Error fetching page sections:', error);
    return [];
  }

  return data ?? [];
}

export async function getSeoContent(pageType: string, pageId: string): Promise<SeoContent | null> {
  const { data, error } = await supabase
    .from('page_seo_content')
    .select('*')
    .eq('page_type', pageType)
    .eq('page_id', pageId)
    .maybeSingle();

  if (error) {
    console.error('Error fetching SEO content:', error);
    return null;
  }

  return data;
}

export async function getAllArticleSections(): Promise<ContentSection[]> {
  const { data, error } = await supabase
    .from('page_content_sections')
    .select('*')
    .eq('page_type', 'article')
    .eq('is_active', true)
    .order('sort_order');

  if (error) {
    console.error('Error fetching article sections:', error);
    return [];
  }

  return data ?? [];
}
