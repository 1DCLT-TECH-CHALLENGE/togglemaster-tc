# Fase 4 - BLOCO 33.8 - Diagnóstico do CrashLoop do Loki

Data: Sat May 23 04:49:39 PM -03 2026

## Objetivo

Diagnosticar o erro real do container `loki` após a remoção/prune dos caches antigos.

Este bloco não altera recursos Kubernetes, não aplica manifests e não reinicia pods.


## Estado geral

```text
65724af (HEAD -> main, origin/main) docs: diagnose loki sync prune without pyyaml
69e8c64 docs: diagnose loki sync prune
7fad6dc docs: stabilize cluster after lab transition
38c433d docs: stabilize cluster after lab transition
d6afff8 fix: disable loki caches for phase 4 lab
8d734ee docs: validate phase 4 grafana dashboard
19aa77c docs: validate phase 4 grafana access
fd2f476 docs: deploy phase 4 prometheus grafana stack
NAME                 SYNC STATUS   HEALTH STATUS   REVISION   PROJECT
observability-loki   Synced        Progressing                default
NAME                                                        READY   STATUS             RESTARTS      AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
loki-0                                                      1/2     CrashLoopBackOff   6 (66s ago)   7m3s    10.10.63.6     ip-10-10-51-233.ec2.internal   <none>           <none>
NAME                                              READY   AGE
loki                                              0/1     35m
NAME                                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
loki                                             ClusterIP   172.20.165.63    <none>        3100/TCP,9095/TCP            35m
loki-headless                                    ClusterIP   None             <none>        3100/TCP                     35m
loki-memberlist                                  ClusterIP   None             <none>        7946/TCP                     35m
```

## Describe loki-0

```text
Name:             loki-0
Namespace:        observability
Priority:         0
Service Account:  loki
Node:             ip-10-10-51-233.ec2.internal/10.10.51.233
Start Time:       Sat, 23 May 2026 16:42:42 -0300
Labels:           app.kubernetes.io/component=single-binary
                  app.kubernetes.io/instance=loki
                  app.kubernetes.io/name=loki
                  app.kubernetes.io/part-of=memberlist
                  apps.kubernetes.io/pod-index=0
                  controller-revision-hash=loki-5977cd5484
                  statefulset.kubernetes.io/pod-name=loki-0
Annotations:      checksum/config: e19c14ac0dabf912d431bf3d955dc9f342a8d52d9029c6406bba72ff73ffedf5
                  kubectl.kubernetes.io/default-container: loki
Status:           Running
IP:               10.10.63.6
IPs:
  IP:           10.10.63.6
Controlled By:  StatefulSet/loki
Containers:
  loki:
    Container ID:  containerd://c2c1c329f2d012e06f6531d1a4d7d10f475c8c9afde30a73a027a1e3a046def6
    Image:         docker.io/grafana/loki:3.6.7
    Image ID:      docker.io/grafana/loki@sha256:3c8fd3570dd9219951a60d3f919c7f31923d10baee578b77bc26c4a0b32d092d
    Ports:         3100/TCP, 9095/TCP, 7946/TCP
    Host Ports:    0/TCP, 0/TCP, 0/TCP
    Args:
      -config.file=/etc/loki/config/config.yaml
      -target=all
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Sat, 23 May 2026 16:48:38 -0300
      Finished:     Sat, 23 May 2026 16:48:39 -0300
    Ready:          False
    Restart Count:  6
    Limits:
      memory:  768Mi
    Requests:
      cpu:        100m
      memory:     256Mi
    Readiness:    http-get http://:http-metrics/ready delay=15s timeout=1s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /etc/loki/config from config (rw)
      /etc/loki/runtime-config from runtime-config (rw)
      /rules from sc-rules-volume (rw)
      /tmp from tmp (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-chffm (ro)
  loki-sc-rules:
    Container ID:   containerd://147e8930327084c21606171fec934febff65d472d931e040db773a2cea4e2383
    Image:          docker.io/kiwigrid/k8s-sidecar:2.5.0
    Image ID:       docker.io/kiwigrid/k8s-sidecar@sha256:a6b3f707f883108376514489a94d6629109a327b2978e1d826cd104c4ca436df
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sat, 23 May 2026 16:42:48 -0300
    Ready:          True
    Restart Count:  0
    Environment:
      METHOD:                WATCH
      LABEL:                 loki_rule
      FOLDER:                /rules
      RESOURCE:              both
      WATCH_SERVER_TIMEOUT:  60
      WATCH_CLIENT_TIMEOUT:  60
      LOG_LEVEL:             INFO
    Mounts:
      /rules from sc-rules-volume (rw)
      /tmp from tmp (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-chffm (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       False 
  ContainersReady             False 
  PodScheduled                True 
Volumes:
  tmp:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      loki
    Optional:  false
  runtime-config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      loki-runtime
    Optional:  false
  sc-rules-volume:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  kube-api-access-chffm:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                   From               Message
  ----     ------     ----                  ----               -------
  Normal   Scheduled  7m7s                  default-scheduler  Successfully assigned observability/loki-0 to ip-10-10-51-233.ec2.internal
  Normal   Pulling    7m6s                  kubelet            Pulling image "docker.io/grafana/loki:3.6.7"
  Normal   Pulled     7m4s                  kubelet            Successfully pulled image "docker.io/grafana/loki:3.6.7" in 2.27s (2.27s including waiting). Image size: 41373791 bytes.
  Normal   Pulling    7m4s                  kubelet            Pulling image "docker.io/kiwigrid/k8s-sidecar:2.5.0"
  Normal   Pulled     7m1s                  kubelet            Successfully pulled image "docker.io/kiwigrid/k8s-sidecar:2.5.0" in 2.22s (2.221s including waiting). Image size: 23422974 bytes.
  Normal   Created    7m1s                  kubelet            Created container: loki-sc-rules
  Normal   Started    7m1s                  kubelet            Started container loki-sc-rules
  Normal   Created    6m11s (x4 over 7m4s)  kubelet            Created container: loki
  Normal   Started    6m11s (x4 over 7m4s)  kubelet            Started container loki
  Normal   Pulled     6m11s (x3 over 7m1s)  kubelet            Container image "docker.io/grafana/loki:3.6.7" already present on machine
  Warning  BackOff    112s (x29 over 7m)    kubelet            Back-off restarting failed container loki in pod loki-0_observability(8ff701dd-0702-4a12-ac55-3c482e0b8e60)
```

