# QONNECT-FL: Federated Time-Series Forecasting for Resource-Aware Cloud-Edge Orchestration

[![Cloud-Edge](https://img.shields.io/badge/Cloud--Edge-Continuum-blueviolet?style=flat)](https://github.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Federated Learning](https://img.shields.io/badge/Federated-Learning-success?style=flat)](https://github.com/)
[![Time-Series](https://img.shields.io/badge/TS-Forecasting-yellow?style=flat)](https://github.com/)

This repository houses QONNECT-FL, an extension of the QONNECT[[1]](https://github.com/dos-group/QONNECT) orchestrator designed for the public cloud. It includes complete setups for two orchestration profiles—each spanning a cloud, edge, and fog cluster on Microsoft Azure—along with the required architectural adaptations for inter-cluster consistency.

It integrates a federated forecasting approach for resource-aware scheduling, alongside benchmarks for five deep forecasting architectures for cluster CPU load using heterogeneous public telemetry.

Detailed usage instructions can be found in the respective subdirectories:

* **`deploy-QONNECT-fl/`** — Contains the infrastructure provisioning, Kubernetes cluster deployment, and the rollout of the QONNECT components. 

* **`runtime-optimization/`** — Implements various deep time-series models trained via the tsai[[2]](https://github.com/timeseriesAI/tsai) framework (both standalone and federated using Flower[[3]](https://github.com/flwrlabs/flower)), serving as the predictive component for the resource orchestration approach in QONNECT. 
