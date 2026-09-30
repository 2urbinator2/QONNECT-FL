import pandas as pd 

import sys
import time 
import os

def simulate_data_stream(partition_id, target = "../cluster-system-data.csv", data_path="../../data/train.csv", interval_sec=1, rows_per_second = 1):
    
    """
    SIMULATION ONLY: Transfers data to csv in 'interval_sec'
    """

    # Check if file and header exist 
    if not os.path.exists(target):
        with open(data_path, "r", encoding="utf-8") as src, open(target, "w", encoding="utf-8") as tgt:
            tgt.write(src.readline())

    # Includes all data for partition_id
    df = pd.read_csv(data_path)
    unique_mids = sorted(df['m_id'].unique()) 
    df = df[df['m_id'] == unique_mids[partition_id]]
    
    print(f"Streaming {rows_per_second} rows every {interval_sec}s...")

    for i in range(0, len(df), rows_per_second):
        
        chunk = df.iloc[i : i + rows_per_second]
        chunk.to_csv(target, mode="a", header=False, index=False)
        time.sleep(interval_sec)


if __name__ == "__main__":

    simulate_data_stream(partition_id= 0, rows_per_second = 10)