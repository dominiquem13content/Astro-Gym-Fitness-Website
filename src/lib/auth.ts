import type { AstroCookies } from 'astro';
import { createServerClient } from './supabase-server';

export interface AdminUser {
  id: string;
  email: string;
  displayName: string;
  role: string;
}

export async function getSession(cookies: AstroCookies) {
  const supabase = createServerClient(cookies);
  const { data: { user }, error } = await supabase.auth.getUser();
  if (error || !user) return null;
  return user;
}

export async function getAdminUser(cookies: AstroCookies): Promise<AdminUser | null> {
  const supabase = createServerClient(cookies);
  const { data: { user }, error } = await supabase.auth.getUser();
  if (error || !user) return null;

  const { data: profile } = await supabase
    .from('admin_profiles')
    .select('*')
    .eq('id', user.id)
    .maybeSingle();

  if (!profile) return null;

  return {
    id: user.id,
    email: user.email ?? profile.email,
    displayName: profile.display_name || 'Admin',
    role: profile.role,
  };
}
