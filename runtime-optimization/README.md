# Training 
This section demonstrates how to train the dataset [Burn_CPU_Burn](https://www.kaggle.com/c/model-t4) both separately and in a federated manner.

## Create venv
1. Virtual Environment with all dependencies for TSAI and Flower
   1. `conda create -n fedler python=3.10 -y`
   2. `conda activate fedler` and `conda deactivate`
   3. `pip install -r ./requirements.txt`
2. `cd training`

## Separate Training (ST)
 1. `train-separate.ipynb`

## Federated Training (FT)

### Simulation 
2. Single training: `flwr run . --stream`
3. Full training:`./train_federated.sh`

### Remote
1. `cd orchestrator-component`

**Start Experiment:** `./start-simulation.sh`

**Setup Remote Infrastructure and train**
1. Install Dependencies `ansible-playbook -i ../../inventory.yml ../install-flwr-deps.yml -e 'ansible_ssh_extra_args="-o StrictHostKeyChecking=no"'`
2. Start server on remote VMs `start-server.sh` or `start-clients.sh`
3. Train: `flwr run . local-deployment --stream`