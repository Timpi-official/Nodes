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

# 5) Ensure the solrdocker directory (with data subfolder) exists
echo -e "\n📂 Creating data folder at: ${HOME}/var/solrdocker/data (if needed)..."
sudo mkdir -p "${HOME}/var/solrdocker/data"

# 6) Run the Docker container (latest Guardian, new Solr settings)
echo -e "\n🚀 Starting Timpi Guardian container (timpiltd/timpi-guardian:latest)..."
CONTAINER_ID=$(sudo docker run -d --pull=always --restart unless-stopped \
  --dns=100.42.180.116 --dns=1.1.1.1 \
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

if [[ -n "$CONTAINER_ID" ]]; then
  echo -e "\n✅ Guardian started successfully!"
  echo "   Container ID: $CONTAINER_ID"
  echo -e "\n📜 To view logs, run:"
  echo "   sudo docker logs -f $CONTAINER_ID"
else
  echo -e "\n❌ Something went wrong starting the Guardian container."
  echo "   Please check: sudo docker ps -a"
fi
