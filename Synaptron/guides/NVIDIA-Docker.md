# 🐳 **Timpi Synaptron — NVIDIA in Docker (Linux)**

<img width="1480" height="862" src="https://github.com/user-attachments/assets/b0749433-3720-4422-a14d-26c4dec067c3"/>

Synaptron is Timpi's AI node. This guide runs it as a **Docker container** — the whole runtime
(the .NET supervisor, the Python worker, PyTorch/CUDA) is baked into one image, so there is no venv,
no `apt`, no driver-repair step on the host. You pull one image and run one command.

The node makes only **outbound** connections. You do not need to open any inbound port.

**Supported:** Linux with an **NVIDIA GPU**.

> **Docker Desktop on Windows or macOS is not supported for GPU work.** On Windows use the
> [Windows guide](NVIDIA-Windows.md).
>
> **There is no AMD image.** `--gpus` and the NVIDIA Container Toolkit are NVIDIA-only. An AMD card
> runs the node as a native Linux install — see the [AMD guide](AMD.md).

> **Two images, one per GPU generation.** Synaptron ships **`cu124`** (Pascal → Hopper: GTX 10-series,
> RTX 20/30/40, A-series, Hopper) and **`cu128`** (Blackwell: RTX 50-series, RTX PRO Blackwell,
> B200/GB200). No single PyTorch build spans both, so the tag has to match the card. The
> **quickstart below reads your card and picks for you**; the manual path shows how to choose by hand.

---

## Contents