## Logs container loki - atual

```text
mkdir /var/loki: read-only file system
error initialising module: ruler-storage
github.com/grafana/dskit/modules.(*Manager).initModule
	/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:138
github.com/grafana/dskit/modules.(*Manager).InitModuleServices
	/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:108
github.com/grafana/loki/v3/pkg/loki.(*Loki).Run
	/src/loki/pkg/loki/loki.go:549
main.main
	/src/loki/cmd/loki/main.go:136
runtime.main
	/usr/local/go/src/runtime/proc.go:283
runtime.goexit
	/usr/local/go/src/runtime/asm_amd64.s:1700
level=info ts=2026-05-23T19:48:39.009058121Z caller=main.go:133 msg="Starting Loki" version="(version=3.6.7, branch=release-3.6.x, revision=7e1daf3a)"
level=info ts=2026-05-23T19:48:39.009098766Z caller=main.go:134 msg="Loading configuration file" filename=/etc/loki/config/config.yaml
level=error ts=2026-05-23T19:48:39.010391703Z caller=log.go:223 msg="error running loki" err="mkdir /var/loki: read-only file system\nerror initialising module: ruler-storage\ngithub.com/grafana/dskit/modules.(*Manager).initModule\n\t/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:138\ngithub.com/grafana/dskit/modules.(*Manager).InitModuleServices\n\t/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:108\ngithub.com/grafana/loki/v3/pkg/loki.(*Loki).Run\n\t/src/loki/pkg/loki/loki.go:549\nmain.main\n\t/src/loki/cmd/loki/main.go:136\nruntime.main\n\t/usr/local/go/src/runtime/proc.go:283\nruntime.goexit\n\t/usr/local/go/src/runtime/asm_amd64.s:1700"
```

## Logs container loki - previous

```text
mkdir /var/loki: read-only file system
error initialising module: ruler-storage
github.com/grafana/dskit/modules.(*Manager).initModule
	/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:138
github.com/grafana/dskit/modules.(*Manager).InitModuleServices
	/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:108
github.com/grafana/loki/v3/pkg/loki.(*Loki).Run
	/src/loki/pkg/loki/loki.go:549
main.main
	/src/loki/cmd/loki/main.go:136
runtime.main
	/usr/local/go/src/runtime/proc.go:283
runtime.goexit
	/usr/local/go/src/runtime/asm_amd64.s:1700
level=info ts=2026-05-23T19:48:39.009058121Z caller=main.go:133 msg="Starting Loki" version="(version=3.6.7, branch=release-3.6.x, revision=7e1daf3a)"
level=info ts=2026-05-23T19:48:39.009098766Z caller=main.go:134 msg="Loading configuration file" filename=/etc/loki/config/config.yaml
level=error ts=2026-05-23T19:48:39.010391703Z caller=log.go:223 msg="error running loki" err="mkdir /var/loki: read-only file system\nerror initialising module: ruler-storage\ngithub.com/grafana/dskit/modules.(*Manager).initModule\n\t/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:138\ngithub.com/grafana/dskit/modules.(*Manager).InitModuleServices\n\t/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:108\ngithub.com/grafana/loki/v3/pkg/loki.(*Loki).Run\n\t/src/loki/pkg/loki/loki.go:549\nmain.main\n\t/src/loki/cmd/loki/main.go:136\nruntime.main\n\t/usr/local/go/src/runtime/proc.go:283\nruntime.goexit\n\t/usr/local/go/src/runtime/asm_amd64.s:1700"
```

