# Fase 4 - BLOCO 33.2 - Loki em modo leve

Data: Sat May 23 08:00:52 PM -03 2026

## Objetivo

Corrigir definitivamente a configuração do Loki para um perfil leve no AWS Academy, removendo caches/memcached que causaram pressão de memória/pods e impediam a Application de ficar Healthy.

Este bloco também corrige o erro de parsing de versão Helm observado no BLOCO 33.1.


## Estado antes da correção

```text
 M fase4/docs/evidencias/fase4-bloco23-inventario-stack.md
 M fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md
 M fase4/docs/evidencias/fase4-bloco25-plano-correcao-capacidade.md
 M fase4/docs/evidencias/fase4-bloco26-iac-capacidade-eks.md
 M fase4/docs/evidencias/fase4-bloco27-terraform-plan-capacidade-eks.md
 M fase4/docs/evidencias/fase4-bloco28-terraform-apply-capacidade-eks.md
 M fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md
 M fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md
 M fase4/docs/evidencias/fase4-bloco31-grafana-access.md
 M fase4/docs/evidencias/fase4-bloco32-grafana-dashboard-customizado.md
 M fase4/docs/evidencias/fase4-bloco33-10-loki-writable-final.md
 M fase4/docs/evidencias/fase4-bloco33-12-promtail-logs-loki.md
 M fase4/docs/evidencias/fase4-bloco33-2-loki-light-mode-v2.md
NAME                 SYNC STATUS   HEALTH STATUS   REVISION   PROJECT
observability-loki   Synced        Progressing                default
NAME                                                        READY   STATUS    RESTARTS      AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
loki-0                                                      2/2     Running   0             85s     10.10.59.54    ip-10-10-61-91.ec2.internal    <none>           <none>
```

## Logs Loki antes da correção

