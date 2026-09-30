import matplotlib
matplotlib.use('Agg')

import torch
import os

import sys
sys.path.append("../")

from flwr.app import ArrayRecord, Context, ConfigRecord
from flwr.serverapp import Grid, ServerApp
from flwr.serverapp.strategy import FedAvg

from io_utils import add_results
from inference import create_model_architecture

app = ServerApp()

@app.main()
def main(grid: Grid, context: Context) -> None:

    # Read run config
    num_rounds: int = context.run_config["num-server-rounds"]
    lr: float = context.run_config["learning-rate"]
    safe_path: str = context.run_config["safe_path"]
    arch: str = context.run_config["arch"]
    run: int = context.run_config["run"]

    # Create dummy dls and create empty model with dummy weights
    global_model, model_name = create_model_architecture(arch)
    arrays = ArrayRecord(global_model.state_dict())

    # Initialize FedAvg strategy
    strategy = FedAvg()

    # Start strategy, run FedAvg for `num_rounds`
    result = strategy.start(
        grid=grid,
        initial_arrays=arrays,
        num_rounds=num_rounds,
        train_config=ConfigRecord({"lr": lr}),
    )

    # Save final model to disk
    result.train_metrics_clientapp
    run_dir = os.path.join(safe_path, f"ram_test_run_{run}")
    os.makedirs(run_dir, exist_ok=True)
    full_file_path = os.path.join(run_dir, f"{model_name}.pth")
    state_dict = result.arrays.to_torch_state_dict() 
    torch.save(state_dict, full_file_path)

    # Add results to the results file
    all_eval_rounds = result.evaluate_metrics_clientapp 
    best_round_idx = min(result.evaluate_metrics_clientapp, key=lambda r: float(all_eval_rounds[r]["val_loss"]))
    best_metrics = dict(all_eval_rounds[best_round_idx]) | dict(result.train_metrics_clientapp[best_round_idx])
    best_metrics['train_loss'] = best_metrics.pop('loss')
    print(best_metrics)

    # Add results 
    add_results(csv_path="../results.csv", run=run, mode="dec-sim",model=model_name, epochs=num_rounds, partition_id="a", results=best_metrics)
    add_results(csv_path="../results.csv", run=run, mode="dec-sim",model=model_name, epochs=num_rounds, partition_id="b", results=best_metrics)
    add_results(csv_path="../results.csv", run=run, mode="dec-sim",model=model_name, epochs=num_rounds, partition_id="c", results=best_metrics)
  