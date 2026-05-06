export type FieldType = 'text' | 'password' | 'number' | 'textarea' | 'checkbox' | 'select';
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
      { id: 'baixar', label: 'Gerar/baixar arquivo', variant: 'success' },
      { id: 'status', label: 'Verificar arquivo', variant: 'secondary' }
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