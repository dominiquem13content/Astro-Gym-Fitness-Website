import { defineMiddleware } from 'astro:middleware';
import { getAdminUser } from './lib/auth';

export const onRequest = defineMiddleware(async (context, next) => {
  const { pathname } = context.url;

  if (!pathname.startsWith('/admin')) {
    return next();
  }

  if (pathname === '/admin/login') {
    const admin = await getAdminUser(context.cookies);
    if (admin) {
      return context.redirect('/admin/dashboard');
    }
    return next();
  }

  const admin = await getAdminUser(context.cookies);
  if (!admin) {
    return context.redirect('/admin/login');
  }

  context.locals.admin = admin;
  return next();
});
