*Only Support · For Native Windows 10/11*

# Windows 10/11

0.9.5-C

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
   - Go to settings and paste your wallet addresss
   - Can take up to 15 minutes before getting Key:  **Available**