## Logs sidecar loki-sc-rules

```text
{"time": "2026-05-23T19:42:52.936071+00:00", "level": "INFO", "msg": "Starting collector"}
{"time": "2026-05-23T19:42:52.937072+00:00", "level": "INFO", "msg": "No folder annotation was provided, defaulting to k8s-sidecar-target-directory"}
{"time": "2026-05-23T19:42:52.937591+00:00", "level": "INFO", "msg": "Starting health server on port 8080"}
{"time": "2026-05-23T19:42:52.937899+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:42:52.938871+00:00", "level": "INFO", "msg": "Unique filenames will not be enforced."}
{"time": "2026-05-23T19:42:52.938996+00:00", "level": "INFO", "msg": "5xx response content will not be enabled."}
{"time": "2026-05-23T19:42:52.939294+00:00", "level": "INFO", "msg": "Performing initial list-based sync before starting watch."}
{"time": "2026-05-23T19:42:52.939426+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:42:52.940285+00:00", "level": "INFO", "msg": "Performing list-based sync on secret resources: {'namespace': 'observability'}"}
{"time": "2026-05-23T19:42:52.958946+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:42:52.960489+00:00", "level": "INFO", "msg": "Performing list-based sync on configmap resources: {'namespace': 'observability'}"}
{"time": "2026-05-23T19:42:53.002686+00:00", "level": "INFO", "msg": "Initial sync complete, sidecar is ready."}
{"time": "2026-05-23T19:42:53.003374+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:42:53.003573+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:42:53.005200+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:42:53.005467+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:43:53.015945+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:43:53.030353+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:44:53.025117+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:44:53.039906+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:45:53.034716+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:45:53.049959+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:46:53.044574+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:46:53.058525+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:47:53.054515+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:47:53.067981+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:48:53.063747+00:00", "level": "INFO", "msg": "Loading incluster config..."}
{"time": "2026-05-23T19:48:53.076264+00:00", "level": "INFO", "msg": "Loading incluster config..."}
```

## ConfigMap Loki - linhas relevantes

```text
5:    auth_enabled: false
8:        planner_address: ""
12:        addresses: ""
14:    common:
15:      compactor_grpc_address: 'loki.observability.svc.cluster.local:9095'
16:      path_prefix: /var/loki
17:      replication_factor: 1
18:      storage:
19:        filesystem:
22:    compactor:
23:      delete_request_store: filesystem
26:      scheduler_address: ""
29:      scheduler_address: ""
32:    limits_config:
40:    memberlist:
42:      - loki-memberlist.observability.svc.cluster.local
47:    ruler:
48:      storage:
51:        dir: /var/loki/ruler-wal
54:    schema_config:
60:        object_store: filesystem
61:        schema: v13
62:        store: tsdb
64:      grpc_listen_port: 9095
65:      http_listen_port: 3100
68:    storage_config:
71:      boltdb_shipper:
73:          server_address: ""
78:      tsdb_shipper:
80:          server_address: ""
89:      {"apiVersion":"v1","data":{"config.yaml":"\nauth_enabled: false\nbloom_build:\n  builder:\n    planner_address: \"\"\n  enabled: false\nbloom_gateway:\n  client:\n    addresses: \"\"\n  enabled: false\ncommon:\n  compactor_grpc_address: 'loki.observability.svc.cluster.local:9095'\n  path_prefix: /var/loki\n  replication_factor: 1\n  storage:\n    filesystem:\n      chunks_directory: /var/loki/chunks\n      rules_directory: /var/loki/rules\ncompactor:\n  delete_request_store: filesystem\n  retention_enabled: true\nfrontend:\n  scheduler_address: \"\"\n  tail_proxy_url: \"\"\nfrontend_worker:\n  scheduler_address: \"\"\nindex_gateway:\n  mode: simple\nlimits_config:\n  max_cache_freshness_per_query: 10m\n  query_timeout: 300s\n  reject_old_samples: true\n  reject_old_samples_max_age: 168h\n  retention_period: 24h\n  split_queries_by_interval: 15m\n  volume_enabled: true\nmemberlist:\n  join_members:\n  - loki-memberlist.observability.svc.cluster.local\npattern_ingester:\n  enabled: false\nquery_range:\n  align_queries_with_step: true\nruler:\n  storage:\n    type: local\n  wal:\n    dir: /var/loki/ruler-wal\nruntime_config:\n  file: /etc/loki/runtime-config/runtime-config.yaml\nschema_config:\n  configs:\n  - from: \"2024-01-01\"\n    index:\n      period: 24h\n      prefix: index_\n    object_store: filesystem\n    schema: v13\n    store: tsdb\nserver:\n  grpc_listen_port: 9095\n  http_listen_port: 3100\n  http_server_read_timeout: 600s\n  http_server_write_timeout: 600s\nstorage_config:\n  bloom_shipper:\n    working_directory: /var/loki/data/bloomshipper\n  boltdb_shipper:\n    index_gateway_client:\n      server_address: \"\"\n  hedging:\n    at: 250ms\n    max_per_second: 20\n    up_to: 3\n  tsdb_shipper:\n    index_gateway_client:\n      server_address: \"\"\n  use_thanos_objstore: false\ntracing:\n  enabled: false\n"},"kind":"ConfigMap","metadata":{"annotations":{"argocd.argoproj.io/tracking-id":"observability-loki:/ConfigMap:observability/loki"},"labels":{"app.kubernetes.io/instance":"loki","app.kubernetes.io/name":"loki","app.kubernetes.io/version":"3.6.7","helm.sh/chart":"loki-7.0.0"},"name":"loki","namespace":"observability"}}
```

