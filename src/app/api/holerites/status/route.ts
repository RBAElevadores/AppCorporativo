import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, parseSessionCookie } from '@/lib/session';
import { callSql, sqlInt, sqlString, sqlTextFromField } from '@/lib/sql';

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

    const seq = sqlInt(campo(body, 'seqArquivo', 'edtSeqArquivo', 'EDTSEQARQUIVO', 'seq', 'SEQ'));
    const nomeInformado = campo(body, 'nome', 'Nome', 'NOME').trim();
    const nome = nomeInformado || `Holerite_${seq}.pdf`;

    if (!nome || nome === 'Holerite_0.pdf') {
      return NextResponse.json(
        { ok: false, message: 'Arquivo de holerite não informado.' },
        { status: 400 }
      );
    }

    const rows = await callSql(`
select top 1
       Nome,
       iif(DtCriouServidor is null, 0, 1) Ready,
       convert(varchar(19), DtCriouServidor, 120) DtCriouServidor
from Arquivos.dbo.ArquivosTempURL
where Nome = ${sqlString(nome)}
order by Seq desc
`);

    const row = rows[0];
    const rowExists = !!row;
    const readyText = sqlTextFromField(row, ['Ready', 'ready', 'Aux', 'aux'], '0').trim();
    const ready = readyText === '1' || readyText.toLowerCase() === 'true';

    return NextResponse.json({
      ok: true,
      data: {
        rowExists,
        ready,
        nome,
        dtCriouServidor: sqlTextFromField(row, ['DtCriouServidor', 'dtCriouServidor'], ''),
        downloadUrl: ready ? `https://rbaelevadores.ddns.net/Arquivos/Temp/${encodeURIComponent(nome)}` : ''
      }
    });
  } catch (error) {
    return NextResponse.json(
      {
        ok: false,
        message: error instanceof Error ? error.message : 'Erro ao verificar holerite.'
      },
      { status: 500 }
    );
  }
}
