#!/bin/bash
set -e

# Detect physical CPU cores
TOTAL_CPUS=$(lscpu | awk '/^Core\(s\) per socket:/ {cores=$4} /^Socket\(s\):/ {sockets=$2} END {print cores * sockets}')
# Detect total threads for reference
TOTAL_THREADS=$(nproc)

# Detect total memory in GB
TOTAL_MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_MEM_GB=$((TOTAL_MEM_KB / 1024 / 1024))

# Fixed displayed defaults (not dynamic)
DEFAULT_CPU=2
DEFAULT_MEM=2
DEFAULT_SWAP=4

echo "🧠 Detected: ${TOTAL_CPUS} physical CPU cores (${TOTAL_THREADS} threads), ${TOTAL_MEM_GB} GB RAM"
echo "💡 Default: ${DEFAULT_CPU} CPUs, ${DEFAULT_MEM}g RAM, ${DEFAULT_SWAP}g Swap"

read -p "🛠️  CPUs to allocate? [default: ${DEFAULT_CPU}]: " CPU_INPUT
read -p "🛠️  RAM in GB? [default: ${DEFAULT_MEM}]: " MEM_INPUT
read -p "🛠️  Swap in GB? [default: ${DEFAULT_SWAP}]: " SWAP_INPUT

CPU_LIMIT="${CPU_INPUT:-$DEFAULT_CPU}"
MEMORY_LIMIT="${MEM_INPUT:-$DEFAULT_MEM}g"
SWAP_LIMIT="${SWAP_INPUT:-$DEFAULT_SWAP}g"

echo "🚀 Launching container with your settings..."

sudo docker run -d \
  --name timpi_collector \
  --restart unless-stopped \
  --net=host \
  --init \
  --ulimit nofile=65536:65536 \
  --cpus="${CPU_LIMIT}" \
  --memory="${MEMORY_LIMIT}" \
  --memory-swap="${SWAP_LIMIT}" \
  -v /etc/localtime:/etc/localtime:ro \
  timpiltd/timpi-collector:latest
