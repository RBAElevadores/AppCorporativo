import crypto from 'crypto';
import { cookies } from 'next/headers';

export const AUTH_COOKIE = 'rba_app_session';

export type AppSession = {
  codigo: number;
  codUsuario: number;
  nome: string;
  mobilePC: string;
  codEmpresa: number;
  departamento: number;
  empresaSistema: number;
  obra: number;
  atendimento: number;
  iamSOS: number;
  idNotificacao: number;
  pCodAtendimento: number;
  tipoNotificacao: string;
  tokenTerceiro: string;
  restrito?: boolean;
  MobilePC: string;
  CodUsuario: number;
  CodEmpresa: number;
  Departamento: number;
  EmpresaSistema: number;
  Obra: number;
  Atendimento: number;
  IAMSOS: number;
  IDNotificacao: number;
  PCodAtendimento: number;
  TipoNotificacao: string;
  TokenTerceiro: string;
};

function secret(): string {
  return process.env.RBA_AUTH_SECRET || 'desenvolvimento-local-trocar-em-producao';
}

function base64url(input: Buffer | string): string {
  return Buffer.from(input).toString('base64url');
}

function sign(payload: string): string {
  return crypto.createHmac('sha256', secret()).update(payload).digest('base64url');
}

function numberOrZero(value: unknown): number {
  const parsed = Number(String(value ?? '').trim().replace(',', '.'));
  return Number.isFinite(parsed) ? parsed : 0;
}

function stringOrEmpty(value: unknown): string {
  return String(value ?? '');
}

export function normalizeSession(input: Partial<AppSession>): AppSession {
  const codUsuario = numberOrZero(input.codUsuario ?? input.CodUsuario ?? input.codigo);
  const mobilePC = stringOrEmpty(input.mobilePC ?? input.MobilePC);
  const codEmpresa = numberOrZero(input.codEmpresa ?? input.CodEmpresa);
  const departamento = numberOrZero(input.departamento ?? input.Departamento);
  const empresaSistema = numberOrZero(input.empresaSistema ?? input.EmpresaSistema);
  const obra = numberOrZero(input.obra ?? input.Obra);
  const atendimento = numberOrZero(input.atendimento ?? input.Atendimento);
  const iamSOS = numberOrZero(input.iamSOS ?? input.IAMSOS);
  const idNotificacao = input.idNotificacao === undefined && input.IDNotificacao === undefined ? -1 : numberOrZero(input.idNotificacao ?? input.IDNotificacao);
  const pCodAtendimento = numberOrZero(input.pCodAtendimento ?? input.PCodAtendimento);
  const tipoNotificacao = stringOrEmpty(input.tipoNotificacao ?? input.TipoNotificacao);
  const tokenTerceiro = stringOrEmpty(input.tokenTerceiro ?? input.TokenTerceiro);

  return {
    codigo: codUsuario,
    codUsuario,
    nome: stringOrEmpty(input.nome),
    mobilePC,
    codEmpresa,
    departamento,
    empresaSistema,
    obra,
    atendimento,
    iamSOS,
    idNotificacao,
    pCodAtendimento,
    tipoNotificacao,
    tokenTerceiro,
    restrito: input.restrito,
    MobilePC: mobilePC,
    CodUsuario: codUsuario,
    CodEmpresa: codEmpresa,
    Departamento: departamento,
    EmpresaSistema: empresaSistema,
    Obra: obra,
    Atendimento: atendimento,
    IAMSOS: iamSOS,
    IDNotificacao: idNotificacao,
    PCodAtendimento: pCodAtendimento,
    TipoNotificacao: tipoNotificacao,
    TokenTerceiro: tokenTerceiro
  };
}

export function createSessionCookie(session: Partial<AppSession>): string {
  const payload = base64url(JSON.stringify(normalizeSession(session)));
  return `${payload}.${sign(payload)}`;
}

export function parseSessionCookie(value?: string | null): AppSession | null {
  if (!value) return null;
  const [payload, signature] = value.split('.');
  if (!payload || !signature) return null;
  const expected = sign(payload);
  try {
    if (!crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected))) return null;
    return normalizeSession(JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')) as Partial<AppSession>);
  } catch {
    return null;
  }
}

export function getCurrentSession(): AppSession | null {
  const store = cookies();
  return parseSessionCookie(store.get(AUTH_COOKIE)?.value);
}
