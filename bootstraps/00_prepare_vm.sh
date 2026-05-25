#!/usr/bin/env bash
set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

section "ToggleMaster TC - 00 Prepare VM"
echo "Prepara uma VM Ubuntu com dependências para as fases locais e cloud."
echo "Instala utilitários, Docker, Terraform, kubectl, Helm, AWS CLI, Go e Python quando ausentes."

if ! command -v apt-get >/dev/null 2>&1; then
  fail "Este bootstrap foi desenhado para Ubuntu/Debian com apt-get."
fi

section "Pacotes base"
sudo apt-get update -y
sudo apt-get install -y \
  ca-certificates curl wget gnupg lsb-release jq unzip zip git make \
  build-essential software-properties-common python3 python3-pip python3-venv openssl

section "Docker"
if ! command -v docker >/dev/null 2>&1; then
  sudo install -m 0755 -d /etc/apt/keyrings

  if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  fi

  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  . /etc/os-release

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
  info "Docker já instalado."
fi

sudo usermod -aG docker "$USER" || true
docker --version || true
docker compose version || true

section "Terraform"
if ! command -v terraform >/dev/null 2>&1; then
  wget -O- https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

  sudo apt-get update -y
  sudo apt-get install -y terraform
else
  info "Terraform já instalado."
fi

terraform version || true

section "kubectl"
if ! command -v kubectl >/dev/null 2>&1; then
  curl -fsSL -o /tmp/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
else
  info "kubectl já instalado."
fi

kubectl version --client=true || true

section "Helm"
if ! command -v helm >/dev/null 2>&1; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  info "Helm já instalado."
fi

helm version || true

section "AWS CLI"
if ! command -v aws >/dev/null 2>&1; then
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  rm -rf /tmp/aws
  unzip -q /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install
else
  info "AWS CLI já instalada."
fi

aws --version || true

section "Go"
if ! command -v go >/dev/null 2>&1; then
  sudo apt-get install -y golang-go
else
  info "Go já instalado."
fi

go version || true

section "Conclusão"
echo "VM preparada."
echo "Se Docker foi instalado agora, pode ser necessário sair e entrar novamente na sessão para o grupo docker valer."
