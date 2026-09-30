#!/bin/bash

delete() {

    for ctx in $(kubectl config get-contexts -o name ); do

        kubectl delete ns ingress-nginx --context "$ctx"

    done

}


deploy() {

    for ctx in $(kubectl config get-contexts -o name | grep '^cloud-'); do
       
        echo "Creating namespaces 'ingress-nginx' and deploy controller on K8s clusters."
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml --context "$ctx"

        kubectl patch svc ingress-nginx-controller -n ingress-nginx --context "$ctx" -p '{
            "metadata": {
                "annotations": {
                "service.beta.kubernetes.io/azure-load-balancer-internal": "true"
                }
            }
        }'

    done

}

COMMAND="$1"
shift

case "$COMMAND" in
    delete)    
        delete "$@"
        ;;
    
    deploy)    
        deploy "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        ;;
esac