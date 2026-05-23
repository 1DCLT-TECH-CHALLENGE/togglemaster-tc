# Fase 4 - BLOCO 30 - Aplicação Prometheus/Grafana via ArgoCD

Data: Sat May 23 03:34:01 PM -03 2026

## Objetivo

Aplicar a primeira parte da stack de observabilidade da Fase 4:

- namespace `observability`;
- `kube-prometheus-stack`, incluindo Prometheus, Grafana, Alertmanager, kube-state-metrics e node-exporter.

Este bloco não instala Loki, Promtail, OpenTelemetry Collector, APM externo, incident management, ChatOps ou self-healing.


## 1. Estado inicial


### Git status

```bash
$ git status --short
?? fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md
?? fase4/scripts/30_apply_prometheus_grafana_argocd.sh

```

RC: `0`

### Últimos commits

```bash
$ git log --oneline --decorate -8
8e812f1 (HEAD -> main, origin/main) feat: prepare phase 4 observability gitops
6926335 docs: apply phase 4 eks capacity fix
abe295a docs: record phase 4 eks capacity terraform plan
d75514c feat: adjust eks capacity for phase 4 observability
72bb291 docs: plan phase 4 observability capacity fix
7d6f15d docs: record phase 4 observability capacity gate
4680d8b docs: record phase 4 stack inventory
74f1c33 docs: open phase 4 delivery

```

RC: `0`

### Cluster nodes

```bash
$ retry_cmd 6 10 kubectl get nodes -o wide
Tentativa 1/6: kubectl get nodes -o wide
NAME                           STATUS   ROLES    AGE   VERSION                INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-10-40-95.ec2.internal    Ready    <none>   12h   v1.30.14-eks-7fcd7ec   10.10.40.95    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-45-215.ec2.internal   Ready    <none>   26m   v1.30.14-eks-7fcd7ec   10.10.45.215   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-48-118.ec2.internal   Ready    <none>   26m   v1.30.14-eks-7fcd7ec   10.10.48.118   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-49-137.ec2.internal   Ready    <none>   12h   v1.30.14-eks-7fcd7ec   10.10.49.137   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-50-171.ec2.internal   Ready    <none>   26m   v1.30.14-eks-7fcd7ec   10.10.50.171   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown

```

RC: `0`

### ArgoCD ToggleMaster

```bash
$ retry_cmd 6 10 kubectl get application togglemaster-dev -n argocd -o wide
Tentativa 1/6: kubectl get application togglemaster-dev -n argocd -o wide
NAME               SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev   Synced        Healthy         8e812f1317bd690ffd791d86ceb39d2a8b26c18d   default

```

RC: `0`

### Pods antes da observabilidade

