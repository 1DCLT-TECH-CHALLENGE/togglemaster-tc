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

## Resultado runtime

```text
APP_STATUS=Synced/Healthy
LOKI_READY=2/2
LOKI_STATUS=Running
CACHE_STS_COUNT=0
```

## Estado final

```text
NAME                 SYNC STATUS   HEALTH STATUS   REVISION   PROJECT
observability-loki   Synced        Healthy                    default
NAME                                                        READY   STATUS      RESTARTS   AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
loki-0                                                      2/2     Running     0          70s     10.10.53.75    ip-10-10-61-91.ec2.internal    <none>           <none>
NAME                                              READY   AGE
loki                                              1/1     41m
NAME                                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
loki                                             ClusterIP   172.20.165.63    <none>        3100/TCP,9095/TCP            41m
loki-headless                                    ClusterIP   None             <none>        3100/TCP                     41m
loki-memberlist                                  ClusterIP   None             <none>        7946/TCP                     41m
```

## Loki ready

```text
ready
pod "loki-ready-test" deleted
```

## Logs Loki

```text
level=info ts=2026-05-23T19:54:26.83310143Z caller=main.go:133 msg="Starting Loki" version="(version=3.6.7, branch=release-3.6.x, revision=7e1daf3a)"
level=info ts=2026-05-23T19:54:26.833164261Z caller=main.go:134 msg="Loading configuration file" filename=/etc/loki/config/config.yaml
level=info ts=2026-05-23T19:54:26.835296967Z caller=server.go:386 msg="server listening on addresses" http=[::]:3100 grpc=[::]:9095
level=info ts=2026-05-23T19:54:26.838818958Z caller=memberlist_client.go:484 msg="Using memberlist cluster label and node name" cluster_label= node=loki-0-69a569b2
level=info ts=2026-05-23T19:54:26.839170291Z caller=memberlist_client.go:628 msg="memberlist fast-join starting" nodes_found=1 to_join=4
ts=2026-05-23T19:54:26.857505218Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=info ts=2026-05-23T19:54:26.857536637Z caller=memberlist_client.go:634 msg="fast-joining node failed" node=loki-memberlist.observability.svc.cluster.local err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=warn ts=2026-05-23T19:54:26.857557277Z caller=memberlist_client.go:644 msg="memberlist fast-join failed because no node has been successfully reached" elapsed_time=18.390118ms
level=error ts=2026-05-23T19:54:26.857573057Z caller=memberlist_client.go:521 msg="failed to fast-join the memberlist cluster at startup" err="no memberlist node reached during fast-join procedure"
level=info ts=2026-05-23T19:54:26.85759387Z caller=memberlist_client.go:666 phase=startup msg="joining memberlist cluster" join_members=loki-memberlist.observability.svc.cluster.local
level=info ts=2026-05-23T19:54:26.869177529Z caller=table_manager.go:300 index-store=tsdb-2024-01-01 msg="query readiness setup completed" duration=3.124µs distinct_users_len=0 distinct_users=
level=info ts=2026-05-23T19:54:26.869235445Z caller=shipper.go:165 index-store=tsdb-2024-01-01 msg="starting index shipper in RW mode"
level=info ts=2026-05-23T19:54:26.869754379Z caller=head_manager.go:313 index-store=tsdb-2024-01-01 component=tsdb-head-manager msg="loaded wals by period" groups=0
level=info ts=2026-05-23T19:54:26.869812949Z caller=manager.go:86 index-store=tsdb-2024-01-01 component=tsdb-manager msg="loaded leftover local indices" err=null successful=true buckets=0 indices=0 failures=0
level=info ts=2026-05-23T19:54:26.869838468Z caller=head_manager.go:313 index-store=tsdb-2024-01-01 component=tsdb-head-manager msg="loaded wals by period" groups=0
level=info ts=2026-05-23T19:54:26.871114035Z caller=table_manager.go:136 index-store=tsdb-2024-01-01 msg="uploading tables"
ts=2026-05-23T19:54:26.873734666Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T19:54:26.873757637Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=1 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T19:54:26.876595762Z caller=worker.go:134 component=querier msg="Starting querier worker using query-scheduler and scheduler ring for addresses"
level=info ts=2026-05-23T19:54:26.877462451Z caller=mapper.go:47 msg="cleaning up mapped rules directory" path=/var/loki/rules-temp
level=info ts=2026-05-23T19:54:26.911461988Z caller=module_service.go:82 msg=starting module=server
level=info ts=2026-05-23T19:54:26.912794513Z caller=module_service.go:82 msg=starting module=runtime-config
level=info ts=2026-05-23T19:54:26.915826043Z caller=module_service.go:82 msg=starting module=query-frontend-tripperware
level=info ts=2026-05-23T19:54:26.916174041Z caller=module_service.go:82 msg=starting module=memberlist-kv
level=info ts=2026-05-23T19:54:26.917399121Z caller=module_service.go:82 msg=starting module=store
level=info ts=2026-05-23T19:54:26.917457424Z caller=module_service.go:82 msg=starting module=query-scheduler-ring
level=info ts=2026-05-23T19:54:26.917534196Z caller=ring.go:365 msg="ring doesn't exist in KV store yet"
level=info ts=2026-05-23T19:54:26.917859194Z caller=basic_lifecycler.go:321 msg="instance not found in the ring" instance=loki-0 ring=scheduler
level=info ts=2026-05-23T19:54:26.917896307Z caller=basic_lifecycler_delegates.go:63 msg="not loading tokens from file, tokens file path is empty"
level=info ts=2026-05-23T19:54:26.918208536Z caller=ringmanager.go:186 msg="waiting until scheduler is JOINING in the ring"
level=info ts=2026-05-23T19:54:26.918223826Z caller=ringmanager.go:190 msg="scheduler is JOINING in the ring"
level=info ts=2026-05-23T19:54:26.920025087Z caller=module_service.go:82 msg=starting module=cache-generation-loader
level=info ts=2026-05-23T19:54:26.920150472Z caller=module_service.go:82 msg=starting module=ring
level=info ts=2026-05-23T19:54:26.920256445Z caller=ring.go:365 msg="ring doesn't exist in KV store yet"
level=info ts=2026-05-23T19:54:26.920356946Z caller=module_service.go:82 msg=starting module=analytics
level=info ts=2026-05-23T19:54:26.920710938Z caller=module_service.go:82 msg=starting module=ingester
level=info ts=2026-05-23T19:54:26.920806767Z caller=ingester.go:565 component=ingester msg="recovering from checkpoint"
level=info ts=2026-05-23T19:54:26.920857057Z caller=recovery.go:42 component=ingester msg="no checkpoint found, treating as no-op"
level=info ts=2026-05-23T19:54:26.921088028Z caller=module_service.go:82 msg=starting module=compactor
level=info ts=2026-05-23T19:54:26.921360392Z caller=ring.go:365 msg="ring doesn't exist in KV store yet"
level=info ts=2026-05-23T19:54:26.921683563Z caller=basic_lifecycler.go:321 msg="instance not found in the ring" instance=loki-0 ring=compactor
level=info ts=2026-05-23T19:54:26.921710944Z caller=basic_lifecycler_delegates.go:63 msg="not loading tokens from file, tokens file path is empty"
level=info ts=2026-05-23T19:54:26.921928012Z caller=ingester.go:581 component=ingester msg="recovered WAL checkpoint recovery finished" elapsed=1.123196ms errors=false
level=info ts=2026-05-23T19:54:26.921945334Z caller=ingester.go:587 component=ingester msg="recovering from WAL"
level=info ts=2026-05-23T19:54:26.923618794Z caller=compactor.go:383 msg="waiting until compactor is JOINING in the ring"
level=info ts=2026-05-23T19:54:26.92363646Z caller=compactor.go:387 msg="compactor is JOINING in the ring"
level=info ts=2026-05-23T19:54:26.923705963Z caller=ingester.go:603 component=ingester msg="WAL segment recovery finished" elapsed=2.895708ms errors=false
level=info ts=2026-05-23T19:54:26.923722024Z caller=ingester.go:551 component=ingester msg="closing recoverer"
level=info ts=2026-05-23T19:54:26.923739976Z caller=ingester.go:559 component=ingester msg="WAL recovery finished" time=2.934433ms
level=info ts=2026-05-23T19:54:26.923886522Z caller=lifecycler.go:687 component=ingester msg="not loading tokens from file, tokens file path is empty"
level=info ts=2026-05-23T19:54:26.923922833Z caller=lifecycler.go:714 component=ingester msg="instance not found in ring, adding with no tokens" ring=ingester
level=info ts=2026-05-23T19:54:26.92402715Z caller=lifecycler.go:556 component=ingester msg="auto-joining cluster after timeout" ring=ingester
level=info ts=2026-05-23T19:54:26.924133956Z caller=wal.go:158 msg=started component=wal
level=info ts=2026-05-23T19:54:26.925391751Z caller=ingester.go:772 component=ingester msg="sleeping for initial delay before starting periodic flushing" delay=18.365497399s
level=info ts=2026-05-23T19:54:26.925781746Z caller=module_service.go:82 msg=starting module=ingester-querier
level=info ts=2026-05-23T19:54:26.925873528Z caller=module_service.go:82 msg=starting module=rule-evaluator
level=info ts=2026-05-23T19:54:26.925969665Z caller=module_service.go:82 msg=starting module=ruler
level=info ts=2026-05-23T19:54:26.926043591Z caller=ruler.go:536 msg="ruler up and running"
level=info ts=2026-05-23T19:54:26.927612788Z caller=module_service.go:82 msg=starting module=distributor
level=info ts=2026-05-23T19:54:26.927857666Z caller=basic_lifecycler.go:321 component=distributor msg="instance not found in the ring" instance=loki-0 ring=distributor
level=info ts=2026-05-23T19:54:27.918542638Z caller=ringmanager.go:199 msg="waiting until scheduler is ACTIVE in the ring"
level=info ts=2026-05-23T19:54:27.918608005Z caller=ringmanager.go:203 msg="scheduler is ACTIVE in the ring"
level=info ts=2026-05-23T19:54:27.918712585Z caller=module_service.go:82 msg=starting module=query-scheduler
level=info ts=2026-05-23T19:54:27.918781933Z caller=module_service.go:82 msg=starting module=querier
level=info ts=2026-05-23T19:54:27.918855914Z caller=module_service.go:82 msg=starting module=query-frontend
ts=2026-05-23T19:54:27.919391933Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T19:54:27.919428626Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=2 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T19:54:27.92491936Z caller=compactor.go:397 msg="waiting until compactor is ACTIVE in the ring"
level=info ts=2026-05-23T19:54:28.047835211Z caller=compactor.go:401 msg="compactor is ACTIVE in the ring"
level=info ts=2026-05-23T19:54:28.047901855Z caller=loki.go:599 msg="Loki started" startup_time=1.371524485s
ts=2026-05-23T19:54:30.848918458Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T19:54:30.848951221Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=3 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T19:54:30.919709888Z caller=scheduler.go:652 msg="this scheduler is in the ReplicationSet, will now accept requests."
level=info ts=2026-05-23T19:54:30.919839117Z caller=worker.go:235 component=querier msg="adding connection" addr=10.10.53.75:9095
level=info ts=2026-05-23T19:54:33.048450821Z caller=compactor.go:460 msg="this instance has been chosen to run the compactor, starting compactor"
level=info ts=2026-05-23T19:54:33.048544224Z caller=tables_manager.go:70 msg="waiting 10m0s for ring to stay stable and previous compactions to finish before starting compactor"
ts=2026-05-23T19:54:35.10691549Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T19:54:35.106947611Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=4 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T19:54:37.9198429Z caller=frontend_scheduler_worker.go:106 msg="adding connection to scheduler" addr=10.10.53.75:9095
ts=2026-05-23T19:54:48.370096853Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T19:54:48.370126254Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=5 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T19:54:56.925802355Z caller=recalculate_owned_streams.go:49 msg="starting recalculate owned streams job"
level=info ts=2026-05-23T19:54:56.925848288Z caller=recalculate_owned_streams.go:63 msg="detected ring changes, re-evaluating streams ownership"
level=info ts=2026-05-23T19:54:56.925854443Z caller=recalculate_owned_streams.go:52 msg="completed recalculate owned streams job"
level=info ts=2026-05-23T19:55:11.941657559Z caller=memberlist_client.go:673 phase=startup msg="joining memberlist cluster succeeded" reached_nodes=1 elapsed_time=45.084055956s
```
