#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${HOME}/togglemaster-tc"
FASE1_DIR="${BASE_DIR}/fase1"
APP_DIR="${FASE1_DIR}/src/toggle-master-monolith"
LOG_DIR="${FASE1_DIR}/logs"
EVIDENCE_DIR="${FASE1_DIR}/docs/evidencias"

mkdir -p "${LOG_DIR}" "${EVIDENCE_DIR}"

export BASE_DIR FASE1_DIR APP_DIR LOG_DIR EVIDENCE_DIR
