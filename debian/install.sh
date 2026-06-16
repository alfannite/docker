#!/bin/bash

#############################################
# Docker Installation Wizard
# Debian Edition
# Powered by Alfannite
#############################################

# ===== COLORS =====
RED='\033[0;31m'
ORANGE='\033[38;5;208m'
GREEN='\033[0;32m'
BLUE='\033[38;5;117m'
GRAY='\033[38;5;250m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

# ===== BANNER =====
echo -e "${BLUE}"
cat << "EOF"

░███████                         ░██                           
░██   ░██                        ░██                           
░██    ░██  ░███████   ░███████  ░██    ░██ ░███████  ░██░████ 
░██    ░██ ░██    ░██ ░██    ░██ ░██   ░██ ░██    ░██ ░███     
░██    ░██ ░██    ░██ ░██        ░███████  ░█████████ ░██      
░██   ░██  ░██    ░██ ░██    ░██ ░██   ░██ ░██        ░██      
░███████    ░███████   ░███████  ░██    ░██ ░███████  ░██

---------------------------------------------------------------
   ___         ___   _____               _ __     
  / _ )__ __  / _ | / / _/__ ____  ___  (_) /____ 
 / _  / // / / __ |/ / _/ _ `/ _ \/ _ \/ / __/ -_)
/____/\_, / /_/ |_/_/_/ \_,_/_//_/_//_/_/\__/\__/ 
     /___/                                        
---------------------------------------------------------------
EOF
echo -e "${GRAY}Install Docker CE using Official Docker Repository${NC}"
echo

# ===== ROOT CHECK =====
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} Please run this script as root."
    echo
    echo "Example:"
    echo "sudo bash install.sh"
    exit 1
fi

# ===== OS DETECTION =====
if [ -f /etc/os-release ]; then
    . /etc/os-release

    DISTRO="$ID"
    VERSION="$VERSION_ID"
else
    echo -e "${RED}[ERROR]${NC} Unable to detect OS."
    exit 1
fi

if [[ "$DISTRO" != "debian" ]]; then
    echo -e "${RED}[ERROR]${NC} Unsupported Operating System."
    echo "This installer is for Debian only."
    exit 1
fi

echo -e "${GREEN}Detected OS:${NC} Debian"
echo -e "${GREEN}Version:${NC} $VERSION"
echo -e "${GREEN}Architecture:${NC} $(dpkg --print-architecture)"
echo

# ===== CONFIRMATION =====
echo "This installer will:"
echo
echo "  ✓ Install Docker CE"
echo "  ✓ Install Docker CLI"
echo "  ✓ Install Containerd"
echo "  ✓ Install Buildx"
echo "  ✓ Install Docker Compose"
echo "  ✓ Enable Docker Service"
echo

read -p "Continue Installation? [Y/N]: " CONFIRM

case $CONFIRM in
    [Yy]* ) ;;
    * )
        echo
        echo "Installation Cancelled."
        exit 0
        ;;
esac

echo
echo -e "${ORANGE}Starting Installation...${NC}"
echo

# ===== STEP 1 =====
echo "[1/6] Updating Repository..."
apt update

# ===== STEP 2 =====
echo
echo "[2/6] Installing Dependencies..."
apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# ===== STEP 3 =====
echo
echo "[3/6] Adding Docker GPG Key..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg \
| gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

# ===== STEP 4 =====
echo
echo "[4/6] Adding Docker Repository..."

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update

# ===== STEP 5 =====
echo
echo "[5/6] Installing Docker Packages..."

apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# ===== OPTIONAL USER =====
echo
read -p "Add a user to Docker group? [Y/N]: " ADDUSER

if [[ "$ADDUSER" =~ ^[Yy]$ ]]; then

    read -p "Enter username: " USERNAME

    if id "$USERNAME" &>/dev/null; then

        usermod -aG docker "$USERNAME"

        echo
        echo -e "${GREEN}User added to docker group:${NC} $USERNAME"

    else

        echo
        echo -e "${RED}User not found.${NC}"

    fi
fi

# ===== STEP 6 =====
echo
echo "[6/6] Enabling Docker Service..."

systemctl enable docker
systemctl start docker

# ===== VERIFY =====
echo
echo "=================="
echo "Verification"
echo "=================="
echo

docker --version
echo

docker compose version
echo

systemctl is-active docker
echo

# ===== SUCCESS =====
echo -e "${GREEN}"

cat << "EOF"

╔═════════════════════════════════════════════════════════════════════════════════╗
║  /$$$$$$                                                             /$$ /$$ /$$║
║ /$$__  $$                                                           | $$| $$| $$║
║| $$  \__/ /$$   /$$  /$$$$$$$  /$$$$$$$  /$$$$$$   /$$$$$$$ /$$$$$$$| $$| $$| $$║
║|  $$$$$$ | $$  | $$ /$$_____/ /$$_____/ /$$__  $$ /$$_____//$$_____/| $$| $$| $$║
║ \____  $$| $$  | $$| $$      | $$      | $$$$$$$$|  $$$$$$|  $$$$$$ |__/|__/|__/║
║ /$$  \ $$| $$  | $$| $$      | $$      | $$_____/ \____  $$\____  $$            ║
║|  $$$$$$/|  $$$$$$/|  $$$$$$$|  $$$$$$$|  $$$$$$$ /$$$$$$$//$$$$$$$/ /$$ /$$ /$$║
║\______/  \______/  \_______/ \_______/ \_______/|_______/|_______/ |__/|__/|__/ ║
╚═════════════════════════════════════════════════════════════════════════════════╝                                                            

EOF

echo -e "${NC}"

echo "Useful Commands:"
echo
echo "docker ps"
echo "docker images"
echo "docker compose version"
echo "systemctl status docker"
echo

echo "--------------------------------------"
echo "GitHub:"
echo "https://github.com/alfannite"
echo
echo "Documentation:"
echo "https://github.com/alfannite/homelab-docs"
echo "--------------------------------------"