```bash
$ retry_cmd 8 10 kubectl get pods -A -o wide
Tentativa 1/8: kubectl get pods -A -o wide
NAMESPACE      NAME                                                READY   STATUS    RESTARTS   AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
argocd         argocd-application-controller-0                     1/1     Running   0          11h   10.10.53.215   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd         argocd-applicationset-controller-5b964db9cd-rl8kn   1/1     Running   0          12h   10.10.58.145   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd         argocd-dex-server-b8cc6d795-r658p                   1/1     Running   0          12h   10.10.50.38    ip-10-10-49-137.ec2.internal   <none>           <none>
argocd         argocd-notifications-controller-597cccd4ff-q2p2l    1/1     Running   0          12h   10.10.49.102   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd         argocd-redis-675f9c4c99-ngqb4                       1/1     Running   0          12h   10.10.32.229   ip-10-10-40-95.ec2.internal    <none>           <none>
argocd         argocd-repo-server-5c46694888-b4bqj                 1/1     Running   0          12h   10.10.43.108   ip-10-10-40-95.ec2.internal    <none>           <none>
argocd         argocd-server-7f66865588-df8sl                      1/1     Running   0          12h   10.10.56.210   ip-10-10-49-137.ec2.internal   <none>           <none>
kube-system    aws-node-4tqtk                                      2/2     Running   0          12h   10.10.40.95    ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system    aws-node-bfqsn                                      2/2     Running   0          26m   10.10.50.171   ip-10-10-50-171.ec2.internal   <none>           <none>
kube-system    aws-node-hxr94                                      2/2     Running   0          12h   10.10.49.137   ip-10-10-49-137.ec2.internal   <none>           <none>
kube-system    aws-node-jsf8t                                      2/2     Running   0          26m   10.10.45.215   ip-10-10-45-215.ec2.internal   <none>           <none>
kube-system    aws-node-w6wwq                                      2/2     Running   0          26m   10.10.48.118   ip-10-10-48-118.ec2.internal   <none>           <none>
kube-system    coredns-849f74687b-lg2g2                            1/1     Running   0          12h   10.10.45.165   ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system    coredns-849f74687b-sqcpd                            1/1     Running   0          12h   10.10.41.233   ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system    kube-proxy-4d2cb                                    1/1     Running   0          26m   10.10.45.215   ip-10-10-45-215.ec2.internal   <none>           <none>
kube-system    kube-proxy-57stg                                    1/1     Running   0          12h   10.10.40.95    ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system    kube-proxy-chm7l                                    1/1     Running   0          26m   10.10.50.171   ip-10-10-50-171.ec2.internal   <none>           <none>
kube-system    kube-proxy-fm6l2                                    1/1     Running   0          12h   10.10.49.137   ip-10-10-49-137.ec2.internal   <none>           <none>
kube-system    kube-proxy-xth2f                                    1/1     Running   0          26m   10.10.48.118   ip-10-10-48-118.ec2.internal   <none>           <none>
togglemaster   analytics-service-6946467b6b-9fvmm                  1/1     Running   0          82m   10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   auth-service-584688f79d-vpg2z                       1/1     Running   0          12h   10.10.59.194   ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   auth-service-584688f79d-xt6v8                       1/1     Running   0          12h   10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   evaluation-service-7949b95dd5-kf2md                 1/1     Running   0          82m   10.10.37.127   ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   evaluation-service-7949b95dd5-wbrlc                 1/1     Running   0          81m   10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   flag-service-7cd69f6bf9-9ffxm                       1/1     Running   0          12h   10.10.35.34    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster   flag-service-7cd69f6bf9-x7pxc                       1/1     Running   0          12h   10.10.55.41    ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   targeting-service-66d4bb78b6-7zc9d                  1/1     Running   0          12h   10.10.48.76    ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster   targeting-service-66d4bb78b6-8tw7t                  1/1     Running   0          12h   10.10.41.90    ip-10-10-40-95.ec2.internal    <none>           <none>

```

RC: `0`

## 2. Validar manifests antes do apply


### Kustomize apps observability

