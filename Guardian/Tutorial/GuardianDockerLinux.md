# 🛡️ Timpi Guardian Node – Official Community Guide

Run a Guardian Node to help decentralize the web and power Timpi’s search engine.
Secure. Distributed. Community-powered.

<img width="1509" height="850" alt="Guardian Banner" src="https://github.com/user-attachments/assets/f11e358c-15cc-4618-bca0-cfcdb615a65d">

---

# 📑 Table of Contents

* [1. What Is a Guardian Node?](#what-is-a-guardian-node)
* [2. Supported Systems & Requirements](#supported-systems--requirements)
* [3. Installation Paths](#installation-paths)
  * [3.1 New Install (First-Time Setup)](#31-new-install-first-time-setup)
  * [3.2 Upgrade Existing Guardian](#32-upgrade-existing-guardian)
* [4. Step 0 – Install Docker & Java](#4-step-0--install-docker--java)
* [5. Step 0.5 – Create Persistent Storage](#5-step-05--create-persistent-storage)
* [6. Step 1 – Quick Start (Automatic Script)](#6-step-1--quick-start-automatic-script)
  * [6.1 What the Script Does](#61-what-the-script-does)
  * [6.2 Expected Script Output](#62-expected-script-output)
  * [6.3 Expected Container Logs](#63-expected-container-logs)
  * [6.4 Expected Persistent Guardian Logs](#64-expected-persistent-guardian-logs)
* [7. Manual Setup Guide](#7-manual-setup-guide)
  * [7.1 Create Data & Log Folders](#71-create-data--log-folders)
  * [7.2 Run the Guardian Manually](#72-run-the-guardian-manually)
  * [7.3 Open Required Ports](#73-open-required-ports)
  * [7.4 Deep Checks – Inside Docker Container](#74-deep-checks--inside-docker-container)
* [8. Run a Second Guardian Node](#8-run-a-second-guardian-node)
* [9. Verification & Quick Troubleshooting](#9-verification--quick-troubleshooting)
* [10. Docker Parameters Explained](#10-docker-parameters-explained)
* [11. Support](#11-support)

---

<a id="what-is-a-guardian-node"></a>
## 1. What Is a Guardian Node?

A Guardian Node hosts a portion of Timpi’s decentralized index using Apache Solr.

Guardians:

✔ Store segments of the Timpi index  
✔ Serve search queries  
✔ Improve regional latency  
✔ Strengthen decentralization  

---

<a id="supported-systems--requirements"></a>
## 2. Supported Systems & Requirements

| Component | Recommended Minimum                |
| --------- | ---------------------------------- |
| OS        | **Ubuntu 22.04.x LTS (native)**    |
| CPU       | 8+ cores                           |
| RAM       | 12+ GB                             |
| Storage   | **1 TB free** (Solr index)         |
| Network   | Stable 24/7                        |
| Docker    | Required                           |
| Ports     | Solr + Guardian ports must be open |
| Ports     | 4005/8983 (Default) |

⚠️ Official support: **Ubuntu 22.04 LTS + Docker**  
⚠️ Unsupported but may work: WSL, macOS, Windows, Proxmox LXC, etc.

---

<a id="installation-paths"></a>
## 3. Installation Paths

Choose one:

<a id="31-new-install-first-time-setup"></a>
### 3.1 New Install (First-Time Setup)

Use this if you have never run a Guardian on this machine.

1. Install Docker & Java  
2. Create persistent folders  
3. Run the automatic Quick Start installer  

---

<a id="32-upgrade-existing-guardian"></a>
### 3.2 Upgrade Existing Guardian

Remove old container:

```bash
sudo docker rm -f $(sudo docker ps -a -aq --filter "ancestor=timpiltd/timpi-guardian")
````

Remove old image:

```bash
sudo docker rmi -f $(sudo docker images timpiltd/timpi-guardian -q)
```

Then run the Quick Start script below.

---

<a id="4-step-0--install-docker--java"></a>

## 4. Step 0 – Install Docker & Java

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
 | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```bash
sudo apt update
sudo apt install -y docker-ce default-jre
```

Check Docker:

```bash
sudo systemctl status docker
```

Expected:

```text
Active: active (running)
```

### Add your user to the Docker group (recommended)

Fixes “permission denied /var/run/docker.sock”

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

<a id="5-step-05--create-persistent-storage"></a>

## 5. Step 0.5 – Create Persistent Storage

```bash
mkdir -p ${HOME}/var/solrdocker/data
mkdir -p ${HOME}/var/solrdocker/logs
```

Inside container these map to:

* `/var/solr/data`
* `/var/solr/logs`

---

<a id="6-step-1--quick-start-automatic-script"></a>

## 6. Step 1 – Quick Start (Automatic Script)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Timpi-official/Nodes/main/Guardian/TimpiGuardianLatest.sh)
```

---

<a id="61-what-the-script-does"></a>

### 6.1 What the Script Does

✔ Prompts for Solr port, Guardian port, GUID, Country/City
✔ Creates persistent folders
✔ Starts Guardian with:

* `SOLR_HOME=/var/solr`
* `SOLR_DATA=/var/solr/data`
* Correct --dns=100.42.180.29 --dns=100.42.180.99 + 1.1.1.1
* Image: `timpiltd/timpi-guardian:latest`

---

<a id="62-expected-script-output"></a>

### 6.2 Expected Script Output

```text
===== Timpi Guardian – Quick Setup =====
➡️ Solr Port: 8983
➡️ Guardian Port: 4005
➡️ GUID: xxxx
📍 Country: Sweden
🏙️ City: Stockholm

📂 Creating data folder...

🚀 Starting Timpi Guardian container...
Status: Downloaded newer image...

✅ Guardian started successfully!
```

---

<a id="63-expected-container-logs"></a>

### 6.3 Expected Container Logs

```text
INFO: Guardian is running on the main network
Guardian: Production mode detected.
Guardian port = 4005
Starting Solr instance...
Started Solr on port 8983. Happy searching!
```

---

<a id="64-expected-persistent-guardian-logs"></a>

### 6.4 Expected Persistent Guardian Logs

```text
INFO: Triangulation successful. Region: EMEA
INFO: Got the Collection list with 19 entries.
Solr started, starting Guardian API.
Guardian update sent to CO.
```

If you see these → your node is fully online.

---

<a id="7-manual-setup-guide"></a>

# 7. Manual Setup Guide

<a id="71-create-data--log-folders"></a>

## 7.1 Create Data & Log Folders

```bash
mkdir -p ${HOME}/var/solrdocker/data
mkdir -p ${HOME}/var/solrdocker/logs
```

---

<a id="72-run-the-guardian-manually"></a>

## 7.2 Run the Guardian Manually

```bash
sudo docker run -d --pull=always --restart unless-stopped \
  --name guardian1 \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=1.1.1.1 \
  -p 8983:8983 \
  -p 4005:4005 \
  -v ${HOME}/var/solrdocker:/var/solr \
  -e SOLR_HOME=/var/solr \
  -e SOLR_DATA=/var/solr/data \
  -e SOLR_PORT=8983 \
  -e GUARDIAN_PORT=4005 \
  -e GUID="your-guid" \
  -e LOCATION="Country/City" \
  timpiltd/timpi-guardian:latest
```

---

<a id="73-open-required-ports"></a>

## 7.3 Open Required Ports

```bash
sudo ufw allow 8983/tcp
sudo ufw allow 4005/tcp
```

---

<a id="74-deep-checks--inside-docker-container"></a>

## 7.4 Deep Checks – Inside Docker Container

```bash
sudo docker exec -it guardian1 bash
env | grep SOLR
ls -la /var/solr
```

---

<a id="8-run-a-second-guardian-node"></a>

# 8. Run a Second Guardian Node

```bash
mkdir -p ${HOME}/var/solrdocker2/data
mkdir -p ${HOME}/var/solrdocker2/logs
```

```bash
sudo docker run -d --pull=always --restart unless-stopped \
  --name guardian2 \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=1.1.1.1 \
  -p 8984:8984 \
  -p 4006:4006 \
  -v ${HOME}/var/solrdocker2:/var/solr \
  -e SOLR_HOME=/var/solr \
  -e SOLR_DATA=/var/solr/data \
  -e SOLR_PORT=8984 \
  -e GUARDIAN_PORT=4006 \
  -e GUID="second-guid" \
  -e LOCATION="Country/City" \
  timpiltd/timpi-guardian:latest
```

💡 **You can run unlimited Guardians** as long as:

* Ports are unique
* Folders are unique
* GUIDs are unique

---

<a id="9-verification--quick-troubleshooting"></a>

# 9. Verification & Quick Troubleshooting

### **Guardian API check**

```bash
curl -I http://localhost:<guardian_port>
```

Examples:

* `4005` → first Guardian
* `4006` → second Guardian

---

### **Solr UI Check**

```text
http://<your-ip>:8983/solr/
http://<your-ip>:8984/solr/
```

---

### **Container logs**

First, find your Guardian container name:

```bash
sudo docker ps --filter "ancestor=timpiltd/timpi-guardian"
```

Example output:

```text
NAMES
keen_elgamal
```

Then check logs:

```bash
sudo docker logs <container_name>
```

Example:

```bash
sudo docker logs keen_elgamal
```

---

### **Persistent logs**

```bash
tail -n 50 ${HOME}/var/solrdocker/logs/guardian-log*.txt
tail -n 50 ${HOME}/var/solrdocker2/logs/guardian-log*.txt
```

---

<a id="10-docker-parameters-explained"></a>

# 10. Docker Parameters Explained

| Param                           | Meaning                    |
| ------------------------------- | -------------------------- |
| `--pull=always`                 | Always update image        |
| `--restart unless-stopped`      | Auto restart               |
| `--dns=`                        | Timpi DNS+CloudFlare DNS   |
| `-v ~/var/solrdocker:/var/solr` | Persistent storage         |
| `SOLR_HOME`                     | Solr root folder           |
| `SOLR_DATA`                     | Solr index folder          |
| `GUID`                          | Guardian identity          |
| `LOCATION`                      | Region mapping             |

---

<a id="11-support"></a>

# 11. Support

If you need help:

**Discord GeoCore Channel**
[https://discord.com/channels/946982023245992006](https://discord.com/channels/946982023245992006)

**Support Tickets**
[https://discord.com/channels/946982023245992006/1179427377844068493](https://discord.com/channels/946982023245992006/1179427377844068493)

**Registration Page**
[https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md)

