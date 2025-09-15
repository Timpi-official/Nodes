# 🔄  Timpi Collector Node
Our Collectors are decentralized “workers” crawling the web collecting information about websites and their pages. This system remains invisible from front-end services, safeguarding the security of our Collectors.





## ✅ Minimum System Requirements

* OS: Ubuntu 22.04.4 LTS (64-bit) or newer
* CPU: 2 cores
* RAM: 2 GB
* Storage: 1 GB free
* Internet: Stable & unlimited connection


### :exclamation: **Don't have Docker installed yet?**

Run these commands first:

```shell
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

**Add Docker’s GPG key:**

```shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
**Add Docker repo:**

```shell
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Then install Docker:

```shell
sudo apt update
sudo apt install docker-ce
```

**Check Docker:**

```shell
sudo systemctl status docker
```



### :rocket: **Quick Start (if Docker is already installed)**

Paste this in your terminal to install and launch Timpi Collector:

```shell
mkdir -p ~/timpi_collector_docker && cd ~/timpi_collector_docker && curl -O https://raw.githubusercontent.com/Timpi-official/Nodes/main/DockerCollector/LinuxDockerCollectorLatest.sh && mv LinuxDockerCollectorLatest.sh setup_timpi.sh && chmod +x setup_timpi.sh && ./setup_timpi.sh
```

### :brain: **Script Will Detect Your System Resources**

When the script runs, it will:

* Detect how many CPU cores and how much RAM you have
* Show suggested default values for CPU, RAM, and Swap
* Prompt you to enter your own values

Example:

```
🧠 Detected: 8 CPU cores, 16 GB RAM
💡 Default: 2 CPUs, 2g RAM, 4g Swap
```

You will be asked:

```
🛠️ How many CPUs to allocate? [Enter for default: 2]:
🛠️ RAM in GB? [Enter for default: 2]:
🛠️ Swap in GB? [Enter for default: 4]:
```

### :warning: **Important Tip!**

* Do **not** allocate 100% of your system’s CPU or RAM.
* Leave room for your operating system and background tasks.

**Recommended:** Use max 75–80% of total available resources.


---

## 🧱 Want to Run More Than One Collector?

> 🧠 You can run **multiple collectors** on the same machine using Docker – each one with its own **unique name and web port**.
> You **don’t need to change any internal config** like `appsettings.json`.

---

### 🧩 Step-by-Step to Run More Collectors

Let’s say you already have your first one running on port **5015**.

#### 🚀 To start another one on port **5016**:

```shell
sudo docker run -d \
  --name timpi_collector_5016 \
  --restart unless-stopped \
  -p 5016:5015 \
  -v /etc/localtime:/etc/localtime:ro \
  timpiltd/timpi-collector:latest
