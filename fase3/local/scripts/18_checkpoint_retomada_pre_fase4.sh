#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME/togglemaster-tc"
PHASE="$ROOT/fase3"
LOG="$PHASE/logs/fase3-bloco18-checkpoint-retomada-pre-fase4.log"
EVID="$PHASE/docs/evidencias/fase3-bloco18-checkpoint-retomada-pre-fase4.md"

mkdir -p "$PHASE/logs" "$PHASE/docs/evidencias"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 3 - BLOCO 18 - CHECKPOINT DE RETOMADA PRÉ-FASE 4"
echo "============================================================"
echo "Data: $(date)"
echo

cat > "$EVID" <<EOM
# Fase 3 - BLOCO 18 - Checkpoint de Retomada Pré-Fase 4

Data: $(date)

## Objetivo

Validar, de forma read-only, se a base cloud da Fase 3 continua pronta para servir de fundação da Fase 4.

Este checkpoint valida:

- Git local.
- Credenciais AWS Academy carregadas.
- Identidade AWS.
- Região.
- Cluster EKS.
- Nodes.
- ArgoCD.
- Pods dos microsserviços.
- Services e Ingress.
- Recursos AWS principais: ECR, RDS, ElastiCache, SQS e DynamoDB.

Nenhum recurso AWS será criado, alterado ou destruído por este script.

EOM

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

