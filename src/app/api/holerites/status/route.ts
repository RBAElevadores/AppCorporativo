import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, parseSessionCookie } from '@/lib/session';
import { sqlInt, sqlScalar, sqlString } from '@/lib/sql';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

function campo(body: Record<string, unknown>, ...nomes: string[]): string {
  const keys = Object.keys(body);

  for (const nome of nomes) {
    if (body[nome] !== undefined && body[nome] !== null) return String(body[nome]);
    const encontrado = keys.find((key) => key.toLowerCase() === nome.toLowerCase());
    if (encontrado && body[encontrado] !== undefined && body[encontrado] !== null) return String(body[encontrado]);
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
    const seq = sqlInt(campo(body, 'seqArquivo', 'edtSeqArquivo', 'EDTSEQARQUIVO', 'seq', 'SEQ'));
    const nomeInformado = campo(body, 'nome', 'Nome', 'NOME').trim();
    const nome = nomeInformado || `Holerite_${seq}.pdf`;

    if (!nome || nome === 'Holerite_0.pdf') {
      return NextResponse.json({ ok: false, message: 'Arquivo de holerite não informado.' }, { status: 400 });
    }

    const existe = await sqlScalar(`
select count(1) Aux
from Arquivos.dbo.ArquivosTempURL
where Nome = ${sqlString(nome)}
`);

    const pronto = await sqlScalar(`
select 1 Aux
from Arquivos.dbo.ArquivosTempURL
where Nome = ${sqlString(nome)}
  and not DtCriouServidor is null
`);

    const ready = String(pronto ?? '').trim() === '1';

    return NextResponse.json({
      ok: true,
      data: {
        ready,
        nome,
        existe,
        downloadUrl: ready ? `https://rbaelevadores.ddns.net/Arquivos/Temp/${encodeURIComponent(nome)}` : ''
      }
    });
  } catch (error) {
    return NextResponse.json(
      { ok: false, message: error instanceof Error ? error.message : 'Erro ao verificar holerite.' },
      { status: 500 }
    );
  }
}
