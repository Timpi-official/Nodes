#!/bin/bash
set -e

echo "🛠️ Setting up TimpiCollector!"

TOTAL_CPUS=$(nproc)
TOTAL_MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_MEM_GB=$((TOTAL_MEM_KB / 1024 / 1024))
DEFAULT_CPU=$(( TOTAL_CPUS >= 4 ? 4 : TOTAL_CPUS ))
DEFAULT_MEM=$(( TOTAL_MEM_GB >= 8 ? 8 : TOTAL_MEM_GB ))
DEFAULT_SWAP=$DEFAULT_MEM

echo "🧠 Detected: ${TOTAL_CPUS} CPU cores, ${TOTAL_MEM_GB} GB RAM"
echo "💡 Default: ${DEFAULT_CPU} CPUs, ${DEFAULT_MEM}g RAM, ${DEFAULT_SWAP}g Swap"

read -p "🛠️ How many CPUs to allocate? [Enter for default: ${DEFAULT_CPU}]: " CPU_INPUT
read -p "🛠️ RAM in GB (just the number)? [Enter for default: ${DEFAULT_MEM}]: " MEM_INPUT
read -p "🛠️ Swap in GB (just the number)? [Enter for default: ${DEFAULT_SWAP}]: " SWAP_INPUT

CPU_LIMIT="${CPU_INPUT:-$DEFAULT_CPU}"
MEMORY_LIMIT="${MEM_INPUT:-$DEFAULT_MEM}g"
SWAP_LIMIT="${SWAP_INPUT:-$DEFAULT_SWAP}g"

echo "⚙️ Using: ${CPU_LIMIT} CPUs, ${MEMORY_LIMIT} RAM, ${SWAP_LIMIT} Swap"

cat <<'EOF' > Dockerfile
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
apt install -y wget unrar locales tzdata libicu70 libssl-dev libunwind-dev curl && \
ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime && \
dpkg-reconfigure -f noninteractive tzdata && \
locale-gen en_US.UTF-8 && \
apt clean
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV DOTNET_gcConcurrent=false
ENV DOTNET_ThreadPool_MinThreads=3
WORKDIR /opt/timpi
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
EOF

cat <<'EOF' > entrypoint.sh
#!/bin/bash
set -e
INSTALL_DIR="/opt/timpi"
RAR_FILE="$INSTALL_DIR/TimpiCollectorLinuxLatest.rar"
RAR_URL="https://timpi.io/applications/linux/TimpiCollectorLinuxLatest.rar"
echo "📥 Downloading collector..."
wget -q -O "$RAR_FILE" "$RAR_URL"
echo "📦 Extracting..."
unrar x -y "$RAR_FILE" "$INSTALL_DIR" > /dev/null
if [ -d "$INSTALL_DIR/TimpiCollectorLinuxLatest" ]; then
mv "$INSTALL_DIR/TimpiCollectorLinuxLatest"/* "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/TimpiCollectorLinuxLatest"
fi
chmod +x "$INSTALL_DIR/TimpiCollector"
chmod +x "$INSTALL_DIR/TimpiUI"
if [ ! -f "$INSTALL_DIR/timpi.config" ]; then
echo "🧹 No existing timpi.config found — will generate on first run."
else
echo "🛑 Detected existing timpi.config — keeping it."
fi
echo "🔁 Launching TimpiCollector loop..."
while true; do
"$INSTALL_DIR/TimpiCollector" || echo "❌ TimpiCollector crashed. Restarting in 5s..."
sleep 5
done &
echo "🖥️ Starting TimpiUI..."
"$INSTALL_DIR/TimpiUI"
EOF

chmod +x entrypoint.sh

echo "🧼 Removing old container if exists..."
docker rm -f timpi_collector 2>/dev/null || true

echo "📦 Building Docker image..."
docker build -t timpi-collector .

echo "🚀 Running container with CPU=${CPU_LIMIT}, MEMORY=${MEMORY_LIMIT}, SWAP=${SWAP_LIMIT}..."
docker run -d \
--name timpi_collector \
--restart unless-stopped \
--net=host \
--init \
--ulimit nofile=65536:65536 \
--cpus="${CPU_LIMIT}" \
--memory="${MEMORY_LIMIT}" \
--memory-swap="${SWAP_LIMIT}" \
-v /etc/localtime:/etc/localtime:ro \
timpi-collector

echo ""
echo "✅ Timpi Collector is running with your configured limits!"
echo "🌐 Web UI: http://localhost:5015/collector"
echo "🔧 Logs / Shell: docker exec -it timpi_collector bash"
```
