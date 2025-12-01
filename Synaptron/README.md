# 🧬 **TIMPI SYNAPTRON — OFFICIAL INSTALLATION GUIDE**

<img width="1480" height="862" src="https://github.com/user-attachments/assets/b0749433-3720-4422-a14d-26c4dec067c3" />

---

# 📑 **Table of Contents**

1. [Overview](#overview)
2. [Remove Older Synaptron Installations](#remove-older-synaptron-installations)
3. [System Requirements](#system-requirements)
4. [Install Docker](#install-docker)
5. [Install Docker Compose](#install-docker-compose)
6. [Install NVIDIA Drivers (Universal & Safe)](#install-nvidia-drivers-universal--safe)
7. [Install NVIDIA Container Toolkit](#install-nvidia-container-toolkit)
8. [One-Line Synaptron Installation](#one-line-synaptron-installation)
9. [What the Installer Does Automatically](#what-the-installer-does-automatically)
10. [Checking Logs](#checking-logs)
11. [Updating Synaptron](#updating-synaptron)
12. [Uninstall Synaptron](#uninstall-synaptron)
13. [Troubleshooting](#troubleshooting)


---

<a id="overview"></a>
## 🧭 **Overview**

This is the **simplest and safest way** to install a Synaptron node on:

* **Ubuntu 22.04 LTS**
* **Proxmox VM with GPU passthrough**
* **Any Debian-based Linux with NVIDIA support**

---

<a id="remove-older-synaptron-installations"></a>
## ⚠️ **Remove Older Synaptron Installations**

If you installed Synaptron manually or with an older script, remove old containers first:

### Stop & remove old containers

```bash
sudo docker stop timpi-synaptron 2>/dev/null
sudo docker rm timpi-synaptron 2>/dev/null 
sudo docker stop synaptron_universal 2>/dev/null
sudo docker rm synaptron_universal 2>/dev/null
sudo docker stop neo4jtest 2>/dev/null
sudo docker rm neo4jtest 2>/dev/null
sudo docker stop watchtower 2>/dev/null
sudo docker rm watchtower 2>/dev/null
````

### Remove old images

```bash
sudo docker images | grep timpi
sudo docker rmi timpiltd/timpi-synaptron-universal:latest 2>/dev/null
sudo docker rmi timpiltd/timpi-synaptron:latest 2>/dev/null
```

### Check manually so all **old** containers/images are removed

```bash
sudo docker ps
sudo docker ps -a
sudo docker images
```

```bash
sudo docker rm containerID
sudo docker rmi imageID
```

### Remove old folder

```bash
rm -rf ~/Synaptron
```

💡 The new installer automatically fixes permissions **only when needed**.

---

<a id="system-requirements"></a>

## 🖥 **System Requirements**

| Component | Minimum                              |
| --------- | ------------------------------------ |
| CPU       | 4 cores                              |
| RAM       | 12 GB                                |
| GPU       | NVIDIA GPU (Compute Capability 6.1+) |
| VRAM      | 4 GB+                                |
| Storage   | 250 GB SSD/NVMe                      |
| OS        | Ubuntu 22.04 / Proxmox VM            |

---

<a id="install-docker"></a>

## 🐳 **Install Docker**

Test if Docker already works:

```bash
docker version
```

If yes → skip to next section.

Otherwise install Docker CE:

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
```

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker && sudo systemctl start docker
```

---

<a id="install-docker-compose"></a>

## 📦 **Install Docker Compose**

Synaptron requires Docker Compose v2.23+

```bash
sudo apt install -y docker-compose-plugin
```

Check version:

```bash
docker compose version
```

---

<a id="install-nvidia-drivers-universal--safe"></a>

## 🎮 **Install NVIDIA Drivers (Universal & Safe)**

This guide **does NOT force any specific driver version**
(because different GPUs require different drivers).

---

### ✔ Step 1 — Check if driver is already working

```bash
nvidia-smi
```

If you see your GPU → **Drivers OK. Continue to next step.**

---

### ✔ Step 2 — Driver missing or broken?

If you get:

```text
nvidia-smi: command not found
```

or

```text
Failed to initialize NVML
```
---

## 🔧 **CUDA Compatibility Recommendation**

Before continuing, check the **CUDA Version** reported by:

```bash
nvidia-smi
```

Synaptron has been **tested and validated** on:

* **CUDA 12.8+** → Recommended for **Blackwell GPUs**
* **CUDA 12.4** → Recommended for **all other NVIDIA architectures**
  (Ada, Ampere, Turing, Pascal, etc.)

Other CUDA versions (like **12.6** or **13.x**) usually work,
but they are **not officially tested**, so performance may vary.

You may still continue with any version — this is only a **recommendation**, not a requirement.


---


Download the correct driver for your GPU:

👉 [https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/)

Install, reboot, then test:

```bash
nvidia-smi
```

---

<a id="install-nvidia-container-toolkit"></a>

## 🧩 **Install NVIDIA Container Toolkit**

Required for GPU support inside Docker.

If your installer complains about GPU access, run:

```bash
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

---


## 🧪 **Test NVIDIA GPU inside Docker (choose ONE)**

Run *one* of these depending on your CUDA version from `nvidia-smi`:

### Ex. If Your driver says: **CUDA 12.4**

```bash
docker run --rm --gpus all nvidia/cuda:12.4.0-base-ubuntu22.04 nvidia-smi
```

### Your driver says: **CUDA 12.8**
```bash
docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu22.04 nvidia-smi
```

---

<a id="one-line-synaptron-installation"></a>

## 🚀 **ONE-LINE SYNAPTRON INSTALLATION**

Run as **normal user**:


```bash
curl -s https://raw.githubusercontent.com/Timpi-official/Nodes/main/Synaptron/install.sh | bash
```

Installer will ask:

### 1️⃣ Node NAME (≥16 characters)

Example:

```text
SynaptronNodeProxmox001
```

### 2️⃣ GUID

Paste your Synaptron GUID.

---

<a id="what-the-installer-does-automatically"></a>

## 🤖 **What the Installer Does Automatically**

The installer:

✔ Creates `~/Synaptron/`

✔ Fixes permissions **only if needed**

✔ Downloads fresh `docker-compose.yml`

✔ Downloads `run_synaptron.sh`

✔ Injects NAME + GUID into YAML

✔ Detects your CUDA version

✔ Selects correct image (`cuda24` / `cuda28`)

✔ Validates:

* Docker
* Docker Compose
* NVIDIA drivers
* Toolkit
* GPU inside Docker

✔ Starts all containers:

* `synaptron_universal`
* `neo4jtest`
* `watchtower`

You will see:

```text
Synaptron is now running
```

---

<a id="checking-logs"></a>

## 📡 **Checking Logs**

To view real-time node output:

```bash
docker logs -f synaptron_universal
```

Initial run will:

* Install PyTorch
* Install CUDA libs
* Download models
* Prepare NLP tools

It’s ready when you see:

```text
Connected to Wilson...
Waiting for tasks...
```

---

<a id="updating-synaptron"></a>

## 🔄 **Updating Synaptron**

Synaptron updates automatically via Watchtower.

Manual update:

```bash
cd ~/Synaptron
docker compose pull
docker compose up -d
```

---

<a id="uninstall-synaptron"></a>

## ❌ **Uninstall Synaptron**

```bash
cd ~/Synaptron
docker compose down
rm -rf ~/Synaptron
```

---

<a id="troubleshooting"></a>

## 🆘 **Troubleshooting**

The installer detects:

* Missing GPU access
* Broken NVIDIA drivers
* Missing container toolkit
* Snap docker installation
* Permission errors
* Old versions blocking install
* Incorrect CUDA environment

Example fix message:

```text
Docker CANNOT access your NVIDIA GPU.
Fix steps:
  sudo apt install nvidia-container-toolkit
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
```


