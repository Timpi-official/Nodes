# 🧬 **Timpi Synaptron — Ubuntu Linux**

<img width="1480" height="862" src="https://github.com/user-attachments/assets/b0749433-3720-4422-a14d-26c4dec067c3"/>

Synaptron is Timpi's AI node. It connects to the Timpi Orca Controller and runs AI workloads —
entity and intent detection, LLM chat, RAG, vision and image generation — depending on your GPU.

The node makes only **outbound** connections. You do not need to open any inbound port.

**Supported:** Ubuntu 22.04 LTS or 24.04 LTS, 64-bit.

---

## Before you start

| | |
|---|---|
| **GPU** | NVIDIA, RTX 20-series (Turing) or newer for LLM and image work. GTX 10-series (Pascal) can join, but only for legacy low-tier tasks. Minimum compute capability 6.1. |
| **Driver** | **Install it before you start.** 560.94 or newer; RTX 50-series / Blackwell needs 570+. Studio Driver preferred over Game Ready — these machines run compute workloads, where stability matters more than day-one game support. |
| **Disk** | **100 GB free.** The runtime alone is ~8 GB; models are downloaded on demand and grow well beyond that. |
| **Time** | **10–20 minutes** on a typical connection, up to 45 on a slow one; under 10 on a fast one. Almost all of it is a multi-GB PyTorch/CUDA download. |
| **Your node GUID** | Required — this is what you pass in with `--node-guid`, and the node refuses to start without it. You get it by registering your Timpi Node Access NFT at [timpi.com/node/v2/management](https://timpi.com/node/v2/management); see the [registration guide](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md). |

Check your driver before anything else:

```bash
nvidia-smi --query-gpu=name,driver_version --format=csv
```

If that prints a name and a version, you are ready. **Reboot first** if any of these is true: the
command reports a **driver/library version mismatch**, `nvidia-smi` fails to talk to the driver, or
`/var/run/reboot-required` exists — the installer will refuse to run otherwise.

> **Where to get the driver.** If `nvidia-smi` isn't installed yet, the simplest route on Ubuntu is
> `sudo ubuntu-drivers autoinstall`, then reboot — it picks a driver that matches your card. To choose
> a specific version instead, download it from [NVIDIA's driver downloads](https://www.nvidia.com/en-us/drivers/)
> (select your GPU and Linux 64-bit) and follow NVIDIA's own install steps. Confirm your card is
> CUDA-capable first: [CUDA-compatible GPUs](https://developer.nvidia.com/cuda-gpus).

> **Your node GUID is not a plain UUID.** It may contain letters and hyphens in any arrangement, for
> example `1a5737d8-example-node-a05f-ee3aba76548b`. Use exactly the string you were given.

---

## Install

**1. Download the runner**

Get the Linux runner from the official release:

```bash
cd ~
curl -LO https://github.com/Timpi-official/Nodes/releases/download/synaptron-2.0.2/synaptron-node-runner-linux-x64-2.0.2-20260726-213822.zip
```

> Newer versions, when released, are listed at
> [github.com/Timpi-official/Nodes/releases](https://github.com/Timpi-official/Nodes/releases) — always
> take the latest Linux x64 zip.

**2. Unpack the runner**

```bash
unzip synaptron-node-runner-linux-x64-*.zip -d ~/SynaptronNode
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

Run this as your normal user, **not** as root. It asks for your `sudo` password once, to install
system packages and register the service. On a **headless server over a non-interactive SSH command**
it will stop early with a note to reconnect with `ssh -t`, run `sudo -v` first, or configure
passwordless sudo — do one of those and rerun.

**What you should see**

First the hardware check:

```
==> Checking NVIDIA driver, GPU, CUDA compatibility, and local tooling
[PASS] nvidia-smi: /usr/bin/nvidia-smi
[PASS] gpu: 0, NVIDIA GeForce RTX 3060, GPU-7da0df14-..., 12288, 580.173.02, 8.6
[PASS] gpu-minimum-requirement: 1 GPU(s) meet Synaptron minimum compute capability 6.1+.
[PASS] cuda-driver-runtime: Driver reports CUDA 13.0.
SynaptronNode NVIDIA Linux preflight: pass

==> Selecting Transformers device
Transformers device: Cuda
```

> If Docker isn't installed you'll see one extra line, `[WARN] docker: Docker was not found. Needed
> for Linux container mode.`, and the summary will say `preflight: warn` instead of `pass`. That is
> **expected and harmless** — the normal runner does not use Docker, and the install continues.

Then the long part — the virtual environment and PyTorch. **This is where the time goes**; a
progress bar that looks stuck is usually a large wheel downloading (cuDNN alone is ~658 MB). When it
finishes it confirms your GPU:

```
torch=2.11.0+cu128
gliner_import=ok
torch_cuda_available=True
torch_cuda_device_0=NVIDIA GeForce RTX 3060
torch_cuda_capability_0=sm_86
torch_cuda_arch_list=sm_75,sm_80,sm_86,sm_90,sm_100,sm_120
```

`torch_cuda_available=True` is the line that matters — it means PyTorch can see your GPU.

Finally the service is registered:

```
==> Installing Synaptron Node Linux autostart service
Created symlink /etc/systemd/system/multi-user.target.wants/synaptron-node.service → ...
Installed systemd service synaptron-node for user <you>.
● synaptron-node.service - Timpi Synaptron Node Bootstrap and Supervisor
     Active: active (running)
```

`active (running)` means you are done.

### If the hardware check fails

`--install-gpu-dependencies` is a **repair path, not the normal one** — the driver is expected to be
working before you start. If the check fails and the installer repairs the driver, that repair sets
a pending reboot, so the run stops with:

```
The operating system reports a pending reboot. Changed packages: <the packages>. Reboot before starting Synaptron.
```

That is expected. Reboot, run the **same command again**, and it continues from the hardware check.

---

## Check that it is working

**Is my node online?** This is the one that matters. It reads the Controller directly, needs no
login, and works from any machine:

```bash
curl -s https://orcacontroller.timpi.network/api/coordinator/nodes/YOUR-NODE-GUID/status/month
```

You want `"isOnline": true` and a recent `lastPingUtc`. `availabilityPercent` is your uptime for the
month — if you installed mid-month it looks low until the month turns over, which is normal.

**Is the service healthy?**

```bash
systemctl status synaptron-node
```

**Local dashboard** — useful while installing, but a working dashboard only proves the local process
is up, not that the Controller can see you:

```
http://127.0.0.1:8092/dashboard
```

On a headless server, tunnel it from your own machine:

```bash
ssh -L 8092:127.0.0.1:8092 USER@NODE-IP
```

**Logs:** `~/SynaptronNode/logs/`, or `journalctl -u synaptron-node -f` for the service.

> **An empty model cache on a fresh node is correct.** Models are not downloaded at install — the
> Controller decides what your node loads, when work needs it.

---

## Updating to a new release

Grab the newer Linux zip from
[github.com/Timpi-official/Nodes/releases](https://github.com/Timpi-official/Nodes/releases), then
unpack it over the top of your existing folder:

```bash
sudo systemctl stop synaptron-node
unzip -o synaptron-node-runner-linux-x64-*.zip -d ~/SynaptronNode
sudo systemctl start synaptron-node
```

If the new release ships the same `requirements.txt`, your virtual environment and model cache are
reused and this takes seconds instead of the full install. Compare before you start:

```bash
diff ~/SynaptronNode/requirements.txt /path/to/new/requirements.txt
```

If they differ, run the full `Initialise.sh` command from step 2 again instead. Your node GUID lives in
the systemd service, not in the folder, so it survives the unzip either way.

---

## Uninstall

**Remove autostart first**, then delete the folder — in that order:

```bash
bash ./Initialise.sh --uninstall-autostart
cd ~ && rm -rf ~/SynaptronNode
```

> Deleting the folder on its own leaves a systemd service behind that keeps trying to start a
> program that is no longer there.

Everything else lives inside the folder, including the virtual environment and the model cache.

---

## If something goes wrong

| Symptom | Cause and fix |
|---|---|
| `Failed to initialize NVML: Driver/library version mismatch` | The NVIDIA driver was updated without a reboot. **Reboot**, then run the command again. |
| Install stops with `The operating system reports a pending reboot` | A reboot is pending — often from a kernel update rather than NVIDIA. Reboot, then run the same command again. The message lists the exact packages from `/var/run/reboot-required.pkgs`. |
| `NVIDIA preflight failed because this GPU is below the Synaptron minimum requirement` | The card is older than compute capability 6.1. It cannot run Synaptron. |
| `This is a non-interactive shell without passwordless sudo` | You ran the installer over a non-interactive SSH command. Reconnect with `ssh -t`, run `sudo -v` first, or configure passwordless sudo, then rerun. |
| Download seems stuck | It is a multi-GB download. Check the log is still growing before killing it. |
| `Address already in use` on 8091 or 8092 | The service is already running. `sudo systemctl stop synaptron-node` before troubleshooting by hand, then start it again. |
| Node runs but `isOnline` is false | Check outbound HTTPS to `orcacontroller.timpi.network` is not blocked. The node only makes outbound connections. |
| Service keeps restarting | `journalctl -u synaptron-node -n 50` — the supervisor restarts on failure, so a loop means the node itself is exiting. |

## Running more than one GPU

Three cases, and only one of them works — the distinction is what usually trips people up:

| Setup | Supported |
|---|---|
| **One node per GPU**, several cards in one machine | ✅ Yes — run one instance per card |
| One node spanning **several GPUs** | ❌ No |
| **Several nodes on one GPU** | ❌ No — both report the same GPU UUID and the network flags the duplicate |

> **"But my node only uses ~2 GB of VRAM."** True, and a bigger card is still used fully — just not by
> running more nodes on it. The Controller loads *larger* models on RTX 40/50-class cards, or several
> smaller models onto the same node, so the capacity is used through **more models on one node**, not
> more node identities.
>
> The only real exception is hardware partitioning with **NVIDIA MIG** (A100, A30, H100/H200,
> B200/GB200, RTX PRO Blackwell 6000/5000/4500). Consumer cards — RTX 2060–5090, 3090, 4090, 5090 and
> the GTX 10-series — **do not support MIG**, so on those it is strictly one node per card.

For a machine with several cards, give each instance its own folder, node GUID, ports, service name
and GPU UUID. List your GPUs:

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

> Do not reuse a node GUID on a second machine or a second GPU. Each instance needs its own.
>
> If you expose a dashboard on a LAN address it has no authentication or TLS — use a trusted network
> or a VPN only.

---

---

*Tested on Ubuntu, RTX 3060 12 GB, driver 580.173.02, runner 2.0.2 build 20260725-162849.*