- [Before you start](#before-you-start)
- [1. Verify Docker can use your GPU](#1-verify-docker-can-use-your-gpu)
- [2. Install — one command (quickstart)](#2-install--one-command-quickstart)
- [3. Check it's working](#3-check-its-working)
- [4. Keep it updated automatically — Watchtower](#4-keep-it-updated-automatically--watchtower)
- [Which tag to use](#which-tag-to-use)
- [Manual install (choose the image yourself)](#manual-install-choose-the-image-yourself)
- [Running more than one GPU](#running-more-than-one-gpu)
- [Managing the node](#managing-the-node)
- [If something goes wrong](#if-something-goes-wrong)
- [Uninstall](#uninstall)

---

## Before you start

| | |
|---|---|
| **GPU** | NVIDIA, compute capability **6.0+**. RTX 20-series / Turing or newer for LLM and image work; GTX 10-series (Pascal) joins for lighter tasks. RTX 50-series / Blackwell is supported via the **cu128** image. |
| **Driver** | A working NVIDIA driver on the **host** — `nvidia-smi` must run. RTX 20/30/40: 560.94+. RTX 50 / Blackwell: **570+ reporting CUDA 12.8**. Get it from [NVIDIA's driver downloads](https://www.nvidia.com/en-us/drivers/) or, on Ubuntu, `sudo ubuntu-drivers autoinstall`. |
| **Docker** | Installed and running. |
| **NVIDIA Container Toolkit** | **This is the one Docker-specific requirement** — it lets containers use the GPU. Install: [official guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html). Step 1 below verifies it. |
| **Disk** | about **15 GB** for the cu124 image once extracted (~5 GB compressed on the pull); about **20 GB** for cu128. Models are downloaded on demand into a volume and grow beyond that. |
| **Your node GUID** | Required — the node refuses to start without it. Register your Timpi Node Access NFT at [timpi.com/node/v2/management](https://timpi.com/node/v2/management); see the [registration guide](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md). |

> **Your node GUID is not a plain UUID.** It may contain letters, numbers, dots, colons, underscores
> and hyphens in any arrangement, for example `1a5737d8-example-node-a05f-ee3aba76548b`. Use exactly
> the string you were given.

---

## 1. Verify Docker can use your GPU

Before anything else, confirm the NVIDIA Container Toolkit works:

```bash
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

**What you should see** — a table listing your GPU, e.g.:

```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 580.xx       Driver Version: 580.xx       CUDA Version: 13.0      |
|   0  NVIDIA GeForce RTX 4060 Ti      ...      16380MiB                        |
+-----------------------------------------------------------------------------+
```

If it prints your card, you're ready. If it errors on `--gpus`, install the **NVIDIA Container Toolkit**
(link in the table above) and try again.

---

## 2. Install — one command (quickstart)

The quickstart reads your card, picks the right image (**cu124** or **cu128**), pulls it, and starts the
node. It asks for your GUID and a name if you don't pass them.

Run this command, replacing the bold values with your own:

<pre>
bash &lt;(curl -fsSL https://raw.githubusercontent.com/Timpi-official/Nodes/main/Synaptron/scripts/docker-quickstart.sh) \
  --guid <b>YOUR-NODE-GUID</b> --name "<b>My Synaptron</b>" --publish-dashboard
</pre>

**What you should see** — it detects the card, resolves the image, pulls and starts, then waits for the
Controller:

```
==> Checking Docker and the GPU
GPU:    [0] NVIDIA GeForce RTX 4060 Ti, 16380 MiB, compute 8.9, driver CUDA 12.6
Image:  timpiltd/timpi-synaptron:cu124

==> Node identity
Node:   My Synaptron

==> Pulling timpiltd/timpi-synaptron:cu124
Status: Image is up to date for timpiltd/timpi-synaptron:cu124

==> Starting synaptron

==> Waiting for the node to reach the Controller
Connected. The Controller confirms the node within a minute or two; models load only when work arrives.
Asking the Controller whether it sees the node
The Controller reports this node ONLINE.

==> Done
```

`The Controller reports this node ONLINE.` means you're on the network. On a Blackwell card the `Image:`
line reads `…:cu128` instead — the script chose it from the card's compute capability.

Useful options:

| Option | What it does |
|---|---|
| `--publish-dashboard` | Expose the node dashboard on host port 8092 (`http://127.0.0.1:8092/dashboard`). Leave it off if you don't want the port opened. |
| `--version 2.1.9` | Pin to the immutable release tag (`2.1.9-cu124`) instead of the moving one. |
| `--gpu <uuid\|index>` | Which card, on a multi-GPU machine. |
| `--container-name <n>` | Default `synaptron`; the model-cache volume is `<n>-cache`. |
| `--dashboard-port <n>` | Host port for the dashboard, for a second node on the same machine. |
| `--replace` | Stop and remove an existing container of that name first. |
| `--yes` | No confirmation prompt. |

---

## 3. Check it's working

**Follow the startup log:**

```bash
docker logs -f synaptron
```

**What you should see** (these lines mean the node is up and on the network):

```
Synaptron image variant: cu124
Measuring the 4-bit path on this GPU.
quantization_4bit=ok, nf4 forward pass on cuda
      Now listening on: http://127.0.0.1:8092
      Application started. Press Ctrl+C to shut down.
      Controller URL: https://orcacontroller.timpi.network
      Connected to Synaptron Controller SignalR hub https://orcacontroller.timpi.network/hubs/synaptron
      Loaded Synaptron model catalog from Controller: https://orcacontroller.timpi.network/api/catalog/models
```

Press `Ctrl+C` to stop following the log (the container keeps running).

- `Synaptron image variant: cu124` (or `cu128`) confirms the image matches your card. It is read from a
  stamp baked into the image at build time, not guessed.
- `quantization_4bit=ok` is a one-time measurement on the first start on this GPU — it means the 4-bit
  path works, so the node can run quantized models. It runs only once per card.
- `Connected to … SignalR hub` is the line that proves the node reached the Controller.

**Confirm the node is on the card you pinned it to** — these two must name the same GPU:

```bash
docker exec synaptron nvidia-smi -L
docker logs synaptron 2>&1 | grep "GPU detected"
```

The first should list a **single** GPU: the UUID you passed to `--gpu`, or the machine's only card.
The second is what the node reported to the Controller, with the same UUID and which setting pinned
it. If they disagree, or the first names more than one card, the container is not pinned the way you
think: restart it, and see the troubleshooting table below.

**Confirm the GPU is visible inside the container:**

```bash
docker exec synaptron /app/.venv/bin/python -c "import torch; print(torch.cuda.is_available(), torch.cuda.get_device_name(0))"
```
```
True NVIDIA GeForce RTX 4060 Ti
```

**Confirm the network sees you** — in **Discord** run `/synaptronchecker` with your node GUID (shows
🟢 ONLINE), or from any machine:

```bash
curl -s https://orcacontroller.timpi.network/api/coordinator/nodes/YOUR-NODE-GUID/status/month
```

`"isOnline": true` = you are on the network. **An idle node with `loadedModels: []` is normal** — the
Controller loads models onto your node when work needs them; you don't load anything yourself.

---

## 4. Keep it updated automatically — Watchtower

Run one small **Watchtower** container and your Synaptron stays on the latest image automatically.

> **Watch a card-specific tag, never `:latest`.** Watchtower re-pulls whatever tag your container was
> started with. The quickstart starts you on the **moving `cu124` / `cu128` tag**, so Watchtower keeps
> you on the newest build for your card — that is the setup to use.
> ⚠️ **Do not watch a container started from the bare or `:latest` tag.** `:latest` is the `cu124`
> image, so the next update pulls cu124 onto your card, and a Blackwell (50-series) card then refuses to
> start and restart-loops. If your node is on `:latest`, re-run the quickstart (or start it on
> `cu124`/`cu128`) **before** adding Watchtower.
> If you pinned an immutable tag with `--version` (e.g. `2.1.9-cu128`), that tag never moves — a new
> release gets a new tag, so update by re-running the quickstart with `--replace` instead.

**Step 1 — start Watchtower** (paste it exactly as-is):

```bash
sudo docker rm -f watchtower 2>/dev/null

sudo docker run -d \
  --log-opt max-size=10m --log-opt max-file=3 \
  --name watchtower \
  --restart unless-stopped \
  -e DOCKER_API_VERSION=1.44 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower --interval 3600 --cleanup \
  synaptron
```

**Step 2 — update now and confirm it's watching:**

```bash
sudo docker run --rm \
  -e DOCKER_API_VERSION=1.44 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower --run-once --cleanup \
  synaptron
```

Look at the **last line**:

```
Session done   Failed=0 Scanned=1 Updated=0
```

👉 **`Scanned` must equal the number of Timpi containers you listed.** `Updated=0` just means you were
already on the latest — that's fine.

**Updating without Watchtower.** Run the quickstart again with `--replace`. It always pulls first, so on
`cu124` / `cu128` you get the newest build for your card; it keeps the model cache (the volume is
separate from the container) and asks for your node GUID again, so have it from
[timpi.com/node/v2/management](https://timpi.com/node/v2/management). If you started the node with a
hand-written `docker run` instead, pull your tag, remove the container, and run the same command again:

```bash
docker pull timpiltd/timpi-synaptron:cu124     # cu128 on a Blackwell card
docker rm -f synaptron                         # the model cache volume is kept
# then your original docker run command, unchanged
```

---

## Which tag to use

Check your card:

```bash
nvidia-smi --query-gpu=name,compute_cap --format=csv
```

| Your compute capability | Cards | Tag |
|---|---|---|
| **10.0 or higher** | RTX 50-series / Blackwell, RTX PRO Blackwell, B200/GB200 | **`cu128`** |
| **6.0 – 9.x** | GTX 10-series, Tesla P4, RTX 20/30/40, A-series, Hopper | **`cu124`** |
| Below 6.0 | — | Not supported by Synaptron at all |

Each release publishes four tags:

| Tag | What it is |
|---|---|
| `timpiltd/timpi-synaptron:2.1.9-cu124` | Immutable — this exact release, for the cu124 wheel set. What a node should be pinned to if you want no surprises. |
| `timpiltd/timpi-synaptron:cu124` | Moving — the newest build for that wheel set. What the quickstart and Watchtower use. |
| `timpiltd/timpi-synaptron:2.1.9-cu128` | Immutable, Blackwell. |
| `timpiltd/timpi-synaptron:cu128` | Moving, Blackwell. |

> **Always pull `cu124` or `cu128` — never a bare tag or `:latest`.** A bare `docker pull` (or `:latest`)
> resolves to the **cu124** image. That is fine on a cu124 card but **wrong on a Blackwell (50-series)
> card**, and `:latest` is a **legacy tag kept only for older installs** — it is not card-aware and is
> being retired. Point Watchtower at a container started from `:latest`/bare and a later update pulls
> cu124 onto whatever card you have; a Blackwell card then refuses to start (its start-time guard catches
> the mismatch and names the right tag). So pin your card's tag from the start, and if an existing node
> is on `:latest`, move it to `cu124`/`cu128` before it auto-updates.

---

## Manual install (choose the image yourself)

If you'd rather not use the quickstart, pick the image from the table above and run it directly:

```bash
docker pull timpiltd/timpi-synaptron:cu124

docker run -d --name synaptron --gpus all --restart unless-stopped \
  --log-opt max-size=10m --log-opt max-file=3 \
  -e SYNAPTRON_NODE_GUID=YOUR-NODE-GUID \
  -e SYNAPTRON_FRIENDLY_NAME="My Synaptron" \
  -v /etc/machine-id:/etc/machine-id:ro \
  -v synaptron-cache:/app/.cache \
  timpiltd/timpi-synaptron:cu124
```

- The Controller address (`https://orcacontroller.timpi.network`) and the CUDA device are already baked
  in — **the GUID is the only thing you must set.**
- `-v synaptron-cache:/app/.cache` keeps downloaded models between restarts.
- `--restart unless-stopped` brings the node back after a crash or host reboot.
- The log options are not optional in practice: a production node was found running with an unbounded
  `json-file` log, which is how a disk fills and the node dies of something that looks unrelated.
- `-v /etc/machine-id:/etc/machine-id:ro` is what lets the node tell this machine apart from another
  one running the same GPU model. Without it the node reports an empty machine fingerprint (it says so
  in the log at start-up) and the network loses the signal that keeps two such nodes from being read as
  two claims on one card. The quickstart mounts it for you; a hand-written `docker run` has to.

> **Mind the tag on a Blackwell card.** `cu124` has no Blackwell kernels — a 50-series card started on
> the `cu124` image fails every GPU operation while `torch.cuda.is_available()` still returns true. The
> container's start-time guard catches this and refuses to start with the tag to pull instead.

---

## Running more than one GPU

Three cases, and only one of them works:

| Setup | Supported |
|---|---|
| **One node per GPU**, several cards in one machine | ✅ Yes — one container per card |
| One node spanning **several GPUs** | ❌ No |
| **Several nodes on one GPU** | ❌ No — both report the same GPU and the network flags the duplicate |

**The part that catches people out:** `--gpus all` gives *every* container *every* card, so two
containers started with `--gpus all` both claim both cards and the network blocks one. Give each
container **one specific card**. The quickstart does this for you — run it once per card, each with its
own `--guid`, `--container-name`, `--gpu <uuid>`, and a `--dashboard-port <n>` so the second node's
dashboard doesn't collide with the first on host port 8092. By hand, list your GPUs and pass one by UUID:

```bash
nvidia-smi --query-gpu=index,name,uuid --format=csv,noheader
```

```
0, NVIDIA GeForce RTX 4060 Ti, GPU-51fe9889-a57c-61c2-159f-f0d8a811a1a0
1, NVIDIA GeForce RTX 3060, GPU-7da0df14-79ba-67cd-6372-45709da2b74e
```

```bash
docker run -d --name synaptron-gpu0 --restart unless-stopped \
  --log-opt max-size=10m --log-opt max-file=3 \
  --gpus '"device=GPU-51fe9889-a57c-61c2-159f-f0d8a811a1a0"' \
  -e SYNAPTRON_NODE_GUID=FIRST-NODE-GUID \
  -e SYNAPTRON_FRIENDLY_NAME="My Synaptron GPU0" \
  -v /etc/machine-id:/etc/machine-id:ro \
  -v synaptron-cache-gpu0:/app/.cache \
  timpiltd/timpi-synaptron:cu124
```

**Check each container sees exactly one card:**

```bash
docker exec synaptron-gpu0 nvidia-smi -L
```

Each must list a **single** GPU. If it lists both, that container is still on `--gpus all` — remove it
and re-run with the `device=` form.

> Do not reuse a node GUID on a second machine or a second GPU. Each instance needs its own.

---

## Managing the node

```bash
docker logs --tail 50 synaptron     # recent logs
docker stop synaptron               # stop
docker start synaptron              # start again
docker exec synaptron nvidia-smi    # what the GPU is doing right now
docker rm -f synaptron              # remove (models survive in the volume)
```

---

## If something goes wrong

| Symptom | Cause and fix |
|---|---|
| `docker: Error response ... could not select device driver ... [[gpu]]` | NVIDIA Container Toolkit isn't installed/configured. Install it (Before-you-start table), then re-run. |
| Container refuses to start naming a **different tag to pull** | You pulled the wrong image for the card (e.g. `cu124` on a Blackwell 50-series). Pull the tag it names, or use the quickstart which picks automatically. |
| After a **Watchtower or manual update** the node restart-loops with `Refusing to start … Synaptron image variant: cu124` on a **50-series / Blackwell** card | Watchtower was following the bare / `:latest` tag (which is `cu124`) and pulled it onto a card that needs `cu128`. Nothing is wrong with the card — the start-time guard is refusing the wrong image. Switch to cu128: `docker rm -f <name>; docker pull timpiltd/timpi-synaptron:cu128; docker run … timpiltd/timpi-synaptron:cu128`, then re-point Watchtower at the new container. |
| `manifest unknown` / `not found` when pulling `cu124` or `cu128` | That tag has not been published yet for this release. Check the [releases page](https://github.com/Timpi-official/Nodes/releases) for which image tags the current release carries. |
| `nvidia-smi` fails inside the container | Host driver problem or a driver update without a reboot. Run `nvidia-smi` on the host; reboot if it reports a version mismatch. |
| The container was serving, then **lost its GPU while running** — `docker exec synaptron nvidia-smi` says `Failed to initialize NVML: Unknown Error` even though `nvidia-smi` on the host still works | A `systemctl daemon-reload` on the host revoked the GPU. On cgroup v2 with the systemd cgroup driver (Docker's default on Ubuntu), a daemon-reload makes systemd re-apply each container's device rules from its own spec and drop the card the NVIDIA hook granted outside that spec. Any package update that ships a systemd unit — including unattended-upgrades — runs a daemon-reload, so this is not rare. **Recover now:** `docker restart synaptron`. **Prevent it:** name the card's device nodes explicitly alongside `--gpus`: `--device /dev/nvidia0 --device /dev/nvidiactl --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools` (use the card's minor number for `/dev/nvidiaN` — `nvidia-smi -q -i <uuid> \| grep 'Minor Number'`). The **quickstart already does this**; add the flags to a manual `docker run`. |
| Log never shows `Connected to ... SignalR hub` | Outbound HTTPS to `orcacontroller.timpi.network` is blocked (firewall/VPN). The node only makes outbound connections. |
| `isOnline` is false but the container is up | Same as above — check outbound HTTPS; give it a minute after start for the first ping. |
| The Controller says **another node claims your GPU**, or your node is blocked as a duplicate claim, and you changed nothing | The container was granted a different card than the one you pinned — usually after a host reboot or a driver reload with `--restart unless-stopped`. **`docker restart <container>`** re-attaches the requested device. From 2.1.7 the node refuses to start in this state rather than advertise the other node's card, and its log names both the requested and the granted UUID. |
| Container exits with code **44** and the log says `CUDA LOST` | The container was meant to have a GPU and either cannot see one, or can only see a card it did not ask for. Only a container restart re-attaches the device; the runner does that for you if it is managing the container. |
| Node looks healthy but the network says offline, and a **second node** runs on the same machine | Both containers were started with `--gpus all`, so both claim every card and the network blocks the duplicate. Give each container one card. |
| Node runs but stays idle for a long time | **Normal.** Work comes from the Controller; a healthy node can idle with 0 models loaded. Don't reinstall. |
| `A Timpi node ID is required` on start | You didn't pass `-e SYNAPTRON_NODE_GUID=...` (or `--guid` to the quickstart). |

---

## Uninstall

```bash
docker rm -f synaptron watchtower              # stop + remove the node (and Watchtower if you added it)
docker volume rm synaptron-cache               # remove the downloaded models (optional)
docker rmi timpiltd/timpi-synaptron:cu124      # remove the image (optional; cu128 on a Blackwell card)
```

---

*2.1.9 — the Docker steps are unchanged. 2.1.9 limits what an image or audio job's input can make a node
read (no local files, public URLs only). Since 2.1.8 the node code in the image fixes several task types, among
them speech-to-text and audio classification, which needed an `ffmpeg` the image does not carry; every
catalogued model the card can hold was run through the Controller on an RTX 5060 in the cu128 image
(51 of 51 passed across the two test cards). Verified on Ubuntu + RTX 4060 Ti (cu124) at 2.1.2 and re-verified on an RTX 5090
(cu128 image, built and run, start-time card check accepted, kernel, matmul and 4-bit NF4 all passing,
node registered with the Controller). Which image tags exist for a given release is a publishing step —
see the [releases page](https://github.com/Timpi-official/Nodes/releases).*
