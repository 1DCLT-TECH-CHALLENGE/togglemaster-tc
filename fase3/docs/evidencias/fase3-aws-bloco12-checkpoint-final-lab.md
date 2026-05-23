# Fase 3 - AWS Academy - BLOCO AWS-12 - Checkpoint final antes de pausar Lab

Data: 2026-05-22

## Objetivo

Registrar o estado final saudável da infraestrutura AWS antes de pausar o Lab.

## Git

```text
On branch main
Your branch is up to date with 'origin/main'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	fase3/docs/evidencias/fase3-aws-bloco12-checkpoint-final-lab.md

nothing added to commit but untracked files present (use "git add" to track)

81425cc (HEAD -> main, origin/main) docs: record phase 3 post nodegroup drift check
694e1d7 fix: pin eks nodegroup launch template version to latest
d63bdc4 docs: record post nodegroup sanity check
f5d7e80 docs: record fixed eks nodegroup validation
03b349b fix: attach eks cluster sg to managed node launch template
```

## Identidade AWS

```json
{
    "UserId": "AROAYS2NQCUUFEE2UOXGE:user4447841=wellk.well@gmail.com",
    "Account": "590183666984",
    "Arn": "arn:aws:sts::590183666984:assumed-role/voclabs/user4447841=wellk.well@gmail.com"
}
```

## EKS cluster

```text
------------------------------------------------------------------------------------------
|                                     DescribeCluster                                    |
+----------+-----------------------------------------------------------------------------+
|  endpoint|  https://47AAFA7006C0C5399AC8F2CE4704EEC7.gr7.us-east-1.eks.amazonaws.com   |
|  name    |  togglemaster-dev-eks                                                       |
|  status  |  ACTIVE                                                                     |
+----------+-----------------------------------------------------------------------------+
```

## EKS node group

```text
-------------------------------------------
|            DescribeNodegroup            |
+-------------------------------+---------+
|             name              | status  |
+-------------------------------+---------+
|  togglemaster-dev-default-ng  |  ACTIVE |
+-------------------------------+---------+
||             instanceTypes             ||
|+---------------------------------------+|
||  t3.small                             ||
|+---------------------------------------+|
||                scaling                ||
|+---------------+-----------+-----------+|
||  desiredSize  |  maxSize  |  minSize  ||
|+---------------+-----------+-----------+|
||  2            |  3        |  1        ||
|+---------------+-----------+-----------+|
```

## Kubernetes nodes

```text
NAME                           STATUS   ROLES    AGE   VERSION                INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                    CONTAINER-RUNTIME
ip-10-10-43-135.ec2.internal   Ready    <none>   59m   v1.30.14-eks-7fcd7ec   10.10.43.135   <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
ip-10-10-54-77.ec2.internal    Ready    <none>   59m   v1.30.14-eks-7fcd7ec   10.10.54.77    <none>        Amazon Linux 2023.11.20260509   6.1.170-210.320.amzn2023.x86_64   containerd://2.2.3+unknown
```

## kube-system

```text
NAME                       READY   STATUS    RESTARTS   AGE    IP             NODE                           NOMINATED NODE   READINESS GATES
aws-node-7qhv4             2/2     Running   0          59m    10.10.43.135   ip-10-10-43-135.ec2.internal   <none>           <none>
aws-node-8p5c2             2/2     Running   0          59m    10.10.54.77    ip-10-10-54-77.ec2.internal    <none>           <none>
coredns-849f74687b-225zs   1/1     Running   0          157m   10.10.39.107   ip-10-10-43-135.ec2.internal   <none>           <none>
coredns-849f74687b-rcg5g   1/1     Running   0          157m   10.10.42.41    ip-10-10-43-135.ec2.internal   <none>           <none>
kube-proxy-6t2zh           1/1     Running   0          59m    10.10.54.77    ip-10-10-54-77.ec2.internal    <none>           <none>
kube-proxy-vr8fw           1/1     Running   0          59m    10.10.43.135   ip-10-10-43-135.ec2.internal   <none>           <none>
```

## Status

Checkpoint final registrado com infraestrutura saudável antes de pausar o Lab.
