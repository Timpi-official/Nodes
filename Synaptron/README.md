# 🧬 Timpi – Synaptron Installers for Linux & Windows

<img width="1509" height="850" alt="Screenshot_2025-07-23_183112_upscayl_3x_realesrgan-x4plus-anime" src="https://github.com/user-attachments/assets/14e85fef-e61b-4828-998b-884d81ad0b0f" />

Welcome to the official repository for **Timpi Synaptron installations**.  
Here you'll find everything you need to run your Timpi Synaptron node on **Linux** or **Windows**, including setup instructions and system requirements.

---

## ⚠️ Important Support Notice

Timpi Synaptrons are supported on the following environments:

* ✅ **Linux Ubuntu 22.04.4+ with Docker** (requires NVIDIA GPU + CUDA drivers)
* ✅ **Windows 10/11 (native installer)**

❌ **Not Supported**: macOS, WSL (Linux on Windows), Proxmox LXC, or other non-Ubuntu Linux distributions.

❌ **Not Supported**: Systems without a supported NVIDIA GPU (CUDA-capable).

👉 If you choose to run on **any other Linux distribution**, you are welcome to try — but we **do not provide technical support in tickets** for non-Ubuntu setups. You must be able to troubleshoot and guide yourself.

👉 Timpi support is limited to the **Synaptron software**, GPU setup instructions, and the **official installation guides**. Network, firewall, and host-system configuration remain the operator’s responsibility.

---

### 🔎 Check Your GPU First!

Before installing, confirm that your NVIDIA GPU supports CUDA:
👉 [List of CUDA-Compatible GPUs](https://developer.nvidia.com/cuda-gpus)

If your GPU is **not listed**, you cannot run a Synaptron node.

---


We provide:

✅ Step-by-step installation guides  
⚙️ Support for GPU-accelerated workloads  
💻 Compatibility with Linux Ubuntu 22.04.4+ and Windows 10/11  
📁 Clean separation by platform

---

## 🧠 Synaptron Overview

Synaptrons are high-performance AI nodes that power the Timpi network’s ability to process, understand, and analyze web content.  
They require a compatible NVIDIA GPU and serve as the "brains" of the Timpi ecosystem.

---

## 🐳 Docker-Based Synaptron

Timpi also supports Docker for advanced users who want an isolated container setup.
Docker setups are ideal for multi-node environments or headless installations.

👉 **[Synaptron Linux Guide & Scripts](https://github.com/Timpi-official/Nodes/blob/main/Synaptron/guides/Linux.md)**  
Includes full instructions for GPU driver setup, Docker/NVIDIA Docker installation, and node deployment.

---

## 🪟 Windows Synaptron - Native (Windows 10/11)

👉 **[Synaptron Windows Guide & Instructions](https://github.com/Timpi-official/Nodes/blob/main/Synaptron/guides/Windows.md)**
Covers installation, node registration, and troubleshooting in an easy-to-follow format.

---


  ---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 🤝 Contributing

Found a bug or have suggestions? Pull requests are welcome!  
For major changes, please [open an issue](https://discord.com/channels/946982023245992006/1179427377844068493) to discuss it with us first.
