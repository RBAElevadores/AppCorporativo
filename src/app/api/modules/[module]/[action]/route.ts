import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, parseSessionCookie } from '@/lib/session';
import { executeModuleAction } from '@/lib/module-actions';
import { getModuleDefinition } from '@/lib/modules';

export const runtime = 'nodejs';

export async function POST(
  request: NextRequest,
  { params }: { params: { module: string; action: string } }
) {
  try {
    const session = parseSessionCookie(request.cookies.get(AUTH_COOKIE)?.value);
    if (!session) return NextResponse.json({ ok: false, message: 'Sessão expirada. Faça login novamente.' }, { status: 401 });

    const moduleDefinition = getModuleDefinition(params.module);
    if (!moduleDefinition) return NextResponse.json({ ok: false, message: 'Módulo não encontrado.' }, { status: 404 });

    const body = await request.json().catch(() => ({}));
    const result = await executeModuleAction(params.module, params.action, body, session);
    return NextResponse.json(result);
  } catch (error) {
    return NextResponse.json({ ok: false, message: error instanceof Error ? error.message : 'Erro ao executar ação.' }, { status: 500 });
  }
}
