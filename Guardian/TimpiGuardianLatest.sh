#!/bin/bash

# Prompt for Solr Port
echo -e "\n➡️ Enter the port for Solr (Default: 8983)"
read -p "SOLR Port: " SOLR_PORT
SOLR_PORT=${SOLR_PORT:-8983}

# Prompt for Guardian Port
echo -e "\n➡️ Enter the port for Guardian (Default: 4005)"
read -p "Guardian Port: " GUARDIAN_PORT
GUARDIAN_PORT=${GUARDIAN_PORT:-4005}

# Prompt for GUID
echo -e "\n➡️ Enter your GUID (Find it in your Timpi dashboard)"
read -p "GUID: " GUID

# Prompt for location details
unset COUNTRY CITY LOCATION
echo -e "\n📍 Now, let's enter your **location details** step by step!"
while [[ -z "$COUNTRY" ]]; do
  read -p "🌍 Country (Example: US, Germany, UK): " COUNTRY
done
while [[ -z "$CITY" ]]; do
  read -p "🏡 City (Example: New York, Berlin, London) OR a major city in your region: " CITY
done
LOCATION="$COUNTRY/$CITY"
echo -e "\n✅ Location set to: $LOCATION"

# Ensure the solrdocker directory exists
sudo mkdir -p ${HOME}/var/solrdocker

# Run the Docker container
echo -e "\n🚀 Starting Timpi Guardian container..."
sudo docker run -d --pull=always --restart unless-stopped \
  --dns=100.42.180.29 --dns=100.42.180.99 --dns=8.8.8.8 \
  -p ${SOLR_PORT}:${SOLR_PORT} \
  -p ${GUARDIAN_PORT}:${GUARDIAN_PORT} \
  -v ${HOME}/var/solrdocker:/var/solr \
  -e SOLR_PORT=${SOLR_PORT} \
  -e GUARDIAN_PORT=${GUARDIAN_PORT} \
  -e GUID="${GUID}" \
  -e LOCATION="${LOCATION}" \
  timpiltd/timpi-guardian:latest
