export type FieldType = 'text' | 'password' | 'number' | 'textarea' | 'checkbox' | 'select';

export type FieldDefinition = {
  name: string;
  label: string;
  type?: FieldType;
  placeholder?: string;
  defaultValue?: string;
  options?: string[];
};

export type ActionDefinition = {
  id: string;
  label: string;
  variant?: 'primary' | 'secondary' | 'success' | 'danger' | 'warning' | 'outline-dark';
  confirm?: string;
};

export type ModuleDefinition = {
  key: string;
  title: string;
  description: string;
  legacyTemplate?: string;
  loadAction?: string;
  fields: FieldDefinition[];
  actions: ActionDefinition[];
};

export const MODULES: Record<string, ModuleDefinition> = {
  main: {
    key: 'main',
    title: 'Menu Principal',
    description: 'Menu inicial e atalhos principais do app corporativo.',
    legacyTemplate: 'IWformMain.html',
    loadAction: 'menu',
    fields: [],
    actions: [{ id: 'menu', label: 'Atualizar menu', variant: 'primary' }]
  },
  principal: {
    key: 'principal',
    title: 'Principal / Atendimentos SOS',
    description: 'Lista de atendimentos e abertura de atendimento SOS.',
    legacyTemplate: 'IWformPrincipal.html',
    loadAction: 'meusAtendimentos',
    fields: [{ name: 'atendimento', label: 'Código do Atendimento', type: 'number', placeholder: 'Ex.: 12345' }],
    actions: [
      { id: 'meusAtendimentos', label: 'Meus atendimentos', variant: 'primary' },
      { id: 'todosAtendimentos', label: 'Todos atendimentos', variant: 'secondary' },
      { id: 'atender', label: 'Atender código informado', variant: 'success' }
    ]
  },
  chat: {
    key: 'chat',
    title: 'Chat SOS',
    description: 'Conversa com equipamento/tablet, comandos e encerramento de atendimento.',
    legacyTemplate: 'IWformChat.html',
    loadAction: 'carregar',
    fields: [
      { name: 'obra', label: 'Obra', type: 'number' },
      { name: 'atendimento', label: 'Atendimento', type: 'number' },
      { name: 'mensagem', label: 'Mensagem', type: 'textarea' },
      { name: 'comando', label: 'Comando', placeholder: 'Ex.: A1' },
      { name: 'observacao', label: 'Observação', type: 'textarea' }
    ],
    actions: [
      { id: 'carregar', label: 'Carregar dados', variant: 'primary' },
      { id: 'conversa', label: 'Atualizar conversa', variant: 'secondary' },
      { id: 'enviarMensagem', label: 'Enviar mensagem', variant: 'success' },
      { id: 'enviarComando', label: 'Enviar comando', variant: 'warning' },
      { id: 'manualAtivar', label: 'Manual cabineiro ativar' },
      { id: 'manualDesativar', label: 'Manual cabineiro desativar' },
      { id: 'manualSubir', label: 'Subir' },
      { id: 'manualDescer', label: 'Descer' },
      { id: 'pinout', label: 'Solicitar PinOut' },
      { id: 'salvarObservacao', label: 'Salvar observação' },
      { id: 'encerrar', label: 'Encerrar atendimento', variant: 'danger', confirm: 'Confirma encerrar este atendimento?' }
    ]
  },
  'iam-online': {
    key: 'iam-online',
    title: 'IAM Online',
    description: 'Pesquisa de equipamentos, valores, históricos e comandos para placa.',
    legacyTemplate: 'IWformIAMOnline.html',
    fields: [
      { name: 'pesquisar', label: 'Pesquisar', placeholder: 'Obra, apelido ou cliente' },
      { name: 'obra', label: 'Obra', type: 'number' },
      { name: 'acao', label: 'Ação manual', placeholder: 'Ex.: $105' },
      { name: 'acionarBotao', label: 'Botão', placeholder: 'Número do botão' },
      { name: 'valores', label: 'Seq Valores', type: 'number' },
      { name: 'valoresFiltro', label: 'Filtro Valores' },
      { name: 'historicos', label: 'Seq Histórico', type: 'number' },
      { name: 'listaComando', label: 'Seq Lista Comando', type: 'number' },
      { name: 'listaComandoSemEscolha', label: 'Sem Escolha', type: 'number' },
      { name: 'listarComandosFiltrar', label: 'Filtro Comandos' },
      { name: 'mensagemSOS', label: 'Mensagem SOS', type: 'textarea' },
      { name: 'liberarEquip', label: 'Registrar liberação?', type: 'select', options: ['', '0', '1'] },
      { name: 'eprom', label: 'Abrir/fechar EPROM', type: 'checkbox' }
    ],
    actions: [
      { id: 'pesquisar', label: 'Pesquisar', variant: 'primary' },
      { id: 'carregar', label: 'Carregar obra', variant: 'success' },
      { id: 'valores', label: 'Valores' },
      { id: 'atualizarValores', label: 'Atualizar valores' },
      { id: 'historicos', label: 'Históricos' },
      { id: 'listaComandos', label: 'Lista de comandos' },
      { id: 'atualizarListaComandos', label: 'Filtrar comandos' },
      { id: 'enviarAcao', label: 'Enviar ação manual', variant: 'warning', confirm: 'Confirma enviar ação para a placa?' },
      { id: 'acionarBotao', label: 'Acionar botão', variant: 'warning' },
      { id: 'manualAtivar', label: 'Manual cabineiro ativar' },
      { id: 'manualDesativar', label: 'Manual cabineiro desativar' },
      { id: 'manualSubir', label: 'Subir' },
      { id: 'manualDescer', label: 'Descer' },
      { id: 'pinout', label: 'PinOut' },
      { id: 'whiteList', label: 'WhiteList Manual' },
      { id: 'senhaInstalacao', label: 'Senha instalação' },
      { id: 'autorizarInstalacao', label: 'Autorizar instalação', variant: 'danger', confirm: 'Confirma autorizar equipamento em instalação?' },
      { id: 'mensagemSOS', label: 'Enviar mensagem SOS', variant: 'success' }
    ]
  },
  clientes: {
    key: 'clientes',
    title: 'Clientes',
    description: 'Pesquisa de clientes, obras e informações técnicas.',
    legacyTemplate: 'IWformClientes.html',
    fields: [
      { name: 'nome', label: 'Nome' },
      { name: 'cidade', label: 'Cidade' },
      { name: 'obra', label: 'Obra', type: 'number' },
      { name: 'apelidoObra', label: 'Apelido Obra' },
      { name: 'visualizar', label: 'Código do Cliente', type: 'number' },
      { name: 'minhaTela', label: 'Obra Minha Tela', type: 'number' },
      { name: 'pesquisarFicha', label: 'Filtro Ficha Técnica' }
    ],
    actions: [
      { id: 'pesquisar', label: 'Pesquisar', variant: 'primary' },
      { id: 'visualizar', label: 'Visualizar cliente', variant: 'secondary' },
      { id: 'minhaTela', label: 'Minha tela / ficha', variant: 'success' }
    ]
  },
  'ficha-tecnica': {
    key: 'ficha-tecnica',
    title: 'Ficha Técnica',
    description: 'Pesquisa, carregamento, autorização e cálculo de ficha técnica.',
    legacyTemplate: 'IWformFichaTecnica.html',
    fields: [
      { name: 'pesquisar', label: 'Pesquisar' },
      { name: 'ficha', label: 'Ficha', type: 'number' },
      { name: 'pesquisarFicha', label: 'Filtro dentro da ficha' },
      { name: 'dias90', label: '90 dias', type: 'select', options: ['0', '1'], defaultValue: '0' },
      { name: 'acrescimoCompensador', label: 'Acréscimo compensador', placeholder: 'Ex.: -1,5' }
    ],
    actions: [
      { id: 'pesquisar', label: 'Pesquisar', variant: 'primary' },
      { id: 'pesquisarComFicha', label: 'Pesquisar ficha' },
      { id: 'carregar', label: 'Carregar ficha', variant: 'success' },
      { id: 'autorizar', label: 'Autorizar', variant: 'warning' },
      { id: 'calcular', label: 'Calcular' },
      { id: 'acrescimoCompensador', label: 'Salvar acréscimo compensador' },
      { id: 'removerAcrescimoCompensador', label: 'Remover acréscimo compensador', variant: 'danger' },
      { id: 'ligarOnline', label: 'Ligar online' },
      { id: 'desligarOnline', label: 'Desligar online' }
    ]
  },
  'entrega-tecnica': {
    key: 'entrega-tecnica',
    title: 'Entrega Técnica',
    description: 'Pesquisa e acesso à estrutura de entrega técnica.',
    legacyTemplate: 'IWformEntregaTecnica.html',
    fields: [
      { name: 'pesquisar', label: 'Pesquisar' },
      { name: 'obra', label: 'Obra', type: 'number' },
      { name: 'acessarEntregaTecnica', label: 'Tipo acesso', type: 'select', options: ['1', '2'], defaultValue: '2' }
    ],
    actions: [
      { id: 'pesquisar', label: 'Pesquisar', variant: 'primary' },
      { id: 'carregar', label: 'Carregar', variant: 'success' },
      { id: 'acessarEntregaTecnica', label: 'Acessar/gerar URL' },
      { id: 'estruturaEntregaTecnica', label: 'Gerar estrutura' }
    ]
  },
  vistorias: {
    key: 'vistorias',
    title: 'Vistorias',
    description: 'Pesquisa, carregamento, envio e follow-up de vistorias.',
    legacyTemplate: 'IWformVistorias.html',
    fields: [
      { name: 'pesquisar', label: 'Pesquisar' },
      { name: 'obra', label: 'Obra', type: 'number' },
      { name: 'vistoria', label: 'Vistoria', type: 'number' },
      { name: 'pesquisarFicha', label: 'Filtro Ficha' },
      { name: 'envioTipo', label: 'Tipo de envio', type: 'select', options: ['email', 'whatsapp'], defaultValue: 'email' },
      { name: 'envio', label: 'Destino envio' },
      { name: 'envioCopia', label: 'Cópia' },
      { name: 'descAditivo', label: 'Descrição Aditivo', type: 'textarea' },
      { name: 'conseguiuContato', label: 'Conseguiu contato?', type: 'select', options: ['', 'Sim', 'Não'] },
      { name: 'detalheContato', label: 'Detalhe contato', type: 'textarea' },
      { name: 'nomeContato', label: 'Nome contato' }
    ],
    actions: [
      { id: 'pesquisar', label: 'Pesquisar', variant: 'primary' },
      { id: 'carregar', label: 'Carregar vistoria', variant: 'success' },
      { id: 'carregarFicha', label: 'Carregar ficha' },
      { id: 'carregarObra', label: 'Carregar obra' },
      { id: 'arquivosFotos', label: 'Arquivos/Fotos' },
      { id: 'envio', label: 'Enviar', variant: 'warning', confirm: 'Confirma o envio desta vistoria?' },
      { id: 'solicitaAditivo', label: 'Solicitar aditivo' },
      { id: 'lancaFollowUp', label: 'Lançar follow-up' }
    ]
  },
  os: {
    key: 'os',
    title: 'O.S.',
    description: 'Pesquisa, visualização e autorização de O.S. de manutenção.',
    legacyTemplate: 'IWformOS.html',
    fields: [
      { name: 'pesquisar', label: 'Pesquisar' },
      { name: 'os', label: 'O.S.', type: 'number' }
    ],
    actions: [
      { id: 'pesquisar', label: 'Pesquisar', variant: 'primary' },
      { id: 'carregar', label: 'Carregar O.S.', variant: 'success' },
      { id: 'autorizar', label: 'Autorizar', variant: 'warning', confirm: 'Confirma autorizar esta O.S.?' }
    ]
  },
  notificacoes: {
    key: 'notificacoes',
    title: 'Notificações',
    description: 'Consulta e lançamento de notificações push corporativas.',
    legacyTemplate: 'IWformNotificacoes.html',
    loadAction: 'listar',
    fields: [
      { name: 'pesquisar', label: 'Pesquisar usuário' },
      { name: 'usuario', label: 'Código usuário', type: 'number' },
      { name: 'titulo', label: 'Título' },
      { name: 'mensagem', label: 'Mensagem', type: 'textarea' }
    ],
    actions: [
      { id: 'listar', label: 'Listar notificações', variant: 'primary' },
      { id: 'pesquisar', label: 'Pesquisar usuários' },
      { id: 'salvar', label: 'Salvar notificação', variant: 'success' }
    ]
  },
  'abrir-sac': {
    key: 'abrir-sac',
    title: 'Abrir SAC',
    description: 'Abertura de solicitação no Pendências Geral.',
    legacyTemplate: 'IWformAbrirSac.html',
    fields: [
      { name: 'titulo', label: 'Título' },
      { name: 'descricao', label: 'Descrição', type: 'textarea' },
      { name: 'info', label: 'Informações', type: 'textarea' }
    ],
    actions: [{ id: 'confirmar', label: 'Confirmar abertura', variant: 'success', confirm: 'Confirma abrir este SAC?' }]
  },
  'acoes-especiais': {
    key: 'acoes-especiais',
    title: 'Ações Especiais',
    description: 'Execução de grupos e ações especiais do SmartBox.',
    legacyTemplate: 'IWformAcoesEspeciais.html',
    loadAction: 'listar',
    fields: [
      { name: 'grupo', label: 'Grupo' },
      { name: 'executar', label: 'Seq ação', type: 'number' }
    ],
    actions: [
      { id: 'listar', label: 'Listar grupos', variant: 'primary' },
      { id: 'grupo', label: 'Abrir grupo' },
      { id: 'executar', label: 'Executar ação', variant: 'warning', confirm: 'Confirma executar a ação especial?' }
    ]
  },
  'suporte-tecnico': {
    key: 'suporte-tecnico',
    title: 'Suporte Técnico',
    description: 'Orientações técnicas e pesquisa de suporte.',
    legacyTemplate: 'IWformSuporteTecnico.html',
    loadAction: 'inicial',
    fields: [
      { name: 'pesquisar', label: 'Pesquisar' },
      { name: 'orientacao', label: 'Orientação', type: 'number' }
    ],
    actions: [
      { id: 'inicial', label: 'Carregar inicial', variant: 'primary' },
      { id: 'pesquisar', label: 'Pesquisar' },
      { id: 'carregar', label: 'Carregar orientação', variant: 'success' }
    ]
  },
  'plantonistas-sos': {
    key: 'plantonistas-sos',
    title: 'Plantonistas SOS',
    description: 'Lista de telefones de plantão IAM/SOS.',
    legacyTemplate: 'IWFormPlantonistasSOS.html',
    loadAction: 'listar',
    fields: [],
    actions: [{ id: 'listar', label: 'Atualizar lista', variant: 'primary' }]
  },
  holerites: {
    key: 'holerites',
    title: 'Holerites',
    description: 'Lista e geração de URL para arquivos de holerite.',
    legacyTemplate: 'IWformHolerites.html',
    loadAction: 'listar',
    fields: [{ name: 'seqArquivo', label: 'Seq Arquivo', type: 'number' }],
    actions: [
      { id: 'listar', label: 'Listar holerites', variant: 'primary' },
      { id: 'baixar', label: 'Gerar/baixar arquivo', variant: 'success' }
    ]
  },
  indices: {
    key: 'indices',
    title: 'Índices',
    description: 'Consulta de índices e execução administrativa controlada.',
    legacyTemplate: 'IWformIndices.html',
    loadAction: 'listar',
    fields: [{ name: 'script', label: 'Script SQL', type: 'textarea' }],
    actions: [
      { id: 'listar', label: 'Carregar índices', variant: 'primary' },
      { id: 'executarScript', label: 'Executar script', variant: 'danger', confirm: 'Esta ação executa SQL. Confirma?' }
    ]
  },
  query: {
    key: 'query',
    title: 'Query',
    description: 'Execução administrativa de SQL. Use apenas com usuários autorizados.',
    legacyTemplate: 'IWformQuery.html',
    fields: [{ name: 'script', label: 'Script SQL', type: 'textarea' }],
    actions: [{ id: 'executar', label: 'Executar', variant: 'danger', confirm: 'Esta ação executa SQL. Confirma?' }]
  },
  'informacoes-empresa': {
    key: 'informacoes-empresa',
    title: 'Informações da Empresa',
    description: 'Página institucional do app corporativo.',
    legacyTemplate: 'IWformInformacoesEmpresa.html',
    fields: [],
    actions: [{ id: 'carregar', label: 'Carregar informações', variant: 'primary' }]
  }
};

export const MENU: Array<{ key: string; title: string; group: string }> = Object.values(MODULES).map((module) => ({
  key: module.key,
  title: module.title,
  group: ['iam-online', 'chat', 'principal'].includes(module.key) ? 'IAM / SOS' :
    ['query', 'indices', 'acoes-especiais'].includes(module.key) ? 'Administração' :
    ['clientes', 'ficha-tecnica', 'entrega-tecnica', 'vistorias', 'os'].includes(module.key) ? 'Operacional' : 'Geral'
}));

export function getModuleDefinition(key: string): ModuleDefinition | undefined {
  return MODULES[key];
}
