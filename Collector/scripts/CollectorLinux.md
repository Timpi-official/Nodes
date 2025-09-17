*Only Support for Ubuntu +22.04.4 LTS*

---
# 📑 Table of Contents

* [Minimum System Requirements](#-minimum-system-requirements)
* [Quick Installation Command](#quick-installation-command-for-the-latest-collector)
* [Remove timpi.config](#if-you-need-to-remove-timpiconfig-file-for-some-reason)
* [Updating to a New Version](#-updating-to-a-new-version)
* [Reset Config](#-reset-config)
* [Uninstall Collector](#-uninstall-collector)
* [Linux Collector Manual Guide](#linux-collector-manual-guide)

---
## ⚠️ Important Notice – Resource Usage in Timpi Collector v0.10.0-A

**Timpi Collector v0.10.0-A** introduces important changes to how **worker and thread settings** affect your system. They now have a **direct impact on CPU, RAM, and bandwidth usage**.

> ⚠️ If you set worker/thread values too high, **your Collector can consume 100% of your internet bandwidth** — potentially choking your entire connection and affecting other nodes or services (e.g., Guardian, Validator, Synaptron).

To help keep systems stable, the installer now includes **resource limits** such as memory usage caps. This gives the Collector more container-like behavior and protects your system from overload — especially useful on shared or home setups.

**Be cautious** and adjust settings slowly starting with **1 Worker & 5 Threads** using the dashboard at:

```
http://localhost:5015/collector
```

---

# ✅ Minimum System Requirements
*	OS: Ubuntu 22.04.4 LTS (64-bit) or newer
*	CPU: 2 cores
*	RAM: 2 GB
*	Storage: 1 GB free (for app files + logs; Collector does not store large datasets)
*	Internet: Stable & unlimited

---

## Setup the Timpi Collector on your Linux system with this one-command installation. This install version of the Collector and then automatically upgrade it, overwriting any previous files.

### quick installation command for the latest collector
```shell
sudo apt-get install -y dos2unix curl && sudo curl -o Automated_collector_script.sh https://raw.githubusercontent.com/Timpi-official/Nodes/main/Collector/Automated_collector_script.sh && sudo dos2unix Automated_collector_script.sh && bash Automated_collector_script.sh
```
### Note: the quick command is only tested on native Linux installtion Ubuntu (Not Proxmox). if not working jump down to [Linux Collector Manual Guide](#linux-collector-manual-guide).
---
### If you need to remove timpi.config file for some reason
```shell
sudo systemctl stop collector; sudo rm -f /opt/timpi/timpi.config; sudo systemctl start collector
```
---
**Here's what happens:**

1. **Prepares your system**: Installs `dos2unix` and essential tools to ensure smooth script execution.
2. **Downloads and runs the setup script**: Retrieves the latest installer and executes it to install and configure the Timpi Collector.
3. **Performs a safe upgrade**: Stops any running collector, removes old files (if confirmed), and installs version **0.10.0-A** with correct permissions.
4. **Applies memory limits**: Prompts you to set RAM usage, helping prevent overloads and improve stability — especially if you're running other Timpi services.
5. **Registers and starts system services**: Automatically creates systemd services for the Collector and UI, enables them to start on boot, and launches both immediately.


**After installation:**
- Open your browser and visit http://localhost:5015/collector to access the Timpi Collector interface.

**Collector Commands:**
- **View live status**: `sudo journalctl -fu collector -o cat`
- **Start the collector**: `sudo systemctl start collector`
- **Stop the collector**: `sudo systemctl stop collector`
- **Restart the collector**: `sudo systemctl restart collector`
- **Restart the UI**: `sudo systemctl restart collector_ui`

- Check the status of the collector and UI using `sudo systemctl status collector` and `sudo systemctl status collector_ui`.

Just copy, paste, and press Enter

---

# 🔁 Updating to a New Version

When a new Collector release comes out:

### 1.	Run the same [Quick Installation Command](#quick-installation-command-for-the-latest-collector) command again (above).
 
 ### 2.	The script will:
•   Stop the running Collector

•	Remove old files

•	Install the new version

•	Apply memory limits

•	Restart the services

### 👉 You do not need to manually uninstall before upgrading.

⸻

# 🧹 Reset Config

### If you need to reset your wallet key:

```shell
sudo systemctl stop collector
sudo rm -f /opt/timpi/timpi.config
sudo systemctl start collector
```

⸻

# ❌ Uninstall Collector

### To completely remove the Collector:

```shell
sudo systemctl stop collector collector_ui || true
sudo systemctl disable collector collector_ui || true
sudo rm -rf /opt/timpi
sudo rm -f /etc/systemd/system/collector.service /etc/systemd/system/collector_ui.service
sudo systemctl daemon-reload
echo "Collector has been removed successfully."
```

⸻


**Here´s a Quick Removal command Of The Collector:**
```shell
sudo systemctl stop collector collector_ui || true; sudo systemctl disable collector collector_ui || true; sudo rm -rf /opt/timpi; sudo apt-get purge -y dos2unix; sudo apt-get autoremove -y; echo "Collector and dos2unix have been removed successfully."
```

---
# Linux Collector Manual Guide
### **Quick Guide Ubuntu 22.04: Installing/Uninstalling Timpi Collector**

### **Step 1: Remove Old Version**
```shell
echo "Stopping old collector services (if running)..."
sudo systemctl stop collector && echo "Stopped collector" || echo "Collector was not running"
sudo systemctl stop collector_ui && echo "Stopped collector_ui" || echo "Collector UI was not running"

echo "Removing old installation (if exists)..."
sudo rm -rf /opt/timpi && echo "Old /opt/timpi removed" || echo "No existing /opt/timpi folder found"
```

### **Step 2: Update System**
```shell
sudo apt update && sudo apt -y upgrade
```

### **Step 3: Create Installation Folder**
```shell
sudo mkdir -p /opt/timpi
```

### **Step 4: Install Unrar**
```shell
sudo apt install -y unrar
```

### **Step 5: Download Collector**
```shell
sudo wget https://timpi.io/applications/linux/TimpiCollectorLinuxLatest.rar -O /opt/timpi/TimpiCollectorLinuxLatest.rar
```

### **Step 6: Extract Files**
```shell
cd /opt/timpi
sudo unrar x -y /opt/timpi/TimpiCollectorLinuxLatest.rar
```

### **Step 7: Move Files (if needed)**
```shell
if [ -d "/opt/timpi/TimpiCollectorLinuxLatest" ]; then
    sudo mv /opt/timpi/TimpiCollectorLinuxLatest/* /opt/timpi
    sudo rm -rf /opt/timpi/TimpiCollectorLinuxLatest
fi
```

### **Step 8: Set Permissions**
```shell
sudo chmod 755 /opt/timpi/TimpiCollector
sudo chmod 755 /opt/timpi/TimpiUI
```

---

## **🧠 Resource Control – Optional but Recommended**

Before we create the Collector service, it's a good idea to **limit how much memory the service can use**, just like you would inside a Docker container. This helps avoid crashes or slowdowns if your system is low on resources.

We’ll do this using:

* `MemoryMax` – limits how much **RAM** the service can use
* `MemorySwapMax` – allows the service to use **swap memory** if it runs out of RAM

> 💡 **Recommended Settings:**
>
> * Your system should have **at least 2GB RAM**
> * Set `MemoryMax` to about **50–70%** of your total RAM
> * `MemorySwapMax` should be **equal or higher than** `MemoryMax`
>
> ✅ Example for 4GB RAM:
>
> ```
> MemoryMax=2G
> MemorySwapMax=3G
> ```

---

### **Step 9: Create Collector Service**

```shell
sudo nano /etc/systemd/system/collector.service
```

Paste this:

```ini
[Unit]
Description=Timpi Collector Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/timpi
ExecStart=/opt/timpi/TimpiCollector
Restart=always

[Install]
WantedBy=multi-user.target
```

---

### **Step 10: Create UI Service**

```shell
sudo nano /etc/systemd/system/collector_ui.service
```

Paste this:

```ini
[Unit]
Description=Timpi Collector UI Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/timpi
ExecStart=/opt/timpi/TimpiUI
Restart=always

[Install]
WantedBy=multi-user.target
```

---

### **Step 11: Cleanup**

```shell
sudo rm -rf /opt/timpi/TimpiCollectorLinuxLatest.rar
```

---

### **Step 12: Reload & Enable Services**

```shell
sudo systemctl daemon-reload
sudo systemctl enable collector
sudo systemctl enable collector_ui
```

---

### **Step 13: Start Services**

```shell
sudo systemctl start collector
sudo systemctl start collector_ui
```

---

### **Step 14: Check Status**

```shell
sudo systemctl status collector
sudo systemctl status collector_ui
```

---

### **Step 15: Access UI**

Open your browser:

```
http://localhost:5015/collector
```

---

### **Troubleshoot**

```shell
sudo rm /opt/timpi/timpi.config
sudo systemctl restart collector
sudo systemctl restart collector_ui
```

---

### **Uninstall**

```shell
sudo systemctl stop collector
sudo systemctl stop collector_ui
sudo systemctl disable collector
sudo systemctl disable collector_ui
sudo rm -rf /opt/timpi
sudo rm /etc/systemd/system/collector.service
sudo rm /etc/systemd/system/collector_ui.service
sudo systemctl daemon-reload
```

---

# Source
https://timpi.io/applications/linux/TimpiCollectorLinuxLatest.rar
