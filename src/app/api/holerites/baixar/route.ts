import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, parseSessionCookie } from '@/lib/session';
import { callSql, sqlInt, sqlScalar, sqlString } from '@/lib/sql';

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

    if (seq === '0') {
      return NextResponse.json({ ok: false, message: 'Holerite não informado.' }, { status: 400 });
    }

    const nome = `Holerite_${seq}.pdf`;

    const existeHolerite = await sqlScalar(`
select count(1) Aux
from Arquivos.FolhaSalarial.Holerites
where Seq = 0${seq}
`);

    if (String(existeHolerite ?? '').trim() === '0') {
      return NextResponse.json(
        { ok: false, message: `Holerite não encontrado para Seq ${seq}.`, data: { seq, nome, existeHolerite } },
        { status: 404 }
      );
    }

    const script = `
delete from Arquivos.dbo.ArquivosTempURL
where not DtCriouServidor is null
  and Arquivo is null;

insert into Arquivos.dbo.ArquivosTempURL(Arquivo, Nome)
select Arquivo, ${sqlString(nome)}
from Arquivos.FolhaSalarial.Holerites
where Seq = 0${seq};
`;

    await callSql(script);

    const inserido = await sqlScalar(`
select count(1) Aux
from Arquivos.dbo.ArquivosTempURL
where Nome = ${sqlString(nome)}
`);

    if (String(inserido ?? '').trim() === '0') {
      return NextResponse.json(
        { ok: false, message: `Arquivo temporário não foi criado para o holerite ${seq}.`, data: { seq, nome, existeHolerite, inserido } },
        { status: 500 }
      );
    }

    return NextResponse.json({
      ok: true,
      message: 'Gerando o arquivo, aguarde...',
      data: { seq, nome, existeHolerite, inserido }
    });
  } catch (error) {
    return NextResponse.json(
      { ok: false, message: error instanceof Error ? error.message : 'Erro ao preparar holerite.' },
      { status: 500 }
    );
  }
}
