#!/bin/bash

# Script Name: Timpi Guardian Latest Installer.sh
# Description: Guardian setup script
# Revision: 1.0.1 # Initial version of the Synaptron setup script
# Author: [Johno]
# Last Updated: [2025-01-25]

# Changelog:
# v1.0.0 - Initial version of the Guardian setup script
# v1.0.1 - Added Timpi logo, changed the installation of how docker was installed, added revision and changelog.

# Display Timpi ASCII Logo
echo "================================================================"
echo "             ████████╗██╗███╗   ███╗██████╗ ██╗"
echo "             ╚══██╔══╝██║████╗ ████║██╔══██╗██║"
echo "                ██║   ██║██╔████╔██║██████╔╝██║"
echo "                ██║   ██║██║╚██╔╝██║██╔═══╝ ██║"
echo "                ██║   ██║██║ ╚═╝ ██║██║     ██║"
echo "                ╚═╝   ╚═╝╚═╝     ╚═╝╚═╝     ╚═╝"
echo "================================================================"
echo "                  Welcome to Guardian Setup"
echo "================================================================"

# Check if running as root or regular user
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Step 1: Update and Install Essentials
echo "=== Step 1: Updating and Installing Essentials ==="
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

# Welcome message
echo -e "${GREEN}Starting Timpi Guardian Node Installation and Removal Script${NC}"
echo -e "${YELLOW}Ensure you have your GUID and external IP/Domain handy.${NC}"

# Part 1: Removal of Previous Guardian Installation
echo -e "${GREEN}Removing any existing Guardian Node installation...${NC}"
containers=$($SUDO docker ps -q --filter "ancestor=timpiltd/timpi-guardian")
if [ -n "$containers" ]; then
    $SUDO docker stop $containers
    $SUDO docker rm $containers
else
    echo "No running Guardian containers to stop."
fi

stopped_containers=$($SUDO docker ps -a -q --filter "ancestor=timpiltd/timpi-guardian")
if [ -n "$stopped_containers" ]; then
    $SUDO docker rm $stopped_containers
else
    echo "No stopped Guardian containers to remove."
fi

if $SUDO docker images -q timpiltd/timpi-guardian | grep -q '.'; then
    $SUDO docker rmi timpiltd/timpi-guardian
else
    echo "No Guardian Docker image to remove."
fi

GUARDIAN_STORAGE="$HOME/guardian-storage"
if [ -d "$GUARDIAN_STORAGE" ]; then
    $SUDO rm -rf $GUARDIAN_STORAGE
else
    echo "No Guardian storage directory to remove."
fi

echo -e "${GREEN}Previous Guardian Node installation removed.${NC}"

# Part 2: Installation of New Guardian Node
echo -e "${GREEN}Starting Timpi Guardian Node Installation...${NC}"

$SUDO apt update && $SUDO apt install -y apt-transport-https ca-certificates curl software-properties-common
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker not found. Installing Docker...${NC}"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    echo "deb [arch=$($SUDO dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $($SUDO lsb_release -cs) stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    $SUDO apt update
    $SUDO apt install -y docker-ce
    $SUDO systemctl enable docker
    $SUDO systemctl start docker
else
    echo -e "${GREEN}Docker is already installed. Skipping Docker installation.${NC}"
fi

$SUDO apt install -y default-jre
mkdir -p $GUARDIAN_STORAGE/data

# Port selection
echo -e "${GREEN}Port Configuration${NC}"
echo "1) Use Default Ports (4005 and 8983)"
echo "2) Specify Custom Ports"
read -p "Choose an option (1-2): " PORT_OPTION

case $PORT_OPTION in
    1)
        GUARDIAN_PORT=4005
        SOLR_PORT=8983
        echo -e "${YELLOW}Using default ports: Guardian Port=$GUARDIAN_PORT, Solr Port=$SOLR_PORT${NC}"
        ;;
    2)
        read -p "Enter custom Guardian port: " GUARDIAN_PORT
        read -p "Enter custom Solr port: " SOLR_PORT
        echo -e "${YELLOW}Using custom ports: Guardian Port=$GUARDIAN_PORT, Solr Port=$SOLR_PORT${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

# User inputs
read -p "Enter your GUID (This MUST match your Guardian registration): " GUID
read -p "Enter your external IP or domain (This MUST match your Guardian registration): " SOLR_HOST

# Run the Guardian Node Docker container
echo -e "${GREEN}Running the Guardian Node Docker container...${NC}"
$SUDO docker run -d --restart unless-stopped --pull=always \
    -p $GUARDIAN_PORT:4005 \
    -p $SOLR_PORT:8983 \
    -v $GUARDIAN_STORAGE:/var/solr \
    -e SOLR_PORT=$SOLR_PORT \
    -e GUARDIAN_PORT=$GUARDIAN_PORT \
    -e SOLR_HOST=$SOLR_HOST \
    -e GUID=$GUID \
    timpiltd/timpi-guardian

echo -e "${GREEN}Timpi Guardian Node setup is complete.${NC}"
echo -e "${YELLOW}Guardian Port: $GUARDIAN_PORT, Solr Port: $SOLR_PORT${NC}"
