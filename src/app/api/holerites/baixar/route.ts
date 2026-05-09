import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, parseSessionCookie } from '@/lib/session';
import { callSql, sqlInt } from '@/lib/sql';

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

    if (seq === '0') {
      return NextResponse.json(
        { ok: false, message: 'Holerite não informado.' },
        { status: 400 }
      );
    }

    const nome = `Holerite_${seq}.pdf`;

    const scriptPedido = `
delete from Arquivos.dbo.ArquivosTempURL
where not DtCriouServidor is null
  and Arquivo is null

insert into Arquivos.dbo.ArquivosTempURL(Arquivo,Nome)
select Arquivo, 'Holerite_'+cast(Seq as varchar(10))+'.pdf'
from Arquivos.FolhaSalarial.Holerites
where Seq = ${seq}
`;

    // Igual ao IntraWeb/Delphi: apenas solicita a criação do arquivo temporário.
    // Não faço SELECT de confirmação aqui, porque esse SELECT estava causando falso erro 500.
    // O acompanhamento fica na rota /api/holerites/status.
    await callSql(scriptPedido);

    return NextResponse.json({
      ok: true,
      message: 'Pedido do arquivo temporário registrado. Aguardando geração do PDF...',
      data: {
        seq,
        nome
      }
    });
  } catch (error) {
    return NextResponse.json(
      {
        ok: false,
        message: error instanceof Error ? error.message : 'Erro ao preparar holerite.'
      },
      { status: 500 }
    );
  }
}
