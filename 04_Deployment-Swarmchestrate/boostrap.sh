#!/bin/bash

ns() {
    for ctx in $(kubectl config get-contexts -o name); do
        kubectl apply -f ../../swarmchestrate-alternative/config/ns.yaml --context "$ctx"
    done
}

ingress() {
    for ctx in $(kubectl config get-contexts -o name); do
        kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml --context "$ctx"
        kubectl wait --namespace ingress-nginx \
            --for=condition=ready pod \
            --selector=app.kubernetes.io/component=controller \
            --timeout=90s \
            --context "$ctx"
    done
}
    

all() {
    ns
    ingress
}

COMMAND="$1"
shift

case "$COMMAND" in
    ns)
        ns "$@"
        ;;
    ingress)
        ingress "$@"
        ;;
    all)
        ns "$@"
        ingress "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        ;;
esac