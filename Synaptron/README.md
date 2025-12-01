# 🧬 **TIMPI SYNAPTRON — OFFICIAL INSTALLATION GUIDE**

<img width="1480" height="862" src="https://github.com/user-attachments/assets/b0749433-3720-4422-a14d-26c4dec067c3"/>

---

# 📑 **Table of Contents**

1. [Overview](#1-overview)
2. [Remove Older Synaptron Installations](#2-remove-older-synaptron-installations)
3. [System Requirements](#3-system-requirements)
4. [Install Docker](#4-install-docker)

   * 4.1 [Check if Docker is installed](#41-check-if-docker-is-installed)
   * 4.2 [Install Docker CE](#42-install-docker-ce)
5. [Install Docker Compose](#5-install-docker-compose)

   * 5.1 [Install Docker Compose plugin](#51-install-docker-compose-plugin)
   * 5.2 [Verify Docker Compose version](#52-verify-docker-compose-version)
6. [Install NVIDIA Drivers](#6-install-nvidia-drivers)

   * 6.1 [Check if driver works](#61-check-if-driver-works)
   * 6.2 [Fix missing/broken driver](#62-fix-missingbroken-driver)
   * 6.3 [CUDA compatibility recommendation](#63-cuda-compatibility-recommendation)
7. [Install NVIDIA Container Toolkit](#7-install-nvidia-container-toolkit)

   * 7.1 [Test GPU inside Docker](#71-test-gpu-inside-docker)
8. [One-Line Synaptron Installation](#8-one-line-synaptron-installation)
9. [What the Installer Does Automatically](#9-what-the-installer-does-automatically)
10. [Checking Logs](#10-checking-logs)
11. [Updating Synaptron](#11-updating-synaptron)
12. [Uninstall Synaptron](#12-uninstall-synaptron)
13. [Troubleshooting](#13-troubleshooting)

---

# 1. **Overview**

This guide provides the **official, stable, GPU-verified** installation method for:

* **Ubuntu 22.04 LTS**
* **Proxmox VMs with GPU passthrough**
* **Debian-based systems with NVIDIA support**

---

## 1.1 **Choose the correct path**

### 🟩 **You are upgrading from an older Synaptron**

Do this:

1. Go to **Section 2 — Remove Older Installations**
2. Then jump directly to **Section 8 — One-Line Installer**

### 🟦 **Brand-new install / fresh server**

Follow everything in order:

2 → 3 → 4 → 5 → 6 → 7 → 8

---

# 2. **Remove Older Synaptron Installations**

### 2.1 Stop & remove old containers

```bash
sudo docker stop timpi-synaptron synaptron_universal neo4jtest watchtower 2>/dev/null
sudo docker rm timpi-synaptron synaptron_universal neo4jtest watchtower 2>/dev/null
```

### 2.2 Remove old images

```bash
sudo docker rmi timpiltd/timpi-synaptron-universal:latest 2>/dev/null
sudo docker rmi timpiltd/timpi-synaptron:latest 2>/dev/null
```

### 2.3 Confirm everything is gone

```bash
sudo docker ps -a
sudo docker images
```

If anything remains:

```bash
sudo docker rm <containerID>
sudo docker rmi <imageID>
```

### 2.4 Remove old folders

```bash
rm -rf ~/Synaptron
```

---

# 3. **System Requirements**

| Component | Requirement                      |
| --------- | -------------------------------- |
| CPU       | 4 cores                          |
| RAM       | 12 GB minimum                    |
| GPU       | NVIDIA (Compute Capability 6.1+) |
| VRAM      | 4 GB+                            |
| Storage   | 250 GB SSD/NVMe                  |
| OS        | Ubuntu 22.04 / Proxmox VM        |

---

# 4. **Install Docker**

<a id="41-check-if-docker-is-installed"></a>

## 4.1 **Check if Docker is installed**

### Command:

```bash
docker version
```

### Expected output:

If Docker works, you should see:

```
Client: Docker Engine - Community
 Version:           27.x.x

Server: Docker Engine - Community
 Engine:
  Version:          27.x.x
```

If you see:

```
command not found
```

→ Docker is not installed.

### Optional check (beginner-friendly)

```bash
sudo systemctl status docker
```

Expected:

```
Active: active (running)
```

If both checks pass → Skip to section **5**.

---

<a id="42-install-docker-ce"></a>

## 4.2 **Install Docker CE**

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
```

Add Docker GPG key:

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

Add repository:

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install:

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker && sudo systemctl start docker
```

Re-test:

```bash
docker version
```

---

# 5. **Install Docker Compose**

<a id="51-install-docker-compose-plugin"></a>

## 5.1 Install Compose v2 plugin

```bash
sudo apt install -y docker-compose-plugin
```

<a id="52-verify-docker-compose-version"></a>

## 5.2 Verify version

```bash
docker compose version
```

Expected:

```
Docker Compose version v2.23.x  or newer
```

---

# 6. **Install NVIDIA Drivers**

<a id="61-check-if-driver-works"></a>

## 6.1 Test if driver is working

```bash
nvidia-smi
```

Expected:

```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 555.xx.xx  Driver Version: 555.xx  CUDA Version: 12.x           |
```

If your GPU appears → driver is fine.

---

<a id="62-fix-missingbroken-driver"></a>

## 6.2 If driver is missing or broken

You may see:

```
nvidia-smi: command not found
```

or

```
Failed to initialize NVML
```

→ Install or repair your driver.

---

<a id="63-cuda-compatibility-recommendation"></a>

## 6.3 CUDA compatibility recommendation

From `nvidia-smi`, check:

```
CUDA Version: 12.8
```

**Recommended:**

| Your GPU                                 | Use            |
| ---------------------------------------- | -------------- |
| Blackwell                                | CUDA **12.8+** |
| All others (Ada, Ampere, Turing, Pascal) | CUDA **12.4**  |

Other versions (12.6, 13.x) usually work but are **not tested**.

Official driver install guide:
[https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/)

---

# 7. **Install NVIDIA Container Toolkit**

```bash
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

---

<a id="71-test-gpu-inside-docker"></a>

## 7.1 Test GPU inside Docker

### CUDA 12.4

```bash
docker run --rm --gpus all nvidia/cuda:12.4.0-base-ubuntu22.04 nvidia-smi
```

### CUDA 12.8+

```bash
docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu22.04 nvidia-smi
```

Expected output:
NVIDIA-SMI table appears **inside Docker**.

---

# 8. **One-Line Synaptron Installation**

Run as normal user:

```bash
https://raw.githubusercontent.com/Timpi-official/Nodes/main/Synaptron/install.sh
```

Installer asks:

### 1️⃣ Enter your Node NAME

(At least 17 characters)

### 2️⃣ Enter your GUID

---

## ⏳ Important Note

Model downloads & OLLAMA setup may take **20–40 minutes** depending on system speed.

Do **not** interrupt it.

---

## When the installation is finished, you will see:

```text
Synaptron is now running
```

This is the final success confirmation.

---

# 9. **What the Installer Does Automatically**

✔ Creates `~/Synaptron/`
✔ Fixes permissions
✔ Downloads latest `docker-compose.yml`
✔ Adds correct **DNS servers**
✔ Injects NAME + GUID
✔ Detects CUDA version
✔ Selects correct container image
✔ Validates Docker, Compose, Drivers, Toolkit
✔ Starts:

* `synaptron_universal`
* `neo4jtest`
* `watchtower`

---

# 10. **Checking Logs**

```bash
docker logs -f synaptron_universal
```

Ready when you see:

```
Connected to Wilson...
Waiting for tasks...
```

---

# 11. **Updating Synaptron**

Auto-updated by **Watchtower**.

Manual update:

```bash
cd ~/Synaptron
docker compose pull
docker compose up -d
```

---

# 12. **Uninstall Synaptron**

```bash
cd ~/Synaptron
docker compose down
rm -rf ~/Synaptron
```

---

# 13. **Troubleshooting**

The installer automatically detects:

* Missing GPU access
* Broken NVIDIA drivers
* Missing container toolkit
* Snap Docker issues
* Wrong permissions
* Old files blocking installation
* Incorrect CUDA environment

Example fix:

```
Docker CANNOT access your NVIDIA GPU.
Fix steps:
  sudo apt install nvidia-container-toolkit
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
```

If errors persist, include:

* Your `nvidia-smi` output
* Your Docker GPU test output
* Your GUID
* The last 20 lines of Synaptron log
