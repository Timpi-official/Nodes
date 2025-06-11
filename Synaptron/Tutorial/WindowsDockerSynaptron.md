# 🧊 Timpi Synaptron Setup (Windows 10 & 11)

💪 With NVIDIA GPU support, login fix, `.wslconfig` config, and Windows Firewall instructions.

---

### 🧪 Optional Pre-check: See if Virtualization is Already Enabled

1. Press `Ctrl + Shift + Esc` to open **Task Manager**
2. Go to the **Performance > CPU** tab
3. Look for:

```
Virtualization: Enabled
```
![452623933-cb2b34cd-9621-464c-9248-50c2576aed0c](https://github.com/user-attachments/assets/30015fbd-b5ab-44af-9988-e7435c99a618)


✅ If it says `Enabled`, you can **skip the BIOS step**.

---

## ✅ Step 1: Enable Virtualization in BIOS

1. Restart your PC
2. Enter BIOS (`DEL`, `F2`, `ESC`, or `F10`)
3. Enable virtualization:

   * **Intel**: `Intel VT-x`
   * **AMD**: `SVM Mode` or `AMD-V`
4. Save & Exit (`F10`)

---

## 💡 Bonus Tip (Windows 11 Only)

To enter BIOS without restarting:

> **Settings > System > Recovery > Advanced Startup > Restart Now**
> → **Troubleshoot > Advanced Options > UEFI Firmware Settings**

---

## ✅ Step 2: Enable Required Windows Features

1. Open **Turn Windows features on or off**

2. Enable:

   * ✅ Windows Subsystem for Linux
   * ✅ Virtual Machine Platform
   * ✅ Hyper-V

   ![Windows Features](https://github.com/user-attachments/assets/176eab1d-17d8-4da5-a525-aac199b23b08)

3. Reboot when prompted

---

## ✅ Step 3: Install Docker Desktop

1. Download from:
   🔗 [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)

2. Install with only WSL2 backend and Hyper-V:

   * ✅ WSL2 backend
   * ✅ Hyper-V

3. Reboot after installation

---

## ✅ Step 4: Fix File Extensions (.wslconfig)

1. Open File Explorer (`Windows Key + E`)
2. Go to **View > Options > View tab**
3. ❌ Uncheck “**Hide extensions for known file types**”
4. Click **Apply > OK**

   ![Show Extensions](https://github.com/user-attachments/assets/51fe4bdf-cf9a-4d46-ad5f-1bcacaa6fd9c)

---

## ✅ Step 5: Create `.wslconfig` (Required for Synaptron Stability)

1. Open Notepad

2. Paste this config:

   ```ini
   [wsl2]
   memory=12GB
   processors=4
   swap=4GB
   localhostForwarding=true
   pageReporting=true
   nestedVirtualization=false
   debugConsole=false

   [experimental]
   autoMemoryReclaim=dropCache
   sparseVhd=true
   ```

3. Save as:
   
![452798022-bc396c3c-52c8-45aa-8e60-58841d157fe3](https://github.com/user-attachments/assets/475bfbfa-3b29-4588-8977-0cfceec993ee)

   ```
   C:\Users\YourUsername\.wslconfig
   ```

⚠️ Make sure it's exactly `.wslconfig`, not `.wslconfig.txt`

4. Reboot your PC again

---

## ✅ Step 6: Log In to Docker Hub

### A. Login via Docker Desktop GUI

1. Open Docker Desktop
2. Click your profile icon (top-right)

![Docker GUI Login](https://github.com/user-attachments/assets/698631b4-9ae5-4d2a-b006-7c25adbc347e)
   
4. Sign in using your Docker Hub account

![452798940-623d283a-2fb1-4b05-b64b-894733bf5ec6](https://github.com/user-attachments/assets/4e10ba22-7525-4592-898f-b13bcb854407)

![452798948-4d3186a8-2555-409e-b1c7-a34867af491f](https://github.com/user-attachments/assets/12a988fb-1bd3-4083-87db-3cc6f7d0cceb)


🔐 [Create Docker Hub Account](https://hub.docker.com/signup)

---

### B. Login via PowerShell (Required)

1. Open powershell run as administrator by right click on it

Login via webbrowser:
```powershell
docker login
```

Follow the prompts:

![452798400-88b59694-71c8-4806-8a5b-4ce12b06a270](https://github.com/user-attachments/assets/4d28c7bf-1710-47b6-b861-ae3dab4b58d8)

Login via powershell
```powershell
docker login -u username
```
It will promt:
```
Password: <your-password>
```

✅ You should see:

```
Login Succeeded
```
![452798578-203d3db9-83c4-4382-9fd2-aa26e2f509cf](https://github.com/user-attachments/assets/65dd89fe-3cad-4da6-ad71-019b91cdc4a4)

> 🔐 This prevents the error: `401 Unauthorized – failed to fetch oauth token`

---

## ✅ Step 7: Verify Docker is Working

Test Docker installation:

```powershell
docker run hello-world
```

You should see:

```
Hello from Docker!
```

![452619501-62aeca8f-fe3f-44c4-83e4-19920cc3ba66](https://github.com/user-attachments/assets/f5e2834c-6b08-4a03-801f-5d31ad7a4835)

---

## ✅ Step 8: Run Timpi Synaptron (Docker)

Paste this in **PowerShell**:

```powershell
docker run -d --name timpi_synaptron --restart unless-stopped --cpus="4" --memory="12g" --memory-swap="16g" --gpus all -e NAME="YourNodeNameHere_Min17Characters" -e GUID="YOUR-GUID" timpiltd/timpi-synaptron:latest
```

🔁 The container will take \~30-50 minutes to fully download required models.

---

## 🧱 Windows Defender Firewall Prompt

Allow Docker access when prompted:

1. ✅ **Private networks**
2. ❌ Public networks (optional)

> Fix later via:
> `Control Panel > Firewall > Allow app through Firewall` → Enable for Docker Desktop (Private)

![Screenshot 2025-06-11 195853](https://github.com/user-attachments/assets/aa147943-3f38-4ebc-8100-1bcd83413fd1)


---

## 📊 Monitor Your Synaptron
Run These Commands In Powershell

| Task                       | Command                          |
| -------------------------- | -------------------------------- |
| 🟢 Show running containers | `docker ps`                      |
| 🔁 View logs live          | `docker logs -f timpi_synaptron` |
| ❌ Stop Synaptron           | `docker stop timpi_synaptron`    |
| 🔄 Restart Synaptron       | `docker start timpi_synaptron`   |
| 🧹 Remove container        | `docker rm timpi_synaptron`      |

---

## 🧯 Common Issues & Fixes

| Error                    | Fix                                                           |
| ------------------------ | ------------------------------------------------------------- |
| `401 Unauthorized`       | Run `docker login` again in PowerShell                        |
| `.wslconfig` not working | Uncheck "Hide extensions for known file types"                |
| `Unable to find image`   | Make sure you're logged into Docker Hub                       |
| Synaptron not using GPU  | Ensure your NVIDIA drivers are up to date + Docker has access |

---