```

📌 Now access it in your browser:
**http\://<your-server-ip>:5016**

✅ Repeat with any port:

```shell
-p 5017:5015 --name timpi_collector_5017
```

Each collector still uses **port 5015 inside the container**, but Docker maps it to a new **external port**.

---

> ⚠️ **Note about multiple collectors**  
> The `Quick Start` script (`setup_timpi.sh`) is only for setting up your **first collector**.  
> To run more collectors on the same machine, you need to use the manual `sudo docker run` command shown above — using **unique names** and **different external ports** like `5016`, `5017`, etc.  
>  
> 📌 **Don’t re-run the Quick Start script for additional collectors.**

> 💡 **Customize Your Resource Limits (Optional)**  
> You can increase the values for `--cpus`, `--memory`, and `--memory-swap` depending on your system.  
> For example: `--cpus="3"` or `--memory="4g"` are valid.  
>  
> ⚠️ **Minimum required values**:
> - `--cpus="2"`
> - `--memory="2g"`
> - `--memory-swap="4g"` (recommended if you’re near your RAM limit)  
>  
> Just make sure **not to use more than 75–80%** of your total system resources to keep your server stable.


---

### ⚠️ Important Tips

* Always pick a **unique container name** (e.g., `timpi_collector_5016`, `timpi_collector_5017`)
* Always map to a **new external port**
* Don't touch `appsettings.json` — leave it at `"http_port": "5015"`

---

### 🛠 Example: 3 Collectors on One Machine

| Name                   | Docker Command | Access UI at                                   |
| ---------------------- | -------------- | ---------------------------------------------- |
| timpi\_collector       | `-p 5015:5015` | [http://localhost:5015](http://localhost:5015) |
| timpi\_collector\_5016 | `-p 5016:5015` | [http://localhost:5016](http://localhost:5016) |
| timpi\_collector\_5017 | `-p 5017:5015` | [http://localhost:5017](http://localhost:5017) |

---



### :globe_with_meridians: **Open the Web UI, paste your wallet key under settings:**

http://localhost:5015/collector


### :toolbox: **Most Useful Docker Commands for Timpi Users**


### :mag: **1. View Container Logs (Live):**

```shell
sudo docker logs -f timpi_collector
```

### :clipboard: **2. List All Running Containers:**

```shell
sudo docker ps
```

### :clipboard: **3. List All Containers (Including Stopped):**

```shell
sudo docker ps -a
```

### :arrows_counterclockwise: **4. Restart the Container:**

```shell
sudo docker restart timpi_collector
```

### :octagonal_sign: **5. Stop the Container:**

```shell
sudo docker stop timpi_collector
```

### :no_entry_sign: **6. Remove the Container:**

```shell
sudo docker rm timpi_collector
```

**:warning: Only do this if you plan to re-run it — it will be gone for good.**

### :mag: **7. Inspect Container Settings:**

```shell
sudo docker inspect timpi_collector
```

### :bulb: **8. Just Resource Limits:**

```shell
sudo docker inspect timpi_collector | grep -iE '"NanoCpus"|"Memory"|"MemorySwap"'
```

### :bar_chart: **9. Monitor Resource Usage Live:**

```shell
sudo docker stats timpi_collector
```

### :package: **10. Pull the Latest Image (If Needed):**

```shell
sudo docker pull timpiltd/timpi-collector:latest
```

## 🛠️ **Inside the Container: Important Commands**

Before accessing the container, install essential tools:

```shell
sudo docker exec -it timpi_collector /bin/bash -c "apt update && apt install -y vim nano"
```

Now, you can access the container with:

```shell
sudo docker exec -it timpi_collector bash
```

Inside the container, you can use the following commands:

* **View `timpi.config`:**

```shell
vim /opt/timpi/timpi.config
```

* **View `CollectorSettings.json`:**

```shell
vim /opt/timpi/CollectorSettings.json
```

* **Tail the logs live:**

```shell
tail -f /opt/timpi/TimpiCollectorLogs.log
```

## :fire: **Advanced Commands (Optional, for Advanced Users Only)**

### 🛠️ **View Collector Data Every 2 Seconds with jq:**

If `jq` is not installed, run:

```shell
sudo apt update && sudo apt install -y jq
```

Then, monitor key data:

```bash
sudo watch -n 2 'docker exec timpi_collector cat /opt/timpi/UIData.txt | jq -r "\"Collected/sec: \(.CollectedPerSec) | Avg/5min: \(.AvgCollectedOverFiveMin) | URLs Done: \(.CurrentURLsDone) | Core Active: \(.CoreActive)\""'
```

### 🛠️ **View Logs with More Detail:**

* To view the latest logs every 5 seconds:

```shell
sudo watch -n 5 'docker exec timpi_collector tail -n 20 /opt/timpi/TimpiCollectorLogs.log'
```

**Change Log Level to `Verbose` (No Restart Required):**

1. Open the `CollectorSettings.json` file:

```shell
sudo docker exec -it timpi_collector vim /opt/timpi/CollectorSettings.json
```

2. Locate:

```json
{
"LogLevel": "Error"
}
```

3. Change it to:

```json
{
"LogLevel": "Debug"
}
```

* **No restart is required.**
* If the container is restarted, it will reset to `Error`.

### 🛠️ **Update Wallet Key:**

To update your wallet key, open the `timpi.config` file:

```shell
sudo docker exec -it timpi_collector vim /opt/timpi/timpi.config
```

Locate and update the `Wallet` parameter:

```json
"Wallet": "YOUR_NEUTARO_WALLET_ADDRESS"
```

## :tada: **Fun Command: Timpi Monitor with ASCII Art & Colors**

For those who want to add some fun to their monitoring, run this one-liner to install some fancy tools and create a `timpi-monitor` command:

```shell
sudo apt update && sudo apt install -y ruby figlet boxes jq && sudo gem install lolcat --bindir=/usr/local/bin && echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc && source ~/.bashrc && echo -e '#!/bin/bash\n\nclear\nfiglet -f slant "Timpi Monitor" | lolcat -a -d 2 -F 0.8\n\n# Header Separator\necho -e "\n\e[1;36m===================== TIMPI CONFIG =====================\e[0m" | lolcat -F 0.8;\n\nwhile true; do\n tput cup 10 0\n sudo docker exec timpi_collector cat /opt/timpi/timpi.config | jq -r "{\"NumberClients\": .NumberClients, \"ConnectionsPerServer\": .ConnectionsPerServer, \"HostProd\": .HostProd, \"Coordinator\": .Coordinator, \"NFTName\": .NFTName}" | boxes -d stone | lolcat -F 0.8;\n\n # Space between sections\n tput cup 20 0\n echo -e "\n\e[1;36m===================== LIVE STATS =====================\e[0m" | lolcat -F 0.8;\n\n # Data Block for Live Stats\n tput cup 22 0\n sudo docker exec timpi_collector cat /opt/timpi/UIData.txt | jq -r "\"Collected/sec: \(.CollectedPerSec) | Avg/5min: \(.AvgCollectedOverFiveMin) | URLs Done: \(.CurrentURLsDone) | Core Active: \(.CoreActive)\"" | boxes -d stone | lolcat -F 0.8;\n\n sleep 2\ndone' | sudo tee /usr/local/bin/timpi-monitor > /dev/null && sudo chmod +x /usr/local/bin/timpi-monitor
```

Now, you can run the fun command anytime with:

```shell
timpi-monitor
```
