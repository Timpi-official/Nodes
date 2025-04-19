# Here you will find all the different Linux and Windows versions for the collector. 
We will also include installation scripts / instructions.

# Linux Ubuntu +22.04.4 LTS

0.9.5
https://timpi.io/applications/linux/TimpiCollectorLinuxLatest.rar

### Only Support for Ubuntu +22.04.4 LTS

Setup the Timpi Collector on your Linux system with this one-command installation. This  install version 0.9.5-C of the Collector and then automatically upgrade it, overwriting any previous files.

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


# Windows 10/11

0.9.5
https://timpi.io/applications/windows/TimpiCollectorWindowsLatest.rar


## 🌟 **How to Install Timpi Collector on Windows**

### 🔹 **Automated Installation (Recommended)**
Run the following command directly in your **PowerShell (as Administrator)**:

```powershell
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Timpi-official/Nodes/main/Collector/TimpiCollectorWindowsLatest.bat' -OutFile 'TimpiCollectorWindowsLatest.bat'; Start-Process -FilePath 'TimpiCollectorWindowsLatest.bat' -Verb RunAs"
```

### 🔹 **Manual Installation (If the above method fails)**

1. **📥 Download the Installer File**  
   Click the link below to download the installer file:  
   👉 Download the .Bat installer:

   link: https://raw.githubusercontent.com/Timpi-official/Nodes/main/Collector/TimpiCollectorWindowsLatest.bat
   

3. **📂 Run the Installer as Administrator**  
   - **Right-click** on the downloaded `.bat` file and select **“Run as Administrator”**.  
   - This is necessary for installing services and creating shortcuts on your system.

4. **🛠️ Follow the Installation Process**  
   The script will automatically:
   - ✅ **Check for 7-Zip** and install it if necessary.  
   - ✅ **Download the latest Timpi Collector files**.  
   - ✅ **Extract and move files** to: `C:\Program Files\Timpi Intl. LTD`  
   - ✅ **Set required permissions** for the installation folder.  
   - ✅ **Create and start the Timpi Collector Service**.  
   - ✅ **Create a Desktop Shortcut** for `TimpiManager.exe`.

5. **🎉 Complete Installation**  
   - When the installation finishes, you will see a success message
   - **Press any key** to exit the installer.

6. **📊 Open the Timpi Dashboard**  
   - Double-click the **Desktop Shortcut** to launch `TimpiManager.exe`.  
   - Visit the dashboard at: **http://localhost:5015/collector**
