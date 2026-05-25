#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
cd "$ROOT"

section "ToggleMaster TC - Bootstrap Fase 2"
echo "Escopo:"
echo "- Cinco microsserviços locais."
echo "- PostgreSQL, Redis, LocalStack, SQS local, DynamoDB local e analytics."
echo "- Não usa AWS real."
echo "- Recria e valida a Fase 2 local usando Docker Compose."

if [ "${BOOTSTRAP_SKIP_PREPARE_VM:-false}" != "true" ]; then
  run_script "$ROOT/bootstraps/00_prepare_vm.sh"
fi

require_cmd docker
docker compose version >/dev/null

require_dir "$ROOT/fase2"
require_dir "$ROOT/fase2/local/scripts"

mkdir -p "$ROOT/fase2/logs" "$ROOT/fase2/tmp" "$ROOT/fase2/docs/evidencias"

scripts=(
  "fase2/local/scripts/06_prepare_docker_assets.sh"
  "fase2/local/scripts/10_generate_final_phase2_assets.sh"
  "fase2/local/scripts/11_prepare_executable_phase2.sh"
  "fase2/local/scripts/12_apply_runtime_patches.sh"
  "fase2/local/scripts/15_fix_phase2_compose_runtime.sh"
  "fase2/local/scripts/16_stabilize_phase2_runtime.sh"
  "fase2/local/scripts/17_validate_phase2_e2e_flow.sh"
)

for s in "${scripts[@]}"; do
  require_file "$ROOT/$s"
  chmod +x "$ROOT/$s"
done

if [ "${BOOTSTRAP_RESET_LOCAL:-false}" = "true" ]; then
  section "Reset local Fase 2"
  if [ -f "$ROOT/fase2/docker/docker-compose.phase2-exec.yaml" ]; then
    docker compose -f "$ROOT/fase2/docker/docker-compose.phase2-exec.yaml" down -v --remove-orphans || true
  fi
fi

for s in "${scripts[@]}"; do
  run_script "$ROOT/$s"
done

section "Fase 2 concluída"
echo "Fase 2 local validada end-to-end."
echo "Evidências: fase2/docs/evidencias/"
