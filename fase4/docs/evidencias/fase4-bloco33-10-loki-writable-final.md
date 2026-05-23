# Fase 4 - BLOCO 33.10 - Loki com /var/loki writable

## Objetivo

Finalizar a correção do Loki para o AWS Academy Lab.

O diagnóstico anterior confirmou CrashLoopBackOff por tentativa de escrita em /var/loki com root filesystem somente leitura.

A correção mantém readOnlyRootFilesystem=true e adiciona um emptyDir montado em /var/loki.

Data: Sat May 23 04:53:27 PM -03 2026

## Patch GitOps

```diff
diff --git a/fase4/gitops/apps/observability/loki-application.yaml b/fase4/gitops/apps/observability/loki-application.yaml
index d09f7d6..f7466a3 100644
--- a/fase4/gitops/apps/observability/loki-application.yaml
+++ b/fase4/gitops/apps/observability/loki-application.yaml
@@ -15,6 +15,7 @@ spec:
         releaseName: loki
         valueFiles:
           - $values/fase4/gitops/observability/values/loki-values.yaml
+          - $values/fase4/gitops/observability/values/loki-lab-writable-values.yaml
     - repoURL: git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git
       targetRevision: main
       ref: values
```

## Validação local

```text
LOKI_VERSION=7.0.0
kubectl dry-run server OK
Helm render OK com /var/loki writable e sem caches
```
