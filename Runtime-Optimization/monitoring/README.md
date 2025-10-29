



1. Configure Federation on the Central Cluster
   ```bash
   # Find out Ingress IP + Port:
    kubectl get svc -n ingress-nginx --context=edge-energy

   # Use prometheus.yml
    - job_name: 'federate-edge' # Needs a specific name 
        metrics_path: '/federate'
        params:
        'match[]':
            - '{__name__=~".+"}'
        static_configs:
        - targets: ['172.18.0.26:31288'] # Has to be adopted 
    ````

2. Apply and Access
    ```bash
    # Apply Configmap
    kubectl --context=cloud-energy -n monitoring create configmap prometheus-config --from-file=prometheus.yml --dry-run=client -o yaml | kubectl apply -f -

    # Access Prometheus and Grafana
    kubectl port-forward -n monitoring svc/prometheus-server 9090:80
    kubectl port-forward -n monitoring svc/grafana 3000:80

    http://localhost:9090 
    http://localhost:3000 

    ```

## Deletion
1. ``kubectl delete namespace monitoring --context=fog-energy``
2. ``kubectl get ns --context=fog-energy``
3. ``helm uninstall grafana -n monitoring``
4. ``kubectl -n monitoring delete pod prometheus-server-7f96ccbf56-mggsf``




kubectl replace --context=edge-energy --raw "/api/v1/namespaces/monitoring/finalize" -f - <<EOF
{
  "apiVersion": "v1",
  "kind": "Namespace",
  "metadata": {
    "name": "monitoring"
  },
  "spec": {
    "finalizers": []
  }
}
EOF





cloud-performance-control ansible_host=20.39.38.216  ip=10.0.1.12 etcd_member_name=etcd1

cloud-performance-worker ansible_host=172.190.63.250  ip=10.0.1.11