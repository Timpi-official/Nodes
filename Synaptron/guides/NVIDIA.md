# 🧬 **Timpi Synaptron — NVIDIA GPU**

<img width="1480" height="862" src="https://github.com/user-attachments/assets/b0749433-3720-4422-a14d-26c4dec067c3"/>

Synaptron is Timpi's AI node. It connects to the Timpi Orca Controller and runs AI workloads —
entity and intent detection, LLM chat, RAG, vision and image generation — depending on your GPU.

The node makes only **outbound** connections. You do not need to open any inbound port.

**NVIDIA is the fully supported vendor: Windows, Linux and Docker.** Pick your platform:

| Platform | Guide | Notes |
|---|---|---|
| **Windows 10 / 11** | **[Windows](NVIDIA-Windows.md)** | Installer `.exe` (recommended), or the runner ZIP + desktop app with a tray icon. **Windows is NVIDIA-only.** |
| **Ubuntu Linux** | **[Linux](NVIDIA-Linux.md)** | `Initialise.sh`, one command, systemd service. |
| **Linux + Docker** | **[Docker](NVIDIA-Docker.md)** | One image, one command; the simplest path if you already run containers. |

Other cards: **[AMD](AMD.md)** (Linux only, through ROCm).

---

## What every platform needs

| | |
|---|---|
| **GPU** | NVIDIA, **RTX 20-series (Turing) or newer** for LLM and image work. GTX 10-series and Tesla P4 (Pascal) join **on the GPU** as a lower tier with a limited task set — support is planned to be phased out in a future release, announced in advance. Minimum compute capability **6.0**. RTX 50-series / Blackwell is supported. |
| **Driver** | **Install it before you start.** RTX 20/30/40 (Turing/Ampere/Ada): **560.94 or newer** recommended; on Linux and Docker what the setup checks is a driver reporting **CUDA 12.0 or newer** (560.35 passes). RTX 50 / Blackwell: **570 or newer reporting CUDA 12.8**, on every platform. Studio Driver preferred over Game Ready. [NVIDIA's driver downloads](https://www.nvidia.com/en-us/drivers/), or `sudo ubuntu-drivers autoinstall` on Ubuntu. |
| **Disk** | **100 GB free.** The runtime alone is ~8 GB (about 15–20 GB for a Docker image); models are downloaded on demand and grow well beyond that. |
| **Time** | **10–20 minutes** on a typical connection, up to 45 on a slow one. Almost all of it is a multi-GB PyTorch/CUDA download. |
| **Your node GUID** | Required — the node refuses to start without it. Register your Timpi Node Access NFT at [timpi.com/node/v2/management](https://timpi.com/node/v2/management) ([registration guide](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md)), then find its GUID at [timpi.se/my-nodes.html](https://timpi.se/my-nodes.html) (connect the wallet that holds the NFT). |

Check the driver and the card before you choose anything:

```bash
nvidia-smi --query-gpu=name,driver_version,compute_cap --format=csv
```

If that prints a name, a version and a capability, you are ready. **Reboot first** if it reports a
**driver/library version mismatch**, if `nvidia-smi` cannot talk to the driver, or if (on Linux)
`/var/run/reboot-required` exists — the installer refuses to run otherwise.

> **Your node GUID is not a plain UUID.** It may contain letters, numbers, dots, colons, underscores
> and hyphens in any arrangement, for example `1a5737d8-example-node-a05f-ee3aba76548b`. Use exactly
> the string you were given. It is your node's credential: the node keeps it out of its own logs,
> banners and pasteable output, and you should keep it out of screenshots and support requests too.

---

## Two PyTorch stacks, and why you don't have to care

No single official PyTorch build spans every supported card, so Synaptron carries two:

| Stack | Cards it is picked for | Compute capability it can run | Driver |
|---|---|---|---|
| **cu124** | GTX 10-series, Tesla P4, RTX 20/30/40, A-series, Hopper | 5.0 – 9.9 (Synaptron accepts 6.0 and up) | CUDA 12.0 or newer |
| **cu128** | RTX 50-series / Blackwell, RTX PRO Blackwell, B200/GB200 | 7.5 – 12.9 | **570+, reporting CUDA 12.8** |

The ranges overlap from 7.5 to 9.9, and every install path still puts those cards on cu124: it runs on
any 12.x driver, where cu128 needs a 570 driver.

A card outside its stack's range fails every GPU operation with *"no kernel image is available for
execution on the device"* while `torch.cuda.is_available()` still returns true — which is why the split
exists and why nothing guesses.

**Every install path picks for you** from the card's compute capability: the Windows installer and
desktop app, `Initialise.sh` on Linux, and the Docker quickstart. The only place you choose by hand is
a manual `docker pull` / `docker run`, and the [Docker guide](NVIDIA-Docker.md#which-tag-to-use) has
the table. A container started on the wrong image is stopped at start-up with the tag you should have
pulled, rather than registering and failing every job.

---

## Once it is running

| | |
|---|---|
| **Is the network seeing me?** | `curl -s https://orcacontroller.timpi.network/api/coordinator/nodes/YOUR-NODE-GUID/status/month` (with **your own GUID** in place of **`YOUR-NODE-GUID`**) — you want `"isOnline": true` and a recent `lastPingUtc`. Or run **`/synaptronchecker`** in Discord with your node GUID. |
| **Local dashboard** | `http://127.0.0.1:8092/dashboard` — proves the local process is up, not that the Controller can see you. Tunnel it on a headless box: `ssh -L 8092:127.0.0.1:8092 USER@NODE-IP`. |
| **An idle node is normal** | Models are not downloaded at install, and a healthy node can sit idle with `loadedModels: []`. The Controller decides what your node loads, when work needs it. **Do not reinstall while waiting.** |

---

*2.1.11 — nothing on this page changes: choosing a path, and the steps on each, are as in 2.1.7. 2.1.11
sends you to [timpi.se/my-nodes.html](https://timpi.se/my-nodes.html) to find your node GUID. 2.1.10
refuses a node ID copied unchanged from a guide's example (`YOUR-NODE-GUID`) and says why, in the log, on the
local dashboard and in the Windows app, where such a node used to show as online. 2.1.9
limits what an image or audio job's input can make a node read (no local files, public URLs only);
2.1.8 before it fixed how a node serves several task types (image and audio input, speech without
`ffmpeg`, question-answering and planning on chat models, image generation). See the set's README.*
