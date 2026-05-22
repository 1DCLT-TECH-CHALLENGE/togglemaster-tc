# Exemplo de backend remoto S3.
# NÃO contém valores reais do AWS Academy.
# Copiar para backend.hcl somente quando o AWS Academy Lab estiver aberto.

bucket         = "REPLACE_WITH_ACADEMY_TFSTATE_BUCKET"
key            = "togglemaster/fase3/dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "REPLACE_WITH_ACADEMY_TFLOCK_TABLE"
encrypt        = true
