# Fase 4 - BLOCO 33.2 - Loki em modo leve

Data: Sat May 23 05:35:19 PM -03 2026

## Objetivo

Corrigir definitivamente a configuração do Loki para um perfil leve no AWS Academy, removendo caches/memcached que causaram pressão de memória/pods e impediam a Application de ficar Healthy.

Este bloco também corrige o erro de parsing de versão Helm observado no BLOCO 33.1.


## Estado antes da correção

```text
 M fase3/docs/evidencias/fase3-bloco18-checkpoint-retomada-pre-fase4.md
 M fase3/docs/evidencias/fase3-bloco19-validacao-apps-pre-fase4.md
 M fase3/docs/evidencias/fase3-bloco20-validacao-offline.md
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
observability-loki   Synced        Healthy                    default
NAME                                                        READY   STATUS    RESTARTS   AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
loki-0                                                      2/2     Running   0          2m35s   10.10.54.213   ip-10-10-61-91.ec2.internal    <none>           <none>
```

## Logs Loki antes da correção

```text
level=info ts=2026-05-23T20:32:50.557114366Z caller=main.go:133 msg="Starting Loki" version="(version=3.6.7, branch=release-3.6.x, revision=7e1daf3a)"
level=info ts=2026-05-23T20:32:50.557169967Z caller=main.go:134 msg="Loading configuration file" filename=/etc/loki/config/config.yaml
level=info ts=2026-05-23T20:32:50.559267089Z caller=server.go:386 msg="server listening on addresses" http=[::]:3100 grpc=[::]:9095
level=info ts=2026-05-23T20:32:50.566450227Z caller=memberlist_client.go:484 msg="Using memberlist cluster label and node name" cluster_label= node=loki-0-c025b481
level=info ts=2026-05-23T20:32:50.566795068Z caller=memberlist_client.go:628 msg="memberlist fast-join starting" nodes_found=1 to_join=4
level=info ts=2026-05-23T20:32:50.572232387Z caller=table_manager.go:300 index-store=tsdb-2024-01-01 msg="query readiness setup completed" duration=2.364µs distinct_users_len=0 distinct_users=
level=info ts=2026-05-23T20:32:50.572272715Z caller=shipper.go:165 index-store=tsdb-2024-01-01 msg="starting index shipper in RW mode"
level=info ts=2026-05-23T20:32:50.572688072Z caller=head_manager.go:313 index-store=tsdb-2024-01-01 component=tsdb-head-manager msg="loaded wals by period" groups=0
level=info ts=2026-05-23T20:32:50.572740043Z caller=manager.go:86 index-store=tsdb-2024-01-01 component=tsdb-manager msg="loaded leftover local indices" err=null successful=true buckets=0 indices=0 failures=0
level=info ts=2026-05-23T20:32:50.572764311Z caller=head_manager.go:313 index-store=tsdb-2024-01-01 component=tsdb-head-manager msg="loaded wals by period" groups=0
level=info ts=2026-05-23T20:32:50.575730406Z caller=table_manager.go:136 index-store=tsdb-2024-01-01 msg="uploading tables"
level=info ts=2026-05-23T20:32:50.576494242Z caller=mapper.go:47 msg="cleaning up mapped rules directory" path=/var/loki/rules-temp
ts=2026-05-23T20:32:50.590699766Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=info ts=2026-05-23T20:32:50.590726939Z caller=memberlist_client.go:634 msg="fast-joining node failed" node=loki-memberlist.observability.svc.cluster.local err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=warn ts=2026-05-23T20:32:50.59075398Z caller=memberlist_client.go:644 msg="memberlist fast-join failed because no node has been successfully reached" elapsed_time=23.961875ms
level=error ts=2026-05-23T20:32:50.590764086Z caller=memberlist_client.go:521 msg="failed to fast-join the memberlist cluster at startup" err="no memberlist node reached during fast-join procedure"
level=info ts=2026-05-23T20:32:50.590781584Z caller=memberlist_client.go:666 phase=startup msg="joining memberlist cluster" join_members=loki-memberlist.observability.svc.cluster.local
level=info ts=2026-05-23T20:32:50.597843091Z caller=worker.go:134 component=querier msg="Starting querier worker using query-scheduler and scheduler ring for addresses"
ts=2026-05-23T20:32:50.59878817Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T20:32:50.59881982Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=1 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T20:32:50.630561584Z caller=module_service.go:82 msg=starting module=cache-generation-loader
level=info ts=2026-05-23T20:32:50.632040906Z caller=module_service.go:82 msg=starting module=server
level=info ts=2026-05-23T20:32:50.633330254Z caller=module_service.go:82 msg=starting module=runtime-config
level=info ts=2026-05-23T20:32:50.636298031Z caller=module_service.go:82 msg=starting module=query-frontend-tripperware
level=info ts=2026-05-23T20:32:50.636850293Z caller=module_service.go:82 msg=starting module=memberlist-kv
level=info ts=2026-05-23T20:32:50.637705602Z caller=module_service.go:82 msg=starting module=query-scheduler-ring
level=info ts=2026-05-23T20:32:50.637951171Z caller=ring.go:365 msg="ring doesn't exist in KV store yet"
level=info ts=2026-05-23T20:32:50.638678788Z caller=module_service.go:82 msg=starting module=store
level=info ts=2026-05-23T20:32:50.638717979Z caller=module_service.go:82 msg=starting module=ring
level=info ts=2026-05-23T20:32:50.63876722Z caller=ring.go:365 msg="ring doesn't exist in KV store yet"
level=info ts=2026-05-23T20:32:50.638866951Z caller=basic_lifecycler.go:321 msg="instance not found in the ring" instance=loki-0 ring=scheduler
level=info ts=2026-05-23T20:32:50.638894828Z caller=basic_lifecycler_delegates.go:63 msg="not loading tokens from file, tokens file path is empty"
level=info ts=2026-05-23T20:32:50.639137742Z caller=module_service.go:82 msg=starting module=ingester-querier
level=info ts=2026-05-23T20:32:50.639162841Z caller=module_service.go:82 msg=starting module=analytics
level=info ts=2026-05-23T20:32:50.63966388Z caller=ringmanager.go:186 msg="waiting until scheduler is JOINING in the ring"
level=info ts=2026-05-23T20:32:50.639683687Z caller=ringmanager.go:190 msg="scheduler is JOINING in the ring"
level=info ts=2026-05-23T20:32:50.639736218Z caller=module_service.go:82 msg=starting module=rule-evaluator
level=info ts=2026-05-23T20:32:50.639854885Z caller=module_service.go:82 msg=starting module=distributor
level=error ts=2026-05-23T20:32:50.640058194Z caller=ratestore.go:110 msg="error getting ingester clients" err="empty ring"
level=info ts=2026-05-23T20:32:50.640119807Z caller=module_service.go:82 msg=starting module=ingester
level=info ts=2026-05-23T20:32:50.640248077Z caller=ingester.go:565 component=ingester msg="recovering from checkpoint"
level=info ts=2026-05-23T20:32:50.640294116Z caller=recovery.go:42 component=ingester msg="no checkpoint found, treating as no-op"
level=info ts=2026-05-23T20:32:50.645435505Z caller=basic_lifecycler.go:321 component=distributor msg="instance not found in the ring" instance=loki-0 ring=distributor
level=info ts=2026-05-23T20:32:50.647031488Z caller=ingester.go:581 component=ingester msg="recovered WAL checkpoint recovery finished" elapsed=6.78527ms errors=false
level=info ts=2026-05-23T20:32:50.647061608Z caller=ingester.go:587 component=ingester msg="recovering from WAL"
level=info ts=2026-05-23T20:32:50.647361428Z caller=ingester.go:603 component=ingester msg="WAL segment recovery finished" elapsed=7.11539ms errors=false
level=info ts=2026-05-23T20:32:50.64737966Z caller=ingester.go:551 component=ingester msg="closing recoverer"
level=info ts=2026-05-23T20:32:50.647397311Z caller=ingester.go:559 component=ingester msg="WAL recovery finished" time=7.150612ms
level=info ts=2026-05-23T20:32:50.647519616Z caller=lifecycler.go:687 component=ingester msg="not loading tokens from file, tokens file path is empty"
level=info ts=2026-05-23T20:32:50.647553206Z caller=lifecycler.go:714 component=ingester msg="instance not found in ring, adding with no tokens" ring=ingester
level=info ts=2026-05-23T20:32:50.64765391Z caller=lifecycler.go:556 component=ingester msg="auto-joining cluster after timeout" ring=ingester
level=info ts=2026-05-23T20:32:50.647807668Z caller=wal.go:158 msg=started component=wal
level=info ts=2026-05-23T20:32:50.647883238Z caller=ingester.go:772 component=ingester msg="sleeping for initial delay before starting periodic flushing" delay=16.389207619s
level=info ts=2026-05-23T20:32:50.648234982Z caller=module_service.go:82 msg=starting module=ruler
level=info ts=2026-05-23T20:32:50.648280469Z caller=ruler.go:536 msg="ruler up and running"
level=info ts=2026-05-23T20:32:50.64838569Z caller=module_service.go:82 msg=starting module=compactor
level=info ts=2026-05-23T20:32:50.64931865Z caller=ring.go:365 msg="ring doesn't exist in KV store yet"
level=info ts=2026-05-23T20:32:50.649381711Z caller=basic_lifecycler.go:321 msg="instance not found in the ring" instance=loki-0 ring=compactor
level=info ts=2026-05-23T20:32:50.649408646Z caller=basic_lifecycler_delegates.go:63 msg="not loading tokens from file, tokens file path is empty"
level=info ts=2026-05-23T20:32:50.649573212Z caller=compactor.go:383 msg="waiting until compactor is JOINING in the ring"
level=info ts=2026-05-23T20:32:50.649591917Z caller=compactor.go:387 msg="compactor is JOINING in the ring"
level=info ts=2026-05-23T20:32:51.640914404Z caller=ringmanager.go:199 msg="waiting until scheduler is ACTIVE in the ring"
level=info ts=2026-05-23T20:32:51.650040907Z caller=compactor.go:397 msg="waiting until compactor is ACTIVE in the ring"
level=info ts=2026-05-23T20:32:51.751757368Z caller=ringmanager.go:203 msg="scheduler is ACTIVE in the ring"
level=info ts=2026-05-23T20:32:51.751848586Z caller=module_service.go:82 msg=starting module=query-scheduler
level=info ts=2026-05-23T20:32:51.751949696Z caller=module_service.go:82 msg=starting module=querier
level=info ts=2026-05-23T20:32:51.751991233Z caller=module_service.go:82 msg=starting module=query-frontend
level=info ts=2026-05-23T20:32:51.850388648Z caller=compactor.go:401 msg="compactor is ACTIVE in the ring"
level=info ts=2026-05-23T20:32:51.850452115Z caller=loki.go:599 msg="Loki started" startup_time=1.456506232s
ts=2026-05-23T20:32:52.061443382Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T20:32:52.061474602Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=2 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T20:32:54.752346526Z caller=worker.go:235 component=querier msg="adding connection" addr=10.10.54.213:9095
level=info ts=2026-05-23T20:32:54.752470825Z caller=scheduler.go:652 msg="this scheduler is in the ReplicationSet, will now accept requests."
ts=2026-05-23T20:32:55.305682384Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T20:32:55.305709073Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=3 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T20:32:56.851015652Z caller=compactor.go:460 msg="this instance has been chosen to run the compactor, starting compactor"
level=info ts=2026-05-23T20:32:56.851160561Z caller=tables_manager.go:70 msg="waiting 10m0s for ring to stay stable and previous compactions to finish before starting compactor"
level=info ts=2026-05-23T20:33:01.7523657Z caller=frontend_scheduler_worker.go:106 msg="adding connection to scheduler" addr=10.10.54.213:9095
ts=2026-05-23T20:33:02.101451008Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T20:33:02.101478975Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=4 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
ts=2026-05-23T20:33:13.986933364Z caller=memberlist_logger.go:74 level=warn msg="Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host"
level=warn ts=2026-05-23T20:33:13.986961629Z caller=memberlist_client.go:700 phase=startup msg="joining memberlist cluster" attempts=5 max_attempts=10 err="1 error occurred:\n\t* Failed to resolve loki-memberlist.observability.svc.cluster.local: lookup loki-memberlist.observability.svc.cluster.local on 172.20.0.10:53: no such host\n\n"
level=info ts=2026-05-23T20:33:20.648540721Z caller=recalculate_owned_streams.go:49 msg="starting recalculate owned streams job"
level=info ts=2026-05-23T20:33:20.648590242Z caller=recalculate_owned_streams.go:63 msg="detected ring changes, re-evaluating streams ownership"
level=info ts=2026-05-23T20:33:20.648600612Z caller=recalculate_owned_streams.go:52 msg="completed recalculate owned streams job"
level=info ts=2026-05-23T20:33:33.636992955Z caller=memberlist_client.go:673 phase=startup msg="joining memberlist cluster succeeded" reached_nodes=1 elapsed_time=43.04620463s
level=info ts=2026-05-23T20:33:50.576579166Z caller=table_manager.go:136 index-store=tsdb-2024-01-01 msg="uploading tables"
level=info ts=2026-05-23T20:33:50.647917617Z caller=recalculate_owned_streams.go:49 msg="starting recalculate owned streams job"
level=info ts=2026-05-23T20:33:50.647951591Z caller=recalculate_owned_streams.go:52 msg="completed recalculate owned streams job"
level=info ts=2026-05-23T20:34:20.648781735Z caller=recalculate_owned_streams.go:49 msg="starting recalculate owned streams job"
level=info ts=2026-05-23T20:34:20.648825584Z caller=recalculate_owned_streams.go:52 msg="completed recalculate owned streams job"
level=info ts=2026-05-23T20:34:50.576173112Z caller=table_manager.go:136 index-store=tsdb-2024-01-01 msg="uploading tables"
level=info ts=2026-05-23T20:34:50.648799198Z caller=recalculate_owned_streams.go:49 msg="starting recalculate owned streams job"
level=info ts=2026-05-23T20:34:50.648842883Z caller=recalculate_owned_streams.go:52 msg="completed recalculate owned streams job"
level=info ts=2026-05-23T20:35:12.496805751Z caller=flush.go:305 component=ingester msg="flushing stream" user=fake fp=38ddb456265481e7 immediate=false num_chunks=1 total_comp="38 kB" avg_comp="38 kB" total_uncomp="678 kB" avg_uncomp="678 kB" synced=1 labels="{app=\"argocd-application-controller\", container=\"argocd-application-controller\", filename=\"/var/log/pods/argocd_argocd-application-controller-0_a5ddd7e7-d254-4053-a53e-bcd993717cc8/argocd-application-controller/0.log\", job=\"argocd/argocd-application-controller\", namespace=\"argocd\", node_name=\"ip-10-10-37-16.ec2.internal\", pod=\"argocd-application-controller-0\", service_name=\"argocd-application-controller\", stream=\"stderr\"}"
level=info ts=2026-05-23T20:35:12.521570548Z caller=roundtrip.go:415 org_id=fake msg="executing query" type=range query="{namespace=\"togglemaster\"} |= \"TOGGLEMASTER_PROMTAIL_FINAL_1779568463\"" start=2026-05-23T20:20:12Z end=2026-05-23T20:36:12Z start_delta=15m0.521567039s end_delta=-59.478432719s length=16m0s step=3000 query_hash=44106131
level=info ts=2026-05-23T20:35:12.523932642Z caller=table_manager.go:195 index-store=tsdb-2024-01-01 msg="get or create table" found=false table=index_20596 wait_for_lock=1.037µs
level=info ts=2026-05-23T20:35:12.523957297Z caller=table_manager.go:205 index-store=tsdb-2024-01-01 msg="downloading all files for table" table=index_20596
level=info ts=2026-05-23T20:35:12.524098031Z caller=table_manager.go:195 index-store=tsdb-2024-01-01 msg="get or create table" found=true table=index_20596 wait_for_lock=136.838µs
ts=2026-05-23T20:35:12.524255442Z caller=spanlogger.go:152 table-name=index_20596 user-id=fake user=fake level=info msg="init index set" duration=100.516µs success=true
ts=2026-05-23T20:35:12.524276701Z caller=spanlogger.go:152 table-name=index_20596 user-id=fake user=fake level=info msg="downloaded index set at query time" duration=100.516µs
ts=2026-05-23T20:35:12.524424515Z caller=spanlogger.go:152 table-name=index_20596 user=fake level=info msg="init index set" duration=86.028µs success=true
ts=2026-05-23T20:35:12.524437494Z caller=spanlogger.go:152 table-name=index_20596 user=fake level=info msg="downloaded index set at query time" duration=86.028µs
level=info ts=2026-05-23T20:35:12.525484726Z caller=metrics.go:409 org_id=fake latency=fast query_type=stats start=2026-05-23T20:29:30Z end=2026-05-23T20:36:12Z start_delta=5m42.525481s end_delta=-59.474518715s length=6m42s duration=1.713505ms status=200 query="{namespace=\"togglemaster\"}" query_hash=1812713949 total_entries=1
level=info ts=2026-05-23T20:35:12.525662051Z caller=metrics.go:409 org_id=fake latency=fast query_type=stats start=2026-05-23T20:19:42Z end=2026-05-23T20:30:00Z start_delta=15m30.525659372s end_delta=5m12.525659616s length=10m18s duration=1.966084ms status=200 query="{namespace=\"togglemaster\"}" query_hash=1812713949 total_entries=1
level=info ts=2026-05-23T20:35:12.527371338Z caller=engine.go:274 component=querier org_id=fake msg="executing query" query="{namespace=\"togglemaster\"} |= \"TOGGLEMASTER_PROMTAIL_FINAL_1779568463\"" query_hash=44106131 type=range length=9m48s step=3s
level=info ts=2026-05-23T20:35:12.527731315Z caller=engine.go:274 component=querier org_id=fake msg="executing query" query="{namespace=\"togglemaster\"} |= \"TOGGLEMASTER_PROMTAIL_FINAL_1779568463\"" query_hash=44106131 type=range length=6m12s step=3s
level=info ts=2026-05-23T20:35:12.529003838Z caller=table_manager.go:195 index-store=tsdb-2024-01-01 msg="get or create table" found=true table=index_20596 wait_for_lock=1.072µs
level=info ts=2026-05-23T20:35:12.529027286Z caller=table_manager.go:195 index-store=tsdb-2024-01-01 msg="get or create table" found=true table=index_20596 wait_for_lock=619ns
level=info ts=2026-05-23T20:35:12.529397297Z caller=metrics.go:237 component=querier org_id=fake latency=fast query="{namespace=\"togglemaster\"} |= \"TOGGLEMASTER_PROMTAIL_FINAL_1779568463\"" query_hash=44106131 query_type=filter range_type=range length=9m48s start_delta=15m0.529367381s end_delta=5m12.529367578s step=3s duration=1.94877ms status=200 limit=20 returned_lines=0 throughput=0B total_bytes=0B total_bytes_structured_metadata=0B lines_per_second=0 total_lines=0 post_filter_lines=0 total_entries=0 store_chunks_download_time=0s queue_time=68.153µs splits=0 shards=0 query_referenced_structured_metadata=false pipeline_wrapper_filtered_lines=0 chunk_refs_fetch_time=121.437µs cache_chunk_req=0 cache_chunk_hit=0 cache_chunk_bytes_stored=0 cache_chunk_bytes_fetched=0 cache_chunk_download_time=0s cache_index_req=0 cache_index_hit=0 cache_index_download_time=0s cache_stats_results_req=0 cache_stats_results_hit=0 cache_stats_results_download_time=0s cache_volume_results_req=0 cache_volume_results_hit=0 cache_volume_results_download_time=0s cache_result_req=0 cache_result_hit=0 cache_result_download_time=0s cache_result_query_length_served=0s cardinality_estimate=0 ingester_chunk_refs=0 ingester_chunk_downloaded=0 ingester_chunk_matches=0 ingester_requests=1 ingester_chunk_head_bytes=0B ingester_chunk_compressed_bytes=0B ingester_chunk_decompressed_bytes=0B ingester_post_filter_lines=0 congestion_control_latency=0s index_total_chunks=0 index_post_bloom_filter_chunks=0 index_bloom_filter_ratio=0.00 index_used_bloom_filters=false index_shard_resolver_duration=0s disable_pipeline_wrappers=false has_labelfilter_before_parser=false
level=info ts=2026-05-23T20:35:12.529380934Z caller=metrics.go:237 component=querier org_id=fake latency=fast query="{namespace=\"togglemaster\"} |= \"TOGGLEMASTER_PROMTAIL_FINAL_1779568463\"" query_hash=44106131 query_type=filter range_type=range length=6m12s start_delta=5m12.529367458s end_delta=-59.470632379s step=3s duration=1.593827ms status=200 limit=20 returned_lines=1 throughput=4.2MB total_bytes=6.7kB total_bytes_structured_metadata=120B lines_per_second=9411 total_lines=15 post_filter_lines=1 total_entries=1 store_chunks_download_time=0s queue_time=433.117µs splits=0 shards=0 query_referenced_structured_metadata=false pipeline_wrapper_filtered_lines=0 chunk_refs_fetch_time=143.869µs cache_chunk_req=0 cache_chunk_hit=0 cache_chunk_bytes_stored=0 cache_chunk_bytes_fetched=0 cache_chunk_download_time=0s cache_index_req=0 cache_index_hit=0 cache_index_download_time=0s cache_stats_results_req=0 cache_stats_results_hit=0 cache_stats_results_download_time=0s cache_volume_results_req=0 cache_volume_results_hit=0 cache_volume_results_download_time=0s cache_result_req=0 cache_result_hit=0 cache_result_download_time=0s cache_result_query_length_served=0s cardinality_estimate=0 ingester_chunk_refs=0 ingester_chunk_downloaded=0 ingester_chunk_matches=2 ingester_requests=1 ingester_chunk_head_bytes=6.7kB ingester_chunk_compressed_bytes=0B ingester_chunk_decompressed_bytes=0B ingester_post_filter_lines=1 congestion_control_latency=0s index_total_chunks=0 index_post_bloom_filter_chunks=0 index_bloom_filter_ratio=0.00 index_used_bloom_filters=false index_shard_resolver_duration=0s disable_pipeline_wrappers=false has_labelfilter_before_parser=false
level=info ts=2026-05-23T20:35:12.531862219Z caller=metrics.go:237 component=frontend org_id=fake latency=fast query="{namespace=\"togglemaster\"} |= \"TOGGLEMASTER_PROMTAIL_FINAL_1779568463\"" query_hash=44106131 query_type=filter range_type=range length=16m0s start_delta=15m0.531826997s end_delta=-59.468172849s step=3s duration=9.830527ms status=200 limit=20 returned_lines=0 throughput=684kB total_bytes=6.7kB total_bytes_structured_metadata=120B lines_per_second=1525 total_lines=15 post_filter_lines=1 total_entries=1 store_chunks_download_time=0s queue_time=501µs splits=2 shards=2 query_referenced_structured_metadata=false pipeline_wrapper_filtered_lines=0 chunk_refs_fetch_time=265.306µs cache_chunk_req=0 cache_chunk_hit=0 cache_chunk_bytes_stored=0 cache_chunk_bytes_fetched=0 cache_chunk_download_time=0s cache_index_req=0 cache_index_hit=0 cache_index_download_time=0s cache_stats_results_req=0 cache_stats_results_hit=0 cache_stats_results_download_time=0s cache_volume_results_req=0 cache_volume_results_hit=0 cache_volume_results_download_time=0s cache_result_req=0 cache_result_hit=0 cache_result_download_time=0s cache_result_query_length_served=0s cardinality_estimate=0 ingester_chunk_refs=0 ingester_chunk_downloaded=0 ingester_chunk_matches=2 ingester_requests=2 ingester_chunk_head_bytes=6.7kB ingester_chunk_compressed_bytes=0B ingester_chunk_decompressed_bytes=0B ingester_post_filter_lines=1 congestion_control_latency=0s index_total_chunks=0 index_post_bloom_filter_chunks=0 index_bloom_filter_ratio=0.00 index_used_bloom_filters=false index_shard_resolver_duration=0s disable_pipeline_wrappers=false has_labelfilter_before_parser=false
level=info ts=2026-05-23T20:35:20.648581887Z caller=recalculate_owned_streams.go:49 msg="starting recalculate owned streams job"
level=info ts=2026-05-23T20:35:20.648628939Z caller=recalculate_owned_streams.go:52 msg="completed recalculate owned streams job"

--- previous ---
```

## Patch aplicado

```diff
```
