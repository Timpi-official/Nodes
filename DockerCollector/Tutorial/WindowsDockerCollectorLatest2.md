# 🧊 Timpi Collector Setup (Windows 10 & 11)

🔧 With login fix, file extension warning, and Docker verification.

---

## ✅ Step 1: Enable Virtualization in BIOS

1. Restart your PC

2. Enter BIOS (`DEL`, `F2`, `ESC`, or `F10`)

3. Enable virtualization:

   * **Intel**: `Intel VT-x`
   * **AMD**: `SVM Mode` or `AMD-V`

4. Save & Exit (usually `F10`)

🧪 **Verify after boot**:
Press `Ctrl + Shift + Esc` → Go to **Performance > CPU**
Check for:

```
Virtualization: Enabled
```

---

## 💡 Bonus Tip (Windows 11 Only)

You can enter BIOS without restarting manually:

> **Settings > System > Recovery > Advanced Startup > Restart Now**
> → **Troubleshoot > Advanced Options > UEFI Firmware Settings**

---

## ✅ Step 2: Enable Required Windows Features

1. Open `Turn Windows features on or off`

2. Enable:

   * ✅ Windows Subsystem for Linux
   * ✅ Virtual Machine Platform
   * ✅ Hyper-V

3. Click **OK** and reboot when prompted

---

## ✅ Step 3: Install Docker Desktop

1. Download:
   🔗 [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)

2. Install with default settings:

   * ✅ WSL2 backend
   * ✅ Hyper-V

3. Reboot after installation

---

## ✅ Step 4: Fix File Extensions Setting (IMPORTANT for .wslconfig)

To correctly save `.wslconfig`, ensure Windows shows file extensions:

1. Press `Windows Key + E` to open File Explorer
2. Click **View > Options**
3. Under **View tab**:

   * ❌ Uncheck **“Hide extensions for known file types”**
4. Click **Apply > OK**

---

## ✅ Step 5: Create `.wslconfig` (Required for Stability)

1. Open **Notepad**

2. Paste:

   ```ini
   [wsl2]
   memory=2GB
   processors=2
   swap=3GB
   localhostForwarding=true
   pageReporting=true
   nestedVirtualization=false
   debugConsole=false

   [experimental]
   autoMemoryReclaim=dropCache
   sparseVhd=true
   ```

3. Save as:

   ```
   C:\Users\<YourUsername>\.wslconfig
   ```

   ⚠️ It must be named exactly `.wslconfig` (with no `.txt` at the end).

4. Reboot your PC again

---

## ✅ Step 6: Log In to Docker Hub (Required)

Windows users **must log in to Docker Hub** via CLI or GUI.

### 🧭 Method A: Login via Docker Desktop (GUI)

1. Open Docker Desktop
2. Click your profile icon (top-right)
3. Sign in with your Docker Hub account

   * Or create one: [https://hub.docker.com/signup](https://hub.docker.com/signup)

### 🧭 Method B: Login via PowerShell (RECOMMENDED)

```powershell
docker login
```

It will prompt:

```
Username: <your Docker Hub username>
Password: <your password>
```

✅ After successful login, you will see:

```
Login Succeeded
```

> 🔐 This prevents the error: `401 Unauthorized – failed to fetch oauth token`

---

## ✅ Step 7: Verify Docker Works

Run the official Docker test image:

```powershell
docker run hello-world
```

If successful, you will see:

> **Hello from Docker!**

📸 Expected output:

*Hello from Docker*

---

## ✅ Step 8: Run Timpi Collector

Paste this into **PowerShell**:

```powershell
docker run -d `
--name timpi_collector `
--restart unless-stopped `
--ulimit nofile=65536:65536 `
--cpus="2" `
--memory="2g" `
--memory-swap="4g" `
-p 5015:5015 `
timpiltd/timpi-collector:latest
```

🌐 Visit:

```
http://localhost:5015/collector
```

---

## 🧯 Common Issues & Fixes

| Error                    | Fix                                                             |
| ------------------------ | --------------------------------------------------------------- |
| `401 Unauthorized`       | Run `docker login` in PowerShell                                |
| `.wslconfig` not working | Uncheck “Hide extensions for known file types” in File Explorer |
| `Unable to find image`   | Ensure you're signed into Docker                                |
| UI not loading           | Wait 30–60 seconds after container starts                       |

---
