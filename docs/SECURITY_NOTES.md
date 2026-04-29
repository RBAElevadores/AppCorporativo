# Notas de segurança

## Endpoint SQL

O endpoint informado:

```text
https://iam.rbaelevadores.com.br/retornasqljson
```

recebe um body com SQL livre:

```json
{ "script": "select ..." }
```

Por isso, ele não deve ser chamado diretamente pelo navegador.

Este projeto chama esse endpoint apenas pelo backend Next.js, dentro de rotas `/api/*`. Assim o navegador nunca recebe a variável `RBA_SQL_ENDPOINT`.

## Melhorias recomendadas

1. Adicionar autenticação no endpoint SQL, por exemplo `Authorization: Bearer <token>`.
2. Colocar esse token na Vercel como `RBA_SQL_TOKEN`.
3. Bloquear CORS no endpoint para navegadores.
4. Registrar log de SQLs recebidos por usuário/IP/data.
5. Evoluir de SQL livre para procedures/API com whitelist.
6. Trocar senha em texto puro por hash no banco, como bcrypt/argon2, em uma etapa posterior.

## Query e Índices

Os módulos `query` e `indices` preservam a capacidade administrativa de executar SQL livre que existia no IntraWeb. O uso desses módulos deve ser restrito por permissão.
