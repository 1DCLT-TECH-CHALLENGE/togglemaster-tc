# Fase 4 - BLOCO 31 - Validação de Acesso ao Grafana

Data: Sat May 23 04:04:05 PM -03 2026

## Objetivo

Validar que o Grafana instalado pelo kube-prometheus-stack está acessível e integrado ao Prometheus.

Este bloco não instala novos componentes.

A senha admin do Grafana é lida do Kubernetes Secret somente em memória e não é registrada nesta evidência.


## Resultado

- Grafana Service: `kube-prometheus-stack-grafana`
- Port-forward local temporário usado no teste: `http://localhost:13000`
- Grafana API health validada.
- Datasource Prometheus encontrado: `true`
- Dashboard customizado ToggleMaster encontrado: `false`

### Grafana health

```json
{
  "database": "ok",
  "version": "13.0.1+security-01",
  "commit": "9bbe672d"
}
```

### Datasources

```text
Datasources encontrados:
- name=Alertmanager type=alertmanager url=http://kube-prometheus-stack-alertmanager.observability:9093/ isDefault=False
- name=Loki type=loki url=http://loki.observability.svc.cluster.local:3100 isDefault=False
- name=Prometheus type=prometheus url=http://kube-prometheus-stack-prometheus.observability:9090/ isDefault=True
PROMETHEUS_DATASOURCE_FOUND=true
- Prometheus datasource: Prometheus -> http://kube-prometheus-stack-prometheus.observability:9090/
```

### Dashboards

```text
Dashboards encontrados:
- title=Alertmanager / Overview uid=alertmanager-overview folder=None
- title=CoreDNS uid=vkQ0UHxik folder=None
- title=etcd uid=c2f4e12cdf69feb95caa41a5a1b423d9 folder=None
- title=Grafana Overview uid=6be0s85Mk folder=None
- title=Kubernetes / API server uid=09ec8aa1e996d6ffcd6817bbaff4db1b folder=None
- title=Kubernetes / Compute Resources /  Multi-Cluster uid=b59e6c9f2fcbe2e16d77fc492374cc4f folder=None
- title=Kubernetes / Compute Resources / Cluster uid=efa86fd1d0c121a26444b636a3f509a8 folder=None
- title=Kubernetes / Compute Resources / Namespace (Pods) uid=85a562078cdf77779eaa1add43ccec1e folder=None
- title=Kubernetes / Compute Resources / Namespace (Workloads) uid=a87fb0d919ec0ea5f6543124e16c42a5 folder=None
- title=Kubernetes / Compute Resources / Node (Pods) uid=200ac8fdbfbb74b39aff88118e4d1c2c folder=None
- title=Kubernetes / Compute Resources / Pod uid=6581e46e4e5c7ba40a07646395ef7b23 folder=None
- title=Kubernetes / Compute Resources / Workload uid=a164a7f0339f99e89cea5cb47e9be617 folder=None
- title=Kubernetes / Controller Manager uid=72e0e05bef5099e5f049b05fdc429ed4 folder=None
- title=Kubernetes / Kubelet uid=3138fa155d5915769fbded898ac09fd9 folder=None
- title=Kubernetes / Networking / Cluster uid=ff635a025bcfea7bc3dd4f508990a3e9 folder=None
- title=Kubernetes / Networking / Namespace (Pods) uid=8b7a8b326d7a6f1f04244066368c67af folder=None
- title=Kubernetes / Networking / Namespace (Workload) uid=bbb2a765a623ae38130206c7d94a160f folder=None
- title=Kubernetes / Networking / Pod uid=7a18067ce943a40ae25454675c19ff5c folder=None
- title=Kubernetes / Networking / Workload uid=728bf77cc1166d2f3133bf25846876cc folder=None
- title=Kubernetes / Persistent Volumes uid=919b92a8e8041bd567af9edab12c840c folder=None
- title=Kubernetes / Proxy uid=632e265de029684c40b21cb76bca4f94 folder=None
- title=Kubernetes / Scheduler uid=2e6b6a3b4bddf1427b3a55aa1311c656 folder=None
- title=Node Exporter / AIX uid=7e0a61e486f727d763fb1d86fdd629c2 folder=None
- title=Node Exporter / MacOS uid=629701ea43bf69291922ea45f4a87d37 folder=None
- title=Node Exporter / Nodes uid=7d57716318ee0dddbac5a7f451fb7753 folder=None
- title=Node Exporter / USE Method / Cluster uid=3e97d1d02672cdd0861f4c97c64f89b2 folder=None
- title=Node Exporter / USE Method / Node uid=fac67cfbe174d3ef53eb473d73d9212f folder=None
- title=Prometheus / Overview uid=9fa0d141-d019-4ad7-8bc5-42196ee308bd folder=None
CUSTOM_DASHBOARD_FOUND=false
```
