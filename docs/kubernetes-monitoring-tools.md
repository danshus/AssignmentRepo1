# Kubernetes Monitoring Tools Guide

## Overview

Kubernetes monitoring is essential for maintaining the health, performance, and security of containerized applications. This guide covers the most popular monitoring solutions and their integration with the Sentinel architecture.

## Monitoring Stack Categories

### 1. Metrics Collection & Storage
- **Prometheus**: Time-series database and monitoring system
- **InfluxDB**: High-performance time-series database
- **TimescaleDB**: PostgreSQL extension for time-series data

### 2. Visualization & Dashboards
- **Grafana**: Leading visualization platform
- **Kibana**: Elasticsearch visualization (part of ELK stack)
- **Datadog**: Cloud-based monitoring with built-in dashboards

### 3. Logging Solutions
- **ELK Stack**: Elasticsearch, Logstash, Kibana
- **Fluentd/Fluent Bit**: Log collection and forwarding
- **Loki**: Log aggregation by Grafana

### 4. Distributed Tracing
- **Jaeger**: End-to-end distributed tracing
- **Zipkin**: Distributed tracing system
- **OpenTelemetry**: Vendor-neutral observability framework

## Popular Monitoring Solutions

### Prometheus + Grafana Stack

**Features:**
- Pull-based metrics collection
- Powerful query language (PromQL)
- Rich ecosystem of exporters
- Excellent Kubernetes integration
- Free and open-source

**Use Cases:**
- Infrastructure monitoring
- Application metrics
- Alerting and notification
- Custom dashboards

**Integration with Sentinel:**
```yaml
# prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
      - job_name: 'sentinel-backend'
        static_configs:
          - targets: ['sentinel-backend-service:8080']
      - job_name: 'sentinel-gateway'
        static_configs:
          - targets: ['sentinel-gateway-service:8080']
```

### ELK Stack (Elasticsearch, Logstash, Kibana)

**Features:**
- Centralized log aggregation
- Real-time log processing
- Powerful search and analytics
- Machine learning capabilities
- Security features (X-Pack)

**Use Cases:**
- Application log analysis
- Security event correlation
- Performance troubleshooting
- Compliance reporting

**Integration with Sentinel:**
```yaml
# elasticsearch-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elasticsearch
spec:
  replicas: 3
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:8.8.0
        ports:
        - containerPort: 9200
        env:
        - name: discovery.type
          value: single-node
        - name: xpack.security.enabled
          value: "true"
        resources:
          requests:
            memory: "2Gi"
            cpu: "500m"
          limits:
            memory: "4Gi"
            cpu: "1000m"
```

### Datadog

**Features:**
- Full-stack observability
- APM (Application Performance Monitoring)
- Infrastructure monitoring
- Log management
- Real-time dashboards
- AI-powered anomaly detection

**Use Cases:**
- Enterprise monitoring
- Multi-cloud environments
- DevOps teams
- Performance optimization

**Integration with Sentinel:**
```yaml
# datadog-agent.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: datadog-agent
spec:
  selector:
    matchLabels:
      app: datadog-agent
  template:
    metadata:
      labels:
        app: datadog-agent
    spec:
      serviceAccountName: datadog-agent
      containers:
      - name: datadog-agent
        image: gcr.io/datadoghq/agent:latest
        env:
        - name: DD_API_KEY
          valueFrom:
            secretKeyRef:
              name: datadog-secret
              key: api-key
        - name: DD_SITE
          value: "datadoghq.com"
        - name: DD_COLLECT_KUBERNETES_EVENTS
          value: "true"
        - name: DD_LOGS_ENABLED
          value: "true"
        - name: DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL
          value: "true"
        - name: DD_CONTAINER_EXCLUDE_LOGS
          value: "image:datadog/agent"
        - name: DD_KUBERNETES_KUBELET_NODENAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: DD_CRI_SOCKET_PATH
          value: /var/run/containerd/containerd.sock
        - name: DD_KUBELET_TLS_VERIFY
          value: "false"
        volumeMounts:
        - name: dockersocket
          mountPath: /var/run/docker.sock
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: cgroup
          mountPath: /host/sys/fs/cgroup
          readOnly: true
        - name: pointdir
          mountPath: /opt/datadog-agent/run
      volumes:
      - name: dockersocket
        hostPath:
          path: /var/run/docker.sock
      - name: proc
        hostPath:
          path: /proc
      - name: cgroup
        hostPath:
          path: /sys/fs/cgroup
      - name: pointdir
        hostPath:
          path: /opt/datadog-agent/run
```

### Jaeger (Distributed Tracing)

**Features:**
- Distributed transaction monitoring
- Performance and latency analysis
- Root cause analysis
- Service dependency mapping
- OpenTelemetry support

**Use Cases:**
- Microservices debugging
- Performance optimization
- Service mesh monitoring
- API troubleshooting

**Integration with Rapyd Sentinel:**
```yaml
# jaeger-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
    spec:
      containers:
      - name: jaeger
        image: jaegertracing/all-in-one:latest
        ports:
        - containerPort: 16686
        - containerPort: 14268
        env:
        - name: COLLECTOR_OTLP_ENABLED
          value: "true"
        - name: SPAN_STORAGE_TYPE
          value: "memory"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

## Security-Focused Monitoring

### Falco (Runtime Security)

**Features:**
- Runtime security monitoring
- Behavioral analysis
- Threat detection
- Compliance monitoring
- Real-time alerts

**Integration:**
```yaml
# falco-deployment.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: falco
spec:
  selector:
    matchLabels:
      app: falco
  template:
    metadata:
      labels:
        app: falco
    spec:
      serviceAccountName: falco
      containers:
      - name: falco
        image: falcosecurity/falco:latest
        securityContext:
          privileged: true
        volumeMounts:
        - name: falco-config
          mountPath: /etc/falco
        - name: falco-rules
          mountPath: /etc/falco/rules.d
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
        - name: dev
          mountPath: /host/dev
        - name: var-run-docker-sock
          mountPath: /var/run/docker.sock
      volumes:
      - name: falco-config
        configMap:
          name: falco-config
      - name: falco-rules
        configMap:
          name: falco-rules
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
      - name: dev
        hostPath:
          path: /dev
      - name: var-run-docker-sock
        hostPath:
          path: /var/run/docker.sock
