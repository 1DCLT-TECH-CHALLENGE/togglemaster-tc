#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
DOCKER_DIR="$BASE/docker"
COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"
ENV_FILE="$DOCKER_DIR/.env.phase2.local"

LOG="$BASE/logs/fase2-bloco17-4-fix-localstack-exec.log"
EVID="$BASE/docs/evidencias/fase2-bloco17-4-correcao-localstack-exec.md"
BACKUP_DIR="$BASE/tmp/backups-bloco17-4-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BASE/logs" "$BASE/docs/evidencias" "$BACKUP_DIR"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 17.4 - CORREÇÃO LOCALSTACK EXEC + RERUN BLOCO 16"
echo "============================================================"
echo "Data: $(date)"
echo

{
  echo "# Fase 2 - BLOCO 17.4 - Correção LocalStack Exec"
  echo
  echo "Data: $(date)"
  echo
  echo "## Objetivo"
  echo "Corrigir chamadas antigas docker exec localstack no BLOCO 16 e reexecutar a estabilização do runtime."
  echo
} > "$EVID"

echo
echo "[1/6] Backup dos scripts impactados"

for script in \
  "$BASE/local/scripts/16_stabilize_phase2_runtime.sh" \
  "$BASE/local/scripts/17_validate_phase2_e2e_flow.sh"
do
  if [ -f "$script" ]; then
    cp -a "$script" "$BACKUP_DIR/$(basename "$script").bak"
    echo "Backup: $script"
  fi
done

echo
echo "Backup em: $BACKUP_DIR"

echo
echo "[2/6] Aplicando correção docker exec localstack -> docker compose exec"

python3 - "$BASE" <<'PY'
from pathlib import Path
import sys

base = Path(sys.argv[1])

compose_prefix = 'docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" exec -T localstack'

def ensure_line_after_marker(text: str, marker: str, line: str) -> str:
    if line in text:
        return text
    if marker in text:
        return text.replace(marker, marker + line + "\n", 1)
    return line + "\n" + text

for script_name in [
    "16_stabilize_phase2_runtime.sh",
    "17_validate_phase2_e2e_flow.sh",
]:
    p = base / "local/scripts" / script_name
    if not p.exists():
        continue

    s = p.read_text()

    # Garante variáveis necessárias nos scripts.
    if 'BASE="$HOME/togglemaster-tc/fase2"' not in s and "BASE=" not in s:
        s = 'BASE="$HOME/togglemaster-tc/fase2"\n' + s

    if 'DOCKER_DIR=' not in s:
        s = ensure_line_after_marker(
            s,
            'BASE="$HOME/togglemaster-tc/fase2"\n',
            'DOCKER_DIR="$BASE/docker"'
        )

    if 'COMPOSE_FILE=' not in s:
        s = ensure_line_after_marker(
            s,
            'DOCKER_DIR="$BASE/docker"\n',
            'COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"'
        )

    if 'ENV_FILE=' not in s:
        s = ensure_line_after_marker(
            s,
            'COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"\n',
            'ENV_FILE="$DOCKER_DIR/.env.phase2.local"'
        )

    # Corrige chamadas antigas, inclusive as quebradas em múltiplas linhas.
    s = s.replace('docker exec -it localstack', compose_prefix)
    s = s.replace('docker exec -i localstack', compose_prefix)
    s = s.replace('docker exec -t localstack', compose_prefix)
    s = s.replace('docker exec localstack', compose_prefix)

    p.write_text(s)
PY

chmod +x "$BASE/local/scripts/16_stabilize_phase2_runtime.sh"
chmod +x "$BASE/local/scripts/17_validate_phase2_e2e_flow.sh"

echo
echo "[3/6] Validando sintaxe dos scripts"

bash -n "$BASE/local/scripts/16_stabilize_phase2_runtime.sh"
bash -n "$BASE/local/scripts/17_validate_phase2_e2e_flow.sh"

echo "OK: bash -n passou."

echo
echo "[4/6] Verificando ocorrências restantes nos scripts ativos"

grep -n 'docker exec .*localstack' \
  "$BASE/local/scripts/16_stabilize_phase2_runtime.sh" \
  "$BASE/local/scripts/17_validate_phase2_e2e_flow.sh" || true

echo
echo "[5/6] Reexecutando BLOCO 16 - estabilização do runtime"

cd "$BASE"
./local/scripts/16_stabilize_phase2_runtime.sh

echo
echo "[6/6] Status final da stack"

cd "$DOCKER_DIR"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps

echo
echo "============================================================"
echo "BLOCO 17.4 FINALIZADO"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "Backup: $BACKUP_DIR"
echo "============================================================"

{
  echo
  echo "## Resultado"
  echo
  echo "- Scripts ativos corrigidos para usar \`docker compose exec -T localstack\`."
  echo "- Sintaxe validada com \`bash -n\`."
  echo "- BLOCO 16 reexecutado."
  echo "- Status final da stack registrado."
  echo
  echo "## Arquivos"
  echo "- Log: \`$LOG\`"
  echo "- Backup: \`$BACKUP_DIR\`"
} >> "$EVID"
