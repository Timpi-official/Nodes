# 🌐 **1. Timpi GeoCore Node – Official Community Guide**

Run a **GeoCore Node** to help power Timpi’s decentralized, location-aware routing infrastructure.
Lightweight. Fast. Privacy-focused.

<img width="1509" height="850" src="https://github.com/user-attachments/assets/7b69280a-a77b-46d3-85d0-88b517c097bb" />

---

# 📘 **2. Table of Contents**

1. [Introduction – What Is a GeoCore Node?](#21-introduction--what-is-a-geocore-node)
2. [System Requirements](#22-system-requirements)
3. [Important Support Notice](#23-important-support-notice)
4. [Two Paths: New Install vs Upgrade](#24-two-paths-new-install--upgrade-flow)
5. [Clean Slate (Optional but Recommended)](#24a-clean-slate-optional-but-recommended)
6. [Register Your GUID](#25-register-your-guid)
7. [NEW INSTALL PATH](#3-new-install-path)

   * [3.1 Install Docker](#31-install-docker)
   * [3.2 Automatic GeoCore Installation](#32-automatic-geocore-installation)
   * [3.3 Manual Install (Any Port)](#33-manual-install-any-port)
   * [3.4 Open Your Port](#34-open-your-port)
8. [UPGRADE PATH](#4-upgrade-path)

   * [4.1 Upgrade Steps](#41-upgrade-steps)
   * [4.2 Verify After Upgrade](#42-verify-after-upgrade)
9. [Monitor Logs](#5-monitor-logs)
10. [Expected Logs & Outputs](#6-expected-logs--outputs)
11. [Run Multiple GeoCores](#7-run-multiple-geocores)
12. [Docker Parameter Reference](#8-docker-parameter-reference)
13. [Troubleshooting](#9-troubleshooting)
14. [Upcoming Feature](#10-upcoming-feature)
15. [Community & Support](#11-community--support)

---

<a id="21-introduction--what-is-a-geocore-node"></a>

# 1. **Introduction – What Is a GeoCore Node?**

A **GeoCore Node** powers Timpi’s decentralized network by:

* announcing your physical region (e.g., `Sweden/Stockholm`)
* connecting to the TAP (Timpi Access Point)
* routing search traffic to the nearest Guardians
* improving global decentralization and performance

GeoCore is lightweight, Docker-based, and ideal for 24/7 operation.

---

<a id="22-system-requirements"></a>

# 2. **System Requirements**

| Component | Recommended Minimum           |
| --------- | ----------------------------- |
| OS        | **Ubuntu 22.04 LTS (native)** |
| CPU       | 4 cores                       |
| RAM       | 8 GB                          |
| Storage   | 3 GB                          |
| Bandwidth | 50 Mbps                       |
| Uptime    | 95%+                          |
| Port      | **4014/TCP (default)**        |
| Docker    | Required                      |

---

<a id="23-important-support-notice"></a>

# 3. **Important Support Notice**

Timpi officially supports:

✔ Ubuntu 22.04 LTS
✔ Native Docker
✔ FluxOS Marketplace deployments

Not supported (community-only):

❌ Windows, WSL, macOS
❌ Proxmox LXC
❌ Other Linux distributions

---

<a id="24-two-paths-new-install--upgrade-flow"></a>

# 4. **Two Paths: New Install & Upgrade Flow**

### ✔ Path A – New Install
7. [NEW INSTALL PATH](#3-new-install-path)
For brand-new users.

### ✔ Path B – Upgrade
8. [UPGRADE PATH](#4-upgrade-path)
For existing operators who want to update safely.

---

<a id="24a-clean-slate-optional-but-recommended"></a>

# 5. ⚠️ **Clean Slate (Optional but Recommended)**

This section **removes all old GeoCore containers and images**, including randomly-named containers such as `epic_satoshi`.

Use this when:

* switching ports
* changing GUID
* upgrading from older versions
* troubleshooting
* cleaning broken installations

---

## 5.1 **Stop & remove ALL old GeoCore containers**

Check containers, image IDs:

```bash
sudo docker ps
sudo docker ps -a
sudo docker images
```

Stop/Remove Container:

```bash
sudo docker stop <ContainerID>
sudo docker rm <ContainerID>
```

---

## 5.2 **Remove ALL old GeoCore images**

```bash
sudo docker rmi timpiltd/timpi-geocore:latest 2>/dev/null
sudo docker rmi -f $(docker images timpiltd/timpi-geocore -q) 2>/dev/null
sudo docker rmi -f $(docker images "timpiltd/timpi-geocore:*" -q) 2>/dev/null
```

Expected output
```
Untagged: timpiltd/timpi-geocore:latest
Untagged: timpiltd/timpi-geocore@sha256:da4c3d3cbe3bb28b365e335f2cd8260e819c55354e569e681e372e6a58685601
Deleted: sha256:3878a5239426d2b73f06a2eff39190430b4dfdbd53610c91b46cb8a87a03f84f
Deleted: sha256:eea381a8de5021105cf5b705bdd0eafddb20e1a136e21ab062453ff5d9b7886e
Deleted: sha256:3b42107b18bdca6034a110f83d6d20137277c33e45640ef2a1066b3f69d203c7
Deleted: sha256:25c9bd9824529f5ba09933bad018069159cfb6e27fa8333e593f251dd891bfdb
Deleted: sha256:4ac6541196fdea9e07b513cd3be7a847e7bc4a421297e16218b4923fab5cdf7b
Deleted: sha256:a6a882b83a0fe39b03d31f8e57bcdda99245dce78dc3a8499f72d0c0b51f54d7
Deleted: sha256:0624e8ef7c79887727e867cc93bc64c86fc4a9368d239d5f2bdd40e4dba99ac1
Deleted: sha256:9cb1201be94fedc643598b405bdb9b6588124437001815037174d12564464483
Deleted: sha256:f1a9b6ac3ae92f79ddc2c56cd7452b95d31f04860ba758a344ba0e5c76959187
```

---

## 5.3 **Confirm everything is gone**

```bash
sudo docker ps
sudo docker ps -a
sudo docker images
```

If any remain:

```bash
sudo docker rm <containerID>
sudo docker rmi <imageID>
```

---

## 5.4 **Remove old GeoCore folders (optional)**

Remove only GeoCore:

```bash
sudo rm -rf /var/timpi/GeoCore
```

Remove everything (GeoCore + DataCom):

```bash
sudo rm -rf /var/timpi
```

---

## 5.5 **Deep Docker cleanup (optional)**

```bash
sudo docker container prune -f
sudo docker image prune -f
sudo docker volume prune -f
sudo docker network prune -f
```

---

## 5.6 **Restart a stopped GeoCore container**

```bash
sudo docker start $(sudo docker ps -a --filter "ancestor=timpiltd/timpi-geocore:latest" -q)
```

*(Works fine even with multiple GeoCores – it starts all of them.)*

---

<a id="25-register-your-guid"></a>

# 6. **Register Your GUID**

👉 [https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md)

Example of generated GUID:

```text
2f7256b8-c275-429b-8088-01519cced582
```

---

<a id="3-new-install-path"></a>

# 🔵 **3. NEW INSTALL PATH**

---

<a id="31-install-docker"></a>

## 3.1 **Install Docker**

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```

Add Docker repo:

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list
```

Install Docker:

```bash
sudo apt update
sudo apt install -y docker-ce
sudo systemctl status docker
```

Expected:

```text
active (running)
```

Fix permissions:

```bash
sudo usermod -aG docker $USER
```

Logout/login.

---

<a id="32-automatic-geocore-installation"></a>

## 3.2 **Automatic GeoCore Installation**

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Timpi-official/Nodes/main/Geocore/GC-AutoInstall.sh)
```

**The script:**

* asks for port
* asks for GUID
* asks for location
* launches container
* prints log commands

#### ✅ Example run (expected output)

```bash
timpi@timpi-timpicore:/var/timpi/GeoCore$ bash <(curl -sSL https://raw.githubusercontent.com/Timpi-official/Nodes/main/Geocore/GC-AutoInstall.sh)

🌐 Timpi GeoCore Setup Script

➡️ Enter the port for GeoCore (Default: 4013)
GeoCore Port: 4013

🆔 Enter your GUID (Found in your Timpi dashboard)
GUID: YOUR-ACTUAL-GUID-HERE

📍 Let's enter your **location**
🌍 Country (Example: Sweden, Germany, United States): Sweden
🏙️ City (Example: Stockholm, Berlin, New York): Stockholm

✅ Location set to: Sweden/Stockholm

🚀 Launching GeoCore container...
latest: Pulling from timpiltd/timpi-geocore
7e49dc6156b0: Already exists
82e5182ff07f: Pull complete
e926bcd8cfd8: Pull complete
26c93f7a5ed6: Pull complete
49474c3d06da: Pull complete
0ba4642246c9: Pull complete
9757068358ec: Pull complete
e0a111a75b31: Pull complete
Digest: sha256:da4c3d3cbe3bb28b365e335f2cd8260e819c55354e569e681e372e6a58685601
Status: Downloaded newer image for timpiltd/timpi-geocore:latest

✅ GeoCore is now running on port 4013
🧾 Container ID: 4d915ab92ec8c15665e03eae6d63f350b9106fc499a95ac01e12723bff6d4453

📡 To view logs:

1️⃣  Real-time log file:
    sudo tail -f $(ls -t /var/timpi/GeoCore/logs/GeoCore-log*.txt | head -n 1)

2️⃣  Docker logs:
    sudo docker logs -f --tail 50 4d915ab92ec8c15665e03eae6d63f350b9106fc499a95ac01e12723bff6d4453

🧠 Tip: Press Ctrl + C to stop viewing the logs.
```

#### 📄 Example GeoCore logs (first healthy startup)

```bash
timpi@timpi-timpicore:/var/timpi/GeoCore$ sudo docker logs -f --tail 50 4d915ab92ec8c15665e03eae6d63f350b9106fc499a95ac01e12723bff6d4453
Setting timezone to UTC...
Current UTC time: Mon Dec  8 08:10:03 UTC 2025
timedatectl not available. Skipping sync check.
Warning: /opt/timpi/datacom/Timpi_DataCom not found. Using image copy in /opt/datacom if needed.
Starting TimpiDataCom...
Starting TimpiGeoCore...
GeoCore: Log_Folder missing, trying to get it from appsettings.json
ERROR: Could not read Log_Folder from appsettings.json. Error: Object reference not set to an instance of an object.
----------------------------- PreLogger messages END ------------------------------
INFO: GeoCore is running on the main network
INFO: IsDirectDeployment is not set, using default value 0.
GeoCore: Production mode detected.
GeoCore: DEBUG_LEVEL missing, trying to get it from appsettings.json
ERROR: DEBUG_LEVEL missing, assume Warning level
GeoCore: Log_Folder missing, trying to get it from appsettings.json
GeoCore: Log folder /var/timpi/GeoCore/logs exists.
Environment variable 'GUID' found - YOUR-ACTUAL-GUID-HERE.
GeoCore: Checking parameters
GeoCore: ConnectionPort port = 4013
Environment variable 'LOCATION' found - Sweden/Stockholm.
GeoCore: Checking done, starting log manager. Logs are now in the persistent folder as /var/timpi/GeoCore/logs/GeoCore-log[DATE].txt
----------------------------- PreLogger messages END ------------------------------
---------------------------- GeoCore: System test done ----------------------------
INFO: Got version X.X.XX from core - Own version: X.X.XX
INFO: GeoCore Node information received from TAP. NA - USEC
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://[::]:4013
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Production
info: Microsoft.Hosting.Lifetime[0]
      Content root path: /opt/timpi/geocore
INFO: Found 79 free Guardians in 11 regions
INFO: Starting Processor 1 with 0 files in the InboundFolder folder
```

---

<a id="33-manual-install-any-port"></a>

## 3.3 **Manual Install (Any Port)**

GeoCore does not require port **4014** even if it’s the default.
You may use any free port — here is a working example using **4014**:

```bash
sudo docker run -d \
  --name geocore \
  --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=8.8.8.8 \
  -p 4014:4014 \
  -v /var/timpi:/var/timpi \
  -e COMPORT=4014 \
  -e GUID="your-guid-here" \
  -e LOCATION="Sweden/Stockholm" \
  timpiltd/timpi-geocore:latest
```

---

<a id="34-open-your-port"></a>

## 3.4 **Open Your Port**

```bash
sudo ufw allow 4014/tcp
```

Router:

```text
External:4014 → Internal:4014 (TCP)
```

---

<a id="4-upgrade-path"></a>

# 🟩 **4. UPGRADE PATH**

Because GeoCore uses `--pull=always`, updating is simple.

---

<a id="41-upgrade-steps"></a>

## 4.1 **Upgrade Steps**

### 1️⃣ Stop container

```bash
sudo docker stop $(sudo docker ps --filter "ancestor=timpiltd/timpi-geocore" -q)
```

### 2️⃣ Remove container

```bash
sudo docker rm $(sudo docker ps -a --filter "ancestor=timpiltd/timpi-geocore" -q)
```
### *(Optional Note for Beginners)*

> If Docker says **“requires at least 1 argument”**, it simply means no old GeoCore container exists. This is normal — continue to the next step.

### 3️⃣ Pull new version

```bash
sudo docker pull timpiltd/timpi-geocore:latest
```

### 4️⃣ Re-run your GeoCore

(Example using port 4014)

```bash
sudo docker run -d \
  --name geocore \
  --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=8.8.8.8 \
  -p 4014:4014 \
  -v /var/timpi:/var/timpi \
  -e COMPORT=4014 \
  -e GUID="your-guid" \
  -e LOCATION="Sweden/Stockholm" \
  timpiltd/timpi-geocore:latest
```

---

<a id="42-verify-after-upgrade"></a>

## 4.2 **Verify After Upgrade**

Because `docker logs` only accepts **one container**, and many users run multiple GeoCores, verify logs **per port**:

If your GeoCore runs on **4014**:

```bash
sudo docker logs -f $(sudo docker ps --filter "publish=4014" -q)
```

If it runs on **another port**, e.g. **4015**:

```bash
sudo docker logs -f $(sudo docker ps --filter "publish=4015" -q)
```

Look for lines like:

```text
GeoCore is running on the main network
Found X free Guardians
```

---

<a id="5-monitor-logs"></a>

# 🔵 **5. Monitor Logs**

---

## 5.1 **GeoCore Logs (Docker)**

### Single GeoCore (only one running)

If you only run ONE GeoCore, you can still use:

```bash
sudo docker logs -f $(sudo docker ps --filter "ancestor=timpiltd/timpi-geocore" -q)
```

### Multiple GeoCores (recommended method)

Use **port-based filters** so Docker only selects one container:

**GeoCore #1 (example: port 4014)**

```bash
sudo docker logs -f $(sudo docker ps --filter "publish=4014" -q)
```

**GeoCore #2 (example: port 4015)**

```bash
sudo docker logs -f $(sudo docker ps --filter "publish=4015" -q)
```

**GeoCore #N** — replace `<PORT>`:

```bash
sudo docker logs -f $(sudo docker ps --filter "publish=<PORT>" -q)
```

---

## 5.2 **GeoCore Log Files**

Follow the latest GeoCore log file:

```bash
sudo tail -n 50 -f $(ls -t /var/timpi/GeoCore/logs/GeoCore-log*.txt | head -n 1)
```

Example of expected output:
```
timpi@timpi-timpicore:/var/timpi/GeoCore/logs$ sudo tail -n 50 -f $(ls -t /var/timpi/GeoCore/logs/GeoCore-log*.txt | head -n 1)
2025-12-08 08:10:04.150 +00:00 [INF] Logger started at 12/08/2025 08:10:04.
2025-12-08 08:10:04.164 +00:00 [INF] GeoCore: DEBUG_LEVEL 1 found.
2025-12-08 08:10:04.164 +00:00 [INF] ----------------------------- PreLogger messages START -----------------------------
2025-12-08 08:10:04.165 +00:00 [INF] GeoCore is running on the main network.
2025-12-08 08:10:04.165 +00:00 [INF] GeoCore: IsDirectDeployment is not set, using default value 0.
2025-12-08 08:10:04.165 +00:00 [INF] GeoCore: Production mode detected.
2025-12-08 08:10:04.165 +00:00 [WRN] GeoCore: DEBUG_LEVEL missing, trying to get it from appsettings.json
2025-12-08 08:10:04.165 +00:00 [WRN] DEBUG_LEVEL missing, assume Warning level.
2025-12-08 08:10:04.165 +00:00 [ERR] GeoCore: Log_Folder missing,  trying to get it from appsettings.json
2025-12-08 08:10:04.165 +00:00 [ERR] GeoCore: Log_Folder found: /var/timpi/GeoCore/logs.
2025-12-08 08:10:04.165 +00:00 [INF] GeoCore: Log folder /var/timpi/GeoCore/logs exists.
2025-12-08 08:10:04.165 +00:00 [INF] GeoCore: Environment variable 'GUID' found - YOUR-GUID.
2025-12-08 08:10:04.165 +00:00 [INF] GeoCore: ConnectionPort port = 4013.
2025-12-08 08:10:04.165 +00:00 [INF] GeoCore: Environment variable 'LOCATION' found - Sweden/Norrkoping.
2025-12-08 08:10:04.165 +00:00 [INF] ----------------------------- PreLogger messages END ------------------------------
2025-12-08 08:10:04.165 +00:00 [INF] ------------------------------ GeoCore: System test ------------------------------
2025-12-08 08:10:04.165 +00:00 [INF] GeoCore: CPU Count: 32 cores detected.
2025-12-08 08:10:04.165 +00:00 [INF] GeoCore: Memory Limit: 64 MB detected. Usable: 56
2025-12-08 08:10:04.166 +00:00 [INF] GeoCore: Harddisk Size: 1832 GB detected.
2025-12-08 08:10:04.166 +00:00 [INF] GeoCore: Free Space: 1418 GB detected.
2025-12-08 08:10:04.166 +00:00 [INF] Collector: Found Version X.X.X
2025-12-08 08:10:04.166 +00:00 [INF] GeoCore: Found Version X.X.XX
2025-12-08 08:10:04.166 +00:00 [INF] ---------------------------- GeoCore: System test done ----------------------------
2025-12-08 08:10:04.166 +00:00 [INF] ---------------------------- GeoCore: Version check --------------------------------
2025-12-08 08:10:04.166 +00:00 [INF] INFO: Checking Version of the GeoCore from the TAP.
2025-12-08 08:10:04.310 +00:00 [INF] INFO: GeoCore is up to date (X.X.XX).
2025-12-08 08:10:04.310 +00:00 [INF] ------------------------- GeoCore: Version check done ------------------------------
2025-12-08 08:10:04.310 +00:00 [INF] ------------------------ GeoCore: TAP Connection test ------------------------------
2025-12-08 08:10:04.449 +00:00 [INF] The response was successful: Geocore found on http://tapcore1.timpi.network:4014/
2025-12-08 08:10:04.449 +00:00 [INF] Getting GeoCore Object from Coordinator was True, GUID=YOUR-GUID
2025-12-08 08:10:04.449 +00:00 [INF] The GeoCore is trying to start on port:4013 with GUID YOUR-GUID.
2025-12-08 08:10:04.450 +00:00 [INF] GeoCore Node information received from TAP. NA - USEC
2025-12-08 08:10:04.450 +00:00 [INF] ---------------------- GeoCore: TAP Connection test done ---------------------------
2025-12-08 10:40:33.968 +00:00 [INF] Running remote command on Guardian - 12/08/2025 10:40:33
```

Nice alias (optional):

```bash
alias geocorelog='sudo tail -f $(ls -t /var/timpi/GeoCore/logs/GeoCore-log*.txt | head -n 1)'
```

List all logs:

```bash
ls -l /var/timpi/GeoCore/logs
```

---

## 5.3 **DataCom Logs**

```bash
sudo tail -f /var/timpi/Datacom-log*.txt
```

List:

```bash
ls -l /var/timpi/Datacom-log*.txt
```

---

<a id="6-expected-logs--outputs"></a>

# 🔵 **6. Expected Logs & Outputs**

---

## 6.1 **GeoCore Healthy Startup**

These lines do **not** always appear together – just make sure you see them somewhere in the log:

```text
Environment variable 'GUID' found - <YOUR GUID>
Environment variable 'LOCATION' found - Sweden/Stockholm
GeoCore: ConnectionPort found 4014
GeoCore: Log folder /var/timpi/GeoCore/logs created.
INFO: Got version 1.1.xx from core - Own version: 1.1.xx
INFO: GeoCore is running on the main network
GeoCore: Production mode detected.
Now listening on: http://[::]:4014
```

---

## 6.2 **Guardian Scan**

```text
INFO: Found 78 free Guardians in 11 regions
```

(Exact numbers will vary.)

---

## 6.3 **DataCom Healthy Logs**

```text
Datacom: Found Version 1.0.2
INFO: Datacom is up to date
INFO: Reading Public Suffix List
INFO: Reading Top10 Million List
Done reading Top10 million file
Starting master timer.
Starting worker!
```

---

<a id="7-run-multiple-geocores"></a>

# 🔵 **7. Run Multiple GeoCores**

Each node needs:

✔ Unique folder
✔ Unique container name
✔ Unique port
✔ Unique GUID

---

## 7.1 **Second GeoCore (geocore2)**

```bash
sudo docker run -d \
  --name geocore2 \
  --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=8.8.8.8 \
  -p 4015:4015 \
  -v /var/timpi2:/var/timpi \
  -e COMPORT=4015 \
  -e GUID="your-second-guid" \
  -e LOCATION="Sweden/Stockholm" \
  timpiltd/timpi-geocore:latest
```

---

## 7.2 **Third GeoCore (geocore3)**

```bash
sudo docker run -d \
  --name geocore3 \
  --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=8.8.8.8 \
  -p 4016:4016 \
  -v /var/timpi3:/var/timpi \
  -e COMPORT=4016 \
  -e GUID="your-third-guid" \
  -e LOCATION="Sweden/Stockholm" \
  timpiltd/timpi-geocore:latest
```

---

## 7.3 **Fourth GeoCore (geocore4)**

```bash
sudo docker run -d \
  --name geocore4 \
  --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=8.8.8.8 \
  -p 4017:4017 \
  -v /var/timpi4:/var/timpi \
  -e COMPORT=4017 \
  -e GUID="your-fourth-guid" \
  -e LOCATION="Sweden/Stockholm" \
  timpiltd/timpi-geocore:latest
```

---

<a id="8-docker-parameter-reference"></a>

# 🔵 **8. Docker Parameter Reference**

| Parameter                   | Description                 |
| --------------------------- | --------------------------- |
| `--pull=always`             | Always fetch latest version |
| `--restart unless-stopped`  | Auto-restart                |
| `--dns`                     | Timpi DNS (and fallback)    |
| `-p PORT:PORT`              | GeoCore exposed port        |
| `-v /var/timpiX:/var/timpi` | Unique volume per node      |
| `-e GUID=`                  | GeoCore GUID                |
| `-e COMPORT=`               | GeoCore port                |
| `-e LOCATION=`              | Country/City                |

---

<a id="9-troubleshooting"></a>

# 🔵 **9. Troubleshooting**

### Restart a stopped GeoCore

```bash
sudo docker start $(sudo docker ps -a --filter "ancestor=timpiltd/timpi-geocore:latest" -q)
```

### DNS issues

```bash
sudo docker exec -it geocore cat /etc/resolv.conf
```

### Permission issues

```bash
sudo chmod -R 777 /var/timpi
```

(Adjust to your security needs.)

---

<a id="10-upcoming-feature"></a>

# 🔵 **10. Upcoming Feature**

**GeoCore Online Checker Tool**
Will show:

* uptime
* version
* routing status
* region
* TAP connectivity

---

<a id="11-community--support"></a>

# 🔵 **11. Community & Support**

**Discord GeoCore Channel**
[https://discord.com/channels/946982023245992006](https://discord.com/channels/946982023245992006)

**Support Tickets**
[https://discord.com/channels/946982023245992006/1179427377844068493](https://discord.com/channels/946982023245992006/1179427377844068493)

**Registration Page**
[https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md)


