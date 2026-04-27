Tags: [[_My_projects]]
#MyProjects 

# Introduction
Install Helm chart:
```bash
# Run this from the helm_charts/prometheus_grafana folder
helm dependency update
helm -n prometheus install monitoring . &
```

Get Grafana 'admin' user password by running:
```bash
kubectl -n prometheus get secrets monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
```
# Accessing Grafana
We can access Grafana from a browser using `localhost:3000` URL 
## How it works
We can access Grafana using `localhost:3000` because:
- In the `kind-config.yaml` we mapped the 30000 port from kind node containers into the port 3000 on the localhost:
  ```yaml
  nodes:
	  - role: control-plane
		extraPortMappings:
			- containerPort: 30000
				hostPort: 3000
				protocol: TCP
  ```
- In `values.yaml` in the `helm_charts/prometheus_grafana` Helm chart, we modified the Grafana's service to use a NodePort:
  ```yaml
  kube-prometheus-stack:
  grafana:
    service:
      type: NodePort
      port: 80        # service port inside cluster
      targetPort: 3000  # container port
      nodePort: 30000   # host port you want to expose
  ```
  More info in comments in the `kind-config.yaml` and `values.yaml` files.
# Created exporters
The official Helm chart which we use installs two exporters:
- node-exporter
- kube-state-metrics
## node-exporter
Runs on every node and gives:
- CPU usage
- memory usage
- disk I/O

Its metrics are in the `Nod Exporter ...` Grafana dashboards.
## kube-state-metrics
Runs as a single pod and gives:
- pod states
- deployments
- replicas
- restarts
