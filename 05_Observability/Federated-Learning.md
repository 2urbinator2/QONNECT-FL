# Federated Learning

## Konzept 
- zentraler Server: Hält globales Model
- Clients: Jeder Client hat eigene lokale Daten
- Ablauf:
  - Server schickt globales Model an alle Clients
  - Jeder Client trainiert das Modell lokal auf seinen Daten 
  - Jeder schickt nur Gewichtsupdates 
  - Der Server aggregiert die Updates (z.B. Durchschnitt) und aktualisiert das globale Model
  - Vorgang wiederholen (mehrere Runden)
- Modelle können überwacht und unüberwacht
- Trianing erfolgt vorher -> System hat nur die ermittelten Parameter


-> Gute Frameworks für Machine Learning -> Anaconda
    -> Viele Libraries bereits installiert

- Beispiel: 
  - überwachtes lernen: Daten sind gelabelt (x,y)
  - lineares model: y = w * x + b
    - wird mit gradient Descent gelöst 
  - Training
    - 5 Trainingsrunden
    - federated averaging wird verwendet
- 