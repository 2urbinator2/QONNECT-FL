





How to train the model?
1. Prepare infrastructure: `ansible-playbook -i ../inventory.yml setup-flr.yml`
   1. (optional): Check if instances can ping with: `ping xxx` and `nc -zv xxx 22`
2. Start Flower: Connect to every instance with `ssh -i ~/.ssh/az-key furban@xxx` and `source ~/venv/bin/activate` connect to venv
   1. Server: `/home/furban/venv/bin/flower-superlink --insecure`
   2. Client: 
        ```bash
        # Instance 1
        /home/furban/venv/bin/flower-supernode \
        --insecure \
        --superlink 10.0.1.5:9092 \
        --clientappio-api-address 10.0.1.6:9094 \
        --node-config "partition-id=1 num-partitions=2"

        # Instance 2
        /home/furban/venv/bin/flower-supernode \
        --insecure \
        --superlink 10.0.1.5:9092 \
        --clientappio-api-address 10.0.1.7:9094 \
        --node-config "partition-id=2 num-partitions=2"
        ```
3. Start Flower: `flwr run .`