#!/bin/bash

db() {
    echo "Adding community.postgresql collection"
    ansible-galaxy collection install community.postgresql

    echo "Setup PostgreSQL on $HOST"
    ansible-playbook -i ../inventory.yml playbooks-db/setup-postgre.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'

    echo "Setup database on $HOST and enable remote access"
    ansible-playbook -i ../inventory.yml playbooks-db/setup-db.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'
    
    echo "Setup pgAdmin4 on $HOST"
    ansible-playbook -i ../inventory.yml playbooks-db/setup-pgadmin.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'

    echo "Migrate SQL scripts on $HOST"
    ansible-playbook -i ../inventory.yml playbooks-db/migrate-sql-scripts.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'

}

ns() {
    echo "Creating namespaces 'swarmchestrate' in all clusters if not exist"

    for ctx in $(kubectl config get-contexts -o name); do
        kubectl create namespace swarmchestrate --context "$ctx" --dry-run=client -o yaml | kubectl apply -f -
    done
}

ingress() {
    for ctx in $(kubectl config get-contexts -o name); do

        echo "Setting up Ingress-Nginx in context: $ctx"

        if echo "$ctx" | grep -q '^cloud-'; then
            kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml --context "$ctx"
            kubectl wait --namespace ingress-nginx \
                --for=condition=ready pod \
                --selector=app.kubernetes.io/component=controller \
                --timeout=300s \
                --context "$ctx" 
        fi
    done
}

raft_lb() {
    for ctx in $(kubectl config get-contexts -o name | grep '^cloud-'); do

        echo "Setting up Raft_lb LoadBalancer in context: $ctx"
        kubectl apply -f config/lb.yaml -n swarmchestrate --context "$ctx"

        echo "Give some time for LoadBalancer to get an IP from MetalLB in context: $ctx"
        if kubectl get svc -A -o yaml --context "$ctx" | grep -q "metallb.universe.tf/address-pool"; then
       
            kubectl patch svc resource-lead-agent-lb -n swarmchestrate \
              -p '{"metadata":{"annotations":{"metallb.universe.tf/address-pool":"resource-lead-agent-pool"}}}' \
              --context "$ctx"
        else
            echo "No metallb address-pool annotation found in this context: $ctx"
        fi
    done
}

setup_driver() {

    echo "Setting up Azure File CSI Driver in all clusters"

    for ctx in $(kubectl config get-contexts -o name | grep '^cloud-'); do
        kubectl config use-context "$ctx"

        helm repo add azurefile-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/charts
        helm repo update
        helm install azurefile-csi-driver azurefile-csi-driver/azurefile-csi-driver \
            --namespace kube-system \
            --version 1.33.4 \
            --create-namespace
    done
}

all() {
    ns
    ingress
    raft_lb
    setup_driver
}

metallb() {

    ctx=$(kubectl config current-context)

    echo "Setting up MetalLB in context: $ctx"
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml --context "${ctx}"

    echo "Waiting for MetalLB pods to be ready in context: $ctx"
    kubectl wait --namespace metallb-system \
        --for=condition=ready pod \
        --selector=app=metallb \
        --timeout=300s \
        --context "${ctx}"

    echo "Applying MetalLB configuration in context: $ctx"
    kubectl apply -f config/metallb.yaml --context "${ctx}"

}

remove_metallb() {
    ctx=$(kubectl config current-context)

    # Remove finalizers from MetalLB resources to allow deletion
    for kind in ipaddresspool l2advertisement bgppeer; do
        kubectl get $kind -n metallb-system -o name --context "${ctx}" 2>/dev/null \
        | xargs -r -n1 -I{} kubectl patch {} -n metallb-system --context "${ctx}" \
            -p '{"metadata":{"finalizers":[]}}' --type=merge
    done

    # Delete MetalLB resources
    kubectl delete ipaddresspool,l2advertisement,bgppeer --all -n metallb-system --context "${ctx}" --ignore-not-found

    # Delete Controller, Speaker & Services
    kubectl delete deployment,daemonset,service -n metallb-system --all --context "${ctx}" --ignore-not-found

    # Finally, delete the MetalLB CRDs
    for crd in ipaddresspools.metallb.io l2advertisements.metallb.io bgppeers.metallb.io; do
        kubectl patch crd $crd -p '{"metadata":{"finalizers":[]}}' --type=merge --context "${ctx}" 2>/dev/null || true
    done

    # Delete the CRDs
    kubectl delete crd ipaddresspools.metallb.io l2advertisements.metallb.io bgppeers.metallb.io --ignore-not-found

    # Delete Namespace Finalizers
    kubectl patch namespace metallb-system -p '{"metadata":{"finalizers":[]}}' --type=merge --context "${ctx}"

    # Delete Namespace
    kubectl patch namespace metallb-system -p '{"metadata":{"finalizers":[]}}' --type=merge
    kubectl delete namespace metallb-system --ignore-not-found



}

COMMAND="$1"
shift

case "$COMMAND" in
    db)
        db "$@"
        ;;
    ns)
        ns "$@"
        ;;
    ingress)
        ingress "$@"
        ;;
    mlb)
        metallb "$@"
        ;;
    rmlb)
        remove_metallb "$@"
        ;;
    rlb)
        raft_lb "$@"
        ;;
    driver)
        setup_driver "$@"
        ;;
    all)
        all "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        ;;
esac