# 🧬 **Timpi Synaptron — AMD GPU (Linux only)**

<img width="1480" height="862" src="https://github.com/user-attachments/assets/b0749433-3720-4422-a14d-26c4dec067c3"/>

Synaptron is Timpi's AI node. It connects to the Timpi Orca Controller and runs AI workloads —
entity and intent detection, LLM chat, RAG, vision and image generation — depending on your GPU.

The node makes only **outbound** connections. You do not need to open any inbound port.

**Supported:** Ubuntu 22.04 LTS or 24.04 LTS, 64-bit, with a working **ROCm** installation.

> **Windows: not supported, and not planned.** There are no ROCm PyTorch wheels for Windows, so an
> AMD card cannot run the node there. The Windows installer and the desktop app are **NVIDIA-only**
> and will refuse an AMD machine. Linux is the only AMD path.
>
> **Docker: no AMD image.** `--gpus` and the NVIDIA Container Toolkit are NVIDIA-only, and no ROCm
> image is published. The native Linux runner below is the whole of it.

Other cards: **[NVIDIA](NVIDIA.md)** (Windows, Linux, Docker).

---

## Contents

- [Before you start](#before-you-start)
- [1. Check ROCm](#1-check-rocm)
- [2. Download and unpack the runner](#2-download-and-unpack-the-runner)
- [3. Install — one command](#3-install--one-command)
- [4. Check that it is working](#4-check-that-it-is-working)
- [What is different from an NVIDIA node](#what-is-different-from-an-nvidia-node)
- [Running more than one AMD GPU](#running-more-than-one-amd-gpu)
- [Updating to a new release](#updating-to-a-new-release)
- [Uninstall](#uninstall)
- [If something goes wrong](#if-something-goes-wrong)

---

## Before you start

| | |
|---|---|
| **GPU** | AMD, **RDNA 2 (RX 6000 series, `gfx1030`) or newer**, or **CDNA (Instinct MI100, `gfx908`) or newer**. Admission is decided on the card's **gfx target** — the AMD counterpart of a CUDA compute capability — not on its name. RDNA 1, Vega and older are refused. **APUs and integrated graphics are not supported:** the pinned ROCm PyTorch build carries no kernels for them, so the node finds no usable device. |
| **ROCm** | **Install it before you start** — **6.1 or newer**, working for the user who will run the node; the pinned PyTorch wheels are the **ROCm 7.2** build, so a current ROCm 7.x is the combination this was measured on. The node checks ROCm and names what is wrong, but it does not install or repair it. Follow AMD's own guide: [ROCm installation on Linux](https://rocm.docs.amd.com/projects/install-on-linux/). |
| **Disk** | **100 GB free.** The runtime alone is ~8 GB; models are downloaded on demand and grow well beyond that. |
| **Time** | **10–20 minutes** on a typical connection, up to 45 on a slow one. Almost all of it is a multi-GB PyTorch/ROCm download. |
| **Your node GUID** | Required — the installer asks for it, and the node refuses to start without it. Register your Timpi Node Access NFT at [timpi.com/node/v2/management](https://timpi.com/node/v2/management) ([registration guide](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md)), then find its GUID at [timpi.se/my-nodes.html](https://timpi.se/my-nodes.html) (connect the wallet that holds the NFT). |

> **Your node GUID is not a plain UUID.** It may contain letters, numbers, dots, colons, underscores
> and hyphens in any arrangement, for example `1a5737d8-example-node-a05f-ee3aba76548b`. Use exactly
> the string you were given.

> **What Timpi supports here is the node installation.** The operating system, the AMD driver and
> ROCm are yours. This is the part operators spend the most time on, and it is worth getting ROCm
> working — and rebooting once after it — before you download anything below.

---

## 1. Check ROCm

Run these **as the user who will own the node**, not as root. All three have to succeed; they are
exactly what the node itself relies on:

```bash
rocminfo | grep -m1 gfx        # your card's gfx target, e.g. gfx1102
rocm-smi                       # lists the card
ls -l /dev/kfd /dev/dri/       # both present, and you can read them
```

What the answers mean:

- **`rocminfo` prints a `gfx…` line** — ROCm can see the card. If it shows only a CPU agent, ROCm is
  not working yet; fix that first.
- **`rocm-smi` lists the card** — the node builds its GPU report from `rocm-smi --json`, and needs
  **ROCm 6.1 or newer** for that report to name the gfx target.
- **`/dev/kfd` and `/dev/dri/` are readable** — if `ls` says permission denied, add yourself to the
  render and video groups, then **log out and back in** (a new shell is not enough):

  ```bash
  sudo usermod -aG render,video "$USER"
  ```

---

## 2. Download and unpack the runner

Get the **Linux x64** runner from the
[releases page](https://github.com/Timpi-official/Nodes/releases). The release carries a
short, stable file name you can paste straight into a terminal:

```bash
cd ~
curl -fLO https://github.com/Timpi-official/Nodes/releases/download/synaptron-2.1.11/synaptron-linux.zip
unzip synaptron-linux.zip -d ~/SynaptronNode
cd ~/SynaptronNode
```

> **Why the short name matters.** The build also publishes the same ZIP under its full, timestamped
> name (`synaptron-node-runner-linux-x64-<version>-<date>.zip`). That name wraps onto two lines in an
> 80-column terminal, and a `curl` command pasted across the wrap runs **with no URL at all** and sits
> there looking like a hang. Use the short name above; if you prefer the timestamped asset, copy its
> URL from the release page and paste it as a single line.

---

## 3. Install — one command

From the unzipped runner folder:

```bash
bash scripts/install-node-amd.sh
```

It asks for the two things only you know — **your Timpi node ID** and the **friendly name** this node
should show — checks them, shows what it is about to run, and on your confirmation runs the whole
install. Run it as your normal user, **not** as root; it asks for `sudo` when the systemd service or
Ubuntu packages need it.

Useful options:

| Option | What it does |
|---|---|
| `--guid <id> --name "My Node"` | Pass the two values instead of being asked. |
| `--yes` | Skip the confirmation prompt. |
| `--dry-run` | Print what would run and stop. Your node ID is never printed. |
| `--no-autostart` | Install and start, but write no systemd service. |
| `--port` / `--dashboard-port` / `--service-name` | For a second node on the same machine (see below). |

It is for a machine with **no node on it**: if a node folder or a `synaptron-node` service is already
present it stops and says so rather than replace anything.

> **The install runs in the foreground for 10–45 minutes.** If you press **Ctrl+Z** it does not
> cancel — Linux **suspends** it and you get your prompt back with the install frozen mid-download.
> Type **`fg`** to resume it. (**Ctrl+C** is the one that cancels.) Nothing is broken either way:
> rerun the same command and it continues.

**What that one command does, in order**

1. **`scripts/detect-gpu-vendor.sh`** decides the vendor from what the drivers report. A machine with
   **both** an NVIDIA and an AMD card is an **NVIDIA machine**: NVIDIA wins the tie and the CUDA stack
   is installed. Remove the NVIDIA card to run on AMD.
2. **`scripts/check-rocm-linux.sh`** runs instead of the NVIDIA preflight. It checks the gfx target
   against the minimum, `rocm-smi`, `/dev/kfd`, `/dev/dri` and your group membership, and — once the
   virtual environment exists — that the installed torch is a **ROCm build that sees the card**. Every
   failure names its cure. **Exit status 3 means the card is below the minimum** and cannot run the
   node.
3. **The AMD opt-in.** AMD support is opt-in for this release: the installer sets
   `SYNAPTRON_ALLOW_AMD_GPU=1` for you. Installing by hand without it stops here and says so.
4. **`scripts/setup-linux.sh`** installs the **ROCm** PyTorch wheel set from
   `constraints/torch-rocm.txt` instead of a CUDA one. **Do not install a CUDA torch into the same
   virtual environment, and do not edit those pins** — the `+rocm` version tags in that file are
   load-bearing, because PyPI publishes a `torchvision` with the same version number that installs
   cleanly and then fails at import.
5. **The systemd service** is written with the AMD opt-in and any ROCm device selection carried into
   it, so the node survives a reboot. A unit written without the opt-in refuses to start on every
   boot.

**What you should see**

The ROCm preflight, in place of the NVIDIA one:

```
==> Detected an AMD GPU. Checking ROCm, devices, and local tooling
==> SynaptronNode ROCm Linux preflight
[PASS] rocminfo: GPU agents report gfx1102
[PASS] gpu-supported: at least one GPU is at or above the Synaptron AMD minimum
[PASS] rocm-smi: reports a card inventory the node can read
[PASS] rocm-smi-gfx: names each card's gfx target, which the Controller admits on
[PASS] dev-kfd: /dev/kfd is present and this user can open it
[PASS] dev-dri: render node(s) present and this user can open them: /dev/dri/renderD128
SynaptronNode ROCm Linux preflight: pass

SYNAPTRON_ALLOW_AMD_GPU is set: continuing on AMD.
```

> A `[WARN] docker: Docker was not found` line, and a summary of `preflight: warn` instead of `pass`,
> is **expected and harmless** — the native runner does not use Docker, and the install continues.

Then the long part — the virtual environment and the ROCm PyTorch stack. **This is where the time
goes**; a progress bar that looks stuck is usually a large wheel downloading. The versions carry a
`+rocm` tag, which is how you know the right stack landed:

```
Detected an AMD GPU. Using the ROCm PyTorch stack.
Successfully installed ... torch-2.14.0+rocm7.2 torchaudio-2.11.0+rocm7.2 torchvision-0.29.0+rocm7.2 ...
```

Then the on-card verification, the host, and the Controller:

```
torch=2.14.0+rocm7.2
torch_cuda_available=True
torch_cuda_device_0=AMD Radeon RX 7600
quantization_4bit=ok, nf4 forward pass on cuda
      Now listening on: http://127.0.0.1:8092
      Connected to Synaptron Controller SignalR hub https://orcacontroller.timpi.network/hubs/synaptron
      Loaded Synaptron model catalog from Controller: https://orcacontroller.timpi.network/api/catalog/models
```

`Connected to … SignalR hub` is the line that matters — your node reached the Controller.

> **`torch_cuda_available=True` on an AMD card is correct, not a mistake.** Under ROCm, AMD's HIP
> runtime answers the whole `torch.cuda` API, so torch reports "cuda" for your Radeon. The node knows
> the difference and reports the card to the Controller as AMD with its gfx target.

Finally:

```
==> Installing Synaptron Node Linux autostart service
Installed systemd service synaptron-node for user <you>.
● synaptron-node.service - Timpi Synaptron Node Bootstrap and Supervisor
     Active: active (running)
```

`active (running)` means you are done.

---

## 4. Check that it is working

**Is my node online?** This is the one that matters — it reads the Controller directly and needs no
login:

**Replace `YOUR-NODE-GUID` with your own GUID here too.** With the example ID left in, this reports someone else's node, which can show online.

```bash
curl -s https://orcacontroller.timpi.network/api/coordinator/nodes/YOUR-NODE-GUID/status/month
```

You want `"isOnline": true` and a recent `lastPingUtc`. The same answer carries your `gpuTier` and the
AMD `generation` the Controller recognised.

**Is the service healthy?**

```bash
systemctl status synaptron-node
journalctl -u synaptron-node -f
```

**Is the card busy?** `rocm-smi` is the `nvidia-smi` of this world:

```bash
rocm-smi --showuse                 # utilisation
rocm-smi --showmeminfo vram        # memory
```

**Local dashboard** — useful while installing, but it only proves the local process is up:

```
http://127.0.0.1:8092/dashboard
```

On a headless server, tunnel it: `ssh -L 8092:127.0.0.1:8092 USER@NODE-IP`.

**Two deeper checks**, both of which run unchanged on AMD:

```bash
.venv/bin/python scripts/verify-install.py   # the installed stack can do the node's work, offline
python3 scripts/workload-test.py --quick     # a running worker actually completes work
```

> `verify-install.py` has to run with the **virtual environment's** Python — that is the one that has
> torch. `workload-test.py` only speaks HTTP to the running worker, so any `python3` will do.

> **An empty model cache on a fresh node is correct.** Models are not downloaded at install — the
> Controller decides what your node loads, when work needs it.

---

## What is different from an NVIDIA node

| | |
|---|---|
| **How the card is judged** | By its **gfx target**, never by a CUDA compute capability. Under ROCm, HIP invents an NVIDIA-shaped capability — an RX 7600 reports 11.0, which in NVIDIA's numbering is Blackwell — so nothing on either side is allowed to judge an AMD card by NVIDIA rules. |
| **Tier and rewards** | The card is tiered by **VRAM**, exactly like an NVIDIA card: an 8 GB Radeon lands in the same tier as an 8 GB GeForce. Rewards use the multiplier for its **AMD generation** (RDNA 2/3/4, CDNA 1–4). |
| **Model catalog** | Slightly smaller. The **vLLM models are NVIDIA-only** — there is no ROCm vLLM build in this stack — so an AMD node is not offered them. Everything else, including **4-bit quantized models**, is offered when the card has the memory for it; `verify-install.py` measures the 4-bit path on your card at install time and the node withholds those models if it fails. |
| **Pinning a card** | `--gpu-uuid` is **NVIDIA-only** (consumer Radeons all report the same UUID). Use ROCm's own selectors — see below. |
| **Docker** | Not available. There is no AMD image. |
| **Windows** | Not available, and not planned. |

---

## Running more than one AMD GPU

One installation folder and one systemd service per GPU, each with its own node ID, ports and service
name. Pin the card with **ROCm's own selector** before you install, and the service carries it:

```bash
ROCR_VISIBLE_DEVICES=1 bash scripts/install-node-amd.sh \
  --port 8093 --dashboard-port 8094 --service-name synaptron-node-gpu2
```

The node follows ROCm's rules exactly:

- `ROCR_VISIBLE_DEVICES` takes precedence over `HIP_VISIBLE_DEVICES`, which takes precedence over
  `CUDA_VISIBLE_DEVICES`.
- Indexes are physical card numbers in `rocm-smi` order.
- A selector the node cannot interpret makes it report **no GPU** rather than every GPU — two nodes
  advertising the same card knock each other off the network, so this fails safe on purpose.
- An **unpinned** node on a multi-card machine advertises every card, and warns that it did.

| Setup | Supported |
|---|---|
| **One node per GPU**, several cards in one machine | ✅ Yes — one instance per card, each pinned |
| One node spanning **several GPUs** | ❌ No |
| **Several nodes on one GPU** | ❌ No |
| **Mixed AMD + NVIDIA in one machine** | ❌ Not as two nodes — the machine installs as NVIDIA |

> Do not reuse a node GUID on a second machine or a second GPU. Each instance needs its own. A
> dashboard on a LAN address has no authentication or TLS — use a trusted network or a VPN only.

---

## Updating to a new release

Set `VER` to the newest `synaptron-<version>` release on the
[releases page](https://github.com/Timpi-official/Nodes/releases) (that repository also publishes the
Timpi Collector, so its "Latest" release is not necessarily a Synaptron one):

**1. Download, and check whether the Python packages changed** (nothing is replaced yet):

```bash
VER=2.1.11
cd ~ && curl -fLO "https://github.com/Timpi-official/Nodes/releases/download/synaptron-$VER/synaptron-linux.zip"
for f in requirements.txt $(unzip -Z1 synaptron-linux.zip 'constraints/*.txt'); do
  [ -f ~/SynaptronNode/"$f" ] || continue
  unzip -p synaptron-linux.zip "$f" | cmp -s - ~/SynaptronNode/"$f" || echo "changed: $f"
done
```

**No output** means the new release pins the same packages as your install (`requirements.txt` and every
file in `constraints/`, `torch-rocm.txt` included), so your virtual environment and model cache are
reused and step 2 takes seconds. That is the case from 2.1.6, the first AMD release, through 2.1.11.

**2. Replace the files and restart:**

```bash
sudo systemctl stop synaptron-node
unzip -o synaptron-linux.zip -d ~/SynaptronNode
sudo systemctl start synaptron-node
```

If step 1 printed a `changed:` line, run `bash scripts/install-node-amd.sh` again on a machine whose node
you first removed, or rerun the by-hand `Initialise.sh` command with the AMD opt-in. Your node GUID
lives in the systemd service, so it survives the unzip either way.

---

## Uninstall

**Remove autostart first**, then delete the folder — in that order:

```bash
bash ./Initialise.sh --uninstall-autostart
cd ~ && rm -rf ~/SynaptronNode
```

> Deleting the folder on its own leaves a systemd service behind that keeps trying to start a program
> that is no longer there.

ROCm itself is untouched by this; remove it with AMD's own instructions if you no longer want it.

---

## If something goes wrong

| Symptom | Cause and fix |
|---|---|
| `curl` appears to hang and downloads nothing | The download URL was pasted across a line wrap, so `curl` ran with no URL. Use the short `synaptron-linux.zip` name, on one line. |
| The install froze and you have your prompt back | **Ctrl+Z** suspended it. Type **`fg`** to resume. |
| `rocminfo` shows only a CPU agent | ROCm is not working yet. Reinstall or repair ROCm from AMD's guide, reboot, and check again before installing the node. |
| `ls: /dev/kfd: Permission denied` | You are not in the render/video groups. `sudo usermod -aG render,video "$USER"`, then log out and back in. |
| ROCm preflight fails with **exit status 3** | The card is below the minimum (RDNA 2 / `gfx1030`, or CDNA / `gfx908`). It cannot run the node. |
| `AMD support is not enabled on this node` | You ran `Initialise.sh` by hand without the opt-in. Use `scripts/install-node-amd.sh`, or set `SYNAPTRON_ALLOW_AMD_GPU=1`. |
| The service refuses to start on every boot, but a manual run works | The unit was written without the AMD opt-in. Reinstall autostart with `install-node-amd.sh`, which carries it in. |
| The install picked CUDA on an AMD machine | The machine also has an NVIDIA card, and NVIDIA wins the tie. Remove the NVIDIA card to run on AMD. |
| `torchvision` installs and then fails at import | A non-`+rocm` wheel got in. Delete `.venv` and reinstall; do not edit `constraints/torch-rocm.txt`. |
| The node registers but is offered no models | The Controller's catalog has not been told your card is welcome. Report it — the node side is fine. |
| Node runs but `isOnline` is false | Check outbound HTTPS to `orcacontroller.timpi.network` is not blocked. The node only makes outbound connections. |
| The log says `will not connect: The node ID is an example value from a guide`, and `http://127.0.0.1:8092/` says **Not connecting** | You installed with the guide's example (`YOUR-NODE-GUID`). Copy your node's ID from [timpi.se/my-nodes.html](https://timpi.se/my-nodes.html) and run `bash scripts/install-node-amd.sh --guid <that id>` again. Before 2.1.10 the node accepted the example and its work was credited to nobody. |
| `not in the usual form of a Timpi node ID` (a warning; the node still starts) | Your ID is not 8-4-4-4-12 hex digits. Check it character by character against [timpi.se/my-nodes.html](https://timpi.se/my-nodes.html): a mistyped ID registers as a different node, and your own shows offline. |
| Several AMD nodes, and one keeps dropping off | Two of them are advertising the same card. Pin each with `ROCR_VISIBLE_DEVICES` and reinstall its service. |

---

*AMD support arrived in 2.1.6 and is **opt-in**; 2.1.11 changes nothing in the install on this page (it only moves the link for finding your node GUID;
2.1.10 refuses the guide's example node ID,
measured on the same card), and 2.1.9's input rules and 2.1.8's task fixes were run on the same card. Measured end to
end on a **Radeon RX 7600** (`gfx1102`,
RDNA 3, 8 GB) under ROCm 7.x on Ubuntu 24.04: install from the release ZIP, ROCm preflight,
`verify-install.py` with the 4-bit path measured on the card, `workload-test.py --quick` 6/6,
registration on the production Controller, and jobs dispatched from the Controller completed. Other
RDNA 2/3/4 and CDNA/Instinct cards are admitted by the gfx-target rule but have not been measured
individually; if you run one, please report what you see. Measured twice on that card — once on
2026-09-19 and again on 2026-09-21 from the 2.1.6 code, including that the node ID stays out of the
service journal and the install logs.*
