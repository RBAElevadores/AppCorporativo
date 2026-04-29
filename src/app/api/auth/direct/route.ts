import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, createSessionCookie } from '@/lib/session';
import { callSql, sqlInt, sqlNumberFromField, sqlTextFromField } from '@/lib/sql';

export const runtime = 'nodejs';

export async function POST(request: NextRequest) {
  try {
    if (process.env.RBA_ALLOW_LEGACY_DIRECT_LOGIN !== 'true') {
      return NextResponse.json({ ok: false, message: 'Login direto legado desativado. Configure RBA_ALLOW_LEGACY_DIRECT_LOGIN=true somente se necessário.' }, { status: 403 });
    }

    const body = await request.json();
    const codUsuario = sqlInt(body.codusuario ?? body.codUsuario);
    if (codUsuario === '0') return NextResponse.json({ ok: false, message: 'codusuario inválido.' }, { status: 400 });

    const rows = await callSql(`select top 1 Codigo as Codigo, Nome as Nome, isnull(EmpresaSistema,0) as EmpresaSistema, isnull(Departamento,0) as Departamento from Usuarios where Codigo = 0${codUsuario}`);
    const row = rows[0];
    if (!row) return NextResponse.json({ ok: false, message: 'Usuário não encontrado.' }, { status: 404 });

    const codigo = sqlNumberFromField(row, ['Codigo', 'codigo', 'CODIGO'], 0);
    const nome = sqlTextFromField(row, ['Nome', 'nome', 'NOME'], 'Usuário');
    const empresaSistema = sqlNumberFromField(row, ['EmpresaSistema', 'empresasistema', 'EMPRESASISTEMA'], 0);
    const departamento = sqlNumberFromField(row, ['Departamento', 'departamento', 'DEPARTAMENTO'], 0);

    if (!codigo) return NextResponse.json({ ok: false, message: 'Retorno de usuário inválido.' }, { status: 500 });

    const response = NextResponse.json({ ok: true, user: { codigo, nome, empresaSistema, departamento } });
    response.cookies.set(AUTH_COOKIE, createSessionCookie({ codigo, nome, empresaSistema, departamento }), {
      httpOnly: true,
      sameSite: 'lax',
      secure: process.env.NODE_ENV === 'production',
      path: '/',
      maxAge: 60 * 60 * 12
    });
    return response;
  } catch (error) {
    return NextResponse.json({ ok: false, message: error instanceof Error ? error.message : 'Erro no login direto.' }, { status: 500 });
  }
}
