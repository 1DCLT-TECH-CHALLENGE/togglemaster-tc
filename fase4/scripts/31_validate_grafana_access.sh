#!/usr/bin/env bash
set -Eeuo pipefail

cd "$HOME/togglemaster-tc"

PHASE="fase4"
EVID="$PHASE/docs/evidencias/fase4-bloco31-grafana-access.md"
LOG="$PHASE/docs/evidencias/fase4-bloco31-grafana-access.log"
TMP="$PHASE/tmp/bloco31"

OBS_NS="observability"
GRAFANA_SVC="kube-prometheus-stack-grafana"
LOCAL_PORT="13000"

mkdir -p "$PHASE/docs/evidencias" "$TMP"

exec > >(tee "$LOG") 2>&1

cleanup() {
  if [ -n "${PF_PID:-}" ]; then
    echo
    echo "Cleanup: encerrando port-forward Grafana..."
    kill "$PF_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

cat > "$EVID" <<EOM
# Fase 4 - BLOCO 31 - Validação de Acesso ao Grafana

Data: $(date)

## Objetivo

Validar que o Grafana instalado pelo kube-prometheus-stack está acessível e integrado ao Prometheus.

Este bloco não instala novos componentes.

A senha admin do Grafana é lida do Kubernetes Secret somente em memória e não é registrada nesta evidência.

EOM

echo "[1/8] Estado inicial"
git status --short
kubectl get application observability-kube-prometheus-stack -n argocd -o wide
kubectl get pods -n "$OBS_NS" -o wide
kubectl get svc -n "$OBS_NS" "$GRAFANA_SVC" -o wide

echo
echo "[2/8] Obtendo credencial admin do Grafana sem exibir senha"
GRAFANA_USER="admin"
GRAFANA_PASS="$(kubectl get secret kube-prometheus-stack-grafana -n "$OBS_NS" -o jsonpath='{.data.admin-password}' | base64 -d)"

if [ -z "$GRAFANA_PASS" ]; then
  echo "ERRO: senha admin do Grafana não encontrada."
  exit 10
fi

echo "OK: senha admin carregada em memória. Não será exibida nem salva."

echo
echo "[3/8] Abrindo port-forward temporário"
pkill -f "kubectl.*port-forward.*${GRAFANA_SVC}.*${LOCAL_PORT}:80" >/dev/null 2>&1 || true

kubectl -n "$OBS_NS" port-forward "svc/$GRAFANA_SVC" "${LOCAL_PORT}:80" > "$TMP/grafana-port-forward.log" 2>&1 &
PF_PID=$!

sleep 5

if ! kill -0 "$PF_PID" >/dev/null 2>&1; then
  echo "ERRO: port-forward não ficou ativo."
  cat "$TMP/grafana-port-forward.log" || true
  exit 20
fi

echo "OK: port-forward ativo em http://localhost:${LOCAL_PORT}"

echo
echo "[4/8] Validando Grafana /api/health"
curl -sS -u "${GRAFANA_USER}:${GRAFANA_PASS}" "http://localhost:${LOCAL_PORT}/api/health" > "$TMP/grafana-health.json"
cat "$TMP/grafana-health.json"

python3 - "$TMP/grafana-health.json" <<'PY'
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text())
if data.get("database") != "ok":
    print("ERRO: Grafana health database não está ok.")
    sys.exit(1)

print("OK: Grafana health validado.")
PY

echo
echo "[5/8] Validando datasources"
curl -sS -u "${GRAFANA_USER}:${GRAFANA_PASS}" "http://localhost:${LOCAL_PORT}/api/datasources" > "$TMP/grafana-datasources.json"

python3 - "$TMP/grafana-datasources.json" > "$TMP/datasources-summary.txt" <<'PY'
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text())

print("Datasources encontrados:")
for ds in data:
    print(f"- name={ds.get('name')} type={ds.get('type')} url={ds.get('url')} isDefault={ds.get('isDefault')}")

prom = [ds for ds in data if ds.get("type") == "prometheus"]
if not prom:
    print("PROMETHEUS_DATASOURCE_FOUND=false")
    raise SystemExit(1)

print("PROMETHEUS_DATASOURCE_FOUND=true")
for ds in prom:
    print(f"- Prometheus datasource: {ds.get('name')} -> {ds.get('url')}")
PY

cat "$TMP/datasources-summary.txt"

echo
echo "[6/8] Verificando dashboards disponíveis"
curl -sS -u "${GRAFANA_USER}:${GRAFANA_PASS}" "http://localhost:${LOCAL_PORT}/api/search?type=dash-db" > "$TMP/grafana-dashboards.json"

python3 - "$TMP/grafana-dashboards.json" > "$TMP/dashboard-check.txt" <<'PY'
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text())

print("Dashboards encontrados:")
for item in data[:40]:
    print(f"- title={item.get('title')} uid={item.get('uid')} folder={item.get('folderTitle')}")

custom = [item for item in data if "ToggleMaster" in (item.get("title") or "")]
if custom:
    print("CUSTOM_DASHBOARD_FOUND=true")
else:
    print("CUSTOM_DASHBOARD_FOUND=false")
PY

cat "$TMP/dashboard-check.txt"

CUSTOM_DASHBOARD_FOUND="$(grep 'CUSTOM_DASHBOARD_FOUND=' "$TMP/dashboard-check.txt" | tail -1 | cut -d= -f2 || true)"
PROMETHEUS_DATASOURCE_FOUND="$(grep 'PROMETHEUS_DATASOURCE_FOUND=' "$TMP/datasources-summary.txt" | tail -1 | cut -d= -f2 || true)"

echo
echo "[7/8] Registrando evidência sem senha"

{
  echo
  echo "## Resultado"
  echo
  echo "- Grafana Service: \`$GRAFANA_SVC\`"
  echo "- Port-forward local temporário usado no teste: \`http://localhost:${LOCAL_PORT}\`"
  echo "- Grafana API health validada."
  echo "- Datasource Prometheus encontrado: \`${PROMETHEUS_DATASOURCE_FOUND:-unknown}\`"
  echo "- Dashboard customizado ToggleMaster encontrado: \`${CUSTOM_DASHBOARD_FOUND:-unknown}\`"
  echo
  echo "### Grafana health"
  echo
  echo '```json'
  cat "$TMP/grafana-health.json"
  echo
  echo '```'
  echo
  echo "### Datasources"
  echo
  echo '```text'
  cat "$TMP/datasources-summary.txt"
  echo '```'
  echo
  echo "### Dashboards"
  echo
  echo '```text'
  cat "$TMP/dashboard-check.txt"
  echo '```'
} >> "$EVID"

echo
echo "[8/8] Resultado"
echo "CUSTOM_DASHBOARD_FOUND=${CUSTOM_DASHBOARD_FOUND:-unknown}"
echo "PROMETHEUS_DATASOURCE_FOUND=${PROMETHEUS_DATASOURCE_FOUND:-unknown}"

if [ "${PROMETHEUS_DATASOURCE_FOUND:-false}" != "true" ]; then
  echo "ERRO: datasource Prometheus não validado."
  exit 30
fi

echo
echo "============================================================"
echo "BLOCO 31 FINALIZADO"
echo "CUSTOM_DASHBOARD_FOUND=${CUSTOM_DASHBOARD_FOUND:-unknown}"
echo "Evidência: $EVID"
echo "Log: $LOG"
echo "Terminal continua vivo."
echo "============================================================"
