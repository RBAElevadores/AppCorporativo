import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, createSessionCookie } from '@/lib/session';
import { callSql, describeSqlRow, sqlNumberFromField, sqlString, sqlTextFromField } from '@/lib/sql';

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
  a.Codigo as Codigo,
  a.Nome as Nome,
  isnull(a.EmpresaSistema,0) as EmpresaSistema,
  isnull(a.Departamento,0) as Departamento
from Usuarios a
left outer join Clientes b on b.Codigo = a.CodCli
where ((a.Nick = ${sqlString(nick)}) or (b.CPFCNPJ = ${sqlString(nick)}))
  and a.Senha = ${sqlString(senha)}`;

    const rows = await callSql(sql);
    const row = rows[0];

    if (!row) {
      return NextResponse.json({ ok: false, message: 'Usuário não encontrado.' }, { status: 401 });
    }

    const codigo = sqlNumberFromField(row, ['Codigo', 'codigo', 'CODIGO', 'CodUsuario', 'codUsuario', 'CODUSUARIO'], 0);
    const nome = sqlTextFromField(row, ['Nome', 'nome', 'NOME'], nick);
    const empresaSistema = sqlNumberFromField(row, ['EmpresaSistema', 'empresasistema', 'EMPRESASISTEMA'], 0);
    const departamento = sqlNumberFromField(row, ['Departamento', 'departamento', 'DEPARTAMENTO'], 0);

    if (!codigo) {
      console.error('LOGIN_SQL_INVALID_USER_RETURN', {
        nick,
        rowDescription: describeSqlRow(row),
        rowSample: JSON.stringify(row).slice(0, 1000)
      });

      return NextResponse.json({
        ok: false,
        message: `Retorno de usuário inválido: ${describeSqlRow(row)}.`
      }, { status: 500 });
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
    console.error('LOGIN_ERROR', error);
    return NextResponse.json({ ok: false, message: error instanceof Error ? error.message : 'Erro no login.' }, { status: 500 });
  }
}
