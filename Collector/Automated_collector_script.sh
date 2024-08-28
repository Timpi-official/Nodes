#!/bin/bash

# Define installation directory
INSTALL_DIR="/opt/timpi"

# Function to handle errors
handle_error() {
    echo "An error occurred. Exiting."
    exit 1
}

# Ensure the script is not already running
if pidof -o %PPID -x "$(basename "$0")"; then
   echo "Script is already running."
   exit 1
fi

# Remove Previous Version Of Collector
echo "Removing previous version of collector..."
sudo systemctl stop collector || true
sudo systemctl stop collector_ui || true
sudo rm -rf "$INSTALL_DIR" || true

# Update & Upgrade the system
echo "Updating and upgrading the system..."
sudo apt update && sudo apt -y upgrade || handle_error

# Create directory for Timpi
echo "Creating installation directory..."
sudo mkdir -p "$INSTALL_DIR" || handle_error

# Download the collector 0.9.0
echo "Downloading the collector 0.9.0..."
sudo wget https://timpi.io/applications/linux/TimpiCollector-0-9-0-Linux.zip -O "$INSTALL_DIR/TimpiCollector-0-9-0-Linux.zip" || handle_error

# Install Unzip if not already installed
echo "Installing unzip..."
sudo apt install -y unzip || handle_error

# Unpack The Zip Files
echo "Unpacking the collector 0.9.0..."
sudo unzip "$INSTALL_DIR/TimpiCollector-0-9-0-Linux.zip" -d "$INSTALL_DIR" || handle_error

# Install the Collector 0.9.0
echo "Installing the collector 0.9.0..."
cd "$INSTALL_DIR" || handle_error
sudo unzip TimpiCollector-0-9-0-beta.zip -d "$INSTALL_DIR" || handle_error

# Setting execute rights
echo "Setting execute permissions..."
sudo chmod +x "$INSTALL_DIR/TimpiCollector" || handle_error
sudo chmod +x "$INSTALL_DIR/TimpiUI" || handle_error

# Install Collector service
echo "Installing Collector service..."
sudo mv "$INSTALL_DIR/collector.service" /etc/systemd/system/ || handle_error
sudo mv "$INSTALL_DIR/collector_ui.service" /etc/systemd/system/ || handle_error

# Enable and start services
echo "Enabling and starting services..."
sudo systemctl enable collector || handle_error
sudo systemctl enable collector_ui || handle_error
sudo systemctl start collector || handle_error
sudo systemctl start collector_ui || handle_error

# Download the collector 0.9.1
echo "Downloading the collector 0.9.1..."
sudo wget https://timpi.io/applications/linux/TimpiCollector-0-9-1-Linux-update.zip -O "$INSTALL_DIR/TimpiCollector-0-9-1-Linux-update.zip" || handle_error

# Unpack The Files To Timpi Directory For Upgrade
echo "Upgrading to the collector version 0.9.1..."
sudo unzip -o "$INSTALL_DIR/TimpiCollector-0-9-1-Linux-update.zip" -d "$INSTALL_DIR" || handle_error

# Restart the collector UI service
echo "Restarting the collector UI service..."
sudo systemctl restart collector_ui || handle_error

echo "Installation and upgrade completed. You can now open your browser and use http://localhost:5015/collector"
echo "NOTE: If the collector is not running, please remove the timpi.config file in $INSTALL_DIR"
