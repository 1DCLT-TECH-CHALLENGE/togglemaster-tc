#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

TF_DIR="$ROOT/fase3/terraform/environments/dev"
cd "$TF_DIR"

section "ToggleMaster TC - Destroy AWS Resources"
echo "Remove infraestrutura AWS gerenciada pelo Terraform."
echo "Só aplica destroy com CONFIRM_DESTROY=SIM."

require_cmd aws
require_cmd terraform

section "Conta AWS atual"
aws sts get-caller-identity

section "Plano de destroy"
terraform init -reconfigure
terraform plan -destroy -out=tfplan-destroy

if [ "${CONFIRM_DESTROY:-}" != "SIM" ]; then
  echo
  echo "Plano gerado em: $TF_DIR/tfplan-destroy"
  echo "Para destruir de fato:"
  echo "CONFIRM_DESTROY=SIM $ROOT/bootstraps/06_destroy_aws_resources.sh"
  exit 0
fi

section "Aplicando destroy"
terraform apply "tfplan-destroy"

section "Validação pós-destroy"
terraform state list || true
aws eks list-clusters --region "${AWS_REGION:-us-east-1}" || true
aws rds describe-db-instances --region "${AWS_REGION:-us-east-1}" --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]' --output table || true
aws elasticache describe-cache-clusters --region "${AWS_REGION:-us-east-1}" --query 'CacheClusters[*].[CacheClusterId,CacheClusterStatus]' --output table || true
aws ec2 describe-nat-gateways --region "${AWS_REGION:-us-east-1}" --query 'NatGateways[*].[NatGatewayId,State,VpcId]' --output table || true

section "Destroy concluído"
