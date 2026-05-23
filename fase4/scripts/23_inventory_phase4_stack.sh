#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
LOG="$PHASE/docs/evidencias/fase4-bloco23-inventario-stack.log"
EVID="$PHASE/docs/evidencias/fase4-bloco23-inventario-stack.md"
ADR="$PHASE/docs/adr/ADR-002-fase4-stack-observabilidade-apm-incidentes.md"
TMP="$PHASE/tmp/bloco23"

AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
APP_NS="togglemaster"
ARGO_NS="argocd"

mkdir -p "$PHASE/docs/evidencias" "$PHASE/docs/adr" "$TMP"

exec > >(tee "$LOG") 2>&1

section() {
  echo
  echo "============================================================"
  echo "$1"
  echo "============================================================"
  echo
  {
    echo
    echo "## $1"
    echo
  } >> "$EVID"
}

record_cmd() {
  local title="$1"
  shift

  echo
  echo "### $title"
  echo "\$ $*"
  echo

  {
    echo
    echo "### $title"
    echo
    echo '```bash'
    echo "\$ $*"
  } >> "$EVID"

  set +e
  "$@" 2>&1 | tee "$TMP/last.out"
  local rc=${PIPESTATUS[0]}
  set -e

  cat "$TMP/last.out" >> "$EVID"

  {
    echo
    echo '```'
    echo
    echo "RC: \`$rc\`"
  } >> "$EVID"

  echo
  echo "RC=$rc"
  return "$rc"
}

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 23 - Inventário Técnico e Decisão Inicial da Stack

Data: $(date)

## Objetivo

Inventariar o estado atual da base Fase 3/Fase 4 antes de instalar qualquer componente de observabilidade.

Este bloco é read-only e não altera infraestrutura.

EOM

echo "============================================================"
echo "FASE 4 - BLOCO 23 - INVENTÁRIO TÉCNICO"
echo "============================================================"
echo "Data: $(date)"
echo

section "1. Estado Git"

record_cmd "Git status" git status --short
record_cmd "Últimos commits" git log --oneline --decorate -8
record_cmd "Branch atual" git branch --show-current

allowed_bloco23_status_filter() {
  grep -vE '^\?\? fase4/docs/evidencias/fase4-bloco23-inventario-stack\.md$|^\?\? fase4/scripts/$|^\?\? fase4/scripts/23_inventory_phase4_stack\.sh$|^\?\? fase4/docs/adr/ADR-002-fase4-stack-observabilidade-apm-incidentes\.md$' || true
}

GIT_STATUS="$(git status --short | allowed_bloco23_status_filter)"
if [ -n "$GIT_STATUS" ]; then
  echo "ERRO: Git tem alterações inesperadas no início do BLOCO 23."
  echo "$GIT_STATUS"
  exit 10
fi

echo "OK: Git limpo, exceto artefatos esperados do próprio BLOCO 23."
echo "- OK: Git limpo, exceto artefatos esperados do próprio BLOCO 23." >> "$EVID"

section "2. Ferramentas locais"

record_cmd "AWS CLI" aws --version
record_cmd "kubectl version client" kubectl version --client=true
record_cmd "Helm version" helm version
record_cmd "Docker version" docker --version
record_cmd "Docker compose version" docker compose version

section "3. Estado AWS/EKS read-only"

export AWS_REGION AWS_DEFAULT_REGION="$AWS_REGION"

record_cmd "AWS identity" aws sts get-caller-identity --output table
record_cmd "EKS clusters" aws eks list-clusters --region "$AWS_REGION" --output table
record_cmd "kubectl current context" kubectl config current-context
record_cmd "Nodes" kubectl get nodes -o wide
record_cmd "Node capacity allocatable" bash -lc "kubectl describe nodes | grep -E 'Name:|cpu:|memory:|pods:' | head -120"

section "4. Estado Kubernetes e GitOps"

record_cmd "Namespaces" kubectl get ns
record_cmd "ArgoCD applications" kubectl get applications -n "$ARGO_NS" -o wide
record_cmd "Pods namespace togglemaster" kubectl get pods -n "$APP_NS" -o wide
record_cmd "Services namespace togglemaster" kubectl get svc -n "$APP_NS" -o wide
record_cmd "Deployments namespace togglemaster" kubectl get deployments -n "$APP_NS" -o wide

ARGO_STATUS="$(kubectl get application togglemaster-dev -n "$ARGO_NS" -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"
PODS_NOT_READY="$(kubectl get pods -n "$APP_NS" --no-headers | awk '
{
  split($2, ready, "/");
  if (ready[1] != ready[2] || $3 != "Running") {
    print $0;
  }
}' || true)"

echo "ARGO_STATUS=$ARGO_STATUS"
echo "PODS_NOT_READY=${PODS_NOT_READY:-Nenhum}"

