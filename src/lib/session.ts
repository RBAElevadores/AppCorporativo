import crypto from 'crypto';
import { cookies } from 'next/headers';

export const AUTH_COOKIE = 'rba_app_session';

export type AppSession = {
  codigo: number;
  nome: string;
  empresaSistema: number;
  departamento: number;
  tokenTerceiro?: string;
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

export function createSessionCookie(session: AppSession): string {
  const payload = base64url(JSON.stringify(session));
  return `${payload}.${sign(payload)}`;
}

export function parseSessionCookie(value?: string | null): AppSession | null {
  if (!value) return null;
  const [payload, signature] = value.split('.');
  if (!payload || !signature) return null;
  const expected = sign(payload);
  try {
    if (!crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected))) return null;
    return JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')) as AppSession;
  } catch {
    return null;
  }
}

export function getCurrentSession(): AppSession | null {
  const store = cookies();
  return parseSessionCookie(store.get(AUTH_COOKIE)?.value);
}
