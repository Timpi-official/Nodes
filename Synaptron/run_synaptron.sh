#!/usr/bin/env bash
set -euo pipefail

###########################################################
# Timpi Synaptron – Auto Installer / Runner (Linux Only)
# Ubuntu 22.04+ with NVIDIA GPU
#
# This script:
#  - Blocks Snap Docker
#  - Validates Docker & Docker Compose
#  - Checks Docker daemon permissions
#  - Runs NVIDIA diagnostics (driver + NVML)
#  - Lets user choose:
#       1) Automatic (GPU-based)
#       2) Force cuda24 (t3_cuda24)
#       3) Force cuda28 (t3_cuda28)
#  - If Automatic: Detects GPU model -> ARCH (t3_cuda24 / t3_cuda28)
#  - Selects matching Docker image tag (cuda24 / cuda28)
#  - Verifies GPU access inside Docker
#  - Patches ARCH + image tag in docker-compose.yml
#  - Starts Synaptron stack (neo4j + watchtower + synaptron)
#
# NAME and GUID are handled in install.sh (not here).
###########################################################

REPO_BASE="https://raw.githubusercontent.com/johnolofs/timpi/main/Synaptron"
YML_FILE="docker-compose.yml"

echo "===== Timpi Synaptron – Linux Installer ====="
echo

###########################################################
# Move into script directory
###########################################################
cd "$(dirname "$0")"

###########################################################
# Ensure docker-compose.yml exists
###########################################################
if [[ ! -f "$YML_FILE" ]]; then
  echo "No docker-compose.yml found — downloading..."
  curl -fsS -O "${REPO_BASE}/${YML_FILE}"
fi

###########################################################
# BLOCK SNAP DOCKER
###########################################################
if command -v snap >/dev/null 2>&1 && snap list 2>/dev/null | grep -q "^docker "; then
  echo
  echo "ERROR: Snap Docker detected."
  echo "Snap Docker cannot be used with Synaptron (GPU access will fail)."
  echo
  echo "Fix:"
  echo "  sudo snap remove docker"
  echo "  curl -fsSL https://get.docker.com | sudo bash"
  echo
  exit 1
fi

###########################################################
# Validate Docker + Docker Compose
###########################################################
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker not installed."
  echo "Install it:"
  echo "  curl -fsSL https://get.docker.com | sudo bash"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker compose (v2) missing."
  exit 1
fi

COMPOSE_VERSION="$(docker compose version --short)"
REQUIRED_COMPOSE="2.23.0"

version_ge() {
  # returns true if $2 >= $1 (semantic-ish compare)
  [[ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" == "$1" ]]
}

if ! version_ge "$REQUIRED_COMPOSE" "$COMPOSE_VERSION"; then
  echo "ERROR: Docker Compose version too old: ${COMPOSE_VERSION}"
  echo "Please update to ${REQUIRED_COMPOSE}+"
  exit 1
fi

echo "Docker Compose OK: $COMPOSE_VERSION"

###########################################################
# Docker permissions check
###########################################################
if ! docker ps >/dev/null 2>&1; then
  echo
  echo "ERROR: Cannot talk to Docker daemon as user '$USER'."
  echo

  if ! id -nG "$USER" | grep -qw docker; then
    echo "Fix:"
    echo "  sudo usermod -aG docker $USER"
    echo "  newgrp docker"
    echo
  else
    echo "Docker daemon may not be running:"
    echo "  sudo systemctl start docker"
    echo
  fi

  exit 1
fi

echo "Docker daemon is reachable."

###########################################################
# NVIDIA DRIVER DIAGNOSTICS
###########################################################
echo
echo "Running NVIDIA diagnostics..."

# 1) Check that nvidia-smi exists at all
if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "ERROR: nvidia-smi not found — NVIDIA driver not installed correctly or GPU not detected."
  echo
  echo "Install / fix driver (recommended 550+), then reboot, for example:"
  echo "  sudo apt install -y nvidia-driver-550"
  echo "  sudo reboot"
  echo
  exit 1
fi

# 2) Check for NVML / driver mismatch errors
NVIDIA_ERROR="$(nvidia-smi 2>&1 | grep -i 'Failed' || true)"

if [[ -n "$NVIDIA_ERROR" ]]; then
  echo
  echo "ERROR: NVIDIA driver is broken."
  echo "$NVIDIA_ERROR"
  echo
  echo "This means your NVIDIA installation is corrupted or mismatched."
  echo "Synaptron cannot run until this is fixed."
  echo
  echo "Suggested fix:"
  echo "  sudo apt remove --purge '^nvidia-.*'"
  echo "  sudo apt remove --purge '^libnvidia-.*'"
  echo "  sudo apt autoremove -y"
  echo "  sudo apt install -y nvidia-driver-550"
  echo "  sudo reboot"
  echo
  echo "After reboot:"
  echo "  sudo apt install -y nvidia-container-toolkit"
  echo "  sudo nvidia-ctk runtime configure --runtime=docker"
  echo "  sudo systemctl restart docker"
  echo
  exit 1
fi

echo "NVIDIA driver appears present."

###########################################################
# Helper: detect if GPU is Blackwell-class
###########################################################
is_blackwell() {
  case "$1" in
    *"5090"*|*"5080"*|*"5070"*|*"Blackwell"*|*"GB20"*|*"GB30"*)
      return 0 ;;  # true
    *)
      return 1 ;;  # false
  esac
}

