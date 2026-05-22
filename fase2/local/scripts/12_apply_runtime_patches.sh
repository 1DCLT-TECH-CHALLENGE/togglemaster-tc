#!/usr/bin/env bash
set -Eeuo pipefail

BASE="$HOME/togglemaster-tc/fase2"
SRC="$BASE/src/services"
LOG="$BASE/logs/fase2-bloco12-runtime-patches.log"
EVID="$BASE/docs/evidencias/fase2-bloco12-runtime-patches.md"
BACKUP_DIR="$BASE/tmp/backups-bloco12-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BASE/logs" "$BASE/docs/evidencias" "$BACKUP_DIR"

exec > >(tee "$LOG") 2>&1

echo "============================================================"
echo "FASE 2 - BLOCO 12 - PATCHES OPERACIONAIS CONSOLIDADOS"
echo "============================================================"
echo "Data: $(date)"
echo

{
  echo "# Fase 2 - BLOCO 12 - Patches operacionais consolidados"
  echo
  echo "Data: $(date)"
  echo
  echo "## Objetivo"
  echo "Aplicar de forma idempotente os patches necessários para a Fase 2 local funcionar com Docker Compose, LocalStack, SQS, DynamoDB, Redis e PostgreSQL."
  echo
} > "$EVID"

###############################################################################
# HELPERS
###############################################################################

backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    local rel="${file#$BASE/}"
    local dest="$BACKUP_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    cp -a "$file" "$dest"
  fi
}

###############################################################################
# AUTH-SERVICE
###############################################################################

echo
echo "[AUTH] Corrigindo pgx/go.mod/imports"

AUTH_DIR="$SRC/auth-service"
AUTH_MAIN="$AUTH_DIR/main.go"
AUTH_GO_MOD="$AUTH_DIR/go.mod"

backup_file "$AUTH_MAIN"
backup_file "$AUTH_GO_MOD"
backup_file "$AUTH_DIR/go.sum"
backup_file "$AUTH_DIR/handlers.go"
backup_file "$AUTH_DIR/key.go"

python3 - "$AUTH_DIR" <<'PY'
from pathlib import Path
import re
import sys

auth = Path(sys.argv[1])

# Corrige go.mod caso o subpacote stdlib tenha sido adicionado como módulo.
go_mod = auth / "go.mod"
if go_mod.exists():
    s = go_mod.read_text()
    s = re.sub(
        r'github\.com/jackc/pgx/v4/stdlib\s+v([0-9]+\.[0-9]+\.[0-9]+)',
        r'github.com/jackc/pgx/v4 v\1',
        s,
    )

    seen = False
    out = []
    for line in s.splitlines():
        if re.search(r'github\.com/jackc/pgx/v4\s+v', line):
            if seen:
                continue
            seen = True
        out.append(line)

    go_mod.write_text("\n".join(out) + "\n")

# Remove imports duplicados/não usados já observados no BLOCO 17.
for filename, needles in {
    "main.go": [
        'github.com/jackc/pgx/v4/stdlib',
        '"fmt"',
    ],
    "handlers.go": [
        '"crypto/sha256"',
        '"encoding/hex"',
    ],
    "key.go": [
        '"fmt"',
    ],
}.items():
    p = auth / filename
    if not p.exists():
        continue

    lines = p.read_text().splitlines()
    out = []
    for line in lines:
        if any(n in line for n in needles):
            continue
        out.append(line)
    p.write_text("\n".join(out) + "\n")

# Garante blank import do driver pgx stdlib no main.go.
main = auth / "main.go"
s = main.read_text()

if '_ "github.com/jackc/pgx/v4/stdlib"' not in s:
    lines = s.splitlines()
    out = []
    inserted = False

    for line in lines:
        out.append(line)
        if line.strip() == "import (":
            out.append('\t_ "github.com/jackc/pgx/v4/stdlib"')
            inserted = True

    if not inserted:
        out = []
        for line in lines:
            out.append(line)
            if line.startswith("package "):
                out.append("")
                out.append("import (")
                out.append('\t_ "github.com/jackc/pgx/v4/stdlib"')
                out.append(")")
                inserted = True

    main.write_text("\n".join(out) + "\n")
PY