{
  echo
  echo "### Resultado Kubernetes/GitOps"
  echo
  echo "- ArgoCD: \`$ARGO_STATUS\`"
  if [ -n "$PODS_NOT_READY" ]; then
    echo "- Pods não prontos encontrados."
  else
    echo "- Pods não prontos: nenhum."
  fi
} >> "$EVID"

if [ "$ARGO_STATUS" != "Synced/Healthy" ]; then
  echo "ERRO: ArgoCD não está Synced/Healthy."
  exit 20
fi

if [ -n "$PODS_NOT_READY" ]; then
  echo "ERRO: existem pods não prontos no namespace $APP_NS."
  echo "$PODS_NOT_READY"
  exit 21
fi

section "5. Verificar se já existe observabilidade instalada"

record_cmd "Namespaces de observabilidade existentes" bash -lc "kubectl get ns | grep -Ei 'monitor|observ|grafana|prometheus|loki|tempo|otel|datadog|newrelic' || true"
record_cmd "Pods de observabilidade em todos namespaces" bash -lc "kubectl get pods -A | grep -Ei 'prometheus|grafana|loki|tempo|otel|collector|alloy|datadog|newrelic' || true"
record_cmd "Helm releases em todos namespaces" helm list -A

section "6. Estrutura GitOps e Fase 4"

record_cmd "Estrutura fase4" find fase4 -maxdepth 4 -type f | sort
record_cmd "GitOps fase3 atual" find fase3/gitops -maxdepth 5 -type f | sort
record_cmd "Workflows atuais" find .github/workflows -maxdepth 1 -type f | sort

section "7. Decisão inicial da stack"

cat > "$ADR" <<EOF
# ADR-002 - Stack Inicial de Observabilidade, APM, Incidentes e Self-Healing

## Status

Proposta controlada para implementação.

## Contexto

A Fase 4 exige observabilidade total e resposta ativa sobre a base das Fases 2 e 3 já validada.

O PDF oficial exige:

- Prometheus, Grafana e Loki no Kubernetes.
- OpenTelemetry Collector obrigatório.
- Instrumentação dos microsserviços.
- APM com Datadog ou New Relic.
- Alerta inteligente.
- Incidente em PagerDuty ou OpsGenie.
- ChatOps em Slack, Discord ou Teams.
- Self-healing demonstrável.
- Evidências em vídeo e relatório.

## Decisão inicial

1. Stack open source no cluster:
   - Prometheus para métricas.
   - Loki para logs.
   - Grafana para dashboard e visualização.
   - OpenTelemetry Collector como hub obrigatório.

2. Instalação:
   - Preferência por Helm charts e manifests GitOps versionados.
   - Nada será aplicado manualmente sem evidência e documentação.

3. APM:
   - Decisão pendente entre Datadog e New Relic.
   - A escolha será feita após validar disponibilidade de conta gratuita/token e melhor viabilidade no AWS Academy.

4. Incidentes:
   - Decisão pendente entre PagerDuty e OpsGenie.
   - A escolha será feita após validar conta e integração com alerta.

5. ChatOps:
   - Decisão pendente entre Discord, Slack e Teams.
   - A escolha será feita após validar webhook/canal disponível.

6. Self-healing:
   - Preferência por automação segura e demonstrável.
   - Candidatos:
     - script versionado acionado por webhook;
     - GitHub Action workflow_dispatch/repository_dispatch;
     - runbook automation;
     - Lambda somente se não criar conflito com AWS Academy/LabRole.

## Consequências

- O próximo passo é instalar a stack open source base via GitOps.
- APM, incidentes e ChatOps dependem de credenciais/tokens externos e serão tratados sem versionar segredos.
- Todo requisito só será considerado concluído após demonstração prática.
EOF

cat >> "$EVID" <<EOF

## Decisão inicial registrada

Foi criada a ADR:

- \`$ADR\`

Resumo:

- Prometheus/Grafana/Loki/OTel Collector serão a stack base.
- APM ainda pendente entre Datadog/New Relic.
- Incidentes ainda pendente entre PagerDuty/OpsGenie.
- ChatOps ainda pendente entre Discord/Slack/Teams.
- Self-healing será implementado com automação segura e demonstrável.

EOF

section "8. Resultado"

cat >> "$EVID" <<EOF

## Resultado

Inventário técnico concluído.

Nenhuma infraestrutura foi alterada.

Próximo passo recomendado:

1. Criar manifests/Helm values da stack open source de observabilidade.
2. Aplicar via GitOps/ArgoCD.
3. Validar Prometheus, Grafana, Loki e OTel Collector antes de APM externo.

EOF

echo
echo "============================================================"
echo "BLOCO 23 CONCLUÍDO COM SUCESSO"
echo "Inventário técnico e ADR inicial criados."
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "ADR: $ADR"
echo "============================================================"
