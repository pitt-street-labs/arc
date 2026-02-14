# Chapter 09 -- Server 2 Monitoring Stack

**Depends on:** [Chapter 07](./07-server-2-os.md), [Chapter 08](./08-server-2-infrastructure.md)

The monitoring stack provides metrics collection, log aggregation, alerting, dashboards, and security monitoring.

---

## Stack Overview

| Component | Container | Port | Purpose |
|-----------|-----------|------|---------|
| <!-- Prometheus --> | <!-- prometheus --> | <!-- 9095 --> | Metrics TSDB |
| <!-- Grafana --> | <!-- grafana --> | <!-- 3000 --> | Dashboards |
| <!-- Alertmanager --> | <!-- alertmanager --> | <!-- 9093 --> | Alert routing |
| <!-- Loki --> | <!-- loki --> | <!-- 3100 --> | Log aggregation |
| <!-- Node Exporter --> | <!-- (on each host) --> | <!-- 9100 --> | Host metrics |
| <!-- Blackbox Exporter --> | <!-- blackbox --> | <!-- 9115 --> | HTTP/TCP probes |
| <!-- SNMP Exporter --> | <!-- snmp-exporter --> | <!-- 9116 --> | SNMP metrics |
| <!-- SIEM --> | <!-- wazuh/ossec --> | <!-- 5601 --> | Security monitoring |

---

## Prometheus Configuration

### Scrape Targets

<!-- List all Prometheus scrape targets -->

| Job | Target | Port | Interval |
|-----|--------|------|----------|
| <!-- node --> | <!-- server-1, server-2 --> | 9100 | 30s |
| <!-- containers --> | <!-- server-1, server-2 --> | 9882 | 60s |
| <!-- blackbox --> | <!-- URLs --> | 9115 | 60s |

### Alerting Rules

<!-- Document key alerting rules: host down, disk full, container crashed, etc. -->

### Data Retention

<!-- Retention period, storage location, disk usage -->

---

## Grafana Dashboards

<!-- List key dashboards and their data sources -->

| Dashboard | Data Source | Purpose |
|-----------|------------|---------|
| <!-- Host Overview --> | Prometheus | CPU, memory, disk, network per host |
| <!-- Container Health --> | Prometheus | Container status and resource usage |
| <!-- Service Uptime --> | Prometheus | Blackbox probe results |

---

## Log Aggregation

<!-- Loki/Promtail or ELK configuration -->

### Log Sources

| Source | Agent | Labels |
|--------|-------|--------|
| <!-- server-1 --> | <!-- alloy/promtail --> | host, service |
| <!-- server-2 --> | <!-- alloy/promtail --> | host, service |

---

## Security Monitoring

<!-- SIEM (Wazuh, OSSEC, etc.): agents, dashboards, IDS rules -->

---

## Uptime Monitoring

<!-- External uptime monitoring (Uptime Kuma, Healthchecks, etc.) -->

| Service | URL | Check Type | Interval |
|---------|-----|-----------|----------|
| <!-- monitor name --> | <!-- URL --> | HTTP | 60s |

---

## Deployment

### Rootful vs. Rootless

<!-- Monitoring containers often need root for host metrics.
     Document which run rootful (/etc/containers/systemd/) vs. rootless -->

### Startup Order

<!-- Dependencies between monitoring containers -->

---

## Verification Checklist

- [ ] Prometheus targets all show UP
- [ ] Grafana loads with dashboards
- [ ] Alertmanager receives test alert
- [ ] Loki receives logs from all hosts
- [ ] Uptime monitor shows all services green
