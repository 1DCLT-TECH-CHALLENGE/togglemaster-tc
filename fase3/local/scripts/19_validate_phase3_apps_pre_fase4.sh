#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME/togglemaster-tc"
PHASE="$ROOT/fase3"
LOG="$PHASE/logs/fase3-bloco19-validacao-apps-pre-fase4.log"
EVID="$PHASE/docs/evidencias/fase3-bloco19-validacao-apps-pre-fase4.md"
TMP="$PHASE/tmp/bloco19"

AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
NAMESPACE="togglemaster"
SECRET_NAME="togglemaster-runtime-secret"
FLAG_NAME="enable-new-dashboard"
RULE_TYPE="PERCENTAGE"
RULE_VALUE="50"
DDB_TABLE="togglemaster-dev-ToggleMasterAnalytics"
SQS_QUEUE_NAME="togglemaster-dev-togglemaster-events"

mkdir -p "$PHASE/logs" "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

PF_PIDS=""

cleanup() {
  echo
  echo "Encerrando port-forwards..."
  for pid in $PF_PIDS; do
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
    fi
  done
}
trap cleanup EXIT

record_evid_header() {
  cat > "$EVID" <<EOM
# Fase 3 - BLOCO 19 - Validação Funcional das Aplicações Pré-Fase 4

Data: $(date)

## Objetivo

Validar que as aplicações da Fase 3 continuam funcionais na AWS antes de iniciar a Fase 4.

Este bloco valida:

- Health dos 5 microsserviços.
- Criação e validação de API key.
- Flag service.
- Targeting service.
- Evaluation service.
- Envio de eventos para SQS real.
- Consumo pelo analytics-service.
- Gravação no DynamoDB real.
- Estado final dos pods e ArgoCD.

## Observação

Este teste usa \`kubectl port-forward\` local para acessar os Services \`ClusterIP\`, sem criar ou alterar recursos de infraestrutura.

EOM
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

append_cmd() {
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
  "$@" 2>&1 | tee "$TMP/last_cmd.out"
  local rc=${PIPESTATUS[0]}
  set -e

  cat "$TMP/last_cmd.out" >> "$EVID"

  {
    echo '```'
    echo
    echo "RC: \`$rc\`"
  } >> "$EVID"

  echo
  echo "RC=$rc"
  return "$rc"
}

redact_body_for_output() {
  local infile="$1"

  python3 - "$infile" <<'PY_REDACT'
import json
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
raw = path.read_text(errors="ignore") if path.exists() else ""

def redact(obj):
    if isinstance(obj, dict):
        clean = {}
        for k, v in obj.items():
            lk = str(k).lower()
            if lk in {"key", "api_key", "apikey", "token", "secret", "password"}:
                clean[k] = "REDACTED"
            else:
                clean[k] = redact(v)
        return clean
    if isinstance(obj, list):
        return [redact(v) for v in obj]
    if isinstance(obj, str):
        return re.sub(r"tm_key_[A-Za-z0-9]+", "tm_key_REDACTED", obj)
    return obj

try:
    data = json.loads(raw)
    print(json.dumps(redact(data), ensure_ascii=False))
except Exception:
    redacted = re.sub(r"tm_key_[A-Za-z0-9]+", "tm_key_REDACTED", raw)
    redacted = re.sub(r'("key"\s*:\s*")[^"]+(")', r'\1REDACTED\2', redacted)
    redacted = re.sub(r'("api_key"\s*:\s*")[^"]+(")', r'\1REDACTED\2', redacted)
    redacted = re.sub(r'("apiKey"\s*:\s*")[^"]+(")', r'\1REDACTED\2', redacted)
    redacted = re.sub(r'("token"\s*:\s*")[^"]+(")', r'\1REDACTED\2', redacted)
    print(redacted, end="" if redacted.endswith("\n") else "\n")
PY_REDACT
}

