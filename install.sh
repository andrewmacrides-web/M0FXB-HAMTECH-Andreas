#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="andrewmacrides-web"
REPO_NAME="M0FXB-HAMTECH-Andreas"
BRANCH="main"
ZIP_NAME="M0FXB-HamTech-ASL3-Share.zip"
RAW_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/${ZIP_NAME}"

if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: Please run this installer with sudo/root."
    echo "Example:"
    echo "  wget -qO- https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/install.sh | sudo bash"
    exit 1
fi

echo
echo "=============================================="
echo "  M0FXB HamTech Dashboard - ASL3 Installer"
echo "=============================================="
echo

# Make sure unzip is available.
if ! command -v unzip >/dev/null 2>&1; then
    echo "Installing unzip..."
    apt-get update --allow-releaseinfo-change
    apt-get install -y unzip
fi

# wget should already exist because this bootstrap is normally launched with wget,
# but check anyway in case the script was downloaded another way.
if ! command -v wget >/dev/null 2>&1; then
    echo "Installing wget..."
    apt-get update --allow-releaseinfo-change
    apt-get install -y wget
fi

TMPDIR="$(mktemp -d /tmp/m0fxb-hamtech.XXXXXX)"
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading HamTech package..."
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

bash "$INSTALLER"
