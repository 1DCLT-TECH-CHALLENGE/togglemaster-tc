# Fase 4 - BLOCO 33.4 - Estabilização do cluster após transição do AWS Academy Lab

Data: Sat May 23 04:42:44 PM -03 2026

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
NAME                           STATUS     ROLES    AGE     VERSION                INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-10-34-177.ec2.internal   Ready      <none>   13m     v1.30.14-eks-7fcd7ec   10.10.34.177   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-37-16.ec2.internal    Ready      <none>   11m     v1.30.14-eks-7fcd7ec   10.10.37.16    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-51-233.ec2.internal   Ready      <none>   9m11s   v1.30.14-eks-7fcd7ec   10.10.51.233   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-55-83.ec2.internal    NotReady   <none>   76s     v1.30.14-eks-7fcd7ec   10.10.55.83    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-59-138.ec2.internal   Ready      <none>   7m21s   v1.30.14-eks-7fcd7ec   10.10.59.138   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
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
observability   loki-0                                                      1/2     CrashLoopBackOff   1 (3s ago)      9s      10.10.63.6     ip-10-10-51-233.ec2.internal   <none>           <none>
observability   loki-chunks-cache-0                                         0/2     Pending            0               19m     <none>         <none>                         <none>           <none>
```

RC: `0`

## Inventário Kubernetes nodes

```text
node	ready	unschedulable	shutdown_taint	unreachable_taint	instance_id	provider_id
ip-10-10-34-177.ec2.internal	True	false	false	false	i-0cb62781c3eeb3961	aws:///us-east-1a/i-0cb62781c3eeb3961
ip-10-10-37-16.ec2.internal	True	false	false	false	i-0b1241c4605a5fa6a	aws:///us-east-1a/i-0b1241c4605a5fa6a
ip-10-10-51-233.ec2.internal	True	false	false	false	i-0be3da855ce06a981	aws:///us-east-1b/i-0be3da855ce06a981
ip-10-10-55-83.ec2.internal	Unknown	false	false	true	i-05600cfd3335d5d9c	aws:///us-east-1b/i-05600cfd3335d5d9c
ip-10-10-59-138.ec2.internal	True	false	false	false	i-0663f6e7f2e77b9ef	aws:///us-east-1b/i-0663f6e7f2e77b9ef
```

## Inventário EC2 das instâncias associadas aos nodes

```text
instance_id	private_dns	private_ip	state
i-0663f6e7f2e77b9ef	ip-10-10-59-138.ec2.internal	10.10.59.138	running
i-0be3da855ce06a981	ip-10-10-51-233.ec2.internal	10.10.51.233	running
i-05600cfd3335d5d9c		None	terminated
i-0cb62781c3eeb3961	ip-10-10-34-177.ec2.internal	10.10.34.177	running
i-0b1241c4605a5fa6a	ip-10-10-37-16.ec2.internal	10.10.37.16	running
```

## Nodes selecionados para remoção segura

```text
Nenhum node órfão selecionado.
```

## Nodes após limpeza

```text
NAME                           STATUS                        ROLES    AGE     VERSION                INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-10-34-177.ec2.internal   Ready                         <none>   13m     v1.30.14-eks-7fcd7ec   10.10.34.177   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-37-16.ec2.internal    Ready                         <none>   11m     v1.30.14-eks-7fcd7ec   10.10.37.16    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-51-233.ec2.internal   Ready                         <none>   9m37s   v1.30.14-eks-7fcd7ec   10.10.51.233   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-55-83.ec2.internal    NotReady,SchedulingDisabled   <none>   102s    v1.30.14-eks-7fcd7ec   10.10.55.83    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-59-138.ec2.internal   Ready                         <none>   7m47s   v1.30.14-eks-7fcd7ec   10.10.59.138   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
```

RC: `0`

## Pods problemáticos após limpeza

```text
observability   loki-0                                                      1/2     CrashLoopBackOff    2 (7s ago)      34s     10.10.63.6     ip-10-10-51-233.ec2.internal   <none>           <none>
observability   loki-chunks-cache-0                                         0/2     Pending             0               19m     <none>         <none>                         <none>           <none>
```

RC: `0`

## Applications após limpeza

```text
NAME                                  SYNC STATUS   HEALTH STATUS
observability-dashboards              Synced        Healthy
observability-kube-prometheus-stack   OutOfSync     Healthy
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
