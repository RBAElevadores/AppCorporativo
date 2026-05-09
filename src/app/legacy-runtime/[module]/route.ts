import fs from 'fs/promises';
import path from 'path';
import { NextRequest, NextResponse } from 'next/server';
import { AUTH_COOKIE, parseSessionCookie, type AppSession } from '@/lib/session';
import { getModuleDefinition, MODULES } from '@/lib/modules';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

const NAV_BUTTONS: Record<string, string> = {
  BTNCLIENTES: '/legacy-runtime/clientes',
  BTNIAMONLINE: '/legacy-runtime/iam-online',
  BTNSOS: '/legacy-runtime/principal',
  BTNSUPORTETECNICO: '/legacy-runtime/suporte-tecnico',
  BTNSENHAMASTER: '/legacy-runtime/iam-online',
  BTNPLANTONISTASSOS: '/legacy-runtime/plantonistas-sos',
  BTNFICHATECNICA: '/legacy-runtime/ficha-tecnica',
  BTNOS: '/legacy-runtime/os',
  BTNENTREGATECNICA: '/legacy-runtime/entrega-tecnica',
  BTNVISTORIAS: '/legacy-runtime/vistorias',
  BTNQUERY: '/legacy-runtime/query',
  BTNACOESPECIAIS: '/legacy-runtime/acoes-especiais',
  BTNNOTIFICACOES: '/legacy-runtime/notificacoes',
  BTNHOLERITES: '/legacy-runtime/holerites',
  BTNINDICES: '/legacy-runtime/indices',
  BTNABRIRSAC: '/legacy-runtime/abrir-sac',
  BTNIAMONLINECHAT: '/legacy-runtime/iam-online'
};


const COMPONENT_LABELS: Record<string, string> = {
  btnVistorias: 'Civil'
};

const COMPONENT_IDS: Record<string, string> = {
  btnClientes: 'BTNCLIENTES',
  btnIAMOnline: 'BTNIAMONLINE',
  btnSOS: 'BTNSOS',
  btnSuporteTecnico: 'BTNSUPORTETECNICO',
  btnSenhaMaster: 'BTNSENHAMASTER',
  btnPlantonistasSOS: 'BTNPLANTONISTASSOS',
  btnFichaTecnica: 'BTNFICHATECNICA',
  btnOS: 'BTNOS',
  btnEntregaTecnica: 'BTNENTREGATECNICA',
  btnVistorias: 'BTNVISTORIAS',
  btnQuery: 'BTNQUERY',
  btnAcoesEspeciais: 'BTNACOESPECIAIS',
  btnSair: 'BTNSAIR',
  btnVoltar: 'BTNVOLTAR',
  btnAtender: 'BTNATENDER',
  btnPesquisar: 'BTNPESQUISAR',
  btnVisualizar: 'BTNVISUALIZAR',
  btnMinhaTela: 'BTNMINHATELA',
  btnCarregar: 'BTNCARREGAR',
  btnValores: 'BTNVALORES',
  btnHistoricos: 'BTNHISTORICOS',
  btnListaComando: 'BTNLISTACOMANDO',
  btnAtualizarListaComandos: 'BTNATUALIZARLISTACOMANDOS',
  btnAtualizarValores: 'BTNATUALIZARVALORES',
  btnAcionarBotao: 'BTNACIONARBOTAO',
  btnManualCabineiroAtivar: 'BTNMANUALCABINEIROATIVAR',
  btnManualCabineiroDesativar: 'BTNMANUALCABINEIRODESATIVAR',
  btnManualCabineiroSubir: 'BTNMANUALCABINEIROSUBIR',
  btnManualCabineiroDescer: 'BTNMANUALCABINEIRODESCER',
  btnPinOut: 'BTNPINOUT',
  btnWhiteList: 'BTNWHITELIST',
  btnEmInstalacaoSenha: 'BTNEMINSTALACAOSENHA',
  btnEmInstalacaoAutorizar: 'BTNEMINSTALACAOAUTORIZAR',
  btnMensagemSOS: 'BTNMENSAGEMSOS',
  btnAutorizar: 'BTNAUTORIZAR',
  btnAcrescimoCompensador: 'BTNACRESCIMOCOMPENSADOR',
  btnAcrescimoCompensadorRemover: 'BTNACRESCIMOCOMPENSADORREMOVER',
  btnLigarOnline: 'BTNLIGARONLINE',
  btnDesligarOnline: 'BTNDESLIGARONLINE',
  btnAcessarEntregaTecnica: 'BTNACESSARENTREGATECNICA',
  btnEstruturaEntregaTecnica: 'BTNESTRUTURAENTREGATECNICA',
  btnCarregarFicha: 'BTNCARREGARFICHA',
  btnCarregarVistoria: 'BTNCARREGARVISTORIA',
  btnArquivosFotos: 'BTNARQUIVOSFOTOS',
  btnEnvio: 'BTNENVIO',
  btnSolicitaAditivo: 'BTNSOLICITAADITIVO',
  btnLancaFollowUp: 'BTNLANCAFOLLOWUP',
  btnSalvarNotificacao: 'BTNSALVARNOTIFICACAO',
  btnExecutar: 'BTNEXECUTAR',
  btnGrupo: 'BTNGRUPO',
  btnScript: 'BTNSCRIPT',
  btnBaixar: 'BTNBAIXAR',
  IWBtnConfirma: 'IWBTNCONFIRMA',
  IWBtnCancel: 'IWBTNCANCEL'
};

