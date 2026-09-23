# 🧬 **Timpi Synaptron — NVIDIA on Ubuntu Linux**

<img width="1480" height="862" src="https://github.com/user-attachments/assets/b0749433-3720-4422-a14d-26c4dec067c3"/>

Synaptron is Timpi's AI node. It connects to the Timpi Orca Controller and runs AI workloads —
entity and intent detection, LLM chat, RAG, vision and image generation — depending on your GPU.

The node makes only **outbound** connections. You do not need to open any inbound port.

**Supported:** Ubuntu 22.04 LTS or 24.04 LTS, 64-bit, with an NVIDIA GPU.

> **Prefer containers?** The [Docker guide](NVIDIA-Docker.md) is simpler — one image, one command,
> and it picks the right build for your card automatically.
>
> **On an AMD card?** This page will not work. See the [AMD guide](AMD.md) — Linux only, through ROCm.

---

## Before you start

| | |
|---|---|
| **GPU** | NVIDIA, RTX 20-series (Turing) or newer for LLM and image work. GTX 10-series and Tesla P4 (Pascal) join **on the GPU** as a lower tier with a limited task set — support is planned to be phased out in a future release, announced in advance. Minimum compute capability **6.0**. RTX 50-series / Blackwell is supported. |
| **Driver** | **Install it before you start.** 560.94 or newer; RTX 50-series / Blackwell needs **570+ reporting CUDA 12.8**. Studio Driver preferred over Game Ready. |
| **Disk** | **100 GB free.** The runtime alone is ~8 GB; models are downloaded on demand and grow well beyond that. |
| **Time** | **10–20 minutes** on a typical connection, up to 45 on a slow one. Almost all of it is a multi-GB PyTorch/CUDA download. |
| **Your node GUID** | Required — you pass it with `--node-guid`, and the node refuses to start without it. Register your Timpi Node Access NFT at [timpi.com/node/v2/management](https://timpi.com/node/v2/management); see the [registration guide](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md). |

Check your driver before anything else:

```bash
nvidia-smi --query-gpu=name,driver_version,compute_cap --format=csv
```

If that prints a name, a version and a capability, you are ready. **Reboot first** if any of these is
true: the command reports a **driver/library version mismatch**, `nvidia-smi` cannot talk to the
driver, or `/var/run/reboot-required` exists — the installer will refuse to run otherwise.

> **Where to get the driver.** If `nvidia-smi` isn't installed yet, the simplest route on Ubuntu is
> `sudo ubuntu-drivers autoinstall`, then reboot. To choose a specific version, download it from
> [NVIDIA's driver downloads](https://www.nvidia.com/en-us/drivers/). Confirm your card is CUDA-capable
> first: [CUDA-compatible GPUs](https://developer.nvidia.com/cuda-gpus).

> **Your node GUID is not a plain UUID.** It may contain letters, numbers, dots, colons, underscores
> and hyphens in any arrangement, for example `1a5737d8-example-node-a05f-ee3aba76548b`. Use exactly
> the string you were given.

---

## Install

**1. Download the runner**

The release carries a short, stable file name you can paste straight into a terminal:

```bash
cd ~
curl -fLO https://github.com/Timpi-official/Nodes/releases/download/synaptron-2.1.7/synaptron-linux.zip
```

> **Why the short name.** The release also publishes the same ZIP under its full, timestamped name
> (`synaptron-node-runner-linux-x64-2.1.7-<date>.zip`). That name wraps onto two lines in an 80-column
> terminal, and a `curl` command pasted across the wrap runs **with no URL at all** and sits there
> looking like a hang. Use the short name; if you prefer the versioned asset, copy its URL from the
> [releases page](https://github.com/Timpi-official/Nodes/releases) and paste it as a single line.
>
> To check the download, fetch `SHA256SUMS` from the same release and run `sha256sum -c SHA256SUMS`.
> Both names are listed in it, with the same digest — they are copies of the same bytes.

**2. Unpack the runner**

```bash
unzip synaptron-linux.zip -d ~/SynaptronNode
cd ~/SynaptronNode
```

**3. Run the installer**

Replace `YOUR-NODE-GUID` with the node GUID assigned to this machine:

```bash
bash ./Initialise.sh \
  --controller-url https://orcacontroller.timpi.network \
  --node-guid YOUR-NODE-GUID \
  --install-gpu-dependencies \
  --install-production-deps \
  --install-autostart
```

Run this as your normal user, **not** as root. It asks for your `sudo` password once. No `chmod` is
needed — Synaptron invokes its own scripts through `bash` even when a ZIP extractor dropped the
execute bit.

> **The install runs in the foreground for 10–45 minutes.** If you press **Ctrl+Z** it does not
> cancel — Linux **suspends** it and you get your prompt back with the install frozen mid-download.
> Type **`fg`** to resume. (**Ctrl+C** is the one that cancels.) Either way, rerunning the same
> command continues from where it stopped.

> On a **headless server over a non-interactive SSH command** it stops early with a note to reconnect
> with `ssh -t`, run `sudo -v` first, or configure passwordless sudo — do one of those and rerun.

> **GTX 10-series / Tesla P4 (Pascal) cards** run **on the GPU** (the cu124 stack) as a lower tier with
> a limited set of tasks — no extra flag needed, the installer picks the right stack automatically.
> Pascal support is planned to be phased out in a future release; that will be announced in advance.
> Check your card with `nvidia-smi --query-gpu=name,compute_cap --format=csv`: **6.1** is Pascal (lower
> tier), **7.5+** is a full tier.

**What you should see**

First the hardware check:

```
==> Checking NVIDIA driver, GPU, CUDA compatibility, and local tooling
[PASS] nvidia-smi: /usr/bin/nvidia-smi
[PASS] gpu: 0, NVIDIA GeForce RTX 4060 Ti, GPU-51fe9889-..., 16380, 580.65.06, 8.9
[PASS] gpu-minimum-requirement: 1 GPU(s) meet Synaptron minimum compute capability 6.0+.
[PASS] cuda-driver-runtime: Driver reports CUDA 12.6.
SynaptronNode NVIDIA Linux preflight: pass

==> Selecting Transformers device
Transformers device: Cuda
```

> If Docker isn't installed you'll see one extra line, `[WARN] docker: Docker was not found`, and the
> summary says `preflight: warn` instead of `pass`. That is **expected and harmless** — the native
> runner does not use Docker, and the install continues.

Then the long part — the virtual environment and PyTorch. **This is where the time goes**; a progress
bar that looks stuck is usually a large wheel downloading. When the ML stack finishes you'll see the
pinned versions. On most cards that is the **cu124** set:

```
Successfully installed ... torch-2.6.0+cu124 torchaudio-2.6.0+cu124 torchvision-0.21.0+cu124 ...
Successfully installed ... transformers-5.13.1 accelerate-1.14.0 bitsandbytes-0.50.0 sentence-transformers-5.6.1 ...
```

On an RTX 50-series / Blackwell card the installer selects the **cu128** set instead, and the torch
line reads `torch-2.11.0+cu128 torchaudio-2.11.0+cu128 torchvision-0.26.0+cu128`. Everything after the
torch line is the same on both.

Then the host starts and reaches the Controller:

```
      Now listening on: http://127.0.0.1:8092
      Application started. Press Ctrl+C to shut down.
      Connected to Synaptron Controller SignalR hub https://orcacontroller.timpi.network/hubs/synaptron
      Loaded Synaptron model catalog from Controller: https://orcacontroller.timpi.network/api/catalog/models
```

`Connected to … SignalR hub` is the line that matters — your node reached the Controller.

Finally the service is registered:

```
==> Installing Synaptron Node Linux autostart service
Created symlink /etc/systemd/system/multi-user.target.wants/synaptron-node.service → ...
Installed systemd service synaptron-node for user <you>.
● synaptron-node.service - Timpi Synaptron Node Bootstrap and Supervisor
     Active: active (running)
```

`active (running)` means you are done.

> **Your node ID is not printed** in the install output, the service journal or the local dashboard's
> pasteable views. That is deliberate: the ID is your node's credential, and install output is what
> gets pasted into a support request. The dashboard tells you whether one is configured, not what it
> is.

### If the hardware check fails

`--install-gpu-dependencies` is a **repair path, not the normal one** — the driver is expected to be
working before you start. If it repairs the driver, that repair sets a pending reboot, so the run stops
with:

```
The operating system reports a pending reboot. Changed packages: <the packages>. Reboot before starting Synaptron.
```

That is expected. Reboot, run the **same command again**, and it continues from the hardware check.

---

## Check that it is working

**Is my node online?** This is the one that matters — it reads the Controller directly, needs no login:

```bash
curl -s https://orcacontroller.timpi.network/api/coordinator/nodes/YOUR-NODE-GUID/status/month
```

You want `"isOnline": true` and a recent `lastPingUtc`. `availabilityPercent` is your uptime for the
month — low right after a mid-month install is normal.

**Is the service healthy?**

```bash
systemctl status synaptron-node
```

**Local dashboard** — useful while installing, but only proves the local process is up:

```
http://127.0.0.1:8092/dashboard
```

On a headless server, tunnel it: `ssh -L 8092:127.0.0.1:8092 USER@NODE-IP`.

**Logs:** `~/SynaptronNode/logs/`, or `journalctl -u synaptron-node -f` for the service.

**Does it actually complete work?** Two checks ship with the node:

```bash
.venv/bin/python scripts/verify-install.py        # the installed stack can do the node's work, offline
python3 scripts/workload-test.py --quick          # a running worker completes work, not just registers
```

`verify-install.py` needs the virtual environment's Python — that is the one with torch.
`workload-test.py` only speaks HTTP to the running worker, so any `python3` will do.

> **An empty model cache on a fresh node is correct.** Models are not downloaded at install — the
> Controller decides what your node loads, when work needs it. A node can sit **idle** without
> receiving a task and still be perfectly healthy; do not reinstall or reconfigure while waiting.

---

## Updating to a new release

Set `VER` to the newest `synaptron-<version>` release on the
[releases page](https://github.com/Timpi-official/Nodes/releases) (that repository also publishes the
Timpi Collector, so its "Latest" release is not necessarily a Synaptron one):

```bash
VER=2.1.7
sudo systemctl stop synaptron-node
cd ~ && curl -fLO "https://github.com/Timpi-official/Nodes/releases/download/synaptron-$VER/synaptron-linux.zip"
unzip -o synaptron-linux.zip -d ~/SynaptronNode
sudo systemctl start synaptron-node
```

If the new release ships the same `requirements.txt`, your venv and model cache are reused and this
takes seconds. Compare first: `diff ~/SynaptronNode/requirements.txt /path/to/new/requirements.txt`. If
they differ, run the full `Initialise.sh` command again. Your node GUID lives in the systemd service,
so it survives the unzip either way.

---

## Uninstall

**Remove autostart first**, then delete the folder — in that order:

```bash
bash ./Initialise.sh --uninstall-autostart
cd ~ && rm -rf ~/SynaptronNode
```

> Deleting the folder on its own leaves a systemd service behind that keeps trying to start a program
> that is no longer there.

---

## If something goes wrong

| Symptom | Cause and fix |
|---|---|
| `curl` appears to hang and downloads nothing | The download URL was pasted across a line wrap, so `curl` ran with no URL. Use the short `synaptron-linux.zip` name, on one line. |
| The install froze and you have your prompt back | **Ctrl+Z** suspended it. Type **`fg`** to resume. |
| `unzip` says `filename not matched` and extracts nothing | Extra words landed on the command line after the ZIP name (a wrapped paste, or a terminal status line copied with it). To `unzip` those are a list of members to extract. Retype the command on one line. |
| `Failed to initialize NVML: Driver/library version mismatch` | The NVIDIA driver was updated without a reboot. **Reboot**, then run the command again. |
| Install stops with `The operating system reports a pending reboot` | A reboot is pending. Reboot, then run the same command again. |
| `NVIDIA preflight failed because this GPU is below the Synaptron minimum requirement` | The card is below compute capability 6.0. It cannot run Synaptron. |
| `This is a non-interactive shell without passwordless sudo` | You ran the installer over a non-interactive SSH command. Reconnect with `ssh -t`, run `sudo -v` first, or configure passwordless sudo, then rerun. |
| Download seems stuck | It is a multi-GB download. Check the log is still growing before killing it. |
| `Address already in use` on 8091 or 8092 | The service is already running. `sudo systemctl stop synaptron-node` first. |
| Node runs but `isOnline` is false | Check outbound HTTPS to `orcacontroller.timpi.network` is not blocked. The node only makes outbound connections. |
| Service keeps restarting | `journalctl -u synaptron-node -n 50` — a loop means the node itself is exiting. |

---

## Running more than one GPU

| Setup | Supported |
|---|---|
| **One node per GPU**, several cards in one machine | ✅ Yes — one instance per card |
| One node spanning **several GPUs** | ❌ No |
| **Several nodes on one GPU** | ❌ No — both report the same GPU UUID and the network flags the duplicate |

For a machine with several cards, give each instance its own folder, node GUID, ports, service name and
GPU UUID. List your GPUs:

```bash
nvidia-smi --query-gpu=index,name,uuid --format=csv,noheader
```

Then for the second card:

```bash
cd ~/SynaptronNode-Gpu2
bash ./Initialise.sh \
  --controller-url https://orcacontroller.timpi.network \
  --node-guid SECOND-NODE-GUID \
  --gpu-uuid GPU-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
  --port 8093 \
  --dashboard-port 8094 \
  --service-name synaptron-node-gpu2 \
  --install-production-deps \
  --install-autostart
```

> Do not reuse a node GUID on a second machine or a second GPU. Each instance needs its own. A dashboard
> on a LAN address has no authentication or TLS — use a trusted network or a VPN only.

---

*2.1.7 — the native Linux path is unchanged from 2.1.6. Verified on the
rig, Ubuntu, RTX 4060 Ti (cu124): `Initialise.sh` built the venv (torch 2.6.0+cu124, transformers
5.13.1), the host reached the Controller's SignalR hub, loaded the catalog, and served every task type
(embedding, translation, chat, summarization, question-answering).*
