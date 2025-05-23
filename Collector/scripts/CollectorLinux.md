*Only Support for Ubuntu +22.04.4 LTS*

# Here you will find all the latest Linux version for the collector. 
We will also include installation scripts / instructions.

# Linux Ubuntu +22.04.4 LTS
0.9.5-C

https://timpi.io/applications/linux/TimpiCollectorLinuxLatest.rar

### Setup the Timpi Collector on your Linux system with this one-command installation. This  install version 0.9.5-C of the Collector and then automatically upgrade it, overwriting any previous files.

**Command to run:**
```shell
sudo apt-get install -y dos2unix curl && sudo curl -o Automated_collector_script.sh https://raw.githubusercontent.com/Timpi-official/Nodes/main/Collector/Automated_collector_script.sh && sudo dos2unix Automated_collector_script.sh && bash Automated_collector_script.sh
```

## Important Remove config file
```shell
sudo systemctl stop collector; sudo rm -f /opt/timpi/timpi.config; sudo systemctl start collector
```

**Here's what happens:**
1. **Prepares your system**: Installs `dos2unix` to ensure script compatibility.
2. **Downloads and runs the setup script**: Fetches the latest setup script and executes it to install and configure the Timpi Collector.
3. **Automatic upgrade**: Upgrades the installation to version 0.9.5-C, seamlessly overwriting previous installation files to ensure you're up-to-date.

**After installation:**
- Open your browser and visit http://localhost:5015/collector to access the Timpi Collector interface.

**Collector Commands:**
- **View live status**: `sudo journalctl -fu collector -o cat`
- **Start the collector**: `sudo systemctl start collector`
- **Stop the collector**: `sudo systemctl stop collector`
- **Restart the collector**: `sudo systemctl restart collector`
- **Restart the UI**: `sudo systemctl restart collector_ui`

- Check the status of the collector and UI using `sudo systemctl status collector` and `sudo systemctl status collector_ui`.

Just copy, paste, and press Enter


**Here´s a removal command:**
```shell
sudo systemctl stop collector collector_ui || true; sudo systemctl disable collector collector_ui || true; sudo rm -rf /opt/timpi; sudo apt-get purge -y dos2unix; sudo apt-get autoremove -y; echo "Collector and dos2unix have been removed successfully."
```

---
# Linux Collector Manual Guide
### **Quick Guide Ubuntu 22.04: Installing Timpi Collector 0.9.5-C**

### **Step 1: Remove Old Version**
```shell
echo "Stopping old collector services (if running)..."
sudo systemctl stop collector && echo "Stopped collector" || echo "Collector was not running"
sudo systemctl stop collector_ui && echo "Stopped collector_ui" || echo "Collector UI was not running"

echo "Removing old installation (if exists)..."
sudo rm -rf /opt/timpi && echo "Old /opt/timpi removed" || echo "No existing /opt/timpi folder found"
```

### **Step 2: Update System**
```shell
sudo apt update && sudo apt -y upgrade
```

### **Step 3: Create Installation Folder**
```shell
sudo mkdir -p /opt/timpi
```

### **Step 4: Install Unrar**
```shell
sudo apt install -y unrar
```

### **Step 5: Download Collector**
```shell
sudo wget https://timpi.io/applications/linux/TimpiCollectorLinuxLatest.rar -O /opt/timpi/TimpiCollectorLinuxLatest.rar
```

### **Step 6: Extract Files**
```shell
cd /opt/timpi
sudo unrar x -y /opt/timpi/TimpiCollectorLinuxLatest.rar
```

### **Step 7: Move Files (if needed)**
```shell
if [ -d "/opt/timpi/TimpiCollectorLinuxLatest" ]; then
    sudo mv /opt/timpi/TimpiCollectorLinuxLatest/* /opt/timpi
    sudo rm -rf /opt/timpi/TimpiCollectorLinuxLatest
fi
```

### **Step 8: Set Permissions**
```shell
sudo chmod 755 /opt/timpi/TimpiCollector
sudo chmod 755 /opt/timpi/TimpiUI
```

### **Step 9: Create Collector Service**
```shell
sudo nano /etc/systemd/system/collector.service
```
Paste this:
```
[Unit]
Description=Timpi Collector Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/timpi
ExecStart=/opt/timpi/TimpiCollector
Restart=always

[Install]
WantedBy=multi-user.target
```

### **Step 10: Create UI Service**
```shell
sudo nano /etc/systemd/system/collector_ui.service
```
Paste this:
```
[Unit]
Description=Timpi Collector UI Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/timpi
ExecStart=/opt/timpi/TimpiUI
Restart=always

[Install]
WantedBy=multi-user.target
```

### **Step 11: Cleanup**
```shell
sudo rm -rf /opt/timpi/TimpiCollectorLinuxLatest.rar
```

### **Step 12: Reload & Enable Services**
```shell
sudo systemctl daemon-reload
sudo systemctl enable collector
sudo systemctl enable collector_ui
```

### **Step 13: Start Services**
```shell
sudo systemctl start collector
sudo systemctl start collector_ui
```

### **Step 14: Check Status**
```shell
sudo systemctl status collector
sudo systemctl status collector_ui
```

### **Step 15: Access UI**
Open browser:  
```
http://localhost:5015/collector
```

### **Troubleshoot**
```shell
sudo rm /opt/timpi/timpi.config
sudo systemctl restart collector
sudo systemctl restart collector_ui
```

### **Uninstall**
```shell
sudo systemctl stop collector
sudo systemctl stop collector_ui
sudo systemctl disable collector
sudo systemctl disable collector_ui
sudo rm -rf /opt/timpi
sudo rm /etc/systemd/system/collector.service
sudo rm /etc/systemd/system/collector_ui.service
sudo systemctl daemon-reload
```