run_and_record() {
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
  "$@"
  local rc=$?
  set -e

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

section "1. Conferência de diretório e arquivos de referência"

run_and_record "Diretório raiz" pwd
run_and_record "Listagem raiz" ls -la "$ROOT"

echo "Nota: instrucoes-rebuild.txt e TOPOLOGIAS-FASES-1-3 são guias externos desta conversa/source, não artefatos obrigatórios do repositório local."
echo "- Nota: \`instrucoes-rebuild.txt\` e \`TOPOLOGIAS-FASES-1-3\` são guias externos desta conversa/source, não artefatos obrigatórios do repositório local." >> "$EVID"

section "2. Git"

cd "$ROOT"
run_and_record "Git status" git status --short
run_and_record "Último commit" git log --oneline --decorate -5
run_and_record "Branch atual" git branch --show-current

section "3. Ferramentas locais"

run_and_record "AWS CLI" aws --version
run_and_record "kubectl" kubectl version --client=true
run_and_record "Terraform" terraform version
run_and_record "Docker" docker --version

section "4. AWS Academy / identidade"

AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
export AWS_REGION AWS_DEFAULT_REGION="$AWS_REGION"

echo "Região usada neste checkpoint: $AWS_REGION"
echo "- Região usada: \`$AWS_REGION\`." >> "$EVID"

if ! run_and_record "AWS STS get-caller-identity" aws sts get-caller-identity --output table; then
  echo
  echo "ERRO: credenciais AWS não estão carregadas ou expiraram."
  echo "Carregue as credenciais temporárias do AWS Academy Lab e reexecute este bloco."
  echo "- ERRO: credenciais AWS ausentes ou expiradas. Checkpoint interrompido antes de validar EKS/AWS." >> "$EVID"
  exit 20
fi

section "5. Descoberta do cluster EKS"

run_and_record "Listar clusters EKS" aws eks list-clusters --region "$AWS_REGION" --output table

CLUSTERS="$(aws eks list-clusters --region "$AWS_REGION" --query 'clusters[]' --output text || true)"

CLUSTER_NAME=""
for candidate in togglemaster-dev-eks togglemaster-cluster; do
  if echo "$CLUSTERS" | tr '\t' '\n' | grep -qx "$candidate"; then
    CLUSTER_NAME="$candidate"
    break
  fi
done

if [ -z "$CLUSTER_NAME" ]; then
  CLUSTER_NAME="$(echo "$CLUSTERS" | awk '{print $1}')"
fi

if [ -z "$CLUSTER_NAME" ]; then
  echo "ERRO: nenhum cluster EKS encontrado."
  echo "- ERRO: nenhum cluster EKS encontrado." >> "$EVID"
  exit 30
fi

echo "Cluster selecionado para validação: $CLUSTER_NAME"
echo "- Cluster selecionado: \`$CLUSTER_NAME\`." >> "$EVID"

run_and_record "Describe cluster EKS" aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --query 'cluster.{name:name,status:status,endpoint:endpoint,version:version,roleArn:roleArn}' \
  --output table

section "6. kubeconfig e Kubernetes"

run_and_record "Atualizar kubeconfig local" aws eks update-kubeconfig \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --alias "$CLUSTER_NAME"

run_and_record "Contexto kubectl atual" kubectl config current-context
run_and_record "Nodes" kubectl get nodes -o wide
run_and_record "Namespaces principais" kubectl get ns

section "7. ArgoCD e GitOps"

run_and_record "Applications ArgoCD" kubectl get applications -n argocd -o wide
run_and_record "Application togglemaster-dev" kubectl get application togglemaster-dev -n argocd -o wide

section "8. Namespace togglemaster"

run_and_record "Pods togglemaster" kubectl get pods -n togglemaster -o wide
run_and_record "Deployments togglemaster" kubectl get deployments -n togglemaster -o wide
run_and_record "Services togglemaster" kubectl get svc -n togglemaster -o wide
run_and_record "Ingress togglemaster" kubectl get ingress -n togglemaster -o wide

section "9. Recursos AWS principais"

run_and_record "ECR repositories ToggleMaster" aws ecr describe-repositories \
  --region "$AWS_REGION" \
  --query 'repositories[?contains(repositoryName, `togglemaster`) || contains(repositoryName, `auth`) || contains(repositoryName, `flag`) || contains(repositoryName, `targeting`) || contains(repositoryName, `evaluation`) || contains(repositoryName, `analytics`)].repositoryName' \
  --output table

run_and_record "RDS instances" aws rds describe-db-instances \
  --region "$AWS_REGION" \
  --query 'DBInstances[].{id:DBInstanceIdentifier,status:DBInstanceStatus,engine:Engine,endpoint:Endpoint.Address}' \
  --output table

run_and_record "ElastiCache clusters" aws elasticache describe-cache-clusters \
  --region "$AWS_REGION" \
  --show-cache-node-info \
  --query 'CacheClusters[].{id:CacheClusterId,status:CacheClusterStatus,engine:Engine,node:CacheNodes[0].Endpoint.Address}' \
  --output table

run_and_record "SQS queues" aws sqs list-queues \
  --region "$AWS_REGION" \
  --output table

run_and_record "DynamoDB tables" aws dynamodb list-tables \
  --region "$AWS_REGION" \
  --output table

section "10. Resultado do checkpoint"

PODS_NOT_READY="$(kubectl get pods -n togglemaster --no-headers 2>/dev/null | awk '
{
  split($2, ready, "/");
  if (ready[1] != ready[2] || $3 != "Running") {
    print $0;
  }
}' || true)"
ARGO_STATUS="$(kubectl get application togglemaster-dev -n argocd -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"

echo "ArgoCD status: ${ARGO_STATUS:-indisponível}"
echo "Pods não prontos:"
if [ -n "$PODS_NOT_READY" ]; then
  echo "$PODS_NOT_READY"
else
  echo "Nenhum."
fi

{
  echo
  echo "## Resultado"
  echo
  echo "- ArgoCD: \`${ARGO_STATUS:-indisponível}\`"
  if [ -n "$PODS_NOT_READY" ]; then
    echo "- Pods não prontos encontrados. Verificar log."
  else
    echo "- Pods no namespace \`togglemaster\`: sem pods não prontos detectados."
  fi
  echo "- Log completo: \`$LOG\`"
} >> "$EVID"

if [ "${ARGO_STATUS:-}" != "Synced/Healthy" ]; then
  echo
  echo "ATENÇÃO: ArgoCD não está Synced/Healthy."
  echo "Checkpoint concluído com alerta."
  exit 40
fi

if [ -n "$PODS_NOT_READY" ]; then
  echo
  echo "ATENÇÃO: existem pods não prontos no namespace togglemaster."
  echo "Checkpoint concluído com alerta."
  exit 41
fi

echo
echo "============================================================"
echo "CHECKPOINT PRÉ-FASE 4 CONCLUÍDO COM SUCESSO"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "============================================================"