```bash
$ kubectl kustomize fase4/gitops/apps/observability
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "30"
  name: observability-dashboards
  namespace: argocd
spec:
  destination:
    namespace: observability
    server: https://kubernetes.default.svc
  project: default
  source:
    path: fase4/gitops/observability/dashboards
    repoURL: git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git
    targetRevision: main
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  name: observability-kube-prometheus-stack
  namespace: argocd
spec:
  destination:
    namespace: observability
    server: https://kubernetes.default.svc
  project: default
  sources:
  - chart: kube-prometheus-stack
    helm:
      releaseName: kube-prometheus-stack
      valueFiles:
      - $values/fase4/gitops/observability/values/kube-prometheus-stack-values.yaml
    repoURL: https://prometheus-community.github.io/helm-charts
    targetRevision: 85.3.0
  - ref: values
    repoURL: git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git
    targetRevision: main
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    - ServerSideApply=true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "20"
  name: observability-loki
  namespace: argocd
spec:
  destination:
    namespace: observability
    server: https://kubernetes.default.svc
  project: default
  sources:
  - chart: loki
    helm:
      releaseName: loki
      valueFiles:
      - $values/fase4/gitops/observability/values/loki-values.yaml
    repoURL: https://grafana.github.io/helm-charts
    targetRevision: 7.0.0
  - ref: values
    repoURL: git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git
    targetRevision: main
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    - ServerSideApply=true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "0"
  name: observability-namespace
  namespace: argocd
spec:
  destination:
    namespace: observability
    server: https://kubernetes.default.svc
  project: default
  source:
    path: fase4/gitops/observability/namespace
    repoURL: git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git
    targetRevision: main
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "30"
  name: observability-opentelemetry-collector
  namespace: argocd
spec:
  destination:
    namespace: observability
    server: https://kubernetes.default.svc
  project: default
  sources:
  - chart: opentelemetry-collector
    helm:
      releaseName: opentelemetry-collector
      valueFiles:
      - $values/fase4/gitops/observability/values/opentelemetry-collector-values.yaml
    repoURL: https://open-telemetry.github.io/opentelemetry-helm-charts
    targetRevision: 0.156.2
  - ref: values
    repoURL: git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git
    targetRevision: main
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    - ServerSideApply=true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "21"
  name: observability-promtail
  namespace: argocd
spec:
  destination:
    namespace: observability
    server: https://kubernetes.default.svc
  project: default
  sources:
  - chart: promtail
    helm:
      releaseName: promtail
      valueFiles:
      - $values/fase4/gitops/observability/values/promtail-values.yaml
    repoURL: https://grafana.github.io/helm-charts
    targetRevision: 6.17.1
  - ref: values
    repoURL: git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git
    targetRevision: main
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    - ServerSideApply=true

```

RC: `0`

### Manifest namespace application

```bash
$ cat fase4/gitops/apps/observability/namespace-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: observability-namespace
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  project: default
  source:
    repoURL: git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git
    targetRevision: main
    path: fase4/gitops/observability/namespace
  destination:
    server: https://kubernetes.default.svc
    namespace: observability
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

```

RC: `0`

### Manifest kube-prometheus-stack application

```bash
$ cat fase4/gitops/apps/observability/kube-prometheus-stack-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: observability-kube-prometheus-stack
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "10"
spec:
  project: default
  sources:
    - repoURL: https://prometheus-community.github.io/helm-charts
      chart: kube-prometheus-stack
      targetRevision: 85.3.0
      helm:
        releaseName: kube-prometheus-stack
        valueFiles:
          - $values/fase4/gitops/observability/values/kube-prometheus-stack-values.yaml
    - repoURL: git@github.com:1DCLT-TECH-CHALLENGE/togglemaster-tc.git
      targetRevision: main
      ref: values
  destination:
    server: https://kubernetes.default.svc
    namespace: observability
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true

```

RC: `0`

## 3. Aplicar namespace Application


### kubectl apply namespace application

```bash
$ retry_cmd 4 10 kubectl apply -f fase4/gitops/apps/observability/namespace-application.yaml
Tentativa 1/4: kubectl apply -f fase4/gitops/apps/observability/namespace-application.yaml
application.argoproj.io/observability-namespace created

```

RC: `0`

### Namespace observability

```bash
$ retry_cmd 6 10 kubectl get ns observability -o wide
Tentativa 1/6: kubectl get ns observability -o wide
NAME            STATUS   AGE
observability   Active   2s

```

RC: `0`

## 4. Aplicar kube-prometheus-stack Application


### kubectl apply kube-prometheus-stack application

```bash
$ retry_cmd 4 10 kubectl apply -f fase4/gitops/apps/observability/kube-prometheus-stack-application.yaml
Tentativa 1/4: kubectl apply -f fase4/gitops/apps/observability/kube-prometheus-stack-application.yaml
application.argoproj.io/observability-kube-prometheus-stack created

```

RC: `0`

## 5. Validar recursos instalados


### ArgoCD observability apps

```bash
$ retry_bash 6 10 kubectl get applications -n "argocd" | grep -E 'observability|NAME'
Tentativa 1/6: kubectl get applications -n "argocd" | grep -E 'observability|NAME'
NAME                                  SYNC STATUS   HEALTH STATUS
observability-kube-prometheus-stack   Synced        Healthy
observability-namespace               Synced        Healthy

```

