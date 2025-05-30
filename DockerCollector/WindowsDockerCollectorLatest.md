*Only Support · For Native Windows 10/11*

** 🚀Quick Start (if Docker is already installed)**
Paste this in Powershell to install and launch Timpi Collector:
```shell
docker run -d `
--name timpi_collector `
--restart unless-stopped `
--init `
--ulimit nofile=65536:65536 `
--cpus="2" `
--memory="2g" `
--memory-swap="4g" `
-e TZ=UTC `
-p 5015:5015 `
timpiltd/timpi-collector:latest

```
**⚠️ Important Tip!**
Do not allocate 100% of your system’s CPU or RAM.
**Recommended:** Use max 75–80% of total available resources.

⚙️ Why these limits?
Adjust how much CPU and memory the container can use:

✅ `` --cpus="2"`` – Limits the container to 2 logical CPU cores
✅ ``--memory="2g"`` – Allows up to 2 GB RAM
✅ ``--memory-swap="4g"`` – Adds 2 GB swap if RAM runs out (total = 2g RAM + 2g swap)

⚙️ You can change these values to match your system’s capacity.

# ❗ Don't have Docker installed yet?
Follow this guide first:

## **WSL2 + Docker Setup in Windows 10/11 VM on Proxmox**
*A step-by-step guide for running Docker natively in WSL2 inside a Windows VM*

### **Step 0: Enable Virtualization in BIOS (Important!)**

Before doing anything in Windows or Proxmox, make sure **virtualization is enabled** in your BIOS/UEFI.

1. **Restart your PC / VM Host** and enter BIOS by pressing the right key (usually `DEL`, `F2`, `F10`, or `ESC`).
2. Go to **Advanced Settings** or **CPU Configuration**.
3. Look for **Intel VT-x**, **AMD-V**, or **SVM Mode** (for AMD).
4. Set it to **Enabled**.
5. Save and exit (usually **F10**).
6. After boot, check it's enabled:
   - Press **Ctrl+Shift+Esc** → go to **Performance** tab → Select **CPU** → Make sure **Virtualization = Enabled**

> **Bonus tip for Windows 11 users**:  
Go to **Settings > System > Recovery > Advanced Startup > Restart Now** →  
Select **UEFI Firmware Settings** to access BIOS from inside Windows.  
Make sure **Hyper-V** is also enabled if needed.

```markdown
Step 1: Prep the Proxmox VM
> Skip this if not using Proxmox.

1. Shut down your **Windows 10/11 VM** in Proxmox.
2. In **Proxmox → Hardware → CPU**, change **Type** to: `host`
3. Start the VM again.
```

### **Step 2: Enable WSL + Virtual Machine Platform**

1. Open **"Turn Windows features on or off"**
2. Enable these:
   - ✅ **Virtual Machine Platform**
   - ✅ **Windows Subsystem for Linux**
3. Click OK → Reboot when prompted.

### **Step 3: Install WSL2 Kernel and Set Default**

1. Open **PowerShell as Admin** and run:
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   ```
2. Reboot again.
3. Download and install:
   [WSL2 Kernel Update (MSI)](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)
4. Open **CMD** and run:
   ```shell
   wsl --update
   wsl --set-default-version 2
   ```

### **Step 4: Install Ubuntu 24.04 in WSL**

1. Download Ubuntu 24.04:
   [Ubuntu 24.04 AppxBundle](https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2404-240425.AppxBundle)
2. Rename it:  
   `Ubuntu2404-240425.AppxBundle` → `Ubuntu2404-240425.zip`
3. Extract it. Then rename:
   `Ubuntu_2404.0.5.0_x64.appx` → `Ubuntu_2404.0.5.0_x64.zip`  
   → Extract again to `D:\WSL\Ubuntu_2404`
4. Run `ubuntu2404.exe`. Click **More Info > Run Anyway** if SmartScreen appears.
5. Create your Linux username and password when prompted.

### **Step 5: Confirm WSL is Working**

In CMD, check:
```shell
wsl -l -v
```
You should see:
```
Ubuntu-24.04      Running      2
```

### **Step 6: Install Docker in Ubuntu WSL2**

Paste these line by line in WSL terminal:
```shell
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Add Docker repo:
```shell
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Update & install:
```shell
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### **Step 7: Run Test Container**

```shell
sudo docker run hello-world
```

If you see a success message, **Docker is working inside WSL2!**

### Download Docker Desktop for Windows 10/11
https://www.docker.com/

### 💡 Set up your Global and why`.wslconfig`?

Setting a `.wslconfig` file helps **optimize performance** when running Docker on Windows using WSL 2.

Without it, WSL might:
- Use **too much memory** without releasing it 🧠  
- Run with **default CPU and RAM limits** (which may be too low) ⚠️

With it, you **control** how much:
- RAM (`memory`)
- CPU cores (`processors`)
- Swap space (`swap`)

And enable:
- `autoMemoryReclaim` 🧹 – releases unused memory back to Windows

### 🛠️ Quick setup

1. **Open Notepad**  
   Paste this or any value you want:

   ```ini
   [wsl2]
   memory=2GB
   processors=2
   swap=4GB

   [experimental]
   autoMemoryReclaim=dropCache
   ```

2. **Save as**  
   `C:\Users\<YourUsername>\.wslconfig`  
   *(Make sure it's not `.txt`)*

3. **Restart**  

### 🧠 Difference between `.wslconfig` and Docker limits:

- **`.wslconfig`** = Sets **global limits** for all WSL2/Docker use (CPU, RAM, swap)
- **`--cpus` / `--memory`** = Sets **per-container limits**

> ✅ Set `.wslconfig` to give WSL enough power  
> ✅ Use Docker flags to control how much each container uses

✅ Done! WSL will now respect these limits every time it runs — keeping Docker smoother and more stable 💪
