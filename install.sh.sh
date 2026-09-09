#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="andrewmacrides-web"
REPO_NAME="M0FXB-HAMTECH-Andreas"
BRANCH="main"

# V1 package with:
# - automatic IP address display
# - large light-blue PayPal Donate button
# - no browser audio streaming
ZIP_NAME="M0FXB-HamTech-ASL3-Share-IP-PayPal.zip"
RAW_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/${ZIP_NAME}"

if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: Please run this installer with sudo/root."
    echo "Example:"
    echo "  wget -qO- https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/install.sh | sudo bash"
    exit 1
fi

echo
echo "===================================================="
echo " M0FXB HamTech Dashboard - ASL3 Installer"
echo " IP Display + PayPal Donate Edition"
echo "===================================================="
echo

if ! command -v unzip >/dev/null 2>&1; then
    echo "Installing unzip..."
    apt-get update --allow-releaseinfo-change
    apt-get install -y unzip
fi

if ! command -v wget >/dev/null 2>&1; then
    echo "Installing wget..."
    apt-get update --allow-releaseinfo-change
    apt-get install -y wget
fi

TMPDIR="$(mktemp -d /tmp/m0fxb-hamtech.XXXXXX)"
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading HamTech package with IP display and PayPal Donate button..."
wget -q --show-progress -O "$TMPDIR/$ZIP_NAME" "$RAW_URL"

echo "Extracting package..."
unzip -q "$TMPDIR/$ZIP_NAME" -d "$TMPDIR"

INSTALLER="$TMPDIR/M0FXB-HamTech-ASL3-Share/install.sh"

if [[ ! -f "$INSTALLER" ]]; then
    echo "ERROR: install.sh was not found inside the downloaded package."
    exit 1
fi

chmod +x "$INSTALLER"

echo
echo "Package downloaded successfully."
echo "Starting the HamTech ASL3 installer..."
echo

if [[ -r /dev/tty ]]; then
    bash "$INSTALLER" </dev/tty
else
    echo "ERROR: No interactive terminal is available."
    echo "Download install.sh first, then run it with sudo bash."
    exit 1
fi
