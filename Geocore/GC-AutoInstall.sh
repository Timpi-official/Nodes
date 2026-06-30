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

echo -e "\n✅ GeoCore is now running on port ${GEOCORE_PORT}"
echo -e "🧾 Container ID: ${CONTAINER_ID}"

# 🔄 Set up Watchtower if auto-updates were enabled
if [[ "$ENABLE_WT" =~ ^[Yy] ]]; then
  echo -e "\n🔄 Enabling automatic updates (Watchtower)..."
  sudo docker rm -f watchtower 2>/dev/null
  if sudo docker run -d --name watchtower --restart unless-stopped \
    -e DOCKER_API_VERSION=1.44 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower --interval 3600 --cleanup --label-enable >/dev/null; then
    echo -e "✅ Watchtower active — GeoCore (and any other labelled Timpi nodes on this machine) will auto-update on new releases."
  else
    echo -e "⚠️ Could not start Watchtower — GeoCore still runs; you can enable auto-updates later (see guide §3.5)."
  fi
else
  echo -e "\nℹ️ Automatic updates skipped. You can enable them later (see guide §3.5)."
fi

# 📋 Summary
echo -e "\n────────────────────────────────────────────"
echo -e "📦 GeoCore setup complete (container: geocore, port ${GEOCORE_PORT})."
if [[ "$ENABLE_WT" =~ ^[Yy] ]]; then
  echo -e "🔄 Auto-updates: ON. Watchtower checks Docker Hub about once an hour and updates"
  echo -e "   this node automatically when Timpi releases a new version (your GUID, port and"
  echo -e "   data are kept). Check it:  \033[1msudo docker logs watchtower\033[0m"
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
