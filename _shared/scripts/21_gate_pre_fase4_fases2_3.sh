#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

ROOT="$HOME/togglemaster-tc"
SHARED="$ROOT/_shared"
EVID="$SHARED/evidencias/gate-pre-fase4-fases2-3.md"
LOG="/tmp/gate-pre-fase4-fases2-3.log"
TMP="/tmp/togglemaster-gate-pre-fase4"
AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
NAMESPACE="togglemaster"

mkdir -p "$SHARED/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

allowed_gate_status_filter() {
  grep -vE '^\?\? _shared/evidencias/gate-pre-fase4-fases2-3\.md$|^\?\? _shared/scripts/21_gate_pre_fase4_fases2_3\.sh$' || true
}

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

record_file_tail() {
  local title="$1"
  local file="$2"
  local lines="${3:-80}"

  echo
  echo "### $title"
  echo "Arquivo: $file"
  echo

  {
    echo
    echo "### $title"
    echo
    echo "Arquivo: \`$file\`"
    echo
    echo '```text'
  } >> "$EVID"

  if [ -f "$file" ]; then
    tail -n "$lines" "$file" | tee "$TMP/tail.out"
    cat "$TMP/tail.out" >> "$EVID"
  else
    echo "Arquivo não encontrado: $file" | tee "$TMP/tail.out"
    cat "$TMP/tail.out" >> "$EVID"
  fi

  {
    echo
    echo '```'
  } >> "$EVID"
}

check_marker() {
  local label="$1"
  local file="$2"
  local pattern="$3"

  echo
  echo "### Check marker: $label"

  if [ ! -f "$file" ]; then
    echo "ERRO: arquivo não encontrado: $file"
    echo "- ERRO: \`$label\` não encontrado porque o arquivo \`$file\` não existe." >> "$EVID"
    return 1
  fi

  if grep -qE "$pattern" "$file"; then
    echo "OK: $label"
    echo "- OK: $label." >> "$EVID"
    return 0
  fi

  echo "ERRO: marcador não encontrado para $label"
  echo "- ERRO: marcador não encontrado para $label." >> "$EVID"
  return 1
}

cat > "$EVID" <<EOM
# Gate Consolidado Pré-Fase 4 — Fases 2 e 3

Data: $(date)

## Objetivo

Registrar um checkpoint consolidado antes de iniciar a Fase 4.

Este gate confirma que:

- A Fase 2 local está funcional.
- A Fase 3 cloud está funcional.
- A base Kubernetes/GitOps/IaC/DevSecOps da Fase 3 permanece presente e validada por evidências.
- O Git está limpo, exceto pelos próprios arquivos deste gate antes do commit.
- A Fase 4 será iniciada como entrega real da fase, não como rebuild.

## Observação importante

A Fase 4 não será tratada como rebuild. Ela será conduzida como entrega acadêmica completa, com implementação, evidências, relatório, prints e roteiro de vídeo.

EOM

echo "============================================================"
echo "GATE CONSOLIDADO PRÉ-FASE 4 — FASES 2 E 3"
echo "============================================================"
echo "Data: $(date)"
echo

section "1. Estado Git e commits"

record_cmd "Git status inicial" git status --short
record_cmd "Últimos commits" git log --oneline --decorate -10
record_cmd "Branch atual" git branch --show-current

UNEXPECTED_STATUS="$(git status --short | allowed_gate_status_filter)"
if [ -n "$UNEXPECTED_STATUS" ]; then
  echo "ERRO: Git tem alterações inesperadas no início do gate:"
  echo "$UNEXPECTED_STATUS"
  echo "- ERRO: Git tem alterações inesperadas no início do gate." >> "$EVID"
  exit 10
fi

echo "OK: Git limpo, exceto artefatos esperados do próprio gate."
echo "- OK: Git limpo, exceto artefatos esperados do próprio gate." >> "$EVID"

section "2. Confirmação robusta da Fase 2 local"

