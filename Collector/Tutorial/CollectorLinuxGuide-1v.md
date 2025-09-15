
# 📦 Timpi Collector Installation Guide – v0.10.0-A

**Supports:** `Ubuntu 22.04.4 LTS or later`
**Latest version:** [`TimpiCollectorLinuxLatest-0.10.0-A.rar`](https://timpi.io/applications/linux/TimpiCollectorLinuxLatest-0.10.0-A.rar)
**Install method:** Automated script or manual
**Dashboard:** [http://localhost:5015/collector](http://localhost:5015/collector)

---

## ⚠️ Important Notice – Resource Usage in v0.10.0-A

Timpi Collector v0.10.0-A brings performance and stability improvements.
However, setting too many **workers** or **threads** can:

* Overload your **CPU**
* Max out your **RAM**
* Use all your **bandwidth**, affecting Guardian, Synaptron, and other services

🛡️ That’s why this installer adds:

* Auto-detected **RAM limits**
* **Swap support** if RAM runs out
* Self-healing systemd service files

> 💡 Start small → Recommended: **1 Worker / 5 Threads**

---

## 🚀 Quick Auto-Installation (Recommended)

```bash
sudo apt-get install -y dos2unix curl && \
sudo curl -o Automated_collector_script.sh https://raw.githubusercontent.com/johnolofs/timpi/main/Collector/Script/Automated_collector_script.sh && \
sudo dos2unix Automated_collector_script.sh && \
bash Automated_collector_script.sh
```

---

## 🧼 Reset Collector Config (Optional)

```bash
sudo systemctl stop collector
sudo rm -f /opt/timpi/timpi.config
sudo systemctl start collector
```

---

## 🧠 Resource Control – MemoryMax / MemorySwapMax

The installer will ask you how much RAM the Collector can use.

* `MemoryMax` → RAM usage limit (default: 2G)
* `MemorySwapMax` → RAM + 1G (default: 3G)

### ✅ Example

```ini
MemoryMax=2G
MemorySwapMax=3G
```

---

## 🛠️ Manual Installation (Advanced)

### Step 1: Remove Previous Collector

```bash
sudo systemctl stop collector collector_ui || true
sudo systemctl disable collector collector_ui || true
sudo rm -rf /opt/timpi
```

### Step 2: Update System

```bash
sudo apt update && sudo apt -y upgrade
```

### Step 3: Create Installation Folder

```bash
sudo mkdir -p /opt/timpi
```

### Step 4: Install Unrar

```bash
sudo apt install -y unrar
```

### Step 5: Download Collector

```bash
sudo wget https://timpi.io/applications/linux/TimpiCollectorLinuxLatest-0.10.0-A.rar -O /opt/timpi/TimpiCollectorLinuxLatest.rar
```

### Step 6: Extract Files

```bash
cd /opt/timpi
sudo unrar x -y /opt/timpi/TimpiCollectorLinuxLatest.rar
```

### Step 7: Move Files (if needed)

```bash
if [ -d "/opt/timpi/TimpiCollectorLinuxLatest" ]; then
  sudo mv /opt/timpi/TimpiCollectorLinuxLatest/* /opt/timpi
  sudo rm -rf /opt/timpi/TimpiCollectorLinuxLatest
fi
```

### Step 8: Set Permissions

```bash
sudo chmod 755 /opt/timpi/TimpiCollector
sudo chmod 755 /opt/timpi/TimpiUI
```

### Step 9: Create systemd Services

#### Collector service

```bash
sudo nano /etc/systemd/system/collector.service
```

Paste:

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

#### UI service

```bash
sudo nano /etc/systemd/system/collector_ui.service
```

Paste:

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

### Step 10: Clean Up

```bash
sudo rm -f /opt/timpi/TimpiCollectorLinuxLatest.rar
```

### Step 11: Enable & Start Services

```bash
sudo systemctl daemon-reload
sudo systemctl enable collector collector_ui
sudo systemctl start collector collector_ui
```

---

## 🔍 Useful Commands

```bash
# Status
sudo systemctl status collector
sudo systemctl status collector_ui

# Restart
sudo systemctl restart collector
sudo systemctl restart collector_ui

# Logs (live)
sudo journalctl -fu collector -o cat
```

---

## ❌ Full Uninstall

```bash
sudo systemctl stop collector collector_ui
sudo systemctl disable collector collector_ui
sudo rm -rf /opt/timpi
sudo rm /etc/systemd/system/collector.service
sudo rm /etc/systemd/system/collector_ui.service
sudo systemctl daemon-reload
```

---

