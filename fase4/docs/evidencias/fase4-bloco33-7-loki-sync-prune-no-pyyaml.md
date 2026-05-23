# Fase 4 - BLOCO 33.7 - Sync/prune Loki sem PyYAML

Data: Sat May 23 04:47:35 PM -03 2026

## Objetivo

Executar sync/prune do Loki no ArgoCD sem depender do módulo Python `yaml`, confirmar se os caches antigos foram removidos e registrar logs objetivos do `loki-0`.


## Estado inicial

```text
69e8c64 (HEAD -> main, origin/main) docs: diagnose loki sync prune
7fad6dc docs: stabilize cluster after lab transition
38c433d docs: stabilize cluster after lab transition
d6afff8 fix: disable loki caches for phase 4 lab
8d734ee docs: validate phase 4 grafana dashboard
19aa77c docs: validate phase 4 grafana access
fd2f476 docs: deploy phase 4 prometheus grafana stack
8e812f1 feat: prepare phase 4 observability gitops
NAME                 SYNC STATUS   HEALTH STATUS   REVISION   PROJECT
observability-loki   OutOfSync     Progressing                default
NAME                                                        READY   STATUS             RESTARTS       AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
loki-0                                                      1/2     CrashLoopBackOff   5 (108s ago)   4m58s   10.10.63.6     ip-10-10-51-233.ec2.internal   <none>           <none>
loki-chunks-cache-0                                         0/2     Pending            0              24m     <none>         <none>                         <none>           <none>
loki-results-cache-0                                        2/2     Running            0              5m18s   10.10.58.123   ip-10-10-59-138.ec2.internal   <none>           <none>
NAME                                              READY   AGE
loki                                              0/1     33m
loki-chunks-cache                                 0/1     24m
loki-results-cache                                1/1     24m
NAME                                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
loki                                             ClusterIP   172.20.165.63    <none>        3100/TCP,9095/TCP            33m
loki-chunks-cache                                ClusterIP   None             <none>        11211/TCP,9150/TCP           24m
loki-headless                                    ClusterIP   None             <none>        3100/TCP                     33m
loki-memberlist                                  ClusterIP   None             <none>        7946/TCP                     33m
loki-results-cache                               ClusterIP   None             <none>        11211/TCP,9150/TCP           24m
```

## Application ArgoCD

