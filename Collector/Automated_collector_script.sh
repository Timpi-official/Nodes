#!/bin/bash

# Define installation directory
INSTALL_DIR="/opt/timpi"

# Function to handle errors
handle_error() {
    echo "An error occurred. Exiting."
    exit 1
}

# Remove Previous Version Of Collector
echo "Removing previous version of collector..."
sudo systemctl stop collector || true
sudo systemctl stop collector_ui || true
sudo rm -rf "$INSTALL_DIR" || true

# Update & Upgrade the system
echo "Updating and upgrading the system..."
sudo apt update && sudo apt -y upgrade || handle_error

# Create directory for Timpi
sudo mkdir -p "$INSTALL_DIR" || handle_error

# Install Unzip if not already installed
echo "Installing unzip..."
sudo apt install -y unzip || handle_error

# Install Unrar if not already installed
echo "Installing unrar..."
sudo apt install -y unrar || handle_error

# Download the latest collector version (0.9.5)
echo "Downloading the latest collector version (0.9.5)..."
sudo wget https://timpi.io/applications/linux/TimpiCollectorLinuxLatest.rar -O "$INSTALL_DIR/TimpiCollectorLinuxLatest.rar" || handle_error

# Unpack The RAR Files To Timpi Directory For Upgrade, overwriting any existing files
echo "Upgrading to the latest collector version (0.9.5)..."
sudo unrar e -y "$INSTALL_DIR/TimpiCollectorLinuxLatest.rar" "$INSTALL_DIR" || handle_error

# Setting correct permissions for TimpiCollector and TimpiUI
echo "Setting execute permissions for TimpiCollector and TimpiUI..."
sudo chmod 755 "$INSTALL_DIR/TimpiCollector" || handle_error
sudo chmod 755 "$INSTALL_DIR/TimpiUI" || handle_error

# Install Collector service
echo "Installing Collector service..."
sudo mv "$INSTALL_DIR/collector.service" /etc/systemd/system/ || handle_error
sudo mv "$INSTALL_DIR/collector_ui.service" /etc/systemd/system/ || handle_error

# Clean up by removing the old archives
echo "Cleaning up..."
sudo rm -rf "$INSTALL_DIR/TimpiCollectorLinuxLatest.rar" || handle_error

# Enable and start services
sudo systemctl enable collector || handle_error
sudo systemctl enable collector_ui || handle_error
sudo systemctl start collector || handle_error
sudo systemctl start collector_ui || handle_error

echo "Installation and upgrade completed. You can now open your browser and use http://localhost:5015/collector"
echo "NOTE: If the collector is not running, please remove the timpi.config file in $INSTALL_DIR"
