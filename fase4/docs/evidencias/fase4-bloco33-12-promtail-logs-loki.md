# Fase 4 - BLOCO 33.12 - Promtail e logs reais no Loki

## Objetivo

Validar que o Promtail coleta logs reais do namespace togglemaster e envia ao Loki.

Esta evidência fecha a cadeia:

pod no namespace togglemaster -> Promtail -> Loki -> consulta Loki API.

Data: Sat May 23 05:12:41 PM -03 2026

## Resultado

- Loki Application: `Synced/Healthy`
- Promtail Application: `Synced/Healthy`
- Promtail Desired/Ready: `5/5`
- Nodes Ready: `5`
- Pod de teste: `promtail-log-test-1779567186`
- Log real emitido no namespace `togglemaster`.
- Log real encontrado via consulta Loki API.

## Estado das Applications

```text
NAME                     SYNC STATUS   HEALTH STATUS   REVISION   PROJECT
observability-loki       Synced        Healthy                    default
observability-promtail   Synced        Healthy                    default
```

## Pods Loki e Promtail

```text
NAME                                                        READY   STATUS    RESTARTS   AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
loki-0                                                      2/2     Running   0          19m   10.10.53.75    ip-10-10-61-91.ec2.internal    <none>           <none>
promtail-7czrn                                              1/1     Running   0          14m   10.10.63.6     ip-10-10-51-233.ec2.internal   <none>           <none>
promtail-dczbq                                              1/1     Running   0          14m   10.10.51.75    ip-10-10-61-91.ec2.internal    <none>           <none>
promtail-dhlpf                                              1/1     Running   0          14m   10.10.42.215   ip-10-10-37-16.ec2.internal    <none>           <none>
promtail-lx9q4                                              1/1     Running   0          14m   10.10.33.199   ip-10-10-34-177.ec2.internal   <none>           <none>
promtail-twhxw                                              1/1     Running   0          14m   10.10.62.205   ip-10-10-59-138.ec2.internal   <none>           <none>
```

## DaemonSet Promtail

```text
NAME       DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE   CONTAINERS   IMAGES                             SELECTOR
promtail   5         5         5       5            5           <none>          14m   promtail     docker.io/grafana/promtail:3.5.1   app.kubernetes.io/instance=promtail,app.kubernetes.io/name=promtail
```

## Loki ready

```text
ready

```

## Log real emitido

```text
TOGGLEMASTER_PROMTAIL_FINAL_1779567186
```

## Validação da consulta Loki

```text
LOKI_QUERY_STATUS=success
LOKI_MARKER_FOUND=true
LOKI_RESULT_STREAMS=1
```

## Resposta Loki