RC: `0`

### Pods observability

```bash
$ retry_cmd 8 10 kubectl get pods -n observability -o wide
Tentativa 1/8: kubectl get pods -n observability -o wide
NAME                                                        READY   STATUS      RESTARTS   AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running     0          17m   10.10.61.84    ip-10-10-48-118.ec2.internal   <none>           <none>
kube-prometheus-stack-admission-create-v6pwv                0/1     Completed   0          38s   10.10.61.62    ip-10-10-48-118.ec2.internal   <none>           <none>
kube-prometheus-stack-admission-patch-qqklj                 0/1     Completed   0          3s    10.10.61.62    ip-10-10-48-118.ec2.internal   <none>           <none>
kube-prometheus-stack-grafana-79bcfffd55-lxf4t              3/3     Running     0          25s   10.10.34.88    ip-10-10-45-215.ec2.internal   <none>           <none>
kube-prometheus-stack-kube-state-metrics-64659c7c5c-dz2zx   1/1     Running     0          17m   10.10.55.108   ip-10-10-50-171.ec2.internal   <none>           <none>
kube-prometheus-stack-operator-8564f47cff-f99bt             1/1     Running     0          17m   10.10.55.47    ip-10-10-48-118.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-btj4c        1/1     Running     0          17m   10.10.49.137   ip-10-10-49-137.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-g28h6        1/1     Running     0          17m   10.10.50.171   ip-10-10-50-171.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-lwz8l        1/1     Running     0          17m   10.10.48.118   ip-10-10-48-118.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-m54qw        1/1     Running     0          17m   10.10.45.215   ip-10-10-45-215.ec2.internal   <none>           <none>
kube-prometheus-stack-prometheus-node-exporter-r4hf7        1/1     Running     0          17m   10.10.40.95    ip-10-10-40-95.ec2.internal    <none>           <none>
prometheus-kube-prometheus-stack-prometheus-0               2/2     Running     0          17m   10.10.52.90    ip-10-10-50-171.ec2.internal   <none>           <none>

```

RC: `0`

### Services observability

```bash
$ retry_cmd 6 10 kubectl get svc -n observability -o wide
Tentativa 1/6: kubectl get svc -n observability -o wide
NAME                                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE   SELECTOR
alertmanager-operated                            ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP   17m   app.kubernetes.io/name=alertmanager
kube-prometheus-stack-alertmanager               ClusterIP   172.20.167.225   <none>        9093/TCP,8080/TCP            17m   alertmanager=kube-prometheus-stack-alertmanager,app.kubernetes.io/name=alertmanager
kube-prometheus-stack-grafana                    ClusterIP   172.20.29.140    <none>        80/TCP                       17m   app.kubernetes.io/instance=kube-prometheus-stack,app.kubernetes.io/name=grafana
kube-prometheus-stack-kube-state-metrics         ClusterIP   172.20.124.21    <none>        8080/TCP                     17m   app.kubernetes.io/instance=kube-prometheus-stack,app.kubernetes.io/name=kube-state-metrics
kube-prometheus-stack-operator                   ClusterIP   172.20.2.80      <none>        443/TCP                      17m   app=kube-prometheus-stack-operator,release=kube-prometheus-stack
kube-prometheus-stack-prometheus                 ClusterIP   172.20.74.139    <none>        9090/TCP,8080/TCP            17m   app.kubernetes.io/name=prometheus,operator.prometheus.io/name=kube-prometheus-stack-prometheus
kube-prometheus-stack-prometheus-node-exporter   ClusterIP   172.20.231.67    <none>        9100/TCP                     17m   app.kubernetes.io/instance=kube-prometheus-stack,app.kubernetes.io/name=prometheus-node-exporter
prometheus-operated                              ClusterIP   None             <none>        9090/TCP                     17m   app.kubernetes.io/name=prometheus

```

