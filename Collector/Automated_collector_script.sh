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

# Create Collector service file if it doesn't exist
if [ ! -f /etc/systemd/system/collector.service ]; then
    echo "Creating collector.service..."
    sudo bash -c 'cat > /etc/systemd/system/collector.service <<EOF
[Unit]
Description=Timpi Collector Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/timpi
ExecStart=/opt/timpi/TimpiCollector
Restart=always

[Install]
WantedBy=multi-user.target
EOF'
fi

# Create Collector UI service file if it doesn't exist
if [ ! -f /etc/systemd/system/collector_ui.service ]; then
    echo "Creating collector_ui.service..."
    sudo bash -c 'cat > /etc/systemd/system/collector_ui.service <<EOF
[Unit]
Description=Timpi Collector UI Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/timpi
ExecStart=/opt/timpi/TimpiUI
Restart=always

[Install]
WantedBy=multi-user.target
EOF'
fi

# Clean up by removing the old archives
echo "Cleaning up..."
sudo rm -rf "$INSTALL_DIR/TimpiCollectorLinuxLatest.rar" || handle_error

# Reload and enable services
echo "Reloading and enabling services..."
sudo systemctl daemon-reload || handle_error
sudo systemctl enable collector || handle_error
sudo systemctl enable collector_ui || handle_error

# Start services
echo "Starting services..."
sudo systemctl start collector || handle_error
sudo systemctl start collector_ui || handle_error

# Check status of services
echo "Checking service statuses..."
sudo systemctl status collector
sudo systemctl status collector_ui

echo "Installation and upgrade completed. You can now open your browser and use http://localhost:5015/collector"
echo "NOTE: If the collector is not running, please remove the timpi.config file in $INSTALL_DIR"
