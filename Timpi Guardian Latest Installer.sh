#!/bin/bash

# Script Name: Timpi Guardian Auto-Installer
# Description: Installs and configures the Timpi Guardian Node.
# Revision: 1.1.0 # Improved installation process based on Synaptron setup
# Author: [Johno]
# Last Updated: [2025-01-31]

# Changelog:
# v1.0.0 - Initial version of the Guardian setup script
# v1.1.0 - Improved installation steps, added structured user input, and better logging
# v1.1.1 - Added Confirmation steps and overall improvements

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

# Confirm user wants to proceed
while true; do
    read -p "Do you want to procceed with the installation? (yes/no): " yn
    case $yn in
        [Yy]* ) break ;;
        [Nn]* ) echo "Goodbye Maby Another Time."; exit ;;
        * ) echo "Please answer yes or no." ;;
    esac
done

# Check if running as root or regular user
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Step 1: Update and Install Required Packages
echo "🔹 Updating system and installing required packages..."
$SUDO apt update && $SUDO apt install -y apt-transport-https ca-certificates curl software-properties-common default-jre

# Step 2: Add Docker Repository and Install Docker
echo "🔹 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$($SUDO dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $($SUDO lsb_release -cs) stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
    $SUDO apt update && $SUDO apt install -y docker-ce
    $SUDO systemctl enable docker && $SUDO systemctl start docker
else
    echo "✅ Docker is already installed. Skipping installation."
fi

# Step 3: User Input for Configuration
while true; do
    read -p "Enter your GUID (must match Guardian registration): " GUID
    [[ -n "$GUID" ]] && break || echo "❌ GUID cannot be empty. Try again."
done

while true; do
    read -p "Enter your external IP or domain (must match Guardian registration): " SOLR_HOST
    [[ -n "$SOLR_HOST" ]] && break || echo "❌ IP/Domain cannot be empty. Try again."
done

# Port Configuration
echo "🔹 Configuring Ports..."
echo "1) Use Default Ports (4005 and 8983)"
echo "2) Specify Custom Ports"
read -p "Choose an option (1-2): " PORT_OPTION
case $PORT_OPTION in
    1)
        GUARDIAN_PORT=4005
        SOLR_PORT=8983
        ;;
    2)
        while true; do
            read -p "Enter custom Guardian port: " GUARDIAN_PORT
            [[ "$GUARDIAN_PORT" =~ ^[0-9]+$ ]] && break || echo "❌ Invalid port. Please enter a number."
        done
        while true; do
            read -p "Enter custom Solr port: " SOLR_PORT
            [[ "$SOLR_PORT" =~ ^[0-9]+$ ]] && break || echo "❌ Invalid port. Please enter a number."
        done
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "✅ Ports configured: Guardian Port=$GUARDIAN_PORT, Solr Port=$SOLR_PORT"

# Ensure Guardian Storage Directory Exists
GUARDIAN_STORAGE="$HOME/guardian-storage"
echo "🔹 Ensuring Guardian storage directory exists..."
mkdir -p $GUARDIAN_STORAGE

# Step 4: Run Guardian Node Container
echo "🔹 Running Guardian Node Docker container..."
$SUDO docker run -d --restart unless-stopped --pull=always \
    -p $GUARDIAN_PORT:$GUARDIAN_PORT \
    -p $SOLR_PORT:$SOLR_PORT \
    -v $GUARDIAN_STORAGE:/var/solr \
    -e SOLR_PORT=$SOLR_PORT \
    -e GUARDIAN_PORT=$GUARDIAN_PORT \
    -e SOLR_HOST=$SOLR_HOST \
    -e GUID=$GUID \
    timpiltd/timpi-guardian

echo "========================================================================="
echo "🎉 Guardian Node Setup Complete! 🎉"
echo ""
echo "Use the following commands to monitor your setup:"
echo "1️⃣  Check running containers: sudo docker ps"
echo "2️⃣  View logs in real-time: sudo docker logs -f <container_id>"
echo "========================================================================="