RC: `0`

### Deployments observability

```bash
$ retry_cmd 6 10 kubectl get deployments -n observability -o wide
Tentativa 1/6: kubectl get deployments -n observability -o wide
NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS                                            IMAGES                                                                                                               SELECTOR
kube-prometheus-stack-grafana              1/1     1            1           17m   grafana-sc-dashboard,grafana-sc-datasources,grafana   quay.io/kiwigrid/k8s-sidecar:2.7.3,quay.io/kiwigrid/k8s-sidecar:2.7.3,docker.io/grafana/grafana:13.0.1-security-01   app.kubernetes.io/instance=kube-prometheus-stack,app.kubernetes.io/name=grafana
kube-prometheus-stack-kube-state-metrics   1/1     1            1           17m   kube-state-metrics                                    registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.19.0                                                        app.kubernetes.io/instance=kube-prometheus-stack,app.kubernetes.io/name=kube-state-metrics
kube-prometheus-stack-operator             1/1     1            1           17m   kube-prometheus-stack                                 quay.io/prometheus-operator/prometheus-operator:v0.90.1                                                              app=kube-prometheus-stack-operator,release=kube-prometheus-stack

```

RC: `0`

### StatefulSets observability

```bash
$ retry_cmd 6 10 kubectl get statefulsets -n observability -o wide
Tentativa 1/6: kubectl get statefulsets -n observability -o wide
NAME                                              READY   AGE   CONTAINERS                     IMAGES
alertmanager-kube-prometheus-stack-alertmanager   1/1     17m   alertmanager,config-reloader   quay.io/prometheus/alertmanager:v0.32.1,quay.io/prometheus-operator/prometheus-config-reloader:v0.90.1
prometheus-kube-prometheus-stack-prometheus       1/1     17m   prometheus,config-reloader     quay.io/prometheus/prometheus:v3.11.3-distroless,quay.io/prometheus-operator/prometheus-config-reloader:v0.90.1

```

RC: `0`

### DaemonSets observability

```bash
$ retry_cmd 6 10 kubectl get daemonsets -n observability -o wide
Tentativa 1/6: kubectl get daemonsets -n observability -o wide
NAME                                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE   CONTAINERS      IMAGES                                                SELECTOR
kube-prometheus-stack-prometheus-node-exporter   5         5         5       5            5           kubernetes.io/os=linux   17m   node-exporter   quay.io/prometheus/node-exporter:v1.11.1-distroless   app.kubernetes.io/instance=kube-prometheus-stack,app.kubernetes.io/name=prometheus-node-exporter

```

RC: `0`

## 6. Checagem de readiness


### Pods não prontos

```text
Nenhum pod não pronto no namespace observability.
```

## 7. Capacity check pós-instalação Prometheus/Grafana


### Capacity check pós-instalação

```text
TOTAL_POD_CAPACITY=55
TOTAL_PODS_USED=38
TOTAL_PODS_REMAINING=17
Pods por namespace:
- argocd: 7
- kube-system: 12
- observability: 10
- togglemaster: 9
Pods por node:
- ip-10-10-40-95.ec2.internal: used=11 remaining=0
- ip-10-10-45-215.ec2.internal: used=5 remaining=6
- ip-10-10-48-118.ec2.internal: used=6 remaining=5
- ip-10-10-49-137.ec2.internal: used=11 remaining=0
- ip-10-10-50-171.ec2.internal: used=5 remaining=6
```

## 8. Resultado


## Resultado

BLOCO 30 concluído com sucesso.

Componentes aplicados:

- `observability-namespace`
- `observability-kube-prometheus-stack`

Validações realizadas:

- ArgoCD Applications Synced/Healthy;
- pods do namespace `observability` Running/Ready;
- services, deployments, statefulsets e daemonsets listados;
- capacity check pós-instalação registrado.

Ainda não foram instalados:

- Loki;
- Promtail;
- OpenTelemetry Collector;
- APM externo;
- Incident Management;
- ChatOps;
- Self-healing.

