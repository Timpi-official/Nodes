# 🧬 **Timpi Synaptron — Windows 10 / 11**

<img width="1480" height="862" src="https://github.com/user-attachments/assets/b0749433-3720-4422-a14d-26c4dec067c3"/>

Synaptron is Timpi's AI node. It connects to the Timpi Orca Controller and runs AI workloads —
entity and intent detection, LLM chat, RAG, vision and image generation — depending on your GPU.

The node makes only **outbound** connections. You do not need to open any inbound port.

**Supported:** Windows 10 or Windows 11, 64-bit.

---

## Before you start

| | |
|---|---|
| **GPU** | NVIDIA, RTX 20-series (Turing) or newer for LLM and image work. GTX 10-series (Pascal) can join, but only for legacy low-tier tasks. Minimum compute capability 6.1. |
| **Driver** | **Install it before you start.** RTX 20/30/40 (Turing/Ampere/Ada): **560.94 or newer**. RTX 50 / Blackwell: **570.00 or newer**. Studio Driver preferred over Game Ready — these machines run compute workloads, where stability matters more than day-one game support. |
| **Disk** | **100 GB free.** The runtime alone is ~8 GB; models are downloaded on demand and grow well beyond that. |
| **Time** | **10–20 minutes** on a typical connection, up to 45 on a slow one. Almost all of it is a multi-GB PyTorch/CUDA download. |
| **Your node GUID** | Required — this is what you paste in when you install, and the node refuses to start without it. You get it by registering your Timpi Node Access NFT at [timpi.com/node/v2/management](https://timpi.com/node/v2/management); see the [registration guide](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md). |

> **Where to get the driver.** Download it from [NVIDIA's driver downloads](https://www.nvidia.com/en-us/drivers/)
> (select your GPU and Windows 64-bit), or use the [NVIDIA App](https://www.nvidia.com/en-us/software/nvidia-app/)
> to install it and keep it updated. Confirm your card is CUDA-capable first:
> [CUDA-compatible GPUs](https://developer.nvidia.com/cuda-gpus).

> **Your node GUID is not a plain UUID.** It may contain letters, numbers, dots, colons, underscores
> and hyphens in any arrangement, for example `1a5737d8-example-node-a05f-ee3aba76548b`. Use exactly
> the string you were given.

**Do not install Python, CUDA Toolkit, Visual C++ Redistributable, or .NET by hand.** The desktop
setup checks for them and installs or repairs what's missing.

---

## Install — desktop app (recommended)

**1. Download the runner**

Get the Windows runner from the official release:
[…/releases/download/synaptron-2.0.2/synaptron-node-runner-win-x64-2.0.2-20260726-213822.zip](https://github.com/Timpi-official/Nodes/releases/download/synaptron-2.0.2/synaptron-node-runner-win-x64-2.0.2-20260726-213822.zip)

> Newer versions, when released, are listed at
> [github.com/Timpi-official/Nodes/releases](https://github.com/Timpi-official/Nodes/releases) —
> always take the latest **Windows x64** zip.

**2. Extract the whole ZIP**

Right-click the ZIP → **Extract All** → a writable folder such as `C:\SynaptronNode`.
(Do **not** run it from inside the ZIP viewer, and avoid `C:\Program Files` — it needs a writable
folder.)

**3. Start the desktop app**

Double-click **`Start-SynaptronNode.vbs`**. It opens the Synaptron Node desktop app.

> **Windows SmartScreen** may show *"Windows protected your PC"*. Click **More info → Run anyway** —
> the app isn't code-signed yet. If you see a **User Account Control** prompt, approve it; the
> installer needs it to repair the NVIDIA driver, Visual C++ Redistributable, Python or .NET.

**4. Fill in and install**

In the app:

- **Controller address:** `https://orcacontroller.timpi.network`
- **Node GUID:** the Timpi node GUID assigned to this machine
- **Processing device:** leave on **`Auto`**

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

**In Discord:** run **`/synaptronchecker`** with your node GUID. You want it to show your node
**online** with a recent check-in — that's the easiest way to confirm the network can see you.

**Local dashboard:** `http://127.0.0.1:8092/dashboard` (a working dashboard only proves the local
process is up, not that the Controller can see you).

> **Advanced (optional):** from PowerShell you can query the Controller directly —
> `(Invoke-RestMethod "https://orcacontroller.timpi.network/api/coordinator/nodes/YOUR-NODE-GUID/status/month").isOnline`
> should return `True`.

> **An empty model cache on a fresh node is correct.** Models are not downloaded at install — the
> Controller decides what your node loads, when work needs it.

---

## Your node is idle — is it working?

**Almost certainly yes.** A correctly installed node can sit idle for days without receiving a single
task, and that is expected right now. Work reaches your node from the Controller, which distributes
what originates from Orca — and Orca isn't public yet, so there is very little to hand out. As Timpi
finishes updating nodes and Orca goes live, your node starts receiving tasks on its own. **You do not
need to reinstall, restart, or reconfigure anything while waiting** — one of our nodes ran five hours
straight with 9,243 supervisor heartbeats, 0 models loaded and 0 inference requests, and nothing was
wrong.

**How to tell idle from broken** — a healthy idle node shows *all* of these:

- Status reads **`idle.` with a green dot** — not `paused.` and not `failed:`.
- Both processes are alive (in PowerShell):
  ```powershell
  Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*SynaptronNode*" -and $_.Name -match 'dotnet|python' } | Select-Object Name, ProcessId
  ```
  You should see two — `dotnet.exe` (the supervisor) and `python.exe` (the worker).
- The startup log contains `Connected to Synaptron Controller SignalR hub`.
- `Invoke-RestMethod http://127.0.0.1:8091/capabilities` returns **your node GUID** and
  `torchCudaSupported : true`.

If all of that holds, your node is connected and available — waiting, not failing.

**Signs something is actually wrong:** the status says `failed:` (check `logs\` for an entry
timestamped when it happened); only one of the two processes is running; `/capabilities` doesn't
respond; or the node GUID returned isn't the one assigned to you.

> **A deliberate stop shows as `stopped:`, not `failed:`.** When you stop the node (tray icon or
> `Stop-SynaptronNode.ps1`) the app reads `stopped: Synaptron node was stopped locally.` with a grey
> dot — allow ~30 s for it to settle. A `failed:` you didn't cause is worth a look in `logs\`; note
> the app shows the *last recorded* status when not running, so match it against the log timestamps.

---

## What your GPU can run

**You don't choose from the full catalog.** The Controller sends a catalog already filtered for your
card — each model carries a `minVramGb` requirement and permitted GPU families, and you only see the
ones that fit, so you can't request a model that won't load. What matters is how much your card
unlocks. On a verified **RTX 3060 (12 GB)** that was **43 models across 23 task types**:

| VRAM | Models | What it covers |
|---|---|---|
| < 1 GB | 16 | Classification, translation, NER, summarization, speech-to-text, embeddings — runs on almost any supported card |
| 1–3 GB | 11 | Object detection, image classification, larger embeddings, audio classification |
| 4 GB | 9 | First language models — Qwen 0.5–1.5B, DeepSeek R1-distill, DETR |
| 6–8 GB | 5 | Gemma 2 2B, Llama 3.2 3B, and image generation (SD-Turbo, SDXL-Turbo, SDXL Base) |
| 10–12 GB | 2 | Phi-3.5-mini, Qwen2.5-Coder 7B (int4) — the ceiling for a 12 GB card |

Most task types run on modest hardware; it's the large language models and image generation that
demand VRAM.

---

## Advanced: PowerShell instead of the desktop app

Open **PowerShell as Administrator** in the runner folder and start the node directly:

```powershell
cd C:\SynaptronNode
powershell -ExecutionPolicy Bypass -File .\scripts\start-node-bootstrap-windows.ps1 `
  -ControllerUrl https://orcacontroller.timpi.network `
  -NodeGuid YOUR-NODE-GUID `
  -InstallGpuDependencies
```

If the NVIDIA driver is installed or updated, Windows may need a restart — reboot and run the **same
command again**. The first run also repairs CUDA-enabled PyTorch, the Visual C++ Redistributable,
Python and .NET as needed; if it can't install the driver automatically it opens the official NVIDIA
download page and stops rather than falling back to CPU. The bootstrap dashboard opens at
`http://127.0.0.1:8093/dashboard`, then the supervisor at `http://127.0.0.1:8092/dashboard`.

---

## Updating to a new release

Grab the newer **Windows x64** zip from
[github.com/Timpi-official/Nodes/releases](https://github.com/Timpi-official/Nodes/releases). Stop
the node from the **tray menu** (or run `Stop-SynaptronNode.ps1`), extract the new ZIP over your
`C:\SynaptronNode` folder, then start it again with `Start-SynaptronNode.vbs`.

If the new release ships the same `requirements.txt`, your virtual environment and model cache are
reused and this is quick. Your node GUID (`config\node-guid.txt`) survives the extract.

---

## Uninstall

1. Stop the node — tray menu **Stop**, or:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Stop-SynaptronNode.ps1 -DisableAutostart
   ```
2. Remove autostart (if you enabled it):
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Initialise.ps1 -UninstallAutostart
   ```
3. Delete the `C:\SynaptronNode` folder. Everything — the virtual environment and the model cache —
   lives inside it.

---

## If something goes wrong

| Symptom | Cause and fix |
|---|---|
| SmartScreen *"Windows protected your PC"* | The app isn't code-signed yet. **More info → Run anyway.** |
| The desktop app doesn't open / "desktop app was not found" | You ran it from inside the ZIP or the extract is incomplete. Extract the **whole** ZIP to a folder, then double-click `Start-SynaptronNode.vbs`. |
| `Failed to initialize NVML` / driver mismatch, or nvidia-smi errors | The NVIDIA driver was updated without a reboot. **Reboot**, then start again. |
| Torch fails to load `c10.dll` / DLL load errors | The **Microsoft Visual C++ Redistributable 2015–2022 x64** is missing. The installer normally repairs it; if not, install it and restart the node. |
| `No Python at '"C:\Users\...\python.exe'` | Re-run with the latest runner package; the installer repairs broken venv paths. If a half-installed env remains, delete the local `.venv` folder once and rerun. |
| Preflight says the GPU is below the minimum | The card is older than compute capability 6.1. It cannot run Synaptron. |
| Download seems stuck | It is a multi-GB download. Watch the dashboard/progress before killing it. |
| `Address already in use` on 8091/8092/8093 | The node is already running. Stop it (tray → Stop) before starting a second copy. |
| Node runs but `isOnline` is false | Check outbound HTTPS to `orcacontroller.timpi.network` isn't blocked by a firewall/VPN. The node only makes outbound connections. |

---

*Based on the official Synaptron 2.0.2 Windows runner. The install was verified on a clean Windows 11
machine (RTX 3060) through both the desktop-app and PowerShell paths.*
