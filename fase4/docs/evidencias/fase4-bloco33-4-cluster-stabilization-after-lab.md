# Fase 4 - BLOCO 33.4 - Estabilização do cluster após transição do AWS Academy Lab

Data: Sat May 23 04:41:26 PM -03 2026

## Objetivo

Estabilizar o cluster EKS antes de retomar Loki/Promtail.

O checkpoint anterior mostrou nodes antigos em `NotReady,SchedulingDisabled`, taints de `shutdown/unreachable` e muitos pods em `Terminating`. Este bloco faz inventário seguro e remove apenas objetos Node órfãos quando houver confirmação de que o node não deve mais participar do cluster.


## AWS identity

```text
------------------------------------------------------------------------------------------------
|                                       GetCallerIdentity                                      |
+---------+------------------------------------------------------------------------------------+
|  Account|  590183666984                                                                      |
|  Arn    |  arn:aws:sts::590183666984:assumed-role/voclabs/user4447841=wellk.well@gmail.com   |
|  UserId |  AROAYS2NQCUUFEE2UOXGE:user4447841=wellk.well@gmail.com                            |
+---------+------------------------------------------------------------------------------------+
```

RC: `0`

## Update kubeconfig

```text
Updated context arn:aws:eks:us-east-1:590183666984:cluster/togglemaster-dev-eks in /home/wellk/.kube/config
```

RC: `0`

## Nodes iniciais

```text
NAME                           STATUS                        ROLES    AGE     VERSION                INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-10-34-177.ec2.internal   Ready                         <none>   11m     v1.30.14-eks-7fcd7ec   10.10.34.177   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-37-16.ec2.internal    Ready                         <none>   10m     v1.30.14-eks-7fcd7ec   10.10.37.16    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-40-95.ec2.internal    NotReady,SchedulingDisabled   <none>   13h     v1.30.14-eks-7fcd7ec   10.10.40.95    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-45-215.ec2.internal   NotReady,SchedulingDisabled   <none>   94m     v1.30.14-eks-7fcd7ec   10.10.45.215   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-48-118.ec2.internal   NotReady,SchedulingDisabled   <none>   93m     v1.30.14-eks-7fcd7ec   10.10.48.118   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-49-137.ec2.internal   NotReady,SchedulingDisabled   <none>   13h     v1.30.14-eks-7fcd7ec   10.10.49.137   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-50-171.ec2.internal   NotReady,SchedulingDisabled   <none>   94m     v1.30.14-eks-7fcd7ec   10.10.50.171   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-51-233.ec2.internal   Ready                         <none>   7m53s   v1.30.14-eks-7fcd7ec   10.10.51.233   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-57-245.ec2.internal   NotReady,SchedulingDisabled   <none>   118s    v1.30.14-eks-7fcd7ec   10.10.57.245   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-59-138.ec2.internal   Ready                         <none>   6m3s    v1.30.14-eks-7fcd7ec   10.10.59.138   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
```

RC: `0`

## Applications ArgoCD iniciais

```text
NAME                                  SYNC STATUS   HEALTH STATUS
observability-dashboards              Synced        Healthy
observability-kube-prometheus-stack   Synced        Healthy
observability-loki                    OutOfSync     Progressing
observability-namespace               Synced        Healthy
togglemaster-dev                      Synced        Healthy
```

RC: `0`

## Pods problemáticos iniciais

