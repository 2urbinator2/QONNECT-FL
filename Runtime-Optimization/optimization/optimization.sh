#!/bin/bash

# Check if a parameter was provided
if [ -z "$1" ]; then
    echo "Invalid input. Please provide 1, 2, or 3."
    exit 1
fi

# Determine the mode based on input
case $1 in
    1)
        echo "Federated Learning as runtime optimization is activated."
        dummy_message="[Federated Learning] Optimization cycle running..."
        ;;
    2)
        echo "Time Series Analysis as runtime optimization is activated."
        dummy_message="[Time Series Analysis] Processing next data window..."
        ;;
    3)
        echo "Reinforcement Learning as runtime optimization is activated."
        dummy_message="[Reinforcement Learning] Agent is exploring new actions..."
        ;;
    *)
        echo "Invalid input. Please provide 1, 2, or 3."
        exit 1
        ;;
esac

# Infinite loop for dummy output every 1 second
while true; do
    echo "$dummy_message"
    sleep 1
done
