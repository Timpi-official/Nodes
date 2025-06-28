# 🛡️ Timpi Guardian Node

Run a Guardian Node to help decentralize the web and power Timpi’s search engine.
Secure. Distributed. Community-powered.

![Timpi Logo](https://nft.timpi.io/assets/timpi_image/guardian-hero.jpg)

---

## 📌 What is a Guardian Node?

A Guardian Node hosts a portion of Timpi’s decentralized index using Solr and serves web search results in the Timpi network. Guardians work together to ensure the web remains free and censorship-resistant.

---

## ✅ Supported Systems & Requirements

| Component | Recommended Minimum             |
| --------- | ------------------------------- |
| OS        | **Ubuntu 22.04.4 LTS (native)** |
| CPU       | 4+ cores                        |
| RAM       | 8+ GB                           |
| Storage   | **1 TB+ free disk space**       |
| Network   | Stable 24/7 internet            |
| Docker    | Required (see below)            |

>  ⚠️ Timpi does **not officially support** WSL, Proxmox LXC, Windows, macOS, or VM-limited environments.

---

### 🛠️ Step 0 – Install Docker & Java (Required for All Methods)

Before running either the automatic or manual setup, Docker **must be installed** on your system. Java is also required.

Run these **one line at a time** in your terminal on **Ubuntu 22.04.4 LTS**:

```bash
sudo apt update
```

```bash
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```bash
sudo apt update
```

```bash
sudo apt install -y docker-ce
```

```bash
sudo apt install -y default-jre
```

```bash
sudo systemctl status docker
```

> ✅ Docker must show `active (running)` before continuing.



## 🚀 Step 1 – Quick Start (Automatic Script)

> ✅ **Recommended for most users**
> 
>
> This option guides you interactively and automates:
>
> * Choosing Solr and Guardian ports
> * Entering your Guardian GUID
> * Setting your physical location (Country/City)
> * Creating the correct storage folder
> * Launching the Docker container

---

### ▶️ To get started, run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Timpi-official/Nodes/main/Guardian/TimpiGuardianLatest.sh)
```

---

### 💡 What You’ll See:

```text
➡️ Enter the port for Solr (Default: 8983)
➡️ Enter the port for Guardian (Default: 4005)
➡️ Enter your GUID
📍 Country?  City?
```

Once complete, your Guardian will automatically start using Docker.

---

### ✅ What to Do After the Script:

1. **Firewall Configuration** (if using UFW):

   ```bash
   sudo ufw allow 8983/tcp
   sudo ufw allow 4005/tcp
   ```

   *(Replace ports if you chose custom ones.)*

2. **Check Status:**

   ```bash
   sudo docker ps
   ```

3. **View Logs:**

   ```bash
   sudo docker logs <container_id>
   ```

---

## 🧹 Remove Previous Guardian (for updates)

Before reinstalling or updating, **remove any existing Guardian container and image** to prevent conflicts:

```bash
# Remove running Guardian container
sudo docker rm -f $(sudo docker ps -aq --filter "ancestor=timpiltd/timpi-guardian")

# Remove the Guardian image
sudo docker rmi -f $(sudo docker images timpiltd/timpi-guardian -q)
```

---

## 🔧 Manual Setup Guide

Use this if you want full control over setup or prefer not to use the script.

---

> 🚨 Docker & Java must be installed before continuing. If not done yet, go back to **Step 0**.

---

### 2. Create Data Folder

This folder stores your Guardian's index data and logs:

```bash
sudo mkdir -p ${HOME}/var/solrdocker
```

> ⚠️ **At least 1 TB of free disk space is required.**
> Keep this folder between updates — do **not delete it**.

---

### 3. Run the Guardian Manually

Replace the following:

* `your-guid-here` → your actual GUID from the Timpi dashboard
* `Country/City` → your real location (e.g., `Germany/Berlin`)

```bash
sudo docker run -d --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=8.8.8.8 \
  -p 8983:8983 \
  -p 4005:4005 \
  -v ${HOME}/var/solrdocker:/var/solr \
  -e SOLR_PORT=8983 \
  -e GUARDIAN_PORT=4005 \
  -e GUID=your-guid-here \
  -e LOCATION="Country/City" \
  timpiltd/timpi-guardian:latest
```

---

### 4. Open Firewall Ports

If you're using UFW:

```bash
sudo ufw allow 8983/tcp
sudo ufw allow 4005/tcp
```

Replace with your custom ports if needed.

---

### 5. View Logs

Check container status:

```bash
sudo docker ps
```

View real-time Guardian logs:

```bash
sudo docker logs <container_id>
```

Or view persistent log files:

```bash
cd ${HOME}/var/solrdocker/data/
```

```bash
# View the most recent log file live
ls -t guardian-log*.txt | head -n 1 | xargs tail -f
```

---

## 🧩 Run a Second Guardian Node

Want to run two Guardian nodes on the same machine? You can!
Just follow these rules:

* Use **different ports**
* Use a **different data folder**
* Use a **different GUID**

### Example setup:

```bash
# Create second data folder
mkdir -p ${HOME}/var/solrdocker2
```

```bash
# Run second Guardian on new ports
sudo docker run -d --pull=always --restart unless-stopped \
  -p 8984:8984 \
  -p 4006:4006 \
  -v ${HOME}/var/solrdocker2:/var/solr \
  -e SOLR_PORT=8984 \
  -e GUARDIAN_PORT=4006 \
  -e GUID=second-guid-here \
  -e LOCATION="Germany/Munich" \
  timpiltd/timpi-guardian:latest
```

Open the new ports:

```bash
sudo ufw allow 8984/tcp
sudo ufw allow 4006/tcp
```

---

## 📖 Docker Parameters Explained

| Option                     | Description                                  |
| -------------------------- | -------------------------------------------- |
| `--pull=always`            | Always use the latest Guardian image         |
| `--restart unless-stopped` | Automatically restart if system reboots      |
| `--dns`                    | Custom DNS resolvers for Timpi network       |
| `-p HOST:CONTAINER`        | Port mapping between host and container      |
| `-v`                       | Mount local storage for Solr index           |
| `-e SOLR_PORT`             | Internal Solr engine port                    |
| `-e GUARDIAN_PORT`         | Public Guardian API port                     |
| `-e GUID`                  | Your Timpi-assigned Guardian ID              |
| `-e LOCATION`              | Format: `Country/City` (used in network map) |

---

## 🙋 Support

Having trouble or want help?

* 💬 Ask in [Discord – Guardian Channel](https://discord.com/channels/946982023245992006/1179480800601849938)
* 🐛 Report bugs or suggestions: [Discord Support](https://discord.com/channels/946982023245992006/1179427377844068493)

---

## 🤝 Contribute

This is a community-powered project!
If you see improvements or want to add features to this guide:

* Fork this repo
* Submit a pull request
* Or just share feedback on Discord

---

**Built with ❤️ by the Timpi community**
Powering a truly free and private internet 🌍
