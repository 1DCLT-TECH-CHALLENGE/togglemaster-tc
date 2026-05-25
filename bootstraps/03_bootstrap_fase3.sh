#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
cd "$ROOT"

section "ToggleMaster TC - Bootstrap Fase 3"
echo "Escopo:"
echo "- Usa a estrutura da Fase 2."
echo "- Cria infraestrutura cloud via Terraform/IaC."
echo "- Prepara EKS, RDS, Redis, ECR, SQS, DynamoDB, Secrets e GitOps."
echo "- Requer AWS Academy/LabRole ativo."
echo
echo "Segurança:"
echo "- Sem CONFIRM_AWS_COSTS=SIM, o script valida e gera plano."
echo "- Com CONFIRM_AWS_COSTS=SIM, aplica Terraform e continua o fluxo cloud."

if [ "${BOOTSTRAP_SKIP_PREPARE_VM:-false}" != "true" ]; then
  run_script "$ROOT/bootstraps/00_prepare_vm.sh"
fi

require_cmd aws
require_cmd terraform
require_cmd kubectl
require_cmd docker
require_cmd jq

section "Identidade AWS"
aws sts get-caller-identity

TF_DIR="$ROOT/fase3/terraform/environments/dev"
require_dir "$TF_DIR"

section "Terraform init, fmt, validate e plan"
cd "$TF_DIR"

terraform init -reconfigure
terraform fmt -recursive
terraform validate

PLAN_FILE="${PLAN_FILE:-tfplan-phase3}"
terraform plan -out="$PLAN_FILE"

if [ "${CONFIRM_AWS_COSTS:-}" != "SIM" ]; then
  section "Apply bloqueado por segurança"
  echo "Plano gerado em: $TF_DIR/$PLAN_FILE"
  echo
  echo "Para criar a infraestrutura AWS:"
  echo "CONFIRM_AWS_COSTS=SIM $ROOT/bootstraps/03_bootstrap_fase3.sh"
  exit 0
fi

section "Aplicando Terraform"
terraform apply "$PLAN_FILE"

AWS_REGION="$(terraform output -raw aws_region 2>/dev/null || echo "${AWS_REGION:-us-east-1}")"
CLUSTER_NAME="$(terraform output -raw eks_cluster_name)"

section "Atualizando kubeconfig"
aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
kubectl get nodes

section "Build e push das imagens para ECR"
if [ "${BOOTSTRAP_BUILD_PUSH_IMAGES:-true}" = "true" ]; then
  TAG="${IMAGE_TAG:-$(git -C "$ROOT" rev-parse --short HEAD)}"
  ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

  aws ecr get-login-password --region "$AWS_REGION" \
    | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

  ECR_JSON="$(terraform output -json ecr_repository_urls)"

  services=(
    "auth-service:fase2/src/services/auth-service"
    "flag-service:fase2/src/services/flag-service"
    "targeting-service:fase2/src/services/targeting-service"
    "evaluation-service:fase2/src/services/evaluation-service"
    "analytics-service:fase2/src/services/analytics-service"
  )

  cd "$ROOT"

  for item in "${services[@]}"; do
    svc="${item%%:*}"
    path="${item#*:}"
    repo="$(echo "$ECR_JSON" | jq -r --arg svc "$svc" '.[$svc]')"

    [ "$repo" != "null" ] || fail "Repo ECR não encontrado para $svc"
    require_dir "$ROOT/$path"

    section "Build/push $svc"
    docker build -t "$repo:$TAG" "$ROOT/$path"
    docker push "$repo:$TAG"

    manifest="$ROOT/fase3/gitops/base/${svc}.yaml"
    if [ -f "$manifest" ]; then
      python3 - "$manifest" "$repo:$TAG" <<'PY'
import re
import sys
path = sys.argv[1]
image = sys.argv[2]
text = open(path, encoding="utf-8").read()
text = re.sub(r'image:\s*["\']?[^"\'\n]+["\']?', f'image: "{image}"', text, count=1)
open(path, "w", encoding="utf-8").write(text)
PY
      echo "Manifest atualizado localmente: $manifest -> $repo:$TAG"
    fi
  done
else
  warn "Build/push ignorado por BOOTSTRAP_BUILD_PUSH_IMAGES=false."
fi

section "Instalando/aplicando ArgoCD e GitOps"
cd "$ROOT"

if [ "${BOOTSTRAP_INSTALL_ARGOCD:-true}" = "true" ]; then
  kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  kubectl -n argocd rollout status deployment/argocd-server --timeout=300s || true
fi

kubectl apply -k fase3/gitops/apps

section "Fase 3 concluída"
echo "Infraestrutura cloud e GitOps aplicados."
echo "Atenção: runtime secrets e credenciais temporárias do AWS Academy podem exigir scripts operacionais específicos da Fase 3."
