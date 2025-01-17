#!/bin/bash

# Exit script on error
set -e

# Function to print error and exit
error_exit() {
    echo "Error: $1"
    exit 1
}

# Check for required tools
for cmd in git gcc make; do
    if ! command -v $cmd &>/dev/null; then
        error_exit "$cmd is required but not installed."
    fi
done

# Define variables
PACMAN_VERSION="6.0.2" # Adjust this to the desired version
PACMAN_URL="https://gitlab.archlinux.org/pacman/pacman.git"
BUILD_DIR="$HOME/pacman-build"

# Install dependencies
echo "Installing dependencies..."
sudo apt-get install -y libarchive-dev curl-dev gpgme-dev python3-dev || \
    error_exit "Failed to install dependencies. Install them manually and rerun the script."

# Clone pacman repository
echo "Cloning pacman repository..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
git clone "$PACMAN_URL"
cd pacman

# Checkout the desired version
echo "Checking out version $PACMAN_VERSION..."
git checkout "v$PACMAN_VERSION" || error_exit "Failed to checkout version $PACMAN_VERSION."

# Build and install pacman
echo "Building pacman..."
./autogen.sh || error_exit "Autogen failed."
./configure || error_exit "Configure failed."
make || error_exit "Make failed."

echo "Installing pacman..."
sudo make install || error_exit "Installation failed."

# Cleanup
echo "Cleaning up..."
cd ~
rm -rf "$BUILD_DIR"

# Verify installation
if command -v pacman &>/dev/null; then
    echo "Pacman installed successfully!"
else
    error_exit "Pacman installation failed."
fi
