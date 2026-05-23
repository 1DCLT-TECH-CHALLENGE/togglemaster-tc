#!/usr/bin/env bash
set -Eeuo pipefail

# BEGIN BLOCO20_3_COMPOSE_RESTORE_GUARD
# Proteção: o fluxo E2E da Fase 2 injeta API key dinâmica no Compose
# para recriar o evaluation-service. Essa alteração é runtime-only e
# não pode permanecer no arquivo versionado.
PHASE2_COMPOSE_FILE="$HOME/togglemaster-tc/fase2/docker/docker-compose.phase2-exec.yaml"
PHASE2_COMPOSE_BACKUP="$(mktemp /tmp/togglemaster-phase2-compose-before-e2e.XXXXXX.yaml)"

if [ -f "$PHASE2_COMPOSE_FILE" ]; then
  cp "$PHASE2_COMPOSE_FILE" "$PHASE2_COMPOSE_BACKUP"
fi

restore_phase2_compose_after_e2e() {
  local rc=$?
  if [ -f "${PHASE2_COMPOSE_BACKUP:-}" ] && [ -f "${PHASE2_COMPOSE_FILE:-}" ]; then
    cp "$PHASE2_COMPOSE_BACKUP" "$PHASE2_COMPOSE_FILE"
    rm -f "$PHASE2_COMPOSE_BACKUP"
    echo "OK: Compose da Fase 2 restaurado após E2E para evitar persistência de API key runtime."
  fi
  exit "$rc"
}

trap restore_phase2_compose_after_e2e EXIT
# END BLOCO20_3_COMPOSE_RESTORE_GUARD


BASE="$HOME/togglemaster-tc/fase2"
DOCKER_DIR="$BASE/docker"
COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"
ENV_FILE="$DOCKER_DIR/.env.phase2.local"

LOG="$BASE/logs/fase2-bloco17-e2e-flow.log"
EVID="$BASE/docs/evidencias/fase2-bloco17-validacao-e2e.md"

MASTER_KEY="local-master-key"
FLAG_NAME="enable-new-dashboard"
TARGETING_RULE_VALUE="50"
SQS_TEST_USER="user-123-sqs"

mkdir -p "$BASE/logs" "$BASE/docs/evidencias"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 17 - VALIDAÇÃO FUNCIONAL E2E"
echo "============================================================"
echo "Data: $(date)"
echo

{
  echo "# Fase 2 - BLOCO 17 - Validação Funcional End-to-End"
  echo
  echo "Data: $(date)"
  echo
  echo "## Objetivo"
  echo "Validar a Fase 2 local de ponta a ponta: auth, flag, targeting, evaluation, Redis, SQS LocalStack, analytics-service e DynamoDB LocalStack."
  echo
} > "$EVID"

cd "$DOCKER_DIR"

echo
echo "[1/12] Validando arquivos obrigatórios"

for f in "$COMPOSE_FILE" "$ENV_FILE"
do
  if [ ! -f "$f" ]; then
    echo "ERRO: arquivo obrigatório não encontrado: $f"
    exit 1
  fi
  echo "OK: $f"
done

echo
echo "[2/12] Validando serviços obrigatórios em execução"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps | tee -a "$EVID"

REQUIRED_SERVICES="auth-service flag-service targeting-service evaluation-service analytics-service localstack redis postgres-auth postgres-flags postgres-targeting"

for svc in $REQUIRED_SERVICES
do
  if ! docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps --services --filter status=running | grep -qx "$svc"; then
    echo "ERRO: serviço obrigatório não está running: $svc"
    echo "Execute/estabilize o BLOCO 16 antes do BLOCO 17."
    exit 1
  fi
  echo "OK running: $svc"
done

echo
echo "[3/12] Health checks HTTP"

{
  echo
  echo "## Health checks"
} >> "$EVID"

for item in \
  "8001 auth-service" \
  "8002 flag-service" \
  "8003 targeting-service" \
  "8004 evaluation-service" \
  "8005 analytics-service"
do
  port="$(echo "$item" | awk '{print $1}')"
  svc="$(echo "$item" | awk '{print $2}')"

  echo
  echo "### $svc / porta $port ###"

  if curl -fsS --max-time 8 "http://localhost:$port/health" | tee "$BASE/logs/fase2-bloco17-health-$svc.json"; then
    echo "OK: $svc health"
  else
    echo "ERRO: health falhou para $svc na porta $port"
    exit 1
  fi
done | tee -a "$EVID"

echo
echo "[4/12] Auth-service: criar API key"

API_RESPONSE="$(
  curl -sS --max-time 10 -X POST http://localhost:8001/admin/keys \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $MASTER_KEY" \
    -d '{"name":"phase2-e2e-local"}'
)"

