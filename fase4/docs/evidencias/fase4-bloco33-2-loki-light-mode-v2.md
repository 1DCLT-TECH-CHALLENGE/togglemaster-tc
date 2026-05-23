# Fase 4 - BLOCO 33.2 - Loki em modo leve

Data: Sat May 23 04:23:22 PM -03 2026

## Objetivo

Corrigir definitivamente a configuração do Loki para um perfil leve no AWS Academy, removendo caches/memcached que causaram pressão de memória/pods e impediam a Application de ficar Healthy.

Este bloco também corrige o erro de parsing de versão Helm observado no BLOCO 33.1.


## Estado antes da correção

```text
 M fase4/gitops/observability/values/loki-values.yaml
?? fase4/docs/evidencias/fase4-bloco33-2-loki-light-mode-v2.md
?? fase4/scripts/33_2_fix_loki_light_mode_v2.sh
NAME                 SYNC STATUS   HEALTH STATUS   REVISION   PROJECT
observability-loki   Synced        Progressing                default
NAME                                                        READY   STATUS             RESTARTS       AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
loki-0                                                      1/2     CrashLoopBackOff   6 (3m6s ago)   8m56s   10.10.59.120   ip-10-10-50-171.ec2.internal   <none>           <none>
loki-chunks-cache-0                                         0/2     Pending            0              8m56s   <none>         <none>                         <none>           <none>
loki-results-cache-0                                        2/2     Running            0              8m56s   10.10.45.203   ip-10-10-45-215.ec2.internal   <none>           <none>
```

## Logs Loki antes da correção

```text
mkdir /var/loki: read-only file system
error initialising module: ruler-storage
github.com/grafana/dskit/modules.(*Manager).initModule
	/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:138
github.com/grafana/dskit/modules.(*Manager).InitModuleServices
	/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:108
github.com/grafana/loki/v3/pkg/loki.(*Loki).Run
	/src/loki/pkg/loki/loki.go:549
main.main
	/src/loki/cmd/loki/main.go:136
runtime.main
	/usr/local/go/src/runtime/proc.go:283
runtime.goexit
	/usr/local/go/src/runtime/asm_amd64.s:1700
level=info ts=2026-05-23T19:20:21.51582693Z caller=main.go:133 msg="Starting Loki" version="(version=3.6.7, branch=release-3.6.x, revision=7e1daf3a)"
level=info ts=2026-05-23T19:20:21.515880624Z caller=main.go:134 msg="Loading configuration file" filename=/etc/loki/config/config.yaml
level=error ts=2026-05-23T19:20:21.517263205Z caller=log.go:223 msg="error running loki" err="mkdir /var/loki: read-only file system\nerror initialising module: ruler-storage\ngithub.com/grafana/dskit/modules.(*Manager).initModule\n\t/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:138\ngithub.com/grafana/dskit/modules.(*Manager).InitModuleServices\n\t/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:108\ngithub.com/grafana/loki/v3/pkg/loki.(*Loki).Run\n\t/src/loki/pkg/loki/loki.go:549\nmain.main\n\t/src/loki/cmd/loki/main.go:136\nruntime.main\n\t/usr/local/go/src/runtime/proc.go:283\nruntime.goexit\n\t/usr/local/go/src/runtime/asm_amd64.s:1700"

--- previous ---
mkdir /var/loki: read-only file system
error initialising module: ruler-storage
github.com/grafana/dskit/modules.(*Manager).initModule
	/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:138
github.com/grafana/dskit/modules.(*Manager).InitModuleServices
	/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:108
github.com/grafana/loki/v3/pkg/loki.(*Loki).Run
	/src/loki/pkg/loki/loki.go:549
main.main
	/src/loki/cmd/loki/main.go:136
runtime.main
	/usr/local/go/src/runtime/proc.go:283
runtime.goexit
	/usr/local/go/src/runtime/asm_amd64.s:1700
level=info ts=2026-05-23T19:20:21.51582693Z caller=main.go:133 msg="Starting Loki" version="(version=3.6.7, branch=release-3.6.x, revision=7e1daf3a)"
level=info ts=2026-05-23T19:20:21.515880624Z caller=main.go:134 msg="Loading configuration file" filename=/etc/loki/config/config.yaml
level=error ts=2026-05-23T19:20:21.517263205Z caller=log.go:223 msg="error running loki" err="mkdir /var/loki: read-only file system\nerror initialising module: ruler-storage\ngithub.com/grafana/dskit/modules.(*Manager).initModule\n\t/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:138\ngithub.com/grafana/dskit/modules.(*Manager).InitModuleServices\n\t/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:108\ngithub.com/grafana/loki/v3/pkg/loki.(*Loki).Run\n\t/src/loki/pkg/loki/loki.go:549\nmain.main\n\t/src/loki/cmd/loki/main.go:136\nruntime.main\n\t/usr/local/go/src/runtime/proc.go:283\nruntime.goexit\n\t/usr/local/go/src/runtime/asm_amd64.s:1700"
```

## Patch aplicado

```diff
diff --git a/fase4/gitops/observability/values/loki-values.yaml b/fase4/gitops/observability/values/loki-values.yaml
index 2fe6954..f974bce 100644
--- a/fase4/gitops/observability/values/loki-values.yaml
+++ b/fase4/gitops/observability/values/loki-values.yaml
@@ -53,3 +53,12 @@ read:
   replicas: 0
 write:
   replicas: 0
+
+# Phase 4 AWS Academy lightweight profile.
+# Disable Loki memcached caches to avoid Pending pods and memory pressure.
+chunksCache:
+  enabled: false
+
+resultsCache:
+  enabled: false
+
```
