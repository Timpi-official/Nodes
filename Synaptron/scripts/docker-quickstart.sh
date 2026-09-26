#!/usr/bin/env bash
# Synaptron node in Docker, in one command. Nothing to download first, nothing left on disk.
#
#   bash <(curl -fsSL https://<host>/docker-quickstart.sh)
#   curl -fsSL https://<host>/docker-quickstart.sh | bash -s -- --guid <id> --name "My Node"
#
# The official Timpi Docker path is: pull one image, run one docker command with your node GUID,
# remove with docker rm -f. This script is that path, plus the one thing Docker cannot do for you:
# Synaptron ships two images (cu124 for Pascal through Hopper, cu128 for Blackwell) and the tag has
# to match the card, so this reads the card and picks. It does not scan the machine for other
# installs, does not need an uninstaller, and keeps nothing on the host but the container and its
# model-cache volume.
#
# Options (all optional; GUID and name are asked for if not given):
#   --guid <id>            your Timpi node GUID
#   --name <text>          the name shown on the dashboard
#   --repo <repo>          image repository       (default timpiltd/timpi-synaptron)
#   --version <x.y.z>      pinned release, e.g. 2.1.2 -> 2.1.2-cu124   (default: the moving cu124/cu128 tag)
#   --tag <tag>            exact tag; '{variant}' in it is replaced by the card-based choice,
#                          e.g. --tag '2.1.2-{variant}-test' -> 2.1.2-cu124-test on a Pascal card
#   --gpu <uuid|index>     which card, on a multi-GPU machine
#   --container-name <n>   default synaptron; the cache volume is <n>-cache
#   --controller-url <u>   default is baked into the image (production)
#   --allow-insecure-controller   accept a plaintext http:// Controller (test instances only)
#   --publish-dashboard    expose the node dashboard on port 8092
#   --dashboard-port <n>   host port for it, for a second node on the same machine (default 8092)
#   --replace              stop and remove an existing container of that name first
#   --yes                  no confirmation prompt
set -euo pipefail

REPO="timpiltd/timpi-synaptron"; TAG=""; VERSION=""; GUID=""; NAME=""; GPU_SEL=""; CNAME="synaptron"
CONTROLLER_URL=""; PUBLISH="false"; REPLACE="false"; YES="false"; INSECURE="false"; DASH_PORT="8092"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --guid) GUID="$2"; shift 2 ;;            --name) NAME="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;            --version) VERSION="$2"; shift 2 ;;
    --tag) TAG="$2"; shift 2 ;;              --gpu) GPU_SEL="$2"; shift 2 ;;
    --container-name) CNAME="$2"; shift 2 ;; --controller-url) CONTROLLER_URL="$2"; shift 2 ;;
    --publish-dashboard) PUBLISH="true"; shift ;; --replace) REPLACE="true"; shift ;;
    --allow-insecure-controller) INSECURE="true"; shift ;;
    --dashboard-port) DASH_PORT="$2"; shift 2 ;;
    --yes) YES="true"; shift ;;
    -h|--help) awk 'NR > 1 { if ($0 !~ /^#/) exit; sub(/^# ?/, ""); print }' "${BASH_SOURCE[0]:-$0}"; exit 0 ;;
    # The option only, never the value glued to it: "--guid=<id>" arrives here as one token and
    # this message is what an operator pastes when the script refuses to run.
    # The token is never echoed, in any form. Checking for a leading hyphen is not enough:
    # "--node-guid:<id>" passes that test and "${1%%=*}" only strips an equals sign, so the
    # whole id printed. There is no reliable way to separate an option name from a value
    # glued to it by an unknown character, and this message is what gets pasted when the
    # node will not start -- so it names nothing.
    *) echo "Unrecognised argument. Run with --help for the accepted options." >&2; exit 2 ;;
  esac