```text
level=info ts=2026-05-23T22:59:33.518143365Z caller=main.go:133 msg="Starting Loki" version="(version=3.6.7, branch=release-3.6.x, revision=7e1daf3a)"
level=info ts=2026-05-23T22:59:33.518203738Z caller=main.go:134 msg="Loading configuration file" filename=/etc/loki/config/config.yaml
level=info ts=2026-05-23T22:59:33.521526619Z caller=server.go:386 msg="server listening on addresses" http=[::]:3100 grpc=[::]:9095
level=info ts=2026-05-23T22:59:33.526366232Z caller=memberlist_client.go:484 msg="Using memberlist cluster label and node name" cluster_label= node=loki-0-6f2a3481
level=info ts=2026-05-23T22:59:33.526764992Z caller=memberlist_client.go:628 msg="memberlist fast-join starting" nodes_found=1 to_join=4
ts=2026-05-23T22:59:33.536971894Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=info ts=2026-05-23T22:59:33.537002434Z caller=memberlist_client.go:634 msg="fast-joining node failed" node=loki-memberlist.observability.svc.cluster.local err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=warn ts=2026-05-23T22:59:33.537018888Z caller=memberlist_client.go:644 msg="memberlist fast-join failed because no node has been successfully reached" elapsed_time=10.25705ms
level=error ts=2026-05-23T22:59:33.537031881Z caller=memberlist_client.go:521 msg="failed to fast-join the memberlist cluster at startup" err="no memberlist node reached during fast-join procedure"
level=info ts=2026-05-23T22:59:33.537043893Z caller=memberlist_client.go:666 phase=startup msg="joining memberlist cluster" join_members=loki-memberlist.observability.svc.cluster.local
level=info ts=2026-05-23T22:59:33.541330388Z caller=table_manager.go:300 index-store=tsdb-2024-01-01 msg="query readiness setup completed" duration=4.197µs distinct_users_len=0 distinct_users=
level=info ts=2026-05-23T22:59:33.541376401Z caller=shipper.go:165 index-store=tsdb-2024-01-01 msg="starting index shipper in RW mode"
level=info ts=2026-05-23T22:59:33.541791608Z caller=table_manager.go:136 index-store=tsdb-2024-01-01 msg="uploading tables"
level=info ts=2026-05-23T22:59:33.541871797Z caller=head_manager.go:313 index-store=tsdb-2024-01-01 component=tsdb-head-manager msg="loaded wals by period" groups=0
level=info ts=2026-05-23T22:59:33.54192522Z caller=manager.go:86 index-store=tsdb-2024-01-01 component=tsdb-manager msg="loaded leftover local indices" err=null successful=true buckets=0 indices=0 failures=0
level=info ts=2026-05-23T22:59:33.541955174Z caller=head_manager.go:313 index-store=tsdb-2024-01-01 component=tsdb-head-manager msg="loaded wals by period" groups=0
level=info ts=2026-05-23T22:59:33.547105928Z caller=mapper.go:47 msg="cleaning up mapped rules directory" path=/var/loki/rules-temp
level=info ts=2026-05-23T22:59:33.549791716Z caller=worker.go:134 component=querier msg="Starting querier worker using query-scheduler and scheduler ring for addresses"
ts=2026-05-23T22:59:33.556703212Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T22:59:33.556731596Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=1 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T22:59:33.578437524Z caller=module_service.go:82 msg=starting module=server
level=info ts=2026-05-23T22:59:33.578806896Z caller=module_service.go:82 msg=starting module=cache-generation-loader
level=info ts=2026-05-23T22:59:33.578881054Z caller=module_service.go:82 msg=starting module=runtime-config
level=info ts=2026-05-23T22:59:33.579700948Z caller=module_service.go:82 msg=starting module=query-frontend-tripperware
level=info ts=2026-05-23T22:59:33.579729048Z caller=module_service.go:82 msg=starting module=memberlist-kv
level=info ts=2026-05-23T22:59:33.579799432Z caller=module_service.go:82 msg=starting module=store
level=info ts=2026-05-23T22:59:33.579824729Z caller=module_service.go:82 msg=starting module=query-scheduler-ring
level=info ts=2026-05-23T22:59:33.579889599Z caller=ring.go:365 msg="ring doesn't exist in KV store yet"
level=info ts=2026-05-23T22:59:33.579939445Z caller=basic_lifecycler.go:321 msg="instance not found in the ring" instance=loki-0 ring=scheduler
level=info ts=2026-05-23T22:59:33.579981535Z caller=basic_lifecycler_delegates.go:63 msg="not loading tokens from file, tokens file path is empty"
level=info ts=2026-05-23T22:59:33.580196851Z caller=ringmanager.go:186 msg="waiting until scheduler is JOINING in the ring"
level=info ts=2026-05-23T22:59:33.580207589Z caller=ringmanager.go:190 msg="scheduler is JOINING in the ring"
level=info ts=2026-05-23T22:59:33.580582082Z caller=module_service.go:82 msg=starting module=ring
level=info ts=2026-05-23T22:59:33.580607193Z caller=ring.go:365 msg="ring doesn't exist in KV store yet"
level=info ts=2026-05-23T22:59:33.580656283Z caller=module_service.go:82 msg=starting module=analytics
level=info ts=2026-05-23T22:59:33.580891373Z caller=module_service.go:82 msg=starting module=ingester-querier
level=info ts=2026-05-23T22:59:33.580921012Z caller=module_service.go:82 msg=starting module=compactor
level=info ts=2026-05-23T22:59:33.580968604Z caller=ring.go:365 msg="ring doesn't exist in KV store yet"
level=info ts=2026-05-23T22:59:33.581028692Z caller=module_service.go:82 msg=starting module=rule-evaluator
level=info ts=2026-05-23T22:59:33.581058192Z caller=module_service.go:82 msg=starting module=ingester
level=info ts=2026-05-23T22:59:33.581111636Z caller=ingester.go:565 component=ingester msg="recovering from checkpoint"
level=info ts=2026-05-23T22:59:33.581153304Z caller=recovery.go:42 component=ingester msg="no checkpoint found, treating as no-op"
level=info ts=2026-05-23T22:59:33.581214252Z caller=module_service.go:82 msg=starting module=ruler
level=info ts=2026-05-23T22:59:33.58123199Z caller=ruler.go:536 msg="ruler up and running"
level=info ts=2026-05-23T22:59:33.581288729Z caller=module_service.go:82 msg=starting module=distributor
level=error ts=2026-05-23T22:59:33.581373962Z caller=ratestore.go:110 msg="error getting ingester clients" err="empty ring"
level=info ts=2026-05-23T22:59:33.581446106Z caller=basic_lifecycler.go:321 msg="instance not found in the ring" instance=loki-0 ring=compactor
level=info ts=2026-05-23T22:59:33.581474718Z caller=basic_lifecycler_delegates.go:63 msg="not loading tokens from file, tokens file path is empty"
level=info ts=2026-05-23T22:59:33.581577007Z caller=basic_lifecycler.go:321 component=distributor msg="instance not found in the ring" instance=loki-0 ring=distributor
level=info ts=2026-05-23T22:59:33.582596951Z caller=compactor.go:383 msg="waiting until compactor is JOINING in the ring"
level=info ts=2026-05-23T22:59:33.582631013Z caller=ingester.go:581 component=ingester msg="recovered WAL checkpoint recovery finished" elapsed=1.526593ms errors=false
level=info ts=2026-05-23T22:59:33.582648154Z caller=ingester.go:587 component=ingester msg="recovering from WAL"
level=info ts=2026-05-23T22:59:33.585997529Z caller=ingester.go:603 component=ingester msg="WAL segment recovery finished" elapsed=4.892564ms errors=false
level=info ts=2026-05-23T22:59:33.586023405Z caller=ingester.go:551 component=ingester msg="closing recoverer"
level=info ts=2026-05-23T22:59:33.586041593Z caller=ingester.go:559 component=ingester msg="WAL recovery finished" time=4.936363ms
level=info ts=2026-05-23T22:59:33.586192101Z caller=lifecycler.go:687 component=ingester msg="not loading tokens from file, tokens file path is empty"
level=info ts=2026-05-23T22:59:33.586222475Z caller=lifecycler.go:714 component=ingester msg="instance not found in ring, adding with no tokens" ring=ingester
level=info ts=2026-05-23T22:59:33.586334584Z caller=lifecycler.go:556 component=ingester msg="auto-joining cluster after timeout" ring=ingester
level=info ts=2026-05-23T22:59:33.586509128Z caller=wal.go:158 msg=started component=wal
level=info ts=2026-05-23T22:59:33.590883788Z caller=ingester.go:772 component=ingester msg="sleeping for initial delay before starting periodic flushing" delay=4.291224798s
level=info ts=2026-05-23T22:59:33.727705748Z caller=compactor.go:387 msg="compactor is JOINING in the ring"
level=info ts=2026-05-23T22:59:34.580887357Z caller=ringmanager.go:199 msg="waiting until scheduler is ACTIVE in the ring"
level=info ts=2026-05-23T22:59:34.728207055Z caller=compactor.go:397 msg="waiting until compactor is ACTIVE in the ring"
ts=2026-05-23T22:59:34.731689643Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T22:59:34.731742714Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=2 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T22:59:34.778659562Z caller=ringmanager.go:203 msg="scheduler is ACTIVE in the ring"
level=info ts=2026-05-23T22:59:34.778735869Z caller=module_service.go:82 msg=starting module=query-scheduler
level=info ts=2026-05-23T22:59:34.77884409Z caller=module_service.go:82 msg=starting module=query-frontend
level=info ts=2026-05-23T22:59:34.778929381Z caller=module_service.go:82 msg=starting module=querier
level=info ts=2026-05-23T22:59:34.885717692Z caller=compactor.go:401 msg="compactor is ACTIVE in the ring"
level=info ts=2026-05-23T22:59:34.885784978Z caller=loki.go:599 msg="Loki started" startup_time=1.509700683s
level=info ts=2026-05-23T22:59:37.7796483Z caller=worker.go:235 component=querier msg="adding connection" addr=10.10.59.54:9095
level=info ts=2026-05-23T22:59:37.779782385Z caller=scheduler.go:652 msg="this scheduler is in the ReplicationSet, will now accept requests."
ts=2026-05-23T22:59:38.149339955Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T22:59:38.1493749Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=3 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T22:59:39.885886792Z caller=compactor.go:460 msg="this instance has been chosen to run the compactor, starting compactor"
level=info ts=2026-05-23T22:59:39.885985625Z caller=tables_manager.go:70 msg="waiting 10m0s for ring to stay stable and previous compactions to finish before starting compactor"
level=info ts=2026-05-23T22:59:44.779945013Z caller=frontend_scheduler_worker.go:106 msg="adding connection to scheduler" addr=10.10.59.54:9095
ts=2026-05-23T22:59:45.542076237Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T22:59:45.54210372Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=4 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
ts=2026-05-23T22:59:54.651889961Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T22:59:54.651922447Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=5 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T23:00:03.591365063Z caller=recalculate_owned_streams.go:49 msg="starting recalculate owned streams job"
level=info ts=2026-05-23T23:00:03.591420228Z caller=recalculate_owned_streams.go:63 msg="detected ring changes, re-evaluating streams ownership"
level=info ts=2026-05-23T23:00:03.591426456Z caller=recalculate_owned_streams.go:52 msg="completed recalculate owned streams job"
level=info ts=2026-05-23T23:00:33.542749641Z caller=table_manager.go:136 index-store=tsdb-2024-01-01 msg="uploading tables"
level=info ts=2026-05-23T23:00:33.592029799Z caller=recalculate_owned_streams.go:49 msg="starting recalculate owned streams job"
level=info ts=2026-05-23T23:00:33.592076409Z caller=recalculate_owned_streams.go:52 msg="completed recalculate owned streams job"
ts=2026-05-23T23:00:46.700204852Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: read udp 10.10.59.54:34142->172.20.0.10:53: i/o timeout"
level=warn ts=2026-05-23T23:00:46.700234544Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=6 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: read udp 10.10.59.54:34142->172.20.0.10:53: i/o timeout\n\n"

--- previous ---
```

## Patch aplicado

```diff
```
