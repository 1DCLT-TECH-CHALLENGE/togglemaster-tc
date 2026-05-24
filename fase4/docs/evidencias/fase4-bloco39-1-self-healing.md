# Fase 4 - BLOCO 39.1 - Self-healing controlado

Data: Sat May 23 10:07:21 PM -03 2026

## Objetivo
Demonstrar uma ação corretiva automatizada de self-healing, reduzindo o MTTR por meio de um rollout restart controlado e validação automática de recuperação.

## Estratégia
Foi criado um script operacional de self-healing que identifica o deployment alvo, registra o estado antes da ação, executa `kubectl rollout restart`, aguarda o `rollout status` e valida que os pods retornaram ao estado Running/Ready.

## Deployment alvo
```text
Namespace: togglemaster
Deployment: targeting-service
```

## Execução do self-healing
```text
============================================================
SELF-HEALING - ROLLOUT RESTART CONTROLADO
============================================================
Namespace: togglemaster
Deployment alvo: targeting-service
Data: Sat May 23 10:06:36 PM -03 2026

[1/7] Estado do deployment antes
NAME                READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS          IMAGES                                                                                         SELECTOR
targeting-service   2/2     2            2           20h   targeting-service   590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c   app.kubernetes.io/name=targeting-service

[2/7] Pods antes

[3/7] Validando réplicas disponíveis antes da ação
DESIRED=2
AVAILABLE_BEFORE=2

[4/7] Executando ação corretiva: kubectl rollout restart
deployment.apps/targeting-service restarted

[5/7] Aguardando recuperação do rollout
Waiting for deployment "targeting-service" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "targeting-service" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "targeting-service" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "targeting-service" rollout to finish: 1 of 2 updated replicas are available...
deployment "targeting-service" successfully rolled out

[6/7] Estado do deployment depois
NAME                READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS          IMAGES                                                                                         SELECTOR
targeting-service   2/2     2            2           20h   targeting-service   590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c   app.kubernetes.io/name=targeting-service

[7/7] Pods depois

DESIRED=2
AVAILABLE_AFTER=2
UPDATED_AFTER=2

SELF_HEALING_RESULT=SUCCESS
Ação corretiva executada e deployment recuperado.
```

## Pods antes
```text
```

## Pods depois
```text
```

## ReplicaSets antes
```text
NAME                            DESIRED   CURRENT   READY   AGE
targeting-service-599dc5ffd     2         2         2       3h41m
targeting-service-66d4bb78b6    0         0         0       20h
targeting-service-f87cdc465     0         0         0       3h56m
```

## ReplicaSets depois
```text
NAME                            DESIRED   CURRENT   READY   AGE
targeting-service-599dc5ffd     0         0         0       3h42m
targeting-service-66d4bb78b6    0         0         0       20h
targeting-service-6bf8db4c76    2         2         2       37s
targeting-service-f87cdc465     0         0         0       3h57m
```

## Eventos recentes
```text
LAST SEEN   TYPE      REASON              OBJECT                                    MESSAGE
40s         Normal    ScalingReplicaSet   deployment/targeting-service              Scaled up replica set targeting-service-6bf8db4c76 to 1 from 0
40s         Normal    ScalingReplicaSet   deployment/targeting-service              Scaled down replica set targeting-service-599dc5ffd to 1 from 2
40s         Normal    SuccessfulDelete    replicaset/targeting-service-599dc5ffd    Deleted pod: targeting-service-599dc5ffd-8xttp
40s         Normal    SuccessfulCreate    replicaset/targeting-service-6bf8db4c76   Created pod: targeting-service-6bf8db4c76-q4lc8
40s         Normal    Killing             pod/targeting-service-599dc5ffd-8xttp     Stopping container targeting-service
40s         Normal    Scheduled           pod/targeting-service-6bf8db4c76-q4lc8    Successfully assigned togglemaster/targeting-service-6bf8db4c76-q4lc8 to ip-10-10-46-233.ec2.internal
39s         Normal    Pulling             pod/targeting-service-6bf8db4c76-q4lc8    Pulling image "590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c"
34s         Normal    Started             pod/targeting-service-6bf8db4c76-q4lc8    Started container targeting-service
34s         Normal    Created             pod/targeting-service-6bf8db4c76-q4lc8    Created container: targeting-service
34s         Normal    Pulled              pod/targeting-service-6bf8db4c76-q4lc8    Successfully pulled image "590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c" in 5.432s (5.432s including waiting). Image size: 145282450 bytes.
20s         Normal    Scheduled           pod/targeting-service-6bf8db4c76-bz74d    Successfully assigned togglemaster/targeting-service-6bf8db4c76-bz74d to ip-10-10-56-28.ec2.internal
20s         Normal    SuccessfulDelete    replicaset/targeting-service-599dc5ffd    Deleted pod: targeting-service-599dc5ffd-g2llf
20s         Normal    SuccessfulCreate    replicaset/targeting-service-6bf8db4c76   Created pod: targeting-service-6bf8db4c76-bz74d
20s         Normal    Killing             pod/targeting-service-599dc5ffd-g2llf     Stopping container targeting-service
20s         Normal    ScalingReplicaSet   deployment/targeting-service              Scaled down replica set targeting-service-599dc5ffd to 0 from 1
20s         Normal    ScalingReplicaSet   deployment/targeting-service              Scaled up replica set targeting-service-6bf8db4c76 to 2 from 1
19s         Normal    Started             pod/targeting-service-6bf8db4c76-bz74d    Started container targeting-service
19s         Normal    Created             pod/targeting-service-6bf8db4c76-bz74d    Created container: targeting-service
19s         Normal    Pulled              pod/targeting-service-6bf8db4c76-bz74d    Container image "590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:otel-b4f0b5c" already present on machine
19s         Warning   Unhealthy           pod/targeting-service-599dc5ffd-g2llf     Readiness probe failed: Get "http://10.10.47.38:8000/health": dial tcp 10.10.47.38:8000: connect: connection refused
```

## Resultado
O self-healing foi executado com sucesso. O deployment alvo passou por rollout restart controlado, o Kubernetes recriou os pods e o rollout finalizou com sucesso, mantendo o serviço operacional.

## Figura associada
Figura 13 – Execução do self-healing demonstrando ação corretiva, rollout restart e recuperação dos pods.
