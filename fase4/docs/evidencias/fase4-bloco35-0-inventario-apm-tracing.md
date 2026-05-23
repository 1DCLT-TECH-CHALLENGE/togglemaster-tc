# Fase 4 - BLOCO 35.0 - Inventário APM/tracing

## Objetivo

Inventariar o estado atual da instrumentação, dos serviços e dos manifests antes de implementar APM/tracing real.

Este bloco não altera recursos Kubernetes, não aplica manifests e não modifica código de aplicação.

Data: Sat May 23 05:26:00 PM -03 2026

## Git

```text
06e44df (HEAD -> main, origin/main) docs: validate phase 4 otel collector
601ec5a feat: add phase 4 otel collector gitops
9e4fe3e docs: validate promtail logs in loki
539c098 docs: validate loki writable storage fix
2702a34 fix: mount writable var directory for loki
63f1918 docs: validate loki writable storage fix
05a6499 docs: diagnose loki crashloop
65724af docs: diagnose loki sync prune without pyyaml
69e8c64 docs: diagnose loki sync prune
7fad6dc docs: stabilize cluster after lab transition
38c433d docs: stabilize cluster after lab transition
d6afff8 fix: disable loki caches for phase 4 lab
```

## Applications ArgoCD

```text
NAME                                  SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
observability-dashboards              Synced        Healthy         06e44df683ed818e4abf565df667c06ef7ea5bd5   default
observability-kube-prometheus-stack   Synced        Healthy                                                    default
observability-loki                    Synced        Healthy                                                    default
observability-namespace               Synced        Healthy         06e44df683ed818e4abf565df667c06ef7ea5bd5   default
observability-otel-collector          Synced        Healthy         06e44df683ed818e4abf565df667c06ef7ea5bd5   default
observability-promtail                Synced        Healthy                                                    default
togglemaster-dev                      Synced        Healthy         06e44df683ed818e4abf565df667c06ef7ea5bd5   default
```

## Workloads ToggleMaster

```text
NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS           IMAGES                                                                                     SELECTOR
deployment.apps/analytics-service    1/1     1            1           15h   analytics-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb    app.kubernetes.io/name=analytics-service
deployment.apps/auth-service         2/2     2            2           15h   auth-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb         app.kubernetes.io/name=auth-service
deployment.apps/evaluation-service   2/2     2            2           15h   evaluation-service   590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb   app.kubernetes.io/name=evaluation-service
deployment.apps/flag-service         2/2     2            2           15h   flag-service         590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb         app.kubernetes.io/name=flag-service
deployment.apps/targeting-service    2/2     2            2           15h   targeting-service    590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb    app.kubernetes.io/name=targeting-service

NAME                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
service/analytics-service    ClusterIP   172.20.81.122   <none>        8000/TCP   15h   app.kubernetes.io/name=analytics-service
service/auth-service         ClusterIP   172.20.222.48   <none>        8000/TCP   15h   app.kubernetes.io/name=auth-service
service/evaluation-service   ClusterIP   172.20.66.90    <none>        8000/TCP   15h   app.kubernetes.io/name=evaluation-service
service/flag-service         ClusterIP   172.20.51.154   <none>        8000/TCP   15h   app.kubernetes.io/name=flag-service
service/targeting-service    ClusterIP   172.20.90.181   <none>        8000/TCP   15h   app.kubernetes.io/name=targeting-service

NAME                                      READY   STATUS    RESTARTS      AGE   IP             NODE                           NOMINATED NODE   READINESS GATES
pod/analytics-service-6946467b6b-m7dkk    1/1     Running   0             57m   10.10.35.35    ip-10-10-34-177.ec2.internal   <none>           <none>
pod/auth-service-584688f79d-4fvw5         1/1     Running   0             51m   10.10.52.161   ip-10-10-51-233.ec2.internal   <none>           <none>
pod/auth-service-584688f79d-lkmfd         1/1     Running   6 (51m ago)   55m   10.10.47.28    ip-10-10-34-177.ec2.internal   <none>           <none>
pod/evaluation-service-7949b95dd5-6vrk6   1/1     Running   0             18m   10.10.55.176   ip-10-10-61-91.ec2.internal    <none>           <none>
pod/evaluation-service-7949b95dd5-tkxrk   1/1     Running   3 (51m ago)   52m   10.10.34.105   ip-10-10-37-16.ec2.internal    <none>           <none>
pod/flag-service-7cd69f6bf9-6sv22         1/1     Running   0             51m   10.10.55.3     ip-10-10-51-233.ec2.internal   <none>           <none>
pod/flag-service-7cd69f6bf9-lvvzs         1/1     Running   3 (51m ago)   57m   10.10.36.164   ip-10-10-34-177.ec2.internal   <none>           <none>
pod/targeting-service-66d4bb78b6-ntdtf    1/1     Running   0             51m   10.10.49.16    ip-10-10-51-233.ec2.internal   <none>           <none>
pod/targeting-service-66d4bb78b6-xz4vl    1/1     Running   3 (52m ago)   57m   10.10.39.50    ip-10-10-34-177.ec2.internal   <none>           <none>
```

## Workloads Observability

