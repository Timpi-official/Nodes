# ⚠️ Retired — the Linux (systemd) Collector has been replaced by Docker

**Do not use this installation method for a new Collector.** The native Linux build is being retired and
its download is no longer updated — the package on `timpi.io` has not changed since **13 November 2025**, so
a Collector installed this way cannot reach the current version.

## 👉 Use the Docker Collector instead

**[Linux Docker Collector Guide](https://github.com/Timpi-official/Nodes/blob/main/Collector/guides/LinuxDocker.md)**

It runs on the same Ubuntu machine, keeps your GUID, and — with **Watchtower** (§8 of that guide) — stays on
the latest version automatically. That is the only Collector path that receives updates.

## Already running the Linux (systemd) Collector?

**Please migrate.** Your node still crawls, but it is stuck on the November 2025 build and will not receive
new versions, including anything required for reward eligibility.

Migrating is short — your **GUID stays the same**:

```bash
# 1) Note your GUID first — it's in the old service file (you'll paste it into the Docker guide)
grep -oE '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}' \
  /etc/systemd/system/collector.service

# 2) Stop and disable the old services (names as created by the guide below)
sudo systemctl disable --now collector-updater.timer 2>/dev/null || true
sudo systemctl disable --now collector-updater.service 2>/dev/null || true
sudo systemctl disable --now collector.service 2>/dev/null || true
sudo systemctl daemon-reload
```

or

```bash
sudo systemctl stop collector.service
sudo systemctl disable collector.service

sudo systemctl stop collector-updater.timer
sudo systemctl disable collector-updater.timer

sudo systemctl stop collector-updater.service
sudo systemctl disable collector-updater.service

sudo rm -f /etc/systemd/system/collector.service
sudo rm -f /etc/systemd/system/collector-updater.service
sudo rm -f /etc/systemd/system/collector-updater.timer

sudo systemctl daemon-reload
sudo systemctl reset-failed
```

> If step 1 prints nothing, your unit may be named differently — find it with
> `systemctl list-units --all | grep -i collector`, then read the GUID from
> `systemctl cat <unit> | grep ExecStart`.

Then follow the **[Docker guide](https://github.com/Timpi-official/Nodes/blob/main/Collector/guides/LinuxDocker.md)**
from §5 (Install Docker) onward, using that same GUID. The old files under `/opt/timpi` can be deleted once
the Docker Collector is running and crawling.

> 💡 Running Windows? A new Windows Collector is on the way — keep an eye on the announcements channel.

---

<details>
<summary>Old instructions (kept for reference only — no longer maintained)</summary>

# 🔄 **Timpi Collector v2 — Linux Installation Guide**

*(Auto-Updating Systemd Edition — 6 Hour Cycle)*

Timpi Collectors are decentralized “workers” that crawl and index websites for the **Timpi Search Engine** — privately, securely, and without ads or tracking.
This guide installs and configures both:

* 🧠 **TimpiCollector** – main worker
* 🔄 **CollectorAutoUpdater** – auto-updates the worker

Everything runs automatically in the background via **systemd services + timer**, including across reboots.

---

<img width="1024" height="576" alt="Timpi Collector" src="https://github.com/user-attachments/assets/8dcd810f-fa30-4912-ac11-c63417ec15bc" />

---

## 📑 **Table of Contents**

1. [Get Your GUID & Manage Workers](#guid)
2. [About Collector v2](#about)
3. [System Requirements](#requirements)
4. [Step 1 — Remove Old Versions](#step1)
5. [Step 2 — Prepare a Clean Directory](#step2)
6. [Step 3 — Download & Extract Collector v2](#step3)
7. [Step 4 — Set Permissions](#step4)
8. [Step 5 — Create the Collector Service](#step5)
9. [Step 6 — Add the Auto-Updater Service](#step6)
10. [Step 7 — Create and Enable the 6-Hour Timer](#step7)
11. [Step 8 — Verify Everything Works](#verify)
12. [How the Auto-Updater Works](#autoupdater)
13. [Manual Update / Emergency Hotfix](#manual-update)
14. [File Summary](#files)
15. [Troubleshooting](#troubleshooting)


---

> ⚠️ **Support Policy**
>
> Timpi officially supports installations on **Windows 10/11**, **native Linux (Ubuntu)**, and **Docker running on native Linux**.  
>  
> Other environments — including **Proxmox**, **LXC containers**, **nested virtualization**, or **emulated systems** — are considered **unsupported**.  
>  
> You are free to experiment with these setups, but please note that **technical support and helpdesk tickets are only available for supported platforms**.  
> For the best performance and reliability, always use a fully supported operating system.

---


<a name="guid"></a>

## 1️⃣ Get Your GUID & Manage Workers

👉 Visit **[https://timpi.com/node/v2/management](https://timpi.com/node/v2/management)**

Here you can:

* Register and copy your **Collector GUID**
* Adjust **Workers** and **Threads**
* See if your Collector is **online**

💡 Recommended start: **1 Worker & 5 Threads** for stable performance.

---

<a name="about"></a>

## 2️⃣ About Collector v2

Collector v2 for Linux is **headless**, **auto-updating**, and fully **dashboard-managed**.

✅ Highlights:

* 🚫 No UI or tray icon
* 🔄 Automatic updates via `CollectorAutoUpdater` + systemd timer
* ⚙️ Managed from the Timpi Dashboard
* 🧠 Built for stable 24/7 operation

---

<a name="requirements"></a>

## 3️⃣ System Requirements

| Resource | Minimum                          |
| :------- | :------------------------------- |
| OS       | Ubuntu 22.04 LTS (64-bit)        |
| CPU      | 2 cores                          |
| RAM      | 2 GB                             |
| Storage  | 1 GB free (SSD recommended)      |
| Network  | Stable connection (no data caps) |

---

<a name="step1"></a>

## 4️⃣ Step 1 — Remove Old Versions

```bash
sudo systemctl stop collector 2>/dev/null || true
sudo systemctl stop collector_ui 2>/dev/null || true
sudo systemctl stop collector-updater.timer 2>/dev/null || true
sudo systemctl stop collector-updater 2>/dev/null || true
sudo rm -f /etc/systemd/system/collector*.service /etc/systemd/system/collector*.timer
sudo systemctl daemon-reload
```

---

<a name="step2"></a>

## 5️⃣ Step 2 — Prepare a Clean Directory

```bash
sudo rm -rf /opt/timpi
sudo mkdir -p /opt/timpi
sudo chown "$USER:$USER" /opt/timpi
cd /opt/timpi
```

---

<a name="step3"></a>

## 6️⃣ Step 3 — Download & Extract Collector v2

```bash
wget https://timpi.io/applications/linux/TimpiCollectorLinuxLatest-v2.rar -O TimpiCollectorLinuxLatest-v2.rar
sudo apt install -y unrar
unrar x TimpiCollectorLinuxLatest-v2.rar
rm -rf TimpiCollectorLinuxLatest TimpiCollectorLinuxLatest-v2.rar
```

Expected contents:

```text
/opt/timpi/
├── TimpiCollector
├── CollectorAutoUpdater
├── CollectorSettings.json
└── public_suffix_list.dat
```

---

<a name="step4"></a>

## 7️⃣ Step 4 — Set Permissions

```bash
sudo chmod +x /opt/timpi/TimpiCollector
sudo chmod +x /opt/timpi/CollectorAutoUpdater
```

---

<a name="step5"></a>

## 8️⃣ Step 5 — Create the Collector Service

```bash
sudo nano /etc/systemd/system/collector.service
```

![Important](https://img.shields.io/badge/IMPORTANT-Replace%20YOUR--GUID--HERE-red?style=for-the-badge)

> ⚠️ **Replace** <span style="color:red; font-weight:bold">YOUR-GUID-HERE</span> **with your actual GUID from your Timpi dashboard https://timpi.com/node/v2/management before running the command below.**


```ini
[Unit]
Description=Timpi Collector v2 (Headless)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/timpi
ExecStart=/opt/timpi/TimpiCollector YOUR-GUID-HERE
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Save → `Ctrl + O`, `Enter`, `Ctrl + X`.

---

<a name="step6"></a>

## 9️⃣ Step 6 — Add the Auto-Updater Service

```bash
sudo nano /etc/systemd/system/collector-updater.service
```

Paste:

```ini
[Unit]
Description=Timpi Collector Auto-Updater
After=network.target
Wants=collector.service

[Service]
Type=oneshot
User=root
WorkingDirectory=/opt/timpi
ExecStart=/bin/bash -c '\
  echo "[INFO] Stopping collector..."; \
  systemctl stop collector || true; \
  sleep 2; \
  echo "[INFO] Running CollectorAutoUpdater..."; \
  /opt/timpi/CollectorAutoUpdater; \
  echo "[INFO] Restarting collector..."; \
  systemctl start collector || true; \
  echo "[INFO] Update check done."'
```

---

<a name="step7"></a>

## 🔟 Step 7 — Create and Enable the 6-Hour Timer

```bash
sudo nano /etc/systemd/system/collector-updater.timer
```

Paste:

```ini
[Unit]
Description=Run Timpi Collector Auto-Updater every 6 hours (and after boot)

[Timer]
OnBootSec=2min
OnUnitActiveSec=6h
Persistent=true
Unit=collector-updater.service

[Install]
WantedBy=timers.target
```

Then enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable collector
sudo systemctl enable collector-updater.timer
sudo systemctl start collector
sudo systemctl start collector-updater.timer
```

---

<a name="verify"></a>

## 1️⃣1️⃣ Step 8 — Verify Everything Works

**Check status:**

```bash
sudo systemctl status collector
```

**Follow logs:**

```bash
sudo journalctl -u collector -f
```
```bash
sudo journalctl -u collector-updater -f
```

**Change Collector Log Level**

### ➡️ **Set log level to ERROR**

```bash
sudo sed -i 's/"LogLevel":"[A-Za-z]*"/"LogLevel":"Error"/' /opt/timpi/CollectorSettings.json
sudo systemctl restart collector
```

### ➡️ **Set log level to VERBOSE (Troubleshooting)**

```bash
sudo sed -i 's/"LogLevel":"[A-Za-z]*"/"LogLevel":"Verbose"/' /opt/timpi/CollectorSettings.json
sudo systemctl restart collector
```

**Timer schedule:**

```bash
systemctl list-timers | grep collector-updater
```

✅ `NEXT` and `LAST` should be roughly 6 hours apart.

---

<a name="autoupdater"></a>

## 1️⃣2️⃣ How the Auto-Updater Works

| Trigger       | Action                                            |
| :------------ | :------------------------------------------------ |
| System boot   | Wait 2 min → runs updater                         |
| Every 6 hours | Re-runs updater                                   |
| During update | Stops collector → downloads new binary → restarts |
| After update  | Collector runs latest version automatically       |

---

<a name="manual-update"></a>

## 1️⃣3️⃣ Manual Update / Emergency Hotfix

### 🟢 Force an update immediately

```bash
sudo systemctl start collector-updater.service
```

Monitor:

```bash
sudo journalctl -u collector-updater -f
```

---

### 🟡 Manual run (advanced)

```bash
sudo systemctl stop collector
cd /opt/timpi
sudo ./CollectorAutoUpdater
sudo systemctl start collector
```

---

### 🔵 Reset timer schedule

```bash
sudo systemctl restart collector-updater.timer
```

---

### 🧾 Check version & health

```bash
sudo systemctl status collector
sudo journalctl -u collector -n 20
```

Look for:

```text
[INF] Starting Timpi Collector (GUID=xxxx)
[INF] The response was successful: Collector found on ...
```

---

<a name="files"></a>

## 1️⃣4️⃣ File Summary

| Path                                            | Description               |
| :---------------------------------------------- | :------------------------ |
| `/opt/timpi/TimpiCollector`                     | Main collector binary     |
| `/opt/timpi/CollectorAutoUpdater`               | Auto-updater binary       |
| `/etc/systemd/system/collector.service`         | Collector systemd service |
| `/etc/systemd/system/collector-updater.service` | Updater service           |
| `/etc/systemd/system/collector-updater.timer`   | 6-hour timer              |

---

<a name="troubleshooting"></a>

## 1️⃣5️⃣ Troubleshooting

**Collector shows “deactivating (stop-sigterm)”**
→ Normal while updating.

**Timer missing `NEXT`** → Reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart collector-updater.timer
```

**Collector offline in dashboard** → Verify GUID and logs:

```bash
sudo journalctl -u collector -n 50
```

**Change log level**

```bash
sudo nano /opt/timpi/CollectorSettings.json
```

Edit `"LogLevel"` then:

```bash
sudo systemctl restart collector
```

---

## ✅ Done!

Your **Timpi Collector v2 (Linux)** is now:

* Always running via systemd
* Auto-updating every 6 hours
* Restarting after updates
* Managed through **[https://timpi.com/node/v2/management](https://timpi.com/node/v2/management)**

For urgent patches, simply run:

```bash
sudo systemctl start collector-updater.service
```


</details>
