#!/bin/bash

set -e

cleanup() {

    if [ $? -ne 0 ]; then
        echo "⚠️ Error detected or process interrupted! Killing background simulation..."
    else
        echo "✅ Pipeline finished successfully. Cleaning up..."
    fi
    
    kill 0 2>/dev/null
}


trap cleanup INT TERM EXIT

# Starts data stream 
cd core
python sim_utils.py > /dev/null 2>&1 &

# Start prediction and decision making with the model
python main.py