gofmt -w "$AUTH_DIR"/*.go

grep -R --line-number 'github.com/jackc/pgx/v4/stdlib' "$AUTH_DIR"/*.go || true

###############################################################################
# PYTHON SERVICES REQUIREMENTS
###############################################################################

echo
echo "[PYTHON] Normalizando requirements"

for svc in flag-service targeting-service analytics-service
do
  echo
  echo "### $svc ###"

  REQ="$SRC/$svc/requirements.txt"

  if [ ! -f "$REQ" ]; then
    echo "ERRO: requirements não encontrado: $REQ"
    exit 1
  fi

  backup_file "$REQ"

  python3 - "$REQ" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

s = s.replace("requests==2.28.1Werkzeug==2.3.8", "requests==2.28.1\nWerkzeug==2.3.8")

lines = [line.strip() for line in s.splitlines() if line.strip()]

if "Werkzeug==2.3.8" not in lines:
    lines.append("Werkzeug==2.3.8")

out = []
seen = set()
for line in lines:
    if line not in seen:
        out.append(line)
        seen.add(line)

p.write_text("\n".join(out) + "\n")
PY

  grep -n '^Werkzeug==2.3.8$' "$REQ"
done

###############################################################################
# EVALUATION-SERVICE
###############################################################################

echo
echo "[EVALUATION] Aplicando suporte LocalStack/AWS_ENDPOINT_URL"

EVAL_DIR="$SRC/evaluation-service"
EVAL_MAIN="$EVAL_DIR/main.go"

backup_file "$EVAL_MAIN"
backup_file "$EVAL_DIR/go.mod"
backup_file "$EVAL_DIR/go.sum"

python3 - "$EVAL_MAIN" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

if '"github.com/aws/aws-sdk-go/aws/credentials"' not in s:
    s = s.replace(
        '"github.com/aws/aws-sdk-go/aws"\n',
        '"github.com/aws/aws-sdk-go/aws"\n\t"github.com/aws/aws-sdk-go/aws/credentials"\n'
    )

old = '''\t// Cliente SQS (AWS SDK)
\tvar sqsSvc *sqs.SQS
\tif sqsQueueURL != "" {
\t\tsess, err := session.NewSession(&aws.Config{Region: aws.String(awsRegion)})
\t\tif err != nil {
\t\t\tlog.Fatalf("Não foi possível criar sessão AWS: %v", err)
\t\t}
\t\tsqsSvc = sqs.New(sess)
\t\tlog.Println("Cliente SQS inicializado com sucesso.")
\t}
'''

new = '''\t// Cliente SQS (AWS SDK)
\tvar sqsSvc *sqs.SQS
\tif sqsQueueURL != "" {
\t\tawsEndpointURL := os.Getenv("AWS_ENDPOINT_URL")

\t\tawsConfig := &aws.Config{
\t\t\tRegion: aws.String(awsRegion),
\t\t}

\t\tif awsEndpointURL != "" {
\t\t\tlog.Printf("Usando endpoint AWS customizado: %s", awsEndpointURL)
\t\t\tawsConfig.Endpoint = aws.String(awsEndpointURL)
\t\t\tawsConfig.Credentials = credentials.NewStaticCredentials(
\t\t\t\tos.Getenv("AWS_ACCESS_KEY_ID"),
\t\t\t\tos.Getenv("AWS_SECRET_ACCESS_KEY"),
\t\t\t\t"",
\t\t\t)
\t\t\tawsConfig.DisableSSL = aws.Bool(true)
\t\t\tawsConfig.S3ForcePathStyle = aws.Bool(true)
\t\t}

\t\tsess, err := session.NewSession(awsConfig)
\t\tif err != nil {
\t\t\tlog.Fatalf("Não foi possível criar sessão AWS: %v", err)
\t\t}
\t\tsqsSvc = sqs.New(sess)
\t\tlog.Println("Cliente SQS inicializado com sucesso.")
\t}
'''

if "awsEndpointURL := os.Getenv(\"AWS_ENDPOINT_URL\")" not in s:
    if old not in s:
        raise SystemExit("Bloco SQS padrão não encontrado em evaluation-service/main.go.")
    s = s.replace(old, new)

p.write_text(s)
PY

gofmt -w "$EVAL_MAIN"

grep -n 'AWS_ENDPOINT_URL\|credentials.NewStaticCredentials\|Usando endpoint AWS customizado' "$EVAL_MAIN"

###############################################################################
# ANALYTICS-SERVICE
###############################################################################

echo
echo "[ANALYTICS] Aplicando suporte LocalStack/AWS_ENDPOINT_URL no Boto3"

AN_APP="$SRC/analytics-service/app.py"

backup_file "$AN_APP"

python3 - "$AN_APP" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

if 'AWS_ENDPOINT_URL = os.getenv("AWS_ENDPOINT_URL")' not in s:
    s = s.replace(
        'DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")\n',
        'DYNAMODB_TABLE_NAME = os.getenv("AWS_DYNAMODB_TABLE")\n'
        'AWS_ENDPOINT_URL = os.getenv("AWS_ENDPOINT_URL")\n'
    )

old = '''# --- Clientes Boto3 ---
# Criamos a sessão uma vez
try:
    session = boto3.Session(region_name=AWS_REGION)
    sqs_client = session.client("sqs")
    dynamodb_client = session.client("dynamodb")
    log.info(f"Clientes Boto3 inicializados na região {AWS_REGION}")
except NoCredentialsError:
    log.critical("Credenciais da AWS não encontradas. Verifique seu ambiente.")
    sys.exit(1)
except Exception as e:
    log.critical(f"Erro ao inicializar o Boto3: {e}")
    sys.exit(1)
'''

new = '''# --- Clientes Boto3 ---
# Criamos a sessão uma vez
try:
    session = boto3.Session(region_name=AWS_REGION)

    boto3_client_kwargs = {}
    if AWS_ENDPOINT_URL:
        boto3_client_kwargs["endpoint_url"] = AWS_ENDPOINT_URL
        log.info(f"Usando endpoint AWS customizado: {AWS_ENDPOINT_URL}")

    sqs_client = session.client("sqs", **boto3_client_kwargs)
    dynamodb_client = session.client("dynamodb", **boto3_client_kwargs)
    log.info(f"Clientes Boto3 inicializados na região {AWS_REGION}")
except NoCredentialsError:
    log.critical("Credenciais da AWS não encontradas. Verifique seu ambiente.")
    sys.exit(1)
except Exception as e:
    log.critical(f"Erro ao inicializar o Boto3: {e}")
    sys.exit(1)
'''

if 'boto3_client_kwargs["endpoint_url"] = AWS_ENDPOINT_URL' not in s:
    if old not in s:
        raise SystemExit("Bloco Boto3 padrão não encontrado em analytics-service/app.py.")
    s = s.replace(old, new)

p.write_text(s)
PY

python3 -m py_compile "$AN_APP"

grep -n 'AWS_ENDPOINT_URL\|endpoint_url\|Usando endpoint AWS customizado' "$AN_APP"

###############################################################################
# SQL FILES
###############################################################################

echo
echo "[SQL] Verificando init.sql"

find "$SRC" -path '*/db/init.sql' | sort | while read -r sql
do
  echo
  echo "Arquivo: $sql"
  tail -5 "$sql"
