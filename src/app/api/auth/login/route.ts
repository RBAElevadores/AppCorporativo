import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, createSessionCookie } from '@/lib/session';
import { callSql, describeSqlRow, sqlInt, sqlNumberFromField, sqlString, sqlTextFromField } from '@/lib/sql';

export const runtime = 'nodejs';

async function readOptionalNumber(sql: string): Promise<number> {
  try {
    const rows = await callSql(sql);
    return sqlNumberFromField(rows[0], Object.keys(rows[0] ?? {}), 0);
  } catch (error) {
    console.error('LOGIN_OPTIONAL_NUMBER_ERROR', error);
    return 0;
  }
}

async function readOptionalText(sql: string, fallback: string): Promise<string> {
  try {
    const rows = await callSql(sql);
    const row = rows[0];
    if (!row) return fallback;
    return sqlTextFromField(row, Object.keys(row), fallback) || fallback;
  } catch (error) {
    console.error('LOGIN_OPTIONAL_TEXT_ERROR', error);
    return fallback;
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const nick = String(body.nick ?? '').trim();
    const senha = String(body.senha ?? '').trim();

    if (!nick || !senha) {
      return NextResponse.json({ ok: false, message: 'Preencha usuário e senha.' }, { status: 400 });
    }

    // Esta primeira consulta replica o login do IntraWeb/Delphi original.
    // Mantemos simples: primeiro obtemos apenas o Codigo; depois carregamos os dados auxiliares.
    const sqlCodigo = `
select top 1
  a.Codigo as Codigo
from Usuarios a
left outer join Clientes b on b.Codigo = a.CodCli
where ((a.Nick = ${sqlString(nick)}) or (b.CPFCNPJ = ${sqlString(nick)}))
  and Senha = ${sqlString(senha)}`;

    const codigoRows = await callSql(sqlCodigo);
    const codigoRow = codigoRows[0];

    if (!codigoRow) {
      return NextResponse.json({ ok: false, message: 'Usuário não encontrado.' }, { status: 401 });
    }

    const codigo = sqlNumberFromField(codigoRow, ['Codigo', 'codigo', 'CODIGO', 'CodUsuario', 'codUsuario', 'CODUSUARIO'], 0);

    if (!codigo) {
      console.error('LOGIN_SQL_INVALID_CODIGO_RETURN', {
        nick,
        rowDescription: describeSqlRow(codigoRow),
        rowSample: JSON.stringify(codigoRow).slice(0, 1000)
      });

      return NextResponse.json({
        ok: false,
        message: `Retorno de código de usuário inválido: ${describeSqlRow(codigoRow)}.`
      }, { status: 500 });
    }

    const codigoSql = sqlInt(codigo);
    const nome = await readOptionalText(`select top 1 Nome from Usuarios where Codigo = ${codigoSql}`, nick);
    const empresaSistema = await readOptionalNumber(`select top 1 EmpresaSistema from Usuarios where Codigo = ${codigoSql}`);
    const departamento = await readOptionalNumber(`select top 1 Departamento from Usuarios where Codigo = ${codigoSql}`);

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
