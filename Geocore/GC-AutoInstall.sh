#!/bin/bash

echo -e "\n🌐 Timpi GeoCore Setup Script"

# 🔌 Prompt for GeoCore Port
echo -e "\n➡️ Enter the port for GeoCore (Default: 4013)"
read -p "GeoCore Port: " GEOCORE_PORT
GEOCORE_PORT=${GEOCORE_PORT:-4013}

# 🆔 Prompt for GUID
echo -e "\n🆔 Enter your GUID (Found in your Timpi dashboard)"
read -p "GUID: " GUID

# 📍 Prompt for location (Country/City)
unset COUNTRY CITY LOCATION
echo -e "\n📍 Let's enter your **location**"
while [[ -z "$COUNTRY" ]]; do
  read -p "🌍 Country (Example: Sweden, Germany, United States): " COUNTRY
done
while [[ -z "$CITY" ]]; do
  read -p "🏙️ City (Example: Stockholm, Berlin, New York): " CITY
done
LOCATION="$COUNTRY/$CITY"
echo -e "\n✅ Location set to: $LOCATION"

# 🔄 Ask about automatic updates (Watchtower)
echo -e "\n🔄 Automatic updates keep your GeoCore on the latest version — no manual upgrades."
read -p "Enable automatic updates? [Y/n]: " ENABLE_WT
ENABLE_WT=${ENABLE_WT:-Y}
# Tracks whether Watchtower ACTUALLY started — the summary used to report the
# operator's answer instead, so it said "Auto-updates: ON" even when the start failed.
WT_STARTED=0
WT_LABEL=""
if [[ "$ENABLE_WT" =~ ^[Yy] ]]; then
  WT_LABEL="-l com.centurylinklabs.watchtower.enable=true"
fi

# 🧹 Remove any existing 'geocore' container (clean re-runs; avoids random-named clutter)
sudo docker rm -f geocore 2>/dev/null

# 🐳 Run GeoCore Docker container
echo -e "\n🚀 Launching GeoCore container..."
CONTAINER_ID=$(sudo docker run -d --name geocore --pull=always --restart unless-stopped \
  ${WT_LABEL} \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=1.1.1.1 \
  -p ${GEOCORE_PORT}:${GEOCORE_PORT} \
  -v /var/timpi:/var/timpi \
  -e COMPORT=${GEOCORE_PORT} \
  -e GUID="${GUID}" \
  -e LOCATION="${LOCATION}" \
  timpiltd/timpi-geocore:latest)

# Never claim success we haven't verified. Without this the script printed
# "✅ GeoCore is now running" and "setup complete" even when docker run had failed
# and nothing existed — the operator walks away believing they have a node.
if [[ -z "$CONTAINER_ID" ]] || ! sudo docker ps -q --filter "id=${CONTAINER_ID}" | grep -q .; then
  echo -e "\n❌ GeoCore did NOT start — nothing is running."
  echo -e "   The Docker error is printed above. The usual causes are:"
  echo -e "     • port ${GEOCORE_PORT} is already used by something else"
  echo -e "     • Docker Hub couldn't be reached"
  echo -e "     • not enough disk space"
  # The failed run leaves a half-created husk behind, and the rm -f above already
  # removed any previous container — say so instead of implying nothing changed.
  sudo docker rm -f geocore >/dev/null 2>&1
  echo -e "   ⚠️ If you had a GeoCore before, it has been replaced and is not running."
  echo -e "   Fix the cause above and re-run this script — your GUID and data are untouched."
  exit 1
fi

echo -e "\n✅ GeoCore is now running on port ${GEOCORE_PORT}"
echo -e "🧾 Container ID: ${CONTAINER_ID}"

# 🔄 Set up Watchtower if auto-updates were enabled
if [[ "$ENABLE_WT" =~ ^[Yy] ]]; then
  echo -e "\n🔄 Enabling automatic updates (Watchtower)..."
  # Name-based, matching every guide and announcement — NOT --label-enable.
  # This replaces any existing Watchtower, so it must cover what the previous one did:
  # an operator who set theirs up from an announcement has UNLABELLED containers, and a
  # --label-enable Watchtower silently covers none of them (verified: Scanned 3 -> 0).
  # Names that aren't running are ignored, so one list is safe for everyone.
  sudo docker rm -f watchtower 2>/dev/null
  if sudo docker run -d --name watchtower --restart unless-stopped \
    -e DOCKER_API_VERSION=1.44 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower --interval 3600 --cleanup \
    geocore geocore2 geocore3 guardian1 guardian2 \
    timpi-collector timpi-collector-1 timpi-collector-2 >/dev/null; then
    WT_STARTED=1
    echo -e "✅ Watchtower active — this GeoCore and every other Timpi node on this machine will auto-update on new releases."
  else
    echo -e "⚠️ Could not start Watchtower — GeoCore still runs; you can enable auto-updates later (see guide §3.5)."
  fi
else
  echo -e "\nℹ️ Automatic updates skipped. You can enable them later (see guide §3.5)."
fi

# 📋 Summary
echo -e "\n────────────────────────────────────────────"
echo -e "📦 GeoCore setup complete (container: geocore, port ${GEOCORE_PORT})."
if [[ "$WT_STARTED" == "1" ]]; then
  echo -e "🔄 Auto-updates: ON. Watchtower checks Docker Hub about once an hour and updates"
  echo -e "   this node automatically when Timpi releases a new version (your GUID, port and"
  echo -e "   data are kept)."
  echo -e "   Its first check is an hour from now, so its log stays quiet until then."
elif [[ "$ENABLE_WT" =~ ^[Yy] ]]; then
  echo -e "⚠️ Auto-updates: OFF — you asked for them, but Watchtower could not start (see above)."
  echo -e "   Your GeoCore runs fine. Re-run this script to try again."
else
  echo -e "🔄 Auto-updates: OFF. Upgrade manually per the guide, or re-run this script and"
  echo -e "   choose Yes to turn on automatic updates."
fi
echo -e "────────────────────────────────────────────"

# 📄 Show how to check logs
echo -e "\n📡 To view logs:\n"

echo -e "1️⃣  Real-time log file:"
echo -e "    \033[1msudo tail -f \$(ls -t /var/timpi/GeoCore/logs/GeoCore-log*.txt | head -n 1)\033[0m"

echo -e "\n2️⃣  Docker logs:"
echo -e "    \033[1msudo docker logs -f --tail 50 ${CONTAINER_ID}\033[0m"

echo -e "\n🧠 Tip: Press \033[1mCtrl + C\033[0m to stop viewing the logs.\n"