done

###############################################################################
# GO BUILD CHECK
###############################################################################

echo
echo "[GO] Validação de build"

BUILD_DIR="$BASE/tmp/build-checks-bloco12-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BUILD_DIR"

for svc in auth-service evaluation-service
do
  echo
  echo "### $svc ###"

  (
    cd "$SRC/$svc"
    go mod tidy
    go test ./...
    go build -o "$BUILD_DIR/$svc" .
  )
done

echo
echo "Binários de validação gerados fora do source tree em: $BUILD_DIR"

###############################################################################
# EVIDÊNCIA
###############################################################################

{
  echo
  echo "## Resultado"
  echo
  echo "- Patches de auth-service aplicados/idempotentes."
  echo "- Requirements Python normalizados."
  echo "- evaluation-service com suporte a AWS_ENDPOINT_URL/LocalStack."
  echo "- analytics-service com suporte a AWS_ENDPOINT_URL/LocalStack."
  echo "- init.sql verificados."
  echo "- go test/go build passaram para auth-service e evaluation-service, com binários gerados fora do source tree."
  echo
  echo "## Arquivos"
  echo
  echo "- Log: \`$LOG\`"
  echo "- Backup: \`$BACKUP_DIR\`"
} >> "$EVID"

echo
echo "============================================================"
echo "PATCHES OPERACIONAIS FINALIZADOS"
echo "LOG: $LOG"
echo "EVIDÊNCIA: $EVID"
echo "BACKUP: $BACKUP_DIR"
echo "============================================================"