## StatefulSet Loki - linhas relevantes

```text
7:      {"apiVersion":"apps/v1","kind":"StatefulSet","metadata":{"annotations":{"argocd.argoproj.io/tracking-id":"observability-loki:apps/StatefulSet:observability/loki"},"labels":{"app.kubernetes.io/component":"single-binary","app.kubernetes.io/instance":"loki","app.kubernetes.io/name":"loki","app.kubernetes.io/part-of":"memberlist","app.kubernetes.io/version":"3.6.7","helm.sh/chart":"loki-7.0.0"},"name":"loki","namespace":"observability"},"spec":{"podManagementPolicy":"Parallel","replicas":1,"revisionHistoryLimit":10,"selector":{"matchLabels":{"app.kubernetes.io/component":"single-binary","app.kubernetes.io/instance":"loki","app.kubernetes.io/name":"loki"}},"serviceName":"loki-headless","template":{"metadata":{"annotations":{"checksum/config":"e19c14ac0dabf912d431bf3d955dc9f342a8d52d9029c6406bba72ff73ffedf5","kubectl.kubernetes.io/default-container":"loki"},"labels":{"app.kubernetes.io/component":"single-binary","app.kubernetes.io/instance":"loki","app.kubernetes.io/name":"loki","app.kubernetes.io/part-of":"memberlist"}},"spec":{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"single-binary","app.kubernetes.io/instance":"loki","app.kubernetes.io/name":"loki"}},"topologyKey":"kubernetes.io/hostname"}]}},"automountServiceAccountToken":true,"containers":[{"args":["-config.file=/etc/loki/config/config.yaml","-target=all"],"image":"docker.io/grafana/loki:3.6.7","imagePullPolicy":"IfNotPresent","name":"loki","ports":[{"containerPort":3100,"name":"http-metrics","protocol":"TCP"},{"containerPort":9095,"name":"grpc","protocol":"TCP"},{"containerPort":7946,"name":"http-memberlist","protocol":"TCP"}],"readinessProbe":{"failureThreshold":3,"httpGet":{"path":"/ready","port":"http-metrics"},"initialDelaySeconds":15,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1},"resources":{"limits":{"memory":"768Mi"},"requests":{"cpu":"100m","memory":"256Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true},"volumeMounts":[{"mountPath":"/tmp","name":"tmp"},{"mountPath":"/etc/loki/config","name":"config"},{"mountPath":"/etc/loki/runtime-config","name":"runtime-config"},{"mountPath":"/rules","name":"sc-rules-volume"}]},{"env":[{"name":"METHOD","value":"WATCH"},{"name":"LABEL","value":"loki_rule"},{"name":"FOLDER","value":"/rules"},{"name":"RESOURCE","value":"both"},{"name":"WATCH_SERVER_TIMEOUT","value":"60"},{"name":"WATCH_CLIENT_TIMEOUT","value":"60"},{"name":"LOG_LEVEL","value":"INFO"}],"image":"docker.io/kiwigrid/k8s-sidecar:2.5.0","imagePullPolicy":"IfNotPresent","name":"loki-sc-rules","securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true},"volumeMounts":[{"mountPath":"/tmp","name":"tmp"},{"mountPath":"/rules","name":"sc-rules-volume"}]}],"enableServiceLinks":true,"securityContext":{"fsGroup":10001,"fsGroupChangePolicy":"OnRootMismatch","runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001},"serviceAccountName":"loki","terminationGracePeriodSeconds":30,"volumes":[{"emptyDir":{},"name":"tmp"},{"configMap":{"items":[{"key":"config.yaml","path":"config.yaml"}],"name":"loki"},"name":"config"},{"configMap":{"name":"loki-runtime"},"name":"runtime-config"},{"emptyDir":{},"name":"sc-rules-volume"}]}},"updateStrategy":{"rollingUpdate":{"partition":0}}}}
13:    app.kubernetes.io/name: loki
17:  name: loki
32:      app.kubernetes.io/name: loki
43:        app.kubernetes.io/name: loki
53:                app.kubernetes.io/name: loki
57:      - args:
60:        image: docker.io/grafana/loki:3.6.7
62:        name: loki
64:        - containerPort: 3100
65:          name: http-metrics
67:        - containerPort: 9095
68:          name: grpc
70:        - containerPort: 7946
71:          name: http-memberlist
73:        readinessProbe:
83:        resources:
84:          limits:
86:          requests:
98:        - mountPath: /tmp
99:          name: tmp
100:        - mountPath: /etc/loki/config
101:          name: config
102:        - mountPath: /etc/loki/runtime-config
103:          name: runtime-config
104:        - mountPath: /rules
105:          name: sc-rules-volume
107:        - name: METHOD
109:        - name: LABEL
111:        - name: FOLDER
113:        - name: RESOURCE
115:        - name: WATCH_SERVER_TIMEOUT
117:        - name: WATCH_CLIENT_TIMEOUT
119:        - name: LOG_LEVEL
121:        image: docker.io/kiwigrid/k8s-sidecar:2.5.0
123:        name: loki-sc-rules
124:        resources: {}
134:        - mountPath: /tmp
135:          name: tmp
136:        - mountPath: /rules
137:          name: sc-rules-volume
153:        name: tmp
159:          name: loki
160:        name: config
163:          name: loki-runtime
164:        name: runtime-config
166:        name: sc-rules-volume
```