```text
argocd          argocd-application-controller-0                             1/1     Terminating         0               13h     10.10.53.215   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd          argocd-applicationset-controller-5b964db9cd-rl8kn           1/1     Terminating         0               13h     10.10.58.145   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd          argocd-dex-server-b8cc6d795-r658p                           1/1     Terminating         0               13h     10.10.50.38    ip-10-10-49-137.ec2.internal   <none>           <none>
argocd          argocd-notifications-controller-597cccd4ff-q2p2l            1/1     Terminating         0               13h     10.10.49.102   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd          argocd-redis-675f9c4c99-ngqb4                               1/1     Terminating         0               13h     10.10.32.229   ip-10-10-40-95.ec2.internal    <none>           <none>
argocd          argocd-repo-server-5c46694888-b4bqj                         1/1     Terminating         0               13h     10.10.43.108   ip-10-10-40-95.ec2.internal    <none>           <none>
argocd          argocd-server-7f66865588-df8sl                              1/1     Terminating         0               13h     10.10.56.210   ip-10-10-49-137.ec2.internal   <none>           <none>
kube-system     coredns-849f74687b-lg2g2                                    1/1     Terminating         0               13h     10.10.45.165   ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system     coredns-849f74687b-sqcpd                                    1/1     Terminating         0               13h     10.10.41.233   ip-10-10-40-95.ec2.internal    <none>           <none>
observability   alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Terminating         0               66m     10.10.61.84    ip-10-10-48-118.ec2.internal   <none>           <none>
observability   kube-prometheus-stack-grafana-7b6c9657c7-c7prc              3/3     Terminating         0               16m     10.10.61.62    ip-10-10-48-118.ec2.internal   <none>           <none>
observability   kube-prometheus-stack-kube-state-metrics-64659c7c5c-dz2zx   1/1     Terminating         0               67m     10.10.55.108   ip-10-10-50-171.ec2.internal   <none>           <none>
observability   kube-prometheus-stack-operator-8564f47cff-f99bt             1/1     Terminating         0               67m     10.10.55.47    ip-10-10-48-118.ec2.internal   <none>           <none>
observability   loki-0                                                      1/2     Terminating         5 (14m ago)     17m     10.10.59.120   ip-10-10-50-171.ec2.internal   <none>           <none>
observability   loki-chunks-cache-0                                         0/2     Pending             0               18m     <none>         <none>                         <none>           <none>
observability   loki-results-cache-0                                        2/2     Terminating         0               17m     10.10.34.88    ip-10-10-45-215.ec2.internal   <none>           <none>
observability   prometheus-kube-prometheus-stack-prometheus-0               2/2     Terminating         0               66m     10.10.52.90    ip-10-10-50-171.ec2.internal   <none>           <none>
togglemaster    analytics-service-6946467b6b-9fvmm                          1/1     Terminating         0               149m    10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster    auth-service-584688f79d-2v6sh                               1/1     Terminating         0               50m     10.10.34.34    ip-10-10-45-215.ec2.internal   <none>           <none>
togglemaster    auth-service-584688f79d-xt6v8                               1/1     Terminating         0               13h     10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster    evaluation-service-7949b95dd5-jkwhj                         1/1     Terminating         0               50m     10.10.57.117   ip-10-10-48-118.ec2.internal   <none>           <none>
togglemaster    evaluation-service-7949b95dd5-wbrlc                         1/1     Terminating         0               148m    10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster    flag-service-7cd69f6bf9-9ffxm                               1/1     Terminating         0               13h     10.10.35.34    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster    flag-service-7cd69f6bf9-x7pxc                               1/1     Terminating         0               13h     10.10.55.41    ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster    targeting-service-66d4bb78b6-7zc9d                          1/1     Terminating         0               13h     10.10.48.76    ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster    targeting-service-66d4bb78b6-8tw7t                          1/1     Terminating         0               13h     10.10.41.90    ip-10-10-40-95.ec2.internal    <none>           <none>
```

RC: `0`

## Inventário Kubernetes nodes

```text
node	ready	unschedulable	shutdown_taint	unreachable_taint	instance_id	provider_id
ip-10-10-34-177.ec2.internal	True	false	false	false	i-0cb62781c3eeb3961	aws:///us-east-1a/i-0cb62781c3eeb3961
ip-10-10-37-16.ec2.internal	True	false	false	false	i-0b1241c4605a5fa6a	aws:///us-east-1a/i-0b1241c4605a5fa6a
ip-10-10-40-95.ec2.internal	Unknown	true	true	true	i-0824b8c0e9bfa49ff	aws:///us-east-1a/i-0824b8c0e9bfa49ff
ip-10-10-45-215.ec2.internal	Unknown	true	true	true	i-0ac2d087b87cd8ebc	aws:///us-east-1a/i-0ac2d087b87cd8ebc
ip-10-10-48-118.ec2.internal	Unknown	true	true	true	i-0bfeb521d5b7a67f0	aws:///us-east-1b/i-0bfeb521d5b7a67f0
ip-10-10-49-137.ec2.internal	Unknown	true	true	true	i-07656201652bcabd3	aws:///us-east-1b/i-07656201652bcabd3
ip-10-10-50-171.ec2.internal	Unknown	true	true	true	i-04172a53d17c77da3	aws:///us-east-1b/i-04172a53d17c77da3
ip-10-10-51-233.ec2.internal	True	false	false	false	i-0be3da855ce06a981	aws:///us-east-1b/i-0be3da855ce06a981
ip-10-10-55-83.ec2.internal	False	false	false	false	i-05600cfd3335d5d9c	aws:///us-east-1b/i-05600cfd3335d5d9c
ip-10-10-57-245.ec2.internal	Unknown	true	false	true	i-0a72318b8b02d83a5	aws:///us-east-1b/i-0a72318b8b02d83a5
ip-10-10-59-138.ec2.internal	True	false	false	false	i-0663f6e7f2e77b9ef	aws:///us-east-1b/i-0663f6e7f2e77b9ef
```

