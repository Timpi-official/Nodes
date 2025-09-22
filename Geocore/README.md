# 🌐 Timpi GeoCore Node



Run a **GeoCore Node** to help power Timpi’s decentralized, location-aware search infrastructure.  
Fast. Distributed. Privacy-focused.

<img width="1509" height="850" alt="Screenshot_2025-07-23_182616_upscayl_3x_realesrgan-x4plus-anime" src="https://github.com/user-attachments/assets/7b69280a-a77b-46d3-85d0-88b517c097bb" />


---

# 📑 Table of Contents

* [What is a GeoCore Node?](#-what-is-a-geocore-node)
* [System Requirements](#-system-requirements)
* [Step 0 – Register Your GUID](#-step-0--register-your-guid)
* [Step 1 – Install Docker](#step-1-install-docker)
* [Step 1B – Automatic GeoCore Installation](#step-1b-automatic-geocore-installation)

  * [What happens under the hood?](#-what-happens-under-the-hood)
* [Step 2 – Open Required Ports](#-step-2--open-required-ports)
* [Step 3 – Manual Installation (Production Mode)](#-step-3--manual-installation---run-in-production-mode-background)
* [Step 4 – Monitor Logs](#-step-4--monitor-logs)
* [Run a Second GeoCore (Optional)](#-run-a-second-geocore-optional)
* [Docker Parameters Reference](#-docker-parameters-reference)
* [Upcoming Feature](#upcoming-feature)
* [Community & Support](#-community--support)

---

## 📌 What is a GeoCore Node?

A **GeoCore Node** enhances Timpi’s network by routing traffic based on geographic proximity. Each node announces its location, connects to the TAP (Timpi Access Point), and strengthens the decentralized infrastructure.

GeoCore nodes are lightweight and easy to run — perfect for individuals who want to support Timpi with minimal resources.

---

## ✅ System Requirements

| Component   | Recommended Minimum                    |
| ----------- | -------------------------------------- |
| OS          | **Ubuntu 22.04 LTS (native install)**  |
| CPU         | 4 cores                                |
| RAM         | 8 GB                                   |
| Storage     | 3 GB free disk space                   |
| Bandwidth   | 50 Mbps up/down                        |
| Uptime      | 95% minimum (penalties for downtime)   |
| Network     | Port forwarding required               |
| Docker      | ✅ Required                             |
| Ports       | `4100/tcp` (default) — open in firewall and router |

---

## ⚠️ Important Support Notice

Timpi GeoCore nodes are supported on:

* ✅ **Linux Ubuntu 22.04 LTS (native) with Docker**
* ✅ [ **FluxOS** Flux Marketplace deployment](https://github.com/Timpi-official/Nodes/tree/main/FluxDeployment)

❌ **Not Supported**: Windows (10/11), macOS, WSL (Linux on Windows), Proxmox LXC, or other non-Ubuntu Linux distributions.

👉 If you choose to run on **any other Linux distribution**, you are welcome to try — but we **do not provide technical support in tickets** for non-Ubuntu setups. You must be able to troubleshoot and guide yourself.

👉 Timpi support is limited to the **GeoCore software** (Ubuntu Docker + Flux) and the **official installation guides**. Network, firewall, router, and host configuration remain the responsibility of the operator.

---

## 📝 Step 0 – Register Your GUID

Before running your node, you need to **register your unique GeoCore GUID** on the Timpi network:

📎 [➡️ GeoCore Registration Page](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md)

Once registered, you’ll receive a **GUID** like:

**2f7256b8-c275-429b-8077-01519cced572**

---

## Step 1 install docker

Run these one by one on your Ubuntu 22.04 server:

```shell
sudo apt update
````

```shell
sudo apt upgrade
````

```shell
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```

```shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

```shell
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```shell
sudo apt update
```

```shell
sudo apt install -y docker-ce
```

```shell
sudo systemctl status docker
```

✅ Docker must show `active (running)` before continuing.

---

⚠️ Tip: Solve Common Docker Issues

If Docker says it’s not running or not found after install, run:

```shell
sudo usermod -aG docker $USER
```

Then log out and log back in to apply the permissions.

🧠 This step ensures your user can run Docker without sudo and helps avoid permission issues.

---
## Step 1B Automatic GeoCore Installation

### ⚠️ NOTE: Install docker before running script below if it fails go to manual step 3!

You can install GeoCore with a single command:


```shell
bash <(curl -sSL https://raw.githubusercontent.com/johnolofs/Geocore/main/GC-AutoInstall.sh)
```

## ⚙️ This script will:

- ✅ Check if Docker is running
- 🔌 Prompt you for a GeoCore port (default: 4100)
- 🆔 Ask for your GeoCore GUID
- 📍 Ask for your location in format Country/City
- 🐳 Launch the Docker container
- 📡 Show how to monitor logs

---

### 📦 What happens under the hood?

The script runs this:

```shell
sudo docker run -d --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=8.8.8.8 \
  -p ${GEOCORE_PORT}:${GEOCORE_PORT} \
  -v /var/timpi:/var/timpi \
  -e CONPORT=${GEOCORE_PORT} \
  -e GUID="${GUID}" \
  -e LOCATION="${LOCATION}" \
  timpiltd/timpi-geocore:latest
```

It also prints instructions to check your logs afterward:

```shell
# Real-time log file 10 rows:
sudo tail -f $(ls -t /var/timpi/GeoCore-log*.txt | head -n 1)

# Real-time full log file
sudo tail -n +1 -F $(ls -t /var/timpi/GeoCore-log*.txt | head -n 1)

# Docker logs:
sudo docker logs -f --tail 50 <Container_ID>
```

> 💡 Tip: Press **Ctrl + C** to stop viewing logs.

---

## 🔓 Step 2 – Open Required Ports

### If using UFW (firewall):

```shell
sudo ufw allow 4100/tcp
```

### If using a home router:

Forward external port `4100` to your server’s internal IP on port `4100` (TCP).

---

## 🚀 Step 3 – Manual Installation - Run in Production Mode (Background)


Once Docker is installed and your GUID is registered, you can run GeoCore in the background with auto-restart enabled:

```shell
sudo docker run -d --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=8.8.8.8 \
  -p 4100:4100 \
  -v /var/timpi:/var/timpi \
  -e CONPORT=4100 \
  -e GUID="your-guid-here" \
  -e LOCATION="Sweden/Stockholm" \
  timpiltd/timpi-geocore:latest
```

Replace:

* `your-guid-here` with your registered GUID
* `Sweden/Stockholm` with your real location (e.g., `Germany/Berlin`, `US/Dallas`)

---

## 📖 Step 4 – Monitor Logs

### View real-time logs from the latest GeoCore log file:

```shell
sudo tail -f $(ls -t /var/timpi/GeoCore-log*.txt | head -n 1)
```

### Output (note: using Custom port 4006):

<img width="1054" height="203" alt="Skärmavbild 2025-07-28 kl  18 09 46" src="https://github.com/user-attachments/assets/ce17ee32-3251-438b-b0e4-a9c737a9de0a" />


### View real-time logs from the latest GeoCore docker logs (Note: Using Custom Port 4006):

```shell
sudo docker logs -f --tail 50 <Container_ID>
```

<img width="883" height="385" alt="Skärmavbild 2025-07-28 kl  18 13 08" src="https://github.com/user-attachments/assets/02849db0-a000-42b9-96c1-a5a8f19f3870" />


💡 **Optional shortcut** – add this to `~/.bashrc`:

```shell
echo "alias geocorelog='sudo tail -f \$(ls -t /var/timpi/GeoCore-log*.txt | head -n 1)'" >> ~/.bashrc
source ~/.bashrc
```

Then use:

```shell
geocorelog
```

---

## 🧬 Run a Second GeoCore (Optional)

You can run multiple GeoCores on the same machine by:


* Using a different **port** `-p 4101:4101 \` and `-e CONPORT=4101 \` (Needs to be the same port number).
* Using a different **GUID**
* (Mandatory) Mounting a separate volume

### Example:

```shell
sudo docker run -d --pull=always \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=8.8.8.8 \
  --restart unless-stopped \
  -p 4101:4101 \
  -v /var/timpi2:/var/timpi \
  -e CONPORT=4101 \
  -e GUID="your-second-guid" \
  -e LOCATION="Sweden/Stockholm" \
  timpiltd/timpi-geocore:latest
```

---

## 🔍 Docker Parameters Reference

| Parameter                  | Description                              |
| -------------------------- | ---------------------------------------- |
| `--pull=always`            | Always pull the latest image             |
| `--restart unless-stopped` | Auto-restart container on failure/reboot |
| `--dns`                    | Connect to Timpi DNS                     |
| `-p 4100:4100`             | Maps external port to container          |
| `-v /var/timpi:/var/timpi` | Mounts data folder                       |
| `-e GUID="..."`            | Your registered GeoCore GUID             |
| `-e CONPORT=4100`          | Port the GeoCore listens on              |
| `-e LOCATION="..."`        | Location for routing logic               |

---

## Upcoming Feature
Geocore Online Checker Tool to be announced.

## 🙋 Community & Support

* 💬 Ask in [Discord – GeoCore Channel](https://discord.com/channels/946982023245992006)
* 🛠️ Get help in [#support](https://discord.com/channels/946982023245992006/1179427377844068493)
* 🧾 Register your GeoCore: [GeoCore Registration Page](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md)

---

**Built with 🧠 by the Timpi community**
Empowering a faster, fairer, and decentralized internet 🌍
