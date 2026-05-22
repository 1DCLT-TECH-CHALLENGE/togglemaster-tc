# Fundação da VM e Framework — ToggleMaster TC

Esta evidência consolida o estado da VM após instalação das ferramentas base, criação da estrutura do projeto, criação do framework comum e correção definitiva do Docker sem sudo.

## Data/hora do snapshot
Mon May 18 10:20:16 PM -03 2026

## Sistema operacional
Distributor ID:	Ubuntu
Description:	Ubuntu 26.04 LTS
Release:	26.04
Codename:	resolute

Linux tc-fiap 7.0.0-15-generic #15-Ubuntu SMP PREEMPT_DYNAMIC Wed Apr 22 16:06:43 UTC 2026 x86_64 GNU/Linux

## Usuário, grupos e Docker
wellk
uid=1000(wellk) gid=1000(wellk) groups=1000(wellk),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),100(users),111(lpadmin),114(lxd),973(docker)
docker:x:973:wellk
srw-rw---- 1 root docker 0 May 18 22:08 /var/run/docker.sock
Client: Docker Engine - Community
 Version:           29.5.1
 API version:       1.54
 Go version:        go1.26.3
 Git commit:        2518b52
 Built:             Mon May 18 15:24:46 2026
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          29.5.1
  API version:      1.54 (minimum version 1.40)
  Go version:       go1.26.3
  Git commit:       dd24a3a
  Built:            Mon May 18 15:24:46 2026
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v2.2.3
  GitCommit:        77c84241c7cbdd9b4eca2591793e3d4f4317c590
 runc:
  Version:          1.3.5
  GitCommit:        v1.3.5-0-g488fc13e
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
Docker Compose version v5.1.3

## Ferramentas base
git version 2.53.0
curl 8.18.0 (x86_64-pc-linux-gnu) libcurl/8.18.0 OpenSSL/3.5.5 zlib/1.3.1 brotli/1.2.0 zstd/1.5.7 libidn2/2.3.8 libpsl/0.21.2 libssh2/1.11.1 nghttp2/1.68.0 librtmp/2.3 mit-krb5/1.22.1 OpenLDAP/2.6.10
Terraform v1.15.3
on linux_amd64
Client Version: v1.30.14
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
version.BuildInfo{Version:"v3.20.0", GitCommit:"b2e4314fa0f229a1de7b4c981273f61d69ee5a59", GitTreeState:"clean", GoVersion:"go1.25.6"}
aws-cli/2.34.49 Python/3.14.4 Linux/7.0.0-15-generic exe/x86_64.ubuntu.26
go version go1.26.0 linux/amd64
Python 3.11.9
pip 25.3 from /home/wellk/.pyenv/versions/3.11.9/lib/python3.11/site-packages/pip (python 3.11)
pyenv 2.6.31

## AWS sem credenciais nesta etapa

## Estrutura principal do projeto
/home/wellk/togglemaster-tc
├── bootstraps
│   └── README.md
├── fase1
│   ├── docker
│   ├── docs
│   │   ├── adr
│   │   ├── arquitetura
│   │   ├── evidencias
│   │   └── relatorio
│   ├── insumos
│   ├── local
│   │   └── scripts
│   ├── logs
│   ├── README.md
│   ├── repos
│   │   └── upstream
│   ├── src
│   └── tmp
├── fase2
│   ├── docker
│   ├── docs
│   │   ├── adr
│   │   ├── arquitetura
│   │   ├── evidencias
│   │   └── relatorio
│   ├── insumos
│   ├── local
│   │   └── scripts
│   ├── logs
│   ├── README.md
│   ├── repos
│   │   └── upstream
│   ├── src
│   └── tmp
├── fase3
│   ├── docker
│   ├── docs
│   │   ├── adr
│   │   ├── arquitetura
│   │   ├── evidencias
│   │   └── relatorio
│   ├── insumos
│   ├── local
│   │   └── scripts
│   ├── logs
│   ├── README.md
│   ├── repos
│   │   └── upstream
│   ├── src
│   └── tmp
├── fase4
│   ├── docker
│   ├── docs
│   │   ├── adr
│   │   ├── arquitetura
│   │   ├── evidencias
│   │   └── relatorio
│   ├── insumos
│   ├── local
│   │   └── scripts
│   ├── logs
│   ├── README.md
│   ├── repos
│   │   └── upstream
│   ├── src
│   └── tmp
└── _shared
    ├── evidencias
    │   ├── bootstrap-framework.md
    │   └── fundacao-vm-framework.md
    ├── logs
    ├── README.md
    ├── scripts
    │   ├── 00_common.sh
    │   └── 00_common.sh.pre-etapa12-bloco1a.bkp
    └── tmp

67 directories, 10 files

## Framework comum
[2026-05-18 22:21:14] [INFO] Framework comum carregado. TC_ROOT=/home/wellk/togglemaster-tc

============================================================
Validação de ferramentas base
============================================================
[2026-05-18 22:21:14] [INFO] Comando encontrado: bash -> /usr/bin/bash
[2026-05-18 22:21:14] [INFO] Comando encontrado: git -> /usr/bin/git
[2026-05-18 22:21:14] [INFO] Comando encontrado: curl -> /usr/bin/curl
[2026-05-18 22:21:14] [INFO] Comando encontrado: docker -> /usr/bin/docker
[2026-05-18 22:21:14] [INFO] Comando encontrado: terraform -> /usr/bin/terraform
[2026-05-18 22:21:14] [INFO] Comando encontrado: kubectl -> /usr/bin/kubectl
[2026-05-18 22:21:14] [INFO] Comando encontrado: helm -> /usr/sbin/helm
[2026-05-18 22:21:14] [INFO] Comando encontrado: aws -> /usr/local/bin/aws
[2026-05-18 22:21:14] [INFO] Comando encontrado: go -> /usr/bin/go
[2026-05-18 22:21:14] [INFO] Comando encontrado: python3 -> /home/wellk/.pyenv/shims/python3
[2026-05-18 22:21:14] [INFO] Comando opcional encontrado: tree -> /usr/bin/tree
[2026-05-18 22:21:14] [INFO] Nenhuma credencial AWS detectada no ambiente.
179:assert_not_sensitive_file() {
180-  local target="${1:-}"
181-
182-  if [[ -z "$target" ]]; then
183:    error "assert_not_sensitive_file requer caminho do arquivo"
184-    return 1
185-  fi
186-
187-  if [[ ! -f "$target" ]]; then
188-    return 0
189-  fi
190-
191-  if grep -Eqi \
192-    '(AWS_SECRET_ACCESS_KEY|aws_secret_access_key|BEGIN RSA PRIVATE KEY|BEGIN OPENSSH PRIVATE KEY|password *=|token *=)' \
193-    "$target"; then
194-
195-    error "Possível conteúdo sensível detectado em: $target"
196-    return 1
197-  fi
198-
199-  return 0
200-}
201-
202-validate_base_tools() {
203-  section "Validação de ferramentas base"
204-  require_command bash
205-  require_command git
206-  require_command curl
207-  require_command docker
208-  require_command terraform

