import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, createSessionCookie } from '@/lib/session';
import { callSql, sqlString } from '@/lib/sql';

export const runtime = 'nodejs';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const nick = String(body.nick ?? '').trim();
    const senha = String(body.senha ?? '').trim();

    if (!nick || !senha) {
      return NextResponse.json({ ok: false, message: 'Preencha usuário e senha.' }, { status: 400 });
    }

    const sql = `
select top 1
  a.Codigo,
  a.Nome,
  isnull(a.EmpresaSistema,0) EmpresaSistema,
  isnull(a.Departamento,0) Departamento
from Usuarios a
left outer join Clientes b on b.Codigo = a.CodCli
where ((a.Nick = ${sqlString(nick)}) or (b.CPFCNPJ = ${sqlString(nick)}))
  and a.Senha = ${sqlString(senha)}`;

    const rows = await callSql(sql);
    const row = rows[0];

    if (!row) {
      return NextResponse.json({ ok: false, message: 'Usuário não encontrado.' }, { status: 401 });
    }

    const codigo = Number(row.Codigo ?? row.codigo ?? 0);
    const nome = String(row.Nome ?? row.nome ?? nick);
    const empresaSistema = Number(row.EmpresaSistema ?? row.empresasistema ?? 0);
    const departamento = Number(row.Departamento ?? row.departamento ?? 0);

    if (!codigo) {
      return NextResponse.json({ ok: false, message: 'Retorno de usuário inválido.' }, { status: 500 });
    }

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
    return NextResponse.json({ ok: false, message: error instanceof Error ? error.message : 'Erro no login.' }, { status: 500 });
  }
}