```text
NAME                                  SYNC STATUS   HEALTH STATUS   REVISION                                   PROJECT
observability-otel-collector          Synced        Healthy         06e44df683ed818e4abf565df667c06ef7ea5bd5   default
observability-loki                    Synced        Healthy                                                    default
observability-promtail                Synced        Healthy                                                    default
observability-kube-prometheus-stack   Synced        Healthy                                                    default
NAME                                                       READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS                                            IMAGES                                                                                                               SELECTOR
deployment.apps/kube-prometheus-stack-grafana              1/1     1            1           111m    grafana-sc-dashboard,grafana-sc-datasources,grafana   quay.io/kiwigrid/k8s-sidecar:2.7.3,quay.io/kiwigrid/k8s-sidecar:2.7.3,docker.io/grafana/grafana:13.0.1-security-01   app.kubernetes.io/instance=kube-prometheus-stack,app.kubernetes.io/name=grafana
deployment.apps/kube-prometheus-stack-kube-state-metrics   1/1     1            1           111m    kube-state-metrics                                    registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.19.0                                                        app.kubernetes.io/instance=kube-prometheus-stack,app.kubernetes.io/name=kube-state-metrics
deployment.apps/kube-prometheus-stack-operator             1/1     1            1           111m    kube-prometheus-stack                                 quay.io/prometheus-operator/prometheus-operator:v0.90.1                                                              app=kube-prometheus-stack-operator,release=kube-prometheus-stack
deployment.apps/otel-collector                             1/1     1            1           8m15s   otel-collector                                        otel/opentelemetry-collector-contrib:0.111.0                                                                         app.kubernetes.io/name=otel-collector
NAME                                                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                         AGE     SELECTOR
service/kube-prometheus-stack-alertmanager               ClusterIP   172.20.167.225   <none>        9093/TCP,8080/TCP                               111m    alertmanager=kube-prometheus-stack-alertmanager,app.kubernetes.io/name=alertmanager
service/kube-prometheus-stack-grafana                    ClusterIP   172.20.29.140    <none>        80/TCP                                          111m    app.kubernetes.io/instance=kube-prometheus-stack,app.kubernetes.io/name=grafana
service/kube-prometheus-stack-kube-state-metrics         ClusterIP   172.20.124.21    <none>        8080/TCP                                        111m    app.kubernetes.io/instance=kube-prometheus-stack,app.kubernetes.io/name=kube-state-metrics
service/kube-prometheus-stack-operator                   ClusterIP   172.20.2.80      <none>        443/TCP                                         111m    app=kube-prometheus-stack-operator,release=kube-prometheus-stack
service/kube-prometheus-stack-prometheus                 ClusterIP   172.20.74.139    <none>        9090/TCP,8080/TCP                               111m    app.kubernetes.io/name=prometheus,operator.prometheus.io/name=kube-prometheus-stack-prometheus
service/kube-prometheus-stack-prometheus-node-exporter   ClusterIP   172.20.231.67    <none>        9100/TCP                                        111m    app.kubernetes.io/instance=kube-prometheus-stack,app.kubernetes.io/name=prometheus-node-exporter
service/loki                                             ClusterIP   172.20.165.63    <none>        3100/TCP,9095/TCP                               71m     app.kubernetes.io/component=single-binary,app.kubernetes.io/instance=loki,app.kubernetes.io/name=loki
service/loki-headless                                    ClusterIP   None             <none>        3100/TCP                                        71m     app.kubernetes.io/instance=loki,app.kubernetes.io/name=loki
service/loki-memberlist                                  ClusterIP   None             <none>        7946/TCP                                        71m     app.kubernetes.io/instance=loki,app.kubernetes.io/name=loki,app.kubernetes.io/part-of=memberlist
service/otel-collector                                   ClusterIP   172.20.181.189   <none>        4317/TCP,4318/TCP,8888/TCP,8889/TCP,13133/TCP   8m16s   app.kubernetes.io/name=otel-collector
service/prometheus-operated                              ClusterIP   None             <none>        9090/TCP                                        111m    app.kubernetes.io/name=prometheus
NAME                                                            READY   STATUS    RESTARTS   AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
pod/alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   0          43m     10.10.62.25    ip-10-10-51-233.ec2.internal   <none>           <none>
pod/kube-prometheus-stack-grafana-5f8d49b54c-lczq2              3/3     Running   0          4m14s   10.10.58.123   ip-10-10-59-138.ec2.internal   <none>           <none>
pod/kube-prometheus-stack-kube-state-metrics-64659c7c5c-xmbbz   1/1     Running   0          53m     10.10.45.107   ip-10-10-37-16.ec2.internal    <none>           <none>
pod/kube-prometheus-stack-operator-8564f47cff-vvvnh             1/1     Running   0          52m     10.10.41.21    ip-10-10-37-16.ec2.internal    <none>           <none>
pod/kube-prometheus-stack-prometheus-node-exporter-2mn94        1/1     Running   0          54m     10.10.37.16    ip-10-10-37-16.ec2.internal    <none>           <none>
pod/kube-prometheus-stack-prometheus-node-exporter-925qv        1/1     Running   0          50m     10.10.59.138   ip-10-10-59-138.ec2.internal   <none>           <none>
pod/kube-prometheus-stack-prometheus-node-exporter-cj27n        1/1     Running   0          42m     10.10.61.91    ip-10-10-61-91.ec2.internal    <none>           <none>
pod/kube-prometheus-stack-prometheus-node-exporter-pgwdt        1/1     Running   0          56m     10.10.34.177   ip-10-10-34-177.ec2.internal   <none>           <none>
pod/kube-prometheus-stack-prometheus-node-exporter-v2m65        1/1     Running   0          52m     10.10.51.233   ip-10-10-51-233.ec2.internal   <none>           <none>
pod/loki-0                                                      2/2     Running   0          31m     10.10.53.75    ip-10-10-61-91.ec2.internal    <none>           <none>
pod/otel-collector-6f554966d7-v7wbh                             1/1     Running   0          8m16s   10.10.63.217   ip-10-10-59-138.ec2.internal   <none>           <none>
pod/prometheus-kube-prometheus-stack-prometheus-0               2/2     Running   0          43m     10.10.38.89    ip-10-10-37-16.ec2.internal    <none>           <none>
pod/promtail-7czrn                                              1/1     Running   0          26m     10.10.63.6     ip-10-10-51-233.ec2.internal   <none>           <none>
pod/promtail-dczbq                                              1/1     Running   0          26m     10.10.51.75    ip-10-10-61-91.ec2.internal    <none>           <none>
pod/promtail-dhlpf                                              1/1     Running   0          26m     10.10.42.215   ip-10-10-37-16.ec2.internal    <none>           <none>
pod/promtail-lx9q4                                              1/1     Running   0          26m     10.10.33.199   ip-10-10-34-177.ec2.internal   <none>           <none>
pod/promtail-twhxw                                              1/1     Running   0          26m     10.10.62.205   ip-10-10-59-138.ec2.internal   <none>           <none>
```

## Variáveis dos Deployments ToggleMaster

```text

---- deployment/analytics-service ----
container=analytics-service image=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb
env:AWS_ACCESS_KEY_ID=
env:AWS_SECRET_ACCESS_KEY=
env:AWS_SESSION_TOKEN=
envFrom=togglemaster-runtime-config

---- deployment/auth-service ----
container=auth-service image=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb
env:DATABASE_URL=
env:MASTER_KEY=
envFrom=togglemaster-runtime-config

---- deployment/evaluation-service ----
container=evaluation-service image=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb
env:SERVICE_API_KEY=
env:AWS_ACCESS_KEY_ID=
env:AWS_SECRET_ACCESS_KEY=
env:AWS_SESSION_TOKEN=
envFrom=togglemaster-runtime-config

---- deployment/flag-service ----
container=flag-service image=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb
env:DATABASE_URL=
envFrom=togglemaster-runtime-config

---- deployment/targeting-service ----
container=targeting-service image=590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb
env:DATABASE_URL=
envFrom=togglemaster-runtime-config
```

## Busca OTEL/OpenTelemetry no repositório