http_request() {
  local name="$1"
  local method="$2"
  local url="$3"
  local body="${4:-}"
  local outfile="$5"
  shift 5
  local headers=("$@")

  local status_file="$outfile.status"

  if [ -n "$body" ]; then
    curl -sS --max-time 15 \
      -X "$method" "$url" \
      "${headers[@]}" \
      -H 'Content-Type: application/json' \
      -d "$body" \
      -o "$outfile" \
      -w "%{http_code}" > "$status_file"
  else
    curl -sS --max-time 15 \
      -X "$method" "$url" \
      "${headers[@]}" \
      -o "$outfile" \
      -w "%{http_code}" > "$status_file"
  fi

  local status
  status="$(cat "$status_file")"

  {
    echo
    echo "### $name"
    echo "HTTP_STATUS=$status"
    redact_body_for_output "$outfile"
    echo
  } >&2

  {
    echo
    echo "### $name"
    echo
    echo "- HTTP status: \`$status\`"
    echo
    echo '```json'
    redact_body_for_output "$outfile"
    echo
    echo '```'
  } >> "$EVID"

  echo "$status"
}

expect_http_2xx_or_409() {
  local label="$1"
  local status="$2"

  case "$status" in
    200|201|202|204|409)
      echo "OK: $label retornou HTTP $status"
      ;;
    *)
      echo "ERRO: $label retornou HTTP $status"
      exit 10
      ;;
  esac
}

expect_http_2xx() {
  local label="$1"
  local status="$2"

  case "$status" in
    200|201|202|204)
      echo "OK: $label retornou HTTP $status"
      ;;
    *)
      echo "ERRO: $label retornou HTTP $status"
      exit 11
      ;;
  esac
}

wait_http() {
  local name="$1"
  local url="$2"

  echo "Aguardando $name em $url"

  for i in $(seq 1 30); do
    if curl -fsS --max-time 3 "$url" >/dev/null 2>&1; then
      echo "OK: $name respondeu."
      return 0
    fi
    sleep 1
  done

  echo "ERRO: $name não respondeu em tempo hábil."
  return 1
}

start_port_forward() {
  local svc="$1"
  local local_port="$2"
  local svc_port="$3"
  local pf_log="$TMP/port-forward-$svc.log"

  echo "Iniciando port-forward: $svc localhost:$local_port -> svc/$svc:$svc_port"

  kubectl -n "$NAMESPACE" port-forward "svc/$svc" "$local_port:$svc_port" > "$pf_log" 2>&1 &
  local pid=$!
  PF_PIDS="$PF_PIDS $pid"

  sleep 2

  if ! kill -0 "$pid" 2>/dev/null; then
    echo "ERRO: port-forward de $svc morreu ao iniciar."
    cat "$pf_log" || true
    exit 20
  fi
}

get_secret_value_silent() {
  local key="$1"

  kubectl -n "$NAMESPACE" get secret "$SECRET_NAME" \
    -o "jsonpath={.data.$key}" \
    | base64 -d
}

json_get_api_key() {
  python3 -c '
import json
import sys

try:
    data = json.load(sys.stdin)
except Exception:
    print("")
    raise SystemExit(0)

for key in ("api_key", "apiKey", "key", "token"):
    val = data.get(key)
    if val:
        print(val)
        break
else:
    print("")
'
}


json_get_count() {
  python3 -c '
import json
import sys

try:
    data = json.load(sys.stdin)
    print(int(data.get("Count", 0)))
except Exception:
    print(0)
'
}


record_evid_header

echo "============================================================"
echo "FASE 3 - BLOCO 19 - VALIDAÇÃO FUNCIONAL DAS APLICAÇÕES"
echo "============================================================"
echo "Data: $(date)"
echo

section "1. Pré-checks AWS, Kubernetes e GitOps"

export AWS_REGION AWS_DEFAULT_REGION="$AWS_REGION"

append_cmd "AWS identity" aws sts get-caller-identity --output table
append_cmd "Contexto kubectl" kubectl config current-context
append_cmd "ArgoCD application" kubectl get application togglemaster-dev -n argocd -o wide
append_cmd "Pods iniciais" kubectl get pods -n "$NAMESPACE" -o wide
append_cmd "Services" kubectl get svc -n "$NAMESPACE" -o wide