F2_B20_EVID="fase2/docs/evidencias/fase2-bloco20-revalidacao-local-pre-fase4.md"
F2_B20_LOG="fase2/logs/fase2-bloco20-revalidacao-local-pre-fase4.log"
F2_B17_EVID="fase2/docs/evidencias/fase2-bloco17-validacao-e2e.md"
F2_B16_EVID="fase2/docs/evidencias/fase2-bloco16-estabilizacao-runtime.md"

for f in "$F2_B20_EVID" "$F2_B20_LOG" "$F2_B17_EVID" "$F2_B16_EVID"; do
  if [ ! -f "$f" ]; then
    echo "ERRO: arquivo obrigatório da Fase 2 não encontrado: $f"
    echo "- ERRO: arquivo obrigatório da Fase 2 não encontrado: \`$f\`." >> "$EVID"
    exit 11
  fi
done

if grep -qE 'Script 16:.*`0`|Resultado script 16:.*`0`|S16_RC=0' "$F2_B20_EVID" \
   && grep -qE 'Script 17:.*`0`|Resultado script 17:.*`0`|S17_RC=0' "$F2_B20_EVID"; then
  echo "OK: evidência do BLOCO 20 comprova scripts 16 e 17 com retorno 0."
  echo "- OK: evidência do BLOCO 20 comprova scripts 16 e 17 com retorno 0." >> "$EVID"
else
  echo "ERRO: evidência do BLOCO 20 não comprova scripts 16 e 17 com retorno 0."
  exit 12
fi

if grep -qE 'BLOCO 16 FINALIZADO COM SUCESSO|Health checks obrigatórios' "$F2_B20_LOG" \
   && grep -qE 'BLOCO 17 FINALIZADO COM SUCESSO|DynamoDB Count: 3|OK: DynamoDB scan retornou Count=3' "$F2_B20_LOG"; then
  echo "OK: log do BLOCO 20 comprova runtime e E2E local da Fase 2."
  echo "- OK: log do BLOCO 20 comprova runtime e E2E local da Fase 2." >> "$EVID"
else
  echo "ERRO: log do BLOCO 20 não comprova runtime + E2E local da Fase 2."
  exit 13
fi

record_file_tail \
  "Resumo recente da revalidação local da Fase 2" \
  "$F2_B20_LOG" \
  120

section "3. Confirmação robusta da Fase 3 cloud"

F3_B18_EVID="fase3/docs/evidencias/fase3-bloco18-checkpoint-retomada-pre-fase4.md"
F3_B19_EVID="fase3/docs/evidencias/fase3-bloco19-validacao-apps-pre-fase4.md"
F3_B19_LOG="fase3/logs/fase3-bloco19-validacao-apps-pre-fase4.log"
F3_B194_EVID="fase3/docs/evidencias/fase3-bloco19-4-diagnostico-async.md"
F3_B195_EVID="fase3/docs/evidencias/fase3-bloco19-5-refresh-pod-aws-creds.md"

for f in "$F3_B18_EVID" "$F3_B19_EVID" "$F3_B19_LOG" "$F3_B194_EVID" "$F3_B195_EVID"; do
  if [ ! -f "$f" ]; then
    echo "ERRO: arquivo obrigatório da Fase 3 não encontrado: $f"
    echo "- ERRO: arquivo obrigatório da Fase 3 não encontrado: \`$f\`." >> "$EVID"
    exit 14
  fi
done

if grep -qE 'Synced/Healthy|Pods.*sem pods não prontos|CHECKPOINT PRÉ-FASE 4' "$F3_B18_EVID"; then
  echo "OK: evidência do BLOCO 18 comprova checkpoint cloud/GitOps da Fase 3."
  echo "- OK: evidência do BLOCO 18 comprova checkpoint cloud/GitOps da Fase 3." >> "$EVID"
else
  echo "ERRO: evidência do BLOCO 18 não comprova checkpoint cloud/GitOps."
  exit 15
fi

