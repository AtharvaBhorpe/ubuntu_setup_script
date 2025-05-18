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
  [8]="Install Pixi package manager"
  [9]="Install OpenRazer and Polychromatic drivers"
  [10]="Install Rust using rustup"
  [11]="Install VNC Server from local .deb"
  [12]="Install Zoom Meeting from local .deb"
  [13]="Set custom (Gruvbox) wallpaper"
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
    [1-9]|10|11|12|13)
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

# Step 8: Install Pixi package manager
if [ "${selected[8]}" = true ]; then
    echo -e "${CYAN}Installing Pixi package manager...${NC}"
    curl -fsSL https://pixi.sh/install.sh | bash
    echo -e "${GREEN}Pixi package manager installed.${NC}"
    
    # Add Pixi to PATH for the current session
    echo -e "${CYAN}Adding Pixi to PATH...${NC}"
    if [ -f "/home/$SUDO_USER/.pixi/bin/pixi" ]; then
        # Create a symlink in /usr/local/bin to make pixi available system-wide
        ln -sf "/home/$SUDO_USER/.pixi/bin/pixi" /usr/local/bin/pixi
        echo -e "${GREEN}Pixi added to PATH.${NC}"
    else
        echo -e "${RED}Pixi installation path not found.${NC}"
    fi
    
    # Verify installation
    if command -v pixi &> /dev/null; then
        echo -e "${GREEN}Pixi installation verified. Version: $(pixi --version)${NC}"
    else
        echo -e "${YELLOW}Pixi installed but not available in PATH. You may need to restart your shell.${NC}"
    fi
fi

# Step 9: Install OpenRazer and Polychromatic drivers
if [ "${selected[9]}" = true ]; then
    echo -e "${CYAN}Installing OpenRazer and Polychromatic drivers...${NC}"
    
    # Add repositories
    echo -e "${CYAN}Adding OpenRazer and Polychromatic repositories...${NC}"
    add-apt-repository ppa:openrazer/stable -y
    add-apt-repository ppa:polychromatic/stable -y
    apt update
    
    # Install packages
    echo -e "${CYAN}Installing OpenRazer and Polychromatic packages...${NC}"
    apt install openrazer-meta polychromatic -y
    
    # Add user to plugdev group
    echo -e "${CYAN}Adding user to plugdev group...${NC}"
    gpasswd -a $SUDO_USER plugdev
    
    echo -e "${GREEN}OpenRazer and Polychromatic drivers installed.${NC}"
    echo -e "${YELLOW}NOTE: You may need to reboot your system for the Razer drivers to work properly.${NC}"
fi

# Step 10: Install Rust using rustup
if [ "${selected[10]}" = true ]; then
    echo -e "${CYAN}Installing Rust using rustup...${NC}"
    
    # Install dependencies
    echo -e "${CYAN}Installing dependencies...${NC}"
    apt install curl build-essential gcc make -y
    
    # Download and run rustup installer as the non-root user
    echo -e "${CYAN}Running rustup installer...${NC}"
    # We need to run this as the actual user, not as root
    if [ -n "$SUDO_USER" ]; then
        su - $SUDO_USER -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
        
        # Source the cargo environment for the current session for verification
        if [ -f "/home/$SUDO_USER/.cargo/env" ]; then
            echo -e "${CYAN}Sourcing Cargo environment...${NC}"
            # This doesn't affect the root user, but we do it for completeness
            source "/home/$SUDO_USER/.cargo/env"
        fi
        
        # Add Rust to the user's shell configuration if not already there
        if ! grep -q "source ~/.cargo/env" "/home/$SUDO_USER/.bashrc"; then
            echo -e "${CYAN}Adding Rust to user's .bashrc...${NC}"
            echo 'source ~/.cargo/env' >> "/home/$SUDO_USER/.bashrc"
        fi
        
        echo -e "${GREEN}Rust installed for user $SUDO_USER.${NC}"
        echo -e "${YELLOW}NOTE: You may need to open a new terminal or run 'source ~/.cargo/env' to use Rust tools.${NC}"
    else
        echo -e "${RED}Unable to determine the actual user. Rust should be installed by a regular user, not root.${NC}"
        echo -e "${YELLOW}Please run 'curl --proto \"=https\" --tlsv1.2 -sSf https://sh.rustup.rs | sh' manually after this script completes.${NC}"
    fi