ARGO_STATUS="$(kubectl get application togglemaster-dev -n argocd -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"

if [ "$ARGO_STATUS" != "Synced/Healthy" ]; then
  echo "ERRO: ArgoCD não está Synced/Healthy. Status atual: ${ARGO_STATUS:-indisponível}"
  exit 30
fi

PODS_NOT_READY="$(kubectl get pods -n "$NAMESPACE" --no-headers | awk '
{
  split($2, ready, "/");
  if (ready[1] != ready[2] || $3 != "Running") {
    print $0;
  }
}' || true)"

if [ -n "$PODS_NOT_READY" ]; then
  echo "ERRO: existem pods não prontos:"
  echo "$PODS_NOT_READY"
  exit 31
fi

section "2. Validar Secret operacional sem expor valores"

kubectl -n "$NAMESPACE" get secret "$SECRET_NAME" >/dev/null

MASTER_KEY="$(get_secret_value_silent MASTER_KEY || true)"

if [ -z "$MASTER_KEY" ]; then
  echo "ERRO: MASTER_KEY ausente no Secret $SECRET_NAME."
  exit 40
fi

echo "OK: Secret operacional existe e MASTER_KEY foi carregada sem exibir valor."
echo "- OK: Secret operacional existe e MASTER_KEY foi carregada sem exibir valor." >> "$EVID"

section "3. Descobrir SQS e contar DynamoDB antes do teste"

SQS_URL="$(aws sqs get-queue-url \
  --queue-name "$SQS_QUEUE_NAME" \
  --region "$AWS_REGION" \
  --query 'QueueUrl' \
  --output text)"

echo "SQS_URL=$SQS_URL"
echo "- SQS URL validada: \`$SQS_URL\`" >> "$EVID"

DDB_BEFORE_JSON="$TMP/ddb-before.json"
aws dynamodb scan \
  --region "$AWS_REGION" \
  --table-name "$DDB_TABLE" \
  --select COUNT \
  > "$DDB_BEFORE_JSON"

DDB_COUNT_BEFORE="$(cat "$DDB_BEFORE_JSON" | json_get_count)"

echo "DDB_COUNT_BEFORE=$DDB_COUNT_BEFORE"
echo "- DynamoDB Count antes do teste: \`$DDB_COUNT_BEFORE\`" >> "$EVID"

section "4. Iniciar port-forwards locais"

start_port_forward auth-service 18001 8000
start_port_forward flag-service 18002 8000
start_port_forward targeting-service 18003 8000
start_port_forward evaluation-service 18004 8000
start_port_forward analytics-service 18005 8000

wait_http "auth-service" "http://127.0.0.1:18001/health"
wait_http "flag-service" "http://127.0.0.1:18002/health"
wait_http "targeting-service" "http://127.0.0.1:18003/health"
wait_http "evaluation-service" "http://127.0.0.1:18004/health"
wait_http "analytics-service" "http://127.0.0.1:18005/health"

section "5. Health checks HTTP dos microsserviços"

for svc in \
  "auth-service:18001" \
  "flag-service:18002" \
  "targeting-service:18003" \
  "evaluation-service:18004" \
  "analytics-service:18005"
do
  name="${svc%%:*}"
  port="${svc##*:}"
  out="$TMP/health-$name.json"

  status="$(http_request "Health $name" GET "http://127.0.0.1:$port/health" "" "$out")"
  expect_http_2xx "Health $name" "$status"
done

section "6. Auth-service: criar e validar API key"

API_KEY_RESPONSE="$TMP/auth-create-api-key.json"

status="$(http_request "Auth - criar API key" POST "http://127.0.0.1:18001/admin/keys" \
  '{"name":"phase3-pre-fase4"}' \
  "$API_KEY_RESPONSE" \
  -H "Authorization: Bearer $MASTER_KEY")"

expect_http_2xx "Auth criar API key" "$status"

API_KEY="$(cat "$API_KEY_RESPONSE" | json_get_api_key)"

