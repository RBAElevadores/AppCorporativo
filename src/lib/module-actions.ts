import type { AppSession } from './session';
import { callSql, rowsToHtml, sqlBit, sqlHtml, sqlInt, sqlNumber, sqlScalar, sqlString } from './sql';
import { requirePermission } from './permissions';

export type ModuleActionResult = {
  ok: boolean;
  message?: string;
  html?: string;
  data?: unknown;
  target?: string;
};

type FormDataObject = Record<string, unknown>;

function field(form: FormDataObject, ...names: string[]): string {
  const keys = Object.keys(form);
  for (const name of names) {
    if (form[name] !== undefined && form[name] !== null) return String(form[name]);
    const found = keys.find((key) => key.toLowerCase() === name.toLowerCase());
    if (found && form[found] !== undefined && form[found] !== null) return String(form[found]);
  }
  return '';
}

function htmlResult(html: string, message?: string, target = 'resultado'): ModuleActionResult {
  return { ok: true, html, message, target };
}

function messageResult(message: string, data?: unknown): ModuleActionResult {
  return { ok: true, message, data };
}

async function execHtml(sql: string, message?: string, target?: string): Promise<ModuleActionResult> {
  return htmlResult(await sqlHtml(sql), message, target);
}

async function execRows(sql: string, message?: string, target?: string): Promise<ModuleActionResult> {
  const rows = await callSql(sql);
  return htmlResult(rowsToHtml(rows), message, target);
}

function obra(form: FormDataObject): string {
  return sqlInt(field(form, 'obra', 'edtObra', 'EDTOBRA'));
}

function atendimento(form: FormDataObject): string {
  return sqlInt(field(form, 'atendimento', 'edtAtendimento', 'EDTATENDIMENTO'));
}

function makeSenhaInstalacao(obraValue: string): string {
  const n = Number.parseInt(obraValue || '0', 10) || 0;
  return String(((Math.trunc(n * 123 + 123) % 1000000007) % 10000));
}

