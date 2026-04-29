import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, parseSessionCookie } from '@/lib/session';
import { executeModuleAction, legacyComponentToAction } from '@/lib/module-actions';
import { getModuleDefinition } from '@/lib/modules';

export const runtime = 'nodejs';

export async function POST(
  request: NextRequest,
  { params }: { params: { module: string; component: string } }
) {
  try {
    const session = parseSessionCookie(request.cookies.get(AUTH_COOKIE)?.value);
    if (!session) return NextResponse.json({ ok: false, message: 'Sessão expirada.' }, { status: 401 });

    if (!getModuleDefinition(params.module)) return NextResponse.json({ ok: false, message: 'Módulo não encontrado.' }, { status: 404 });

    const action = legacyComponentToAction(params.module, params.component);
    if (!action) return NextResponse.json({ ok: false, message: `Componente legado não mapeado: ${params.component}` }, { status: 404 });

    if (action.startsWith('navigate:')) {
      return NextResponse.json({ ok: true, navigateTo: `/app/${action.slice('navigate:'.length)}` });
    }

    if (action === 'logout') {
      const response = NextResponse.json({ ok: true, navigateTo: '/login' });
      response.cookies.set(AUTH_COOKIE, '', { path: '/', maxAge: 0 });
      return response;
    }

    const body = await request.json().catch(() => ({}));
    const result = await executeModuleAction(params.module, action, body, session);
    return NextResponse.json(result);
  } catch (error) {
    return NextResponse.json({ ok: false, message: error instanceof Error ? error.message : 'Erro ao executar ação legado.' }, { status: 500 });
  }
}
