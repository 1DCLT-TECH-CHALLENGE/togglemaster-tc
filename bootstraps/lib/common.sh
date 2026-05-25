#!/usr/bin/env bash
set -Eeuo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="${ROOT:-$(cd "$BOOTSTRAP_DIR/.." && pwd)}"

section() {
  echo
  echo "============================================================"
  echo "$1"
  echo "============================================================"
}

info() {
  echo "[INFO] $*"
}

warn() {
  echo "[WARN] $*"
}

fail() {
  echo "[ERRO] $*" >&2
  exit 1
}

require_file() {
  [ -f "$1" ] || fail "Arquivo obrigatório não encontrado: $1"
}

require_dir() {
  [ -d "$1" ] || fail "Diretório obrigatório não encontrado: $1"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Comando obrigatório não encontrado: $1"
}

run_script() {
  local script="$1"
  require_file "$script"
  chmod +x "$script"
  section "Executando: $script"
  "$script"
}