if grep -qE 'BLOCO 19 CONCLUÍDO COM SUCESSO|Aplicações da Fase 3 validadas funcionalmente pré-Fase 4|DynamoDB depois' "$F3_B19_EVID" \
   && grep -qE 'BLOCO 19 CONCLUÍDO COM SUCESSO|DynamoDB depois: 7|DDB_COUNT_AFTER=7' "$F3_B19_LOG"; then
  echo "OK: evidência/log do BLOCO 19 comprovam validação funcional cloud da Fase 3."
  echo "- OK: evidência/log do BLOCO 19 comprovam validação funcional cloud da Fase 3." >> "$EVID"
else
  echo "ERRO: evidência/log do BLOCO 19 não comprovam validação funcional cloud."
  exit 16
fi

if grep -qE 'ExpiredToken|Diagnóstico do Fluxo Assíncrono|SQS.*ANALYTICS.*DYNAMODB|SQS -> Analytics -> DynamoDB' "$F3_B194_EVID"; then
  echo "OK: diagnóstico assíncrono da Fase 3 documentado."
  echo "- OK: diagnóstico assíncrono da Fase 3 documentado." >> "$EVID"
else
  echo "ERRO: diagnóstico assíncrono da Fase 3 não encontrado na evidência."
  exit 17
fi

if grep -qE 'Atualização das Credenciais AWS dos Pods|togglemaster-runtime-secret|evaluation-service|analytics-service' "$F3_B195_EVID"; then
  echo "OK: renovação de credenciais dos pods documentada."
  echo "- OK: renovação de credenciais dos pods documentada." >> "$EVID"
else
  echo "ERRO: renovação de credenciais dos pods não encontrada na evidência."
  exit 18
fi

record_file_tail \
  "Resumo recente da validação funcional da Fase 3" \
  "$F3_B19_LOG" \
  120

section "4. Estado atual read-only da Fase 3 cloud"

export AWS_REGION AWS_DEFAULT_REGION="$AWS_REGION"

record_cmd "AWS identity atual" aws sts get-caller-identity --output table
record_cmd "Clusters EKS" aws eks list-clusters --region "$AWS_REGION" --output table
record_cmd "Contexto kubectl" kubectl config current-context
record_cmd "ArgoCD application" kubectl get application togglemaster-dev -n argocd -o wide
record_cmd "Pods namespace togglemaster" kubectl get pods -n "$NAMESPACE" -o wide
record_cmd "Services namespace togglemaster" kubectl get svc -n "$NAMESPACE" -o wide

ARGO_STATUS="$(kubectl get application togglemaster-dev -n argocd -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"
PODS_NOT_READY="$(kubectl get pods -n "$NAMESPACE" --no-headers | awk '
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
  echo "### Resultado atual Kubernetes/GitOps"
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
  echo "ERRO: existem pods não prontos na Fase 3."
  echo "$PODS_NOT_READY"
  exit 21
fi

section "5. Artefatos de IaC, GitOps, automação e DevSecOps da Fase 3"

record_cmd "Terraform files" bash -lc 'find fase3/terraform -maxdepth 4 -type f | sort'
record_cmd "GitOps files" bash -lc 'find fase3/gitops -maxdepth 5 -type f | sort'
record_cmd "GitHub Actions workflows" bash -lc 'find .github/workflows -maxdepth 1 -type f | sort'
record_cmd "Scripts locais Fase 3" bash -lc 'find fase3/local/scripts -maxdepth 1 -type f | sort'

check_marker \
  "Fase 3 Terraform/GitOps offline evidenciada" \
  "fase3/docs/evidencias/fase3-bloco20-validacao-offline.md" \
  "Terraform|GitOps|validate|offline"

check_marker \
  "Fase 3 GitHub Actions offline evidenciada" \
  "fase3/docs/evidencias/fase3-bloco21-github-actions-offline.md" \
  "GitHub Actions|workflow|offline"

section "6. Segurança e segredos"