done
# A number, or an absolute http(s) URL, and nothing else, before anything prints: a value in the
# wrong place can be the node GUID, and docker repeats a port it cannot parse. Names the option only.
[[ "${DASH_PORT}" =~ ^[0-9]{1,5}$ ]] || { echo "Stopped: --dashboard-port must be a number; what was typed is not printed, because it can carry an identity." >&2; exit 1; }
[[ -z "${CONTROLLER_URL}" || "${CONTROLLER_URL}" =~ ^https?://[^[:space:]/@]+(/[^[:space:]]*)?$ ]] || { echo "Stopped: --controller-url must be an absolute http:// or https:// URL with no user name or password in it; what was typed is not printed, because it can carry an identity." >&2; exit 1; }

say()  { echo ""; echo "==> $*"; }
die()  { echo ""; echo "Stopped: $*" >&2; exit 1; }
# Prompts read the terminal, not stdin, so this works when the script itself arrives on stdin. The
# GUID is read silently: a terminal is a transcript, and the id must not be in it. Both prompts go
# to the tty explicitly (`read -p` writes to stderr) and fail quietly when there is no terminal --
# [[ -r /dev/tty ]] is not that test, the device is readable by mode without a controlling terminal.
# After the silent read, one line the terminal already holds is kept for the next question: a
# GUID pasted with a Windows line ending arrives as two newlines (the tty maps CR to LF), and the
# second one answered the "Pull and start?" confirmation by itself. An empty pending line is that
# spill and is dropped; a non-empty one was typed ahead and answers the next ask. ask() runs in a
# command substitution, so the caller clears TTY_PENDING once it has been used.
TTY_PENDING=""
ask()  { local reply=""
  if [[ -n "${TTY_PENDING}" ]]; then printf '%s' "${TTY_PENDING}"; return; fi
  if [[ -n "${2:-}" ]]; then { read -r -s -p "$1" reply < /dev/tty 2> /dev/tty && echo > /dev/tty; } 2>/dev/null || reply=""
  else { read -r -p "$1" reply < /dev/tty 2> /dev/tty; } 2>/dev/null || reply=""; fi
  printf '%s' "${reply}"; }
pending_tty_line() { local line=""
  if { read -r -t 0 line < /dev/tty; } 2>/dev/null; then { read -r line < /dev/tty; } 2>/dev/null || line=""; fi
  printf '%s' "${line}"; }

say "Checking Docker and the GPU"
command -v docker >/dev/null 2>&1 || die "Docker is not installed. https://docs.docker.com/engine/install/"
if ! docker info >/dev/null 2>&1; then
  # Being added to the docker group does not reach a shell that was already open, and the obvious
  # message sends someone who has just run usermod straight back round the same loop.
  if getent group docker 2>/dev/null | grep -qE "(:|,)$(id -un)(,|$)"; then
    die "Docker is installed and $(id -un) is already in the docker group, but this shell started before that, so it does not have the group yet. Open a new terminal, or run 'newgrp docker' here, then run this again."
  fi
  die "Docker is installed but this user cannot talk to it. Run: sudo usermod -aG docker $(id -un)   then open a new terminal and run this again."
fi
docker info 2>/dev/null | grep -qi 'nvidia' || die "The NVIDIA Container Toolkit is not set up, so containers cannot use the GPU. https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html"
command -v nvidia-smi >/dev/null 2>&1 || die "nvidia-smi is not installed: the NVIDIA driver is missing. On Ubuntu: sudo ubuntu-drivers autoinstall, then reboot."
mapfile -t ROWS < <(nvidia-smi --query-gpu=index,name,uuid,compute_cap,memory.total --format=csv,noheader 2>/dev/null | sed 's/, */|/g')
[[ ${#ROWS[@]} -gt 0 ]] || die "nvidia-smi reports no GPU. If the driver was just updated, reboot first."
CUDA_VER="$(nvidia-smi 2>/dev/null | grep -o 'CUDA Version: [0-9.]*' | grep -o '[0-9.]*$' || true)"

# Which card. One GPU: that one. Several: --gpu, or ask.
pick=""
if [[ ${#ROWS[@]} -eq 1 ]]; then pick="${ROWS[0]}"
else
  echo "This machine has ${#ROWS[@]} GPUs. One node per card; run this once per card with its own GUID."
  for r in "${ROWS[@]}"; do IFS='|' read -r i n u c m <<<"$r"; echo "  [$i] $n  ($m, compute $c)  $u"; done
  [[ -n "${GPU_SEL}" ]] || GPU_SEL="$(ask 'Which card for this node? [index or UUID] ')"
  for r in "${ROWS[@]}"; do IFS='|' read -r i n u c m <<<"$r"; [[ "${GPU_SEL}" == "$i" || "${GPU_SEL}" == "$u" ]] && pick="$r"; done
  # The value is not repeated: a token in the wrong place can be the node GUID.
  [[ -n "${pick}" ]] || die "No card matches the given --gpu; what was typed is not printed, because it can carry an identity. Pass --gpu <index> or --gpu <UUID> from the list above."
fi
IFS='|' read -r GPU_IDX GPU_NAME GPU_UUID GPU_CAP GPU_MEM <<<"${pick}"

# Which image. The same rule the node's own guard applies at start.
awk_ge() { awk -v a="$1" -v b="$2" 'BEGIN { exit !(a+0 >= b+0) }'; }
if awk_ge "${GPU_CAP}" 10.0; then VARIANT="cu128"
elif awk_ge "${GPU_CAP}" 6.0; then VARIANT="cu124"
else die "${GPU_NAME} is compute ${GPU_CAP}; the network needs 6.0 or newer, so this card cannot run a node."; fi
if [[ "${VARIANT}" == "cu128" && -n "${CUDA_VER}" ]] && ! awk_ge "${CUDA_VER}" 12.8; then
  die "${GPU_NAME} needs the cu128 image, which needs a driver reporting CUDA 12.8 or newer; this one reports ${CUDA_VER}. Update the driver (570 series or newer) and reboot."
fi
if [[ -z "${TAG}" ]]; then TAG="${VARIANT}"; [[ -n "${VERSION}" ]] && TAG="${VERSION}-${VARIANT}"
else TAG="${TAG//\{variant\}/${VARIANT}}"; fi
IMAGE="${REPO}:${TAG}"
echo "GPU:    [${GPU_IDX}] ${GPU_NAME}, ${GPU_MEM}, compute ${GPU_CAP}${CUDA_VER:+, driver CUDA ${CUDA_VER}}"
echo "Image:  ${IMAGE}"

say "Node identity"
[[ -n "${NAME}" ]] || NAME="$(ask 'Name for this node on the dashboard [Synaptron '"$(hostname)"']: ')"
[[ -n "${NAME}" ]] || NAME="Synaptron $(hostname)"
[[ -n "${GUID}" ]] || { GUID="$(ask 'Your Timpi node GUID (from timpi.se/my-nodes.html): ' silent)"; TTY_PENDING="$(pending_tty_line)"; }
[[ -n "${GUID}" ]] || die "A node GUID is required. Pass --guid <id> or type it at the prompt."
# The rule of config/node-id-placeholders.conf, copied because this script runs from a URL with no
# config/ beside it; tests/test_node_identity.py fails if this list drifts from that file. Pasting a
# guide's example unchanged registered nodes as YOUR-NODE-GUID for a month. The value is never printed.
NODE_ID_PLACEHOLDER_WORDS=(YOUR GUID TIMPI NODE EXAMPLE PLACEHOLDER XXXX)
GUID_UPPER="$(printf '%s' "${GUID}" | tr '[:lower:]' '[:upper:]')"
NODE_ID_EXAMPLE="false"
[[ "${GUID_UPPER}" == *'<'* || "${GUID_UPPER}" == *'>'* ]] && NODE_ID_EXAMPLE="true"
for w in "${NODE_ID_PLACEHOLDER_WORDS[@]}"; do [[ "${GUID_UPPER}" == *"${w}"* ]] && NODE_ID_EXAMPLE="true"; done
[[ "${NODE_ID_EXAMPLE}" == "true" ]] && die "The node GUID is an example value from a guide, not your node's ID. Copy your own from https://timpi.se/my-nodes.html and run this again with --guid <that id>."
[[ "${GUID}" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]] \
  || echo "Warning: the node GUID is not in the usual form (8-4-4-4-12 hex digits). Check it character by character against https://timpi.se/my-nodes.html: a mistyped ID registers as a different node."
echo "Node:   ${NAME}"

# An existing container of this name. Replacing it keeps the model cache: the volume is separate.
# It is only removed once the new image is on this machine (below): removing it first meant a pull
# that failed -- Docker Hub unreachable, a mistyped --tag -- left the operator with no node at all.
EXISTING="false"
if docker ps -a --format '{{.Names}}' | grep -Fqx -- "${CNAME}"; then
  EXISTING="true"
  cur="$(docker ps -a --filter "name=^${CNAME}$" --format '{{.Image}}  {{.Status}}')"
  say "A container called ${CNAME} already exists: ${cur}"
  if [[ "${REPLACE}" != "true" ]]; then
    a="$(ask 'Stop and replace it? Its model cache is kept. [y/N] ')"; TTY_PENDING=""
    [[ "${a}" =~ ^[Yy] ]] || die "Left as is. To do it by hand:  docker rm -f ${CNAME}   then run this again (or pass --replace)."
  fi
fi

if [[ "${YES}" != "true" ]]; then
  a="$(ask "Pull ${IMAGE} and start ${CNAME} on ${GPU_NAME}? [Y/n] ")"; TTY_PENDING=""
  [[ -z "${a}" || "${a}" =~ ^[Yy] ]] || die "Cancelled. Nothing was downloaded$([[ "${EXISTING}" == "true" ]] && echo ", and ${CNAME} was left as it was")."
fi

say "Pulling ${IMAGE}"
# Pull first, always: on a moving tag like cu124 that is how a node picks up a new build. Only when
# the pull cannot be done at all does an image already on this machine count. That covers the two
# real cases -- a fleet whose images are streamed host to host with `docker save` because there is
# no registry to pull from, and an operator who pre-pulled on a machine that is now offline -- while
# leaving the ordinary path unchanged: if Docker Hub answers, its copy wins.
if ! docker pull "${IMAGE}"; then
  if docker image inspect "${IMAGE}" >/dev/null 2>&1; then
    echo ""
    echo "Could not pull ${IMAGE}, but that image is already on this machine, so it is used as it is."
    echo "It will not be refreshed until this machine can reach the registry again."
  else
    die "Could not pull ${IMAGE}, and no copy of it is on this machine. Check --repo and --tag, and that this machine can reach Docker Hub.$([[ "${EXISTING}" == "true" ]] && echo " ${CNAME} was not touched and is still as it was.")"
  fi
fi

if [[ "${EXISTING}" == "true" ]]; then
  docker stop "${CNAME}" >/dev/null && docker rm "${CNAME}" >/dev/null && echo "Removed the old container. Volume ${CNAME}-cache kept."
fi

say "Starting ${CNAME}"
ARGS=( -d --name "${CNAME}" --restart unless-stopped
       --log-opt max-size=10m --log-opt max-file=3
       --gpus "device=${GPU_UUID}"
       -e "SYNAPTRON_NODE_GUID=${GUID}" -e "SYNAPTRON_FRIENDLY_NAME=${NAME}" -e "SYNAPTRON_GPU_UUID=${GPU_UUID}"
       -v "${CNAME}-cache:/app/.cache" )
# The card's device nodes, named explicitly next to --gpus. On cgroup v2 with the systemd cgroup
# driver, which is what Docker on Ubuntu sets up, a `systemctl daemon-reload` on the host makes
# systemd re-apply every container's device rules from the container's own spec. The NVIDIA hook
# grants the card outside that spec, so the running node loses it: nvidia-smi inside reports
# "Failed to initialize NVML: Unknown Error", torch stops seeing CUDA, and the node keeps
# advertising a card it can no longer use until the container is restarted. Every unattended
# upgrade of a package with a service does a daemon-reload, so this is not a rare event; it took
# a fleet node down on 2026-09-04. Devices named here are in the spec and survive. This is
# NVIDIA's documented mitigation, reproduced and proved on eight nodes the same day.
# awk must read nvidia-smi's whole report, not `exit` on the first match: exiting early closes the
# pipe while nvidia-smi is still writing, and under `set -o pipefail` that SIGPIPE (exit 141) aborts
# the whole quickstart before `docker run` -- the node never starts. Take the first Minor Number, print
# at END. Found by JohnO running the published 2.1.7 guide end to end (SynWork #87).
minor="$(nvidia-smi -q -i "${GPU_UUID}" 2>/dev/null | awk '/Minor Number/ && m=="" { m=$NF } END { print m }')"
[[ -n "${minor}" || ${#ROWS[@]} -ne 1 ]] || minor=0
if [[ -n "${minor}" && -e "/dev/nvidia${minor}" ]]; then
  for dev in "/dev/nvidia${minor}" /dev/nvidiactl /dev/nvidia-uvm /dev/nvidia-uvm-tools; do
    [[ -e "${dev}" ]] && ARGS+=( --device "${dev}" )
  done
else
  echo "Note: could not map ${GPU_NAME} to its /dev/nvidiaN node, so this container can lose the GPU on a host daemon-reload. If nvidia-smi inside it ever reports an NVML error:  docker restart ${CNAME}"
fi
for mid in /etc/machine-id /var/lib/dbus/machine-id; do [[ -s "${mid}" ]] && { ARGS+=( -v "${mid}:/etc/machine-id:ro" ); break; }; done
[[ -n "${CONTROLLER_URL}" ]] && ARGS+=( -e "SYNAPTRON_CONTROLLER_URL=${CONTROLLER_URL}" )
[[ "${INSECURE}" == "true" ]] && ARGS+=( -e "SYNAPTRON_ALLOW_INSECURE_CONTROLLER=true" )
[[ "${PUBLISH}" == "true" ]] && ARGS+=( -p "${DASH_PORT}:8092" -e "SYNAPTRON_DASHBOARD_URL=http://0.0.0.0:8092" )
docker run "${ARGS[@]}" "${IMAGE}" >/dev/null

say "Waiting for the node to reach the Controller"
ok="false"
for _ in $(seq 1 45); do
  if docker logs "${CNAME}" 2>&1 | grep -q 'Connected to Synaptron Controller SignalR hub'; then ok="true"; break; fi
  if ! docker ps --format '{{.Names}}' | grep -Fqx -- "${CNAME}"; then break; fi
  sleep 2
done
if [[ "${ok}" == "true" ]]; then
  echo "Connected. The Controller confirms the node within a minute or two; models load only when work arrives."
else
  echo "Not connected yet. The last log lines:"; docker logs --tail 15 "${CNAME}" 2>&1 | sed 's/^/    /'
fi
# The public status lags the hub connection by a minute or so; poll it rather than show a stale "false".
ctrl="${CONTROLLER_URL:-https://orcacontroller.timpi.network}"
if [[ "${ok}" == "true" ]]; then
  printf 'Asking the Controller whether it sees the node'
  online="false"
  for _ in $(seq 1 24); do
    status="$(curl -s -m 10 "${ctrl}/api/coordinator/nodes/${GUID}/status/month" 2>/dev/null || true)"
    if printf '%s' "${status}" | grep -q '"isOnline":true'; then online="true"; break; fi
    printf '.'; sleep 5
  done
  echo ""
  if [[ "${online}" == "true" ]]; then echo "The Controller reports this node ONLINE."
  else echo "The Controller does not report it online yet. Give it a few minutes, then check with the command below."; fi
fi

say "Done"
cat <<HOW
  follow the log     docker logs -f ${CNAME}
  is it online       SYNAPTRON_NODE_GUID='<your node id>'; curl -s "${ctrl}/api/coordinator/nodes/\$SYNAPTRON_NODE_GUID/status/month"
  stop / start       docker stop ${CNAME}   /   docker start ${CNAME}
  remove             docker rm -f ${CNAME}          (models stay in volume ${CNAME}-cache)
  remove everything  docker rm -f ${CNAME}; docker volume rm ${CNAME}-cache; docker rmi ${IMAGE}
  update             run this command again with --replace
HOW
