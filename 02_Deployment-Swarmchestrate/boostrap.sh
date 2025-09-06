#!/bin/bash

db() {
    HOST="172.203.145.155"
    USER="furban"
    SSH_KEY="~/.ssh/az-key"

    ansible-playbook -i ../01_Creation-and-Setup-Cluster/inventory/az-k3s-inventory.yml playbooks/remote-access-db.yml

    ansible-playbook \
        -i "$HOST," \
        --user "$USER" \
        --private-key "$SSH_KEY" \
        playbooks/create-database.yml \
        -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'

    until ssh -i "$SSH_KEY" "$USER@$HOST" "pg_isready -U foo -d knowledge_base"; do
        echo "Warte auf die Datenbank..."
        sleep 3
    done

    ssh -i "$SSH_KEY" "$USER@$HOST" "mkdir -p knowledge-base"

    scp -i "$SSH_KEY" -r swarmchestrate-alternative/knowledge-base/migrations "$USER@$HOST:~/knowledge-base/"

    ssh -i "$SSH_KEY" "$USER@$HOST" '
    cd /home/'"$USER"'/knowledge-base/migrations && 
    for f in *.up.sql; do 
        PGPASSWORD=pass psql -h localhost -U foo -d knowledge_base -f "$f"; 
    done'
    
}


ns() {
    for ctx in $(kubectl config get-contexts -o name); do
        kubectl apply -f swarmchestrate-alternative/config/ns.yaml --context "$ctx"
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


raft_lb() {
    for ctx in $(kubectl config get-contexts -o name | grep '^cloud-'); do
        kubectl apply -f swarmchestrate-alternative/config/lb.yaml -n swarmchestrate --context "$ctx"
    done
}

all() {
    db
    ns
    ingress
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
    cleanup_edge_ingress)
        cleanup_edge_ingress "$@"
        ;;
    raft_lb)
        raft_lb "$@"
        ;;
    all)
        ns "$@"
        ingress "$@"
        cleanup_edge_ingress "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        ;;
esac