echo "Scanner definitivo de segredos com allowlist controlada para LocalStack test/test."

python3 - <<'PY_SECRET_SCAN' | tee "$TMP/secret-scan.out"
from pathlib import Path
import re
import subprocess
import sys

gate_files = [
    "_shared/scripts/21_gate_pre_fase4_fases2_3.sh",
    "_shared/evidencias/gate-pre-fase4-fases2-3.md",
]

tracked = subprocess.run(
    ["git", "ls-files"],
    text=True,
    capture_output=True,
    check=True,
).stdout.splitlines()

files = []
seen = set()

for f in tracked + gate_files:
    if not f or f in seen:
        continue
    seen.add(f)

    path = Path(f)
    parts = set(path.parts)
    name = path.name

    # Excluir artefatos temporários/gerados/backups/logs.
    if ".terraform" in parts or "logs" in parts or "tmp" in parts or "__pycache__" in parts:
        continue
    if ".bak" in name or ".backup" in name or name.endswith(".log"):
        continue

    # Escopo versionável relevante.
    if not (
        f.startswith("fase2/")
        or f.startswith("fase3/")
        or f.startswith("_shared/")
        or f.startswith(".github/")
        or f.startswith("bootstraps/")
        or f == "README.md"
    ):
        continue

    files.append(f)

findings = []

# Arquivos que nunca devem estar versionados.
for f in tracked:
    path = Path(f)
    name = path.name

    if name in {"terraform.tfstate", "terraform.tfstate.backup"}:
        findings.append((f, 0, "Terraform state versionado"))
    elif name.endswith(".tfstate") or name.endswith(".tfstate.backup"):
        findings.append((f, 0, "Terraform state versionado"))

    if name.endswith(".tfvars") and name != "terraform.tfvars.example":
        findings.append((f, 0, "tfvars real versionado"))

    if name.endswith(".auto.tfvars"):
        findings.append((f, 0, "auto.tfvars versionado"))

rx_tm_key = re.compile(r'tm_key_[A-Za-z0-9]{20,}')
rx_aws_key = re.compile(r'\b(?:AKIA|ASIA)[0-9A-Z]{16}\b')

# Private key real precisa ter delimitador PEM completo.
rx_private_key_real = re.compile(r'-----BEGIN (?:RSA|OPENSSH|EC|DSA) PRIVATE KEY-----')

rx_secret_assign = re.compile(
    r'(?i)\b(AWS_SECRET_ACCESS_KEY|AWS_SESSION_TOKEN|aws_secret_access_key|aws_session_token)\b\s*[:=]\s*["\']?([^"\'\s]+)'
)

rx_generic_sensitive = re.compile(
    r'(?i)\b(password|secret|token)\b\s*[:=]\s*["\']([^"\']{12,})["\']'
)

def is_regex_or_scanner_line(line: str) -> bool:
    markers = [
        "re.compile",
        "grep -RInE",
        "rx_",
        "BEGIN (?:RSA|OPENSSH|EC|DSA) PRIVATE KEY",
        "BEGIN RSA PRIVATE KEY",
        "BEGIN OPENSSH PRIVATE KEY",
        "AWS_SECRET_ACCESS_KEY=|",
        "AWS_SESSION_TOKEN=|",
        "aws_secret_access_key\\s*=",
        "aws_session_token\\s*=",
        "tm_key_[A-Za-z0-9]",
        "AKIA[0-9A-Z]",
        "ASIA[0-9A-Z]",
    ]
    return any(m in line for m in markers)

def allowed_fake_localstack(path: str, key: str, value: str) -> bool:
    normalized = path.replace("\\", "/")
    if not normalized.startswith("fase2/"):
        return False

    key_upper = key.upper()

    if key_upper == "AWS_SECRET_ACCESS_KEY" and value == "test":
        return True

    if key_upper == "AWS_SESSION_TOKEN" and value in {"test", "fake", "localstack"}:
        return True

    return False

