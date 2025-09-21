# 🧠 Timpi Synaptron Node Setup (Linux)

✅ *Tested on Ubuntu 22.04.4 LTS – Native Only*
⚠️ *Requires Docker and NVIDIA GPU Drivers*

---

![Timpi Logo](https://nft.timpi.io/assets/timpi_image/synaptron-hero.jpg)

# 📑 Table of Contents

* [Minimum System Requirements](#-minimum-system-requirements)
* [Supported GPUs (Examples)](#-supported-gpus-examples)
* [Step 1 – Install NVIDIA GPU Drivers](#step-1-install-nvidia-gpu-drivers)

  * [Install Drivers](#-install-drivers)
  * [Verify Installation](#-verify-installation)
* [Step 2 – Install Docker + NVIDIA Docker](#-step-2--install-docker--nvidia-docker)

  * [Install Docker](#-install-docker)
  * [Install NVIDIA Docker](#-install-nvidia-docker)
* [Step 3 – Choose Your Installation Method](#-step-3--choose-your-installation-method)

  * [Option A: Automatic Installation](#-option-a-automatic-installation)
  * [Option B: Manual Setup](#-option-b-manual-setup)

    * [Deploy the Synaptron Node Manually](#deploy-the-synaptron-node-manually)
* [How to Update Synaptron](#-how-to-update-synaptron)
* [Monitoring & Troubleshooting](#-monitoring--troubleshooting)
* [Video Walkthrough](#-video-walkthrough)
* [Support](#-support)

---

## 📌 Minimum System Requirements

| Component    | Minimum                                                     |
| ------------ | ----------------------------------------------------------- |
| **CPU**      | 4 Cores                                                     |
| **RAM**      | 12 GB                                                       |
| **GPU**      | NVIDIA GPU with Compute Capability **6.1+**, min. 4 GB VRAM |
| **Storage**  | 250 GB SSD/NVMe                                             |
| **Internet** | Unlimited, stable                                           |
| **OS**       | Ubuntu 22.04 64-bit                                         |

> ❌ **Multi-GPU setups are not supported**

---

## 🎮 Supported GPUs (Examples)

| Tier   | VRAM    | Cards                                            |
| ------ | ------- | ------------------------------------------------ |
| Tier 1 | 4–6 GB  | GTX 1050, GTX 1060, RTX 2050, RTX 2060, RTX 3050 |
| Tier 2 | 8–16 GB | GTX 1080 Ti, RTX 2080 Ti, RTX 4060               |

🔗 [Check your GPU Compatibility](https://developer.nvidia.com/cuda-gpus)

---

## Step 1 install nvidia gpu drivers

You **must install** official NVIDIA drivers **before proceeding**.

### 📥 Install Drivers

Use the official guide:
👉 [https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/#ubuntu](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/#ubuntu)

### ✅ Verify Installation

Run the following to confirm the drivers are working:

```shell
nvidia-smi
```

---

## 🧱 Step 2 – Install Docker + NVIDIA Docker

> These steps are required for both **manual** and **automatic** installation methods.

### 🐳 Install Docker

```shell
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
```

```shell
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

```shell
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```shell
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker && sudo systemctl start docker
```

✅ Check Docker version:

```shell
sudo docker version
```

---

### 🎮 Install NVIDIA Docker

```shell
sudo curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```

```shell
sudo apt update
sudo apt install -y nvidia-docker2
sudo systemctl restart docker
```

✅ Confirm GPU is visible to Docker:

```shell
nvidia-smi
```

---

## 🚀 Step 3 – Choose Your Installation Method

You now have two options:

| Option                 | Description                                   |
| ---------------------- | --------------------------------------------- |
| ✅ **Automatic Script** | Recommended – deploys everything via a script |
| 🔧 **Manual Setup**    | Advanced – step-by-step, full control         |

---

## ✅ Option A: Automatic Installation

> **Use this if Docker and NVIDIA drivers are installed.**

This script will:

* Confirm GPU is available
* Ask for your **Node Name** and **GUID**
* Deploy Synaptron automatically

```shell
curl -sSL -o Synaptron_setup.sh https://raw.githubusercontent.com/Timpi-official/Nodes/main/Synaptron/Synaptron_setup
chmod +x Synaptron_setup.sh
./Synaptron_setup.sh
```

🕐 Takes \~30 minutes to download Synaptron data on first boot.

---

## 🔧 Option B: Manual Setup

> Use this method if you prefer full control or to learn how it works behind the scenes.

### Deploy the Synaptron Node Manually

Paste this entire block into your terminal. It will:

1. Ask you to enter a **unique node name** (minimum 17 characters).
2. Ask for your **Guardian GUID** (you can find this in your Timpi dashboard).
3. Start the Synaptron container with GPU acceleration enabled.

```shell
read -p "Enter a unique node name (min. 17 characters): " node_name
read -p "Enter your GUID: " guid
sudo docker run --pull=always --restart always -d \
  -e NAME="$node_name" -e GUID="$guid" --gpus all \
  timpiltd/timpi-synaptron:latest
```

> 🧠 **What this does:**
>
> * `--pull=always`: ensures the container always runs the latest version
> * `--restart always`: container restarts automatically after reboot
> * `--gpus all`: enables NVIDIA GPU usage inside the container
> * `-e NAME=...` and `-e GUID=...`: passes your custom name and ID to the node
> * `-d`: runs in the background (detached mode)

---

## 🔁 How to Update Synaptron

When a new release is announced:

```shell
sudo docker stop <container_id>
sudo docker rm <container_id>
```

Then re-run the [Deploy the Synaptron Node Manually](#deploy-the-synaptron-node-manually) command above with the same `node_name` and `guid`.

---

## 🧪 Monitoring & Troubleshooting

| Task                   | Command                                |
| ---------------------- | -------------------------------------- |
| See running containers | `sudo docker ps`                       |
| View container logs    | `sudo docker logs -f <container_id>`   |
| Restart a container    | `sudo docker start -ia <container_id>` |
| Stop a container       | `sudo docker stop <container_id>`      |
| Remove a container     | `sudo docker rm <container_id>`        |
| Check GPU status       | `nvidia-smi`                           |

---

## 🎥 Video Walkthrough

📺 [Watch the Setup Video](https://www.youtube.com/watch?v=nhfq0PAm_BE&t=6s)

---

## 🙋 Support

Having trouble or want help?

* 💬 Ask in [Discord – Synaptron Channel](https://discord.com/channels/946982023245992006/1179480886455046264)
* 🐛 Report bugs or suggestions: [Discord Support](https://discord.com/channels/946982023245992006/1179427377844068493)

---

**Built with ❤️ by the Timpi community**
Powering a truly free and private internet 🌍
