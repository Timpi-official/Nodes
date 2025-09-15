
# 🔄 Timpi Collector Node (v0.10.0-A)

Our Collectors are decentralized “workers” crawling the web to collect page data. They’re isolated from front-end services to protect network security.

## ✅ Minimum System Requirements

* **OS:** Ubuntu 22.04.4 LTS (64-bit) or newer
* **CPU:** 2 cores (4+ logical cores recommended)
* **RAM:** 2 GB (4 GB+ recommended)
* **Storage:** 1 GB free
* **Internet:** Stable, **unmetered** connection

---

## 🐳 Install Docker (if you don’t have it yet)

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
 | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
 | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable & start Docker
sudo systemctl enable --now docker

# (Optional) Let your user run docker without sudo — log out/in after this
sudo usermod -aG docker $USER

# Verify
docker --version
sudo systemctl status docker --no-pager
```

---

## 🚀 Quick Start (single collector)

**Pull the exact image tag** and run one collector on port **5015**:

```bash
docker pull timpiltd/timpi-collector:0.10.0-A

sudo docker run -d \
  --name timpi_collector \
  --restart unless-stopped \
  -v /etc/localtime:/etc/localtime:ro \
  -p 5015:5015 \
  timpiltd/timpi-collector:0.10.0-A
```

Open the UI: `http://<your-server-ip>:5015/collector`
Go to **Settings → Wallet**, paste your **Neutaro wallet**, then set **Workers & Threads** (see sizing tips below).




## ➕ Run Multiple Collectors on One Machine

Just repeat `docker run` with a **unique name** and a **new external port**.
*(All containers keep using internal 5015; Docker maps your chosen outside port → 5015)*

Example second instance on **5016**:

```bash
sudo docker run -d \
  --name timpi_collector_5016 \
  --restart unless-stopped \
  -v /etc/localtime:/etc/localtime:ro \
  -p 5016:5015 \
  timpiltd/timpi-collector:0.10.0-A
```

UI: `http://<ip>:5016/collector`

---

## 🌐 Open the Web UI & Set Your Wallet

* Go to: `http://<ip>:<port>/collector`
* **Settings → Wallet**: paste your Neutaro wallet
* **Performance**: set **Workers** & **Threads**

  * Rule of thumb: keep **threads × workers** aligned with your **logical cores** (use \~70–80% max) and your **bandwidth** capacity.

---

## 🧰 Useful Docker Commands

```bash
# Live logs
sudo docker logs -f timpi_collector

# Running containers
sudo docker ps

# All containers
sudo docker ps -a

# Restart / Stop / Remove
sudo docker restart timpi_collector
sudo docker stop timpi_collector
sudo docker rm timpi_collector

# Inspect (resources)
sudo docker inspect timpi_collector | grep -iE '"NanoCpus"|"Memory"|"MemorySwap"'

# Live resource usage
sudo docker stats timpi_collector

# Pull this exact version later (for a new node or host)
docker pull timpiltd/timpi-collector:0.10.0-A
```

---

## 🛠 Inside the Container (optional)

```bash
# Enter shell
sudo docker exec -it timpi_collector bash

# Tail logs
tail -f /opt/timpi/TimpiCollectorLogs.log

# View runtime UI metrics (requires jq on host)
sudo watch -n 2 'docker exec timpi_collector cat /opt/timpi/UIData.txt \
 | jq -r "\"Collected/sec: \(.CollectedPerSec) | Avg/5min: \(.AvgCollectedOverFiveMin) | URLs Done: \(.CurrentURLsDone) | Core Active: \(.CoreActive)\""'
```

> Note: Some images may not include editors by default. If needed:
> `sudo docker exec -it timpi_collector bash -lc "apt update && apt install -y vim nano"`

---

## 🧠 Sizing: CPU (logical vs physical) & Bandwidth (quick refresher)

* **Logical cores** include Hyper-Threading/SMT (virtual cores).
  That’s the number to think about for parallel work.
* Keep total **threads × workers** to \~70–80% of logical cores.
* **Bandwidth matters**: more workers = more downloading/uploading.

  * <20 Mbps → 2–3 workers per thread
  * 50–100 Mbps → 3–4 workers per thread
  * 250+ Mbps → 5–6 workers per thread
  * Gigabit/server → up to 10 workers per thread (if CPU allows)

