import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, parseSessionCookie } from '@/lib/session';
import { sqlHtml } from '@/lib/sql';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

export async function POST(request: NextRequest) {
  try {
    const session = parseSessionCookie(request.cookies.get(AUTH_COOKIE)?.value);

    if (!session) {
      return NextResponse.json(
        { ok: false, message: 'Sessão expirada. Faça login novamente.' },
        { status: 401 }
      );
    }

    const retorno = await sqlHtml(`exec SmartBox.USP_HTMLTecnicoOnlineHolerites 0${session.codigo}`);

    return NextResponse.json({
      ok: true,
      retorno
    });
  } catch (error) {
    return NextResponse.json(
      {
        ok: false,
        message: error instanceof Error ? error.message : 'Erro ao carregar holerites.'
      },
      { status: 500 }
    );
  }
}
