# Fase 4 - BLOCO 33.9 - Correção do Loki com volume writable em /var/loki

## Objetivo

Corrigir o CrashLoopBackOff do Loki causado por tentativa de escrita em /var/loki com root filesystem somente leitura.

A correção mantém readOnlyRootFilesystem=true e adiciona um volume emptyDir montado em /var/loki para o modo lab.

Data: Sat May 23 04:51:56 PM -03 2026

## Estado inicial

```text
NAME                 SYNC STATUS   HEALTH STATUS   REVISION   PROJECT
observability-loki   Synced        Progressing                default
NAME                                                        READY   STATUS             RESTARTS        AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
loki-0                                                      1/2     CrashLoopBackOff   6 (3m22s ago)   9m19s   10.10.63.6     ip-10-10-51-233.ec2.internal   <none>           <none>
NAME                                              READY   AGE
loki                                              0/1     37m
```

## Patch GitOps aplicado

```diff
diff --git a/fase4/gitops/apps/observability/loki-application.yaml b/fase4/gitops/apps/observability/loki-application.yaml
index d09f7d6..511da3e 100644
--- a/fase4/gitops/apps/observability/loki-application.yaml
+++ b/fase4/gitops/apps/observability/loki-application.yaml
@@ -15,6 +15,7 @@ spec:
         releaseName: loki
         valueFiles:
           - $values/fase4/gitops/observability/values/loki-values.yaml
+        - $values/fase4/gitops/observability/values/loki-lab-writable-values.yaml
     - repoURL: git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git
       targetRevision: main
       ref: values
```

## Validação Helm render

```text
LOKI_VERSION=7.0.0
Render contém mountPath /var/loki e volume loki-var.
Render não contém chunks-cache/results-cache.
```
