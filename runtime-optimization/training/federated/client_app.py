import matplotlib
matplotlib.use('Agg')

import sys
sys.path.append("../")

import torch

from flwr.app import ArrayRecord, Context, Message, MetricRecord, RecordDict
from flwr.clientapp import ClientApp

from flwr.common import Context

from core import prepare_data, create_learner_object
from inference import create_model_architecture

app = ClientApp()

@app.train()
def train(msg: Message, context: Context):

    # Create Model an load weights
    arch: str = context.run_config["arch"]
    model, _ = create_model_architecture(arch)
    model.load_state_dict(msg.content["arrays"].to_torch_state_dict())

    # Load config data
    partition_id: int = context.node_config["partition-id"]
    path: str = context.run_config["data_path"]
    epochs: int = context.run_config["epochs"]
    lr_from_server = msg.content["config"]["lr"]

    # Create DLS and Chose Paramters
    dls, _, _, _, = prepare_data(partition_id=partition_id, decentralized=True,  data_path=path) 
    device = torch.device("mps" if torch.backends.mps.is_available() else "cuda" if torch.cuda.is_available() else "cpu")
  
    # Intialize learner, determine lr and train
    learn = create_learner_object(dls, model, device) 
   
    # Training
    with learn.no_bar(), learn.no_logging():
        learn.fit_one_cycle(epochs, lr_from_server)

    # Transfer updates to the server
    model_record = ArrayRecord(learn.model.state_dict())

    # Print Metrices
    current_loss = float(learn.recorder.losses[-1])
    metrics = {
        
        "num-examples": len(dls.dataset),
        "loss": current_loss,
    }
    metric_record = MetricRecord(metrics)
    content = RecordDict({"arrays": model_record, "metrics": metric_record})

    return Message(content=content, reply_to=msg)


@app.evaluate()
def evaluate(msg: Message, context: Context):

    # Create Model an load weights
    arch: str = context.run_config["arch"]
    model, _ = create_model_architecture(arch)
    model.load_state_dict(msg.content["arrays"].to_torch_state_dict())

    # Load config data
    path: str = context.run_config["data_path"]
    partition_id: int = context.node_config["partition-id"]

    # Create DLS 
    dls, _, _, _, = prepare_data(partition_id=partition_id, decentralized=True,  data_path=path)
    device = torch.device("mps" if torch.backends.mps.is_available() else "cuda" if torch.cuda.is_available() else "cpu")

    # Create DLS and determine resource 
    learn = create_learner_object(dls, model, device) 
 
    # Evaluate model on the data
    with learn.no_bar(), learn.no_logging():
        loss, m_mse, m_mae, m_rmse = learn.validate()

    # Transfer results
    metrics = {
        "val_loss":  loss,
        "mse":  m_mse,
        "mae":  m_mae,
        "rmse":  m_rmse,
        "num-examples": len(dls.dataset),
    }

    metric_record = MetricRecord(metrics)
    content = RecordDict({"metrics": metric_record})

    return Message(content=content, reply_to=msg)