if [ -z "$API_KEY" ]; then
  echo "ERRO: não foi possível extrair api_key da resposta do auth-service."
  exit 50
fi

echo "OK: API key criada e carregada sem exibir valor."
echo "- OK: API key criada e carregada sem exibir valor." >> "$EVID"

VALIDATE_RESPONSE="$TMP/auth-validate-api-key.json"

status="$(http_request "Auth - validar API key" GET "http://127.0.0.1:18001/validate" \
  "" \
  "$VALIDATE_RESPONSE" \
  -H "Authorization: Bearer $API_KEY")"

expect_http_2xx "Auth validar API key" "$status"

section "7. Flag-service: criar/listar flag"

FLAG_CREATE_RESPONSE="$TMP/flag-create.json"

status="$(http_request "Flag - criar flag $FLAG_NAME" POST "http://127.0.0.1:18002/flags" \
  "{\"name\":\"$FLAG_NAME\",\"description\":\"Flag validada no BLOCO 19 pré-Fase 4\",\"is_enabled\":true}" \
  "$FLAG_CREATE_RESPONSE" \
  -H "X-API-Key: $API_KEY" \
  -H "Authorization: Bearer $API_KEY")"

expect_http_2xx_or_409 "Flag criar $FLAG_NAME" "$status"

FLAG_LIST_RESPONSE="$TMP/flag-list.json"

status="$(http_request "Flag - listar flags" GET "http://127.0.0.1:18002/flags" \
  "" \
  "$FLAG_LIST_RESPONSE" \
  -H "X-API-Key: $API_KEY" \
  -H "Authorization: Bearer $API_KEY")"

expect_http_2xx "Flag listar" "$status"

if ! grep -q "$FLAG_NAME" "$FLAG_LIST_RESPONSE"; then
  echo "ERRO: flag $FLAG_NAME não apareceu na listagem."
  exit 60
fi

section "8. Targeting-service: criar regra"

RULE_CREATE_RESPONSE="$TMP/targeting-create-rule.json"

status="$(http_request "Targeting - criar regra $RULE_TYPE $RULE_VALUE" POST "http://127.0.0.1:18003/rules" \
  "{\"flag_name\":\"$FLAG_NAME\",\"rules\":{\"type\":\"$RULE_TYPE\",\"value\":$RULE_VALUE}}" \
  "$RULE_CREATE_RESPONSE" \
  -H "X-API-Key: $API_KEY" \
  -H "Authorization: Bearer $API_KEY")"

expect_http_2xx_or_409 "Targeting criar regra" "$status"

section "9. Evaluation-service: avaliar flag e gerar eventos"

for user in user-123 user-abc user-123-sqs
do
  echo
  echo "Avaliando $user"

  EVAL_RESPONSE="$TMP/evaluate-$user.json"

  set +e
  status="$(http_request "Evaluation GET - $user" GET "http://127.0.0.1:18004/evaluate?user_id=$user&flag_name=$FLAG_NAME" \
    "" \
    "$EVAL_RESPONSE" \
    -H "X-API-Key: $API_KEY" \
    -H "Authorization: Bearer $API_KEY")"
  rc=$?
  set -e

  if [ "$status" = "404" ] || [ "$status" = "405" ] || [ "$status" = "000" ]; then
    status="$(http_request "Evaluation POST - $user" POST "http://127.0.0.1:18004/evaluate" \
      "{\"user_id\":\"$user\",\"flag_name\":\"$FLAG_NAME\"}" \
      "$EVAL_RESPONSE" \
      -H "X-API-Key: $API_KEY" \
      -H "Authorization: Bearer $API_KEY")"
  fi

  expect_http_2xx "Evaluation $user" "$status"

  if ! grep -q "$FLAG_NAME" "$EVAL_RESPONSE"; then
    echo "ERRO: resposta de evaluation para $user não contém flag_name esperado."
    exit 70
  fi
done

section "10. Validar SQS, analytics-service e DynamoDB"

echo "Aguardando analytics-service consumir mensagens..."
sleep 20

