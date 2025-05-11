#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo privileges."
  exit 1
fi

# Define color codes for better readability
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo -e "${GREEN}=== Starting Ubuntu Setup Script ===${NC}"

# Define the steps available
declare -A steps=(
  [1]="Initial setup (Update packages, Install nala, Source .bashrc)"
  [2]="Update and upgrade with nala"
  [3]="Install flatpak"
  [4]="Install Brave browser"
  [5]="Install Steam"
  [6]="Install Heroic Games Launcher"
  [7]="Install VS Code"
)

# Function to display the TUI selection menu
display_menu() {
  clear
  echo -e "${CYAN}=== Ubuntu Setup Script - Step Selection ===${NC}"
  echo -e "${YELLOW}Select the steps you want to execute:${NC}"
  echo ""
  
  for i in "${!steps[@]}"; do
    if [ "${selected[$i]}" = true ]; then
      echo -e "  ${GREEN}[X]${NC} $i. ${steps[$i]}"
    else
      echo -e "  [ ] $i. ${steps[$i]}"
    fi
  done
  
  echo ""
  echo -e "${YELLOW}Controls:${NC}"
  echo "  - Enter the number to toggle selection"
  echo "  - Type 'a' to select all steps"
  echo "  - Type 'n' to deselect all steps"
  echo "  - Type 'r' to run selected steps"
  echo "  - Type 'q' to quit without running"
  echo ""
  echo -n "Enter your choice: "
}

# Initialize selected steps array
declare -A selected
for i in "${!steps[@]}"; do
  selected[$i]=false
done

# TUI logic
while true; do
  display_menu
  read -r choice
  
  case $choice in
    [1-7])
      if [ -n "${steps[$choice]}" ]; then
        if [ "${selected[$choice]}" = true ]; then
          selected[$choice]=false
        else
          selected[$choice]=true
        fi
      fi
      ;;
    a)
      for i in "${!steps[@]}"; do
        selected[$i]=true
      done
      ;;
    n)
      for i in "${!steps[@]}"; do
        selected[$i]=false
      done
      ;;
    r)
      break
      ;;
    q)
      echo -e "${YELLOW}Exiting script. No changes were made.${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option. Press any key to continue...${NC}"
      read -n 1
      ;;
  esac
done

# Clear screen before starting the installations
clear
echo -e "${GREEN}=== Starting Selected Installations ===${NC}"

# Step 1: Combined initial setup (Update packages, Install nala, Source .bashrc)
if [ "${selected[1]}" = true ]; then
    echo -e "${CYAN}Performing initial setup...${NC}"
    
    # Update system packages
    echo -e "${CYAN}Updating system packages...${NC}"
    apt update
    echo -e "${GREEN}System packages updated.${NC}"
    
    # Install nala
    echo -e "${CYAN}Installing nala...${NC}"
    apt-get install nala -y
    echo -e "${GREEN}Nala installed.${NC}"
    
    # Source .bashrc
    echo -e "${CYAN}Sourcing .bashrc...${NC}"
    if [ -f "/home/$SUDO_USER/.bashrc" ]; then
        source "/home/$SUDO_USER/.bashrc"
        echo -e "${GREEN}.bashrc sourced.${NC}"
    else
        echo -e "${RED}.bashrc not found.${NC}"
    fi
    
    echo -e "${GREEN}Initial setup completed.${NC}"
fi

# Step 2: Update and upgrade using nala (only if nala was installed)
if [ "${selected[2]}" = true ]; then
    if command -v nala &> /dev/null; then
        echo -e "${CYAN}Updating and upgrading packages with nala...${NC}"
        nala update && nala full-upgrade -y
        echo -e "${GREEN}System fully upgraded with nala.${NC}"
    else
        echo -e "${RED}Nala not found, skipping nala-based update and upgrade.${NC}"
    fi
fi

# Step 3: Install flatpak if not already installed
if [ "${selected[3]}" = true ]; then
    echo -e "${CYAN}Setting up flatpak...${NC}"
    apt install flatpak gnome-software-plugin-flatpak -y
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo -e "${GREEN}Flatpak setup complete.${NC}"
fi

# Step 4: Install Brave browser flatpak
if [ "${selected[4]}" = true ]; then
    if command -v flatpak &> /dev/null; then
        echo -e "${CYAN}Installing Brave browser...${NC}"
        flatpak install flathub com.brave.Browser -y
        echo -e "${GREEN}Brave browser installed.${NC}"
    else
        echo -e "${RED}Flatpak not found, skipping Brave browser installation.${NC}"
    fi
fi

# Step 5: Install Steam
if [ "${selected[5]}" = true ]; then
    echo -e "${CYAN}Installing Steam...${NC}"
    apt install steam -y
    echo -e "${GREEN}Steam installed.${NC}"
fi

# Step 6: Install Heroic Games Launcher flatpak
if [ "${selected[6]}" = true ]; then
    if command -v flatpak &> /dev/null; then
        echo -e "${CYAN}Installing Heroic Games Launcher...${NC}"
        flatpak install flathub com.heroicgameslauncher.hgl -y
        echo -e "${GREEN}Heroic Games Launcher installed.${NC}"
    else
        echo -e "${RED}Flatpak not found, skipping Heroic Games Launcher installation.${NC}"
    fi
fi

# Step 7: Install VS Code flatpak
if [ "${selected[7]}" = true ]; then
    if command -v flatpak &> /dev/null; then
        echo -e "${CYAN}Installing VS Code...${NC}"
        flatpak install flathub com.visualstudio.code -y
        echo -e "${GREEN}VS Code installed.${NC}"
    else
        echo -e "${RED}Flatpak not found, skipping VS Code installation.${NC}"
    fi
fi

echo -e "${GREEN}=== Setup complete! ===${NC}"
echo "You may need to restart your system for some changes to take effect."