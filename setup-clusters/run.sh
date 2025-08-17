- hosts: k8s_control
  become: yes
  tasks:
    - name: Initialize Kubernetes control plane
      command: kubeadm init --pod-network-cidr=10.244.0.0/16
      register: kubeadm_init

    - name: Copy kubeconfig
      command: "{{ item }}"
      with_items:
        - mkdir -p $HOME/.kube
        - cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        - chown $(id -u):$(id -g) $HOME/.kube/config

- hosts: k8s_worker
  become: yes
  tasks:
    - name: Join worker to cluster
      command: kubeadm join <CONTROL_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>