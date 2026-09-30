'''This module provides utility functions for result persistence and data routing, ensuring experiments are tracked and stored correctly.'''

import csv
from pathlib import Path

def check_result_file(csv_path):

    file = Path(csv_path)
    headers = ["run", "mode", "model", "epochs", "partition", "train_loss", "val_loss", "mse", "mae", "rmse", "test_loss"]

    file.parent.mkdir(parents=True, exist_ok=True)
    if not file.exists() or list(csv.reader(open(file)))[:1] != [headers]:
        with open(file, "w", newline="", encoding="utf-8") as f:
            csv.writer(f).writerow(headers)

def add_results(csv_path, run, mode, model, epochs, partition_id, results):
 
    check_result_file(csv_path)
    file = Path(csv_path)

    results = {"run": run, "mode": mode, "model": model, "epochs":epochs, "partition": partition_id, **results}

    with open(file, "r", newline="", encoding="utf-8") as f:
        headers = next(csv.reader(f))
    
    filtered_results = {k: results[k] for k in headers if k in results}

    with open(file, "a", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writerow(filtered_results)

