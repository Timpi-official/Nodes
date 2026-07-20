# 🌐 Timpi Collector Node for Windows 10 & 11 (v2)

> ## ⏳ Coming soon — do not install from this page yet
>
> The Windows Collector download has not been rebuilt since **10 November 2025** and cannot reach the
> current node version, so a node installed from it will not qualify for rewards. A new Windows build
> is on the way.
>
> ⚠️ The file named `...-v2.rar` is **not** version 2 — the "v2" refers to the packaging and it dates
> from November too.
>
> **Run the Collector in Docker for now** — [Linux (Docker)](LinuxDocker.md). Your GUID stays the same.
>
> The steps below are kept for reference and will be updated when the new build ships.


### The Timpi Collector is part of the decentralized Timpi search network — it crawls and indexes the web, helping to build the world’s first community-powered search engine.

By running a Collector, you help Timpi grow its decentralized data network — privately, securely, and without ads or tracking.

---

<img width="1024" height="576" alt="TimpiCollector" src="https://github.com/user-attachments/assets/8dcd810f-fa30-4912-ac11-c63417ec15bc" />

---

### 📑 Table of Contents

* [Installation Guide](#-installation-guide)

  * [1. Download the Installer](#-1-download-the-installer)
  * [2. Run the Installer](#-2-run-the-installer)
  * [3. What the Installer Does Automatically](#-3-what-the-installer-does-automatically)
* [Using Timpi Collector](#-using-timpi-collector)

  * [4. Viewing Collector Logs](#-4-viewing-collector-logs)
  * [5. Checking for Updates (Auto-Updater)](#-5-checking-for-updates-auto-updater)
  * [How to Start, Restart, or Stop the Collector Service](#-how-to-start-restart-or-stop-the-collector-service)
  * [6. Access the Management Dashboard](#-6-access-the-management-dashboard)
  * [7. Register or Retrieve Your GUID](#-7-register-or-retrieve-your-guid)
* [Uninstallation Guide](#-uninstallation-guide)

  * [Method 1 – Apps & Features](#-method-1--apps--features)
  * [Method 2 – Control Panel](#-method-2--control-panel)


---

> ⚠️ **Support Policy**
>
> Timpi officially supports installations on **Windows 10/11**, **native Linux (Ubuntu)**, and **Docker running on native Linux**.  
>  
> Other environments — including **Proxmox**, **LXC containers**, **nested virtualization**, or **emulated systems** — are considered **unsupported**.  
>  
> You are free to experiment with these setups, but please note that **technical support and helpdesk tickets are only available for supported platforms**.  
> For the best performance and reliability, always use a fully supported operating system.

---

**Version:** `v2`

📦 **Installer type:** Native `.exe` (Windows Program)

🔗 **Download:** [TimpiCollectorWindowsLatest-v2.rar](https://timpi.io/applications/windows/TimpiCollectorWindowsLatest-v2.rar)

---

## 📥 Installation Guide

### 🔹 1. Download the Installer

* Click the link above to download the compressed `.rar` file.

* Extract it using [7-Zip](https://www.7-zip.org/) or Windows’ built-in tool.

* Inside the folder, you’ll see:

  ```
  TimpiCollectorWindowsLatest-v2.exe
  ```

  <img width="709" height="204" alt="image" src="https://github.com/user-attachments/assets/d8688ced-0e98-4dd9-b47a-b3e310d5b8fc" />

* Extract to (example: Desktop)

<img width="709" height="262" alt="image" src="https://github.com/user-attachments/assets/d2f9a988-b2ce-4c12-86ab-56dd23eb422c" />

---

### 🔹 2. Run the Installer

1. **Right-click** on `TimpiCollectorWindowsLatest-v2.exe`

2. Select **Run as Administrator** (required)

<img width="511" height="573" alt="image" src="https://github.com/user-attachments/assets/3e9b3b87-84a3-4086-9b43-869571bc883e" />

4. When prompted, **paste or type your GUID**

<img width="496" height="391" alt="image" src="https://github.com/user-attachments/assets/46313d5e-923a-4b04-b0a6-f732144d4559" />

   *Your GUID connects this Collector to your Timpi account.*

7. Wait for the installer to complete — usually under one minute.

---

### 🔹 3. What the Installer Does Automatically

✅ Installs the Timpi Collector to
`C:\Program Files\Timpi Intl. LTD`

✅ Creates a **Windows background service**
that runs automatically at startup and restarts if it ever crashes.

✅ Saves your **GUID** in
`C:\Program Files\Timpi Intl. LTD\guid.txt`

✅ Creates **two desktop shortcuts**:

1. **Timpi Collector Logs** – View live logs.
2. **Timpi Collector – Check for Updates** – Runs the Auto-Updater manually.

✅ Adds Timpi Collector to Windows “Apps & Features” for easy uninstallation.

🧩 *Note:* This version **does not** include the old *Timpi Manager* or system tray icon — it runs completely in the background for improved stability and performance.

---

## 🖥 Using Timpi Collector

### 🔹 4. Viewing Collector Logs

The Collector runs silently in the background.
You can verify that it’s working by checking the logs.

#### 🪟 Option 1 – Desktop Shortcut (Recommended)

<img width="634" height="195" alt="image" src="https://github.com/user-attachments/assets/e2b12908-8b92-4ef2-b7c7-45f57bf5e371" />

Simply double-click the **“Timpi Collector Logs”** icon on your desktop.
This opens a PowerShell window that continuously displays live log entries.
**Verbose mode** shows detailed information, while your settings might only display errors or basic info.

<img width="1235" height="128" alt="image" src="https://github.com/user-attachments/assets/96f1fe6f-3f0d-492e-90d0-c6be41a929d4" />

#### 🧑‍💻 Option 2 – Manually in PowerShell

Run this command:

```powershell
Get-Content "C:\Program Files\Timpi Intl. LTD\logs\collector.out.log" -Tail 50 -Wait
```

📂 **Log location:**

```
C:\Program Files\Timpi Intl. LTD\logs\
 ├── collector.out.log  ← Main log (shows normal activity)
 └── collector.err.log  ← Error log (only if issues occur)
```

To stop viewing logs, press **Ctrl + C**.

---

### 🔹 5. Checking for Updates (Auto-Updater)

During installation, a second shortcut is created on your desktop:
**🪄 Timpi Collector – Check for Updates**
<img width="634" height="128" alt="image" src="https://github.com/user-attachments/assets/c4daeacd-f421-4209-8121-416faf339394" />

When launched, it manually runs the **Auto-Updater** and displays its progress:

<img width="978" height="323" alt="image" src="https://github.com/user-attachments/assets/c7c8ad01-db4f-4593-953c-1cf3373e1567" />



Example output:

```
Killing TimpiCollector (PID: 10784)...
Stopping Windows service: Timpi Collector
Service stopped.
Downloading TimpiCollector from: https://timpi.io/applications/windows/TimpiCollectorWindowsLatestExecutable.zip
Download completed. Extracting...
Extraction completed.
Starting service again...

```

🧠 **What this does:**
The updater stops the Collector service, downloads the latest build, updates the executable, and restarts the Collector automatically.

🔁 **Automatic on reboot:**
The Auto-Updater also runs automatically whenever your computer restarts, ensuring your Collector always stays up to date even if you never open this shortcut manually.

✅ **In summary:**
The installer creates two helpful desktop shortcuts:

| Shortcut                                | Purpose                                  |
| --------------------------------------- | ---------------------------------------- |
| **Timpi Collector Logs**                | Opens live logs to view current activity |
| **Timpi Collector – Check for Updates** | Runs the manual Auto-Updater             |

---

### 🔹 How to Start, Restart, or Stop the Collector Service

1. Press **Start → Search → Services** and open the **Services** app

<img width="296" height="628" alt="image" src="https://github.com/user-attachments/assets/0a5b3980-575d-4e16-9ff3-f9189135258c" />

3. Find **Timpi Collector** in the list

<img width="1229" height="214" alt="image" src="https://github.com/user-attachments/assets/90a37183-0893-4dd4-a934-4867503ec4b3" />

Here you can **Start**, **Stop**, **Restart**, or **Pause** the Collector service.

🧩 *Tip:* “Verbose” log level is ideal for troubleshooting, but switch back to “Info” afterward to minimize log size.

---

### 🔹 6. Access the Management Dashboard

You can manage your node directly from your browser:

👉 [https://timpi.com/node/v2/management](https://timpi.com/node/v2/management)

From here you can:

* Monitor performance and uptime
* Adjust worker/thread settings
* View logs and node statistics

<img width="461" height="653" alt="Dashboard" src="https://github.com/user-attachments/assets/9cb31038-1707-4edf-8499-bc686e23a9be" />

---

### 🔹 7. Register or Retrieve Your GUID

If you haven’t set up your node yet, register to get your GUID here:

📘 **Guide:** [Register Your Timpi Node (GUID Setup)](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md)

Your GUID will appear under your profile on the **Timpi Node Management Dashboard**.
You only need to enter it once during installation — it’s saved automatically.

---

## 🗑 Uninstallation Guide

You can uninstall the Timpi Collector just like any other Windows app.

### 🔹 Method 1 – Apps & Features

1. Open **Start → Settings → Apps → Installed Apps**
2. Search for **Timpi**
3. Click **Uninstall** next to **Timpi Collector**

---

### 🔹 Method 2 – Control Panel

1. Press `Windows + R` → type `control` → press **Enter**

<img width="393" height="203" alt="image" src="https://github.com/user-attachments/assets/8c57851c-cd32-41be-ad3a-85526ee4c491" />

3. Go to **Programs → Uninstall a Program**

<img width="1125" height="440" alt="Screenshot 2025-10-29 172710" src="https://github.com/user-attachments/assets/f190b96e-3f86-4c17-bc28-32bb8ef2ad7c" />
5. Find **Timpi Collector**

<img width="916" height="82" alt="image" src="https://github.com/user-attachments/assets/c54f2944-9e83-458f-a91c-eee4596d35d1" />

6. Right-click → **Uninstall**

<img width="1123" height="246" alt="image" src="https://github.com/user-attachments/assets/f47507c4-20e9-484f-a2ef-e30741482717" />

✅ This removes:

* All installed files
* The background service
* Both desktop shortcuts

---

### 🧠 Summary of Key Changes (v2.0.0)

| Feature                  | Description                                                                                                                        |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| 🧩 **No UI / Tray**      | Runs fully headless — no Timpi Manager or tray icon                                                                                |
| 🧾 **GUID Prompt**       | You enter or paste your GUID during installation                                                                                   |
| 🔄 **Auto-Updater**      | Updates automatically on reboot and can also be triggered manually                                                                 |
| 💻 **Web Dashboard**     | Manage workers, threads, and performance online                                                                                    |
| 🌐 **GUID Registration** | Register and view your GUID at [RegisterNodes.md](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md) |