echo "$API_RESPONSE" | tee "$BASE/logs/fase2-bloco17-api-key-response.json" | tee -a "$EVID"

API_KEY="$(echo "$API_RESPONSE" | python3 -c '
import sys, json
d = json.load(sys.stdin)
print(d.get("key") or d.get("api_key") or d.get("apiKey") or "")
')"

if [ -z "$API_KEY" ]; then
  echo "ERRO: não foi possível extrair API key da resposta do auth-service."
  exit 1
fi

echo "OK: API key criada e extraída."

echo
echo "[5/12] Injetando API key dinâmica no evaluation-service"

python3 - "$COMPOSE_FILE" "$API_KEY" <<'PY'
from pathlib import Path
import sys

compose = Path(sys.argv[1])
api_key = sys.argv[2]
lines = compose.read_text().splitlines()

def find_service_block(lines, service):
    start = None
    for i, line in enumerate(lines):
        if line.strip() == f"{service}:" and line.startswith("  "):
            start = i
            break
    if start is None:
        raise SystemExit(f"Serviço não encontrado: {service}")

    end = len(lines)
    for j in range(start + 1, len(lines)):
        if lines[j].startswith("  ") and not lines[j].startswith("    ") and lines[j].strip().endswith(":"):
            end = j
            break

    return start, end

def ensure_environment(lines, service):
    start, end = find_service_block(lines, service)
    for i in range(start, end):
        if lines[i].startswith("    environment:"):
            return lines, i

    insert_at = start + 1
    lines.insert(insert_at, "    environment:")
    return lines, insert_at

def set_env(lines, service, key, value):
    lines, env_idx = ensure_environment(lines, service)
    start, end = find_service_block(lines, service)

    for i in range(env_idx + 1, end):
        stripped = lines[i].strip()
        if stripped.startswith(f"{key}:"):
            lines[i] = f'      {key}: "{value}"'
            return lines
        if stripped.startswith(f"- {key}="):
            lines[i] = f'      {key}: "{value}"'
            return lines

    lines.insert(env_idx + 1, f'      {key}: "{value}"')
    return lines

lines = set_env(lines, "evaluation-service", "SERVICE_API_KEY", api_key)
compose.write_text("\n".join(lines) + "\n")
PY

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" config >/tmp/fase2-compose-bloco17-rendered.yaml

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d --force-recreate evaluation-service

sleep 10

if curl -fsS --max-time 8 http://localhost:8004/health | tee "$BASE/logs/fase2-bloco17-health-evaluation-after-key.json"; then
  echo "OK: evaluation-service recriado com API key dinâmica."
else
  echo "ERRO: evaluation-service não respondeu após recriação."
  exit 1
fi

echo
echo "[6/12] Auth-service: validar API key"

curl -sS -i --max-time 10 http://localhost:8001/validate \
  -H "Authorization: Bearer $API_KEY" \
  | tee "$BASE/logs/fase2-bloco17-validate-api-key.log" \
  | tee -a "$EVID"

if ! grep -q "Chave válida" "$BASE/logs/fase2-bloco17-validate-api-key.log"; then
  echo "ERRO: API key criada não foi validada."
  exit 1
fi

echo
echo "[7/12] Flag-service: criar/listar flag"

CREATE_FLAG_RESPONSE="$(
  curl -sS -i --max-time 10 -X POST http://localhost:8002/flags \
    -H "Authorization: Bearer $API_KEY" \
    -H 'Content-Type: application/json' \
    -d "{\"name\":\"$FLAG_NAME\",\"description\":\"Flag E2E local Fase 2\",\"is_enabled\":true}"
)"

echo "$CREATE_FLAG_RESPONSE" | tee "$BASE/logs/fase2-bloco17-create-flag.log" | tee -a "$EVID"

if echo "$CREATE_FLAG_RESPONSE" | grep -qE "HTTP/1.1 201|HTTP/1.1 409"; then
  echo "OK: flag criada ou já existente."
else
  echo "ERRO: criação da flag falhou."
  exit 1
fi

curl -sS -i --max-time 10 http://localhost:8002/flags \
  -H "Authorization: Bearer $API_KEY" \
  | tee "$BASE/logs/fase2-bloco17-list-flags.log" \
  | tee -a "$EVID"

if ! grep -q "$FLAG_NAME" "$BASE/logs/fase2-bloco17-list-flags.log"; then
  echo "ERRO: flag $FLAG_NAME não apareceu na listagem."
  exit 1
fi

echo
echo "[8/12] Targeting-service: criar/consultar regra"

CREATE_RULE_RESPONSE="$(
  curl -sS -i --max-time 10 -X POST http://localhost:8003/rules \
    -H "Authorization: Bearer $API_KEY" \
    -H 'Content-Type: application/json' \
    -d "{
      \"flag_name\":\"$FLAG_NAME\",
      \"is_enabled\":true,
      \"rules\":{
        \"type\":\"PERCENTAGE\",
        \"value\":$TARGETING_RULE_VALUE
      }
    }"
)"

