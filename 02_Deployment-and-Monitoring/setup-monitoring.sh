#!/bin/bash

setup_prometheus() {

    helm repo list | grep -q "^prometheus-community" || helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

    for ctx in $(kubectl config get-contexts -o name); do

        kubectl --context "$ctx" get namespace monitoring >/dev/null 2>&1 || \
            kubectl --context "$ctx" create namespace monitoring
    
        if helm --kube-context "$ctx" -n monitoring ls | grep -q prometheus; then
            echo "[$ctx] -> Prometheus is already installed – skipping installation."
            continue
        fi

        if [[ "$ctx" == cloud* ]]; then
            # Cloud Kubernetes cluster: Install Prometheus WITH kube-state-metrics
            echo "[$ctx] -> Install Prometheus WITH kube-state-metrics"
            helm upgrade --install prometheus prometheus-community/prometheus \
                --namespace monitoring \
                --set alertmanager.enabled=false \
                --set pushgateway.enabled=false \
                --set server.persistentVolume.enabled=false \
                --kube-context "$ctx"
        else
            # Non-Cloud cluster (e.g., k3s): Install Prometheus WITHOUT kube-state-metrics
            echo "[$ctx] -> Install Prometheus WITHOUT kube-state-metrics"
            helm upgrade --install prometheus prometheus-community/prometheus \
                --namespace monitoring \
                --set alertmanager.enabled=false \
                --set pushgateway.enabled=false \
                --set server.persistentVolume.enabled=false \
                --set kube-state-metrics.enabled=false \
                --kube-context "$ctx"
        fi 

    done  
}   

setup_grafana() {
    helm repo list | grep -q "^grafana" || helm repo add grafana https://grafana.github.io/helm-charts

    for ctx in $(kubectl config get-contexts -o name); do

        [[ "$ctx" != cloud* ]] && continue

        # Check and create namespace if not exists
        kubectl --context "$ctx" get namespace monitoring >/dev/null 2>&1 || \
            kubectl --context "$ctx" create namespace monitoring

        # Check Grafana and skip if exists
        helm --kube-context "$ctx" -n monitoring ls | grep -q grafana && \
            { echo "[$ctx] -> Grafana is already installed – skipping."; continue; }

        # Install Grafana
        echo "[$ctx] -> Installing Grafana..."
        helm upgrade --install grafana grafana/grafana \
            --namespace monitoring \
            --set persistence.enabled=false \
            --set adminPassword='Swarmchestrate' \
            --set readinessProbe.enabled=false \
            --set livenessProbe.enabled=false \
            --kube-context "$ctx"

        break
    done 
}

COMMAND="$1"
shift

case "$COMMAND" in
    setup_prometheus)
        setup_prometheus "$@"
        ;;
    setup_grafana)
        setup_grafana "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        ;;
    
esac