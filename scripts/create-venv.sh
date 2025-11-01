#!/bin/bash

# This script creates a Python virtual environment and installs the required packages.

echo "Creating Python virtual environment..."
/opt/homebrew/bin/python3 -m venv ./venv

echo "Activating virtual environment..."
source ./venv/bin/activate

echo "Installing required packages..."
pip3 install -r ./requirements.txt