fi

# Step 11: Install VNC Server from local .deb
if [ "${selected[11]}" = true ]; then
    echo -e "${CYAN}Installing VNC Server from local .deb file...${NC}"
    
    # Check if the .deb file exists
    VNC_DEB="VNC-Server-7.13.1-Linux-x64.deb"
    
    if [ -f "$VNC_DEB" ]; then
        # Install dependencies for .deb installation
        echo -e "${CYAN}Installing dependencies for .deb installation...${NC}"
        apt install gdebi-core -y
        
        # Install the .deb package
        echo -e "${CYAN}Installing VNC Server using gdebi...${NC}"
        gdebi --non-interactive "$VNC_DEB"
        
        echo -e "${GREEN}VNC Server installed successfully.${NC}"
    else
        echo -e "${RED}VNC Server .deb file not found in the current directory.${NC}"
        echo -e "${YELLOW}Expected file: $VNC_DEB${NC}"
    fi
fi

# Step 12: Install Zoom Meeting from local .deb
if [ "${selected[12]}" = true ]; then
    echo -e "${CYAN}Installing Zoom Meeting from local .deb file...${NC}"
    
    # Check if the .deb file exists
    ZOOM_DEB="zoom_amd64.deb"
    
    if [ -f "$ZOOM_DEB" ]; then
        # Install dependencies for .deb installation
        echo -e "${CYAN}Installing dependencies for .deb installation...${NC}"
        apt install gdebi-core -y
        
        # Install the .deb package
        echo -e "${CYAN}Installing Zoom Meeting using gdebi...${NC}"
        gdebi --non-interactive "$ZOOM_DEB"
        
        echo -e "${GREEN}Zoom Meeting installed successfully.${NC}"
    else
        echo -e "${RED}Zoom Meeting .deb file not found in the current directory.${NC}"
        echo -e "${YELLOW}Expected file: $ZOOM_DEB${NC}"
    fi
fi

# Step 13: Set custom wallpaper
if [ "${selected[13]}" = true ]; then
    echo -e "${CYAN}Setting custom wallpaper...${NC}"
    
    # Define wallpaper file name
    WALLPAPER_FILE="ALLqk82.png"
    
    # Check if the file exists
    if [ -f "$WALLPAPER_FILE" ]; then
        # Get the absolute path to the wallpaper
        WALLPAPER_PATH="$(readlink -f "$WALLPAPER_FILE")"
        
        # Make sure gsettings is installed
        apt install gsettings-desktop-schemas -y
        
        # Install dconf-cli which might be needed for gsettings
        apt install dconf-cli -y
        
        if [ -n "$SUDO_USER" ]; then
            # Set the wallpaper for GNOME desktop
            echo -e "${CYAN}Setting wallpaper as $WALLPAPER_PATH...${NC}"
            
            # Need to set DBUS_SESSION_BUS_ADDRESS for gsettings to work properly
            su - $SUDO_USER -c "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $SUDO_USER)/bus gsettings set org.gnome.desktop.background picture-uri file://$WALLPAPER_PATH"
            su - $SUDO_USER -c "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $SUDO_USER)/bus gsettings set org.gnome.desktop.background picture-uri-dark file://$WALLPAPER_PATH"
            
            # Set picture options to 'zoom' (others: 'none', 'wallpaper', 'centered', 'scaled', 'stretched', 'spanned')
            su - $SUDO_USER -c "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $SUDO_USER)/bus gsettings set org.gnome.desktop.background picture-options 'zoom'"
            
            echo -e "${GREEN}Wallpaper set successfully.${NC}"
        else
            echo -e "${RED}Unable to determine the actual user. Cannot set wallpaper.${NC}"
            echo -e "${YELLOW}You can manually set the wallpaper by right-clicking on the desktop and selecting 'Change Background'.${NC}"
        fi
    else
        echo -e "${RED}Wallpaper image not found in the current directory.${NC}"
        echo -e "${YELLOW}Expected file: $WALLPAPER_FILE${NC}"
    fi
fi

echo -e "${GREEN}=== Setup complete! ===${NC}"
echo "You may need to restart your system for some changes to take effect."