```json
Application source/sources:
[
  {
    "chart": "loki",
    "helm": {
      "releaseName": "loki",
      "valueFiles": [
        "$values/fase4/gitops/observability/values/loki-values.yaml"
      ]
    },
    "repoURL": "https://grafana.github.io/helm-charts",
    "targetRevision": "7.0.0"
  },
  {
    "ref": "values",
    "repoURL": "git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git",
    "targetRevision": "main"
  }
]
Application syncPolicy:
{
  "automated": {
    "prune": false,
    "selfHeal": true
  },
  "syncOptions": [
    "CreateNamespace=true",
    "ServerSideApply=true"
  ]
}
Application status:
{
  "health": {
    "lastTransitionTime": "2026-05-23T19:14:31Z",
    "status": "Progressing"
  },
  "operationState": {
    "finishedAt": "2026-05-23T19:23:41Z",
    "message": "successfully synced (all tasks run)",
    "operation": {
      "initiatedBy": {
        "automated": true
      },
      "retry": {
        "limit": 5
      },
      "sync": {
        "autoHealAttemptsCount": 1,
        "resources": [
          {
            "group": "apps",
            "kind": "StatefulSet",
            "name": "loki"
          },
          {
            "kind": "Service",
            "name": "loki-chunks-cache"
          },
          {
            "kind": "Service",
            "name": "loki-results-cache"
          },
          {
            "group": "apps",
            "kind": "StatefulSet",
            "name": "loki-chunks-cache"
          },
          {
            "group": "apps",
            "kind": "StatefulSet",
            "name": "loki-results-cache"
          }
        ],
        "revisions": [
          "7.0.0",
          "d6afff83fcf1f8b439e1d1b13b04e489cf5262c9"
        ],
        "sources": [
          {
            "chart": "loki",
            "helm": {
              "releaseName": "loki",
              "valueFiles": [
                "$values/fase4/gitops/observability/values/loki-values.yaml"
              ]
            },
            "repoURL": "https://grafana.github.io/helm-charts",
            "targetRevision": "7.0.0"
          },
          {
            "ref": "values",
            "repoURL": "git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git",
            "targetRevision": "main"
          }
        ],
        "syncOptions": [
          "CreateNamespace=true",
          "ServerSideApply=true"
        ]
      }
    },
    "phase": "Succeeded",
    "startedAt": "2026-05-23T19:23:40Z",
    "syncResult": {
      "resources": [
        {
          "group": "",
          "hookPhase": "Succeeded",
          "kind": "Service",
          "message": "ignored (requires pruning)",
          "name": "loki-chunks-cache",
          "namespace": "observability",
          "status": "PruneSkipped",
          "syncPhase": "Sync",
          "version": "v1"
        },
        {
          "group": "",
          "hookPhase": "Succeeded",
          "kind": "Service",
          "message": "ignored (requires pruning)",
          "name": "loki-results-cache",
          "namespace": "observability",
          "status": "PruneSkipped",
          "syncPhase": "Sync",
          "version": "v1"
        },
        {
          "group": "apps",
          "hookPhase": "Succeeded",
          "images": [
            "memcached:1.6.39-alpine",
            "prom/memcached-exporter:v0.15.4"
          ],
          "kind": "StatefulSet",
          "message": "ignored (requires pruning)",
          "name": "loki-chunks-cache",
          "namespace": "observability",
          "status": "PruneSkipped",
          "syncPhase": "Sync",
          "version": "v1"
        },
        {
          "group": "apps",
          "hookPhase": "Succeeded",
          "images": [
            "memcached:1.6.39-alpine",
            "prom/memcached-exporter:v0.15.4"
          ],
          "kind": "StatefulSet",
          "message": "ignored (requires pruning)",
          "name": "loki-results-cache",
          "namespace": "observability",
          "status": "PruneSkipped",
          "syncPhase": "Sync",
          "version": "v1"
        },
        {
          "group": "apps",
          "hookPhase": "Running",
          "images": [
            "docker.io/grafana/loki:3.6.7",
            "docker.io/kiwigrid/k8s-sidecar:2.5.0"
          ],
          "kind": "StatefulSet",
          "message": "statefulset.apps/loki serverside-applied",
          "name": "loki",
          "namespace": "observability",
          "status": "Synced",
          "syncPhase": "Sync",
          "version": "v1"
        }
      ],
      "revision": "",
      "revisions": [
        "7.0.0",
        "d6afff83fcf1f8b439e1d1b13b04e489cf5262c9"
      ],
      "source": {
        "repoURL": ""
      },
      "sources": [
        {
          "chart": "loki",
          "helm": {
            "releaseName": "loki",
            "valueFiles": [
              "$values/fase4/gitops/observability/values/loki-values.yaml"
            ]
          },
          "repoURL": "https://grafana.github.io/helm-charts",
          "targetRevision": "7.0.0"
        },
        {
          "ref": "values",
          "repoURL": "git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git",
          "targetRevision": "main"
        }
      ]
    }
  },
  "sync": {
    "comparedTo": {
      "destination": {
        "namespace": "observability",
        "server": "https://kubernetes.default.svc"
      },
      "source": {
        "repoURL": ""
      },
      "sources": [
        {
          "chart": "loki",
          "helm": {
            "releaseName": "loki",
            "valueFiles": [
              "$values/fase4/gitops/observability/values/loki-values.yaml"
            ]
          },
          "repoURL": "https://grafana.github.io/helm-charts",
          "targetRevision": "7.0.0"
        },
        {
          "ref": "values",
          "repoURL": "git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git",
          "targetRevision": "main"
        }
      ]
    },
    "revisions": [
      "7.0.0",
      "69e8c6454f6a7578affe03e773d50ae0902b85b1"
    ],
    "status": "OutOfSync"
  }
}
```

## Recursos antes do sync/prune

```text
ClusterRoleBinding		loki-clusterrolebinding	Synced	
ClusterRole		loki-clusterrole	Synced	
ConfigMap	observability	loki-runtime	Synced	
ConfigMap	observability	loki	Synced	
ServiceAccount	observability	loki	Synced	
Service	observability	loki-chunks-cache	OutOfSync	
Service	observability	loki-headless	Synced	
Service	observability	loki-memberlist	Synced	
Service	observability	loki-results-cache	OutOfSync	
Service	observability	loki	Synced	
StatefulSet	observability	loki-chunks-cache	OutOfSync	
StatefulSet	observability	loki-results-cache	OutOfSync	
StatefulSet	observability	loki	Synced	
```
