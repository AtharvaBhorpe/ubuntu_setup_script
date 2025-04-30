#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo privileges."
  exit 1
fi

echo "=== Starting system setup ==="

# Step 1: Update system packages
echo "Updating system packages..."
apt update
echo "System packages updated."

# Step 2: Install nala (better apt interface)
echo "Installing nala..."
apt-get install nala -y
echo "Nala installed."

# Step 3: Update .bashrc to include any potential new aliases
echo "Sourcing .bashrc..."
if [ -f "/home/$SUDO_USER/.bashrc" ]; then
  source "/home/$SUDO_USER/.bashrc"
  echo ".bashrc sourced."
else
  echo ".bashrc not found."
fi

# Step 4: Update and upgrade using nala
echo "Updating and upgrading packages with nala..."
nala update && nala full-upgrade -y
echo "System fully upgraded with nala."

# Step 5-7: Install flatpak if not already installed
echo "Setting up flatpak..."
apt install flatpak gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Step 5: Install Brave browser flatpak
echo "Installing Brave browser..."
flatpak install flathub com.brave.Browser -y
echo "Brave browser installed."

# Step 6: Install Steam
echo "Installing Steam..."
apt install steam -y
echo "Steam installed."

# Step 7: Install VS Code flatpak
echo "Installing VS Code..."
flatpak install flathub com.visualstudio.code -y
echo "VS Code installed."

echo "=== Setup complete! ==="
echo "You may need to restart your system for some changes to take effect."