const ACTION_BUTTONS: Record<string, Record<string, string>> = {
  principal: { BTNATENDER: 'atender' },
  clientes: { BTNPESQUISAR: 'pesquisar', BTNVISUALIZAR: 'visualizar', BTNMINHATELA: 'minhaTela' },
  'iam-online': {
    BTNPESQUISAR: 'pesquisar', BTNCARREGAR: 'carregar', BTNVALORES: 'valores', BTNATUALIZARVALORES: 'atualizarValores',
    BTNHISTORICOS: 'historicos', BTNLISTACOMANDO: 'listaComandos', BTNATUALIZARLISTACOMANDOS: 'atualizarListaComandos',
    BTNACAO: 'enviarAcao', BTNACIONARBOTAO: 'acionarBotao', BTNMANUALCABINEIROATIVAR: 'manualAtivar',
    BTNMANUALCABINEIRODESATIVAR: 'manualDesativar', BTNMANUALCABINEIROSUBIR: 'manualSubir',
    BTNMANUALCABINEIRODESCER: 'manualDescer', BTNPINOUT: 'pinout', BTNWHITELIST: 'whiteList',
    BTNEMINSTALACAOSENHA: 'senhaInstalacao', BTNEMINSTALACAOAUTORIZAR: 'autorizarInstalacao', BTNMENSAGEMSOS: 'mensagemSOS'
  },
  chat: {
    BTNATENDER: 'carregar', BTNENVIAR: 'enviarMensagem', BTNENVIARCOMANDO: 'enviarComando', BTNENCERRAR: 'encerrar',
    BTNMANUALCABINEIROATIVAR: 'manualAtivar', BTNMANUALCABINEIRODESATIVAR: 'manualDesativar',
    BTNMANUALCABINEIROSUBIR: 'manualSubir', BTNMANUALCABINEIRODESCER: 'manualDescer', BTNPINOUT: 'pinout'
  },
  'ficha-tecnica': {
    BTNPESQUISAR: 'pesquisar', BTNCARREGAR: 'carregar', BTNAUTORIZAR: 'autorizar', BTNCALCULAR: 'calcular',
    BTNACRESCIMOCOMPENSADOR: 'acrescimoCompensador', BTNACRESCIMOCOMPENSADORREMOVER: 'removerAcrescimoCompensador',
    BTNLIGARONLINE: 'ligarOnline', BTNDESLIGARONLINE: 'desligarOnline'
  },
  'entrega-tecnica': { BTNPESQUISAR: 'pesquisar', BTNCARREGAR: 'carregar', BTNACESSARENTREGATECNICA: 'acessarEntregaTecnica', BTNESTRUTURAENTREGATECNICA: 'estruturaEntregaTecnica' },
  vistorias: { BTNPESQUISAR: 'pesquisar', BTNCARREGAR: 'carregar', BTNCARREGARFICHA: 'carregarFicha', BTNCARREGARVISTORIA: 'carregar', BTNARQUIVOSFOTOS: 'arquivosFotos', BTNENVIO: 'envio', BTNSOLICITAADITIVO: 'solicitaAditivo', BTNLANCAFOLLOWUP: 'lancaFollowUp' },
  os: { BTNPESQUISAR: 'pesquisar', BTNOS: 'carregar', BTNAUTORIZAR: 'autorizar' },
  notificacoes: { BTNPESQUISAR: 'pesquisar', BTNSALVARNOTIFICACAO: 'salvar' },
  'suporte-tecnico': { BTNPESQUISAR: 'pesquisar', BTNCARREGAR: 'carregar' },
  'acoes-especiais': { BTNEXECUTAR: 'executar', BTNGRUPO: 'grupo' },
  indices: { BTNSCRIPT: 'executarScript' },
  holerites: { BTNBAIXAR: 'baixar' },
  'abrir-sac': { IWBTNCONFIRMA: 'salvar', IWBTNCANCEL: '__back' }
};

