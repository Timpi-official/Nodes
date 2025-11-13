# 🔄 **Timpi Collector v2 — Docker Installation Guide**

*(Auto-Updating Edition — 6-Hour Cycle)*

Timpi Collectors are decentralized “workers” that crawl and index websites for the **Timpi Search Engine** — privately, securely, and without ads or tracking.

This Docker edition runs completely in the background and **auto-updates itself** every 6 hours using the built-in `CollectorAutoUpdater`.
No scripts. No manual updates. Fully automated and verified by logs.

---

<img width="1024" height="576" alt="Timpi Collector" src="https://github.com/user-attachments/assets/8dcd810f-fa30-4912-ac11-c63417ec15bc" />

---

## 📑 **Table of Contents**

1. [Overview](#overview)
2. [Get Your GUID](#guid)
3. [About Collector v2 (Docker Edition)](#about)
4. [System Requirements](#requirements)
5. [Install Docker](#dockerinstall)
6. [Run the Collector Container](#run)
7. [Verify It’s Running](#verify)
8. [How Auto-Updating Works](#autoupdate)
9. [View Update History and Version Checks](#verifyupdate)
10. [Force an Immediate Update (Optional)](#forceupdate)
11. [⚙️ Advanced Options](#advanced)
12. [🧩 Running Multiple Collectors (for multiple NFTs / GUIDs)](#multi)
13. [Monitoring and Health Check](#monitoring)
14. [Troubleshooting](#troubleshooting)
15. [Command Reference](#commands)

---

<a name="overview"></a>

## 1️⃣ Overview

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


The **Timpi Collector v2 (Docker Edition)** contains:

* 🧠 `TimpiCollector` — main worker process
* 🔄 `CollectorAutoUpdater` — checks and installs updates automatically

Everything runs **inside** the container — no external scripts or manual work needed.

---

<a name="guid"></a>

## 2️⃣ Get Your GUID

Visit **[https://timpi.com/node/v2/management](https://timpi.com/node/v2/management)**

Here you can register and copy your **Collector GUID**, manage workers & threads, and verify that your node is online.
💡 Recommended start: 1 Worker & 5 Threads.

---

<a name="about"></a>

## 3️⃣ About Collector v2 (Docker Edition)

| Feature              | Description                                                                 |
| :------------------- | :------------------------------------------------------                     |
| 🧩 Headless          | Managed entirely from the Timpi Dashboard                                   |
| 🔄 Auto-Updating     | Internal loop runs `CollectorAutoUpdater` every 6 hours                     |
| ⚙️ Self-Healing      | Restarts automatically after updates                                        |
| 🧠 Dashboard Managed | All settings handled in the dashboard                                       |
| 🪶 Persistent Logs     | `/opt/timpi/TimpiCollectorLogsxxxx-xx-xx.log` keeps update history        |

---

<a name="requirements"></a>

## 4️⃣ System Requirements

| Resource | Minimum                    |
| :------- | :------------------------- |
| OS       | Ubuntu 22.04 LTS (64-bit)  |
| CPU      | 2 cores                    |
| RAM      | 2 GB                       |
| Storage  | 1 GB free (SSD preferred)  |
| Network  | Stable broadband (no caps) |

---

<a name="dockerinstall"></a>

## 5️⃣ Install Docker

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce
sudo systemctl enable --now docker
```

Check Docker:

```bash
sudo systemctl status docker
```

---

<a name="run"></a>

## 6️⃣ Run the Collector Container


---

![Important](https://img.shields.io/badge/IMPORTANT-Replace%20YOUR--GUID--HERE-red?style=for-the-badge)

> ⚠️ **Replace** <span style="color:red; font-weight:bold">YOUR-GUID-HERE</span> **with your actual GUID from your Timpi dashboard https://timpi.com/node/v2/management before running the command below.**

```bash
sudo docker rm -f timpi-collector 2>/dev/null || true

sudo docker run -d --name timpi-collector \
  --restart unless-stopped \
  -e GUID=YOUR-GUID-HERE \
  timpiltd/timpi-collector:latest
```

---

<a name="verify"></a>

## 7️⃣ Verify It’s Running

```bash
sudo docker ps
```

Expected:

```
timpi-collector   Up (healthy)
```

View logs:

```bash
sudo docker logs -f timpi-collector
```

You should see:

```
[INF] Starting Timpi Collector (GUID=xxxx)
[INF] The response was successful: Collector found on ...
[INF] Currently on version 1.0.1
```

---

<a name="autoupdate"></a>

## 8️⃣ How Auto-Updating Works

1. Waits 6 hours (default 21 600 s).
2. Stops all `TimpiCollector` processes.
3. Runs `CollectorAutoUpdater`.
4. Restarts collector with the same GUID.
5. Logs version and update status to both console and `TimpiCollectorLogsxxxx-xx-xx.log`.

✅ Container itself never stops.
✅ Only the collector process restarts.

---

<a name="verifyupdate"></a>

## 9️⃣ View Update History and Version Checks

Check if the auto-updater loop is active:

```bash
sudo docker logs timpi-collector | grep "Auto-Updater loop"
```

Example:

```
[INF] Auto-Updater loop started (interval: 21600s)...
```

Show recent update ticks and versions:

```bash
sudo docker logs timpi-collector | grep -E "Auto-Updater tick|Currently on version"
```

Example output:

```
[INF] Auto-Updater tick: stopping collector for update...
[INF] CollectorAutoUpdater completed successfully.
[INF] Verifying collector version...
[INF] Currently on version 1.0.1
```

View persistent history file:

```bash
sudo docker exec timpi-collector cat /opt/timpi/TimpiCollectorLogsxxxx-xx-xx.log
```

---

<a name="forceupdate"></a>

## 🔁 10️⃣ Force an Immediate Update (Optional)

```bash
sudo docker exec -it timpi-collector bash
./CollectorAutoUpdater
exit
sudo docker restart timpi-collector
```

---

<a name="advanced"></a>

## ⚙️ 11️⃣ Advanced Options

| Option                          | Description                | Example                  |
| :------------------------------ | :------------------------- | :----------------------- |
| `--cpus`                        | Limit CPU cores            | `--cpus="2"`             |
| `--memory`                      | Limit RAM                  | `--memory="2g"`          |
| `--memory-swap`                 | Add swap                   | `--memory-swap="4g"`     |
| `--net=host`                    | Use host network           | `--net=host`             |
| `--ulimit nofile=65536:65536`   | Raise file limit           | Recommended              |
| `-e TZ=`                        | Timezone                   | `-e TZ=Europe/Stockholm` |
| `-e UPDATE_INTERVAL_SECONDS=60` | Short interval for testing | Testing only             |

---

<a name="multi"></a>

## 🧩 12️⃣ Running Multiple Collectors (for multiple NFTs / GUIDs)

If you own **multiple Collector NFTs**, each with its **own GUID**,
you can run multiple containers on the same host — one per GUID.

### Example: Run 3 Collectors on One Machine

| Collector Name      | GUID Example |
| :------------------ | :----------- | 
| `timpi-collector-1` | `GUID1-xxxx` |
| `timpi-collector-2` | `GUID2-yyyy` |
| `timpi-collector-3` |`GUID3-zzzz` |

Commands:

```bash
sudo docker run -d --name timpi-collector-1 \
  --restart unless-stopped \
  -e GUID=GUID1-xxxx \
  timpiltd/timpi-collector:latest

sudo docker run -d --name timpi-collector-2 \
  --restart unless-stopped \
  -e GUID=GUID2-yyyy \
  timpiltd/timpi-collector:latest

sudo docker run -d --name timpi-collector-3 \
  --restart unless-stopped \
  -e GUID=GUID3-zzzz \
  timpiltd/timpi-collector:latest
```

Each container runs independently:

* Separate GUID
* Separate internal auto-updater
* Separate update log (`/opt/timpi/TimpiCollectorLogsxxxx-xx-xx.log`)
* Safe to run on same machine

💡 Tip: Give each collector a unique name (`timpi-collector-1`, `timpi-collector-2`, etc.)
and optionally map different external ports if you need to view network metrics.

---

<a name="monitoring"></a>

## 📊 13️⃣ Monitoring and Health Check

```bash
sudo docker ps
sudo docker logs timpi-collector | grep "Auto-Updater tick"
```

Expected:

```
[INF] Auto-Updater tick: stopping collector for update...
[INF] CollectorAutoUpdater completed successfully.
[INF] Currently on version 1.0.1
```

---

<a name="troubleshooting"></a>

## 🧰 14️⃣ Troubleshooting

| Issue                       | Cause                                         | Fix                                                |
| :-------------------------- | :-------------------------------------------- | :------------------------------------------------- |
| `Text file busy`            | Collector still running during update         | Fixed automatically (v2 stops all processes first) |
| Container stops immediately | Missing GUID                                  | Add `-e GUID=YOUR-GUID`                            |
| Collector offline           | Dashboard delay                               | Check `docker logs`                                |
| No updates yet              | No new release                                | Normal                                             |
| Force manual update         | See [Force an Immediate Update](#forceupdate) |                                                    |

---

<a name="commands"></a>

## 🧾 15️⃣ Command Reference

| Command                                       | Purpose               |
| :-------------------------------------------- | :-------------------- |
| `docker logs -f timpi-collector`              | View live logs        |
| `docker exec -it timpi-collector bash`        | Enter container       |
| `docker restart timpi-collector`              | Restart collector     |
| `docker rm -f timpi-collector`                | Remove container      |
| `docker pull timpiltd/timpi-collector:latest` | Update image manually |
| `docker stats timpi-collector`                | Live CPU/RAM usage    |
| `docker inspect timpi-collector`              | Inspect details       |

---

## ✅ Done!

Your **Timpi Collector v2 (Docker Edition)** now runs:

* 📡 Always active with `--restart unless-stopped`
* 🔄 Self-updating every 6 hours
* 🧾 Logging update history to `/opt/timpi/TimpiCollectorLogsxxxx-xx-xx.log`
* 🧠 Managed via [Timpi Dashboard](https://timpi.com/node/v2/management)
* 🧩 Scalable for multiple NFTs — run one container per GUID

---

