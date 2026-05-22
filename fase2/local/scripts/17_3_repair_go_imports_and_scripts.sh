#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
DOCKER_DIR="$BASE/docker"
COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"
ENV_FILE="$DOCKER_DIR/.env.phase2.local"

LOG="$BASE/logs/fase2-bloco17-3-repair-go-imports.log"
EVID="$BASE/docs/evidencias/fase2-bloco17-3-reparo-imports-go.md"
BACKUP_DIR="$BASE/tmp/backups-bloco17-3-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BASE/logs" "$BASE/docs/evidencias" "$BACKUP_DIR"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 17.3 - REPARO DE IMPORTS GO E SCRIPTS"
echo "============================================================"
echo "Data: $(date)"
echo

{
  echo "# Fase 2 - BLOCO 17.3 - Reparo de imports Go e scripts"
  echo
  echo "Data: $(date)"
  echo
  echo "## Objetivo"
  echo "Corrigir imports Go quebrados após o BLOCO 17.2 e ajustar scripts locais que ainda usam docker exec localstack."
  echo
} > "$EVID"

echo
echo "[1/8] Localizando serviços Go"

AUTH_DIR="$(find "$BASE/src/services" -type f -path '*/auth-service/go.mod' -printf '%h\n' | head -n1 || true)"
EVAL_DIR="$(find "$BASE/src/services" -type f -path '*/evaluation-service/go.mod' -printf '%h\n' | head -n1 || true)"

if [ -z "$AUTH_DIR" ]; then
  echo "ERRO: auth-service não encontrado."
  exit 1
fi

if [ -z "$EVAL_DIR" ]; then
  echo "ERRO: evaluation-service não encontrado."
  exit 1
fi

echo "AUTH_DIR=$AUTH_DIR"
echo "EVAL_DIR=$EVAL_DIR"

echo
echo "[2/8] Backup dos arquivos que serão alterados"

mkdir -p "$BACKUP_DIR/auth-service" "$BACKUP_DIR/evaluation-service" "$BACKUP_DIR/scripts"

for f in \
  "$AUTH_DIR/main.go" \
  "$AUTH_DIR/handlers.go" \
  "$AUTH_DIR/key.go" \
  "$AUTH_DIR/go.mod" \
  "$AUTH_DIR/go.sum" \
  "$EVAL_DIR/evaluator.go" \
  "$EVAL_DIR/go.mod" \
  "$EVAL_DIR/go.sum"
do
  if [ -f "$f" ]; then
    svc="$(basename "$(dirname "$f")")"
    cp -a "$f" "$BACKUP_DIR/$svc/$(basename "$f").bak"
  fi
done

for f in \
  "$BASE/local/scripts/16_stabilize_phase2_runtime.sh" \
  "$BASE/local/scripts/17_validate_phase2_e2e_flow.sh" \
  "$BASE/local/scripts/17_2_repair_go_modules_and_runtime_scripts.sh"
do
  if [ -f "$f" ]; then
    cp -a "$f" "$BACKUP_DIR/scripts/$(basename "$f").bak"
  fi
done

echo "Backup em: $BACKUP_DIR"

echo
echo "[3/8] Corrigindo imports do auth-service"

python3 - "$AUTH_DIR" <<'PY'
from pathlib import Path
import sys

auth = Path(sys.argv[1])

def remove_import_lines(path: Path, needles):
    if not path.exists():
        return
    lines = path.read_text().splitlines()
    out = []
    for line in lines:
        if any(n in line for n in needles):
            continue
        out.append(line)
    path.write_text("\n".join(out) + "\n")

def ensure_import_block_line(path: Path, line_to_add: str):
    s = path.read_text()
    if line_to_add.strip() in s:
        return

    lines = s.splitlines()
    out = []
    inserted = False

    for i, line in enumerate(lines):
        out.append(line)
        if line.strip() == "import (":
            out.append(line_to_add)
            inserted = True

    if not inserted:
        # fallback simples: cria bloco import depois da linha package
        out = []
        for line in lines:
            out.append(line)
            if line.startswith("package "):
                out.append("")
                out.append("import (")
                out.append(line_to_add)
                out.append(")")
                inserted = True

    path.write_text("\n".join(out) + "\n")

# Remove duplicidades/imports inválidos ou não usados apontados pelo build.
remove_import_lines(auth / "main.go", [
    'github.com/jackc/pgx/v4/stdlib',
    '"fmt"',
])
ensure_import_block_line(auth / "main.go", '\t_ "github.com/jackc/pgx/v4/stdlib"')

