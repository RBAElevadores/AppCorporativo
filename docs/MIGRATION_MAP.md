# Mapa da migração IntraWeb → Next.js

| IntraWeb / Delphi | Next.js / React |
|---|---|
| `IWformLogin.html` + `untLogin.pas` | `/login` + `/api/auth/login` |
| `IWformMain.html` + `untMain.pas` | `/app` + `/app/main` |
| `IWformPrincipal.html` + `untPrincipal.pas` | `/app/principal` |
| `IWformChat.html` + `untChat.pas` | `/app/chat` |
| `IWformIAMOnline.html` + `untIAMOnline.pas` | `/app/iam-online` |
| `IWformClientes.html` + `untClientes.pas` | `/app/clientes` |
| `IWformFichaTecnica.html` + `untFichaTecnica.pas` | `/app/ficha-tecnica` |
| `IWformEntregaTecnica.html` + `untEntregaTecnica.pas` | `/app/entrega-tecnica` |
| `IWformVistorias.html` + `untVistorias.pas` | `/app/vistorias` |
| `IWformOS.html` + `untOS.pas` | `/app/os` |
| `IWformNotificacoes.html` + `untNotificacoes.pas` | `/app/notificacoes` |
| `IWformAbrirSac.html` + `untAbrirSac.pas` | `/app/abrir-sac` |
| `IWformAcoesEspeciais.html` + `untAcoesEspeciais.pas` | `/app/acoes-especiais` |
| `IWformSuporteTecnico.html` + `untSuporteTecnico.pas` | `/app/suporte-tecnico` |
| `IWformRamais.html` + `untRamais.pas` | `/app/ramais` |
| `IWFormPlantonistasSOS.html` + `untPlantonistasSOS.pas` | `/app/plantonistas-sos` |
| `IWformHolerites.html` + `untHolerites.pas` | `/app/holerites` |
| `IWformIndices.html` + `untIndices.pas` | `/app/indices` |
| `IWformQuery.html` + `untQuery.pas` | `/app/query` |
| `wwwroot` | `public/wwwroot` |

## Arquivos centrais

- `src/lib/sql.ts`: comunicação server-side com `RBA_SQL_ENDPOINT`.
- `src/lib/session.ts`: cookie assinado de sessão.
- `src/lib/modules.ts`: definição das telas/campos/botões.
- `src/lib/module-actions.ts`: mapeamento das ações Delphi para SQL/stored procedures.
- `src/components/ModuleClient.tsx`: tela React genérica para módulos migrados.
- `public/legacy-bridge.js`: ponte de compatibilidade para templates HTML convertidos.
