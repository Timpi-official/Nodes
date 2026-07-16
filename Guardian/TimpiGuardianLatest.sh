#!/bin/bash

echo -e "\n===== Timpi Guardian – Quick Setup ====="

# 1) Prompt for Solr Port
echo -e "\n➡️ Enter the port for Solr (Default: 8983)"
read -p "SOLR Port: " SOLR_PORT
SOLR_PORT=${SOLR_PORT:-8983}

# 2) Prompt for Guardian Port
echo -e "\n➡️ Enter the port for Guardian (Default: 4005)"
read -p "Guardian Port: " GUARDIAN_PORT
GUARDIAN_PORT=${GUARDIAN_PORT:-4005}

# 3) Prompt for GUID
echo -e "\n➡️ Enter your GUID (Find it in your Timpi dashboard)"
read -p "GUID: " GUID

# 4) Prompt for location details
unset COUNTRY CITY LOCATION
echo -e "\n📍 Now, let's enter your location details step by step!"
while [[ -z "$COUNTRY" ]]; do
  read -p "🌍 Country (Example: Sweden, Germany, US): " COUNTRY
done
while [[ -z "$CITY" ]]; do
  read -p "🏙️ City (Example: Norrkoping, Berlin, NewYork): " CITY
done
LOCATION="$COUNTRY/$CITY"
echo -e "\n✅ Location set to: $LOCATION"

# 5) Ask about automatic updates (Watchtower)
echo -e "\n🔄 Automatic updates keep your Guardian on the latest version — no manual upgrades."
read -p "Enable automatic updates? [Y/n]: " ENABLE_WT
ENABLE_WT=${ENABLE_WT:-Y}
# Tracks whether Watchtower ACTUALLY started — the summary used to report the
# operator's answer instead, so it said "Auto-updates: ON" even when the start failed.
WT_STARTED=0
WT_LABEL=""
if [[ "$ENABLE_WT" =~ ^[Yy] ]]; then
  WT_LABEL="-l com.centurylinklabs.watchtower.enable=true"
fi

# 6) Ensure the solrdocker directory (with data subfolder) exists
echo -e "\n📂 Creating data folder at: ${HOME}/var/solrdocker/data (if needed)..."
sudo mkdir -p "${HOME}/var/solrdocker/data"

# 7) Remove any existing 'guardian1' container (clean re-runs; avoids random-named clutter)
sudo docker rm -f guardian1 2>/dev/null

# 8) Run the Docker container (latest Guardian, new Solr settings)
echo -e "\n🚀 Starting Timpi Guardian container (timpiltd/timpi-guardian:latest)..."
CONTAINER_ID=$(sudo docker run -d --name guardian1 --pull=always --restart unless-stopped \
  ${WT_LABEL} \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=1.1.1.1 \
  -p ${SOLR_PORT}:${SOLR_PORT} \
  -p ${GUARDIAN_PORT}:${GUARDIAN_PORT} \
  -v ${HOME}/var/solrdocker:/var/solr \
  -e SOLR_HOME=/var/solr \
  -e SOLR_DATA=/var/solr/data \
  -e SOLR_PORT=${SOLR_PORT} \
  -e GUARDIAN_PORT=${GUARDIAN_PORT} \
  -e GUID="${GUID}" \
  -e LOCATION="${LOCATION}" \
  timpiltd/timpi-guardian:latest)

# Stop here on failure. This used to print the error and then carry on to set up
# Watchtower and report "Auto-updates: ON" for a Guardian that doesn't exist.
if [[ -z "$CONTAINER_ID" ]] || ! sudo docker ps -q --filter "id=${CONTAINER_ID}" | grep -q .; then
  echo -e "\n❌ The Guardian did NOT start — nothing is running."
  echo -e "   The Docker error is printed above. The usual causes are:"
  echo -e "     • port ${GUARDIAN_PORT} or ${SOLR_PORT} is already used by something else"
  echo -e "     • Docker Hub couldn't be reached"
  echo -e "     • not enough disk space"
  # The failed run leaves a half-created husk behind, and the rm -f above already
  # removed any previous container — say so instead of implying nothing changed.
  sudo docker rm -f guardian1 >/dev/null 2>&1
  echo -e "   ⚠️ If you had a Guardian before, it has been replaced and is not running."
  echo -e "   Fix the cause above and re-run this script — your GUID and data are untouched."
  exit 1
fi

echo -e "\n✅ Guardian started successfully!"
echo "   Container ID: $CONTAINER_ID"
echo -e "\n📜 To watch it, read the Guardian's OWN log — 'docker logs' shows only Solr's output:"
echo "   sudo docker exec guardian1 sh -c 'tail -f /var/solr/logs/guardian-log*.txt'"
echo "   A healthy Guardian repeats: 'Periodic Guardian update to CO succeeded'"

# 9) Set up Watchtower if auto-updates were enabled
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
    echo -e "✅ Watchtower active — this Guardian and every other Timpi node on this machine will auto-update on new releases."
  else
    echo -e "⚠️ Could not start Watchtower — Guardian still runs; you can enable auto-updates later."
  fi
else
  echo -e "\nℹ️ Automatic updates skipped. You can enable them later (see the guide)."
fi

# 📋 Summary
echo -e "\n────────────────────────────────────────────"
echo -e "📦 Guardian setup complete (container: guardian1, Solr ${SOLR_PORT} / Guardian ${GUARDIAN_PORT})."
if [[ "$WT_STARTED" == "1" ]]; then
  echo -e "🔄 Auto-updates: ON. Watchtower checks Docker Hub about once an hour and updates"
  echo -e "   this node automatically (your GUID, ports and Solr data are kept)."
  echo -e "   Its first check is an hour from now, so its log stays quiet until then."
elif [[ "$ENABLE_WT" =~ ^[Yy] ]]; then
  echo -e "⚠️ Auto-updates: OFF — you asked for them, but Watchtower could not start (see above)."
  echo -e "   Your Guardian runs fine. Re-run this script to try again."
else
  echo -e "🔄 Auto-updates: OFF. Upgrade manually per the guide, or re-run and choose Yes."
fi
echo -e "────────────────────────────────────────────"