remove_import_lines(auth / "handlers.go", [
    '"crypto/sha256"',
    '"encoding/hex"',
])

remove_import_lines(auth / "key.go", [
    '"fmt"',
])
PY

echo
echo "Imports pgx stdlib no auth-service após correção:"
grep -R --line-number 'github.com/jackc/pgx/v4/stdlib' "$AUTH_DIR"/*.go || true

echo
echo "[4/8] Corrigindo imports do evaluation-service"

python3 - "$EVAL_DIR" <<'PY'
from pathlib import Path
import sys

eval_dir = Path(sys.argv[1])
p = eval_dir / "evaluator.go"

s = p.read_text()
lines = s.splitlines()

# Remove context se estiver importado e não usado.
lines = [line for line in lines if '"context"' not in line]

s = "\n".join(lines) + "\n"

if '"os"' not in s:
    lines = s.splitlines()
    out = []
    inserted = False

    for line in lines:
        out.append(line)
        if line.strip() == "import (":
            out.append('\t"os"')
            inserted = True

    if not inserted:
        out = []
        for line in lines:
            out.append(line)
            if line.startswith("package "):
                out.append("")
                out.append("import (")
                out.append('\t"os"')
                out.append(")")
                inserted = True

    s = "\n".join(out) + "\n"

p.write_text(s)
PY

echo
echo "Imports relevantes no evaluation-service:"
grep -nE '"os"|"context"' "$EVAL_DIR/evaluator.go" || true

echo
echo "[5/8] gofmt nos serviços Go"

gofmt -w "$AUTH_DIR"/*.go "$EVAL_DIR"/*.go

echo
echo "[6/8] go mod tidy e go test"

for dir in "$AUTH_DIR" "$EVAL_DIR"
do
  echo
  echo "### Validando $dir ###"
  (
    cd "$dir"
    go mod tidy
    go test ./...
  )
done

echo
echo "[7/8] Corrigindo scripts para LocalStack via docker compose exec"

python3 - "$BASE" <<'PY'
from pathlib import Path
import sys

base = Path(sys.argv[1])

replacement = 'docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" exec -T localstack awslocal'

for script_name in [
    "16_stabilize_phase2_runtime.sh",
    "17_validate_phase2_e2e_flow.sh",
]:
    p = base / "local/scripts" / script_name
    if not p.exists():
        continue

    s = p.read_text()

    s = s.replace("docker exec localstack awslocal", replacement)
    s = s.replace("docker exec -i localstack awslocal", replacement)
    s = s.replace("docker exec -t localstack awslocal", replacement)
    s = s.replace("docker exec -it localstack awslocal", replacement)

    # Garante que scripts que usam ENV_FILE/COMPOSE_FILE tenham as variáveis.
    if 'ENV_FILE=' not in s:
        marker = 'COMPOSE_FILE="$DOCKER_DIR/docker-compose.phase2-exec.yaml"\n'
        if marker in s:
            s = s.replace(marker, marker + 'ENV_FILE="$DOCKER_DIR/.env.phase2.local"\n')

    p.write_text(s)
PY

chmod +x "$BASE/local/scripts/16_stabilize_phase2_runtime.sh" || true
chmod +x "$BASE/local/scripts/17_validate_phase2_e2e_flow.sh" || true

echo
echo "Ocorrências restantes de docker exec localstack:"
grep -R --line-number 'docker exec .*localstack' "$BASE/local/scripts" || true

echo
echo "[8/8] Build sem cache dos serviços Go"

cd "$DOCKER_DIR"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" build --no-cache auth-service evaluation-service

echo
echo "============================================================"
echo "BLOCO 17.3 FINALIZADO COM SUCESSO"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "Backup: $BACKUP_DIR"
echo "============================================================"

{
  echo
  echo "## Resultado"
  echo
  echo "- Imports duplicados do \`auth-service\` corrigidos."
  echo "- Imports não usados do \`auth-service\` removidos."
  echo "- \`evaluation-service/evaluator.go\` corrigido com import de \`os\` e remoção de \`context\`."
  echo "- \`gofmt\`, \`go mod tidy\`, \`go test ./...\` e build Docker sem cache executados."
  echo "- Scripts do LocalStack corrigidos para usar \`docker compose exec -T localstack\`."
  echo
  echo "## Arquivos"
  echo "- Log: \`$LOG\`"
  echo "- Backup: \`$BACKUP_DIR\`"
} >> "$EVID"
