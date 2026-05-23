# Fase 4 - BLOCO 33.6 - Sync/prune do Loki no ArgoCD

Data: Sat May 23 04:46:06 PM -03 2026

## Objetivo

Forçar o ArgoCD a aplicar o estado GitOps atual do Loki, com prune dos recursos antigos de cache/memcached, e diagnosticar o CrashLoop do `loki-0`.


## Estado inicial

```text
7fad6dc (HEAD -> main, origin/main) docs: stabilize cluster after lab transition
38c433d docs: stabilize cluster after lab transition
d6afff8 fix: disable loki caches for phase 4 lab
8d734ee docs: validate phase 4 grafana dashboard
19aa77c docs: validate phase 4 grafana access
fd2f476 docs: deploy phase 4 prometheus grafana stack
8e812f1 feat: prepare phase 4 observability gitops
6926335 docs: apply phase 4 eks capacity fix
NAME                 SYNC STATUS   HEALTH STATUS   REVISION   PROJECT
observability-loki   OutOfSync     Progressing                default
NAME                                                        READY   STATUS             RESTARTS      AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
loki-0                                                      1/2     CrashLoopBackOff   5 (19s ago)   3m29s   10.10.63.6     ip-10-10-51-233.ec2.internal   <none>           <none>
loki-chunks-cache-0                                         0/2     Pending            0             22m     <none>         <none>                         <none>           <none>
loki-results-cache-0                                        2/2     Running            0             3m49s   10.10.58.123   ip-10-10-59-138.ec2.internal   <none>           <none>
NAME                                              READY   AGE
loki                                              0/1     31m
loki-chunks-cache                                 0/1     22m
loki-results-cache                                1/1     22m
NAME                                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
loki                                             ClusterIP   172.20.165.63    <none>        3100/TCP,9095/TCP            31m
loki-chunks-cache                                ClusterIP   None             <none>        11211/TCP,9150/TCP           22m
loki-headless                                    ClusterIP   None             <none>        3100/TCP                     31m
loki-memberlist                                  ClusterIP   None             <none>        7946/TCP                     31m
loki-results-cache                               ClusterIP   None             <none>        11211/TCP,9150/TCP           22m
```

## Render local

```text
LOKI_VERSION=7.0.0
Render local não contém chunks-cache/results-cache.
```
