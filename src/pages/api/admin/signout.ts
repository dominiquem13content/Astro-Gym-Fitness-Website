import type { APIRoute } from 'astro';
import { createServerClientFromHeaders } from '../../../lib/supabase-server';

export const prerender = false;

export const POST: APIRoute = async ({ request, redirect }) => {
  const responseHeaders = new Headers();
  const supabase = createServerClientFromHeaders(request, responseHeaders);

  await supabase.auth.signOut();

  responseHeaders.set('Location', '/admin/login');
  return new Response(null, {
    status: 302,
    headers: responseHeaders,
  });
};