```json
{"status":"success","data":{"resultType":"streams","result":[{"stream":{"app":"promtail-log-test-1779567186","container":"promtail-log-test-1779567186","detected_level":"unknown","filename":"/var/log/pods/togglemaster_promtail-log-test-1779567186_a8318d05-d1c2-404d-a025-e1459e019131/promtail-log-test-1779567186/0.log","job":"togglemaster/promtail-log-test-1779567186","namespace":"togglemaster","node_name":"ip-10-10-59-138.ec2.internal","pod":"promtail-log-test-1779567186","service_name":"promtail-log-test-1779567186","stream":"stdout"},"values":[["1779567188439708346","TOGGLEMASTER_PROMTAIL_FINAL_1779567186"]]}],"stats":{"summary":{"bytesProcessedPerSecond":7302664,"linesProcessedPerSecond":16058,"totalBytesProcessed":42746,"totalLinesProcessed":94,"execTime":0.005853,"queueTime":0.000962,"subqueries":0,"totalEntriesReturned":1,"splits":2,"shards":2,"totalPostFilterLines":1,"totalStructuredMetadataBytesProcessed":752},"querier":{"store":{"totalChunksRef":0,"totalChunksDownloaded":0,"chunksDownloadTime":0,"queryReferencedStructuredMetadata":false,"queryUsedV2Engine":false,"chunk":{"headChunkBytes":0,"headChunkLines":0,"decompressedBytes":0,"decompressedLines":0,"compressedBytes":0,"totalDuplicates":0,"postFilterLines":0,"headChunkStructuredMetadataBytes":0,"decompressedStructuredMetadataBytes":0},"chunkRefsFetchTime":0,"congestionControlLatency":0,"pipelineWrapperFilteredLines":0,"dataobj":{"prePredicateDecompressedRows":0,"prePredicateDecompressedBytes":0,"prePredicateDecompressedStructuredMetadataBytes":0,"postPredicateRows":0,"postPredicateDecompressedBytes":0,"postPredicateStructuredMetadataBytes":0,"postFilterRows":0,"pagesScanned":0,"pagesDownloaded":0,"pagesDownloadedBytes":0,"pageBatches":0,"totalRowsAvailable":0,"totalPageDownloadTime":0}}},"ingester":{"totalReached":2,"totalChunksMatched":5,"totalBatches":3,"totalLinesSent":1,"store":{"totalChunksRef":0,"totalChunksDownloaded":0,"chunksDownloadTime":0,"queryReferencedStructuredMetadata":false,"queryUsedV2Engine":false,"chunk":{"headChunkBytes":42746,"headChunkLines":94,"decompressedBytes":0,"decompressedLines":0,"compressedBytes":0,"totalDuplicates":0,"postFilterLines":1,"headChunkStructuredMetadataBytes":752,"decompressedStructuredMetadataBytes":0},"chunkRefsFetchTime":248802,"congestionControlLatency":0,"pipelineWrapperFilteredLines":0,"dataobj":{"prePredicateDecompressedRows":0,"prePredicateDecompressedBytes":0,"prePredicateDecompressedStructuredMetadataBytes":0,"postPredicateRows":0,"postPredicateDecompressedBytes":0,"postPredicateStructuredMetadataBytes":0,"postFilterRows":0,"pagesScanned":0,"pagesDownloaded":0,"pagesDownloadedBytes":0,"pageBatches":0,"totalRowsAvailable":0,"totalPageDownloadTime":0}}},"cache":{"chunk":{"entriesFound":0,"entriesRequested":0,"entriesStored":0,"bytesReceived":0,"bytesSent":0,"requests":0,"downloadTime":0,"queryLengthServed":0},"index":{"entriesFound":0,"entriesRequested":0,"entriesStored":0,"bytesReceived":0,"bytesSent":0,"requests":0,"downloadTime":0,"queryLengthServed":0},"result":{"entriesFound":0,"entriesRequested":0,"entriesStored":0,"bytesReceived":0,"bytesSent":0,"requests":0,"downloadTime":0,"queryLengthServed":0},"statsResult":{"entriesFound":0,"entriesRequested":1,"entriesStored":1,"bytesReceived":0,"bytesSent":0,"requests":2,"downloadTime":32833,"queryLengthServed":0},"volumeResult":{"entriesFound":0,"entriesRequested":0,"entriesStored":0,"bytesReceived":0,"bytesSent":0,"requests":0,"downloadTime":0,"queryLengthServed":0},"seriesResult":{"entriesFound":0,"entriesRequested":0,"entriesStored":0,"bytesReceived":0,"bytesSent":0,"requests":0,"downloadTime":0,"queryLengthServed":0},"labelResult":{"entriesFound":0,"entriesRequested":0,"entriesStored":0,"bytesReceived":0,"bytesSent":0,"requests":0,"downloadTime":0,"queryLengthServed":0},"instantMetricResult":{"entriesFound":0,"entriesRequested":0,"entriesStored":0,"bytesReceived":0,"bytesSent":0,"requests":0,"downloadTime":0,"queryLengthServed":0}},"index":{"totalChunks":0,"postFilterChunks":0,"shardsDuration":0,"usedBloomFilters":false}}}}


```
