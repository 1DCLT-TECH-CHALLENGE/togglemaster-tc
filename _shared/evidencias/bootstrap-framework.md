# Bootstrap Framework — ToggleMaster TC

Framework compartilhado dos bootstraps do rebuild.
## ETAPA 12 — BLOCO 1A — Correção do framework comum

Objetivo:
corrigir gap estrutural identificado após o smoke test da ETAPA 12.

Correção aplicada:
- adicionada função assert_not_sensitive_file ao framework compartilhado;
- proteção básica contra padrões óbvios de segredo:
  - AWS_SECRET_ACCESS_KEY;
  - chaves privadas;
  - password=;
  - token=.

Validações executadas:
- bash -n OK;
- source OK;
- teste positivo retornando 0;
- teste negativo detectando conteúdo sensível corretamente.

Resultado:
framework comum atualizado e alinhado ao baseline de segurança planejado para os próximos bootstraps.
