#!/bin/bash


models=("LSTM" "gMLP" "InceptionTime" "TSTPlus" "GRUPlus")

#models=("gMLP" )

for run in $(seq 8 10)
do
   for arch in "${models[@]}"
   do
      flwr run . --stream --run-config "arch='$arch', run=$run"
   done
done