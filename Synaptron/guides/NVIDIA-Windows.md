# 🧬 **Timpi Synaptron — NVIDIA on Windows 10 / 11**

<img width="1480" height="862" src="https://github.com/user-attachments/assets/b0749433-3720-4422-a14d-26c4dec067c3"/>

Synaptron is Timpi's AI node. It connects to the Timpi Orca Controller and runs AI workloads —
entity and intent detection, LLM chat, RAG, vision and image generation — depending on your GPU.

The node makes only **outbound** connections. You do not need to open any inbound port.

**Supported:** Windows 10 or Windows 11, 64-bit, with an NVIDIA GPU.

> **Windows is NVIDIA-only.** An AMD or Intel card cannot run the node on Windows and the installer
> will say so. AMD runs on Linux through ROCm — see the [AMD guide](AMD.md). Intel is not supported at
> all.

---

## Before you start

| | |
|---|---|
| **GPU** | NVIDIA, RTX 20-series (Turing) or newer for LLM and image work. GTX 10-series and Tesla P4 (Pascal) join **on the GPU** as a lower tier with a limited task set — support is planned to be phased out in a future release, announced in advance. Minimum compute capability **6.0**. RTX 50-series / Blackwell is supported. |
| **Driver** | **Install it before you start.** RTX 20/30/40 (Turing/Ampere/Ada): **560.94 or newer**. RTX 50 / Blackwell: **570.00 or newer** (reporting CUDA 12.8). Studio Driver preferred over Game Ready. |
| **Disk** | **100 GB free.** The runtime alone is ~8 GB; models are downloaded on demand and grow well beyond that. |
| **Time** | **10–20 minutes** on a typical connection, up to 45 on a slow one. Almost all of it is a multi-GB PyTorch/CUDA download. |
| **Your node GUID** | Required — you paste it in when you install, and the node refuses to start without it. Register your Timpi Node Access NFT at [timpi.com/node/v2/management](https://timpi.com/node/v2/management); see the [registration guide](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md). |

> **Where to get the driver.** Download it from [NVIDIA's driver downloads](https://www.nvidia.com/en-us/drivers/)
> (select your GPU and Windows 64-bit), or use the [NVIDIA App](https://www.nvidia.com/en-us/software/nvidia-app/).
> Confirm your card is CUDA-capable first: [CUDA-compatible GPUs](https://developer.nvidia.com/cuda-gpus).

> **Your node GUID is not a plain UUID.** It may contain letters, numbers, dots, colons, underscores
> and hyphens in any arrangement, for example `1a5737d8-example-node-a05f-ee3aba76548b`. Use exactly
> the string you were given.

**Do not install Python, CUDA Toolkit, Visual C++ Redistributable, or .NET by hand.** The desktop
setup checks for them and installs or repairs what's missing.

---

## Install — installer (recommended)

**1. Download the installer**

Get **`SynaptronNodeSetup-2.1.9.exe`** and its **`SHA256SUMS`** from the latest release:
[github.com/Timpi-official/Nodes/releases](https://github.com/Timpi-official/Nodes/releases).

> **Verify the download (optional).** In PowerShell in your Downloads folder:
> `Get-FileHash .\SynaptronNodeSetup-2.1.9.exe -Algorithm SHA256` — compare it to the matching line in
> `SHA256SUMS`.

**2. Run it**

Double-click **`SynaptronNodeSetup-2.1.9.exe`**. It installs to a fixed location, **`C:\Synaptron`** —
there is no folder-choice page — and registers its own entry in **Add/Remove Programs**.

> **Windows SmartScreen** may show *"Windows protected your PC"* — the installer isn't code-signed yet.
> Click **More info → Run anyway**, and approve the **User Account Control** prompt (the installer needs
> it to repair the NVIDIA driver, Visual C++ Redistributable, Python or .NET).

**3. Enter your details and install**

The setup window opens with these fields:

- **Controller address:** `https://orcacontroller.timpi.network` (pre-filled)
- **Timpi node ID:** the node GUID assigned to this machine (the app labels this field *Timpi node ID*)
- **Processing device:** leave on **`Auto`**

Click **Install and start node.** It checks and repairs the driver / Visual C++ / Python / .NET as
needed, then downloads the multi-GB PyTorch/CUDA stack (**this is where the time goes** — a bar that
looks stuck is usually a large wheel downloading). When it finishes it hands the node over to the
supervisor, the install output is replaced with a running confirmation, and the node keeps running
with a **tray icon** — you can close the window:

```
Node running and connected to the Controller.
You can close this window: the node is running in the background.
For worker, GPU, model, and detailed log information, select Open dashboard.
```

> **Reinstalling, or reusing a machine that already ran a node?** If `C:\Synaptron` already holds a
> node, setup pauses with *"An existing Synaptron installation was found"* and shows which node ID is
> there. Every node ID it finds is first copied to `%LOCALAPPDATA%\Synaptron\node-id-backups\`. Click
> **Install anyway** to take the folder over with the ID you just entered, or **Cancel** to keep the
> old one. A node ID belongs to one GPU — only run a second node on this machine if it is going on a
> different card.

This is the path tested on every release — clean install, upgrade over a running node, and uninstall.

---

## Install — runner ZIP + desktop app (alternative)

**1. Download the runner ZIP**

The release carries a short, stable name:

```
https://github.com/Timpi-official/Nodes/releases/download/synaptron-2.1.9/synaptron-windows.zip
```

The same bytes are also published as `synaptron-node-runner-win-x64-2.1.9.zip`, and both names appear
in `SHA256SUMS` with the same digest.

**2. Unblock the ZIP, then extract it**

Right-click the ZIP → **Properties** → tick **Unblock** at the bottom → **OK**. Windows marks
everything inside a downloaded archive as internet content, and the app will not start until that
mark is cleared. Unblocking the ZIP first clears it for every file inside in one step.

Then right-click the ZIP → **Extract All** → a writable folder such as `C:\SynaptronNode`.
(Do **not** run it from inside the ZIP viewer, and avoid `C:\Program Files` — it needs a writable
folder.)

> Already extracted without unblocking? Open **Windows PowerShell** and run:
> ```powershell
> Get-ChildItem C:\SynaptronNode -Recurse -File | Unblock-File
> ```

**3. Start the desktop app**

Double-click **`Start-SynaptronNode.vbs`**. It opens the Synaptron Node desktop app.

> **Windows SmartScreen** may show *"Windows protected your PC"*. Click **More info → Run anyway** —
> the app isn't code-signed yet. If you see a **User Account Control** prompt, approve it; the
> installer needs it to repair the NVIDIA driver, Visual C++ Redistributable, Python or .NET.
>
> A box titled **"Open File – Security Warning"** is a different thing and has no *Run anyway*: it
> means the files are still marked as downloaded. Close it and unblock them as in step 2.

**4. Fill in and install**

In the app:

- **Controller address:** `https://orcacontroller.timpi.network`
- **Timpi node ID:** the node GUID assigned to this machine
- **Processing device:** leave on **`Auto`** — it detects the card and picks the right mode.

Then click **Install and start node.**

**What you should see**

The app shows a live bootstrap view — the hardware check, then the long PyTorch/CUDA download
(**this is where the time goes**; a bar that looks stuck is usually a large wheel downloading). A
local bootstrap dashboard is available at `http://127.0.0.1:8093/dashboard` during this phase.

When preparation succeeds it hands over to the supervisor and the installation output is replaced
with a **running confirmation**; the supervisor dashboard is at `http://127.0.0.1:8092/dashboard`.
Your settings are saved automatically (your node GUID is written to `config\node-guid.txt`).

You can **close the desktop window safely** — the node and its **tray icon** keep running in the
background. The tray menu can open the dashboard, pause/resume, restart, or stop the node.

> **GTX 10-series / Tesla P4 (Pascal) cards** run **on the GPU** (the cu124 stack) as a lower tier with
> a limited task set — nothing extra to set; leave **Processing device** on `Auto`. Pascal support is
> planned to be phased out in a future release, announced in advance.

---

## Keep it running after reboot (autostart)

Once you've confirmed the node starts correctly, enable start-at-logon. Open **PowerShell as
Administrator** in the runner folder and run — it installs a **scheduled task** named
`Timpi Synaptron Node` that starts the node when you log in:

```powershell
powershell -ExecutionPolicy Bypass -File .\Initialise.ps1 `
  -ControllerUrl https://orcacontroller.timpi.network `
  -NodeGuid YOUR-NODE-GUID `
  -InstallGpuDependencies -InstallProductionDeps -InstallAutostart
```

Remove autostart:

```powershell
powershell -ExecutionPolicy Bypass -File .\Initialise.ps1 -UninstallAutostart
```

---

## Check that it is working

**In Discord:** run **`/synaptronchecker`** with your node GUID. You want it **online** with a recent
check-in — the easiest way to confirm the network can see you.

**Local dashboard:** `http://127.0.0.1:8092/dashboard` (proves the local process is up, not that the
Controller can see you).

> **Advanced (optional):** from PowerShell query the Controller directly —
> `(Invoke-RestMethod "https://orcacontroller.timpi.network/api/coordinator/nodes/YOUR-NODE-GUID/status/month").isOnline`
> should return `True`.

> **An empty model cache on a fresh node is correct.** Models are not downloaded at install — the
> Controller decides what your node loads, when work needs it.

> **Your node ID is not printed** in the install output, the logs, or any pasteable local view. That is
> deliberate: the ID is your node's credential, and this output is what gets pasted into a support
> request. `Invoke-RestMethod http://127.0.0.1:8092/api/capabilities` does **not** show it; the
> dashboard says whether one is configured, not what it is.

---

## Your node is idle — is it working?

**Almost certainly yes.** A correctly installed node can sit idle without receiving a single task, and
that is expected — work reaches your node from the Controller, and there is little to hand out until
Orca is fully live. **You do not need to reinstall, restart, or reconfigure anything while waiting.**

**How to tell idle from broken** — a healthy idle node shows *all* of these:

- Status reads **`idle.` with a green dot** — not `paused.` and not `failed:`.
- Both kinds of process are alive (in PowerShell):
  ```powershell
  Get-CimInstance Win32_Process | Where-Object { $_.Name -match '^(dotnet|python|SynaptronNodeHost)' -and $_.CommandLine -match 'SynaptronNodeHost|uvicorn app\.main' } | Select-Object Name, ProcessId
  ```
  You should see `dotnet.exe` (the supervisor, running `SynaptronNodeHost.dll`) and `python.exe` (the
  worker, running `uvicorn app.main`); two `python.exe` entries are normal, the venv launcher and the
  interpreter it starts. This works for both install paths (`C:\Synaptron` and `C:\SynaptronNode`).
- The startup log contains `Connected to Synaptron Controller SignalR hub`.
- `Invoke-RestMethod http://127.0.0.1:8092/api/capabilities` reports the GPU under `hardware.gpus`, each with `torchCudaSupported : true` — it is nested there, not a top-level field.

**Signs something is actually wrong:** the status says `failed:`; `dotnet.exe` or `python.exe` is
missing from that list; `/api/capabilities` doesn't respond; or the dashboard says no node GUID is
configured.

> **A deliberate stop shows as `stopped:`, not `failed:`.** Allow ~30 s for it to settle after a stop.

---

## Advanced: PowerShell instead of the desktop app

This path runs in **two stages**: the bootstrap first installs and verifies the Python/ML stack, then
you start the node. Open **PowerShell** in the runner folder.

**1. Install and verify** (first run downloads a multi-GB PyTorch/CUDA stack):

```powershell
cd C:\SynaptronNode
powershell -ExecutionPolicy Bypass -File .\scripts\start-node-bootstrap-windows.ps1 `
  -ControllerUrl https://orcacontroller.timpi.network `
  -NodeGuid YOUR-NODE-GUID `
  -InstallGpuDependencies
```

The preflight runs first. **A `preflight: warn` is normal** when the only warnings are optional items —
`nvcc`/`cl.exe not found` (needed only to compile CUDA extensions) or low model-cache disk — as long as
the GPU, driver and CUDA lines all say `[PASS]`:

```
SynaptronNode NVIDIA Windows preflight: warn
[PASS] gpu: 0: NVIDIA GeForce RTX 3060 (12 GB, compute 8.6)
[PASS] gpu-minimum-requirement: 1 GPU(s) meet Synaptron minimum compute capability 6.0+.
[PASS] driver-version: Installed NVIDIA driver 591.86 meets required 560.94.
[WARN] cuda-toolkit-nvcc: nvcc was not found. This is optional ...
```

It ends with the dependency check confirming your GPU, then stops without starting the node:

```
torch=2.6.0+cu124   transformers=5.13.1
torch_cuda_available=True   torch_cuda_device_0=NVIDIA GeForce RTX 3060   sm_86
quantization_4bit=ok, nf4 forward pass on cuda
SynaptronNode Python environment is ready.
==> Initialisation completed. -NoStart was supplied, so the node was not started.
```

On an RTX 50-series / Blackwell card that first line reads `torch=2.11.0+cu128` instead — the
installer picks the cu128 stack from the card's compute capability.

**2. Start the node:**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-node-host-windows.ps1 `
  -Port 8091 -HostName 127.0.0.1 `
  -ControllerUrl https://orcacontroller.timpi.network `
  -NodeGuid YOUR-NODE-GUID -TransformersDevice Cuda
```

It starts the Python worker and the .NET supervisor, then reaches the Controller:

```
Controller URL: https://orcacontroller.timpi.network
Now listening on: http://127.0.0.1:8092
Connected to Synaptron Controller SignalR hub https://orcacontroller.timpi.network/hubs/synaptron
Loaded Synaptron model catalog from Controller: https://orcacontroller.timpi.network/api/catalog/models
```

The supervisor dashboard is at `http://127.0.0.1:8092/dashboard`. **The desktop app does both stages
for you** and keeps the node running in the tray — this two-stage path is only for people who prefer
the command line. If the NVIDIA driver was just installed or updated, reboot and run stage 1 again.

> **On a low-disk machine the node keeps 0 models** and the worker log fills with `Withholding <model>:
> needs about N GB free …`. That is the disk-headroom guard, not a fault — the node still registers and
> reports online; it just won't fetch models until there's room. This is why the 100 GB disk
> requirement matters.

---

## Updating to a new release

**Installer install:** download the newer `SynaptronNodeSetup-<version>.exe` (and check it against
`SHA256SUMS`) from [github.com/Timpi-official/Nodes/releases](https://github.com/Timpi-official/Nodes/releases)
and run it over the existing install; there is no need to uninstall first. It stops the running node,
replaces the program files in `C:\Synaptron` (your node ID, the Python environment and the model cache
are left in place), and opens the same setup window as a first install with your Timpi node ID already
filled in. If it finds another Synaptron install on the machine, or a different node ID in the folder,
it shows the **An existing Synaptron installation was found** dialog first; every node ID it finds is
backed up before you choose **Install anyway**.

**ZIP install:** grab the newer `synaptron-windows.zip` from the same release.
**Unblock it the same way as a first install** (right-click → Properties → Unblock → OK). Then stop the
node from the **tray menu** (or `Stop-SynaptronNode.ps1`), extract the new ZIP over your
`C:\SynaptronNode` folder, and start it again with `Start-SynaptronNode.vbs`.

Your venv and model cache are reused, and your node GUID (`config\node-guid.txt`) survives the extract.
Each release's notes say whether its Python packages changed; 2.1.3 through 2.1.9 pin the same ones. If
a release says they changed, run step 1 of [Advanced: PowerShell](#advanced-powershell-instead-of-the-desktop-app)
once after extracting and before starting the node. The installer path needs nothing extra.

---

## Uninstall

**Installer install:** remove **Timpi Synaptron Node** from **Settings → Apps → Installed apps** (or
Add/Remove Programs). That runs the bundled uninstaller and removes `C:\Synaptron`.

**ZIP install:**

1. Stop the node — tray menu **Stop**, or:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Stop-SynaptronNode.ps1 -DisableAutostart
   ```
2. Remove autostart (if you enabled it):
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Initialise.ps1 -UninstallAutostart
   ```
3. Delete the `C:\SynaptronNode` folder. Everything — the venv and the model cache — lives inside it.

---

## If something goes wrong

| Symptom | Cause and fix |
|---|---|
| SmartScreen *"Windows protected your PC"* | The app isn't code-signed yet. **More info → Run anyway.** |
| `Start-SynaptronNode.vbs` fails with **`800704C7`**, *"The operation was canceled by the user"* | The files are still marked as downloaded. Unblock them: `Get-ChildItem C:\SynaptronNode -Recurse -File \| Unblock-File`, then double-click the .vbs again. |
| The desktop app doesn't open / "desktop app was not found" | You ran it from inside the ZIP or the extract is incomplete. Extract the **whole** ZIP to a folder, then double-click `Start-SynaptronNode.vbs`. |
| `Failed to initialize NVML` / driver mismatch, or nvidia-smi errors | The NVIDIA driver was updated without a reboot. **Reboot**, then start again. |
| Torch fails to load `c10.dll` / DLL load errors | The **Microsoft Visual C++ Redistributable 2015–2022 x64** is missing. The installer normally repairs it; if not, install it and restart the node. |
| Preflight says the GPU is below the minimum | The card is below compute capability 6.0. It cannot run Synaptron. |
| Preflight says the GPU is an AMD or Intel card | Windows is NVIDIA-only. AMD runs on Linux only — see the [AMD guide](AMD.md). |
| Download seems stuck | It is a multi-GB download. Watch the dashboard/progress before killing it. |
| `Address already in use` on 8091/8092/8093 | The node is already running. Stop it (tray → Stop) before starting a second copy. |
| Node runs but `isOnline` is false | Check outbound HTTPS to `orcacontroller.timpi.network` isn't blocked by a firewall/VPN. |

---

*2.1.9 — the Windows paths are unchanged apart from the installer's version. 2.1.9 stops an image or
audio job from making the node read a local file or authenticate to a network share. Since 2.1.8,
speech-to-text and audio classification work without `ffmpeg`, which a Windows node does not have.
Measured on an RTX 3080 Ti: the 2.1.9 installer upgraded a running 2.1.8 node in place (node ID kept,
back on the Controller) and `check219.py` passed 10/10 with no `ffmpeg`, the refusals included; before
that, the 2.1.8 installer upgraded a running 2.1.7 node in place (node ID kept, back on the Controller,
`workload-test.py --quick` 6/6), and on that machine, with no `ffmpeg` installed, text-to-speech into
Whisper, audio classification and an image sent as a data URL all worked. Earlier: verified on Windows 11,
RTX 3060 (12 GB) at 2.1.2 and unchanged since: the PowerShell path ran the full install (torch
2.6.0+cu124, transformers 5.13.1, 4-bit measured on-GPU), started the node, reached the SignalR hub,
and the Controller reported it **ONLINE**; the installer → desktop-app flow was verified end-to-end,
including **Install anyway** over an existing install with the prior node ID backed up.*
