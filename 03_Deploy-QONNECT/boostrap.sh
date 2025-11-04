#!/bin/bash

db() {
    echo "Adding community.postgresql collection"
    ansible-galaxy collection install community.postgresql

    echo "Setup PostgreSQL on $HOST"
    ansible-playbook -i ../inventory.yml playbooks-db/setup-postgre.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'

    echo "Setup database on $HOST and enable remote access"
    ansible-playbook -i ../inventory.yml playbooks-db/setup-db.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'
    
    # echo "Setup pgAdmin4 on $HOST"
    # ansible-playbook -i ../inventory.yml playbooks-db/setup-pgadmin.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'







    # until ssh -i "$SSH_KEY" "$USER@$HOST" "pg_isready -U foo -d knowledge_base"; do
    #     echo "Warte auf die Datenbank..."
    #     sleep 3
    # done

    # ssh -i "$SSH_KEY" "$USER@$HOST" "mkdir -p knowledge-base"

    # scp -i "$SSH_KEY" -r swarmchestrate-alternative/knowledge-base/migrations "$USER@$HOST:~/knowledge-base/"

    # ssh -i "$SSH_KEY" "$USER@$HOST" '
    # cd /home/'"$USER"'/knowledge-base/migrations && 
    # for f in *.up.sql; do 
    #     PGPASSWORD=pass psql -h localhost -U foo -d knowledge_base -f "$f"; 
    # done'

}


ns() {
    # 
    # for ctx in $(kubectl config get-contexts -o name); do
    #     kubectl apply -f swarmchestrate-alternative/config/ns.yaml --context "$ctx"
    # done

    # Alternative Methode muss noch getestet werden
    echo "Creating namespaces 'swarmchestrate' in all clusters"
    for ctx in $(kubectl config get-contexts -o name); do
        kubectl create namespace swarmchestrate --context "$ctx" --dry-run=client -o yaml | kubectl apply -f -
    done
    
}

ingress() {
    for ctx in $(kubectl config get-contexts -o name); do
        if echo "$ctx" | grep -q '^cloud-'; then
            kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml --context "$ctx"
            kubectl wait --namespace ingress-nginx \
                --for=condition=ready pod \
                --selector=app.kubernetes.io/component=controller \
                --timeout=300s \
                --context "$ctx" || \
            echo "Warning: Timeout beim Warten auf ingress-nginx-controller in $ctx."
        fi
    done
}

metallb() {

    for ctx in $(kubectl config get-contexts -o name | grep '^cloud-'); do

        kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml --context "${ctx}"

        # Warten, bis MetalLB Pods ready sind
        kubectl wait --namespace metallb-system \
            --for=condition=ready pod \
            --selector=app=metallb \
            --timeout=300s \
            --context "${ctx}"

        # IP-Pool und L2Advertisement aus deiner Datei anwenden
        kubectl apply -f config/metallb.yaml --context "${ctx}"
    done
}

raft_lb() {
    for ctx in $(kubectl config get-contexts -o name | grep '^cloud-'); do
        kubectl apply -f swarmchestrate-alternative/config/lb.yaml -n swarmchestrate --context "$ctx"

        if kubectl get svc -A -o yaml --context "$ctx" | grep -q "metallb.universe.tf/address-pool"; then
       
            kubectl patch svc resource-lead-agent-lb -n swarmchestrate \
              -p '{"metadata":{"annotations":{"metallb.universe.tf/address-pool":"resource-lead-agent-pool"}}}' \
              --context "$ctx"
        else
            echo "No metallb address-pool annotation found in this context: $ctx"
        fi
    done
}

setup_file_share() {
    for ctx in $(kubectl config get-contexts -o name | grep '^cloud-'); do
        kubectl config use-context "$ctx"

        helm repo add azurefile-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/charts
        helm repo update
        helm install azurefile-csi-driver azurefile-csi-driver/azurefile-csi-driver \
            --namespace kube-system \
            --version 1.33.4 \
            --create-namespace

        kubectl apply -f config/secret.yaml
        kubectl apply -f config/pv.yaml
        kubectl apply -f config/pvc.yaml
    done
}

all() {
    db
    ns
    ingress
    metallb
    raft_lb
    setup_file_share
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
    metallb)
        metallb "$@"
        ;;
    raft_lb)
        raft_lb "$@"
        ;;
    setup_file_share)
        setup_file_share "$@"
        ;;
    all)
        db "$@"
        ns "$@"
        ingress "$@"
        cleanup_edge_ingress "$@"
        metallb "$@"
        raft_lb "$@"
        setup_file_share "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        ;;
esac