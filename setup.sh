#!/bin/bash

set -euo pipefail

#-------------------------------------------
# Camera Control UI Setup Script
#-------------------------------------------
# This script performs:
#   - System package updates and dependency installation
#   - Node.js installation or validation
#   - NPM dependency installation
#   - Optional systemd service configuration and startup
#-------------------------------------------

SERVICE_NAME="camera-control-ui"
SERVICE_TEMPLATE="${SERVICE_NAME}.service.in"
SERVICE_OUTPUT="/tmp/${SERVICE_NAME}.service"
REPO_PATH="$(pwd)"
CURRENT_USER="$(whoami)"

echo "Updating system packages..."
sudo apt update

echo "Installing required system packages..."
sudo apt install -y \
  ca-certificates \
  curl \
  gettext-base \
  gnupg

install_nodejs() {
    echo "Installing Node.js LTS from NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
}

NODE_MAJOR=""
if command -v node >/dev/null 2>&1; then
    NODE_VERSION="$(node -v)"
    NODE_MAJOR="${NODE_VERSION#v}"
    NODE_MAJOR="${NODE_MAJOR%%.*}"
    echo "Detected Node.js ${NODE_VERSION}"
fi

if [ -z "${NODE_MAJOR}" ]; then
    install_nodejs
elif [ "${NODE_MAJOR}" -lt 20 ]; then
    echo "Node.js 20 or newer is required. Current version is $(node -v)."
    install_nodejs
else
    echo "Node.js version is compatible."
fi

echo "Installing project dependencies..."
if [ -f "package-lock.json" ]; then
    npm ci
else
    npm install
fi

echo
echo "Starting the Camera Control UI service configuration..."
read -p "Do you want to set up ${SERVICE_NAME}.service in systemd to start on boot? (y/n): " setup_choice

if [[ "${setup_choice}" =~ ^[Yy]$ ]]; then
    if [ ! -f "${SERVICE_TEMPLATE}" ]; then
        echo "Missing service template: ${SERVICE_TEMPLATE}"
        exit 1
    fi

    export CAMERACONTROL_UI_PATH="${REPO_PATH}"
    export CAMERACONTROL_UI_USER="${CURRENT_USER}"

    echo "Detected repository path: ${CAMERACONTROL_UI_PATH}"
    echo "Detected current user: ${CAMERACONTROL_UI_USER}"

    echo "Rendering systemd service file..."
    envsubst < "${SERVICE_TEMPLATE}" > "${SERVICE_OUTPUT}"

    echo "Installing systemd service file..."
    sudo cp "${SERVICE_OUTPUT}" "/etc/systemd/system/${SERVICE_NAME}.service"

    echo "Reloading systemd..."
    sudo systemctl daemon-reload

    echo "Enabling the service to start on boot..."
    sudo systemctl enable "${SERVICE_NAME}.service"
    echo "Service enabled successfully."

    read -p "Do you want to start ${SERVICE_NAME}.service now? (y/n): " start_choice
    if [[ "${start_choice}" =~ ^[Yy]$ ]]; then
        echo "Starting the service..."
        sudo systemctl start "${SERVICE_NAME}.service"
        echo "Service started successfully."
    else
        echo "Skipped starting the service now."
    fi
else
    echo "Skipped systemd setup."
fi

echo
echo "Setup completed."
echo "Useful commands:"
echo "  Start service:   sudo systemctl start ${SERVICE_NAME}.service"
echo "  Stop service:    sudo systemctl stop ${SERVICE_NAME}.service"
echo "  Service status:  sudo systemctl status ${SERVICE_NAME}.service"
echo "  View logs:       journalctl -u ${SERVICE_NAME}.service -f"