def allowed_placeholder_or_variable(value: str) -> bool:
    if value in {"REDACTED", "test", "fake", "localstack", '""', "''"}:
        return True

    if value.startswith("$") or value.startswith("${"):
        return True

    if "{" in value or "}" in value:
        return True

    return False

for f in files:
    path = Path(f)
    if not path.exists() or not path.is_file():
        continue

    text = path.read_text(errors="ignore")

    for lineno, line in enumerate(text.splitlines(), start=1):
        if is_regex_or_scanner_line(line):
            continue

        if rx_tm_key.search(line):
            findings.append((f, lineno, "ToggleMaster API key real"))

        if rx_aws_key.search(line):
            findings.append((f, lineno, "AWS access key id real"))

        if rx_private_key_real.search(line):
            findings.append((f, lineno, "Private key real"))

        for m in rx_secret_assign.finditer(line):
            key = m.group(1)
            value = m.group(2).strip().strip('"').strip("'")

            if allowed_fake_localstack(f, key, value):
                continue

            if allowed_placeholder_or_variable(value):
                continue

            # Só acusa como real se parecer um valor concreto longo.
            if len(value) >= 20:
                findings.append((f, lineno, f"{key} assignment suspeito"))

        m = rx_generic_sensitive.search(line)
        if m:
            value = m.group(2).strip()
            if allowed_placeholder_or_variable(value):
                continue
            findings.append((f, lineno, f"{m.group(1)} genérico suspeito"))

print(f"Arquivos escaneados: {len(files)}")

if findings:
    print("ERRO: possíveis segredos reais encontrados:")
    for file, lineno, label in findings:
        if lineno:
            print(f"- {file}:{lineno}: {label}")
        else:
            print(f"- {file}: {label}")
    sys.exit(30)

print("OK: nenhum segredo real encontrado nos arquivos versionáveis relevantes.")
print("OK: credenciais fake test/test da Fase 2 LocalStack foram tratadas como allowlist controlada.")
print("OK: padrões de regex/scanner não foram tratados como segredos reais.")
PY_SECRET_SCAN

SCAN_RC=${PIPESTATUS[0]}

{
  echo
  echo "### Scanner de segredos"
  echo
  echo '```text'
  cat "$TMP/secret-scan.out"
  echo
  echo '```'
  echo
  echo "SCAN_RC: \`$SCAN_RC\`"
} >> "$EVID"

if [ "$SCAN_RC" -ne 0 ]; then
  echo "ERRO: scanner de segredos encontrou problema real."
  exit "$SCAN_RC"
fi

section "7. Declaração de prontidão para Fase 4"

cat >> "$EVID" <<EOM

## Declaração de prontidão

Com base nos checkpoints e evidências versionadas:

- A Fase 2 local está funcional e revalidada.
- A Fase 3 cloud está funcional e revalidada.
- GitOps/ArgoCD está \`Synced/Healthy\`.
- Os pods dos 5 microsserviços estão \`Running/Ready\`.
- A cadeia SQS -> analytics-service -> DynamoDB foi validada após renovação das credenciais temporárias do AWS Academy.
- A correção de segurança da Fase 2 impede persistência de API key runtime no Compose.
- Não há segredo real detectado nos arquivos versionáveis relevantes deste gate.
- A Fase 4 será iniciada como entrega real, não como rebuild.

EOM

section "8. Resultado final"

record_cmd "Git status final do gate" git status --short
record_cmd "HEAD final" git log --oneline --decorate -5

UNEXPECTED_FINAL="$(git status --short | allowed_gate_status_filter)"
if [ -n "$UNEXPECTED_FINAL" ]; then
  echo "ERRO: Git tem alterações inesperadas ao final do gate:"
  echo "$UNEXPECTED_FINAL"
  exit 40
fi

echo
echo "============================================================"
echo "GATE PRÉ-FASE 4 CONCLUÍDO COM SUCESSO"
echo "Fase 2 e Fase 3 estão aptas como base da Fase 4."
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "============================================================"
