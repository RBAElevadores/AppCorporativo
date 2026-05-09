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

async function localizarPedido(nome: string) {
  const rows = await callSql(`
select top 1
       Seq,
       Nome,
       iif(DtCriouServidor is null, 0, 1) Ready,
       convert(varchar(19), DtCriouServidor, 120) DtCriouServidor
from Arquivos.dbo.ArquivosTempURL
where Nome = ${sqlString(nome)}
order by Seq desc
`);

  return rows[0];
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

    await callSql(scriptPedido);

    let pedido = await localizarPedido(nome);
    let fallbackUsado = false;

    // Fallback: se o endpoint SQL executar apenas o primeiro comando do script composto,
    // roda o INSERT isolado usando exatamente a mesma formação de Nome do Delphi.
    if (!pedido) {
      fallbackUsado = true;

      await callSql(`
insert into Arquivos.dbo.ArquivosTempURL(Arquivo,Nome)
select Arquivo, 'Holerite_'+cast(Seq as varchar(10))+'.pdf'
from Arquivos.FolhaSalarial.Holerites
where Seq = ${seq}
`);

      pedido = await localizarPedido(nome);
    }

    if (!pedido) {
      return NextResponse.json(
        {
          ok: false,
          message: `Não consegui localizar o pedido do arquivo temporário para o holerite ${seq}.`,
          data: {
            seq,
            nome,
            fallbackUsado,
            scriptPedido
          }
        },
        { status: 500 }
      );
    }

    return NextResponse.json({
      ok: true,
      message: 'Pedido do arquivo temporário registrado. Aguardando geração do PDF...',
      data: {
        seq,
        nome,
        fallbackUsado,
        pedidoSeq: sqlTextFromField(pedido, ['Seq', 'seq'], ''),
        ready: sqlTextFromField(pedido, ['Ready', 'ready'], '0') === '1',
        dtCriouServidor: sqlTextFromField(pedido, ['DtCriouServidor', 'dtCriouServidor'], '')
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
