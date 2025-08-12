#!/bin/bash

echo -e "\n🌐 Timpi GeoCore Setup"

# 🔌 Prompt for GeoCore Port
echo -e "\n➡️ Enter the port for GeoCore (Default: 4100)"
read -p "GeoCore Port: " GEOCORE_PORT
GEOCORE_PORT=${GEOCORE_PORT:-4100}

# 🆔 Prompt for GUID
echo -e "\n🆔 Enter your GUID (Found in your Timpi dashboard)"
read -p "GUID: " GUID

# 📍 Prompt for location (Country/City)
unset COUNTRY CITY LOCATION
echo -e "\n📍 Let's enter your location"
while [[ -z "$COUNTRY" ]]; do
  read -p "🌍 Country (Example: Sweden, Germany, United States): " COUNTRY
done
while [[ -z "$CITY" ]]; do
  read -p "🏙️ City (Example: Stockholm, Berlin, New York): " CITY
done
LOCATION="$COUNTRY/$CITY"
echo -e "\n✅ Location set to: $LOCATION"

# 📁 Prepare data folder
DATA_DIR="$HOME/timpi"
echo -e "\n🗂️ Creating data folder at: $DATA_DIR"
sudo mkdir -p "$DATA_DIR"
sudo chown 1000:1000 "$DATA_DIR"

# 🐳 Run GeoCore Docker container
echo -e "\n🚀 Launching GeoCore container..."
sudo docker run -d --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=8.8.8.8 \
  -p ${GEOCORE_PORT}:${GEOCORE_PORT} \
  -v ${DATA_DIR}:/var/timpi \
  -e CONPORT=${GEOCORE_PORT} \
  -e GUID="${GUID}" \
  -e LOCATION="${LOCATION}" \
  timpiltd/timpi-geocore:latest

echo -e "\n✅ GeoCore is now running on port ${GEOCORE_PORT}"

# 📄 Show plain-text commands for later
echo
echo "📡 To view logs later:"
echo "• Log files on host:"
echo "  sudo tail -n +1 -F \"\$HOME/timpi/GeoCore-log*.txt\""
echo
echo "• Docker logs:"
echo "  sudo docker logs -f --tail 50 <YOUR-CONTAINERID>"
echo
echo "• Restart / Stop:"
echo "  sudo docker restart <YOUR-CONTAINERID>"
echo "  sudo docker stop <YOUR-CONTAINERID>"
echo
echo "• Remove container:"
echo "  sudo docker rm -f <YOUR-CONTAINERID>"
echo
echo "• Remove image:"
echo "  sudo docker rmi timpiltd/timpi-geocore:latest"
echo