## Inventário EC2 das instâncias associadas aos nodes

```text
instance_id	private_dns	private_ip	state
i-0ac2d087b87cd8ebc	ip-10-10-45-215.ec2.internal	10.10.45.215	stopped
i-07656201652bcabd3	ip-10-10-49-137.ec2.internal	10.10.49.137	stopped
i-0a72318b8b02d83a5		None	terminated
i-0663f6e7f2e77b9ef	ip-10-10-59-138.ec2.internal	10.10.59.138	running
i-0bfeb521d5b7a67f0	ip-10-10-48-118.ec2.internal	10.10.48.118	stopped
i-04172a53d17c77da3	ip-10-10-50-171.ec2.internal	10.10.50.171	stopped
i-0be3da855ce06a981	ip-10-10-51-233.ec2.internal	10.10.51.233	running
i-05600cfd3335d5d9c	ip-10-10-55-83.ec2.internal	10.10.55.83	shutting-down
i-0824b8c0e9bfa49ff	ip-10-10-40-95.ec2.internal	10.10.40.95	stopped
i-0cb62781c3eeb3961	ip-10-10-34-177.ec2.internal	10.10.34.177	running
i-0b1241c4605a5fa6a	ip-10-10-37-16.ec2.internal	10.10.37.16	running
```

## Nodes selecionados para remoção segura

```text
ip-10-10-40-95.ec2.internal
ip-10-10-45-215.ec2.internal
ip-10-10-48-118.ec2.internal
ip-10-10-49-137.ec2.internal
ip-10-10-50-171.ec2.internal
ip-10-10-57-245.ec2.internal
```

## Nodes após limpeza

```text
NAME                           STATUS     ROLES    AGE     VERSION                INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-10-34-177.ec2.internal   Ready      <none>   12m     v1.30.14-eks-7fcd7ec   10.10.34.177   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-37-16.ec2.internal    Ready      <none>   10m     v1.30.14-eks-7fcd7ec   10.10.37.16    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-51-233.ec2.internal   Ready      <none>   8m26s   v1.30.14-eks-7fcd7ec   10.10.51.233   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-55-83.ec2.internal    NotReady   <none>   31s     v1.30.14-eks-7fcd7ec   10.10.55.83    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-59-138.ec2.internal   Ready      <none>   6m36s   v1.30.14-eks-7fcd7ec   10.10.59.138   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
```

RC: `0`

## Pods problemáticos após limpeza

