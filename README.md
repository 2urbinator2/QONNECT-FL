# Setup Infrastructure and Clusters


In the first step, the infrastructure and the associated Kubernetes clusters need to be created. In the original **Swarmchestrate** setup, *Kind* is used for this purpose. This repository aims to be closer to a *production-like* environment, which is why **Swarmchestrate** should be deployed on real cloud resources (*Azure*). However, since budgets are often tight, this README also describes how to set up a Swarmchestrate VM instance in *VirtualBox*, which closely resembles a cloud infrastructure.

1. To setup VMs and clusters in VirtualBox: `cd/VirtualBox`
2. To setup VMs and clusters in Cloud (*Azure*): `cd/Azure`

Once the infrastructure is in place, Swarmchestrate can be deployed as usual [1].Please use the provided `bootstrap.sh` in this folder.
```Bash
cd ...
```

The main contribution of this repository is to optimize the runtime of Swarmchestrate, for which an additional component is used after deployment.









## Sources
1. https://github.com/dos-group/swarmchestrate-alternative