SQS_ATTRS="$TMP/sqs-attrs-after.json"
aws sqs get-queue-attributes \
  --region "$AWS_REGION" \
  --queue-url "$SQS_URL" \
  --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible ApproximateNumberOfMessagesDelayed \
  > "$SQS_ATTRS"

echo
echo "Atributos SQS após avaliações:"
cat "$SQS_ATTRS"

{
  echo
  echo "### Atributos SQS após avaliações"
  echo
  echo '```json'
  cat "$SQS_ATTRS"
  echo
  echo '```'
} >> "$EVID"

DDB_AFTER_JSON="$TMP/ddb-after.json"
aws dynamodb scan \
  --region "$AWS_REGION" \
  --table-name "$DDB_TABLE" \
  --select COUNT \
  > "$DDB_AFTER_JSON"

DDB_COUNT_AFTER="$(cat "$DDB_AFTER_JSON" | json_get_count)"

echo
echo "DDB_COUNT_AFTER=$DDB_COUNT_AFTER"
echo "- DynamoDB Count depois do teste: \`$DDB_COUNT_AFTER\`" >> "$EVID"

if [ "$DDB_COUNT_AFTER" -le "$DDB_COUNT_BEFORE" ]; then
  echo "ERRO: DynamoDB Count não aumentou. Antes=$DDB_COUNT_BEFORE Depois=$DDB_COUNT_AFTER"
  echo "Isso indica que analytics-service não gravou novos eventos."
  exit 80
fi

DDB_SAMPLE="$TMP/ddb-sample.json"
aws dynamodb scan \
  --region "$AWS_REGION" \
  --table-name "$DDB_TABLE" \
  --limit 5 \
  > "$DDB_SAMPLE"

{
  echo
  echo "### Amostra DynamoDB após teste"
  echo
  echo '```json'
  cat "$DDB_SAMPLE"
  echo
  echo '```'
} >> "$EVID"

section "11. Logs recentes dos serviços"

append_cmd "Logs evaluation-service" kubectl logs -n "$NAMESPACE" deployment/evaluation-service --tail=80
append_cmd "Logs analytics-service" kubectl logs -n "$NAMESPACE" deployment/analytics-service --tail=120

section "12. Estado final"

append_cmd "ArgoCD final" kubectl get application togglemaster-dev -n argocd -o wide
append_cmd "Pods finais" kubectl get pods -n "$NAMESPACE" -o wide

ARGO_STATUS_FINAL="$(kubectl get application togglemaster-dev -n argocd -o jsonpath='{.status.sync.status}/{.status.health.status}' 2>/dev/null || true)"

PODS_NOT_READY_FINAL="$(kubectl get pods -n "$NAMESPACE" --no-headers | awk '
{
  split($2, ready, "/");
  if (ready[1] != ready[2] || $3 != "Running") {
    print $0;
  }
}' || true)"

{
  echo
  echo "## Resultado final"
  echo
  echo "- ArgoCD final: \`$ARGO_STATUS_FINAL\`"
  echo "- DynamoDB antes: \`$DDB_COUNT_BEFORE\`"
  echo "- DynamoDB depois: \`$DDB_COUNT_AFTER\`"
  echo "- Log completo: \`$LOG\`"
} >> "$EVID"

if [ "$ARGO_STATUS_FINAL" != "Synced/Healthy" ]; then
  echo "ERRO: ArgoCD final não está Synced/Healthy: $ARGO_STATUS_FINAL"
  exit 90
fi

if [ -n "$PODS_NOT_READY_FINAL" ]; then
  echo "ERRO: pods não prontos após teste:"
  echo "$PODS_NOT_READY_FINAL"
  exit 91
fi

echo
echo "============================================================"
echo "BLOCO 19 CONCLUÍDO COM SUCESSO"
echo "Aplicações da Fase 3 validadas funcionalmente pré-Fase 4."
echo "DynamoDB antes: $DDB_COUNT_BEFORE"
echo "DynamoDB depois: $DDB_COUNT_AFTER"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "============================================================"
