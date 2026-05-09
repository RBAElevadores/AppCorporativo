import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, parseSessionCookie } from '@/lib/session';
import { sqlHtml } from '@/lib/sql';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

function campo(body: Record<string, unknown>, ...nomes: string[]): string {
  const keys = Object.keys(body);

  for (const nome of nomes) {
    if (body[nome] !== undefined && body[nome] !== null) {
      return String(body[nome]);
    }

    const encontrado = keys.find((key) => key.toLowerCase() === nome.toLowerCase());

    if (encontrado && body[encontrado] !== undefined && body[encontrado] !== null) {
      return String(body[encontrado]);
    }
  }

  return '';
}

export async function POST(request: NextRequest) {
  try {
    const session = parseSessionCookie(request.cookies.get(AUTH_COOKIE)?.value);

    if (!session) {
      return NextResponse.json(
        { ok: false, message: 'Sessão expirada. Faça login novamente.' },
        { status: 401 }
      );
    }

    const body = await request.json().catch(() => ({} as Record<string, unknown>));
    const script = campo(body, 'script', 'edtScript', 'EDTSCRIPT').trim();

    if (!script) {
      return NextResponse.json(
        { ok: false, message: 'Informe o script do índice.' },
        { status: 400 }
      );
    }

    const html = await sqlHtml(script);

    return NextResponse.json({
      ok: true,
      html
    });
  } catch (error) {
    return NextResponse.json(
      {
        ok: false,
        message: error instanceof Error ? error.message : 'Erro ao executar índice.'
      },
      { status: 500 }
    );
  }
}
