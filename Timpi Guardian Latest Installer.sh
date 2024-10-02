#!/bin/bash

# Check if running as root or regular user
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Part 1: Removal of Previous Guardian Installation
echo -e "${GREEN}Starting Timpi Guardian Node Removal...${NC}"

echo "Stopping and removing the Guardian Node Docker containers..."
containers=$($SUDO docker ps -q --filter "ancestor=timpiltd/timpi-guardian")
if [ -n "$containers" ]; then
    $SUDO docker stop $containers
    $SUDO docker rm $containers
else
    echo "No running Guardian containers to stop."
fi

echo "Removing any stopped Guardian Node Docker containers..."
stopped_containers=$($SUDO docker ps -a -q --filter "ancestor=timpiltd/timpi-guardian")
if [ -n "$stopped_containers" ]; then
    $SUDO docker rm $stopped_containers
else
    echo "No stopped Guardian containers to remove."
fi

echo "Removing the Guardian Node Docker image..."
if $SUDO docker images -q timpiltd/timpi-guardian | grep -q '.'; then
    $SUDO docker rmi timpiltd/timpi-guardian
else
    echo "No Guardian Docker image to remove."
fi

echo "Removing persistent data folder..."
GUARDIAN_STORAGE="$HOME/guardian-storage"
if [ -d "$GUARDIAN_STORAGE" ]; then
    $SUDO rm -rf $GUARDIAN_STORAGE
else
    echo "No Guardian storage directory to remove."
fi

echo "Uninstalling Docker..."
$SUDO apt-get purge -y docker-ce docker-ce-cli containerd.io
$SUDO apt-get autoremove -y
$SUDO apt-get clean

echo "Removing Docker repository..."
$SUDO rm /etc/apt/sources.list.d/docker.list

echo -e "${GREEN}Previous Guardian Node installation removed.${NC}"

# Part 2: Installation of New Guardian Node
echo -e "${GREEN}Starting Timpi Guardian Node Installation...${NC}"

echo "Updating package list and installing prerequisites..."
$SUDO apt update && $SUDO apt install -y apt-transport-https ca-certificates curl software-properties-common

echo "Adding Docker’s GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Adding Docker repository..."
echo "deb [arch=$($SUDO dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $($SUDO lsb_release -cs) stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating package list again..."
$SUDO apt update

echo "Installing Docker..."
$SUDO apt install -y docker-ce

echo "Enabling Docker to start on boot..."
$SUDO systemctl enable docker

echo "Installing default Java Runtime Environment..."
$SUDO apt install -y default-jre

echo "Checking Docker status..."
$SUDO systemctl status docker --no-pager

echo "Preparing the Guardian Docker environment..."
GUARDIAN_STORAGE="$HOME/guardian-storage"
mkdir -p $GUARDIAN_STORAGE/data

echo "Pulling the Guardian Node Docker image..."
$SUDO docker pull timpiltd/timpi-guardian

echo ""
echo "*******************************************"
echo "[YOUR GUID]"
echo "*******************************************"
echo "This MUST be the same GUID you have received when you registered the Guardian."
echo "Make sure to enter it correctly."
echo ""
read -p "Please enter your GUID: " GUID

echo ""
echo "*******************************************"
echo "[THE GUARDIAN EXTERNAL IP OR DOMAIN]"
echo "*******************************************"
echo "This MUST be the same IP/Domain you have used for the registration."
echo "The Guardian Docker container MUST be accessible from external over this IP/Domain."
echo "Ensure the IP/Domain is correct and accessible."
echo ""
read -p "Please enter your external IP or domain (SOLR_HOST): " SOLR_HOST

echo "Running the Guardian Node Docker container..."
$SUDO docker run -d --restart unless-stopped --pull=always \
    -p 8983:8983 \
    -p 4005:4005 \
    -v $GUARDIAN_STORAGE:/var/solr \
    -e SOLR_PORT=8983 \
    -e GUARDIAN_PORT=4005 \
    -e SOLR_HOST=$SOLR_HOST \
    -e GUID=$GUID \
    timpiltd/timpi-guardian

echo -e "${GREEN}Timpi Guardian Node setup is complete.${NC}"