export async function executeModuleAction(
  moduleKey: string,
  action: string,
  form: FormDataObject,
  session: AppSession
): Promise<ModuleActionResult> {
  switch (moduleKey) {
    case 'main': {
      if (action === 'menu') {
        return execHtml(`exec [SmartBox].[USP_HTMLTecnicoOnlineMainMenu] 0${session.codigo}`);
      }
      break;
    }

    case 'principal': {
      if (action === 'meusAtendimentos') {
        return execHtml(`exec SmartBox.USP_HTMLAtendimentosUsuario ${session.codigo}`);
      }
      if (action === 'todosAtendimentos') {
        return execHtml('exec SmartBox.USP_HTMLAtendimentos');
      }
      if (action === 'atender') {
        const cod = atendimento(form);
        if (cod === '0') throw new Error('Informe o código do atendimento.');
        const sql = `
if exists(select 1 from SmartBox.Atendimentos where Codigo = 0${cod} and DTInicioAtendimento is null)
  update SmartBox.Atendimentos set DTInicioAtendimento = getdate(), QuemInicioAtendimento = 0${session.codigo} where Codigo = 0${cod}`;
        await callSql(sql);
        const codObra = await sqlScalar(`select Obra from SmartBox.Atendimentos where Codigo = 0${cod}`);
        return messageResult(`Atendimento ${cod} assumido. Obra ${codObra}.`, { atendimento: cod, obra: codObra });
      }
      break;
    }

    case 'chat': {
      const codObra = obra(form);
      const codAtendimento = atendimento(form);
      if (action === 'carregar') {
        const status = await sqlScalar(`select case when not (DTConcluido is null) then 'ATENDIMENTO ENCERRADO' ELSE IIF(DATEDIFF(second,isnull(DTTabletOnline,'01/01/1990'),getdate())<=40,'ON-LINE','OFF-LINE') END StatusTablet from SmartBox.Atendimentos where Codigo = 0${codAtendimento}`);
        const botoeira = await sqlHtml(`exec SmartBox.USP_HTMLSOSBotoeira 0${codObra}`);
        const pendentes = await sqlHtml(`exec SmartBox.USP_HTMLSOSAcoesPendentes 0${codObra}`);
        return htmlResult(`<div class="alert alert-info">Status tablet: <strong>${status || '-'}</strong></div><h5>Botoeira</h5>${botoeira}<hr/><h5>Ações pendentes</h5>${pendentes}`);
      }
      if (action === 'conversa') {
        return execRows(`select Codigo, REPLACE(Texto,CHAR(13)+Char(10),'<br>') Texto, Obra, QuemEnviou, convert(varchar(5),DTInsert,108) Hora from SmartBox.SOSChat where Obra = 0${codObra} and DTInsert between DATEADD(HOUR,-12,GETDATE()) and GETDATE() order by Codigo`);
      }
      if (action === 'enviarMensagem') {
        const mensagem = field(form, 'mensagem', 'memoMsg', 'MEMOMSG');
        if (!mensagem.trim()) throw new Error('Digite a mensagem antes de enviar.');
        await callSql(`insert into SmartBox.SOSChat(Obra,Texto,QuemEnviou,DTInsert) select 0${codObra},${sqlString(mensagem)}, 'RBA', getdate()`);
        return messageResult('Mensagem enviada.');
      }
      if (action === 'enviarComando') {
        const comando = field(form, 'comando', 'edtComando', 'EDTCOMANDO');
        if (!comando.trim()) throw new Error('Digite o comando antes de enviar.');
        await callSql(`exec [SmartBox].[USP_LancaAcao] 0${codObra}, ${sqlString(comando)}, 'ACAO'`);
        return messageResult('Comando enviado.');
      }
      if (action === 'manualAtivar') {
        await callSql(`exec [SmartBox].[USP_LancaAcao] 0${codObra}, 'M1', 'ACAO'`);
        return messageResult('Manual cabineiro ativado.');
      }
      if (action === 'manualDesativar') {
        await callSql(`exec [SmartBox].[USP_LancaAcao] 0${codObra}, 'M0', 'ACAO'`);
        return messageResult('Manual cabineiro desativado.');
      }
      if (action === 'manualSubir') {
        await callSql(`exec [SmartBox].[USP_LancaAcao] 0${codObra}, 'm1', 'ACAO'`);
        return messageResult('Comando subir enviado.');
      }
      if (action === 'manualDescer') {
        await callSql(`exec [SmartBox].[USP_LancaAcao] 0${codObra}, 'm2', 'ACAO'`);
        return messageResult('Comando descer enviado.');
      }
      if (action === 'pinout') {
        await callSql(`exec [SmartBox].[USP_LancaAcao] 0${codObra}, 'Z', 'PINOUT'`);
        return messageResult('Comando PinOut enviado.');
      }
      if (action === 'salvarObservacao') {
        const observacao = field(form, 'observacao', 'edtObservacao', 'EDTOBSERVACAO');
        await callSql(`update SmartBox.Atendimentos set Observacao = ${sqlString(observacao)} where Codigo = 0${codAtendimento}`);
        return messageResult('Observação salva.');
      }
      if (action === 'encerrar') {
        await callSql(`update SmartBox.Atendimentos set DTConcluido = GETDATE(), QuemConcluiu = 'RBA', QuemInicioAtendimento = 0${session.codigo} where Codigo = 0${codAtendimento}`);
        return messageResult('Atendimento encerrado.');
      }
      break;
    }

    case 'iam-online': {
      const codObra = obra(form);
      if (action === 'pesquisar') {
        return execHtml(`exec SmartBox.[USP_HTMLTecnicoOnlineIAMOnlinePesquisa] ${sqlString(field(form, 'pesquisar', 'edtPesquisar', 'EDTPESQUISAR'))}, 0${session.codigo}`);
      }
      if (action === 'carregar') {
        const cabecalho = await sqlHtml(`exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineCabecalho 0${codObra}, 0${session.codigo}`);
        const botoes = await sqlHtml(`exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineBotoeriaAcoes 0${codObra}, 0${session.codigo}`);
        return htmlResult(`<div>${cabecalho}</div><hr/><div>${botoes}</div>`);
      }
      if (action === 'valores') {
        return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineValores 0${codObra}, 0${sqlInt(field(form, 'valores', 'edtValores', 'EDTVALORES'))}, 0`);
      }
      if (action === 'atualizarValores') {
        const filtro = field(form, 'valoresFiltro', 'edtValoresFiltro', 'EDTVALORESFILTRO');
        const filtroSql = filtro.trim() ? `, ${sqlString(filtro)}` : '';
        return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineValores 0${codObra}, 0${sqlInt(field(form, 'valores', 'edtValores', 'EDTVALORES'))}, 1${filtroSql}`);
      }
      if (action === 'historicos') {
        return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineHistoricos 0${codObra}, 0${sqlInt(field(form, 'historicos', 'edtHistoricos', 'EDTHISTORICOS'))}`);
      }
      if (action === 'listaComandos' || action === 'atualizarListaComandos') {
        const atualizar = action === 'atualizarListaComandos' ? '1' : '0';
        return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineIAMOnlineComandos 0${sqlInt(field(form, 'listaComando', 'edtListaComando', 'EDTLISTACOMANDO'))}, 0${sqlInt(field(form, 'listaComandoSemEscolha', 'edtListaComandoSemEscolha', 'EDTLISTACOMANDOSEMESCOLHA'))}, ${sqlString(field(form, 'listarComandosFiltrar', 'edtListarComandosFiltrar', 'EDTLISTARCOMANDOSFILTRAR'))}, ${atualizar}`);
      }
      if (action === 'enviarAcao') {
        await requirePermission(session, 'IAM Online: Enviar comando para placa');
        const acao = field(form, 'acao', 'edtAcao', 'EDTACAO');
        if (!acao.trim()) throw new Error('Digite a ação antes de enviar.');
        if (sqlBit(field(form, 'eprom', 'chkEPROM', 'CHKEPROM')) === '1') {
          await callSql(`insert into SmartBox.Acoes(SeqDados,Acao,DataAtualizacao,Tipo) select Seq, '$066', getdate(), 'ACAO' from SmartBox.Dados where Obra = 0${codObra}`);
        }
        await callSql(`insert into SmartBox.Acoes(SeqDados,Acao,DataAtualizacao,Tipo) select Seq, ${sqlString(acao)}, getdate(), 'ACAO' from SmartBox.Dados where Obra = 0${codObra}`);
        if (sqlBit(field(form, 'eprom', 'chkEPROM', 'CHKEPROM')) === '1') {
          await callSql(`insert into SmartBox.Acoes(SeqDados,Acao,DataAtualizacao,Tipo) select Seq, '$105', getdate(), 'ACAO' from SmartBox.Dados where Obra = 0${codObra}`);
        }
        return messageResult('Comando enviado.');
      }
      if (action === 'acionarBotao') {
        await requirePermission(session, 'IAM Online: Enviar chamado de botão para placa');
        await callSql(`exec [SmartBox].[USP_LancaAcao] 0${codObra}, ${sqlString(`r${field(form, 'acionarBotao', 'edtAcionarBotao', 'EDTACIONARBOTAO')}`)}, 'ACAO'`);
        return messageResult('Botão acionado.');
      }
      if (['manualAtivar', 'manualDesativar', 'manualSubir', 'manualDescer'].includes(action)) {
        await requirePermission(session, 'IAM Online: Ação Manual Cabineiro');
        const code = action === 'manualAtivar' ? 'M1' : action === 'manualDesativar' ? 'M0' : action === 'manualSubir' ? 'm1' : 'm2';
        await callSql(`exec [SmartBox].[USP_LancaAcao] 0${codObra}, ${sqlString(code)}, 'ACAO'`);
        return messageResult('Comando manual enviado.');
      }
      if (action === 'pinout') {
        await callSql(`exec [SmartBox].[USP_LancaAcao] 0${codObra}, 'Z', 'PINOUT'`);
        return messageResult('Comando PinOut enviado.');
      }
      if (action === 'whiteList') {
        await requirePermission(session, 'IAM Online: WhiteList Manual');
        await callSql(`update SmartBox.Dados set DiasWhiteList = 1 where Obra = 0${codObra} if Not exists(select 1 from SmartBox.WhiteListManual where Obra = 0${codObra}) begin insert into SmartBox.WhiteListManual(Obra,Data) select 0${codObra}, getdate() end`);
        return messageResult('Inserido na WhiteList.');
      }
      if (action === 'senhaInstalacao') {
        if (field(form, 'liberarEquip', 'edtLiberarEquip', 'EDTLIBERAREQUIP') === '1') {
          await callSql(`update Obras set Dt_IAM_EquipLiberadoInstalacao = getdate() where Seq = 0${codObra}`);
        }
        return messageResult(`Senha para Autorização: ${makeSenhaInstalacao(codObra)}`);
      }
      if (action === 'autorizarInstalacao') {
        await requirePermission(session, 'IAM Online: Autorizar Equipamento Em Instalacao');
        await callSql(`update Obras set Dt_IAM_EquipLiberadoInstalacao = getdate() where Seq = 0${codObra}`);
        await callSql(`insert into SmartBox.Acoes(SeqDados,Acao,DataAtualizacao,Tipo) select Seq, '$066', getdate(), 'ACAO' from SmartBox.Dados where Obra = 0${codObra}`);
        await callSql(`insert into SmartBox.Acoes(SeqDados,Acao,DataAtualizacao,Tipo) select Seq, '$1091', getdate(), 'ACAO' from SmartBox.Dados where Obra = 0${codObra}`);
        await callSql(`insert into SmartBox.Acoes(SeqDados,Acao,DataAtualizacao,Tipo) select Seq, '$105', getdate(), 'ACAO' from SmartBox.Dados where Obra = 0${codObra}`);
        return messageResult('Autorização enviada.');
      }
      if (action === 'mensagemSOS') {
        const mensagem = field(form, 'mensagemSOS', 'edtMensagemSOS', 'EDTMENSAGEMSOS');
        await callSql(`insert into SmartBox.SOSChat(Obra,Texto,QuemEnviou,DTInsert) select 0${codObra},${sqlString(mensagem)}, 'RBA', getdate()`);
        return messageResult('Mensagem SOS enviada.');
      }
      break;
    }

    case 'clientes': {
      if (action === 'pesquisar') {
        return execHtml(`exec SmartBox.[USP_HTMLTecnicoOnlineClientes] ${sqlString(field(form, 'nome', 'edtNome', 'EDTNOME'))}, 0${sqlInt(field(form, 'obra', 'edtObra', 'EDTOBRA'))}, ${sqlString(field(form, 'apelidoObra', 'edtApelidoObra', 'EDTAPELIDOOBRA'))}, ${sqlString(field(form, 'cidade', 'edtCidade', 'EDTCIDADE'))}`);
      }
      if (action === 'visualizar') {
        return execHtml(`exec [SmartBox].[USP_HTMLTecnicoOnlineClientesInformacoes] 0${sqlInt(field(form, 'visualizar', 'edtVisualizar', 'EDTVISUALIZAR'))}`);
      }
      if (action === 'minhaTela') {
        return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineClientesMinhaTela 0${sqlInt(field(form, 'minhaTela', 'edtMinhaTela', 'EDTMINHATELA'))}, 0${session.codigo}, ${sqlString(field(form, 'pesquisarFicha', 'edtPesquisarFicha', 'EDTPESQUISARFICHA'))}`);
      }
      break;
    }

    case 'ficha-tecnica': {
      const ficha = sqlInt(field(form, 'ficha', 'edtFicha', 'EDTFICHA'));
      if (action === 'pesquisar') {
        return execHtml(`exec SmartBox.[USP_HTMLTecnicoOnlineFichaTecnicaPesquisa] ${sqlString(field(form, 'pesquisar', 'edtPesquisar', 'EDTPESQUISAR'))}, 0${session.codigo}, ${sqlInt(field(form, 'dias90', 'edt90Dias', 'EDT90DIAS'))}, 0`);
      }
      if (action === 'pesquisarComFicha') {
        return execHtml(`exec SmartBox.[USP_HTMLTecnicoOnlineFichaTecnicaPesquisa] ${sqlString(field(form, 'pesquisar', 'edtPesquisar', 'EDTPESQUISAR'))}, 0${session.codigo}, 0, 1`);
      }
      if (action === 'carregar') {
        return execHtml(`exec [SmartBox].[USP_HTMLTecnicoOnlineFichaTecnicaCarregar] ${sqlString(ficha)}, 0${session.codigo}, ${sqlString(field(form, 'pesquisarFicha', 'edtPesquisarFicha', 'EDTPESQUISARFICHA'))}`);
      }
      if (action === 'autorizar') {
        await callSql(`exec FichaTecnica.USP_Autorizar ${ficha}, ${session.codigo}`);
        return messageResult('Ficha autorizada.');
      }
      if (action === 'calcular') {
        return execHtml(`exec [FichaTecnica].[USP_Calcular] ${ficha}`);
      }
      if (action === 'acrescimoCompensador') {
        await requirePermission(session, 'Ficha Técnica: Acréscimo Compensador Negativo');
        return execHtml(`update FichaTecnica.FichasTecnicas set AcrescimoCompensador = ${sqlNumber(field(form, 'acrescimoCompensador', 'edtAcrescimoCompensador', 'EDTACRESCIMOCOMPENSADOR'))} where Seq = 0${ficha}; exec [FichaTecnica].[USP_Calcular] ${ficha}`);
      }
      if (action === 'removerAcrescimoCompensador') {
        return execHtml(`update FichaTecnica.FichasTecnicas set AcrescimoCompensador = null where Seq = 0${ficha}; exec [FichaTecnica].[USP_Calcular] ${ficha}`);
      }
      if (action === 'ligarOnline') {
        await callSql(`update FichaTecnica.FichasTecnicas set QuemOnline = 0${session.codigo}, DtOnline = getdate() where Seq = 0${ficha}`);
        return messageResult('Ficha marcada online.');
      }
      if (action === 'desligarOnline') {
        await callSql(`update FichaTecnica.FichasTecnicas set QuemOnline = null, DtOnline = null where Seq = 0${ficha}`);
        return messageResult('Ficha marcada offline.');
      }
      break;
    }

    case 'entrega-tecnica': {
      if (action === 'pesquisar') {
        await requirePermission(session, 'App Corporativo: Gerencial: Entrega Técnica');
        return execHtml(`exec SmartBox.[USP_HTMLTecnicoOnlineEntregaTecnicaPesquisa] ${sqlString(field(form, 'pesquisar', 'edtPesquisar', 'EDTPESQUISAR'))}, 0${session.codigo}`);
      }
      if (action === 'carregar') {
        return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineEntregaTecnicaCarregar 0${obra(form)}, 0${session.codigo}`);
      }
      if (action === 'acessarEntregaTecnica') {
        const ret = await sqlScalar(`exec SmartBox.USP_AcessarEntregaTecnica 0${obra(form)}, 0${session.codigo}, 0${sqlInt(field(form, 'acessarEntregaTecnica', 'edtAcessarEntregaTecnica', 'EDTACESSARENTREGATECNICA'))}`);
        return messageResult(ret || 'Solicitação executada.');
      }
      if (action === 'estruturaEntregaTecnica') {
        await callSql(`exec WhatsApp.USP_EntregaTecnicaEstrutura 0${obra(form)}, 0${session.codigo}`);
        return messageResult('Estrutura de entrega técnica solicitada.');
      }
      break;
    }

    case 'vistorias': {
      const vistoria = sqlInt(field(form, 'vistoria', 'edtVistoria', 'EDTVISTORIA'));
      if (action === 'pesquisar') {
        return execHtml(`exec SmartBox.[USP_HTMLTecnicoOnlineVistoriasPesquisa] ${sqlString(field(form, 'pesquisar', 'edtPesquisar', 'EDTPESQUISAR'))}, 0${session.codigo}`);
      }
      if (action === 'carregar') {
        return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineVistoriasCarregar 0${vistoria}`);
      }
      if (action === 'carregarFicha') {
        return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineVistoriaCarregarFicha ${sqlString(vistoria)}, ${sqlString(field(form, 'pesquisarFicha', 'edtPesquisarFicha', 'EDTPESQUISARFICHA'))}`);
      }
      if (action === 'carregarObra') {
        return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineVistorias 0${obra(form)}`);
      }
      if (action === 'arquivosFotos') {
        return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineVistoriaCarregarImagens 0${vistoria}`);
      }
      if (action === 'envio') {
        const destino = field(form, 'envio', 'edtEnvio', 'EDTENVIO');
        const tipo = field(form, 'envioTipo', 'edtEnvioTipo', 'EDTENVIOtipo').toLowerCase();
        if (tipo.includes('whats')) {
          await requirePermission(session, 'Vistorias: Enviar WhatsApp');
          await callSql(`exec dbo.USP_EnviaWhatsAppVistoria 0${vistoria}, ${sqlString(destino)}`);
        } else {
          await requirePermission(session, 'Vistorias: Enviar E-Mail');
          await callSql(`exec dbo.USP_EnviaEmailVistoria 0${vistoria}, ${sqlString(destino)}`);
        }
        return messageResult('Envio solicitado.');
      }
      if (action === 'solicitaAditivo') {
        const codObra = await sqlScalar(`select Obra from ObraVistorias where Seq = 0${vistoria}`);
        await callSql(`insert into SolicitacaoAditivo(Obra,Status,UsuInsert,Descricao) select 0${sqlInt(codObra)}, 'Aditivo Solicitado', 0${session.codigo}, ${sqlString(field(form, 'descAditivo', 'memoDescAditivo', 'MEMODESCAditivo'))}`);
        return messageResult('Solicitação de aditivo lançada.');
      }
      if (action === 'lancaFollowUp') {
        const ret = await sqlScalar(`exec Telas.USP_LancaFollowUP @Obra = 0${obra(form)}, @Usuario = ${session.codigo}, @ConseguiuContato = ${sqlString(field(form, 'conseguiuContato', 'cbxConseguiuContato', 'CBXCONSEGUIUCONTATO'))}, @Observacao = ${sqlString(field(form, 'detalheContato', 'memoDetalheContato', 'MEMODETALHECONTATO'))}, @Tipo = 'Civil', @NomeContato = ${sqlString(field(form, 'nomeContato', 'edtNomeContato', 'EDTNOMECONTATO'))}`);
        return messageResult(ret !== '0' ? 'Follow-up lançado.' : 'Follow-up não foi lançado.');
      }
      break;
    }

    case 'os': {
      if (action === 'pesquisar') {
        return execHtml(`exec SmartBox.[USP_HTMLTecnicoOnlineOSPesquisa] ${sqlString(field(form, 'pesquisar', 'edtPesquisar', 'EDTPESQUISAR'))}`);
      }
      if (action === 'carregar') {
        return execHtml(`exec SmartBox.[USP_HTMLTecnicoOnlineOS] ${sqlString(field(form, 'os', 'edtOS', 'EDTOS'))}`);
      }
      if (action === 'autorizar') {
        return execHtml(`exec SmartBox.[USP_HTMLTecnicoOnlineOSAutorizar] ${sqlString(field(form, 'os', 'edtOS', 'EDTOS'))}`);
      }
      break;
    }

    case 'notificacoes': {
      if (action === 'listar') {
        return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineNotificacoes 0${session.codigo}`);
      }
      if (action === 'pesquisar') {
        return execHtml(`exec SmartBox.[USP_HTMLTecnicoOnlineNotificacoesPesquisa] ${sqlString(field(form, 'pesquisar', 'edtPesquisar', 'EDTPESQUISAR'))}`);
      }
      if (action === 'salvar') {
        const ret = await sqlScalar(`exec SmartBox.USP_CorporativoLancarNotificacao ${sqlString(field(form, 'titulo', 'edtTitulo', 'EDTTITULO'))}, ${sqlString(field(form, 'mensagem', 'edtMensagem', 'EDTMENSAGEM'))}, 0${sqlInt(field(form, 'usuario', 'edtUsuario', 'EDTUSUARIO'))}, 0${session.codigo}`);
        return messageResult(ret || 'Notificação lançada.');
      }
      break;
    }

    case 'abrir-sac': {
      if (action === 'confirmar') {
        await callSql(`insert into PendenciasGeral (DtInsert, Titulo, Descricao, Informacoes, Prazo, Tipo, TipoOrigem, UsuInsert) select getdate(), ${sqlString(field(form, 'titulo', 'EdtTitulo', 'EDTTITULO'))}, ${sqlString(field(form, 'descricao', 'MemDescricao', 'MEMDESCRICAO'))}, ${sqlString(field(form, 'info', 'MemInfo', 'MEMINFO'))}, getdate(), 'SAC', 'App Corporativo', 0${session.codigo}`);
        return messageResult('SAC aberto com sucesso.');
      }
      break;
    }

    case 'acoes-especiais': {
      if (action === 'listar') return execHtml('exec SmartBox.USP_HTMLTecnicoOnlineAcoesEspeciais');
      if (action === 'grupo') return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineAcoesEspeciaisBotoes ${sqlString(field(form, 'grupo', 'edtGrupo', 'EDTGRUPO'))}`);
      if (action === 'executar') return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineAcoesEspeciaisExecutar 0${sqlInt(field(form, 'executar', 'edtExecutar', 'EDTEXECUTAR'))}`);
      break;
    }

    case 'suporte-tecnico': {
      if (action === 'inicial') return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineOrientacoesPesquisa ''`);
      if (action === 'pesquisar') return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineOrientacoesPesquisa ${sqlString(field(form, 'pesquisar', 'edtPesquisar', 'EDTPESQUISAR'))}`);
      if (action === 'carregar') return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineOrientacoesCarregar 0${sqlInt(field(form, 'orientacao', 'edtOrientacao', 'EDTORIENTACAO'))}`);
      break;
    }

    case 'ramais': {
      if (action === 'listar') return execHtml('exec SmartBox.USP_HTMLTecnicoOnlineRamais');
      break;
    }

    case 'plantonistas-sos': {
      if (action === 'listar') return execHtml('exec SmartBox.USP_HTMLTecnicoOnlinePlantonistasSOS');
      break;
    }

    case 'holerites': {
      if (action === 'listar') {
        await callSql('delete from Arquivos.dbo.ArquivosTempURL where not DtCriouServidor is null and Arquivo is null');
        return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineHolerites 0${session.codigo}`);
      }
      if (action === 'baixar') {
        const seq = sqlInt(field(form, 'seqArquivo', 'edtSeqArquivo', 'EDTSEQARQUIVO'));
        return execRows(`select * from Arquivos.dbo.ArquivosTempURL where Seq = 0${seq}`);
      }
      break;
    }

    case 'indices': {
      if (action === 'listar') return execHtml(`exec SmartBox.USP_HTMLTecnicoOnlineIndices 0${session.codigo}`);
      if (action === 'executarScript') {
        const script = field(form, 'script', 'edtScript', 'EDTSCRIPT');
        if (!script.trim()) throw new Error('Informe o script.');
        return execRows(script);
      }
      break;
    }

    case 'query': {
      if (action === 'executar') {
        const script = field(form, 'script', 'memoScript', 'MEMOSCRIPT');
        if (!script.trim()) throw new Error('Informe o script.');
        return execRows(script);
      }
      break;
    }

    case 'informacoes-empresa': {
      if (action === 'carregar') {
        return htmlResult(`<div class="text-center p-4"><img src="/wwwroot/LogoRBAAzul.png" class="img-fluid mb-3" style="max-width:220px"/><h4>RBA Elevadores</h4><p>Informações institucionais migradas do app corporativo.</p></div>`);
      }
      break;
    }
  }

  throw new Error(`Ação não mapeada: ${moduleKey}/${action}`);
}

export function legacyComponentToAction(moduleKey: string, component: string): string | null {
  const normalized = component.replace(/^BTN/i, 'btn').replace(/^EDT/i, 'edt').replace(/^MEMO/i, 'memo');
  const maps: Record<string, Record<string, string>> = {
    main: {
      btnSair: 'logout', btnClientes: 'navigate:clientes', btnEntregaTecnica: 'navigate:entrega-tecnica', btnFichaTecnica: 'navigate:ficha-tecnica', btnIAMOnline: 'navigate:iam-online', btnOS: 'navigate:os', btnSOS: 'navigate:principal', btnSuporteTecnico: 'navigate:suporte-tecnico', btnVistorias: 'navigate:vistorias', btnPlantonistasSOS: 'navigate:plantonistas-sos', btnAcoesEspeciais: 'navigate:acoes-especiais', btnQuery: 'navigate:query'
    },
    principal: { btnAtender: 'atender', btnVoltar: 'navigate:main' },
    chat: { btnAtender: 'carregar', btnAudio: 'enviarMensagem', btnPinOut: 'pinout', btnManualCabineiroAtivar: 'manualAtivar', btnManualCabineiroDesativar: 'manualDesativar', btnManualCabineiroSubir: 'manualSubir', btnManualCabineiroDescer: 'manualDescer', btnVoltar: 'navigate:principal' },
    clientes: { btnPesquisar: 'pesquisar', btnVisualizar: 'visualizar', btnMinhaTela: 'minhaTela', btnVoltar: 'navigate:main' },
    'ficha-tecnica': { btnPesquisar: 'pesquisar', btnCarregar: 'carregar', btnAutorizar: 'autorizar', btnAcrescimoCompensador: 'acrescimoCompensador', btnAcrescimoCompensadorRemover: 'removerAcrescimoCompensador', btnLigarOnline: 'ligarOnline', btnDesligarOnline: 'desligarOnline', btnVoltar: 'navigate:main' },
    'iam-online': { btnPesquisar: 'pesquisar', btnCarregar: 'carregar', btnValores: 'valores', btnAtualizarValores: 'atualizarValores', btnHistoricos: 'historicos', btnListaComando: 'listaComandos', btnAtualizarListaComandos: 'atualizarListaComandos', btnAcionarBotao: 'acionarBotao', btnManualCabineiroAtivar: 'manualAtivar', btnManualCabineiroDesativar: 'manualDesativar', btnManualCabineiroSubir: 'manualSubir', btnManualCabineiroDescer: 'manualDescer', btnPinOut: 'pinout', btnWhiteList: 'whiteList', btnEmInstalacaoSenha: 'senhaInstalacao', btnEmInstalacaoAutorizar: 'autorizarInstalacao', btnMensagemSOS: 'mensagemSOS', btnVoltar: 'navigate:main' },
    'entrega-tecnica': { btnPesquisar: 'pesquisar', btnCarregar: 'carregar', btnAcessarEntregaTecnica: 'acessarEntregaTecnica', btnEstruturaEntregaTecnica: 'estruturaEntregaTecnica', btnVoltar: 'navigate:main' },
    vistorias: { btnPesquisar: 'pesquisar', btnCarregar: 'carregar', btnCarregarVistoria: 'carregar', btnCarregarFicha: 'carregarFicha', btnArquivosFotos: 'arquivosFotos', btnEnvio: 'envio', btnSolicitaAditivo: 'solicitaAditivo', btnLancaFollowUp: 'lancaFollowUp', btnVoltar: 'navigate:main' },
    os: { btnPesquisar: 'pesquisar', btnOS: 'carregar', btnAutorizar: 'autorizar', btnVoltar: 'navigate:main' },
    notificacoes: { btnPesquisar: 'pesquisar', btnSalvarNotificacao: 'salvar', btnVoltar: 'navigate:main' },
    'abrir-sac': { IWBtnConfirma: 'confirmar', IWBtnCancel: 'navigate:main', btnVoltar: 'navigate:main' },
    'acoes-especiais': { btnGrupo: 'grupo', btnExecutar: 'executar', btnVoltar: 'navigate:main' },
    'suporte-tecnico': { btnPesquisar: 'pesquisar', btnCarregar: 'carregar', btnVoltar: 'navigate:main' },
    ramais: { btnVoltar: 'navigate:main' },
    'plantonistas-sos': { btnVoltar: 'navigate:main' },
    holerites: { btnBaixar: 'baixar', btnVoltar: 'navigate:main' },
    indices: { btnScript: 'executarScript', btnVoltar: 'navigate:main' },
    query: { btnVoltar: 'navigate:main' }
  };
  return maps[moduleKey]?.[normalized] ?? null;
}