```text
fase3/README.md:23:- credenciais temporárias não devem ser salvas no Git;
fase3/local/scripts/19_validate_phase3_apps_pre_fase4.sh:251:  echo "ERRO: $name não respondeu em tempo hábil."
fase3/local/scripts/18_checkpoint_retomada_pre_fase4.sh:126:  echo "Carregue as credenciais temporárias do AWS Academy Lab e reexecute este bloco."
fase3/docs/evidencias/fase3-aws-blocos-01-03-identificacao-lab.md:14:- credenciais temporárias carregadas no terminal sem versionamento;
fase3/docs/evidencias/fase3-aws-bloco07-apply-timeout-eks.md:50:A AWS aceitou a criação do cluster EKS, mas o tempo padrão de espera do provider Terraform foi insuficiente para o ambiente AWS Academy.
fase3/docs/evidencias/fase3-aws-bloco17ae-deploy-gitops-e2e-cloud.md:186:- credenciais AWS temporárias estavam carregadas;
fase3/docs/evidencias/fase3-aws-bloco17ae-deploy-gitops-e2e-cloud.md:218:Como o AWS Academy usa credenciais temporárias, o Secret operacional deve ser recriado ou atualizado quando uma nova sessão de Lab for iniciada.
fase3/docs/evidencias/fase3-aws-bloco05-networking-nat-pre-plan.md:56:Essa decisão reduz custo, tempo de criação e consumo de quota do Lab, mantendo conectividade real para as subnets privadas.
fase3/docs/evidencias/fase3-bloco14-secrets-module-offline.md:21:- credenciais temporárias.
fase3/docs/evidencias/fase3-aws-bloco13-retomada-lab.md:11:As credenciais temporárias da nova sessão foram carregadas na VM sem versionamento.
fase3/docs/evidencias/fase3-aws-bloco16d-runtime-secrets-inventario.md:23:As credenciais temporárias da sessão estavam carregadas na VM:
fase3/docs/evidencias/fase3-bloco19-5-refresh-pod-aws-creds.md:9:Este bloco atualiza apenas as chaves AWS temporárias no Kubernetes Secret operacional `togglemaster-runtime-secret`, sem exibir valores sensíveis, e reinicia somente os deployments afetados:
fase3/docs/operacional/pre-aws-academy-checklist.md:66:- usar apenas credenciais temporárias do Lab;
fase3/docs/operacional/pre-aws-academy-checklist.md:82:1. credenciais temporárias disponíveis;
fase3/docs/operacional/pre-aws-academy-checklist.md:100:O primeiro comando AWS permitido deverá ser apenas de identificação, depois que o Lab estiver aberto e as credenciais temporárias estiverem carregadas:
fase4/README.md:23:- OpenTelemetry Collector como ponto central de telemetria.
fase4/scripts/33_12_finalize_promtail_loki.sh:92:echo "[4/13] Limpando pods temporários antigos de teste"
fase4/scripts/31_validate_grafana_access.sh:62:echo "[3/8] Abrindo port-forward temporário"
fase4/scripts/31_validate_grafana_access.sh:158:  echo "- Port-forward local temporário usado no teste: \`http://localhost:${LOCAL_PORT}\`"
fase4/scripts/29_prepare_observability_gitops.sh:147:helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts >/dev/null 2>&1 || true
fase4/scripts/29_prepare_observability_gitops.sh:184:OTEL_COLLECTOR_VERSION="$(chart_version open-telemetry/opentelemetry-collector)"
fase4/scripts/29_prepare_observability_gitops.sh:189:echo "OTEL_COLLECTOR_VERSION=$OTEL_COLLECTOR_VERSION"
fase4/scripts/29_prepare_observability_gitops.sh:198:  echo "- opentelemetry-collector: \`$OTEL_COLLECTOR_VERSION\`"
fase4/scripts/29_prepare_observability_gitops.sh:407:cat > fase4/gitops/observability/values/opentelemetry-collector-values.yaml <<'EOF'
fase4/scripts/29_prepare_observability_gitops.sh:411:  repository: otel/opentelemetry-collector-contrib
fase4/scripts/29_prepare_observability_gitops.sh:466:      traces:
fase4/scripts/29_prepare_observability_gitops.sh:733:cat > fase4/gitops/apps/observability/opentelemetry-collector-application.yaml <<EOF
fase4/scripts/29_prepare_observability_gitops.sh:737:  name: observability-opentelemetry-collector
fase4/scripts/29_prepare_observability_gitops.sh:744:    - repoURL: https://open-telemetry.github.io/opentelemetry-helm-charts
fase4/scripts/29_prepare_observability_gitops.sh:745:      chart: opentelemetry-collector
fase4/scripts/29_prepare_observability_gitops.sh:746:      targetRevision: ${OTEL_COLLECTOR_VERSION}
fase4/scripts/29_prepare_observability_gitops.sh:748:        releaseName: opentelemetry-collector
fase4/scripts/29_prepare_observability_gitops.sh:750:          - \$values/fase4/gitops/observability/values/opentelemetry-collector-values.yaml
fase4/scripts/29_prepare_observability_gitops.sh:775:  - opentelemetry-collector-application.yaml
fase4/scripts/29_prepare_observability_gitops.sh:787:A Fase 4 exige uma stack open source com Prometheus, Grafana e Loki no Kubernetes, além do OpenTelemetry Collector como componente obrigatório.
fase4/scripts/29_prepare_observability_gitops.sh:798:- \`opentelemetry-collector\` para receber telemetria OTLP e expor métricas;
fase4/scripts/29_prepare_observability_gitops.sh:806:- opentelemetry-collector: \`${OTEL_COLLECTOR_VERSION}\`
fase4/scripts/29_prepare_observability_gitops.sh:837:record_cmd "Helm template opentelemetry-collector" helm template opentelemetry-collector open-telemetry/opentelemetry-collector \
fase4/scripts/29_prepare_observability_gitops.sh:838:  --version "$OTEL_COLLECTOR_VERSION" \
fase4/scripts/29_prepare_observability_gitops.sh:840:  -f fase4/gitops/observability/values/opentelemetry-collector-values.yaml
fase4/scripts/27_terraform_plan_eks_capacity.sh:96:- salva o plano binário apenas em diretório temporário não versionado;
fase4/scripts/27_terraform_plan_eks_capacity.sh:291:O plano binário foi salvo em diretório temporário não versionado e não deve ser commitado.
fase4/scripts/23_inventory_phase4_stack.sh:171:record_cmd "Namespaces de observabilidade existentes" bash -lc "kubectl get ns | grep -Ei 'monitor|observ|grafana|prometheus|loki|tempo|otel|datadog|newrelic' || true"
fase4/scripts/23_inventory_phase4_stack.sh:172:record_cmd "Pods de observabilidade em todos namespaces" bash -lc "kubectl get pods -A | grep -Ei 'prometheus|grafana|loki|tempo|otel|collector|alloy|datadog|newrelic' || true"
fase4/scripts/23_inventory_phase4_stack.sh:197:- OpenTelemetry Collector obrigatório.
fase4/scripts/23_inventory_phase4_stack.sh:212:   - OpenTelemetry Collector como hub obrigatório.
fase4/scripts/25_plan_observability_capacity_fix.sh:220:# - otel-collector
fase4/scripts/25_plan_observability_capacity_fix.sh:336:A Fase 4 exige Prometheus, Grafana, Loki, OpenTelemetry Collector, APM, alertas, incidentes, ChatOps e self-healing operando na prática. Portanto, instalar a stack sem corrigir capacidade seria inseguro.
fase4/scripts/35_0_inventory_apm_tracing.sh:7:EVID="$PHASE/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md"
fase4/scripts/35_0_inventory_apm_tracing.sh:8:LOG="$PHASE/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.log"
fase4/scripts/35_0_inventory_apm_tracing.sh:20:# Fase 4 - BLOCO 35.0 - Inventário APM/tracing
fase4/scripts/35_0_inventory_apm_tracing.sh:24:Inventariar o estado atual da instrumentação, dos serviços e dos manifests antes de implementar APM/tracing real.
fase4/scripts/35_0_inventory_apm_tracing.sh:48:kubectl get application observability-otel-collector observability-loki observability-promtail observability-kube-prometheus-stack -n "$ARGO_NS" -o wide || true
fase4/scripts/35_0_inventory_apm_tracing.sh:49:kubectl get deploy,svc,pods -n "$OBS_NS" -o wide | grep -E 'NAME|otel-collector|loki|promtail|grafana|prometheus' || true
fase4/scripts/35_0_inventory_apm_tracing.sh:60:echo "[6/12] Busca por OTEL/OpenTelemetry no repositório"
fase4/scripts/35_0_inventory_apm_tracing.sh:62:  grep -RInE 'OTEL|OpenTelemetry|opentelemetry|trace|tracing|jaeger|tempo|xray|collector' \
fase4/scripts/35_0_inventory_apm_tracing.sh:108:if re.search(r"OTEL|OpenTelemetry|opentelemetry", repo_grep, re.I):
fase4/scripts/35_0_inventory_apm_tracing.sh:109:    print("- Foram encontrados sinais de OpenTelemetry/OTEL no repositório. Revisar ocorrências acima.")
fase4/scripts/35_0_inventory_apm_tracing.sh:111:    print("- Não foram encontrados sinais fortes de instrumentação OpenTelemetry já existente nos serviços.")
fase4/scripts/35_0_inventory_apm_tracing.sh:114:    print("- Há serviços Go no projeto; instrumentação pode exigir bibliotecas/SDK OpenTelemetry para Go ou sidecar/auto-instrumentation se viável.")
fase4/scripts/35_0_inventory_apm_tracing.sh:118:    print("- Há serviços Node.js no projeto; instrumentação pode ser feita por SDK OpenTelemetry JS se aplicável.")
fase4/scripts/35_0_inventory_apm_tracing.sh:120:if "OTEL_EXPORTER_OTLP_ENDPOINT" in envs or "OTEL_SERVICE_NAME" in envs:
fase4/scripts/35_0_inventory_apm_tracing.sh:121:    print("- Há variáveis OTEL já configuradas em algum Deployment.")
fase4/scripts/35_0_inventory_apm_tracing.sh:123:    print("- Não há variáveis OTEL evidentes nos Deployments atuais.")
fase4/scripts/35_0_inventory_apm_tracing.sh:129:print("- Priorizar o caminho que gere trace real de requisição entre serviços, para preparar Figura 7 e Figura 8.")
fase4/scripts/35_0_inventory_apm_tracing.sh:130:print("- Manter OTel Collector como endpoint OTLP interno: http://otel-collector.observability.svc.cluster.local:4318 ou gRPC 4317.")
fase4/scripts/35_0_inventory_apm_tracing.sh:134:print("- Figura 7: service map/APM depois que traces reais existirem.")
fase4/scripts/35_0_inventory_apm_tracing.sh:135:print("- Figura 8: trace distribuído depois que uma requisição E2E gerar spans encadeados.")
fase4/scripts/35_0_inventory_apm_tracing.sh:165:  kubectl get application observability-otel-collector observability-loki observability-promtail observability-kube-prometheus-stack -n "$ARGO_NS" -o wide || true
fase4/scripts/35_0_inventory_apm_tracing.sh:166:  kubectl get deploy,svc,pods -n "$OBS_NS" -o wide | grep -E 'NAME|otel-collector|loki|promtail|grafana|prometheus' || true
fase4/scripts/35_0_inventory_apm_tracing.sh:175:  echo "## Busca OTEL/OpenTelemetry no repositório"
fase4/scripts/34_apply_otel_collector_gitops.sh:7:SCRIPT="$PHASE/scripts/34_apply_otel_collector_gitops.sh"
fase4/scripts/34_apply_otel_collector_gitops.sh:8:EVID="$PHASE/docs/evidencias/fase4-bloco34-otel-collector.md"
fase4/scripts/34_apply_otel_collector_gitops.sh:9:LOG="$PHASE/docs/evidencias/fase4-bloco34-otel-collector.log"
fase4/scripts/34_apply_otel_collector_gitops.sh:12:APP="observability-otel-collector"
fase4/scripts/34_apply_otel_collector_gitops.sh:15:APP_FILE="$PHASE/gitops/apps/observability/otel-collector-application.yaml"
fase4/scripts/34_apply_otel_collector_gitops.sh:17:OTEL_DIR="$PHASE/gitops/observability/otel-collector"
fase4/scripts/34_apply_otel_collector_gitops.sh:22:mkdir -p "$PHASE/docs/evidencias" "$TMP" "$OTEL_DIR"
fase4/scripts/34_apply_otel_collector_gitops.sh:36:# Fase 4 - BLOCO 34 - OpenTelemetry Collector via GitOps
fase4/scripts/34_apply_otel_collector_gitops.sh:40:Implantar o OpenTelemetry Collector como hub de telemetria da Fase 4, em modo controlado, via GitOps/ArgoCD.
fase4/scripts/34_apply_otel_collector_gitops.sh:51:O APM externo, service map e trace distribuído serão tratados em blocos posteriores.
fase4/scripts/34_apply_otel_collector_gitops.sh:77:echo "[2/16] Criando ConfigMap do OpenTelemetry Collector"
fase4/scripts/34_apply_otel_collector_gitops.sh:78:cat > "$OTEL_DIR/configmap.yaml" <<'YAML'
fase4/scripts/34_apply_otel_collector_gitops.sh:82:  name: otel-collector-config
fase4/scripts/34_apply_otel_collector_gitops.sh:85:    app.kubernetes.io/name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:88:  otel-collector-config.yaml: |
fase4/scripts/34_apply_otel_collector_gitops.sh:123:        traces:
fase4/scripts/34_apply_otel_collector_gitops.sh:152:cat > "$OTEL_DIR/deployment.yaml" <<'YAML'
fase4/scripts/34_apply_otel_collector_gitops.sh:156:  name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:159:    app.kubernetes.io/name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:165:      app.kubernetes.io/name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:169:        app.kubernetes.io/name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:179:        - name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:180:          image: otel/opentelemetry-collector-contrib:0.111.0
fase4/scripts/34_apply_otel_collector_gitops.sh:183:            - --config=/conf/otel-collector-config.yaml
fase4/scripts/34_apply_otel_collector_gitops.sh:224:            - name: otel-collector-config
fase4/scripts/34_apply_otel_collector_gitops.sh:228:        - name: otel-collector-config
fase4/scripts/34_apply_otel_collector_gitops.sh:230:            name: otel-collector-config
fase4/scripts/34_apply_otel_collector_gitops.sh:235:cat > "$OTEL_DIR/service.yaml" <<'YAML'
fase4/scripts/34_apply_otel_collector_gitops.sh:239:  name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:242:    app.kubernetes.io/name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:247:    app.kubernetes.io/name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:268:cat > "$OTEL_DIR/servicemonitor.yaml" <<'YAML'
fase4/scripts/34_apply_otel_collector_gitops.sh:272:  name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:275:    app.kubernetes.io/name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:284:      app.kubernetes.io/name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:296:cat > "$OTEL_DIR/kustomization.yaml" <<'YAML'
fase4/scripts/34_apply_otel_collector_gitops.sh:312:  name: observability-otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:315:    app.kubernetes.io/name: otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:322:    path: fase4/gitops/observability/otel-collector
fase4/scripts/34_apply_otel_collector_gitops.sh:343:resource = "  - otel-collector-application.yaml"
fase4/scripts/34_apply_otel_collector_gitops.sh:345:if "otel-collector-application.yaml" not in text:
fase4/scripts/34_apply_otel_collector_gitops.sh:351:    print("OK: otel-collector-application.yaml adicionado ao kustomization.")
fase4/scripts/34_apply_otel_collector_gitops.sh:353:    print("OK: otel-collector-application.yaml já estava no kustomization.")
fase4/scripts/34_apply_otel_collector_gitops.sh:360:  - otel-collector-application.yaml
fase4/scripts/34_apply_otel_collector_gitops.sh:366:kubectl kustomize "$OTEL_DIR" > "$TMP/otel-render.yaml"
fase4/scripts/34_apply_otel_collector_gitops.sh:370:grep -n "name: otel-collector" "$TMP/otel-render.yaml" | head -20
fase4/scripts/34_apply_otel_collector_gitops.sh:384:    Path("fase4/gitops/apps/observability/otel-collector-application.yaml"),
fase4/scripts/34_apply_otel_collector_gitops.sh:386:    Path("fase4/gitops/observability/otel-collector/configmap.yaml"),
fase4/scripts/34_apply_otel_collector_gitops.sh:387:    Path("fase4/gitops/observability/otel-collector/deployment.yaml"),
fase4/scripts/34_apply_otel_collector_gitops.sh:388:    Path("fase4/gitops/observability/otel-collector/service.yaml"),
fase4/scripts/34_apply_otel_collector_gitops.sh:389:    Path("fase4/gitops/observability/otel-collector/servicemonitor.yaml"),
fase4/scripts/34_apply_otel_collector_gitops.sh:390:    Path("fase4/gitops/observability/otel-collector/kustomization.yaml"),
fase4/scripts/34_apply_otel_collector_gitops.sh:391:    Path("fase4/scripts/34_apply_otel_collector_gitops.sh"),
fase4/scripts/34_apply_otel_collector_gitops.sh:392:    Path("fase4/docs/evidencias/fase4-bloco34-otel-collector.md"),
fase4/scripts/34_apply_otel_collector_gitops.sh:429:  find "$OTEL_DIR" -maxdepth 1 -type f | sort
fase4/scripts/34_apply_otel_collector_gitops.sh:437:  echo "kubectl kustomize $OTEL_DIR OK"
fase4/scripts/34_apply_otel_collector_gitops.sh:449:  git diff -- "$PHASE/gitops/apps/observability" "$OTEL_DIR" "$SCRIPT" "$EVID"
fase4/scripts/34_apply_otel_collector_gitops.sh:457:git add "$PHASE/gitops/apps/observability" "$OTEL_DIR" "$SCRIPT" "$EVID"
fase4/scripts/34_apply_otel_collector_gitops.sh:464:git commit -m "feat: add phase 4 otel collector gitops"
fase4/scripts/34_apply_otel_collector_gitops.sh:488:  DEP_AVAIL="$(kubectl get deploy otel-collector -n "$OBS_NS" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
fase4/scripts/34_apply_otel_collector_gitops.sh:489:  POD_LINE="$(kubectl get pods -n "$OBS_NS" --no-headers 2>/dev/null | awk '/otel-collector/ {print $0}' || true)"
fase4/scripts/34_apply_otel_collector_gitops.sh:492:  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|otel-collector' || true
fase4/scripts/34_apply_otel_collector_gitops.sh:504:DEP_AVAIL="$(kubectl get deploy otel-collector -n "$OBS_NS" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
fase4/scripts/34_apply_otel_collector_gitops.sh:509:  kubectl describe deploy otel-collector -n "$OBS_NS" || true
fase4/scripts/34_apply_otel_collector_gitops.sh:516:pkill -f "kubectl.*port-forward.*svc/otel-collector" >/dev/null 2>&1 || true
fase4/scripts/34_apply_otel_collector_gitops.sh:517:kubectl -n "$OBS_NS" port-forward svc/otel-collector "${LOCAL_OTLP_PORT}:4318" "${LOCAL_HEALTH_PORT}:13133" > "$TMP/otel-port-forward.log" 2>&1 &
fase4/scripts/34_apply_otel_collector_gitops.sh:535:MARKER="TOGGLEMASTER_OTEL_LOG_$(date +%s)"
fase4/scripts/34_apply_otel_collector_gitops.sh:567:                                {"key": "component", "value": {"stringValue": "otel-collector-validation"}}
fase4/scripts/34_apply_otel_collector_gitops.sh:600:OTEL_MARKER_FOUND="false"
fase4/scripts/34_apply_otel_collector_gitops.sh:603:  kubectl logs deploy/otel-collector -n "$OBS_NS" --tail=500 > "$TMP/otel-collector-logs.txt" 2>&1 || true
fase4/scripts/34_apply_otel_collector_gitops.sh:605:  if grep -q "$MARKER" "$TMP/otel-collector-logs.txt"; then
fase4/scripts/34_apply_otel_collector_gitops.sh:606:    OTEL_MARKER_FOUND="true"
fase4/scripts/34_apply_otel_collector_gitops.sh:615:if [ "$OTEL_MARKER_FOUND" != "true" ]; then
fase4/scripts/34_apply_otel_collector_gitops.sh:617:  cat "$TMP/otel-collector-logs.txt" | tail -120 || true
fase4/scripts/34_apply_otel_collector_gitops.sh:628:  echo "OTEL_APP=$APP_SYNC/$APP_HEALTH"
fase4/scripts/34_apply_otel_collector_gitops.sh:631:  echo "OTEL_MARKER_FOUND=$OTEL_MARKER_FOUND"
fase4/scripts/34_apply_otel_collector_gitops.sh:643:  kubectl get deploy,svc,servicemonitor -n "$OBS_NS" | grep -E 'NAME|otel-collector' || true
fase4/scripts/34_apply_otel_collector_gitops.sh:644:  kubectl get pods -n "$OBS_NS" -o wide | grep -E 'NAME|otel-collector' || true
fase4/scripts/34_apply_otel_collector_gitops.sh:668:  grep -A8 -B8 "$MARKER" "$TMP/otel-collector-logs.txt" || true
fase4/scripts/34_apply_otel_collector_gitops.sh:675:echo "OTEL_APP=$APP_SYNC/$APP_HEALTH"
fase4/scripts/34_apply_otel_collector_gitops.sh:677:echo "OTEL_MARKER_FOUND=$OTEL_MARKER_FOUND"
fase4/scripts/24_capacity_gate_observability.sh:251:print(f"- ESTIMATED_OTEL_PODS={estimated_otel_pods}")
fase4/scripts/30_apply_prometheus_grafana_argocd.sh:145:  echo "ERRO: $app não ficou Synced/Healthy dentro do tempo esperado."
fase4/scripts/30_apply_prometheus_grafana_argocd.sh:162:Este bloco não instala Loki, Promtail, OpenTelemetry Collector, APM externo, incident management, ChatOps ou self-healing.
fase4/scripts/30_apply_prometheus_grafana_argocd.sh:332:- OpenTelemetry Collector;
fase4/docs/fase4-matriz-requisitos.md:15:| F4-03 | Grafana | Dashboard customizado | Print/dashboard com saúde do cluster, requests dos microsserviços e logs em tempo real | Pendente |
fase4/docs/fase4-matriz-requisitos.md:16:| F4-04 | OpenTelemetry Collector | Collector recebendo/processando/exportando telemetria | Manifests, pods e fluxo documentado | Pendente |
fase4/docs/fase4-matriz-requisitos.md:17:| F4-05 | Instrumentação dos 5 serviços | Bibliotecas/configuração OTel nos serviços | Requisições gerando métricas/traces/logs | Pendente |
fase4/docs/fase4-matriz-requisitos.md:18:| F4-06 | APM | Datadog ou New Relic | Service Map e trace distribuído de requisição real | Pendente |
fase4/docs/fase4-matriz-requisitos.md:35:5. APM exibindo Service Map e trace distribuído.
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:163:- opentelemetry-collector: `0.156.2`
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:396:  name: observability-opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:404:  - chart: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:406:      releaseName: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:408:      - $values/fase4/gitops/observability/values/opentelemetry-collector-values.yaml
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:409:    repoURL: https://open-telemetry.github.io/opentelemetry-helm-charts
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:2147:            - --collector.filesystem.mount-points-exclude=^/(dev|proc|sys|run/containerd/.+|var/lib/docker/.+|var/lib/kubelet/.+)($|/)
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:2148:            - --collector.filesystem.fs-types-exclude=^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs|erofs)$
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:5537:        description: Node Exporter text file collector on {{ $labels.instance }} failed to scrape.
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:5538:        runbook_url: https://runbooks.prometheus-operator.dev/runbooks/node/nodetextfilecollectorscrapeerror
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:5539:        summary: Node Exporter text file collector failed to scrape.
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:7153:    tracing:
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:7888:    tracing:
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8036:### Helm template opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8039:$ helm template opentelemetry-collector open-telemetry/opentelemetry-collector --version 0.156.2 --namespace observability -f fase4/gitops/observability/values/opentelemetry-collector-values.yaml
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8041:# Source: opentelemetry-collector/templates/serviceaccount.yaml
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8045:  name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8048:    helm.sh/chart: opentelemetry-collector-0.156.2
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8049:    app.kubernetes.io/name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8050:    app.kubernetes.io/instance: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8053:    app.kubernetes.io/part-of: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8054:    app.kubernetes.io/component: standalone-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8056:# Source: opentelemetry-collector/templates/configmap.yaml
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8060:  name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8063:    helm.sh/chart: opentelemetry-collector-0.156.2
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8064:    app.kubernetes.io/name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8065:    app.kubernetes.io/instance: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8068:    app.kubernetes.io/part-of: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8069:    app.kubernetes.io/component: standalone-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8086:      jaeger:
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8103:          - job_name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8129:        traces:
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8145:          host.name: ${env:OTEL_K8S_NODE_NAME}
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8146:          k8s.namespace.name: ${env:OTEL_K8S_NAMESPACE}
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8147:          k8s.node.ip: ${env:OTEL_K8S_NODE_IP}
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8148:          k8s.node.name: ${env:OTEL_K8S_NODE_NAME}
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8149:          k8s.pod.ip: ${env:OTEL_K8S_POD_IP}
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8150:          k8s.pod.name: ${env:OTEL_K8S_POD_NAME}
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8152:# Source: opentelemetry-collector/templates/service.yaml
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8156:  name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8159:    helm.sh/chart: opentelemetry-collector-0.156.2
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8160:    app.kubernetes.io/name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8161:    app.kubernetes.io/instance: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8164:    app.kubernetes.io/part-of: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8165:    app.kubernetes.io/component: standalone-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8166:    component: standalone-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8171:    - name: jaeger-compact
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8175:    - name: jaeger-grpc
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8179:    - name: jaeger-thrift
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8201:    app.kubernetes.io/name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8202:    app.kubernetes.io/instance: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8203:    component: standalone-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8206:# Source: opentelemetry-collector/templates/deployment.yaml
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8210:  name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8213:    helm.sh/chart: opentelemetry-collector-0.156.2
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8214:    app.kubernetes.io/name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8215:    app.kubernetes.io/instance: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8218:    app.kubernetes.io/part-of: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8219:    app.kubernetes.io/component: standalone-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8225:      app.kubernetes.io/name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8226:      app.kubernetes.io/instance: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8227:      component: standalone-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8236:        app.kubernetes.io/name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8237:        app.kubernetes.io/instance: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8238:        component: standalone-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8242:      serviceAccountName: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8247:        - name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8252:          image: "otel/opentelemetry-collector-contrib:0.152.0"
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8256:            - name: jaeger-compact
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8259:            - name: jaeger-grpc
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8262:            - name: jaeger-thrift
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8283:            - name: OTEL_K8S_NODE_NAME
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8287:            - name: OTEL_K8S_NODE_IP
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8291:            - name: OTEL_K8S_NAMESPACE
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8296:            - name: OTEL_K8S_POD_NAME
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8301:            - name: OTEL_K8S_POD_IP
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8324:              name: opentelemetry-collector-configmap
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8327:        - name: opentelemetry-collector-configmap
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8329:            name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8336:# Source: opentelemetry-collector/templates/servicemonitor.yaml
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8340:  name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8343:    helm.sh/chart: opentelemetry-collector-0.156.2
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8344:    app.kubernetes.io/name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8345:    app.kubernetes.io/instance: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8348:    app.kubernetes.io/part-of: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8349:    app.kubernetes.io/component: standalone-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8353:      app.kubernetes.io/name: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8354:      app.kubernetes.io/instance: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8355:      component: standalone-collector
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8374:fase4/gitops/apps/observability/opentelemetry-collector-application.yaml
fase4/docs/evidencias/fase4-bloco29-gitops-helm-observability.md:8384:fase4/gitops/observability/values/opentelemetry-collector-values.yaml
fase4/docs/evidencias/fase4-bloco24-capacity-gate-observability.md:211:- ESTIMATED_OTEL_PODS=1
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:12:Este bloco não instala Loki, Promtail, OpenTelemetry Collector, APM externo, incident management, ChatOps ou self-healing.
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:233:  name: observability-opentelemetry-collector
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:241:  - chart: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:243:      releaseName: opentelemetry-collector
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:245:      - $values/fase4/gitops/observability/values/opentelemetry-collector-values.yaml
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:246:    repoURL: https://open-telemetry.github.io/opentelemetry-helm-charts
fase4/docs/evidencias/fase4-bloco30-prometheus-grafana-argocd.md:555:- OpenTelemetry Collector;
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:1:# Fase 4 - BLOCO 34 - OpenTelemetry Collector via GitOps
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:5:Implantar o OpenTelemetry Collector como hub de telemetria da Fase 4, em modo controlado, via GitOps/ArgoCD.
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:16:O APM externo, service map e trace distribuído serão tratados em blocos posteriores.
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:60:fase4/gitops/observability/otel-collector/configmap.yaml
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:61:fase4/gitops/observability/otel-collector/deployment.yaml
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:62:fase4/gitops/observability/otel-collector/kustomization.yaml
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:63:fase4/gitops/observability/otel-collector/servicemonitor.yaml
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:64:fase4/gitops/observability/otel-collector/service.yaml
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:65:fase4/gitops/apps/observability/otel-collector-application.yaml
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:72:kubectl kustomize fase4/gitops/observability/otel-collector OK
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:91:   - opentelemetry-collector-application.yaml
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:92:+  - otel-collector-application.yaml
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:98:OTEL_APP=Synced/Healthy
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:101:OTEL_MARKER_FOUND=true
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:108:observability-otel-collector   Synced        Healthy         601ec5a1cef9df9dfd95fedc1916a2ce35411dd6   default
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:115:deployment.apps/otel-collector                             1/1     1            1           42s
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:117:service/otel-collector                                   ClusterIP   172.20.181.189   <none>        4317/TCP,4318/TCP,8888/TCP,8889/TCP,13133/TCP   42s
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:119:servicemonitor.monitoring.coreos.com/otel-collector                                   42s
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:121:otel-collector-6f554966d7-v7wbh                             1/1     Running   0          43s   10.10.63.217   ip-10-10-59-138.ec2.internal   <none>           <none>
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:140:MARKER=TOGGLEMASTER_OTEL_LOG_1779567521
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:154:Body: Str(TOGGLEMASTER_OTEL_LOG_1779567521)
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:156:     -> tc.marker: Str(TOGGLEMASTER_OTEL_LOG_1779567521)
fase4/docs/evidencias/fase4-bloco34-otel-collector.md:157:     -> component: Str(otel-collector-validation)
fase4/docs/evidencias/fase4-bloco23-inventario-stack.md:279:$ bash -lc kubectl get ns | grep -Ei 'monitor|observ|grafana|prometheus|loki|tempo|otel|datadog|newrelic' || true
fase4/docs/evidencias/fase4-bloco23-inventario-stack.md:288:$ bash -lc kubectl get pods -A | grep -Ei 'prometheus|grafana|loki|tempo|otel|collector|alloy|datadog|newrelic' || true
fase4/docs/evidencias/fase4-bloco33-8-loki-crashloop-diagnosis.md:121:    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
fase4/docs/evidencias/fase4-bloco33-8-loki-crashloop-diagnosis.md:133:    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
fase4/docs/evidencias/fase4-bloco33-8-loki-crashloop-diagnosis.md:209:{"time": "2026-05-23T19:42:52.936071+00:00", "level": "INFO", "msg": "Starting collector"}
fase4/docs/evidencias/fase4-bloco33-8-loki-crashloop-diagnosis.md:272:89:      {"apiVersion":"v1","data":{"config.yaml":"\nauth_enabled: false\nbloom_build:\n  builder:\n    planner_address: \"\"\n  enabled: false\nbloom_gateway:\n  client:\n    addresses: \"\"\n  enabled: false\ncommon:\n  compactor_grpc_address: 'loki.observability.svc.cluster.local:9095'\n  path_prefix: /var/loki\n  replication_factor: 1\n  storage:\n    filesystem:\n      chunks_directory: /var/loki/chunks\n      rules_directory: /var/loki/rules\ncompactor:\n  delete_request_store: filesystem\n  retention_enabled: true\nfrontend:\n  scheduler_address: \"\"\n  tail_proxy_url: \"\"\nfrontend_worker:\n  scheduler_address: \"\"\nindex_gateway:\n  mode: simple\nlimits_config:\n  max_cache_freshness_per_query: 10m\n  query_timeout: 300s\n  reject_old_samples: true\n  reject_old_samples_max_age: 168h\n  retention_period: 24h\n  split_queries_by_interval: 15m\n  volume_enabled: true\nmemberlist:\n  join_members:\n  - loki-memberlist.observability.svc.cluster.local\npattern_ingester:\n  enabled: false\nquery_range:\n  align_queries_with_step: true\nruler:\n  storage:\n    type: local\n  wal:\n    dir: /var/loki/ruler-wal\nruntime_config:\n  file: /etc/loki/runtime-config/runtime-config.yaml\nschema_config:\n  configs:\n  - from: \"2024-01-01\"\n    index:\n      period: 24h\n      prefix: index_\n    object_store: filesystem\n    schema: v13\n    store: tsdb\nserver:\n  grpc_listen_port: 9095\n  http_listen_port: 3100\n  http_server_read_timeout: 600s\n  http_server_write_timeout: 600s\nstorage_config:\n  bloom_shipper:\n    working_directory: /var/loki/data/bloomshipper\n  boltdb_shipper:\n    index_gateway_client:\n      server_address: \"\"\n  hedging:\n    at: 250ms\n    max_per_second: 20\n    up_to: 3\n  tsdb_shipper:\n    index_gateway_client:\n      server_address: \"\"\n  use_thanos_objstore: false\ntracing:\n  enabled: false\n"},"kind":"ConfigMap","metadata":{"annotations":{"argocd.argoproj.io/tracking-id":"observability-loki:/ConfigMap:observability/loki"},"labels":{"app.kubernetes.io/instance":"loki","app.kubernetes.io/name":"loki","app.kubernetes.io/version":"3.6.7","helm.sh/chart":"loki-7.0.0"},"name":"loki","namespace":"observability"}}
fase4/docs/evidencias/fase4-bloco27-terraform-plan-capacidade-eks.md:12:- salva o plano binário apenas em diretório temporário não versionado;
fase4/docs/evidencias/fase4-bloco27-terraform-plan-capacidade-eks.md:312:O plano binário foi salvo em diretório temporário não versionado e não deve ser commitado.
fase4/docs/evidencias/fase4-bloco31-grafana-access.md:17:- Port-forward local temporário usado no teste: `http://localhost:13000`
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:1:# Fase 4 - BLOCO 35.0 - Inventário APM/tracing
fase4/docs/evidencias/fase4-bloco35-0-inventario-apm-tracing.md:5:Inventariar o estado atual da instrumentação, dos serviços e dos manifests antes de implementar APM/tracing real.
fase4/docs/adr/ADR-001-fase4-estrategia-observabilidade.md:19:3. OpenTelemetry Collector.
fase4/docs/adr/ADR-004-fase4-gitops-helm-observability-stack.md:9:A Fase 4 exige uma stack open source com Prometheus, Grafana e Loki no Kubernetes, além do OpenTelemetry Collector como componente obrigatório.
fase4/docs/adr/ADR-004-fase4-gitops-helm-observability-stack.md:20:- `opentelemetry-collector` para receber telemetria OTLP e expor métricas;
fase4/docs/adr/ADR-004-fase4-gitops-helm-observability-stack.md:28:- opentelemetry-collector: `0.156.2`
fase4/docs/adr/ADR-003-fase4-correcao-capacidade-observabilidade.md:18:A Fase 4 exige Prometheus, Grafana, Loki, OpenTelemetry Collector, APM, alertas, incidentes, ChatOps e self-healing operando na prática. Portanto, instalar a stack sem corrigir capacidade seria inseguro.
fase4/docs/adr/ADR-002-fase4-stack-observabilidade-apm-incidentes.md:14:- OpenTelemetry Collector obrigatório.
fase4/docs/adr/ADR-002-fase4-stack-observabilidade-apm-incidentes.md:29:   - OpenTelemetry Collector como hub obrigatório.
fase4/gitops/apps/observability/opentelemetry-collector-application.yaml:4:  name: observability-opentelemetry-collector
fase4/gitops/apps/observability/opentelemetry-collector-application.yaml:11:    - repoURL: https://open-telemetry.github.io/opentelemetry-helm-charts
fase4/gitops/apps/observability/opentelemetry-collector-application.yaml:12:      chart: opentelemetry-collector
fase4/gitops/apps/observability/opentelemetry-collector-application.yaml:15:        releaseName: opentelemetry-collector
fase4/gitops/apps/observability/opentelemetry-collector-application.yaml:17:          - $values/fase4/gitops/observability/values/opentelemetry-collector-values.yaml
fase4/gitops/apps/observability/otel-collector-application.yaml:4:  name: observability-otel-collector
fase4/gitops/apps/observability/otel-collector-application.yaml:7:    app.kubernetes.io/name: otel-collector
fase4/gitops/apps/observability/otel-collector-application.yaml:14:    path: fase4/gitops/observability/otel-collector
fase4/gitops/apps/observability/kustomization.yaml:9:  - opentelemetry-collector-application.yaml
fase4/gitops/apps/observability/kustomization.yaml:10:  - otel-collector-application.yaml
fase4/gitops/observability/otel-collector/configmap.yaml:4:  name: otel-collector-config
fase4/gitops/observability/otel-collector/configmap.yaml:7:    app.kubernetes.io/name: otel-collector
fase4/gitops/observability/otel-collector/configmap.yaml:10:  otel-collector-config.yaml: |
fase4/gitops/observability/otel-collector/configmap.yaml:45:        traces:
fase4/gitops/observability/otel-collector/servicemonitor.yaml:4:  name: otel-collector
fase4/gitops/observability/otel-collector/servicemonitor.yaml:7:    app.kubernetes.io/name: otel-collector
fase4/gitops/observability/otel-collector/servicemonitor.yaml:16:      app.kubernetes.io/name: otel-collector
fase4/gitops/observability/otel-collector/service.yaml:4:  name: otel-collector
fase4/gitops/observability/otel-collector/service.yaml:7:    app.kubernetes.io/name: otel-collector
fase4/gitops/observability/otel-collector/service.yaml:12:    app.kubernetes.io/name: otel-collector
fase4/gitops/observability/otel-collector/deployment.yaml:4:  name: otel-collector
fase4/gitops/observability/otel-collector/deployment.yaml:7:    app.kubernetes.io/name: otel-collector
fase4/gitops/observability/otel-collector/deployment.yaml:13:      app.kubernetes.io/name: otel-collector
fase4/gitops/observability/otel-collector/deployment.yaml:17:        app.kubernetes.io/name: otel-collector
fase4/gitops/observability/otel-collector/deployment.yaml:27:        - name: otel-collector
fase4/gitops/observability/otel-collector/deployment.yaml:28:          image: otel/opentelemetry-collector-contrib:0.111.0
fase4/gitops/observability/otel-collector/deployment.yaml:31:            - --config=/conf/otel-collector-config.yaml
fase4/gitops/observability/otel-collector/deployment.yaml:72:            - name: otel-collector-config
fase4/gitops/observability/otel-collector/deployment.yaml:76:        - name: otel-collector-config
fase4/gitops/observability/otel-collector/deployment.yaml:78:            name: otel-collector-config
fase4/gitops/observability/values/opentelemetry-collector-values.yaml:4:  repository: otel/opentelemetry-collector-contrib
fase4/gitops/observability/values/opentelemetry-collector-values.yaml:59:      traces:
```

## Arquivos de dependência encontrados

```text
fase2/repos/upstream/analytics-service/Dockerfile
fase2/repos/upstream/analytics-service/requirements.txt
fase2/repos/upstream/auth-service/Dockerfile
fase2/repos/upstream/auth-service/go.mod
fase2/repos/upstream/evaluation-service/Dockerfile
fase2/repos/upstream/evaluation-service/go.mod
fase2/repos/upstream/flag-service/Dockerfile
fase2/repos/upstream/flag-service/requirements.txt
fase2/repos/upstream/targeting-service/Dockerfile
fase2/repos/upstream/targeting-service/requirements.txt
fase2/src/services/analytics-service/Dockerfile
fase2/src/services/analytics-service/requirements.txt
fase2/src/services/auth-service/Dockerfile
fase2/src/services/auth-service/go.mod
fase2/src/services/evaluation-service/Dockerfile
fase2/src/services/evaluation-service/go.mod
fase2/src/services/flag-service/Dockerfile
fase2/src/services/flag-service/requirements.txt
fase2/src/services/targeting-service/Dockerfile
fase2/src/services/targeting-service/requirements.txt
fase2/tmp/backups-bloco12-20260522-132137/src/services/analytics-service/requirements.txt
fase2/tmp/backups-bloco12-20260522-132137/src/services/auth-service/go.mod
fase2/tmp/backups-bloco12-20260522-132137/src/services/evaluation-service/go.mod
fase2/tmp/backups-bloco12-20260522-132137/src/services/flag-service/requirements.txt
fase2/tmp/backups-bloco12-20260522-132137/src/services/targeting-service/requirements.txt
```

## Imagens em execução

```text
analytics-service-6946467b6b-m7dkk	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/analytics-service:c0f03bb 
auth-service-584688f79d-4fvw5	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb 
auth-service-584688f79d-lkmfd	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/auth-service:c0f03bb 
evaluation-service-7949b95dd5-6vrk6	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb 
evaluation-service-7949b95dd5-tkxrk	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/evaluation-service:c0f03bb 
flag-service-7cd69f6bf9-6sv22	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb 
flag-service-7cd69f6bf9-lvvzs	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/flag-service:c0f03bb 
targeting-service-66d4bb78b6-ntdtf	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb 
targeting-service-66d4bb78b6-xz4vl	590183666984.dkr.ecr.us-east-1.amazonaws.com/togglemaster-dev/targeting-service:c0f03bb 
```

## Services e endpoints

```text
NAME                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
service/analytics-service    ClusterIP   172.20.81.122   <none>        8000/TCP   15h   app.kubernetes.io/name=analytics-service
service/auth-service         ClusterIP   172.20.222.48   <none>        8000/TCP   15h   app.kubernetes.io/name=auth-service
service/evaluation-service   ClusterIP   172.20.66.90    <none>        8000/TCP   15h   app.kubernetes.io/name=evaluation-service
service/flag-service         ClusterIP   172.20.51.154   <none>        8000/TCP   15h   app.kubernetes.io/name=flag-service
service/targeting-service    ClusterIP   172.20.90.181   <none>        8000/TCP   15h   app.kubernetes.io/name=targeting-service