###########################################################
# Helper: read from /dev/tty (works with curl | bash)
###########################################################
read_from_tty() {
  local prompt="$1"
  local value=""

  if [ -e /dev/tty ]; then
    printf "%s" "$prompt" > /dev/tty
    if ! IFS= read -r value < /dev/tty; then
      # could not read -> non-interactive
      return 1
    fi
    printf '%s\n' "$value"
    return 0
  fi

  return 1
}

###########################################################
# Optional: show CUDA version (informational only)
###########################################################
CUDA_LINE="$(nvidia-smi | grep 'CUDA Version' || true)"
if [[ -n "$CUDA_LINE" ]]; then
  CUDA_INFO="$(echo "$CUDA_LINE" | sed -E 's/.*CUDA Version: ([0-9]+\.[0-9]+).*/\1/')"
  echo "Detected CUDA (driver): $CUDA_INFO"
else
  echo "No CUDA version line found in nvidia-smi output."
fi

###########################################################
# MODE SELECTION PROMPT
# 1) Automatic (GPU-based)
# 2) Force cuda24 (t3_cuda24)
# 3) Force cuda28 (t3_cuda28)
#
# If we cannot read from /dev/tty -> Automatic.
###########################################################
ARCH=""
CUDA_TAG=""
MODE="AUTO"

echo
echo "Choose Synaptron CUDA mode:"
echo "  1) Automatic (recommended)"
echo "       - Blackwell (5090/5080/5070/GBxx) -> cuda28"
echo "       - All other GPUs -> cuda24"
echo "  2) Force CUDA 12.4 container (t3_cuda24)"
echo "  3) Force CUDA 12.8+ container (t3_cuda28)"
echo

choice=""
if choice="$(read_from_tty "Select [1-3, default 1]: ")" ; then
  case "$choice" in
    2)
      MODE="FORCE24"
      ARCH="t3_cuda24"
      CUDA_TAG="cuda24"
      echo "Mode selected: Force cuda24 (t3_cuda24)" > /dev/tty
      ;;
    3)
      MODE="FORCE28"
      ARCH="t3_cuda28"
      CUDA_TAG="cuda28"
      echo "Mode selected: Force cuda28 (t3_cuda28)" > /dev/tty
      ;;
    *)
      MODE="AUTO"
      echo "Mode selected: Automatic" > /dev/tty
      ;;
  esac
else
  MODE="AUTO"
  echo "No interactive TTY detected – defaulting to Automatic mode."
fi

###########################################################
# If Automatic, use GPU model to decide ARCH + tag
###########################################################
if [[ "$MODE" == "AUTO" ]]; then
  GPU_MODEL_RAW="$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n1 || true)"
  GPU_MODEL="$(echo "$GPU_MODEL_RAW" | sed 's/^ *//;s/ *$//')"

  ARCH="t3_cuda24"
  CUDA_TAG="cuda24"

  if [[ -z "$GPU_MODEL" ]]; then
    echo "Could not detect GPU model via nvidia-smi. Defaulting to ARCH=t3_cuda24 (cuda24 image)."
  else
    echo "Detected GPU model: $GPU_MODEL"

    if is_blackwell "$GPU_MODEL"; then
      echo "Blackwell-class GPU detected -> using ARCH=t3_cuda28 (cuda28 image)."
      ARCH="t3_cuda28"
      CUDA_TAG="cuda28"
    else
      echo "Non-Blackwell GPU detected -> using ARCH=t3_cuda24 (cuda24 image)."
      ARCH="t3_cuda24"
      CUDA_TAG="cuda24"
    fi
  fi
fi

echo
echo "Using ARCH: $ARCH"
echo "Using image tag: $CUDA_TAG"

###########################################################
# Check GPU visibility inside Docker
###########################################################
echo
echo "Checking GPU access inside Docker..."

if ! docker run --rm --gpus all nvidia/cuda:12.4.0-base-ubuntu22.04 nvidia-smi >/dev/null 2>&1; then
  echo
  echo "ERROR: Docker cannot access your NVIDIA GPU."
  echo
  echo "Fix steps:"
  echo "  sudo apt install -y nvidia-container-toolkit"
  echo "  sudo nvidia-ctk runtime configure --runtime=docker"
  echo "  sudo systemctl restart docker"
  echo
  exit 1
fi

echo "GPU is accessible from inside Docker."

###########################################################
# Patch ARCH + image tag in YAML
###########################################################
# Update ARCH line under x-synaptron-vars
sed -i "s/^  ARCH:.*/  ARCH: ${ARCH}/" "$YML_FILE" || true

# Update image tag for timpi-synaptron-universal
# Replace any ':cudaXX' with the chosen CUDA_TAG
sed -i "s#timpiltd/timpi-synaptron-universal:cuda[0-9]\+#timpiltd/timpi-synaptron-universal:${CUDA_TAG}#g" "$YML_FILE"

###########################################################
# Start Synaptron
###########################################################
echo
echo "Starting Synaptron..."
docker compose -f "$YML_FILE" up --pull=always -d

echo
echo "========================================="
echo "   Synaptron is now running"
echo "========================================="
echo
echo "Logs:"
echo "  docker logs -f synaptron_universal"
