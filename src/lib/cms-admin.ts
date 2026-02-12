import type { SupabaseClient } from '@supabase/supabase-js';
import type { ContentSection, SeoContent } from './cms';

export interface ContentSectionInput {
  page_type: string;
  page_id: string;
  section_type: string;
  title?: string | null;
  content?: string | null;
  content_data?: Record<string, any>;
  sort_order?: number;
  is_active?: boolean;
}

export interface SeoContentInput {
  page_type: string;
  page_id: string;
  intro_text?: string | null;
  main_content?: string | null;
  bottom_content?: string | null;
}

export interface TemplateInput {
  template_name: string;
  page_type: string;
  sections?: Record<string, any>[];
  description?: string | null;
  is_public?: boolean;
}

export async function getAllSections(supabase: SupabaseClient, filters?: { page_type?: string; section_type?: string; is_active?: boolean }) {
  let query = supabase.from('page_content_sections').select('*').order('sort_order');
  if (filters?.page_type) query = query.eq('page_type', filters.page_type);
  if (filters?.section_type) query = query.eq('section_type', filters.section_type);
  if (filters?.is_active !== undefined) query = query.eq('is_active', filters.is_active);
  const { data, error } = await query;
  if (error) throw error;
  return data as ContentSection[];
}

export async function getSectionById(supabase: SupabaseClient, id: string) {
  const { data, error } = await supabase.from('page_content_sections').select('*').eq('id', id).maybeSingle();
  if (error) throw error;
  return data as ContentSection | null;
}

export async function createSection(supabase: SupabaseClient, input: ContentSectionInput) {
  const { data, error } = await supabase.from('page_content_sections').insert({
    ...input,
    content_data: input.content_data ?? {},
    sort_order: input.sort_order ?? 0,
    is_active: input.is_active ?? true,
    updated_at: new Date().toISOString(),
  }).select().single();
  if (error) throw error;
  return data as ContentSection;
}

export async function updateSection(supabase: SupabaseClient, id: string, input: Partial<ContentSectionInput>) {
  const { data, error } = await supabase.from('page_content_sections').update({
    ...input,
    updated_at: new Date().toISOString(),
  }).eq('id', id).select().single();
  if (error) throw error;
  return data as ContentSection;
}

export async function deleteSection(supabase: SupabaseClient, id: string) {
  const { error } = await supabase.from('page_content_sections').delete().eq('id', id);
  if (error) throw error;
}

export async function getAllSeoContent(supabase: SupabaseClient) {
  const { data, error } = await supabase.from('page_seo_content').select('*').order('created_at', { ascending: false });
  if (error) throw error;
  return data as SeoContent[];
}

export async function getSeoContentById(supabase: SupabaseClient, id: string) {
  const { data, error } = await supabase.from('page_seo_content').select('*').eq('id', id).maybeSingle();
  if (error) throw error;
  return data as SeoContent | null;
}

export async function createSeoContent(supabase: SupabaseClient, input: SeoContentInput) {
  const { data, error } = await supabase.from('page_seo_content').insert({
    ...input,
    updated_at: new Date().toISOString(),
  }).select().single();
  if (error) throw error;
  return data as SeoContent;
}

export async function updateSeoContent(supabase: SupabaseClient, id: string, input: Partial<SeoContentInput>) {
  const { data, error } = await supabase.from('page_seo_content').update({
    ...input,
    updated_at: new Date().toISOString(),
  }).eq('id', id).select().single();
  if (error) throw error;
  return data as SeoContent;
}

export async function deleteSeoContent(supabase: SupabaseClient, id: string) {
  const { error } = await supabase.from('page_seo_content').delete().eq('id', id);
  if (error) throw error;
}

export interface Template {
  id: string;
  template_name: string;
  page_type: string;
  sections: Record<string, any>[];
  description: string | null;
  is_public: boolean;
  created_at: string;
}

export async function getAllTemplates(supabase: SupabaseClient) {
  const { data, error } = await supabase.from('content_templates').select('*').order('created_at', { ascending: false });
  if (error) throw error;
  return data as Template[];
}

export async function getTemplateById(supabase: SupabaseClient, id: string) {
  const { data, error } = await supabase.from('content_templates').select('*').eq('id', id).maybeSingle();
  if (error) throw error;
  return data as Template | null;
}

export async function createTemplate(supabase: SupabaseClient, input: TemplateInput) {
  const { data, error } = await supabase.from('content_templates').insert({
    ...input,
    sections: input.sections ?? [],
    is_public: input.is_public ?? false,
  }).select().single();
  if (error) throw error;
  return data as Template;
}

export async function updateTemplate(supabase: SupabaseClient, id: string, input: Partial<TemplateInput>) {
  const { data, error } = await supabase.from('content_templates').update(input).eq('id', id).select().single();
  if (error) throw error;
  return data as Template;
}

export async function deleteTemplate(supabase: SupabaseClient, id: string) {
  const { error } = await supabase.from('content_templates').delete().eq('id', id);
  if (error) throw error;
}