NAME                           ENDPOINTS                             AGE
endpoints/analytics-service    10.10.35.35:8000                      15h
endpoints/auth-service         10.10.47.28:8000,10.10.52.161:8000    15h
endpoints/evaluation-service   10.10.34.105:8000,10.10.55.176:8000   15h
endpoints/flag-service         10.10.36.164:8000,10.10.55.3:8000     15h
endpoints/targeting-service    10.10.39.50:8000,10.10.49.16:8000     15h
```

## Análise preliminar

```text
## Análise preliminar

- Foram encontrados sinais de OpenTelemetry/OTEL no repositório. Revisar ocorrências acima.
- Há serviços Go no projeto; instrumentação pode exigir bibliotecas/SDK OpenTelemetry para Go ou sidecar/auto-instrumentation se viável.
- Há serviços Python no projeto; instrumentação pode ser feita por SDK/auto-instrumentation Python se o runtime permitir.
- Não há variáveis OTEL evidentes nos Deployments atuais.

## Próxima decisão sugerida

- Implementar instrumentação mínima e objetiva em um ou mais serviços que participem do fluxo E2E.
- Priorizar o caminho que gere trace real de requisição entre serviços, para preparar Figura 7 e Figura 8.
- Manter OTel Collector como endpoint OTLP interno: http://otel-collector.observability.svc.cluster.local:4318 ou gRPC 4317.

## Imagens futuras

- Figura 7: service map/APM depois que traces reais existirem.
- Figura 8: trace distribuído depois que uma requisição E2E gerar spans encadeados.
```
