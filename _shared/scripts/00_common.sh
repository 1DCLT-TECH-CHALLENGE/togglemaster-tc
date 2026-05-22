#!/usr/bin/env bash

# Framework compartilhado dos bootstraps ToggleMaster TC.
# Objetivo: padronizar logging, validações, criação segura de arquivos,
# evidências, idempotência e tratamento de erros.

set -Eeuo pipefail
IFS=$'\n\t'

export TC_ROOT="${TC_ROOT:-$HOME/togglemaster-tc}"
export TC_SHARED_DIR="$TC_ROOT/_shared"
export TC_LOG_DIR="$TC_SHARED_DIR/logs"
export TC_EVIDENCE_DIR="$TC_SHARED_DIR/evidencias"
export TC_TMP_DIR="$TC_SHARED_DIR/tmp"

mkdir -p "$TC_LOG_DIR" "$TC_EVIDENCE_DIR" "$TC_TMP_DIR"

export TC_RUN_ID="${TC_RUN_ID:-$(date +%Y%m%d-%H%M%S)}"
export TC_LOG_FILE="${TC_LOG_FILE:-$TC_LOG_DIR/bootstrap-$TC_RUN_ID.log}"
export TC_ISSUES_FILE="${TC_ISSUES_FILE:-$TC_EVIDENCE_DIR/bootstrap-issues.md}"

setup_logging() {
  mkdir -p "$(dirname "$TC_LOG_FILE")"
  touch "$TC_LOG_FILE"
  exec > >(tee -a "$TC_LOG_FILE") 2>&1
}

ts() {
  date '+%Y-%m-%d %H:%M:%S'
}

log() {
  printf '[%s] [INFO] %s\n' "$(ts)" "$*"
}

warn() {
  printf '[%s] [WARN] %s\n' "$(ts)" "$*" >&2
}

error() {
  printf '[%s] [ERROR] %s\n' "$(ts)" "$*" >&2
}

section() {
  printf '\n============================================================\n'
  printf '%s\n' "$*"
  printf '============================================================\n'
}

fail() {
  error "$*"
  exit 1
}
on_error() {
  local exit_code=$?
  local line_no=${1:-unknown}
  error "Falha na linha ${line_no}. Exit code: ${exit_code}."
  error "Log: ${TC_LOG_FILE}"
  exit "$exit_code"
}

trap 'on_error $LINENO' ERR

require_project_root() {
  [[ -d "$TC_ROOT" ]] || fail "TC_ROOT não existe: $TC_ROOT"
  [[ -d "$TC_ROOT/_shared" ]] || fail "Diretório _shared ausente em $TC_ROOT"
}

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "Comando obrigatório não encontrado: $cmd"
  log "Comando encontrado: $cmd -> $(command -v "$cmd")"
}

optional_command() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    log "Comando opcional encontrado: $cmd -> $(command -v "$cmd")"
    return 0
  fi
  warn "Comando opcional ausente: $cmd"
  return 1
}

ensure_dir() {
  local dir="$1"
  mkdir -p "$dir"
  log "Diretório garantido: $dir"
}

create_file_if_missing() {
  local file="$1"
  local content="$2"
  if [[ -f "$file" ]]; then
    log "Arquivo já existe, preservado: $file"
    return 0
  fi
  mkdir -p "$(dirname "$file")"
  printf '%s\n' "$content" > "$file"
  log "Arquivo criado: $file"
}

write_file_managed() {
  local file="$1"
  local content="$2"
  mkdir -p "$(dirname "$file")"
  printf '%s\n' "$content" > "$file"
  log "Arquivo gerenciado escrito/atualizado: $file"
}

append_once() {
  local file="$1"
  local line="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if grep -Fxq "$line" "$file"; then
    log "Linha já presente em $file: $line"
  else
    printf '%s\n' "$line" >> "$file"
    log "Linha adicionada em $file: $line"
  fi
}

ensure_newline_eof() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  [[ -s "$file" ]] || return 0
  tail -c1 "$file" | read -r _ || printf '\n' >> "$file"
}

record_issue() {
  local message="$1"
  mkdir -p "$(dirname "$TC_ISSUES_FILE")"
  {
    printf '\n## Issue registrada em %s\n\n' "$(ts)"
    printf '%s\n' "$message"
  } >> "$TC_ISSUES_FILE"
  warn "Issue registrada em $TC_ISSUES_FILE: $message"
}

record_evidence() {
  local file="$1"
  local title="$2"
  local body="$3"
  mkdir -p "$(dirname "$file")"
  {
    printf '\n# %s\n\n' "$title"
    printf 'Data/hora: %s\n\n' "$(ts)"
    printf '%s\n' "$body"
  } >> "$file"
  log "Evidência registrada: $file"
}

run_cmd() {
  log "Executando: $*"
  "$@"
}

run_cmd_allow_fail() {
  log "Executando com falha permitida: $*"
  if "$@"; then
    log "Comando concluiu com sucesso: $*"
    return 0
  else
    local rc=$?
    warn "Comando falhou com rc=$rc, mas falha foi permitida: $*"
    return "$rc"
  fi
}

check_no_aws_credentials_required_now() {
  if [[ -n "${AWS_ACCESS_KEY_ID:-}" || -n "${AWS_SECRET_ACCESS_KEY:-}" || -n "${AWS_SESSION_TOKEN:-}" ]]; then
    warn "Variáveis AWS detectadas no ambiente. Não serão usadas antes da Fase 3."
  else
    log "Nenhuma credencial AWS detectada no ambiente."
  fi
}

assert_not_sensitive_file() {
  local target="${1:-}"

  if [[ -z "$target" ]]; then
    error "assert_not_sensitive_file requer caminho do arquivo"
    return 1
  fi

  if [[ ! -f "$target" ]]; then
    return 0
  fi

  if grep -Eqi \
    '(AWS_SECRET_ACCESS_KEY|aws_secret_access_key|BEGIN RSA PRIVATE KEY|BEGIN OPENSSH PRIVATE KEY|password *=|token *=)' \
    "$target"; then

    error "Possível conteúdo sensível detectado em: $target"
    return 1
  fi

  return 0
}

validate_base_tools() {
  section "Validação de ferramentas base"
  require_command bash
  require_command git
  require_command curl
  require_command docker
  require_command terraform
  require_command kubectl
  require_command helm
  require_command aws
  require_command go
  require_command python3
  optional_command tree || true
  check_no_aws_credentials_required_now
}

log "Framework comum carregado. TC_ROOT=$TC_ROOT"
