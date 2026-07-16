# 🧠 Timpi Nodes – Collector Installers for Linux & Windows

Welcome to the official repository for **Timpi Collector installations**.  
Here you'll find everything you need to run your Timpi Collector node on **Linux** or **Windows**, including easy one-command setup scripts.

---

## ⚠️ Important Support Notice

Timpi Collectors are supported on the following environments:

* ✅ **Linux Ubuntu 22.04.4+ (native)**
* ✅ **Linux Ubuntu 22.04.4+ with Docker**
* ✅ **Windows 10/11 (native installer)**

❌ **Not Supported**: macOS, WSL (Linux on Windows), Proxmox LXC, or other non-Ubuntu Linux distributions.

👉 If you choose to run on **any other Linux distribution**, you are welcome to try — but we **do not provide technical support in tickets** for non-Ubuntu setups. You must be able to troubleshoot and guide yourself.

👉 Timpi support is limited to the **Collector software** and the **official installation guides**. Network, firewall, and hardware configuration remain the responsibility of the operator.

---


## 🔄 Timpi Collector Overview

Collectors are decentralized “workers” that crawl the web and gather metadata about websites and pages.  
They do not expose any services to the internet, helping maintain high security and privacy.

---

## 🐳 Docker Collector v2 — recommended

**Docker is the supported way to run a Collector on Linux.** It is the only Collector build that receives
updates: with **Watchtower** (§8 of the guide) your node moves to each new version automatically, and one
Watchtower covers every Timpi node on the machine.

* 🐧 **[Linux Docker Collector Guide](https://github.com/Timpi-official/Nodes/blob/main/DockerCollector/Tutorial/LinuxDockerCollectorLatest.md)**
  Clean, containerized setup for Ubuntu. Works for single or multiple Collectors.

## 🐧 Linux Collector (native / systemd) — ⚠️ retired

The native Linux build is **being retired** and its download is no longer updated. Don't start here, and if
you already run it, please migrate — a Collector installed this way cannot reach the current version.

👉 **[Migration notice & old instructions](https://github.com/Timpi-official/Nodes/blob/main/Collector/scripts/CollectorLinux.md)**

---

## 🪟 Windows Collector (Windows 10/11) v2

👉 **[Collector Windows Guide & Installer](https://github.com/Timpi-official/Nodes/blob/main/Collector/scripts/CollectorWindows.md)**  
Includes a clean .exe installer for a native Windows setup with full system integration.

---


## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 🤝 Contributing

Have a fix or idea for improvement? Pull requests are welcome!  
For larger changes, please [open an issue](https://discord.com/channels/946982023245992006/1179427377844068493) to discuss it with us first.