echo "$CREATE_RULE_RESPONSE" | tee "$BASE/logs/fase2-bloco17-create-rule.log" | tee -a "$EVID"

if echo "$CREATE_RULE_RESPONSE" | grep -qE "HTTP/1.1 201|HTTP/1.1 409"; then
  echo "OK: regra criada ou já existente."
else
  echo "ERRO: criação da regra falhou."
  exit 1
fi

curl -sS -i --max-time 10 "http://localhost:8003/rules/$FLAG_NAME" \
  -H "Authorization: Bearer $API_KEY" \
  | tee "$BASE/logs/fase2-bloco17-get-rule.log" \
  | tee -a "$EVID"

if ! grep -q '"type":"PERCENTAGE"' "$BASE/logs/fase2-bloco17-get-rule.log"; then
  echo "ERRO: regra PERCENTAGE não encontrada na consulta."
  exit 1
fi

echo
echo "[9/12] Evaluation-service: avaliar usuários"

for user in user-123 user-abc "$SQS_TEST_USER"
do
  echo
  echo "### evaluate $user ###"

  curl -sS -i --max-time 15 \
    "http://localhost:8004/evaluate?user_id=$user&flag_name=$FLAG_NAME" \
    | tee "$BASE/logs/fase2-bloco17-evaluate-$user.log" \
    | tee -a "$EVID"

  if ! grep -q '"flag_name":"'"$FLAG_NAME"'"' "$BASE/logs/fase2-bloco17-evaluate-$user.log"; then
    echo "ERRO: avaliação falhou para $user."
    exit 1
  fi
done

echo
echo "[10/12] Evaluation-service: confirmar envio para SQS"

sleep 5

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" logs --tail=120 evaluation-service \
  | tee "$BASE/logs/fase2-bloco17-evaluation-sqs.log" \
  | tee -a "$EVID"

if ! grep -q "Evento de avaliação enviado para SQS" "$BASE/logs/fase2-bloco17-evaluation-sqs.log"; then
  echo "ERRO: envio para SQS não confirmado nos logs do evaluation-service."
  exit 1
fi

echo
echo "[11/12] Analytics-service: confirmar consumo e DynamoDB"

sleep 10

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" logs --tail=160 analytics-service \
  | tee "$BASE/logs/fase2-bloco17-analytics-consumo.log" \
  | tee -a "$EVID"

if ! grep -q "salvo no DynamoDB" "$BASE/logs/fase2-bloco17-analytics-consumo.log"; then
  echo "ERRO: analytics-service não confirmou gravação no DynamoDB."
  exit 1
fi

echo
echo "[12/12] DynamoDB LocalStack: scan final"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" exec -T localstack \
  awslocal dynamodb scan --table-name ToggleMasterAnalytics \
  | tee "$BASE/logs/fase2-bloco17-dynamodb-scan.json" \
  | tee -a "$EVID"

COUNT="$(python3 - <<PY
import json
from pathlib import Path
p = Path("$BASE/logs/fase2-bloco17-dynamodb-scan.json")
try:
    data = json.loads(p.read_text())
    print(data.get("Count", 0))
except Exception:
    print(0)
PY
)"

if [ "$COUNT" -lt 1 ]; then
  echo "ERRO: DynamoDB scan retornou Count=$COUNT."
  exit 1
fi

echo
echo "OK: DynamoDB scan retornou Count=$COUNT."

{
  echo
  echo "## Resultado final"
  echo
  echo "BLOCO 17 validado com sucesso."
  echo
  echo "- Health dos 5 serviços: OK"
  echo "- API key dinâmica: OK"
  echo "- Flag: OK"
  echo "- Targeting rule: OK"
  echo "- Evaluation: OK"
  echo "- Envio para SQS LocalStack: OK"
  echo "- Consumo pelo analytics-service: OK"
  echo "- Gravação DynamoDB LocalStack: OK"
  echo "- DynamoDB Count: \`$COUNT\`"
  echo
  echo "## Arquivos gerados"
  echo
  echo "- Log: \`$LOG\`"
  echo "- DynamoDB scan: \`$BASE/logs/fase2-bloco17-dynamodb-scan.json\`"
  echo "- Logs evaluation/SQS: \`$BASE/logs/fase2-bloco17-evaluation-sqs.log\`"
  echo "- Logs analytics: \`$BASE/logs/fase2-bloco17-analytics-consumo.log\`"
} >> "$EVID"

echo
echo "============================================================"
echo "BLOCO 17 FINALIZADO COM SUCESSO"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "DynamoDB Count: $COUNT"
echo "============================================================"
