# App Corporativo RBA - Migração IntraWeb para Next.js

Este projeto é a primeira conversão do app **Delphi Berlin + IntraWeb Técnico Online** para **Next.js + React + TypeScript**, preparado para **GitHub + Vercel + Codex**.

## O que foi migrado

- Estrutura Next.js com App Router.
- Login server-side usando o endpoint SQL da RBA.
- Sessão por cookie `httpOnly` assinado.
- Comunicação com banco por API interna do Next.js, sem expor o endpoint SQL no navegador.
- Páginas React para os módulos principais.
- Ações server-side mapeadas a partir das units Delphi/Pascal.
- Camada de compatibilidade com os templates HTML IntraWeb originais.
- Assets do `wwwroot` copiados para `public/wwwroot`.
- Fontes Delphi originais preservados em `legacy/intraweb-source` para conferência.
- Templates HTML originais preservados em `legacy/templates` e convertidos em `public/legacy`.

## Variáveis de ambiente obrigatórias na Vercel

Configure em **Project Settings > Environment Variables**:

```env
RBA_SQL_ENDPOINT=https://iam.rbaelevadores.com.br/retornasqljson
RBA_AUTH_SECRET=gere-uma-chave-grande-e-aleatoria
```

Opcional, se o endpoint SQL passar a exigir autenticação:

```env
RBA_SQL_TOKEN=token-secreto-do-servidor-de-aplicacao
```

## Como rodar localmente

```bash
npm install
npm run dev
```

Abra:

```text
http://localhost:3000
```

## Como subir no GitHub

Copie todos os arquivos deste projeto para a raiz do seu repositório `RBAElevadores/AppCorporativo` e rode:

```bash
git add .
git commit -m "Migra App Corporativo IntraWeb para Next.js"
git push origin main
```

A Vercel fará o deploy automaticamente porque o projeto já está importado.

## Arquitetura

```text
React / Next.js page
        ↓
/api/modules/[module]/[action]
        ↓
RBA_SQL_ENDPOINT
        ↓
SQL Server / stored procedures existentes
```

O navegador **não chama** `https://iam.rbaelevadores.com.br/retornasqljson` diretamente. As telas chamam APIs internas do Next.js, e essas APIs chamam o endpoint SQL no servidor.

## Páginas principais

- `/login`: login.
- `/app`: dashboard.
- `/app/clientes`: Clientes.
- `/app/ficha-tecnica`: Ficha Técnica.
- `/app/iam-online`: IAM Online.
- `/app/chat`: Chat SOS.
- `/app/vistorias`: Vistorias.
- `/app/os`: O.S.
- `/app/entrega-tecnica`: Entrega Técnica.
- `/app/notificacoes`: Notificações.
- `/app/query`: Query administrativa.

Cada módulo também tem uma versão de compatibilidade visual:

```text
/legacy/clientes
/legacy/iam-online
/legacy/vistorias
...
```

## Observações importantes

1. Este projeto usa as stored procedures e SQLs encontrados no código Delphi anexado. Algumas telas do IntraWeb dependiam de JavaScript executado pelo servidor via `CallBackResponse.AddJavaScriptToExecuteAsCDATA`. Na migração inicial, os retornos são exibidos como HTML no painel de resultado.
2. Como este ambiente não acessa seu endpoint SQL real, a validação final precisa ser feita no seu Vercel ou localmente com acesso ao endpoint.
3. O endpoint `retornasqljson` é muito poderoso porque executa SQL recebido no body. O ideal é protegê-lo com token secreto e restringir chamadas somente ao backend Next.js/Vercel.
4. Os módulos `query` e `indices` executam SQL livre porque isso existia no IntraWeb. Devem ficar restritos a usuários autorizados.
