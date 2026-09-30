#!/bin/bash

db() {
    echo "Adding community.postgresql collection"
    ansible-galaxy collection install community.postgresql

    echo "Setup PostgreSQL, PostgreSQL-Client, pgAdamin4 and Migratio of the tables."
    ansible-playbook -i ../inventory.yml ./config/setup-db.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'

}

ns() {
    echo "Creating namespaces 'swarmchestrate' in all clusters if not exist"

    for ctx in $(kubectl config get-contexts -o name); do
        kubectl create namespace swarmchestrate --context "$ctx" --dry-run=client -o yaml | kubectl apply -f - --context "$ctx"
    done
}

ingress() {
    for ctx in $(kubectl config get-contexts -o name ); do
       
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

raft_lb() {
    for ctx in $(kubectl config get-contexts -o name | grep '^cloud-'); do

        echo "Setting up Raft_lb LoadBalancer in context: $ctx"
        kubectl apply -f config/lb.yaml -n swarmchestrate --context "$ctx"

    done
}

setup_identity() {

    echo "Transfer azure.json on cloud VMs "

    USER=$(grep "^ansible_user=" ../inventory.yml | cut -d'=' -f2)
    KEY=$(grep "^ansible_ssh_private_key_file=" ../inventory.yml | cut -d'=' -f2)
    IPS=$(grep "ansible_host=" ../inventory.yml | sed 's/.*ansible_host=\([0-9.]*\).*/\1/')

    for IP in $IPS; do
        scp -i $KEY config/azure.json $USER@$IP:/tmp/azure.json
        ssh -i "$KEY" "$USER@$IP" "sudo mv /tmp/azure.json /etc/kubernetes/azure.json && sudo chown root:root /etc/kubernetes/azure.json && sudo chmod 600 /etc/kubernetes/azure.json"   
    done

    echo "Install cloud-manager-controller"

    for ctx in $(kubectl config get-contexts -o name); do

        echo "Install controller with helm on $ctx"

        helm upgrade --install azure-cloud-manager cloud-provider-azure/cloud-provider-azure \
        --namespace kube-system \
        --set infrastructure.cloudConfigSecretName=azure-cloud-config \
        --set cloudConfigParams.cloudConfigAbsPath=/etc/kubernetes/azure.json \
        --set "extraArgs={--configure-cloud-routes=false}" 
    done 
}

setup_driver() {

    echo "Setting up Azure File CSI Driver in all clusters"

    for ctx in $(kubectl config get-contexts -o name | grep '^cloud-'); do
        kubectl config use-context "$ctx"

        helm repo add azuredisk-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/charts
        helm repo update

        helm install azuredisk-csi-driver azuredisk-csi-driver/azuredisk-csi-driver \
            --namespace kube-system \
            --create-namespace

    done
}


all() {
    ns
    ingress
    raft_lb
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
    in)
        ingress "$@"
        ;;
    sr)
        raft_lb "$@"
        ;;
    sd)
        setup_driver "$@"
        ;;
    si)
        setup_identity "$@"
        ;;
    all)
        all "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        ;;
esac