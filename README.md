# TDPO: Time Decaying Privacy-Preserving Distributed Optimization


This repository contains the official open-source code for our paper:  TDPO: Time Decaying Privacy-Preserving Distributed Optimization for Multi-Agent Systems

**TDPO** scheme is designed to achieve exact optimal consensus for multi-agent systems while providing unconditional algebraic security against passive inferences. By leveraging a highly efficient $O(1)$ scalar arithmetic mechanism, TDPO bypasses the severe computational bottlenecks of traditional cryptographic methods, making it highly suitable for resource-constrained physical entities like uncrewed systems.

## 📂 Repository Structure

The repository is organized into three main directories based on their functionalities:

### 1. `Mask_Convergence_Analysis` 
This folder contains the numerical simulation scripts used to compute and compare the mask outputs, convergence trajectories, and exact optimal accuracy of different distributed optimization algorithms.
* **Key Features:** Simulates the algorithm's performance against state-of-the-art methods (e.g., standard EXTRA, DGD) and plots the logarithmic residual decrease.

### 2. `Pis`
This folder contains the Python (`.py`) scripts developed for the physical hardware experiments deployed on **Raspberry Pi** microcomputers.
* **Key Features:** Implements the continuous state exchange among neighboring agents using low-latency UDP/IP socket programming. 

### 3. `Scalability`
This folder provides the scripts used for the scalability and robustness analysis in large-scale multi-agent networks.
* **Key Features:** Evaluates how the TDPO scheme perfectly maintains its high execution efficiency and exact convergence as the number of agents  significantly increases.

---

## 🚀 Getting Started

### Prerequisites
* **For Numerical Simulations:** MATLAB R2018 or later.
* **For Hardware Simulations (`Pis`):** Python 3.x, deployed on Raspberry Pi (Model 4B recommended) or any local Linux/Windows network environment.
* **Network Setup:** Ensure all physical or virtual nodes are connected to the same Local Area Network (LAN) if running the UDP socket scripts.

