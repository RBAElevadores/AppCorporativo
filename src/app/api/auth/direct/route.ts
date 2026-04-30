import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, createSessionCookie } from '@/lib/session';
import { callSql, sqlInt, sqlNumberFromField, sqlTextFromField } from '@/lib/sql';

export const runtime = 'nodejs';

function parseIntParam(value: unknown, fallback = 0): number {
  const parsed = Number.parseInt(String(value ?? '').trim(), 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

async function updateVersionIfNeeded(codUsuario: number, versao: string): Promise<void> {
  if (!codUsuario || !versao) return;
  try {
    const safeVersion = String(versao).replace(/[^0-9.]/g, '');
    if (!safeVersion) return;
    await callSql(`update Usuarios set VersaoAppCorporativo = 0${safeVersion} where Codigo = 0${sqlInt(codUsuario)}`);
  } catch (error) {
    console.error('DIRECT_LOGIN_VERSION_UPDATE_ERROR', error);
  }
}

async function readUser(codUsuario: number) {
  try {
    const rows = await callSql(`select top 1 Codigo as Codigo, Nome as Nome, isnull(EmpresaSistema,0) as EmpresaSistema, isnull(Departamento,0) as Departamento from Usuarios where Codigo = 0${sqlInt(codUsuario)}`);
    const row = rows[0];
    if (!row) return null;
    return {
      codigo: sqlNumberFromField(row, ['Codigo', 'codigo', 'CODIGO'], codUsuario),
      nome: sqlTextFromField(row, ['Nome', 'nome', 'NOME'], `Usuário ${codUsuario}`),
      empresaSistema: sqlNumberFromField(row, ['EmpresaSistema', 'empresasistema', 'EMPRESASISTEMA'], 0),
      departamento: sqlNumberFromField(row, ['Departamento', 'departamento', 'DEPARTAMENTO'], 0)
    };
  } catch (error) {
    console.error('DIRECT_LOGIN_READ_USER_ERROR', error);
    return null;
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json() as Record<string, unknown>;
    const codUsuario = parseIntParam(body.codusuario ?? body.codUsuario, 0);
    const mobilePC = String(body.mobilePC ?? '');
    const pCodAtendimento = parseIntParam(body.idobra ?? body.pCodAtendimento, 0);
    const idNotificacao = parseIntParam(body.idnotificacao ?? body.idNotificacao, -1);
    const versao = String(body.versao ?? '').trim();

    if (codUsuario <= 0) {
      return NextResponse.json({ ok: false, message: 'codusuario inválido.' }, { status: 400 });
    }

    await updateVersionIfNeeded(codUsuario, versao);

    const user = await readUser(codUsuario);
    const session = {
      codigo: user?.codigo ?? codUsuario,
      codUsuario: user?.codigo ?? codUsuario,
      nome: user?.nome ?? `Usuário ${codUsuario}`,
      empresaSistema: user?.empresaSistema ?? 0,
      departamento: user?.departamento ?? 0,
      mobilePC,
      idNotificacao,
      pCodAtendimento,
      codEmpresa: 0,
      obra: 0,
      atendimento: 0,
      iamSOS: 0,
      tipoNotificacao: ''
    };

    const response = NextResponse.json({ ok: true, user: session, redirectTo: '/legacy-runtime/main' });
    response.cookies.set(AUTH_COOKIE, createSessionCookie(session), {
      httpOnly: true,
      sameSite: 'lax',
      secure: process.env.NODE_ENV === 'production',
      path: '/',
      maxAge: 60 * 60 * 12
    });
    return response;
  } catch (error) {
    console.error('DIRECT_LOGIN_ERROR', error);
    return NextResponse.json({ ok: false, message: error instanceof Error ? error.message : 'Erro no login direto.' }, { status: 500 });
  }
}
