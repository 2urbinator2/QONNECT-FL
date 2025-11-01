"""FedLabX-MT: A Flower / PyTorch app."""

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import TensorDataset, random_split, DataLoader
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import r2_score


class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.network = nn.Sequential(
            nn.Linear(5, 32),   
            nn.ReLU(),
            nn.Linear(32, 16),
            nn.ReLU(),
            nn.Linear(16, 1)  
        )

    def forward(self, x):
        return self.network(x)

 
def load_data(partition_id: int, num_partitions: int):
    df = pd.read_csv("/home/furban/data.csv")

    X = df[["hour", "day_of_week", "temperature", "household_size", "consumption_prev_hour"]].values
    y = df["consumption_next_hour"].values.reshape(-1, 1)

    scaler_X = StandardScaler()
    X_scaled = scaler_X.fit_transform(X)

    scaler_y = StandardScaler()
    y_scaled = scaler_y.fit_transform(y)

    X_tensor = torch.tensor(X_scaled, dtype=torch.float32)
    y_tensor = torch.tensor(y_scaled, dtype=torch.float32)

    dataset = TensorDataset(X_tensor, y_tensor)
    train_size = int(0.8 * len(dataset))
    test_size = len(dataset) - train_size
    train_dataset, test_dataset = random_split(dataset, [train_size, test_size])

    train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
    test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False)

    return train_loader, test_loader


def train(net, trainloader, epochs, lr, device):
    net.to(device)  # Modell auf Gerät verschieben
    criterion = nn.MSELoss()  # Regression
    optimizer = optim.Adam(net.parameters(), lr=lr)
    net.train()
    
    running_loss = 0.0
    
    for epoch in range(epochs):
        for xb, yb in trainloader:
            xb, yb = xb.to(device), yb.to(device)
            optimizer.zero_grad()
            preds = net(xb)
            loss = criterion(preds, yb)
            loss.backward()
            optimizer.step()
            running_loss += loss.item()
        
        # Optional: alle 10 Epochen ausgeben
        if (epoch + 1) % 10 == 0:
            print(f"Epoch {epoch+1}/{epochs}, Loss: {loss.item():.4f}")
    
    avg_train_loss = running_loss / len(trainloader)
    return avg_train_loss


def test(net, testloader, device):
    net.to(device)
    criterion = nn.MSELoss()
    net.eval()
    
    running_loss = 0.0
    with torch.no_grad():
        for xb, yb in testloader:
            xb, yb = xb.to(device), yb.to(device)
            preds = net(xb)
            loss = criterion(preds, yb)
            running_loss += loss.item()
    
    avg_loss = running_loss / len(testloader)
    eval_acc = 0  
    
    return avg_loss, eval_acc