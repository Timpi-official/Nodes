# 🌐 Timpi Collector Node for Windows 10 & 11 (v2)

### The Timpi Collector is part of the decentralized Timpi search network — it crawls and indexes the web, helping to build the world's first community-powered search engine.

By running a Collector, you help Timpi grow its decentralized data network — privately, securely, and without ads or tracking.

This build is a **native Windows program**. It installs a background **Windows service** that starts automatically at boot, restarts itself if it ever crashes, and keeps crawling whether or not you are signed in. A small **Collector window** (operator UI) is included so you can start/stop the node, save your GUID, and watch the live log — but you don't need to keep it open for the node to run.

---

<img width="1024" height="576" alt="TimpiCollector" src="https://github.com/user-attachments/assets/8dcd810f-fa30-4912-ac11-c63417ec15bc" />

---

### 📑 Table of Contents

* [Installation Guide](#-installation-guide)

  * [1. Download the Installer](#-1-download-the-installer)
  * [2. Run the Installer](#-2-run-the-installer)
  * [3. What the Installer Does Automatically](#-3-what-the-installer-does-automatically)
* [Using Timpi Collector](#-using-timpi-collector)

  * [4. The Collector Window (Operator UI)](#-4-the-collector-window-operator-ui)
  * [5. Viewing Collector Logs](#-5-viewing-collector-logs)
  * [6. Expected Logs — what a healthy node looks like](#-6-expected-logs--what-a-healthy-node-looks-like)
  * [7. Start, Restart, or Stop the Collector Service](#-7-start-restart-or-stop-the-collector-service)
  * [8. Access the Management Dashboard](#-8-access-the-management-dashboard)
  * [9. Register or Retrieve Your GUID](#-9-register-or-retrieve-your-guid)
  * [10. Updating the Collector](#-10-updating-the-collector)
* [Troubleshooting](#-troubleshooting)
* [Uninstallation Guide](#-uninstallation-guide)

  * [Method 1 – Apps & Features](#-method-1--apps--features)
  * [Method 2 – Control Panel](#-method-2--control-panel)
* [Summary of Key Changes](#-summary-of-key-changes)

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

**Version:** `v2` (native Windows build)

📦 **Installer type:** Native `.exe` (Windows Program) — installs a Windows service, no Docker required

🖥 **Requirements:** Windows 10 / 11 (64-bit) · 2 CPU cores · 2 GB RAM · local administrator rights · outbound HTTPS to the Timpi network and the open web

🔗 **Download:** [TimpiCollectorWindowsLatest-v2.rar](https://timpi.io/applications/windows/TimpiCollectorWindowsLatest-v2.rar)

> 💡 The download is a compressed `.rar`. Inside is a single Windows installer, e.g. `TimpiCollectorSetup-2.0.0.exe`. The .NET runtime is bundled — you do **not** need to install .NET or anything else first.

---

## 📥 Installation Guide

### 🔹 1. Download the Installer

* Click the download link above to save the `.rar` file.

* Extract it using [7-Zip](https://www.7-zip.org/) or Windows' built-in extractor (right-click → **Extract All…**).

* Inside the extracted folder you'll see the installer, for example:

  ```
  TimpiCollectorSetup-2.0.0.exe
  ```

---

### 🔹 2. Run the Installer

1. **Double-click** the installer (e.g. `TimpiCollectorSetup-2.0.0.exe`).

2. Windows will show a **User Account Control (UAC)** prompt asking if you want to allow the app to make changes — click **Yes**. Administrator rights are required because the installer registers a Windows service.

   > 🛡️ If Windows SmartScreen shows a "Windows protected your PC" notice on the unsigned installer, click **More info → Run anyway**. See [Troubleshooting](#-troubleshooting) if your antivirus flags it.

3. Accept the license / defaults. The default install location is:

   ```
   C:\Program Files\Timpi\Collector
   ```

4. On the **System ID** page, **paste or type your GUID**.

   *Your GUID connects this Collector to your Timpi account. You can get it from the [Node Management Dashboard](#-8-access-the-management-dashboard).*
   *On a reinstall/upgrade, your existing GUID is pre-filled automatically. If you leave it blank, the service will install but won't start until you provide a GUID (via the Collector window, or by putting it in `guid.txt` — see below).*

   
5. Optionally tick **Create a desktop shortcut**.

6. Click **Install** and wait — it usually finishes in well under a minute.

7. Leave **Launch Timpi Collector** checked on the final page and click **Finish**. The service starts and the Collector window opens.

---

### 🔹 3. What the Installer Does Automatically

✅ Installs the Timpi Collector to
`C:\Program Files\Timpi\Collector`

✅ Registers a **Windows background service** named **`Timpi Collector`** that:

* starts automatically at Windows startup (`start= auto`),
* is watchdogged — the worker is automatically relaunched if it crashes, and Windows' Service Control Manager restarts the host itself on failure (restart after 60 s for the first two failures, then every 5 minutes),
* can be started and stopped from the Collector window or `services.msc` (both require administrator rights).

✅ Saves your **GUID** to
`C:\Program Files\Timpi\Collector\guid.txt`

✅ Installs the **Collector window** (operator UI) and Start Menu shortcuts:

| Shortcut | Purpose |
| --- | --- |
| **Timpi Collector** | Opens the operator window (status, Start/Stop, live log) |
| **Open Log Folder** | Opens the install folder where logs are written |
| **Uninstall Timpi Collector** | Removes the program |

*(A desktop shortcut for **Timpi Collector** is also created if you ticked that option.)*

✅ Adds Timpi Collector to Windows **"Apps & Features"** for easy uninstallation.

🧩 *Note:* This native build runs entirely as a background **Windows service**. The Collector window is optional — closing it does **not** stop crawling. There is **no auto-updater** in this build; see [Updating the Collector](#-10-updating-the-collector).

---

## 🖥 Using Timpi Collector

### 🔹 4. The Collector Window (Operator UI)

Open **Timpi Collector** from the Start Menu (or the desktop shortcut). Because it manages a Windows service, it launches elevated — accept the one UAC prompt.

The window gives you everything you need at a glance:

* **Status indicator** — a colored dot and label showing **Stopped / Starting / Running / Stopping**, plus an uptime counter. It polls the real Windows service every ~2 seconds, so it stays accurate even if you start/stop the service elsewhere (e.g. `services.msc`).
* **GUID field** with **Save** and **Paste** buttons — paste your GUID and click **Save** to write it to `guid.txt`. If you change the GUID while the node is running, clicking **Start** transparently restarts the service so the new GUID takes effect.
* **Start** / **Stop** buttons — these drive the Windows service directly.
* **Open Log Folder** — opens the folder where the logs live.
* **Live log** pane — streams the worker's log in real time.
* **Checkboxes:**
  * *Start collector when launcher opens* — auto-start the node whenever you open the window.
  * *Minimize to tray on close* — clicking **X** hides the window to the system tray instead of closing it.
* **System tray icon** — right-click for **Show / Start / Stop / Open Log Folder / Quit**.

> 💡 **Closing the window does not stop your node.** The Windows service keeps running in the background. To actually stop crawling, use the **Stop** button, the tray menu's **Stop**, or `services.msc`.

---

### 🔹 5. Viewing Collector Logs

The Collector runs silently as a service. You can confirm it's working in any of these ways.

#### 🪟 Option 1 – The Collector Window (Recommended)

Open **Timpi Collector** and watch the **Live log** pane. New lines stream in as the node crawls.

#### 📂 Option 2 – Open the log files directly

Click **Open Log Folder** in the window (or the **Open Log Folder** Start Menu shortcut) to open:

```
C:\Program Files\Timpi\Collector\
```

Log files:

```
C:\Program Files\Timpi\Collector\
 ├── TimpiCollectorLogs<date>.log     ← Main worker log (normal activity + metrics)
 └── logs\
      └── collector.err<date>.log     ← Crash backstop (only meaningful if something goes wrong)
```

* **`TimpiCollectorLogs<date>.log`** (e.g. `TimpiCollectorLogs20260720.log`) is the primary log — daily-rolling, capped at 50 MB with 7 files retained.
* **`logs\collector.err<date>.log`** captures raw error output from the service host. On a healthy node it usually contains only a single "Collector host starting collector process." line.

Logs self-prune (roughly ~420 MB worst case across both streams) — no cleanup task is needed.

#### 🧑‍💻 Option 3 – Tail the log in PowerShell

```powershell
Get-Content "C:\Program Files\Timpi\Collector\TimpiCollectorLogs$(Get-Date -Format yyyyMMdd).log" -Tail 50 -Wait
```

Press **Ctrl + C** to stop watching.

---

### 🔹 6. Expected Logs — what a healthy node looks like

When the service starts, the worker registers with a Coordinator, receives its domain list, and begins crawling. A healthy startup looks like this (your GUID and the coordinator node addresses will differ):

```
2026-07-20 15:07:10 [WRN] Collector was started
2026-07-20 15:07:11 [INF] The response was successful: Collector found on http://tapcore1.timpi.network:4014/
2026-07-20 15:07:11 [INF] Currently on version 2.0.0
2026-07-20 15:07:11 [INF] Logging level: Information
2026-07-20 15:07:11 [INF] Trying to send keep alive to http://tap28.timpi.network:4014
2026-07-20 15:07:12 [INF] Successfully send alive to Coordinator http://tap28.timpi.network:4014
2026-07-20 15:07:12 [WRN] Coordinator updated workers: 1 -> 10
2026-07-20 15:07:12 [WRN] Coordinator updated connections: 5 -> 2
2026-07-20 15:07:12 [INF] http://<coordinator-node>.timpi.network:4013, ... (GeoCore / node list)
2026-07-20 15:07:12 [WRN] Updated public suffix list (10206 -> 10259 entries)
2026-07-20 15:07:53 [INF] Got domains from http://<coordinator-node>.timpi.network:4013
```

> ℹ️ **About the version number.** The `Currently on version 2.0.0` line is the Timpi **network version** your collector reports to the coordinator — the network uses it to confirm your node is on a reward-eligible build. It matches your installed package version (`2.0.0`), so seeing `2.0.0` here is correct and expected.

Then the node settles into a steady stream of per-domain crawl activity:

```
2026-07-20 15:07:59 [WRN] [metrics] viktos.com progress ok=1 soft=0 hard=0 skipped=0 elapsed=0.9s pages/s=1.09 fail%=0.0 avgLatencyMs=301 crawlDelayMs=500
2026-07-20 15:08:01 [WRN] [metrics] agoetzfilm.com finished ok=1 soft=0 hard=0 skipped=0 elapsed=3.0s pages/s=0.34 fail%=0.0 avgLatencyMs=340 crawlDelayMs=500
2026-07-20 15:08:12 [WRN] [metrics] viktos.com progress ok=10 soft=0 hard=0 skipped=0 elapsed=13.8s pages/s=0.72 fail%=0.0 avgLatencyMs=2211 crawlDelayMs=3316
2026-07-20 15:08:22 [WRN] [dns] mississauga-gasoline-prices.example.com: DNS pre-resolution failed; skipping domain.
2026-07-20 15:08:27 [INF] Got domains from http://<coordinator-node>.timpi.network:4107
```

**How to read the `[metrics]` line** — one is emitted per domain as it progresses and again when it finishes:

| Field | Meaning |
| --- | --- |
| `ok` | Pages fetched successfully |
| `soft` | Soft failures (per-URL HTTP errors like 404) |
| `hard` | Hard failures (DNS / SSL / connection / timeout) |
| `skipped` | URLs skipped (robots.txt, `noindex`, or duplicate content) |
| `elapsed` | Time spent on this domain |
| `pages/s` | Crawl rate for the domain |
| `fail%` | Percentage of attempts that failed |
| `avgLatencyMs` | Average page response time |
| `crawlDelayMs` | Current adaptive per-host delay (rises automatically on slower sites, capped at 5 s) |

**Other normal lines you'll see:**

* `[dns] <domain>: DNS pre-resolution failed; skipping domain.` — a dead, parked, or non-existent domain caught quickly (in ~1.5 s) instead of hanging. This is expected and healthy.
* `Coordinator updated workers` / `Coordinator updated connections` — the network is tuning how hard your node works. Normal.
* `Successfully send alive to Coordinator` — your regular keep-alive/heartbeat. Normal.

**What you should NOT see on a healthy node:** repeated `[ERR]`/`[FATAL]` lines, or a `[host] FATAL: installation is corrupt` line in `collector.err`. If you do, see [Troubleshooting](#-troubleshooting).

> ℹ️ On some systems numbers use a comma as the decimal separator (e.g. `elapsed=0,9s`) — that's just your Windows regional format and is harmless.

---

### 🔹 7. Start, Restart, or Stop the Collector Service

You have three equivalent ways to control the node.

**A. From the Collector window** — use the **Start** / **Stop** buttons, or the tray icon menu.

**B. From the Services app:**

1. Press **Start**, type **Services**, and open the **Services** app.
2. Find **Timpi Collector** in the list.
3. Right-click to **Start**, **Stop**, or **Restart** it.

**C. From an elevated Command Prompt / PowerShell:**

```cmd
sc start "Timpi Collector"
sc stop  "Timpi Collector"
sc query "Timpi Collector"
```

A running node reports `STATE : 4  RUNNING`.

🧩 *Tip — turning up the logging.* `C:\Program Files\Timpi\Collector\CollectorSettings.json` holds a
single setting, the log level:

```json
{"LogLevel":"Information"}
```

Valid values, quietest to noisiest: `Error`, `Warning`, `Information` (default), `Debug`, `Verbose`.
Set it to `Verbose` while troubleshooting, restart the service, and put it back to `Information`
afterwards — `Verbose` fills the log quickly. You can also change it from the Management Dashboard.

⚠️ Don't delete this file or leave it invalid. If the Collector cannot read it, it falls back to
`Error`, which hides the normal `[metrics]` crawl lines and makes a healthy node look silent.

---

### 🔹 8. Access the Management Dashboard

You can manage your node from your browser:

👉 [https://timpi.com/node/v2/management](https://timpi.com/node/v2/management)

From here you can:

* Monitor performance and uptime
* Adjust worker / thread / connection settings
* View logs and node statistics

---

### 🔹 9. Register or Retrieve Your GUID

If you haven't set up your node yet, register to get your GUID here:

📘 **Guide:** [Register Your Timpi Node (GUID Setup)](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md)

Your GUID appears under your profile on the **Timpi Node Management Dashboard**. You normally enter it once during installation and it's saved automatically to `guid.txt`.

**To change the GUID later:** open the Collector window, paste the new GUID, and click **Save** (then **Start**/**Restart**). Alternatively, edit `C:\Program Files\Timpi\Collector\guid.txt` and restart the **Timpi Collector** service.

---

### 🔹 10. Updating the Collector

This build does **not** include an automatic updater. To update to a newer release:

1. Download the latest installer from the [download link](https://timpi.io/applications/windows/TimpiCollectorWindowsLatest-v2.rar).
2. Run it. The installer detects your existing installation, stops the old service, replaces the files, and re-registers the service.
3. Your **GUID is preserved** — it's pre-filled on the GUID page, so just click through.

You do not need to uninstall first; installing over the top performs a clean in-place upgrade. Your worker logs are kept across upgrades.

---

## 🧯 Troubleshooting

**Antivirus / Windows Defender flags the installer or `TimpiCollector.exe`.**
The executables are single-file, self-contained .NET binaries and are currently **unsigned**, which some antivirus engines (including Defender's `idp.helu.*` heuristic) flag as a false positive. If you trust this download, allow the file, or add an exclusion for the install folder `C:\Program Files\Timpi\Collector`. Code-signing is planned to remove this friction.

**The Collector window won't open / closes immediately.**
The window requires administrator rights. Approve the UAC prompt when it appears. If you launched it without elevation and nothing happened, right-click the shortcut → **Run as administrator**.

**Service is installed but won't stay running / status stays "Stopped".**
Check `C:\Program Files\Timpi\Collector\logs\collector.err<date>.log`. A line like `[host] FATAL: installation is corrupt — TimpiCollector.exe is missing` means the install is incomplete — re-run the installer to repair it. Also make sure a valid GUID is present in `guid.txt`; without one the worker exits.

**Node runs but shows no rewards / doesn't appear online.**
Confirm the GUID in `guid.txt` matches the one on your Management Dashboard, and that outbound HTTPS to the Timpi network isn't blocked by a firewall. The log should show `Successfully send alive to Coordinator`.

**Lots of `[dns] ... skipping domain` lines.**
This is normal — those are dead/parked domains being skipped quickly. It is not an error.

---

## 🗑 Uninstallation Guide

You can uninstall the Timpi Collector just like any other Windows app. Uninstalling stops and removes the Windows service, deletes the program files, and removes the shortcuts.

### 🔹 Method 1 – Apps & Features

1. Open **Start → Settings → Apps → Installed Apps**
2. Search for **Timpi**
3. Click **⋯ → Uninstall** next to **Timpi Collector**

### 🔹 Method 2 – Control Panel

1. Press `Windows + R` → type `control` → press **Enter**
2. Go to **Programs → Uninstall a Program**
3. Find **Timpi Collector**
4. Right-click → **Uninstall**

✅ This removes:

* All installed files
* The background **Timpi Collector** service
* The Start Menu (and desktop) shortcuts

---

## 🧠 Summary of Key Changes

| Feature | Description |
| --- | --- |
| 🪟 **Native Windows service** | Runs headless in the background via the Windows Service Control Manager; auto-starts at boot and self-restarts on crash |
| 🖥 **Collector window** | Optional operator UI to Start/Stop, save your GUID, and watch the live log — closing it does not stop the node |
| 🧾 **GUID prompt** | Enter or paste your GUID during installation; changeable later from the window or `guid.txt` |
| 📦 **Self-contained** | .NET 10 runtime bundled — no separate .NET install required |
| 🚫 **No auto-updater** | Update by downloading and re-running the latest installer (GUID preserved) |
| 📂 **Install path** | `C:\Program Files\Timpi\Collector` |
| 📝 **Logs** | `TimpiCollectorLogs<date>.log` in the install folder; crash backstop in `logs\collector.err<date>.log` |
| 💻 **Web Dashboard** | Manage workers, threads, and performance online |
| 🌐 **GUID Registration** | Register and view your GUID at [RegisterNodes.md](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md) |