## Eventos recentes

```text
7m14s       Warning   FailedToUpdateEndpointSlices   service/kube-prometheus-stack-prometheus-node-exporter           Error updating Endpoint Slices for Service observability/kube-prometheus-stack-prometheus-node-exporter: skipping Pod kube-prometheus-stack-prometheus-node-exporter-btj4c for Service observability/kube-prometheus-stack-prometheus-node-exporter: Node ip-10-10-49-137.ec2.internal Not Found
7m14s       Normal    Pulling                        pod/loki-0                                                       Pulling image "docker.io/grafana/loki:3.6.7"
7m14s       Normal    Pulling                        pod/prometheus-kube-prometheus-stack-prometheus-0                Pulling image "quay.io/prometheus-operator/prometheus-config-reloader:v0.90.1"
7m13s       Normal    Started                        pod/prometheus-kube-prometheus-stack-prometheus-0                Started container init-config-reloader
7m13s       Normal    Pulled                         pod/prometheus-kube-prometheus-stack-prometheus-0                Successfully pulled image "quay.io/prometheus-operator/prometheus-config-reloader:v0.90.1" in 1.175s (1.175s including waiting). Image size: 14230502 bytes.
7m13s       Normal    Created                        pod/prometheus-kube-prometheus-stack-prometheus-0                Created container: init-config-reloader
7m12s       Normal    Pulled                         pod/loki-0                                                       Successfully pulled image "docker.io/grafana/loki:3.6.7" in 2.27s (2.27s including waiting). Image size: 41373791 bytes.
7m12s       Normal    Pulling                        pod/prometheus-kube-prometheus-stack-prometheus-0                Pulling image "quay.io/prometheus/prometheus:v3.11.3-distroless"
7m12s       Normal    Pulling                        pod/loki-0                                                       Pulling image "docker.io/kiwigrid/k8s-sidecar:2.5.0"
7m9s        Normal    Started                        pod/loki-0                                                       Started container loki-sc-rules
7m9s        Normal    Created                        pod/loki-0                                                       Created container: loki-sc-rules
7m9s        Normal    Pulled                         pod/loki-0                                                       Successfully pulled image "docker.io/kiwigrid/k8s-sidecar:2.5.0" in 2.22s (2.221s including waiting). Image size: 23422974 bytes.
7m6s        Normal    Started                        pod/prometheus-kube-prometheus-stack-prometheus-0                Started container config-reloader
7m6s        Normal    Created                        pod/prometheus-kube-prometheus-stack-prometheus-0                Created container: config-reloader
7m6s        Normal    Pulled                         pod/prometheus-kube-prometheus-stack-prometheus-0                Container image "quay.io/prometheus-operator/prometheus-config-reloader:v0.90.1" already present on machine
7m6s        Normal    Started                        pod/prometheus-kube-prometheus-stack-prometheus-0                Started container prometheus
7m6s        Normal    Created                        pod/prometheus-kube-prometheus-stack-prometheus-0                Created container: prometheus
7m6s        Normal    Pulled                         pod/prometheus-kube-prometheus-stack-prometheus-0                Successfully pulled image "quay.io/prometheus/prometheus:v3.11.3-distroless" in 5.096s (5.096s including waiting). Image size: 152641195 bytes.
6m54s       Normal    SuccessfulCreate               job/kube-prometheus-stack-admission-create                       Created pod: kube-prometheus-stack-admission-create-9x8bg
6m54s       Normal    Scheduled                      pod/kube-prometheus-stack-admission-create-9x8bg                 Successfully assigned observability/kube-prometheus-stack-admission-create-9x8bg to ip-10-10-59-138.ec2.internal
6m53s       Normal    Pulling                        pod/kube-prometheus-stack-admission-create-9x8bg                 Pulling image "ghcr.io/jkroepke/kube-webhook-certgen:1.8.3"
6m52s       Normal    Pulled                         pod/kube-prometheus-stack-admission-create-9x8bg                 Successfully pulled image "ghcr.io/jkroepke/kube-webhook-certgen:1.8.3" in 632ms (632ms including waiting). Image size: 9069191 bytes.
6m52s       Normal    Started                        pod/kube-prometheus-stack-admission-create-9x8bg                 Started container create
6m52s       Normal    Created                        pod/kube-prometheus-stack-admission-create-9x8bg                 Created container: create
6m51s       Warning   FailedScheduling               pod/loki-chunks-cache-0                                          0/5 nodes are available: 1 node(s) had untolerated taint {node.kubernetes.io/unreachable: }, 3 Too many pods, 4 Insufficient memory. preemption: 0/5 nodes are available: 1 Preemption is not helpful for scheduling, 4 No preemption victims found for incoming pod.
6m49s       Normal    Completed                      job/kube-prometheus-stack-admission-create                       Job completed
6m41s       Normal    Pulling                        pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Pulling image "quay.io/kiwigrid/k8s-sidecar:2.7.3"
6m41s       Normal    ScalingReplicaSet              deployment/kube-prometheus-stack-grafana                         Scaled up replica set kube-prometheus-stack-grafana-64b956b8f to 1
6m41s       Normal    SuccessfulCreate               replicaset/kube-prometheus-stack-grafana-64b956b8f               Created pod: kube-prometheus-stack-grafana-64b956b8f-rn6k9
6m41s       Normal    Scheduled                      pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Successfully assigned observability/kube-prometheus-stack-grafana-64b956b8f-rn6k9 to ip-10-10-59-138.ec2.internal
6m38s       Normal    Created                        pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Created container: grafana-sc-datasources
6m38s       Normal    Started                        pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Started container grafana-sc-datasources
6m38s       Normal    Pulled                         pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Container image "quay.io/kiwigrid/k8s-sidecar:2.7.3" already present on machine
6m38s       Normal    Pulling                        pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Pulling image "docker.io/grafana/grafana:13.0.1-security-01"
6m38s       Normal    Pulled                         pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Successfully pulled image "quay.io/kiwigrid/k8s-sidecar:2.7.3" in 2.238s (2.238s including waiting). Image size: 28635339 bytes.
6m38s       Normal    Started                        pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Started container grafana-sc-dashboard
6m38s       Normal    Created                        pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Created container: grafana-sc-dashboard
6m22s       Normal    Scheduled                      pod/kube-prometheus-stack-prometheus-node-exporter-cj27n         Successfully assigned observability/kube-prometheus-stack-prometheus-node-exporter-cj27n to ip-10-10-61-91.ec2.internal
6m22s       Normal    Pulling                        pod/kube-prometheus-stack-prometheus-node-exporter-cj27n         Pulling image "quay.io/prometheus/node-exporter:v1.11.1-distroless"
6m22s       Normal    SuccessfulCreate               daemonset/kube-prometheus-stack-prometheus-node-exporter         Created pod: kube-prometheus-stack-prometheus-node-exporter-cj27n
6m19s       Normal    Pulled                         pod/kube-prometheus-stack-prometheus-node-exporter-cj27n         Successfully pulled image "quay.io/prometheus/node-exporter:v1.11.1-distroless" in 2.916s (2.916s including waiting). Image size: 13036189 bytes.
6m19s       Normal    Created                        pod/kube-prometheus-stack-prometheus-node-exporter-cj27n         Created container: node-exporter
6m19s       Normal    Started                        pod/kube-prometheus-stack-prometheus-node-exporter-cj27n         Started container node-exporter
6m19s       Normal    Pulled                         pod/loki-0                                                       Container image "docker.io/grafana/loki:3.6.7" already present on machine
6m19s       Normal    Started                        pod/loki-0                                                       Started container loki
6m19s       Normal    Created                        pod/loki-0                                                       Created container: loki
6m18s       Warning   FailedToUpdateEndpointSlices   service/kube-prometheus-stack-prometheus-node-exporter           (combined from similar events): Error updating Endpoint Slices for Service observability/kube-prometheus-stack-prometheus-node-exporter: skipping Pod kube-prometheus-stack-prometheus-node-exporter-nswkw for Service observability/kube-prometheus-stack-prometheus-node-exporter: Node ip-10-10-55-83.ec2.internal Not Found
6m17s       Normal    Created                        pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Created container: grafana
6m17s       Normal    Pulled                         pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Successfully pulled image "docker.io/grafana/grafana:13.0.1-security-01" in 21.07s (21.07s including waiting). Image size: 347857876 bytes.
6m17s       Normal    Started                        pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Started container grafana
6m11s       Warning   Unhealthy                      pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Readiness probe failed: Get "http://10.10.61.165:3000/api/health": dial tcp 10.10.61.165:3000: connect: connection refused
6m1s        Normal    ScalingReplicaSet              deployment/kube-prometheus-stack-grafana                         Scaled down replica set kube-prometheus-stack-grafana-7b6c9657c7 to 0 from 1
6m1s        Normal    Killing                        pod/kube-prometheus-stack-grafana-7b6c9657c7-x4fd8               Stopping container grafana-sc-dashboard
6m1s        Normal    Killing                        pod/kube-prometheus-stack-grafana-7b6c9657c7-x4fd8               Stopping container grafana
6m1s        Normal    SuccessfulDelete               replicaset/kube-prometheus-stack-grafana-7b6c9657c7              Deleted pod: kube-prometheus-stack-grafana-7b6c9657c7-x4fd8
6m1s        Normal    Killing                        pod/kube-prometheus-stack-grafana-7b6c9657c7-x4fd8               Stopping container grafana-sc-datasources
5m58s       Normal    Scheduled                      pod/kube-prometheus-stack-admission-patch-26rxs                  Successfully assigned observability/kube-prometheus-stack-admission-patch-26rxs to ip-10-10-61-91.ec2.internal
5m58s       Normal    Pulling                        pod/kube-prometheus-stack-admission-patch-26rxs                  Pulling image "ghcr.io/jkroepke/kube-webhook-certgen:1.8.3"
5m58s       Normal    SuccessfulCreate               job/kube-prometheus-stack-admission-patch                        Created pod: kube-prometheus-stack-admission-patch-26rxs
5m57s       Normal    Created                        pod/kube-prometheus-stack-admission-patch-26rxs                  Created container: patch
5m57s       Normal    Pulled                         pod/kube-prometheus-stack-admission-patch-26rxs                  Successfully pulled image "ghcr.io/jkroepke/kube-webhook-certgen:1.8.3" in 725ms (725ms including waiting). Image size: 9069191 bytes.
5m57s       Normal    Started                        pod/kube-prometheus-stack-admission-patch-26rxs                  Started container patch
5m54s       Normal    Completed                      job/kube-prometheus-stack-admission-patch                        Job completed
2m4s        Normal    Scheduled                      pod/kube-prometheus-stack-admission-create-dlqzx                 Successfully assigned observability/kube-prometheus-stack-admission-create-dlqzx to ip-10-10-61-91.ec2.internal
2m4s        Normal    SuccessfulCreate               job/kube-prometheus-stack-admission-create                       Created pod: kube-prometheus-stack-admission-create-dlqzx
2m3s        Normal    Created                        pod/kube-prometheus-stack-admission-create-dlqzx                 Created container: create
2m3s        Normal    Started                        pod/kube-prometheus-stack-admission-create-dlqzx                 Started container create
2m3s        Normal    Pulled                         pod/kube-prometheus-stack-admission-create-dlqzx                 Container image "ghcr.io/jkroepke/kube-webhook-certgen:1.8.3" already present on machine
2m2s        Warning   FailedScheduling               pod/loki-chunks-cache-0                                          0/5 nodes are available: 2 Too many pods, 5 Insufficient memory. preemption: 0/5 nodes are available: 5 No preemption victims found for incoming pod.
2m1s        Normal    Completed                      job/kube-prometheus-stack-admission-create                       Job completed
2m          Warning   BackOff                        pod/loki-0                                                       Back-off restarting failed container loki in pod loki-0_observability(8ff701dd-0702-4a12-ac55-3c482e0b8e60)
113s        Normal    SuccessfulCreate               replicaset/kube-prometheus-stack-grafana-65cc877d76              Created pod: kube-prometheus-stack-grafana-65cc877d76-mkw77
113s        Normal    ScalingReplicaSet              deployment/kube-prometheus-stack-grafana                         Scaled up replica set kube-prometheus-stack-grafana-65cc877d76 to 1
113s        Normal    Pulling                        pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Pulling image "quay.io/kiwigrid/k8s-sidecar:2.7.3"
113s        Normal    Scheduled                      pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Successfully assigned observability/kube-prometheus-stack-grafana-65cc877d76-mkw77 to ip-10-10-61-91.ec2.internal
110s        Normal    Pulled                         pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Successfully pulled image "quay.io/kiwigrid/k8s-sidecar:2.7.3" in 2.269s (2.269s including waiting). Image size: 28635339 bytes.
110s        Normal    Started                        pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Started container grafana-sc-dashboard
110s        Normal    Created                        pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Created container: grafana-sc-dashboard
110s        Normal    Pulling                        pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Pulling image "docker.io/grafana/grafana:13.0.1-security-01"
110s        Normal    Pulled                         pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Container image "quay.io/kiwigrid/k8s-sidecar:2.7.3" already present on machine
110s        Normal    Started                        pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Started container grafana-sc-datasources
110s        Normal    Created                        pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Created container: grafana-sc-datasources
106s        Warning   FailedScheduling               pod/loki-chunks-cache-0                                          skip schedule deleting pod: observability/loki-chunks-cache-0
106s        Normal    Killing                        pod/loki-results-cache-0                                         Stopping container exporter
106s        Normal    Killing                        pod/loki-results-cache-0                                         Stopping container memcached
90s         Normal    Pulled                         pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Successfully pulled image "docker.io/grafana/grafana:13.0.1-security-01" in 20.535s (20.535s including waiting). Image size: 347857876 bytes.
89s         Normal    Created                        pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Created container: grafana
89s         Normal    Started                        pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Started container grafana
83s         Warning   Unhealthy                      pod/kube-prometheus-stack-grafana-65cc877d76-mkw77               Readiness probe failed: Get "http://10.10.53.75:3000/api/health": dial tcp 10.10.53.75:3000: connect: connection refused
73s         Normal    SuccessfulDelete               replicaset/kube-prometheus-stack-grafana-64b956b8f               Deleted pod: kube-prometheus-stack-grafana-64b956b8f-rn6k9
73s         Normal    ScalingReplicaSet              deployment/kube-prometheus-stack-grafana                         Scaled down replica set kube-prometheus-stack-grafana-64b956b8f to 0 from 1
73s         Normal    Killing                        pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Stopping container grafana-sc-datasources
73s         Normal    Killing                        pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Stopping container grafana
73s         Normal    Killing                        pod/kube-prometheus-stack-grafana-64b956b8f-rn6k9                Stopping container grafana-sc-dashboard
71s         Normal    Pulled                         pod/kube-prometheus-stack-admission-patch-vvccw                  Container image "ghcr.io/jkroepke/kube-webhook-certgen:1.8.3" already present on machine
71s         Normal    Created                        pod/kube-prometheus-stack-admission-patch-vvccw                  Created container: patch
71s         Normal    Scheduled                      pod/kube-prometheus-stack-admission-patch-vvccw                  Successfully assigned observability/kube-prometheus-stack-admission-patch-vvccw to ip-10-10-59-138.ec2.internal
71s         Normal    SuccessfulCreate               job/kube-prometheus-stack-admission-patch                        Created pod: kube-prometheus-stack-admission-patch-vvccw
70s         Normal    Started                        pod/kube-prometheus-stack-admission-patch-vvccw                  Started container patch
67s         Normal    Completed                      job/kube-prometheus-stack-admission-patch                        Job completed
```