const LOAD_ACTION: Record<string, string> = {
  main: 'menu',
  principal: 'meusAtendimentos',
  chat: 'carregar',
  notificacoes: 'listar',
  indices: 'listar'
};

const DEFAULT_TARGET: Record<string, string> = {
  main: 'corpo',
  principal: 'atendimentos',
  clientes: 'TableClientes',
  'iam-online': 'dados',
  chat: 'mensagens',
  'ficha-tecnica': 'TableFichas',
  'entrega-tecnica': 'corpo',
  vistorias: 'TableVistorias',
  os: 'tableOS',
  notificacoes: 'tableNotificacoes',
  'suporte-tecnico': 'TablePesquisa',
  'acoes-especiais': 'corpo',
  indices: 'corpo',
  query: 'corpo'
};

function escapeHtml(value: unknown): string {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function escapeScript(value: unknown): string {
  return JSON.stringify(value).replace(/</g, '\\u003c');
}

function componentId(name: string): string {
  return COMPONENT_IDS[name] || name.toUpperCase();
}

function labelFromComponent(name: string): string {
  if (COMPONENT_LABELS[name]) return COMPONENT_LABELS[name];

  const clean = name
    .replace(/^btn/i, '')
    .replace(/^IWBtn/i, '')
    .replace(/([a-z])([A-Z])/g, '$1 $2')
    .replace(/OS/g, 'O.S.')
    .replace(/IAM/g, 'IAM')
    .trim();
  return (clean || name).toUpperCase();
}

function renderComponent(name: string, session: AppSession): string {
  if (name === 'lblBemVindo') return escapeHtml(session.nome);
  const id = componentId(name);
  const lower = name.toLowerCase();

  if (lower.startsWith('lbl')) return `<span id="${id}"></span>`;
  if (lower.startsWith('memo') || lower.startsWith('mem')) return `<textarea class="form-control" id="${id}" name="${id}" rows="3"></textarea>`;
  if (lower.startsWith('chk')) return `<input class="form-check-input" type="checkbox" id="${id}" name="${id}">`;
  if (lower.startsWith('cbx')) return `<select class="form-control" id="${id}" name="${id}"><option value=""></option><option value="Sim">Sim</option><option value="Não">Não</option></select>`;
  if (lower.startsWith('edt')) return `<input type="text" class="form-control" id="${id}" name="${id}">`;
  if (lower.startsWith('btn') || lower.startsWith('iwbtn')) return `<button type="button" class="btn btn-primary" id="${id}">${escapeHtml(labelFromComponent(name))}</button>`;
  return '';
}

function fixAssetPaths(html: string): string {
  return html
    .replace(/\.\.\/wwwroot\//gi, '/wwwroot/')
    .replace(/href="\/wwwroot\/ico\.png"/gi, 'href="/wwwroot/Ico.png"')
    .replace(/url\((['"]?)FundoCinza2\.png\1\)/gi, "url('/wwwroot/FundoCinza2.png')")
    .replace(/url\((['"]?)LogoRBAAzulOpaco\.png\1\)/gi, "url('/wwwroot/LogoRBAAzulOpaco.png')");
}

function injectCompatibilityScript(html: string, moduleKey: string, moduleTitle: string): string {
  const script = `
<script>
(function(){
  const moduleKey = ${escapeScript(moduleKey)};
  const moduleTitle = ${escapeScript(moduleTitle)};
  const navButtons = ${escapeScript(NAV_BUTTONS)};
  const actionButtons = ${escapeScript(ACTION_BUTTONS[moduleKey] || {})};
  const loadAction = ${escapeScript(LOAD_ACTION[moduleKey] || '')};
  const defaultTarget = ${escapeScript(DEFAULT_TARGET[moduleKey] || 'corpo')};

  window.AddChangedControl = window.AddChangedControl || function(){};

  function byId(id){ return document.getElementById(id); }

  function collectForm(){
    const data = {};
    document.querySelectorAll('input, textarea, select').forEach(function(el){
      if (!el.id && !el.name) return;
      const key = el.id || el.name;
      if (el.type === 'checkbox') data[key] = el.checked;
      else data[key] = el.value;
    });
    return data;
  }

  function chooseTarget(result){
    return (result && result.target) || defaultTarget;
  }

  function setHtml(target, html){
    const targetId = target || defaultTarget;
    const el = byId(targetId) || byId(defaultTarget) || byId('corpo') || byId('atendimentos') || byId('dados') || byId('TableClientes') || byId('TableFichas') || byId('TableVistorias') || byId('tableOS') || byId('tableNotificacoes') || byId('corpoModalMensagem');
    if (el) {
      el.innerHTML = html || '';
      if (typeof window.RBAMainAfterRender === 'function') {
        try { window.RBAMainAfterRender(); } catch(e) {}
      }
    }
  }


  function startsWithLegacyPrefix(text){
    const t = String(text || '').trim();

    return (
      t.startsWith('tabela =') ||
      t.startsWith('tabela=') ||
      t.startsWith('arrayGrafico =') ||
      t.startsWith('arrayGrafico=') ||
      t.startsWith('function ') ||
      t.startsWith("$('#corpo').html") ||
      t.startsWith('$("#corpo").html') ||
      t.startsWith("$( '#corpo' ).html") ||
      t.startsWith('$( "#corpo" ).html')
    );
  }

  function looksLikeLegacyScript(value){
    const text = String(value || '').trim();
    if (!text) return false;

    return (
      text.indexOf('arrayGrafico') >= 0 ||
      text.indexOf('drawTable') >= 0 ||
      text.indexOf('visualizar(') >= 0 ||
      text.indexOf('document.getElementById') >= 0 ||
      text.indexOf('btnFechaModal') >= 0 ||
      text.indexOf('rodaScript(') >= 0 ||
      text.indexOf("$('#corpo').html") >= 0 ||
      text.indexOf('$("#corpo").html') >= 0 ||
      text.indexOf("$( '#corpo' ).html") >= 0 ||
      text.indexOf('$( "#corpo" ).html') >= 0 ||
      startsWithLegacyPrefix(text)
    );
  }


  function ensureLegacyGlobals(){
    const noopButton = { click: function(){} };

    window.btnFechaModalToken = window.btnFechaModalToken || byId('btnFechaModalToken') || noopButton;
    window.btnModalToken = window.btnModalToken || byId('btnModalToken') || noopButton;
    window.btnFechaModalMensagem = window.btnFechaModalMensagem || byId('btnFechaModalMensagem') || noopButton;
    window.btnModalMensagem = window.btnModalMensagem || byId('btnModalMensagem') || noopButton;

    window.btnFechaModalNotificacao = window.btnFechaModalNotificacao || byId('btnFechaModalNotificacao') || noopButton;
    window.btnModalNotificacao = window.btnModalNotificacao || byId('btnModalNotificacao') || noopButton;
  }

  function decodeBasicJsString(raw){
    let out = '';
    const slash = String.fromCharCode(92);
    const nl = String.fromCharCode(10);
    const cr = String.fromCharCode(13);
    const tab = String.fromCharCode(9);

    for (let i = 0; i < raw.length; i++) {
      const ch = raw.charAt(i);

      if (ch !== slash) {
        out += ch;
        continue;
      }

      const next = raw.charAt(i + 1);
      i++;

      if (next === 'n') out += nl;
      else if (next === 'r') out += cr;
      else if (next === 't') out += tab;
      else if (next === slash) out += slash;
      else if (next === "'") out += "'";
      else if (next === '"') out += '"';
      else out += next;
    }

    return out;
  }

  function isSpaceChar(ch){
    const code = ch.charCodeAt(0);
    return code === 32 || code === 10 || code === 13 || code === 9;
  }

  function extractLegacyHtmlAssignment(scriptText){
    const text = String(scriptText || '');

    if (text.indexOf('#corpo') < 0 || text.indexOf('.html') < 0) {
      return null;
    }

    const htmlIndex = text.indexOf('.html');
    const openParen = text.indexOf('(', htmlIndex);

    if (openParen < 0) {
      return null;
    }

    let i = openParen + 1;

    while (i < text.length && isSpaceChar(text.charAt(i))) {
      i++;
    }

    const quote = text.charAt(i);

    if (quote !== "'" && quote !== '"') {
      return null;
    }

    i++;

    let raw = '';
    const slash = String.fromCharCode(92);

    for (; i < text.length; i++) {
      const ch = text.charAt(i);

      if (ch === slash) {
        raw += ch;

        if (i + 1 < text.length) {
          raw += text.charAt(i + 1);
          i++;
        }

        continue;
      }

      if (ch === quote) {
        return decodeBasicJsString(raw);
      }

      raw += ch;
    }

    return null;
  }

  function applyLegacyHtmlAssignment(scriptText){
    const html = extractLegacyHtmlAssignment(scriptText);

    if (html === null) {
      return false;
    }

    const target = byId('corpo') || byId('resultado') || byId('ResultadoMigracao');

    if (!target) {
      return false;
    }

    target.innerHTML = html;

    if (typeof window.RBAMainAfterRender === 'function') {
      try { window.RBAMainAfterRender(); } catch(e) {}
    }

    return true;
  }

  function runLegacyScript(value){
    ensureLegacyGlobals();

    const scriptText = String(value || '').trim();

    if (!scriptText) {
      return;
    }

    function executeScript(){
      new Function(scriptText)();
    }

    try {
      if (applyLegacyHtmlAssignment(scriptText)) {
        return;
      }

      const precisaGoogleCharts =
        scriptText.indexOf('drawTable') >= 0 ||
        scriptText.indexOf('arrayGrafico') >= 0 ||
        scriptText.indexOf('google.visualization') >= 0;

      if (!precisaGoogleCharts) {
        executeScript();
        return;
      }

      if (window.google && google.visualization && (google.visualization.Table || google.visualization.ComboChart)) {
        executeScript();
        return;
      }

      if (window.google && google.charts && typeof google.charts.load === 'function') {
        google.charts.load('current', { packages: ['table', 'corechart'] });
        google.charts.setOnLoadCallback(executeScript);
        return;
      }

      executeScript();
    } catch (scriptError) {
      if (applyLegacyHtmlAssignment(scriptText)) {
        return;
      }

      throw new Error(
        'Erro ao montar retorno legado: ' +
        (scriptError && scriptError.message ? scriptError.message : String(scriptError))
      );
    }
  }

  function showMessage(title, html){
    if (typeof window.mensagem === 'function') {
      try { window.mensagem(title || moduleTitle, html || '', 0, 1, 0); return; } catch(e) {}
    }
    const el = byId('corpoModalMensagem');
    if (el) el.innerHTML = '<div class="alert alert-info">' + (html || '') + '</div>';
    else if (html) alert(String(html).replace(/<[^>]*>/g, ''));
  }

  async function postAction(action){
    if (!action) return;
    if (action === '__back') { window.location.href = '/legacy-runtime/main'; return; }
    try {
      const response = await fetch('/api/modules/' + encodeURIComponent(moduleKey) + '/' + encodeURIComponent(action), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(collectForm())
      });
      const result = await response.json();
      if (!response.ok || !result.ok) throw new Error(result.message || 'Erro ao executar ação.');

      const data = result && result.data ? result.data : {};

      if (data.script) {
        runLegacyScript(data.script);
      }

      if (result.html !== undefined) {
        const htmlText = String(result.html ?? '');

        if (looksLikeLegacyScript(htmlText)) {
          const target = byId(chooseTarget(result));
          if (target) target.innerHTML = '';
          runLegacyScript(htmlText);
        } else {
          setHtml(chooseTarget(result), result.html);
        }
      }

      if (result.message) showMessage(moduleTitle, result.message);
    } catch (e) {
      showMessage('Erro', e && e.message ? e.message : String(e));
    }
  }

  function bindClick(id, fn){
    const el = byId(id);
    if (el) el.addEventListener('click', function(ev){ ev.preventDefault(); fn(); });
  }

  Object.keys(navButtons).forEach(function(id){ bindClick(id, function(){ window.location.href = navButtons[id]; }); });
  Object.keys(actionButtons).forEach(function(id){ bindClick(id, function(){ postAction(actionButtons[id]); }); });
  bindClick('BTNVOLTAR', function(){ window.location.href = '/legacy-runtime/main'; });
  bindClick('BTNSAIR', async function(){ await fetch('/api/auth/logout', { method: 'POST' }); window.location.href = '/login'; });

  // Alguns HTMLs retornados pelo banco chamam diretamente BTNs ocultos do IntraWeb.
  Object.keys(navButtons).forEach(function(id){ if (!window[id]) window[id] = byId(id); });
  Object.keys(actionButtons).forEach(function(id){ if (!window[id]) window[id] = byId(id); });

  if (loadAction) postAction(loadAction);
  else if (typeof window.RBAMainAfterRender === 'function') {
    try { window.RBAMainAfterRender(); } catch(e) {}
  }
})();
</script>`;

  return html.includes('</body>') ? html.replace('</body>', `${script}\n</body>`) : `${html}\n${script}`;
}

async function loadTemplate(template: string): Promise<string> {
  const candidates = [
    path.join(process.cwd(), 'legacy', 'templates', template),
    path.join(process.cwd(), 'public', 'legacy', template)
  ];

  for (const candidate of candidates) {
    try {
      return await fs.readFile(candidate, 'utf8');
    } catch {
      // try next path
    }
  }

  throw new Error(`Template legado não encontrado: ${template}`);
}

function renderLegacyHtml(raw: string, moduleKey: string, moduleTitle: string, session: AppSession): string {
  let html = fixAssetPaths(raw);
  html = html.replace(/\{%\s*([^%]+?)\s*%\}/g, (_match, name: string) => renderComponent(String(name).trim(), session));
  html = injectCompatibilityScript(html, moduleKey, moduleTitle);
  return html;
}

export async function GET(request: NextRequest, { params }: { params: { module: string } }) {
  const session = parseSessionCookie(request.cookies.get(AUTH_COOKIE)?.value);
  if (!session) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  const moduleDefinition = getModuleDefinition(params.module) || MODULES.main;
  if (!moduleDefinition.legacyTemplate) {
    return NextResponse.redirect(new URL('/legacy-runtime/main', request.url));
  }

  try {
    const raw = await loadTemplate(moduleDefinition.legacyTemplate);
    const html = renderLegacyHtml(raw, moduleDefinition.key, moduleDefinition.title, session);
    return new NextResponse(html, {
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
        'Cache-Control': 'no-store'
      }
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Erro ao carregar tela legada.';
    return new NextResponse(`<!doctype html><html lang="pt-br"><body><pre>${escapeHtml(message)}</pre></body></html>`, {
      status: 500,
      headers: { 'Content-Type': 'text/html; charset=utf-8' }
    });
  }
}
