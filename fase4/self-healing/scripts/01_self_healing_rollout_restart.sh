#!/usr/bin/env bash
set -euo pipefail

NS="${1:-togglemaster}"
TARGET_DEPLOY="${2:-targeting-service}"
TMP="${TMP:-/tmp/togglemaster-self-healing}"

mkdir -p "$TMP"

echo "============================================================"
echo "SELF-HEALING - ROLLOUT RESTART CONTROLADO"
echo "============================================================"
echo "Namespace: $NS"
echo "Deployment alvo: $TARGET_DEPLOY"
echo "Data: $(date)"
echo

echo "[1/7] Estado do deployment antes"
kubectl get deploy "$TARGET_DEPLOY" -n "$NS" -o wide | tee "$TMP/deploy-before.txt"

echo
echo "[2/7] Pods antes"
kubectl get pods -n "$NS" -l app="$TARGET_DEPLOY" -o wide | tee "$TMP/pods-before.txt"

echo
echo "[3/7] Validando réplicas disponíveis antes da ação"
DESIRED="$(kubectl get deploy "$TARGET_DEPLOY" -n "$NS" -o jsonpath='{.spec.replicas}')"
AVAILABLE_BEFORE="$(kubectl get deploy "$TARGET_DEPLOY" -n "$NS" -o jsonpath='{.status.availableReplicas}')"
AVAILABLE_BEFORE="${AVAILABLE_BEFORE:-0}"

echo "DESIRED=$DESIRED"
echo "AVAILABLE_BEFORE=$AVAILABLE_BEFORE"

if [ "$AVAILABLE_BEFORE" -lt 1 ]; then
  echo "ERRO: deployment sem réplica disponível antes do self-healing."
  exit 20
fi

echo
echo "[4/7] Executando ação corretiva: kubectl rollout restart"
kubectl rollout restart deploy/"$TARGET_DEPLOY" -n "$NS"

echo
echo "[5/7] Aguardando recuperação do rollout"
kubectl rollout status deploy/"$TARGET_DEPLOY" -n "$NS" --timeout=300s

echo
echo "[6/7] Estado do deployment depois"
kubectl get deploy "$TARGET_DEPLOY" -n "$NS" -o wide | tee "$TMP/deploy-after.txt"

echo
echo "[7/7] Pods depois"
kubectl get pods -n "$NS" -l app="$TARGET_DEPLOY" -o wide | tee "$TMP/pods-after.txt"

AVAILABLE_AFTER="$(kubectl get deploy "$TARGET_DEPLOY" -n "$NS" -o jsonpath='{.status.availableReplicas}')"
AVAILABLE_AFTER="${AVAILABLE_AFTER:-0}"
UPDATED_AFTER="$(kubectl get deploy "$TARGET_DEPLOY" -n "$NS" -o jsonpath='{.status.updatedReplicas}')"
UPDATED_AFTER="${UPDATED_AFTER:-0}"

echo
echo "DESIRED=$DESIRED"
echo "AVAILABLE_AFTER=$AVAILABLE_AFTER"
echo "UPDATED_AFTER=$UPDATED_AFTER"

if [ "$AVAILABLE_AFTER" -lt 1 ]; then
  echo "ERRO: self-healing não recuperou réplicas disponíveis."
  exit 30
fi

echo
echo "SELF_HEALING_RESULT=SUCCESS"
echo "Ação corretiva executada e deployment recuperado."