## Resumo automático

```text
### current
mkdir /var/loki: read-only file system
error initialising module: ruler-storage
level=info ts=2026-05-23T19:48:39.009098766Z caller=main.go:134 msg="Loading configuration file" filename=/etc/loki/config/config.yaml
level=error ts=2026-05-23T19:48:39.010391703Z caller=log.go:223 msg="error running loki" err="mkdir /var/loki: read-only file system\nerror initialising module: ruler-storage\ngithub.com/grafana/dskit/modules.(*Manager).initModule\n\t/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:138\ngithub.com/grafana/dskit/modules.(*Manager).InitModuleServices\n\t/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:108\ngithub.com/grafana/loki/v3/pkg/loki.(*Loki).Run\n\t/src/loki/pkg/loki/loki.go:549\nmain.main\n\t/src/loki/cmd/loki/main.go:136\nruntime.main\n\t/usr/local/go/src/runtime/proc.go:283\nruntime.goexit\n\t/usr/local/go/src/runtime/asm_amd64.s:1700"

### previous
mkdir /var/loki: read-only file system
error initialising module: ruler-storage
level=info ts=2026-05-23T19:48:39.009098766Z caller=main.go:134 msg="Loading configuration file" filename=/etc/loki/config/config.yaml
level=error ts=2026-05-23T19:48:39.010391703Z caller=log.go:223 msg="error running loki" err="mkdir /var/loki: read-only file system\nerror initialising module: ruler-storage\ngithub.com/grafana/dskit/modules.(*Manager).initModule\n\t/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:138\ngithub.com/grafana/dskit/modules.(*Manager).InitModuleServices\n\t/src/loki/vendor/github.com/grafana/dskit/modules/modules.go:108\ngithub.com/grafana/loki/v3/pkg/loki.(*Loki).Run\n\t/src/loki/pkg/loki/loki.go:549\nmain.main\n\t/src/loki/cmd/loki/main.go:136\nruntime.main\n\t/usr/local/go/src/runtime/proc.go:283\nruntime.goexit\n\t/usr/local/go/src/runtime/asm_amd64.s:1700"

### describe
                  app.kubernetes.io/part-of=memberlist
Annotations:      checksum/config: e19c14ac0dabf912d431bf3d955dc9f342a8d52d9029c6406bba72ff73ffedf5
      -config.file=/etc/loki/config/config.yaml
      Reason:       Error
      /etc/loki/config from config (rw)
      /etc/loki/runtime-config from runtime-config (rw)
  config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
  runtime-config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
  Warning  BackOff    112s (x29 over 7m)    kubelet            Back-off restarting failed container loki in pod loki-0_observability(8ff701dd-0702-4a12-ac55-3c482e0b8e60)

```

## Resultado

- Application Loki: `Synced/Progressing`
- Status do pod loki-0: `CrashLoopBackOff`
- Próximo passo: aplicar correção específica baseada nos logs acima.
