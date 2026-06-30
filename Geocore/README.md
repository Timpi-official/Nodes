# 🌐 Timpi GeoCore Node – Official Community Guide

Run a **GeoCore Node** to help power Timpi's decentralized, location-aware routing infrastructure.
Lightweight. Fast. Privacy-focused.

<img width="1509" height="850" src="https://github.com/user-attachments/assets/7b69280a-a77b-46d3-85d0-88b517c097bb" />

---

# 📘 Table of Contents

1. [What Is a GeoCore Node?](#s1-intro)
2. [System Requirements](#s2-requirements)
3. [Support Notice](#s3-support)
4. [Register Your GUID](#s4-guid)
5. [Install Docker](#s5-docker)
6. [Install GeoCore](#s6-install)
   * [6.1 Automatic Install (Recommended)](#s6-1-auto)
   * [6.2 Manual Install (Any Port)](#s6-2-manual)
   * [6.3 Open Your Port](#s6-3-port)
7. [Auto-Updates (How Your Node Stays Current)](#s7-autoupdate)
   * [7.1 Already have a node? Turn on auto-updates](#s7-1-existing)
   * [7.2 Verify auto-updates](#s7-2-verify)
8. [Manual Update (Fallback — only without auto-updates)](#s8-manual-update)
9. [Run Multiple GeoCores](#s9-multiple)
10. [Monitor Logs](#s10-logs)
11. [Expected Logs & Outputs](#s11-expected)
12. [Docker Parameter Reference](#s12-params)
13. [Troubleshooting (incl. Clean Slate / Reset)](#s13-troubleshooting)
14. [Upcoming Feature](#s14-upcoming)
15. [Community & Support](#s15-community)

---

<a id="s1-intro"></a>

# 1. What Is a GeoCore Node?

A **GeoCore Node** powers Timpi's decentralized network by:

* announcing your physical region (e.g., `Sweden/Stockholm`)
* connecting to the TAP (Timpi Access Point)
* routing search traffic to the nearest Guardians
* improving global decentralization and performance

GeoCore is lightweight, Docker-based, and ideal for 24/7 operation.

> 🆕 **New in this guide:** GeoCore now **updates itself automatically** (via Watchtower). Set it up once
> and you'll never chase manual updates again — see [§7](#s7-autoupdate).

---

<a id="s2-requirements"></a>

# 2. System Requirements

| Component | Recommended Minimum           |
| --------- | ----------------------------- |
| OS        | **Ubuntu 22.04 LTS (native)** |
| CPU       | 4 cores                       |
| RAM       | 8 GB                          |
| Storage   | 3 GB                          |
| Bandwidth | 50 Mbps                       |
| Uptime    | 95%+                          |
| Port      | **4013/TCP (default)**        |
| DNS       | **`100.42.180.29` + `100.42.180.99` required** (`1.1.1.1` optional fallback) |
| Docker    | Required                      |

---

<a id="s3-support"></a>

# 3. Support Notice

Timpi officially supports:

✔ Ubuntu 22.04 LTS  ✔ Native Docker  ✔ FluxOS Marketplace deployments

Not supported (community-only):

❌ Windows, WSL, macOS  ❌ Proxmox LXC  ❌ Other Linux distributions

---

<a id="s4-guid"></a>

# 4. Register Your GUID

You need a **GUID** (your node's identity) before installing. Get it here:

👉 <https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md>

Example of a generated GUID:

```text
2f7256b8-c275-429b-8088-01519cced582
```

---

<a id="s5-docker"></a>

# 5. Install Docker

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```

Add Docker's repo:

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list
```

Install:

```bash
sudo apt update
sudo apt install -y docker-ce
sudo systemctl status docker     # expect: active (running)
sudo usermod -aG docker $USER     # then log out and back in
```

> ⚠️ **Don't use Snap Docker** — it can't give containers the access GeoCore needs. If you installed Docker via
> Snap, remove it (`sudo snap remove docker`) and use the steps above.

---

<a id="s6-install"></a>

# 🔵 6. Install GeoCore

Two ways — pick one:

* **[6.1 Automatic](#s6-1-auto)** — one command, asks a few questions, also turns on **auto-updates**. *(Recommended.)*
* **[6.2 Manual](#s6-2-manual)** — full control over the `docker run` command and ports.

---

<a id="s6-1-auto"></a>

## 6.1 Automatic Install (Recommended)

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Timpi-official/Nodes/main/Geocore/GC-AutoInstall.sh)
```

The script asks for your **port**, **GUID**, **location**, and whether to **enable auto-updates** (recommended).
It then launches GeoCore and, if you said yes, sets up Watchtower so the node keeps itself up to date.

#### ✅ Example run

```text
🌐 Timpi GeoCore Setup Script

➡️ Enter the port for GeoCore (Default: 4013)
GeoCore Port: 4013

🆔 Enter your GUID (Found in your Timpi dashboard)
GUID: YOUR-ACTUAL-GUID-HERE

📍 Let's enter your location
🌍 Country: Sweden
🏙️ City: Stockholm
✅ Location set to: Sweden/Stockholm

🔄 Automatic updates keep your GeoCore on the latest version — no manual upgrades.
Enable automatic updates? [Y/n]: Y

🚀 Launching GeoCore container...
latest: Pulling from timpiltd/timpi-geocore
Status: Downloaded newer image for timpiltd/timpi-geocore:latest

✅ GeoCore is now running on port 4013
🧾 Container ID: 8088f4e69d56...

🔄 Enabling automatic updates (Watchtower)...
✅ Watchtower active — GeoCore (and any other labelled Timpi nodes on this machine) will auto-update on new releases.

────────────────────────────────────────────
📦 GeoCore setup complete (container: geocore, port 4013).
🔄 Auto-updates: ON. Watchtower checks Docker Hub about once an hour and updates
   this node automatically when Timpi releases a new version (your GUID, port and
   data are kept). Check it:  sudo docker logs watchtower
────────────────────────────────────────────
```

➡️ Next: **[6.3 Open Your Port](#s6-3-port)**, then check your logs in **[§10](#s10-logs)**.

---

<a id="s6-2-manual"></a>

## 6.2 Manual Install (Any Port)

GeoCore can use any free port (default `4013`). Example:

```bash
sudo docker run -d \
  --name geocore \
  --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=1.1.1.1 \
  -p 4013:4013 \
  -v /var/timpi:/var/timpi \
  -e COMPORT=4013 \
  -e GUID="your-guid-here" \
  -e LOCATION="Sweden/Stockholm" \
  timpiltd/timpi-geocore:latest
```

> 📡 **About `--dns`:** the two Timpi DNS servers (`100.42.180.29`, `100.42.180.99`) are **required** — they
> resolve TAP/Timpi services. `--dns=1.1.1.1` (Cloudflare) is an **optional** fallback for general lookups and may be left out.

➡️ After a manual install, turn on **[auto-updates (§7)](#s7-autoupdate)** so you never have to update by hand.

---

<a id="s6-3-port"></a>

## 6.3 Open Your Port

```bash
sudo ufw allow 4013/tcp
```

On your router, forward the port to this machine:

```text
External:4013 → Internal:4013 (TCP)
```

---

<a id="s7-autoupdate"></a>

# 🟢 7. Auto-Updates (How Your Node Stays Current)

Timpi ships new GeoCore versions to `timpiltd/timpi-geocore:latest`. With **auto-updates on**, your node
picks them up by itself — usually within an hour — and you never run manual upgrade steps again.

* Used **Automatic Install (6.1)** and chose **Yes**? ✅ You're already set — nothing more to do.
* Did a **Manual Install (6.2)**, or already have a node running? → follow [7.1](#s7-1-existing) below.

> 🔁 **Nothing to remove yourself.** When a new version is out, Watchtower stops your old container, pulls the
> new image, recreates it with the **same GUID, port and data**, and deletes the old image — all automatically.

---

<a id="s7-1-existing"></a>

## 7.1 Already have a node? Turn on auto-updates (one time)

**Step 1 — find your GeoCore's container name:**

```bash
sudo docker ps
```

Look at the **NAMES** column (far right), e.g.:

```text
CONTAINER ID   IMAGE                           NAMES
abc123def456   timpiltd/timpi-geocore:latest   geocore
```

Here the name is `geocore`. Yours might be `geocore` or a random name like `epic_satoshi` — note it for Step 2.

**Step 2 — start Watchtower** (change **only the last word** to your name from Step 1):

```bash
sudo docker run -d \
  --name watchtower \
  --restart unless-stopped \
  -e DOCKER_API_VERSION=1.44 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower --interval 3600 --cleanup geocore
```

* Run this **once**. From now on GeoCore updates itself automatically.
* The `-e DOCKER_API_VERSION=1.44` line is **required** — without it Watchtower won't start on modern Docker.
* Leave `--name watchtower` (line 2) alone — that's Watchtower's own name, not your node.
* Running **several GeoCores** (see [§9](#s9-multiple))? One Watchtower covers all — list each name at the end:
  `... --cleanup geocore geocore2 geocore3` (or omit the names to watch every container on the machine).

---

<a id="s7-2-verify"></a>

## 7.2 Verify auto-updates

```bash
sudo docker ps --filter name=watchtower
sudo docker logs watchtower --tail 20
```

You should see Watchtower running and a line like `Scheduling first run …`.

---

<a id="s8-manual-update"></a>

# 🟩 8. Manual Update (Fallback)

> 💡 **Most operators never need this** — auto-updates ([§7](#s7-autoupdate)) handle it. These steps are only for
> nodes **without** Watchtower, or if you want to force an update right now.

```bash
# 1) Stop & remove the current container (your data stays on disk in /var/timpi)
sudo docker stop geocore 2>/dev/null
sudo docker rm   geocore 2>/dev/null

# 2) Pull the newest image
sudo docker pull timpiltd/timpi-geocore:latest

# 3) Re-run (same GUID, port, volume, location as before)
sudo docker run -d \
  --name geocore \
  --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=1.1.1.1 \
  -p 4013:4013 \
  -v /var/timpi:/var/timpi \
  -e COMPORT=4013 \
  -e GUID="your-guid" \
  -e LOCATION="Sweden/Stockholm" \
  timpiltd/timpi-geocore:latest

# 4) Remove the old image (keeps disk clean)
sudo docker image prune -f
```

*(Replace `geocore` with your container's name if it differs — check `sudo docker ps`.)*

---

<a id="s9-multiple"></a>

# 🔵 9. Run Multiple GeoCores

Each node on the same machine needs its **own**: container **name**, **port**, **host volume path**, and **GUID**.
Only change the **host** side of `-v` (left of the colon) — keep the container side `/var/timpi` exactly as-is.

```bash
# GeoCore #2
sudo docker run -d --name geocore2 \
  --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=1.1.1.1 \
  -p 4015:4015 -v /var/timpi2:/var/timpi \
  -e COMPORT=4015 -e GUID="your-second-guid" -e LOCATION="Sweden/Stockholm" \
  timpiltd/timpi-geocore:latest

# GeoCore #3
sudo docker run -d --name geocore3 \
  --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=1.1.1.1 \
  -p 4016:4016 -v /var/timpi3:/var/timpi \
  -e COMPORT=4016 -e GUID="your-third-guid" -e LOCATION="Sweden/Stockholm" \
  timpiltd/timpi-geocore:latest
```

Unique per node: `--name`, `-p` host port, host volume path, `COMPORT`, `GUID`. The `--dns` flags stay the same.

> 🔄 **One Watchtower covers all of them** — list every name (or omit names to watch all):
> `... --cleanup geocore geocore2 geocore3`. See [§7.1](#s7-1-existing).

---

<a id="s10-logs"></a>

# 🔵 10. Monitor Logs

**One GeoCore:**

```bash
sudo docker logs -f geocore
```

**Multiple GeoCores** — select by port so Docker picks exactly one:

```bash
sudo docker logs -f $(sudo docker ps --filter "publish=4015" -q)
```

**Log files on disk:**

```bash
sudo tail -n 50 -f $(ls -t /var/timpi/GeoCore/logs/GeoCore-log*.txt | head -n 1)
ls -l /var/timpi/GeoCore/logs        # list all
```

> 📁 These paths use `/var/timpi` (the default volume). If a node uses a different host path
> (e.g. `-v /var/timpi2:/var/timpi`), look under that path instead — e.g. `/var/timpi2/GeoCore/logs/`.
> The `docker logs` commands above work by name/port regardless of the volume path.

Handy alias (optional):

```bash
alias geocorelog='sudo tail -f $(ls -t /var/timpi/GeoCore/logs/GeoCore-log*.txt | head -n 1)'
```

**DataCom logs:**

```bash
sudo tail -f /var/timpi/Datacom-log*.txt
```

---

<a id="s11-expected"></a>

# 🔵 11. Expected Logs & Outputs

**Healthy GeoCore startup** (key lines — they may not all appear together, and the version number changes over time):

```text
Starting TimpiDataCom...
Starting TimpiGeoCore...
INFO: GeoCore is running on the main network
GeoCore: Production mode detected.
Environment variable 'GUID' found - <YOUR-GUID>.
GeoCore: ConnectionPort port = 4013
Environment variable 'LOCATION' found - Sweden/Stockholm.
---------------------------- GeoCore: System test done ----------------------------
INFO: Got version 1.2.0 from core - Own version: 1.2.0
INFO: GeoCore Node information received from TAP. NA - USEC
      Now listening on: http://[::]:4013
      Application started. Press Ctrl+C to shut down.
```

**Guardian scan** (numbers vary):

```text
INFO: Found 72 free Guardians in 11 regions
```

**Crawling activity** — once running, you'll see domains being processed:

```text
INFO: Starting Processor 1 with 0 files in the InboundFolder folder
Domain example.com is finshed. Active:1
```

> 📄 **DataCom** runs alongside GeoCore (`Starting TimpiDataCom...`). Its detailed logs are in
> `/var/timpi/Datacom-log*.txt` — see [§10](#s10-logs).

---

<a id="s12-params"></a>

# 🔵 12. Docker Parameter Reference

| Parameter                   | Description                      |
| --------------------------- | -------------------------------- |
| `--name`                    | Container name (unique per node) |
| `--pull=always`             | Fetch the latest image on (re)create |
| `--restart unless-stopped`  | Auto-restart after reboots       |
| `--dns`                     | **Timpi DNS — required.** The two `100.42.180.x` are required; `--dns=1.1.1.1` is an optional fallback |
| `-p PORT:PORT`              | GeoCore exposed port             |
| `-v /var/timpiX:/var/timpi` | Data volume (unique host path per node) |
| `-e GUID=`                  | Your node GUID                   |
| `-e COMPORT=`               | GeoCore port                     |
| `-e LOCATION=`              | Country/City                     |
| `containrrr/watchtower`     | Auto-updater (see [§7](#s7-autoupdate)) |
| `-e DOCKER_API_VERSION=1.44`| Required env for Watchtower      |

---

<a id="s13-troubleshooting"></a>

# 🔵 13. Troubleshooting

### Restart a stopped GeoCore

```bash
sudo docker start geocore
```

### DNS issues

```bash
sudo docker exec -it geocore cat /etc/resolv.conf
```

### Permission issues

```bash
sudo chmod -R 777 /var/timpi    # adjust to your security needs
```

### 🧹 Clean Slate / full reset (only when needed)

Use this **only** to clean up broken or duplicate setups (e.g. leftover randomly-named containers like
`epic_satoshi`), or before changing ports/GUID. It removes **all** GeoCore containers and images:

```bash
# Stop & remove all GeoCore containers
sudo docker rm -f $(sudo docker ps -a --filter "ancestor=timpiltd/timpi-geocore" -q) 2>/dev/null

# Remove all GeoCore images
sudo docker rmi -f $(sudo docker images "timpiltd/timpi-geocore" -q) 2>/dev/null

# (Optional) deep cleanup of dangling docker bits
sudo docker image prune -f
```

> ⚠️ To also wipe **node data**: `sudo rm -rf /var/timpi` (you'll re-register from scratch). Skip this unless you
> really want a clean start.

After a reset, reinstall via [§6](#s6-install).

---

<a id="s14-upcoming"></a>

# 🔵 14. Upcoming Feature

**GeoCore Online Checker Tool** — will show uptime, version, routing status, region, and TAP connectivity.

---

<a id="s15-community"></a>

# 🔵 15. Community & Support

* **Discord GeoCore channel:** <https://discord.com/channels/946982023245992006>
* **Support tickets:** <https://discord.com/channels/946982023245992006/1179427377844068493>
* **Registration page:** <https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md>
