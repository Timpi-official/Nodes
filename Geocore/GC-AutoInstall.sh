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

# 🐳 Run GeoCore Docker container
echo -e "\n🚀 Launching GeoCore container..."
CONTAINER_ID=$(sudo docker run -d --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=1.1.1.1 \
  -p ${GEOCORE_PORT}:${GEOCORE_PORT} \
  -v /var/timpi:/var/timpi \
  -e COMPORT=${GEOCORE_PORT} \
  -e GUID="${GUID}" \
  -e LOCATION="${LOCATION}" \
  timpiltd/timpi-geocore:latest)

echo -e "\n✅ GeoCore is now running on port ${GEOCORE_PORT}"
echo -e "🧾 Container ID: ${CONTAINER_ID}"

# 📄 Show how to check logs
echo -e "\n📡 To view logs:\n"

echo -e "1️⃣  Real-time log file:"
echo -e "    \033[1msudo tail -f \$(ls -t /var/timpi/GeoCore/logs/GeoCore-log*.txt | head -n 1)\033[0m"

echo -e "\n2️⃣  Docker logs:"
echo -e "    \033[1msudo docker logs -f --tail 50 ${CONTAINER_ID}\033[0m"

echo -e "\n🧠 Tip: Press \033[1mCtrl + C\033[0m to stop viewing the logs.\n"
