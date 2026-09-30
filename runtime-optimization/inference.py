import torch
import numpy as np

from tsai.models.InceptionTime import InceptionTime
from tsai.models.TSTPlus import TSTPlus
from tsai.models.gMLP import gMLP
from tsai.models.RNN import LSTM
from tsai.models.RNNPlus import GRUPlus

from tsai.data.preparation import SlidingWindow

from training.core import prepare_data



from pathlib import Path
import gc
import joblib


def create_model_architecture(model_name, c_in=87, c_out=30, seq_len=96):

    if model_name == "LSTM":
        arch = LSTM(c_in=c_in, c_out=c_out)

    elif model_name == "GRUPlus":
        arch = GRUPlus(c_in=c_in, c_out=c_out, seq_len=seq_len)

    elif model_name == "InceptionTime":
        arch = InceptionTime(c_in=c_in, c_out=c_out, seq_len=seq_len)

    elif model_name == "TSTPlus":
        arch = TSTPlus(c_in=c_in, c_out=c_out, seq_len=seq_len)

    elif model_name == "gMLP":
        arch = gMLP(c_in=c_in, c_out=c_out, seq_len=seq_len)
    
    else: 
        raise ValueError(f"Architecture unknown: '{model_name}'")

    return arch, model_name

def run_inference(df, path, arch, decentralized=False, s=2, w_l=96, h=30):
    '''Makes predictions for raw data'''

    # Model and stats path
    base_path = Path(path).resolve()
    
    if decentralized:
        model_file = base_path / f"{arch}.pth"
        base_path = base_path.parent
    else:
        model_file = base_path / "models" / f"{arch}.pth"

    stats_file = base_path / 'preprocessing_stats.joblib'

    # Load required stats 
    stats = joblib.load(stats_file)
    means = stats['means']
    stds = stats['stds']

    # Scaling, Window Sliding 
    df = df.select_dtypes(include=[np.number]).astype('float32')
    X_scaled = (df - means) / stds
    X_test, _ = SlidingWindow(window_len=w_l, stride=s, get_x=None, get_y=[])(X_scaled)

    # Load Model
    model, _ = create_model_architecture(model_name=arch, c_in=87, c_out=h, seq_len=96)
    weights = torch.load(model_file, map_location=torch.device('cpu'))
    model.load_state_dict(weights)
    model.eval()

    # Predictions
    X_tensor = torch.tensor(X_test, dtype=torch.float32)
    with torch.no_grad():
        predictions = model(X_tensor)

    return predictions