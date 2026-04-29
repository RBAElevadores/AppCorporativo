import type { AppSession } from './session';
import { sqlScalar, sqlString } from './sql';

export async function hasPermission(session: AppSession, descricao: string, tipo = 'V'): Promise<boolean> {
  const safeTipo = ['V', 'I', 'A', 'E'].includes(tipo) ? tipo : 'V';
  const sql = `
if not exists(select 1 from Permissoes.Permissao where ltrim(rtrim(Descricao)) = ${sqlString(descricao)})
    insert into Permissoes.Permissao(Descricao) values(${sqlString(descricao)});
if exists(
  select 1
  from Permissoes.UsuarioPermissao
  where CodPermissao = (select CodPermissao from Permissoes.Permissao where Descricao = ${sqlString(descricao)})
    and CodUsuario = ${session.codigo}
    and ${safeTipo} = 1
) select 1 else select 0`;

  return (await sqlScalar(sql)) === '1';
}

export async function requirePermission(session: AppSession, descricao: string, tipo = 'V'): Promise<void> {
  const ok = await hasPermission(session, descricao, tipo);
  if (!ok) throw new Error(`Usuário sem permissão: ${descricao}`);
}
