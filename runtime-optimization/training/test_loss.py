import numpy as np
import pandas as pd

from sklearn.metrics import mean_squared_error
from tsai.data.preparation import SlidingWindow
from training.core import prepare_data
from inference import run_inference


def compute_test_loss(runs=[1,7,8,9,10], partitions=['a', 'b', 'c'], models=["LSTM", "gMLP","InceptionTime", "TSTPlus", "GRUPlus"], data_path="../data/train.csv", results="./results.csv", federated=False, s=2, h=30):
    '''Creates the test loss for the training'''

    # Load results and check column
    df_results = pd.read_csv(results)
    if "test_loss" not in df_results.columns:
        df_results["test_loss"] = np.nan

    # Select run
    for run in runs:

        # Filter Partition 
        for i, partition in enumerate(partitions): 

            # Path to the models 
            if federated:
                full_path = f"../models/decentral-sim/run_{run}"
            else:
                full_path = f"../models/central/run_{run}/{partition}"

            for model in models: 
                
                # Create Test Partition
                if federated:
                    _ , df_test, _, _ = prepare_data(data_path=data_path, partition_id=i, s=s, decentralized=federated, stats_file='./models/decentral-sim/preprocessing_stats.joblib')
                else: 
                    _ , df_test, _, _ = prepare_data(data_path=data_path, partition_id=i, s=s)
        
                # Calculate predictions and true values
                y_col = [df_test.columns.get_loc('cpu_01_busy')]
                _, y_test = SlidingWindow(window_len=96, stride=s, get_x=None, get_y=y_col, horizon=h)(df_test)
                y_pred = run_inference(df=df_test, path=full_path, arch=model, decentralized=federated)
                valid_windows_count = len(y_test)
                y_pred = y_pred[:valid_windows_count]


                # Calculates MSE and add value
                mse = mean_squared_error(y_test, y_pred)
                df_results.loc[
                    (df_results["run"] == run)
                    & (df_results["partition"] == partition)
                    & (df_results["model"] == model),
                    "test_loss",
                ] = mse
    
    df_results.to_csv("./results.csv", index=False)
