
# 🪟 Timpi Collector for Windows 10 & 11

**Version:** `0.10.0-A`
📦 **Installer type:** Native `.exe` (Windows Program)

🔗 **Download:**
👉 [TimpiCollectorWindowsLatest-0.10.0-A.rar](https://timpi.io/applications/windows/TimpiCollectorWindowsLatest-0.10.0-A.rar)

---

## 📥 Installation Guide

### 🔹 1. Download the Installer

1. Click the link above to download the `.rar` file.
2. Extract it using [7-Zip](https://www.7-zip.org/) or Windows built-in tool.
3. Inside the archive, you’ll find the installer:
   👉 `TimpiCollectorSetup_0.10.0-A.exe`

---

### 🔹 2. Run the Installer

* **Right-click** `TimpiCollectorSetup_0.10.0-A.exe`
* Select **“Run as Administrator”**
* Follow the on-screen wizard to install the Collector

---

### 🔹 3. What the Installer Does Automatically

✅ Installs Timpi Collector to:
`C:\Program Files\Timpi Intl. LTD`

✅ Registers the Collector as a **Windows Service**

✅ Adds a **Desktop Shortcut** for `TimpiManager.exe`

✅ Places a **System Tray Icon** for quick access

✅ Adds **Timpi Collector** to Windows “Apps & Features”
(for simple uninstall and version tracking)

---

## 🖥️ Using Timpi Collector

### 🔹 4. Start the Collector

* Double-click the **TimpiManager** icon on your desktop
* You’ll see the **Red Timpi icon** appear in the system tray (next to the clock)

🖱️ **Right-click the tray icon** to:

* ▶️ Start or Stop the **Collector**
* 🌐 Start or Stop the **UI**
* ❌ Exit

---

### 🔹 5. Access the Dashboard

Open your browser and go to:
👉 [http://localhost:5015/collector](http://localhost:5015/collector)

In the **Settings tab**:

* Paste your **Neutaro Wallet Address**

  > (e.g., `neutaro1wah07cndmpfhfnanyrs2rpxnns286gsjrhx024`)
* Wait up to **15 minutes** for your **Key** to become ✅ Available

---

## 🧠 Resource Usage Tips

Just like on Linux, the Windows version of v0.10.0-A uses **CPU and RAM heavily** depending on:

* Number of **Threads** and **Workers**
* Total **system bandwidth** and **load**

> 💡 We recommend starting with **1 Worker / 5 Threads**, and gradually increasing if your system allows.

---

## 🗑️ Uninstallation Guide

Timpi Collector can be uninstalled like any normal Windows application.

### 🔹 Method 1 – Apps & Features

1. Open the **Start Menu** → **Settings**
2. Go to **Apps** → **Apps & Features**
3. Search for: `Timpi`
4. Click on **Timpi Collector v0.10.0-A**
5. Click **Uninstall** and confirm

---

### 🔹 Method 2 – Control Panel

1. Press `Windows + R` → type `control` → hit Enter
2. Go to: **Programs → Uninstall a Program**
3. Find **Timpi Collector**
4. Right-click → **Uninstall**

✅ This will:

* Remove the Collector and services
* Delete shortcuts and tray icon
* Clean up from “Apps & Features”
