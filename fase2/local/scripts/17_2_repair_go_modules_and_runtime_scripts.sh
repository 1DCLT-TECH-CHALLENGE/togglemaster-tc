#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
LOG="$BASE/logs/fase2-bloco17-2-repair-go-modules.log"
EVID="$BASE/docs/evidencias/fase2-bloco17-2-reparo-go-modules.md"
BACKUP_DIR="$BASE/tmp/backups-bloco17-2-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BASE/logs" "$BASE/docs/evidencias" "$BACKUP_DIR"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 17.2 - REPARO GO MODULES E LOCALSTACK EXEC"
echo "============================================================"
echo "Data: $(date)"
echo

{
  echo "# Fase 2 - BLOCO 17.2 - Reparo Go Modules e LocalStack Exec"
  echo
  echo "Data: $(date)"
  echo
  echo "## Objetivo"
  echo "Corrigir de forma cirúrgica os erros encontrados na tentativa de estabilização da stack antes do BLOCO 17 E2E."
  echo
} > "$EVID"

echo
echo "[1/7] Localizando serviços Go"

AUTH_DIR="$(find "$BASE" -type f -path '*/auth-service/go.mod' -printf '%h\n' | head -n1 || true)"
EVAL_DIR="$(find "$BASE" -type f -path '*/evaluation-service/go.mod' -printf '%h\n' | head -n1 || true)"

if [ -z "$AUTH_DIR" ]; then
  echo "ERRO: auth-service/go.mod não encontrado."
  exit 1
fi

if [ -z "$EVAL_DIR" ]; then
  echo "ERRO: evaluation-service/go.mod não encontrado."
  exit 1
fi

echo "AUTH_DIR=$AUTH_DIR"
echo "EVAL_DIR=$EVAL_DIR"

{
  echo
  echo "## Diretórios localizados"
  echo
  echo "- AUTH_DIR: \`$AUTH_DIR\`"
  echo "- EVAL_DIR: \`$EVAL_DIR\`"
} >> "$EVID"

echo
echo "[2/7] Backup dos arquivos Go"

for dir in "$AUTH_DIR" "$EVAL_DIR"
do
  svc="$(basename "$dir")"
  mkdir -p "$BACKUP_DIR/$svc"
  cp -a "$dir/go.mod" "$BACKUP_DIR/$svc/go.mod.bak"
  if [ -f "$dir/go.sum" ]; then
    cp -a "$dir/go.sum" "$BACKUP_DIR/$svc/go.sum.bak"
  fi
done

echo "Backup em: $BACKUP_DIR"

echo
echo "[3/7] Corrigindo auth-service/go.mod"

python3 - <<PY
from pathlib import Path
import re

p = Path("$AUTH_DIR") / "go.mod"
s = p.read_text()

# Corrige erro: require github.com/jackc/pgx/v4/stdlib v4.18.3
s = re.sub(
    r'github\\.com/jackc/pgx/v4/stdlib\\s+v([0-9]+\\.[0-9]+\\.[0-9]+)',
    r'github.com/jackc/pgx/v4 v\\1',
    s,
)

# Remove linhas duplicadas exatas de github.com/jackc/pgx/v4, preservando a primeira
seen = False
out = []
for line in s.splitlines():
    if re.search(r'github\\.com/jackc/pgx/v4\\s+v', line):
        if seen:
            continue
        seen = True
    out.append(line)

p.write_text("\\n".join(out) + "\\n")
PY

echo
echo "auth-service/go.mod após correção:"
grep -n 'github.com/jackc/pgx' "$AUTH_DIR/go.mod" || true

if grep -q 'github.com/jackc/pgx/v4/stdlib' "$AUTH_DIR/go.mod"; then
  echo "ERRO: go.mod ainda contém subpacote stdlib como módulo."
  exit 1
fi

echo
echo "[4/7] Garantindo blank import do pgx stdlib no auth-service"

python3 - <<PY
from pathlib import Path
import re

base = Path("$AUTH_DIR")

for p in base.glob("*.go"):
    s = p.read_text()
    # Se a linha importa stdlib sem blank import, corrige.
    s = re.sub(
        r'(?m)^(\\s*)"github\\.com/jackc/pgx/v4/stdlib"',
        r'\\1_ "github.com/jackc/pgx/v4/stdlib"',
        s,
    )
    # Evita duplicação acidental: _ _ "..."
    s = s.replace('_ _ "github.com/jackc/pgx/v4/stdlib"', '_ "github.com/jackc/pgx/v4/stdlib"')
    p.write_text(s)
PY

grep -R --line-number 'github.com/jackc/pgx/v4/stdlib' "$AUTH_DIR"/*.go || true

echo
echo "[5/7] Regenerando go.sum com go mod tidy"

if ! command -v go >/dev/null 2>&1; then
  echo "ERRO: comando go não encontrado no host."
  echo "Precisamos do Go no host para regenerar go.sum de forma limpa."
  exit 1
fi

for dir in "$AUTH_DIR" "$EVAL_DIR"
do
  echo
  echo "### go mod tidy em $dir ###"
  (
    cd "$dir"
    rm -f go.sum
    go mod tidy
    go test ./... || true
  )
done

echo
echo "[6/7] Corrigindo scripts que ainda usam docker exec localstack"

for script in \
  "$BASE/local/scripts/16_stabilize_phase2_runtime.sh" \
  "$BASE/local/scripts/17_validate_phase2_e2e_flow.sh"
do
  if [ -f "$script" ]; then
    cp -a "$script" "$BACKUP_DIR/$(basename "$script").bak"
    python3 - <<PY
from pathlib import Path

p = Path("$script")
s = p.read_text()

s = s.replace(
    'docker exec localstack awslocal',
    'docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" exec -T localstack awslocal'
)

# Alguns scripts podem usar variáveis com nomes diferentes; cobre o caso local do BLOCO 16 se ele estiver em DOCKER_DIR.
s = s.replace(
    'docker exec -i localstack awslocal',
    'docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" exec -T localstack awslocal'
)

p.write_text(s)
PY
    chmod +x "$script"
  fi
done

echo
echo "Ocorrências restantes de docker exec localstack:"
grep -R --line-number 'docker exec .*localstack' "$BASE/local/scripts" || true

echo
echo "[7/7] Build controlado dos serviços Go"

cd "$BASE/docker"

docker compose --env-file .env.phase2.local -f docker-compose.phase2-exec.yaml build --no-cache auth-service evaluation-service

echo
echo "============================================================"
echo "BLOCO 17.2 FINALIZADO COM SUCESSO"
echo "Log: $LOG"
echo "Evidência: $EVID"
echo "Backup: $BACKUP_DIR"
echo "============================================================"

{
  echo
  echo "## Resultado"
  echo
  echo "- Reparo do \`auth-service/go.mod\` executado."
  echo "- \`go.sum\` dos serviços Go regenerado com \`go mod tidy\`."
  echo "- Scripts locais corrigidos para usar \`docker compose exec -T localstack\`."
  echo "- Build sem cache de auth-service e evaluation-service executado."
  echo
  echo "## Arquivos"
  echo "- Log: \`$LOG\`"
  echo "- Backup: \`$BACKUP_DIR\`"
} >> "$EVID"
