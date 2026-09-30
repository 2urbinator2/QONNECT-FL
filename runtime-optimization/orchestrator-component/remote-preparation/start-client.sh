#!/bin/bash

source /home/$(whoami)/flwr-files/venv/bin/activate

./venv/bin/flower-supernode \
    --insecure \
    --superlink 10.0.1.5:9092 \
    --clientappio-api-address 10.0.1.6:9094 \
    --node-config "partition-id=1 num-partitions=1"