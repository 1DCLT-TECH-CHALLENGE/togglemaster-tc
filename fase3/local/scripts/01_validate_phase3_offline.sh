#!/usr/bin/env bash
set -Eeuo pipefail

BASE="${BASE:-$HOME/togglemaster-tc}"
FASE3="$BASE/fase3"
LOG_DIR="$FASE3/logs"
EVID_DIR="$FASE3/docs/evidencias"

mkdir -p "$LOG_DIR" "$EVID_DIR"

LOG="$LOG_DIR/fase3-bloco20-validate-offline.log"
EVID="$EVID_DIR/fase3-bloco20-validacao-offline.md"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 3 - BLOCO 20 - VALIDAÇÃO OFFLINE"
echo "============================================================"
echo "Data: $(date)"
echo

cd "$BASE"

echo "[1/7] Conferindo ferramentas locais"
for cmd in terraform kubectl git grep find; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK: $cmd => $(command -v "$cmd")"
  else
    echo "ERRO: comando obrigatório não encontrado: $cmd"
    exit 1
  fi
done

echo
echo "[2/7] Terraform fmt check"
cd "$FASE3/terraform"
terraform fmt -recursive -check

echo
echo "[3/7] Terraform init sem backend remoto"
cd "$FASE3/terraform/environments/dev"
terraform init -backend=false

echo
echo "[4/7] Terraform validate"
terraform validate

echo
echo "[5/7] Render Kustomize base"
cd "$BASE"
kubectl kustomize fase3/gitops/base > "$LOG_DIR/fase3-bloco20-gitops-base-render.yaml"
grep -nE '^kind: |^  name: ' "$LOG_DIR/fase3-bloco20-gitops-base-render.yaml" | head -120

echo
echo "[6/7] Render Kustomize overlay dev"
kubectl kustomize fase3/gitops/overlays/dev > "$LOG_DIR/fase3-bloco20-gitops-dev-render.yaml"
grep -nE '^kind: |^  name: |AUTH_SERVICE_URL|FLAG_SERVICE_URL|TARGETING_SERVICE_URL' "$LOG_DIR/fase3-bloco20-gitops-dev-render.yaml" | head -140

echo
echo "[7/7] Render Kustomize ArgoCD apps"
kubectl kustomize fase3/gitops/apps > "$LOG_DIR/fase3-bloco20-argocd-apps-render.yaml"
grep -nE '^kind: |^  name: |repoURL|path:|targetRevision:' "$LOG_DIR/fase3-bloco20-argocd-apps-render.yaml" | head -80

echo
echo "[AUDIT] Conferindo caminhos proibidos no Git"
if git ls-files --others --exclude-standard | grep -E '(^|/)(logs|tmp|\.terraform)/|\.tfstate|\.tfvars$|\.env$|\.bak|\.bkp' ; then
  echo "ERRO: arquivos locais/gerados aparecem como candidatos ao Git."
  exit 1
else
  echo "OK: nenhum arquivo local/gerado proibido aparece como candidato ao Git."
fi

echo
echo "[AUDIT] Busca por padrões óbvios de segredo"
SECRET_FINDINGS="$LOG_DIR/fase3-bloco20-secret-findings.txt"

grep -R \
  --exclude-dir=.git \
  --exclude-dir=.terraform \
  --exclude-dir=logs \
  --exclude-dir=tmp \
  --exclude='*.lock.hcl' \
  --exclude='01_validate_phase3_offline.sh' \
  --line-number \
  -E 'AKIA[0-9A-Z]{16}|ghp_|github_pat_|tm_key_[a-f0-9]{20,}|aws_secret_access_key[[:space:]]*=|secret_string[[:space:]]*=|password[[:space:]]*=' \
  _shared fase3 > "$SECRET_FINDINGS" || true

cat "$SECRET_FINDINGS"

UNEXPECTED_FINDINGS="$(
  grep -v 'manage_master_user_password = true' "$SECRET_FINDINGS" \
    | grep -v 'password=;' \
    | grep -v '`password=`' \
    | grep -v 'referência documental ao padrão' \
    || true
)"

if [[ -n "$UNEXPECTED_FINDINGS" ]]; then
  echo
  echo "ERRO: achados inesperados de possível segredo:"
  echo "$UNEXPECTED_FINDINGS"
  exit 1
else
  echo "OK: sem achados inesperados de segredo."
fi

cat > "$EVID" <<'EOF_EVIDENCE'
# Fase 3 - BLOCO 20 - Validação offline automatizada

Data: __GENERATED_AT__

## Objetivo

Executar validação local automatizada da Fase 3 sem conexão com AWS.

## Comandos/validações executados

- conferência de ferramentas locais;
- `terraform fmt -recursive -check`;
- `terraform init -backend=false`;
- `terraform validate`;
- `kubectl kustomize fase3/gitops/base`;
- `kubectl kustomize fase3/gitops/overlays/dev`;
- `kubectl kustomize fase3/gitops/apps`;
- auditoria de caminhos proibidos;
- auditoria básica de padrões de segredo.

## Resultado

Validação offline concluída com sucesso.

## Auditoria de segredos

O scanner exclui o próprio script `01_validate_phase3_offline.sh`, pois ele contém literalmente as regexes usadas para detectar padrões sensíveis.

Também são permitidas referências documentais explícitas a padrões bloqueados, como `password=`, quando não representam credenciais reais.

## Restrições respeitadas

Não foi executado:

- `aws configure`;
- `aws sts get-caller-identity`;
- `terraform plan`;
- `terraform apply`;
- `kubectl apply`;
- conexão com cluster Kubernetes real;
- criação de recurso AWS;
- login no AWS Academy.

## Logs gerados

- `logs/fase3-bloco20-validate-offline.log`
- `logs/fase3-bloco20-gitops-base-render.yaml`
- `logs/fase3-bloco20-gitops-dev-render.yaml`
- `logs/fase3-bloco20-argocd-apps-render.yaml`
- `logs/fase3-bloco20-secret-findings.txt`

## Status

Fase 3 offline validada automaticamente.
EOF_EVIDENCE

sed -i "s|__GENERATED_AT__|$(date)|g" "$EVID"

echo
echo "============================================================"
echo "FASE 3 - BLOCO 20 FINALIZADO COM SUCESSO"
echo "LOG: $LOG"
echo "EVIDÊNCIA: $EVID"
echo "============================================================"