```text
argocd          argocd-application-controller-0                             1/1     Terminating       0               13h     10.10.53.215   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd          argocd-applicationset-controller-5b964db9cd-rl8kn           1/1     Terminating       0               13h     10.10.58.145   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd          argocd-dex-server-b8cc6d795-r658p                           1/1     Terminating       0               13h     10.10.50.38    ip-10-10-49-137.ec2.internal   <none>           <none>
argocd          argocd-notifications-controller-597cccd4ff-q2p2l            1/1     Terminating       0               13h     10.10.49.102   ip-10-10-49-137.ec2.internal   <none>           <none>
argocd          argocd-redis-675f9c4c99-ngqb4                               1/1     Terminating       0               13h     10.10.32.229   ip-10-10-40-95.ec2.internal    <none>           <none>
argocd          argocd-repo-server-5c46694888-b4bqj                         1/1     Terminating       0               13h     10.10.43.108   ip-10-10-40-95.ec2.internal    <none>           <none>
argocd          argocd-server-7f66865588-df8sl                              1/1     Terminating       0               13h     10.10.56.210   ip-10-10-49-137.ec2.internal   <none>           <none>
kube-system     coredns-849f74687b-lg2g2                                    1/1     Terminating       0               13h     10.10.45.165   ip-10-10-40-95.ec2.internal    <none>           <none>
kube-system     coredns-849f74687b-sqcpd                                    1/1     Terminating       0               13h     10.10.41.233   ip-10-10-40-95.ec2.internal    <none>           <none>
observability   alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Terminating       0               67m     10.10.61.84    ip-10-10-48-118.ec2.internal   <none>           <none>
observability   kube-prometheus-stack-grafana-7b6c9657c7-c7prc              3/3     Terminating       0               16m     10.10.61.62    ip-10-10-48-118.ec2.internal   <none>           <none>
observability   kube-prometheus-stack-kube-state-metrics-64659c7c5c-dz2zx   1/1     Terminating       0               67m     10.10.55.108   ip-10-10-50-171.ec2.internal   <none>           <none>
observability   kube-prometheus-stack-operator-8564f47cff-f99bt             1/1     Terminating       0               67m     10.10.55.47    ip-10-10-48-118.ec2.internal   <none>           <none>
observability   loki-0                                                      1/2     Terminating       5 (14m ago)     17m     10.10.59.120   ip-10-10-50-171.ec2.internal   <none>           <none>
observability   loki-chunks-cache-0                                         0/2     Pending           0               18m     <none>         <none>                         <none>           <none>
observability   loki-results-cache-0                                        2/2     Terminating       0               18m     10.10.34.88    ip-10-10-45-215.ec2.internal   <none>           <none>
observability   prometheus-kube-prometheus-stack-prometheus-0               2/2     Terminating       0               67m     10.10.52.90    ip-10-10-50-171.ec2.internal   <none>           <none>
togglemaster    analytics-service-6946467b6b-9fvmm                          1/1     Terminating       0               150m    10.10.34.64    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster    auth-service-584688f79d-2v6sh                               1/1     Terminating       0               51m     10.10.34.34    ip-10-10-45-215.ec2.internal   <none>           <none>
togglemaster    auth-service-584688f79d-xt6v8                               1/1     Terminating       0               13h     10.10.54.108   ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster    evaluation-service-7949b95dd5-jkwhj                         1/1     Terminating       0               51m     10.10.57.117   ip-10-10-48-118.ec2.internal   <none>           <none>
togglemaster    evaluation-service-7949b95dd5-wbrlc                         1/1     Terminating       0               149m    10.10.37.48    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster    flag-service-7cd69f6bf9-9ffxm                               1/1     Terminating       0               13h     10.10.35.34    ip-10-10-40-95.ec2.internal    <none>           <none>
togglemaster    flag-service-7cd69f6bf9-x7pxc                               1/1     Terminating       0               13h     10.10.55.41    ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster    targeting-service-66d4bb78b6-7zc9d                          1/1     Terminating       0               13h     10.10.48.76    ip-10-10-49-137.ec2.internal   <none>           <none>
togglemaster    targeting-service-66d4bb78b6-8tw7t                          1/1     Terminating       0               13h     10.10.41.90    ip-10-10-40-95.ec2.internal    <none>           <none>
```

RC: `0`

## Applications após limpeza

```text
NAME                                  SYNC STATUS   HEALTH STATUS
observability-dashboards              Synced        Healthy
observability-kube-prometheus-stack   Synced        Healthy
observability-loki                    OutOfSync     Progressing
observability-namespace               Synced        Healthy
togglemaster-dev                      Synced        Healthy
```

RC: `0`

## Contagem final de nodes

```text
READY_COUNT=4
TOTAL_COUNT=5
```

## Resultado

- Credenciais AWS/EKS validadas.
- Nodes inventariados e comparados com EC2.
- Objetos Node órfãos removidos apenas quando seguro.
- Cluster estabilizado para nova tentativa de diagnóstico Loki.
- Próximo passo: diagnosticar  e corrigir values/ArgoCD antes de aplicar Promtail.
