import type { APIRoute } from 'astro';
import { createServerClientFromHeaders } from '../../../../lib/supabase-server';
import { getAdminUser } from '../../../../lib/auth';
import { deleteTemplate } from '../../../../lib/cms-admin';

export const prerender = false;

export const POST: APIRoute = async ({ params, request, cookies }) => {
  const admin = await getAdminUser(cookies);
  if (!admin) {
    return new Response('Unauthorized', { status: 401 });
  }

  const form = await request.formData();
  const method = form.get('_method')?.toString();

  if (method === 'DELETE') {
    const responseHeaders = new Headers();
    const supabase = createServerClientFromHeaders(request, responseHeaders);

    try {
      await deleteTemplate(supabase, params.id!);
    } catch {
      // Ignore delete errors
    }

    responseHeaders.set('Location', '/admin/templates?success=Template+deleted');
    return new Response(null, { status: 302, headers: responseHeaders });
  }

  return new Response('Method not allowed', { status: 405 });
};
