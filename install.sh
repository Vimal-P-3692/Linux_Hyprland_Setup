#!/bin/bash
# --------------------------------------------
# Dank Linux Installer Script
# Usage: ./install.sh
# --------------------------------------------

set -e  # Exit on error

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# Supported distros
SUPPORTED=("arch" "manjaro" "fedora" "debian" "ubuntu" "opensuse")

# Required packages
REQUIRED_PKGS=("gcc" "cmake" "git" "curl" "perl" "wget" "gwenview")

echo -e "${CYAN}🚀 Starting Dank Linux installation...${RESET}"
echo

# Detect distro
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    distro_id=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
else
    echo -e "${RED}❌ Unable to detect your Linux distribution.${RESET}"
    exit 1
fi

# Check if distro is supported
if [[ ! " ${SUPPORTED[*]} " =~ " ${distro_id} " ]]; then
    echo -e "${RED}❌ Unsupported distribution: ${distro_id}${RESET}"
    echo -e "${YELLOW}Supported distros: ${SUPPORTED[*]}${RESET}"
    exit 1
fi

echo -e "${GREEN}✅ Detected supported distro: ${distro_id}${RESET}"
echo

# Function to install missing packages
install_missing_packages() {
    echo -e "${CYAN}🔍 Checking required packages...${RESET}"

    MISSING=()

    for pkg in "${REQUIRED_PKGS[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            MISSING+=("$pkg")
        fi
    done

    if [ ${#MISSING[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All required packages are installed.${RESET}"
    else
        echo -e "${YELLOW}⚠️ Missing packages: ${MISSING[*]}${RESET}"

        read -p "Do you want to install them now? (y/N): " confirm
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            case "$distro_id" in
                arch|manjaro)
                    sudo pacman -S --needed "${MISSING[@]}"
                    ;;
                fedora)
                    sudo dnf install -y "${MISSING[@]}"
                    ;;
                debian|ubuntu)
                    sudo apt install -y "${MISSING[@]}"
                    ;;
                opensuse*)
                    sudo zypper install -y "${MISSING[@]}"
                    ;;
                *)
                    echo -e "${RED}❌ Unsupported distro package manager.${RESET}"
                    exit 1
                    ;;
            esac
        else
            echo -e "${RED}Installation aborted — required packages missing.${RESET}"
            exit 1
        fi
    fi
}

install_missing_packages

# Confirm before running the installer
read -p "Proceed with Dank Linux installation? (y/N): " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
    echo -e "${YELLOW}Installation cancelled.${RESET}"
    exit 1
fi

# Run the official installer
echo
echo -e "${CYAN}⬇️ Running official Dank Linux installer...${RESET}"
curl -fsSL https://install.danklinux.com | sh

echo
echo -e "${GREEN}✅ Installation completed successfully!${RESET}"
echo
echo -e "${YELLOW}For more details, visit:${RESET}"
echo "👉 https://github.com/AvengeMedia/DankMaterialShell.git"

