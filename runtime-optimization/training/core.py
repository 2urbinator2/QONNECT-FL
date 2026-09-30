"""FedLabX-MT: A Flower / PyTorch app."""
import matplotlib
matplotlib.use('Agg')

# ML 
import torch
import pandas as pd
import numpy as np


# Path
from pathlib import Path

# Further
import gc
import joblib

# TSAI modules 
from tsai.data.preparation import SlidingWindow
from tsai.data.preprocessing import TSStandardize
from tsai.data.core import get_ts_dls
from tsai.learner import ts_learner

from fastai.torch_core import set_seed
from fastai.metrics import mse, mae, rmse
   
def prepare_data(partition_id, decentralized=False, data_path="../data/train.csv", stats_file=Path('../models/decentral-sim') / 'preprocessing_stats.joblib', t_p=0.6, v_p=0.8, w_l=96, h=30, bs=64, s=2):
    '''Loads the data, prepares it for the hardware, and returns a fully prepared DataLoader'''
    
    # Load Data, remove non-numeric columns and bring data in the same format
    df = pd.read_csv(data_path)
    unique_mids = sorted(df['m_id'].unique())
    target_id = unique_mids[partition_id] 
    df = df[df['m_id'] == target_id].copy()  
    df = df.select_dtypes(include=[np.number]) 
    df = df.astype('float32')

    # Data Splitting (train=0.6, val=0.2, test=0.2), delete df 
    df_train, df_val, df_test = split_df(df, t_p, v_p)
    del df
    gc.collect()

    # Build colum arrays, copy X raw data and return
    y_col = [df_test.columns.get_loc('cpu_01_busy')]

    # Create mean und sts based on train data
    if decentralized:    
        stats = joblib.load(stats_file)
        means = stats['means']
        stds = stats['stds']
    else:
        means = df_train.mean(axis=0).values
        stds = df_train.std(axis=0).values  
        stds[stds == 0] = 1.0

    # Window sliding
    X_train, y_train = SlidingWindow(window_len=w_l, stride=s, get_y=y_col, get_x=None, horizon=h)(df_train)
    X_val, y_val = SlidingWindow(window_len=w_l, stride=s, get_y=y_col, get_x=None, horizon=h)(df_val)

    # del df_train, df_val
    gc.collect()

    # Combine test and validate data and safe legth
    len_train = len(X_train)
    len_val   = len(X_val)

    X = np.concatenate([X_train, X_val]).astype('float32')
    y = np.concatenate([y_train, y_val]).astype('float32')
 
    del X_train, X_val, y_train, y_val
    gc.collect()

    # Create Dataloaders
    train_idx = list(range(0, len_train))
    val_idx = list(range(len_train, len_train + len_val))
    
    splits =(train_idx, val_idx)
    tfms = [None, None]
    batch_tfms = TSStandardize(mean=means[None, :, None], std=stds[None, :, None], by_sample=False)

    dls = get_ts_dls(X, y, splits=splits, tfms=tfms, batch_tfms=batch_tfms, bs=bs, shuffle_train=False)

    del X, y 
    gc.collect()

    return dls, df_test, means, stds

def create_learner_object(dls, arch, device=None, seed=42):
    '''Creates a TSAI learner object'''

    # set_seed(seed, reproducible=True)

    learn = ts_learner(dls, arch, metrics=[mse, mae, rmse], device=device, path=Path("."))

    return learn

def split_df(df, t_p=0.6, v_p=0.8):
    '''Splits Data in Train, Validfation, Test'''

    df_train = df.iloc[:int(len(df) * t_p)].copy()

    df_val = df.iloc[int(len(df) * t_p):int(len(df) * v_p)].copy()
    df_test = df.iloc[int(len(df) * v_p):].copy()

    return  df_train, df_val, df_test

def calculate_mean(target_clusters=["a", "b", "c"]):
    '''Calculates mean for federated learning'''
    
    data_path = "../data/train.csv"
    models_path = "../models/decentral-sim"

    df = pd.read_csv(data_path)
    test_frames = []

    for m_id in target_clusters:
        sub_df = df[df['m_id'] == m_id]
        train, _, _ = split_df(sub_df)

        test_frames.append(train)

    df_train = pd.concat(test_frames)
    df_train = df_train.select_dtypes(include=[np.number]) 

    means = df_train.mean(axis=0).values
    stds = df_train.std(axis=0).values  
    stds[stds == 0] = 1.0

    target_path = Path(models_path).resolve()
    target_path.mkdir(parents=True, exist_ok=True)
    stats_file = target_path / 'preprocessing_stats.joblib'

    if not stats_file.exists():
        target_path.mkdir(parents=True, exist_ok=True)
        joblib.dump({'means': means, 'stds': stds}, stats_file)