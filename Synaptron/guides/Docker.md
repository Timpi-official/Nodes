# 🐳 **Timpi Synaptron — Docker (Linux + NVIDIA)**

<img width="1480" height="862" src="https://github.com/user-attachments/assets/b0749433-3720-4422-a14d-26c4dec067c3"/>

Synaptron is Timpi's AI node. This guide runs it as a **Docker container** — the whole runtime
(the .NET supervisor, the Python worker, PyTorch/CUDA) is baked into one image, so there is no venv,
no `apt`, no driver-repair step on the host. You pull one image and run one command.

The node makes only **outbound** connections. You do not need to open any inbound port.

**Supported:** Linux with an **NVIDIA GPU**. (Docker Desktop on Windows/Mac is *not* supported for GPU
work — use the native Windows guide there.)

---

## Contents

- [Before you start](#before-you-start)
- [1. Verify Docker can use your GPU](#1-verify-docker-can-use-your-gpu)
- [2. Pull the image](#2-pull-the-image)
- [3. Run it — just add your node GUID](#3-run-it--just-add-your-node-guid)
- [4. Check it's working](#4-check-its-working)
- [5. Keep it updated automatically — Watchtower](#5-keep-it-updated-automatically--watchtower)
- [Running more than one GPU](#running-more-than-one-gpu)
- [Managing the node](#managing-the-node)
- [If something goes wrong](#if-something-goes-wrong)
- [Uninstall](#uninstall)

---
## Before you start

| | |
|---|---|
| **GPU** | NVIDIA, compute capability **6.1+** (RTX 20-series / Turing or newer for LLM & image work; GTX 10-series can join for lighter tasks). |
| **Driver** | A working NVIDIA driver on the **host** — `nvidia-smi` must run. Get it from [NVIDIA's driver downloads](https://www.nvidia.com/en-us/drivers/) or, on Ubuntu, `sudo ubuntu-drivers autoinstall`. Confirm your card is CUDA-capable: [CUDA-compatible GPUs](https://developer.nvidia.com/cuda-gpus). |
| **Docker** | Installed and running. |
| **NVIDIA Container Toolkit** | **This is the one Docker-specific requirement** — it lets containers use the GPU. Install: [official guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html). Step 1 below verifies it. |
| **Disk** | **~12 GB** for the image; models are downloaded on demand into a volume and grow beyond that. |
| **Your node GUID** | Required — the node refuses to start without it. Register your Timpi Node Access NFT at [timpi.com/node/v2/management](https://timpi.com/node/v2/management); see the [registration guide](https://github.com/Timpi-official/Nodes/blob/main/Registration/RegisterNodes.md). |

> **Your node GUID is not a plain UUID.** It may contain letters and hyphens in any arrangement, for
> example `1a5737d8-example-node-a05f-ee3aba76548b`. Use exactly the string you were given.

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

## 2. Pull the image

```bash
docker pull timpiltd/timpi-synaptron:latest
```

Ends with:

```
Status: Downloaded newer image for timpiltd/timpi-synaptron:latest
```

---

## 3. Run it — just add your node GUID

Replace `YOUR-NODE-GUID` with the GUID assigned to this machine:

```bash
docker run -d --name synaptron --gpus all --restart unless-stopped \
  --log-opt max-size=10m --log-opt max-file=3 \
  -e SYNAPTRON_NODE_GUID=YOUR-NODE-GUID \
  -e SYNAPTRON_FRIENDLY_NAME="My Synaptron" \
  -v synaptron-cache:/app/.cache \
  timpiltd/timpi-synaptron:latest
```

- The Controller address (`https://orcacontroller.timpi.network`) and the CUDA device are already baked
  in — **the GUID is the only thing you must set.**
- **`SYNAPTRON_FRIENDLY_NAME`** is the name your node shows under in the Orca dashboard — pick anything.
  Leave it out and it defaults to `Synaptron <container-id>` (a random-looking name), so it's worth
  setting.
- `-v synaptron-cache:/app/.cache` keeps downloaded models between restarts.
- `--restart unless-stopped` brings the node back after a crash or host reboot.

> **One node per GPU.** A GPU can back only one Synaptron node — two nodes on the same card report
> the same GPU and the network flags the duplicate. `--gpus all` gives the container **every** card in
> the machine, which is what you want for a single node. If you have several cards and want a node on
> each, do **not** start them all with `--gpus all` — see
> [Running more than one GPU](#running-more-than-one-gpu) below.

---

## 4. Check it's working

**Follow the startup log:**

```bash
docker logs -f synaptron
```

**What you should see** (these lines mean the node is up and on the network):

```
Controller URL: https://orcacontroller.timpi.network
Node ID: YOUR-NODE-GUID
      Connected to Synaptron Controller SignalR hub https://orcacontroller.timpi.network/hubs/synaptron
      Loaded Synaptron model catalog from Controller: https://orcacontroller.timpi.network/api/catalog/models
      [python] INFO:     Uvicorn running on http://127.0.0.1:8091 (Press CTRL+C to quit)
      [python] INFO:     127.0.0.1:xxxxx - "GET /health HTTP/1.1" 200 OK
      [python] INFO:     127.0.0.1:xxxxx - "GET /capabilities HTTP/1.1" 200 OK
```

Press `Ctrl+C` to stop following the log (the container keeps running).

**Confirm the GPU is visible inside the container:**

```bash
docker exec synaptron /app/.venv/bin/python -c "import torch; print(torch.cuda.is_available(), torch.cuda.get_device_name(0))"
```
```
True NVIDIA GeForce RTX 4060 Ti
```

**Confirm the network sees you** — in **Discord** run `/synaptronchecker` with your node GUID (shows
🟢 ONLINE / 2.x), or from any machine:

```bash
curl -s https://orcacontroller.timpi.network/api/coordinator/nodes/YOUR-NODE-GUID/status/month
```
```json
{"nodeGuid":"YOUR-NODE-GUID","isOnline":true,"lastPingUtc":"2026-07-27T...","availabilityPercent":100,"loadedModels":[], ...}
```

`"isOnline": true` = you are on the network. **An idle node with `loadedModels: []` is normal** — the
Controller loads models onto your node when work needs them; you don't load anything yourself.

---

## 5. Keep it updated automatically — Watchtower

Run one small **Watchtower** container and your Synaptron stays on the latest image automatically — no
manual upgrade steps when a new release ships.

✅ **Your node GUID and model cache are kept** — Watchtower recreates the container with the same settings
and the same `synaptron-cache` volume.
🔁 **Nothing to remove yourself** — Watchtower stops, replaces and cleans up the old container & image when
it updates. Your node keeps running until then; it's offline only for the few seconds of the swap, then
reconnects on its own.

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

This watches your **`synaptron`** container and checks hourly. If you also run other Timpi nodes on this
machine (Collector/GeoCore/Guardian), add their container names to the end of the last line too — one
Watchtower covers them all.

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

ℹ️ Your background Watchtower checks **every hour from now on**, and its first check is an hour after you
started it — so `docker logs watchtower` stays quiet until then. That's normal, not a failure.

> **Prefer to update by hand?** `docker pull timpiltd/timpi-synaptron:latest`, then `docker rm -f synaptron`
> and re-run the Step 3 command. Your GUID (run command) and model cache (volume) carry over.

---

## Running more than one GPU

Three cases, and only one of them works — the distinction is what usually trips people up:

| Setup | Supported |
|---|---|
| **One node per GPU**, several cards in one machine | ✅ Yes — one container per card |
| One node spanning **several GPUs** | ❌ No |
| **Several nodes on one GPU** | ❌ No — both report the same GPU and the network flags the duplicate |

**The part that catches people out:** `--gpus all` gives *every* container *every* card. A node reports
whatever GPUs it can see, so two containers started with `--gpus all` both claim both cards — even
though each is only computing on one. The network sees two nodes claiming the same GPU, blocks one of
them, and because both keep re-registering they can end up blocking each other. Nothing in the
container logs says so: the node looks perfectly healthy from the inside.

So give each container **one specific card**. List your GPUs:

```bash
nvidia-smi --query-gpu=index,name,uuid --format=csv,noheader
```

```
0, NVIDIA GeForce RTX 4060 Ti, GPU-51fe9889-a57c-61c2-159f-f0d8a811a1a0
1, NVIDIA GeForce RTX 3060, GPU-7da0df14-79ba-67cd-6372-45709da2b74e
```

Then run one container per card, each with its own node GUID, container name and cache volume:

```bash
# first card
docker run -d --name synaptron-gpu0 --restart unless-stopped \
  --log-opt max-size=10m --log-opt max-file=3 \
  --gpus '"device=GPU-51fe9889-a57c-61c2-159f-f0d8a811a1a0"' \
  -e SYNAPTRON_NODE_GUID=FIRST-NODE-GUID \
  -e SYNAPTRON_FRIENDLY_NAME="My Synaptron GPU0" \
  -v synaptron-cache-gpu0:/app/.cache \
  timpiltd/timpi-synaptron:latest

# second card
docker run -d --name synaptron-gpu1 --restart unless-stopped \
  --log-opt max-size=10m --log-opt max-file=3 \
  --gpus '"device=GPU-7da0df14-79ba-67cd-6372-45709da2b74e"' \
  -e SYNAPTRON_NODE_GUID=SECOND-NODE-GUID \
  -e SYNAPTRON_FRIENDLY_NAME="My Synaptron GPU1" \
  -v synaptron-cache-gpu1:/app/.cache \
  timpiltd/timpi-synaptron:latest
```

**Mind the quoting.** `--gpus '"device=GPU-..."'` needs the inner double quotes, wrapped in single
quotes for the shell. `--gpus '"device=0"'` also works and selects by index, but the UUID form cannot
be thrown off by a card being re-ordered after a reboot.

**Check each container sees exactly one card** — this is the step that confirms it worked:

```bash
docker exec synaptron-gpu0 nvidia-smi -L
docker exec synaptron-gpu1 nvidia-smi -L
```

Each must list a **single** GPU, and they must be different ones. If either lists both cards, that
container is still running with `--gpus all` — remove it and re-run with the `device=` form.

> Do not reuse a node GUID on a second machine or a second GPU. Each instance needs its own.
>
> Running Watchtower? List every container name on its command line, e.g.
> `containrrr/watchtower --interval 3600 --cleanup synaptron-gpu0 synaptron-gpu1`.

> **"But my node only uses ~2 GB of VRAM."** True, and a bigger card is still used fully — just not by
> running more nodes on it. The Controller loads *larger* models on RTX 40/50-class cards, or several
> smaller models onto the same node, so the capacity is used through **more models on one node**, not
> more node identities.
>
> The only real exception is hardware partitioning with **NVIDIA MIG** (A100, A30, H100/H200,
> B200/GB200, RTX PRO Blackwell 6000/5000/4500). Consumer cards — RTX 2060–5090, 3090, 4090, 5090 and
> the GTX 10-series — **do not support MIG**, so on those it is strictly one node per card.

---

## Managing the node

```bash
docker logs --tail 50 synaptron     # recent logs
docker stop synaptron               # stop
docker start synaptron              # start again
docker exec synaptron nvidia-smi    # what the GPU is doing right now
docker rm -f synaptron              # remove (your GUID is in the run command; models survive in the volume)
```

---

## If something goes wrong

| Symptom | Cause and fix |
|---|---|
| `docker: Error response ... could not select device driver ... [[gpu]]` | NVIDIA Container Toolkit isn't installed/configured. Install it (Before-you-start table), then re-run. |
| `nvidia-smi` fails inside the container | Host driver problem or a driver update without a reboot. Run `nvidia-smi` on the host; reboot if it reports a version mismatch. |
| Log never shows `Connected to ... SignalR hub` | Outbound HTTPS to `orcacontroller.timpi.network` is blocked (firewall/VPN). The node only makes outbound connections. |
| `isOnline` is false but the container is up | Same as above — check outbound HTTPS; give it a minute after start for the first ping. |
| Node looks healthy but the network says offline, and a **second node** runs on the same machine | Both containers were started with `--gpus all`, so both claim every card and the network blocks the duplicate. Give each container one card — see [Running more than one GPU](#running-more-than-one-gpu). |
| Node runs but stays idle for a long time | **Normal.** Work comes from the Controller; a healthy node can idle with 0 models loaded. Don't reinstall. |
| `A Timpi node ID is required` on start | You didn't pass `-e SYNAPTRON_NODE_GUID=...`. Add it to the `docker run` command. |
| Watchtower `run-once` shows `Scanned=0` | The container name after `--cleanup` doesn't match a running container. Check `docker ps` (NAMES column) and use that exact name. |

---

## Uninstall

```bash
docker rm -f synaptron watchtower       # stop + remove the node (and Watchtower if you added it)
docker volume rm synaptron-cache        # remove the downloaded models (optional)
docker rmi timpiltd/timpi-synaptron:latest    # remove the image (optional)
```

---

*Verified on Ubuntu + RTX 4060 Ti. Every step above was run end-to-end against the official
`timpiltd/timpi-synaptron:latest` (fresh pull from Docker Hub): online in Orca, correct node name,
model load/unload from the Orca Controller, GPU inference, and Watchtower. In a controlled same-GPU
benchmark the container ran within run-to-run noise of a native install (no measurable overhead); a
~9.5-hour soak (2,222 inferences) showed 0 errors, 0 restarts, flat VRAM (±1 MiB), no latency drift,
and stayed online the whole time.*
