# 🔄 **Timpi Collector v2 — Docker Installation Guide**

*(Auto-Updating Edition — 6-Hour Cycle)*

Timpi Collectors are decentralized “workers” that crawl and index websites for the **Timpi Search Engine** — privately, securely, and without ads or tracking.

This Docker edition runs completely in the background. It does **not** update itself — add **Watchtower** ([§8](#autoupdate)) and every Timpi node on the machine stays current automatically.
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
9. [Verify Auto-Updates and Check Your Version](#verifyupdate)
10. [Update Right Now (Optional)](#forceupdate)
11. [⚙️ Advanced Options](#advanced)
12. [🧩 Running Multiple Collectors (for multiple NFTs / GUIDs)](#multi)
13. [Monitoring and Health Check](#monitoring)
14. [📊 Statistics, Workers and Threads](#cli)
15. [Troubleshooting](#troubleshooting)
16. [Command Reference](#commands)

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
* 🔄 Updates are handled by **Watchtower** ([§8](#autoupdate)), not by the Collector itself

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
| 🔄 Auto-Updating     | Via **Watchtower** ([§8](#autoupdate)) — the Collector does not self-update |
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

Before starting, we **remove any old container AND the old cached image**, so Docker **must** pull the newest version:

## 1) Remove old container (if it exists)
```bash
sudo docker rm -f timpi-collector 2>/dev/null || true
```
## 2) Remove old cached image (forces Docker to download the new one)
```bash
sudo docker rmi -f timpiltd/timpi-collector:latest 2>/dev/null || true
```
## 3) Pull the newest Timpi Collector image
```bash
sudo docker pull timpiltd/timpi-collector:latest
```
## 4) Start the Collector with your GUID
```bash
sudo docker run -d --name timpi-collector \
  --restart unless-stopped \
  -e GUID=YOUR-GUID-HERE \
  timpiltd/timpi-collector:latest
```

---

<a name="verify"></a>

## 7️⃣ Verify It’s Running

```bash
sudo docker ps --filter name=timpi-collector
```

Expected — the container is up:

```
CONTAINER ID   IMAGE                             STATUS        NAMES
3348866e699d   timpiltd/timpi-collector:latest   Up 2 hours    timpi-collector
```

> ℹ️ `Up` is all you get — the image has no healthcheck, so it never reports `(healthy)`. And `Up` only means
> the container is running: see [§13](#monitoring) to confirm it is actually **crawling**.

# 🐳 **2. Docker: Change Collector Log Level**

### ➡️ **Set log level to ERROR**

```bash
sudo docker exec timpi-collector sh -c 'sed -i "s/\"LogLevel\":\"[A-Za-z]*\"/\"LogLevel\":\"Error\"/" /opt/timpi/CollectorSettings.json'
sudo docker restart timpi-collector
```

### ➡️ **Set log level to VERBOSE**

```bash
sudo docker exec timpi-collector sh -c 'sed -i "s/\"LogLevel\":\"[A-Za-z]*\"/\"LogLevel\":\"Verbose\"/" /opt/timpi/CollectorSettings.json'
sudo docker restart timpi-collector
```

View logs:

```bash
sudo docker logs --tail 50 -f timpi-collector

```

You should see it start and reach a coordinator:

```
Starting TimpiCollector with GUID xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
[INF] Currently on version 2.0.0
[WRN] Collector was started
[INF] The response was successful: Collector found on http://tapcore1.timpi.network:4014/
```

Then, once it has work, a metrics line per domain:

```
[WRN] [metrics] example.com finished ok=10 soft=0 hard=0 skipped=0 ... fail%=0.0
```

`ok=` is pages fetched — that's the number that matters.

---

<a name="autoupdate"></a>

## 8️⃣ How Auto-Updating Works

The Collector does **not** update itself. The old in-container auto-updater has been removed, so a Collector
started with the command in §6 keeps running the image it was pulled with — forever — until you update it.

To get automatic updates, run **one Watchtower container**. It watches Docker Hub and replaces your
Collector whenever a new version ships (your GUID and data are kept). One Watchtower covers **every** Timpi
node on the machine. Paste it exactly as-is — there is nothing to edit:

```bash
sudo docker rm -f watchtower 2>/dev/null

sudo docker run -d \
  --name watchtower \
  --restart unless-stopped \
  -e DOCKER_API_VERSION=1.44 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower --interval 3600 --cleanup \
  geocore geocore2 geocore3 geocore4 \
  guardian1 guardian2 guardian3 guardian4 \
  timpi-collector timpi-collector-1 timpi-collector-2 timpi-collector-3 \
  timpi-collector-4 timpi-collector-5 timpi-collector-test
```

* It covers every Collector (§12), plus any GeoCore or Guardian on the same machine. Names you don't run are
  simply ignored, so the list is safe to paste as-is. Only add a name if `sudo docker ps` shows one that
  isn't listed.
* The **first line** removes any Watchtower you already have — Docker won't start a second container called
  `watchtower`, and an older one likely watches only a single node.
* `-e DOCKER_API_VERSION=1.44` is **required** — without it Watchtower crash-loops on modern Docker.
* ✅ Your GUID and crawl data survive updates. ✅ Nothing to clean up — Watchtower removes the old image.

---

<a name="verifyupdate"></a>

## 9️⃣ Verify Auto-Updates and Check Your Version

**Is Watchtower covering this Collector?**

```bash
sudo docker logs watchtower --tail 20
```

```text
Only checking containers which name matches "geocore" or "timpi-collector" or ...
Scheduling first run: 2026-07-16 23:06:45 +0000 UTC
```

* The **first** line must include your Collector's name.
* The **second** shows the first check is an hour away — the log stays quiet until then. That's normal,
  **not** a failure.

**What version am I on?**

```bash
sudo docker logs timpi-collector --tail 50 | grep -i "currently on version"
```

```text
[INF] Currently on version 2.0.0
```

**Persistent log file** (inside the container):

```bash
sudo docker exec timpi-collector sh -c 'ls /opt/timpi/TimpiCollectorLogs*.log'
sudo docker exec timpi-collector sh -c 'tail -20 /opt/timpi/TimpiCollectorLogs*.log'
```

---

<a name="forceupdate"></a>

## 🔁 🔟 Update Right Now (Optional)

Don't want to wait up to an hour for Watchtower's next check? Run the same list once. It updates immediately
and its last line reports what it covered — `Scanned` should equal the number of Timpi nodes you run:

```bash
sudo docker run --rm \
  -e DOCKER_API_VERSION=1.44 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower --run-once --cleanup \
  geocore geocore2 geocore3 geocore4 \
  guardian1 guardian2 guardian3 guardian4 \
  timpi-collector timpi-collector-1 timpi-collector-2 timpi-collector-3 \
  timpi-collector-4 timpi-collector-5 timpi-collector-test
```

```text
Session done   Failed=0 Scanned=1 Updated=1
```

This works whether or not you run Watchtower in the background.

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

**1. Is it running?**

```bash
sudo docker ps --filter name=timpi-collector
```

**2. What version?**

```bash
sudo docker logs timpi-collector --tail 50 | grep -i "currently on version"
```
```
[INF] Currently on version 2.0.0
```

**3. Is it actually crawling?** — the one that matters. Counts the domains finished in the last hour:

```bash
sudo docker logs timpi-collector --since 1h | grep -c "finished ok"
```

Any number above 0 means it's working. `0` on a Collector that has been up for a while is worth
investigating (see [§15](#troubleshooting)) — a Collector can be "running" and still crawl nothing.

---

<a name="cli"></a>

## 📊 14️⃣ Statistics, Workers and Threads

The Collector has a small set of commands you can run **against a container that is already running** —
they read and write the same two files the Collector itself uses, so nothing needs restarting.

> ℹ️ Requires the image published **2026-08-06 or later**. Check with
> `sudo docker exec -w /opt/timpi timpi-collector ./TimpiCollector help` — if you get the help text,
> you have it.

### ➡️ See how much your node has crawled

```bash
sudo docker exec -w /opt/timpi timpi-collector ./TimpiCollector stats
```

```
Timpi Collector — statistics
  Pages crawled : 279,601
  Lifetime total: 279,601
  Last updated  : 2026-08-06 08:15:22  (12 s ago)
```

**Pages crawled** is the visible counter, **Lifetime total** is everything the node has ever done.
To start the visible counter over without losing the lifetime total:

```bash
sudo docker exec -w /opt/timpi timpi-collector ./TimpiCollector stats reset
```

### ➡️ Set your own worker and thread limits

By default the coordinator decides how many workers your node runs. If you want your machine to stay
below a certain load — for example on a small VPS or a machine you also use for something else — set
your own ceiling:

```bash
# show current limits
sudo docker exec -w /opt/timpi timpi-collector ./TimpiCollector limits

# set a ceiling: max 20 workers, max 4 threads per worker
sudo docker exec -w /opt/timpi timpi-collector ./TimpiCollector limits 20 4

# back to automatic (coordinator decides)
sudo docker exec -w /opt/timpi timpi-collector ./TimpiCollector limits 0 0
```

* **Workers** = how many domains the node crawls at the same time. **Threads** = how many pages it
  fetches at the same time within one domain.
* `0` means **auto** — no limit of your own, the coordinator decides.
* Hard caps are **75 workers** and **10 threads**; higher values are reduced to those.
* A running Collector picks up a change **within about 2 minutes** — no restart needed. You will see
  it in the log:

  ```
  [WRN] Worker limit: clamping workers 69 -> 20 (operator limit)
  ```

* Setting a limit does **not** increase your rewards or reduce them — Timpi's reward is based on
  uptime, not on how much you crawl. Size it to your hardware.

> ⚠️ **These settings reset when the image updates.** Limits and the statistics counter live inside
> the container, so when Watchtower installs a new version the container is recreated and both go back
> to their defaults (limits = auto, counter = 0). This is expected. If you rely on a specific limit,
> set it again after an update.

---

<a name="troubleshooting"></a>

## 🧰 15️⃣ Troubleshooting

| Issue                       | Cause                                         | Fix                                                |
| :-------------------------- | :-------------------------------------------- | :------------------------------------------------- |
| `Text file busy`            | Collector still running during update         | Fixed automatically (v2 stops all processes first) |
| Container stops immediately | Missing GUID                                  | Add `-e GUID=YOUR-GUID`                            |
| Collector offline           | Dashboard delay                               | Check `docker logs`                                |
| No updates yet              | No new release                                | Normal                                             |
| Force manual update         | See [Force an Immediate Update](#forceupdate) |                                                    |

---

<a name="commands"></a>

## 🧾 16️⃣ Command Reference

| Command                                       | Purpose               |
| :-------------------------------------------- | :-------------------- |
| `docker logs -f timpi-collector`              | View live logs        |
| `docker exec -it timpi-collector bash`        | Enter container       |
| `docker restart timpi-collector`              | Restart collector     |
| `docker rm -f timpi-collector`                | Remove container      |
| `docker pull timpiltd/timpi-collector:latest` | Update image manually |
| `docker stats timpi-collector`                | Live CPU/RAM usage    |
| `docker inspect timpi-collector`              | Inspect details       |
| `docker exec -w /opt/timpi timpi-collector ./TimpiCollector stats` | Pages crawled ([§14](#cli)) |
| `docker exec -w /opt/timpi timpi-collector ./TimpiCollector limits` | Show worker/thread limits |
| `docker exec -w /opt/timpi timpi-collector ./TimpiCollector limits 20 4` | Set limits (0 = auto) |

---

## ✅ Done!

Your **Timpi Collector v2 (Docker Edition)** now runs:

* 📡 Always active with `--restart unless-stopped`
* 🔄 Self-updating every 6 hours
* 🧾 Logging update history to `/opt/timpi/TimpiCollectorLogsxxxx-xx-xx.log`
* 🧠 Managed via [Timpi Dashboard](https://timpi.com/node/v2/management)
* 🧩 Scalable for multiple NFTs — run one container per GUID

---

