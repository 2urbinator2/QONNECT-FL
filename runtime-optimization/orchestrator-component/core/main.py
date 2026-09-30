import sys
import os
from pathlib import Path

import pandas as pd
import numpy as np

import time

root_path = Path(__file__).resolve().parent.parent.parent
sys.path.append(str(root_path)) 

from inference import run_inference

class InferenceComponent:

    def __init__(self, w_l=96, model_path = "../../models/decentral-sim/run_5",  stream_data_path="../cluster-system-data.csv", model_arch="TSTPlus", retrain_interval=10):

        # Model
        self.w_l = w_l
        self.model_path = model_path
        self.model_arch = model_arch

        # Stream Data Path
        self.stream_data_path = stream_data_path
   
        # Global variables 
        self.processed_rows = 0
        self.internal_memory = pd.DataFrame()

        # Retrain counter
        self.retrain_interval = retrain_interval
        self.prediction_counter = 0

        # Safe results
        self.evaluation_history = []

    def save_to_csv(self, decision, pred_value,filename="../results-TS-2.csv"):
        if not os.path.exists(filename):
            with open(filename, 'w') as f:
                f.write("Decision,Prediction,\n")
                
        with open(filename, 'a') as f:
            f.write(f"{decision},{pred_value},\n")

    def make_cluster_decision(self, pred_value):
        '''Decision function to find the best cluster '''

        if pred_value > 40:
            return "CHOOSE_LARGER_CLUSTER"
        else:
            return "KEEP_CURRENT_CLUSTER"
        
    def fetch_new_data(self):
        '''Fetches new data from the data stream'''

        # Check if data file exists
        if not os.path.exists(self.stream_data_path):
            return pd.DataFrame()  

        # Current number of rows in the csv and a stop condition (no new row)
        with open(self.stream_data_path, "r", encoding="utf-8") as f:
            total_rows = sum(1 for _ in f)

        if total_rows <= self.processed_rows:
            print(f"No new data found in {self.stream_data_path}")
            return pd.DataFrame()

        # Reads header, reads new data and updates
        header = pd.read_csv(self.stream_data_path, nrows=0).columns.tolist()
        
        new_data = pd.read_csv(
            self.stream_data_path,
            skiprows=self.processed_rows,
            names=header              
        )

        # Remove non-numeric columns
        new_data = new_data.drop(columns=['Id','m_id','sample_time'], errors='ignore')
        
        self.processed_rows = total_rows
        
        return new_data
    
    def run_pipeline_step(self):
        """Receives a new data block, updates memory, and returns a prediction 
        if the internal memory contains enough data"""

        # Fetch new data 
        new_block = self.fetch_new_data()
        if new_block.empty:
            return None

        # Add data to the internal memory and check if length is sufficient for the model
        self.internal_memory = pd.concat([self.internal_memory, new_block], ignore_index=True)
        print(f"[+] Current Memory Size: {len(self.internal_memory)}/{self.w_l} rows loaded.")
        
        if len(self.internal_memory) < self.w_l:
            return "STANDBY"
            
        # Data stream specific and test data specific
        model_input_df = self.internal_memory.iloc[-self.w_l:]
        model_input_df = model_input_df.apply(pd.to_numeric, errors='coerce')

        # Calculate pred_value and decision and append them to the evaluation_history
        pred_value = run_inference(df=model_input_df, path=self.model_path, arch=self.model_arch, decentralized=True)
        peak = pred_value.max().item()

        decision = self.make_cluster_decision(peak)
        self.save_to_csv(decision, peak)

        # Clean internal memory
        self.internal_memory = self.internal_memory.iloc[self.w_l:]

        # Retrain Model decentral
        self.retrain()

        return decision, peak
        
    
    def start_live_monitoring(self, interval_sec=5):

        print(f"=== Monitoring started ({interval_sec}s interval) ===")
        try:
            while True:
                result = self.run_pipeline_step()
                
                if isinstance(result, tuple):
                    decision, prediction = result
                    print(f"[!!!] Prediction: {prediction} -> Decision: {decision}")
                
                elif result is None:
                    print("[.] No new data detected. Waiting...")
                
                else:
                    print(f"[-] Status: {result} (Collecting data...)")
                
                time.sleep(interval_sec)
        except KeyboardInterrupt:
            print("\n=== Monitoring stopped. ===")
    
    def retrain(self):
        self.prediction_counter += 1
        if self.prediction_counter >= self.retrain_interval:
            print("\n🔄 [PIPELINE INFO] You should retrain the model now!")
            self.prediction_counter = 0
    
if __name__ == "__main__":

    predictor = InferenceComponent()
    predictor.start_live_monitoring()

    # preds = preds.max().item()
    # print(preds)

    # predictor = InferenceComponent()

    # a = predictor.run_pipeline_step()
    
    # print(a.shape)

    #print(b.shape)