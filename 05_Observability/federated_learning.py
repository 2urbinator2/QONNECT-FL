import torch
from torch import nn, optim

# Simuliere Daten für 3 Clients
client_data = [
    (torch.randn(10, 1), torch.randn(10, 1) * 2 + 1),  # Client 1
    (torch.randn(10, 1), torch.randn(10, 1) * 0.5 - 1), # Client 2
    (torch.randn(10, 1), torch.randn(10, 1) * 1 + 0),   # Client 3
]

# Einfaches lineares Modell
class SimpleModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.linear = nn.Linear(1, 1)
    def forward(self, x):
        return self.linear(x)

# Server: Globales Modell initialisieren
global_model = SimpleModel()

# Trainingsparameter
epochs = 3
lr = 0.1

for round in range(5):  # 5 Federated Rounds
    client_weights = []
    print(f"\n--- Runde {round+1} ---")
    
    # Jeder Client trainiert lokal
    for data, target in client_data:
        local_model = SimpleModel()
        local_model.load_state_dict(global_model.state_dict())  # Start vom globalen Modell
        
        optimizer = optim.SGD(local_model.parameters(), lr=lr)
        loss_fn = nn.MSELoss()
        
        # Lokales Training
        for _ in range(epochs):
            optimizer.zero_grad()
            pred = local_model(data)
            loss = loss_fn(pred, target)
            loss.backward()
            optimizer.step()
        
        client_weights.append(local_model.state_dict())
    
    # Server aggregiert Gewichte (Durchschnitt)
    new_state_dict = global_model.state_dict()
    for key in new_state_dict:
        new_state_dict[key] = torch.stack([client[key] for client in client_weights], 0).mean(0)
    
    global_model.load_state_dict(new_state_dict)
    print(f"Globales Modell nach Runde {round+1}: {global_model.linear.weight.item():.4f}, {global_model.linear.bias.item():.4f}")


def predict(global_model, x_input):
    global_model.eval()
    with torch.no_grad():
        y_hat = global_model(x_input)
    return y_hat


x_vals = input("Gib Zahlen ein, getrennt durch Komma: ")  # z.B. "0.2,0.5"
x_list = [float(x.strip()) for x in x_vals.split(",")]  # in Liste von floats
x_tensor = torch.tensor([[x] for x in x_list])  # in 2D-Tensor umwandeln

# Vorhersage
y_pred = predict(global_model, x_tensor)
print("Vorhersagen:", y_pred)