```

### OPA Gatekeeper (Policy Enforcement)

**Features:**
- Policy-as-code
- Admission control
- Resource validation
- Compliance enforcement
- Custom policies

**Integration:**
```yaml
# gatekeeper-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gatekeeper-controller-manager
spec:
  replicas: 2
  selector:
    matchLabels:
      control-plane: controller-manager
  template:
    metadata:
      labels:
        control-plane: controller-manager
    spec:
      serviceAccountName: gatekeeper-admin
      containers:
      - name: manager
        image: openpolicyagent/gatekeeper:latest
        args:
        - --port=8443
        - --logtostderr
        - --emit-admission-events
        ports:
        - containerPort: 8443
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
```

## Monitoring Best Practices

### 1. Multi-Layer Monitoring
- **Infrastructure Layer**: Node metrics, resource usage
- **Kubernetes Layer**: Pod health, service discovery
- **Application Layer**: Business metrics, custom KPIs
- **Security Layer**: Runtime threats, policy violations

### 2. Alerting Strategy
```yaml
# prometheus-rules.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: sentinel-rules
spec:
  groups:
  - name: sentinel
    rules:
    - alert: HighCPUUsage
      expr: container_cpu_usage_seconds_total{container="sentinel-backend"} > 0.8
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage detected"
        description: "Container {{ $labels.container }} has high CPU usage"
    
    - alert: PodRestarting
      expr: increase(kube_pod_container_status_restarts_total[5m]) > 0
      labels:
        severity: critical
      annotations:
        summary: "Pod is restarting frequently"
        description: "Pod {{ $labels.pod }} is restarting"
    
    - alert: SecurityViolation
      expr: falco_events_total > 0
      labels:
        severity: critical
      annotations:
        summary: "Security violation detected"
        description: "Falco detected a security violation"
```

### 3. Resource Optimization
- Use resource requests and limits
- Implement horizontal pod autoscaling
- Monitor and optimize storage usage
- Implement proper retention policies

### 4. Security Considerations
- Encrypt monitoring data in transit and at rest
- Implement RBAC for monitoring access
- Use service accounts with minimal permissions
- Regular security updates for monitoring tools

## Cost Optimization

### 1. Data Retention
- Implement tiered storage (hot/warm/cold)
- Use data compression
- Set appropriate retention periods
- Archive old data to cheaper storage

### 2. Resource Management
- Right-size monitoring components
- Use spot instances for non-critical workloads
- Implement auto-scaling
- Monitor and optimize costs

### 3. Tool Selection
- Open-source vs commercial solutions
- Self-hosted vs managed services
- Feature requirements vs cost
- Support and maintenance overhead

## Integration with CI/CD Pipeline

### GitHub Actions Integration
```yaml
# .github/workflows/monitoring-setup.yml
name: Monitoring Setup
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy-monitoring:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
    
    - name: Deploy Prometheus
      run: |
        kubectl apply -f k8s/monitoring/prometheus/
        kubectl apply -f k8s/monitoring/grafana/
    
    - name: Deploy Security Monitoring
      run: |
        kubectl apply -f k8s/monitoring/falco/
        kubectl apply -f k8s/monitoring/gatekeeper/
    
    - name: Verify Monitoring
      run: |
        kubectl get pods -n monitoring
        kubectl get svc -n monitoring
```

## Recommended Monitoring Stack for Sentinel

### Production Environment
1. **Prometheus + Grafana**: Core metrics and visualization
2. **ELK Stack**: Log aggregation and analysis
3. **Jaeger**: Distributed tracing
4. **Falco**: Runtime security monitoring
5. **OPA Gatekeeper**: Policy enforcement

### Development Environment
1. **Prometheus + Grafana**: Basic monitoring
2. **Fluentd**: Log forwarding
3. **Falco**: Security monitoring

## Learning Resources

### Documentation
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [ELK Stack Guide](https://www.elastic.co/guide/index.html)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)

### Courses
- Kubernetes Monitoring with Prometheus (Coursera)
- ELK Stack for Log Analysis (Udemy)
- Distributed Tracing with Jaeger (Pluralsight)

### Hands-on Practice
- Set up monitoring for a sample application
- Create custom dashboards
- Implement alerting rules
- Practice troubleshooting with monitoring data

## Interview Preparation

### Common Questions
1. **How would you design a monitoring strategy for a microservices architecture?**
2. **What metrics are most important for Kubernetes monitoring?**
3. **How do you handle monitoring data retention and costs?**
4. **What security considerations are important for monitoring tools?**
5. **How do you integrate monitoring with CI/CD pipelines?**

### Key Concepts to Understand
- Metrics vs logs vs traces
- Pull vs push monitoring
- Time-series databases
- Alerting and notification systems
- Distributed tracing concepts
- Security monitoring and threat detection

This comprehensive monitoring setup ensures that your Sentinel architecture is fully observable, secure, and maintainable in production environments. 