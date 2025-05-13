*Only Support · For Native Ubuntu +22.04.4 LTS*

## :wastebasket: Remove Previous Guardian container before running anything below :warning: 
Here's a brief text to include at the start:

Before proceeding, ensure you remove the previous Guardian container & image to prevent conflicts:

```shell
sudo docker rm -f $(sudo docker ps -aq --filter "ancestor=timpiltd/timpi-guardian")
```
```shell
sudo docker rmi -f $(sudo docker images timpiltd/timpi-guardian -q)
```


## :rocket: Quick Start (if Docker is already installed)

Paste this in your terminal to install and launch Timpi Guardian:
```shell
bash <(curl -fsSL https://raw.githubusercontent.com/Timpi-official/Nodes/main/Guardian/TimpiGuardianLatest.sh)
```

# :exclamation: Don't have Docker installed yet?
Follow this guide first:

### :bricks: Step 1 — Install Docker & Java

**1. Update system packages:**
```shell
sudo apt update
```

**2. Install required dependencies:**
```shell
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

**3. Add Docker’s GPG key:**
```shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

**4. Add Docker’s repository:**
```shell
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

**5. Update package list again:**
```shell
sudo apt update
```

**6. (Optional) Check Docker repo source:**
```shell
apt-cache policy docker-ce
```

**7. Install Java:**
```shell
sudo apt install default-jre
```

**8. Install Docker:**
```shell
sudo apt install docker-ce
```

**9. Confirm Docker is running:**
```shell
sudo systemctl status docker
```



### :floppy_disk: Step 2 — Prepare Guardian Data Folder

Create a persistent folder to store the Guardian's Solr database:

```shell
sudo mkdir -p ${HOME}/var/solrdocker
```

> :warning: **You need at least 1 TB of free disk space**.  
> This folder must remain intact between reboots and updates.

### :rocket: Step 3 — Start Your Guardian Manually

Use the following Docker command to run your Guardian node:

```shell
sudo docker run --pull=always --restart unless-stopped --dns=100.42.180.116 --dns=212.28.186.105 --dns=8.8.8.8 -d -p [SOLR_PORT]:[SOLR_PORT] -p [GUARDIAN_PORT]:[GUARDIAN_PORT] -v ${HOME}/var/solrdocker:/var/solr -e SOLR_PORT=[SOLR_PORT] -e GUARDIAN_PORT=[GUARDIAN_PORT] -e GUID=[YOUR_GUID] -e LOCATION="[COUNTRY]/[CITY]" timpiltd/timpi-guardian:latest
```

### :brain: Explanation of Each Part

| Parameter          | Description |
|-------------------|-------------|
| `--pull=always`   | Always pull the latest version of the image |
| `--restart unless-stopped` | Restart automatically on reboot or crash |
| `--dns`           | Custom DNS for TAP communication |
| `-p`              | Port forwarding (external to internal) |
| `-v`              | Mounts your persistent storage |
| `-e SOLR_PORT`    | Port used by internal Solr search engine |
| `-e GUARDIAN_PORT`| Port for Guardian TAP communication |
| `-e GUID`         | Your unique Guardian ID (from Timpi dashboard) |
| `-e LOCATION`     | Format: `Country/City` (e.g., `SWEDEN/Stockholm`) |


### :arrows_counterclockwise: Use Custom Ports

You can use any available ports on your system.

**Example using custom ports:**
```shell
sudo docker run --pull=always --restart unless-stopped --dns=100.42.180.116 --dns=212.28.186.105 --dns=8.8.8.8 -d -p 9090:9090 -p 5000:5000 -v ${HOME}/var/solrdocker:/var/solr -e SOLR_PORT=9090 -e GUARDIAN_PORT=5000 -e GUID=your-guid-here -e LOCATION="Sweden/Stockholm" timpiltd/timpi-guardian:latest
```

> :brain: **Note**: Both the `-p` and `-e` variables must match your chosen ports.



### :closed_lock_with_key: Step 4 — Open Ports in Firewall

If you're using `UFW` (Uncomplicated Firewall), open your selected ports like so:

```shell
# Default port example
sudo ufw allow 8983/tcp
sudo ufw allow 4005/tcp

# Custom port example
sudo ufw allow 9090/tcp
sudo ufw allow 5000/tcp
```

### :white_check_mark: You're Done!

Your Guardian node is now up and running.

### :page_facing_up: Step 5 — View Guardian Logs (Optional)

```shell
sudo docker ps       # Shows running containers
sudo docker logs [container_id]  # Check logs for Guardian
```

All logs from your Guardian Node are stored inside the persistent data folder:

```shell
cd ${HOME}/var/solrdocker/data/
```

Each log file is timestamped by date:
```
guardian-logYYYYMMDD.txt
```

### :clipboard: Example:
```shell
/var/solrdocker/data/guardian-log20250422.txt
```

### :tv: To view the most recent log:
```shell
ls -t ${HOME}/var/solrdocker/data/guardian-log*.txt | head -n 1 | xargs tail -f
```

This will **automatically open the latest log file** and stream new entries live.

### :package: To view logs for a specific day:
```shell
cat ${HOME}/var/solrdocker/data/guardian-log20250421.txt
```
> :brain: These logs persist even after reboots or updates, so you can track issues or performance over time.

For support, ask in the [Guardian support channel](https://discord.com/channels/946982023245992006/1179480800601849938).
