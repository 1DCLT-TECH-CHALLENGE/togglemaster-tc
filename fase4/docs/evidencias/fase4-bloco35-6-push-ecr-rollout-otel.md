# Fase 4 - BLOCO 35.6 - Push ECR e rollout GitOps das imagens OTEL

Data: Sat May 23 06:24:49 PM -03 2026

## Objetivo
Publicar as imagens instrumentadas no ECR, atualizar GitOps e validar rollout no EKS.

## Tag publicada
otel-b4f0b5c

## Repositórios usados
```text
evaluation-service	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
flag-service	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
targeting-service	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
```

## Manifests atualizados
```text
fase3/gitops/base/evaluation-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:otel-b4f0b5c
fase3/gitops/base/flag-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:otel-b4f0b5c
fase3/gitops/base/targeting-service.yaml:27:          image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c
```

## Validação Kustomize
```text
285:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:otel-b4f0b5c
340:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:otel-b4f0b5c
395:        image: 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c
```

## Resultado runtime
```text
NAME               SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
togglemaster-dev   Synced        Healthy         6612b9090c3ca9f1683c39e2ec380a381ae3211b   default
NAME                                  READY   STATUS    RESTARTS       AGE    IP             NODE                           NOMINATED NODE   READINESS GATES
evaluation-service-57d59f7b64-sl594   1/1     Running   0              44s    10.10.39.50    ip-10-10-34-177.ec2.internal   <none>           <none>
evaluation-service-57d59f7b64-vfjlq   1/1     Running   0              64s    10.10.49.149   ip-10-10-51-233.ec2.internal   <none>           <none>
flag-service-6d964dcffb-fxtgh         1/1     Running   0              64s    10.10.55.176   ip-10-10-61-91.ec2.internal    <none>           <none>
flag-service-6d964dcffb-rb47f         1/1     Running   0              44s    10.10.36.164   ip-10-10-34-177.ec2.internal   <none>           <none>
targeting-service-599dc5ffd-28pwg     1/1     Running   0              44s    10.10.34.105   ip-10-10-37-16.ec2.internal    <none>           <none>
targeting-service-599dc5ffd-ftkhh     1/1     Running   0              64s    10.10.60.165   ip-10-10-59-138.ec2.internal   <none>           <none>

evaluation-service-57d59f7b64-sl594 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:otel-b4f0b5c 
evaluation-service-57d59f7b64-vfjlq 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:otel-b4f0b5c 
flag-service-6d964dcffb-fxtgh 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:otel-b4f0b5c 
flag-service-6d964dcffb-rb47f 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:otel-b4f0b5c 
targeting-service-599dc5ffd-28pwg 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c 
targeting-service-599dc5ffd-ftkhh 590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c 
```

## Resultado final
- ArgoCD Application: Synced/Healthy
- Pods com tag otel-b4f0b5c: 6
