# 🧬 Timpi – Synaptron Installers for Linux, Windows & Docker

<img width="1509" height="850" alt="Screenshot_2025-07-23_183112_upscayl_3x_realesrgan-x4plus-anime" src="https://github.com/user-attachments/assets/14e85fef-e61b-4828-998b-884d81ad0b0f" />

Welcome to the official repository for **Timpi Synaptron installations**.  
Here you'll find everything you need to run your Timpi Synaptron node on **Linux**, **Windows**, or **Docker**, including setup instructions and system requirements.

---

## ⚠️ Important Support Notice

Timpi Synaptrons are supported on the following environments:

* ✅ **Linux Ubuntu 22.04 / 24.04 LTS** — native runner (requires NVIDIA GPU + CUDA-capable driver)
* ✅ **Windows 10/11** — native desktop app
* ✅ **Docker (Linux + NVIDIA)** — containerized runner (requires the NVIDIA Container Toolkit)

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

## 🐧 Linux Synaptron (Ubuntu 22.04 / 24.04)

The Synaptron runs as a **native node runner** — download the runner, run one installer command, and
it registers with the Controller and keeps itself running as a systemd service.

👉 **[Synaptron Linux Guide](https://github.com/Timpi-official/Nodes/blob/main/Synaptron/guides/Linux.md)**  
Requirements, download, install, verifying your node, updating, and troubleshooting.

---

## 🪟 Windows Synaptron (Windows 10/11)

The Synaptron installs from a **desktop app** — extract the runner, double-click, enter your node
GUID, and click install.

👉 **[Synaptron Windows Guide](https://github.com/Timpi-official/Nodes/blob/main/Synaptron/guides/Windows.md)**
Requirements, download, the desktop-app install, verifying your node, and troubleshooting.

---

## 🐳 Docker (Linux + NVIDIA)

Run the Synaptron as a **Docker container** — the entire runtime is baked into one image. Pull it, run
one command with your node GUID, and keep it updated automatically with **Watchtower**. Requires the
**NVIDIA Container Toolkit** on the host.

👉 **[Synaptron Docker Guide](https://github.com/Timpi-official/Nodes/blob/main/Synaptron/guides/Docker.md)**  
Requirements, pull, run, verifying your node, Watchtower auto-updates, and troubleshooting.

---


  ---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 🤝 Contributing

Found a bug or have suggestions? Pull requests are welcome!  
For major changes, please [open an issue](https://discord.com/channels/946982023245992006/1179427377844068493) to discuss it with us first.
