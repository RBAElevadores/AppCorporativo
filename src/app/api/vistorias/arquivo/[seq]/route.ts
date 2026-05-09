import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, parseSessionCookie } from '@/lib/session';
import { getSqlField, readSql, sqlInt } from '@/lib/sql';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

function cleanBase64(value: unknown): string {
  return String(value ?? '')
    .replace(/<[^>]*>/g, '')
    .replace(/\s/g, '');
}

function mimeFrom(value: unknown, ext: string | null): string {
  const explicit = String(value ?? '').trim().toLowerCase();
  if (explicit) return explicit;

  const extension = String(ext ?? '').trim().toLowerCase();
  if (extension === 'pdf') return 'application/pdf';
  return 'image/jpeg';
}

export async function GET(request: NextRequest, { params }: { params: { seq: string } }) {
  const session = parseSessionCookie(request.cookies.get(AUTH_COOKIE)?.value);
  if (!session) {
    return new NextResponse('Não autorizado.', { status: 401 });
  }

  const seq = sqlInt(params.seq);
  if (seq === '0') {
    return new NextResponse('Arquivo não informado.', { status: 400 });
  }

  const url = new URL(request.url);
  const vistoria = sqlInt(url.searchParams.get('vistoria') ?? '0');
  const ext = url.searchParams.get('ext');
  const filtroVistoria = vistoria !== '0' ? ` and Vistoria = 0${vistoria}` : '';

  const rows = await readSql(`
select top 1
  Base64 = cast((select Foto as [*] for xml path(''), binary base64) as varchar(max)),
  MimeType = case when Tipo = 'Projeto' then 'application/pdf' else 'image/jpeg' end
from ObraVistoriaFotos
where Seq = 0${seq}${filtroVistoria}`);

  const row = rows[0];
  const base64 = cleanBase64(getSqlField(row, ['Base64', 'base64', 'FotoBase64']));

  if (!base64) {
    return new NextResponse('Arquivo não encontrado.', { status: 404 });
  }

  const mimeType = mimeFrom(getSqlField(row, ['MimeType', 'mimeType', 'ContentType']), ext);
  const buffer = Buffer.from(base64, 'base64');

  return new NextResponse(buffer, {
    headers: {
      'Content-Type': mimeType,
      'Cache-Control': 'private, max-age=600'
    }
  });
}
