#!/bin/bash

#############################################
# Docker Uninstall Wizard
# Debian Edition
# Powered by Alfannite
#############################################

# ===== COLORS =====
RED='\033[0;31m'
ORANGE='\033[38;5;208m'
GREEN='\033[0;32m'
BLUE='\033[38;5;117m'
GRAY='\033[38;5;250m'
NC='\033[0m'

clear

# ===== BANNER =====
echo -e "${BLUE}"

cat << "EOF"


░██     ░██            ░██                         ░██               ░██ ░██ 
░██     ░██                                        ░██               ░██ ░██ 
░██     ░██ ░████████  ░██░████████   ░███████  ░████████  ░██████   ░██ ░██ 
░██     ░██ ░██    ░██ ░██░██    ░██ ░██           ░██          ░██  ░██ ░██ 
░██     ░██ ░██    ░██ ░██░██    ░██  ░███████     ░██     ░███████  ░██ ░██ 
 ░██   ░██  ░██    ░██ ░██░██    ░██        ░██    ░██    ░██   ░██  ░██ ░██ 
  ░██████   ░██    ░██ ░██░██    ░██  ░███████      ░████  ░█████░██ ░██ ░██ 


EOF

echo -e "${GRAY}Remove Docker Engine from Debian${NC}"
echo

# ===== ROOT CHECK =====
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} Please run this script as root."
    exit 1
fi

# ===== MENU =====

echo "Choose Uninstall Mode:"
echo
echo "[1] Standard Uninstall"
echo "[2] Complete Uninstall (Remove ALL Docker Data)"
echo

read -p "Choose Option: " OPTION

echo

echo -e "${RED}WARNING${NC}"
echo
echo "This action may permanently remove:"
echo
echo "- Docker Containers"
echo "- Docker Images"
echo "- Docker Networks"
echo "- Docker Volumes"
echo "- Docker Configuration"
echo

read -p "Continue? [Y/N]: " CONFIRM

case $CONFIRM in
    [Yy]* ) ;;
    * )
        echo
        echo "Operation Cancelled."
        exit 0
        ;;
esac

# ===== PROGRESS =====

progress() {
    local percent=$1

    if [ $percent -lt 40 ]; then
        COLOR=$RED
    elif [ $percent -lt 80 ]; then
        COLOR=$ORANGE
    else
        COLOR=$GREEN
    fi

    local filled=$((percent / 5))
    local empty=$((20 - filled))

    printf "\r${COLOR}["
    printf "%0.s#" $(seq 1 $filled)
    printf "%0.s-" $(seq 1 $empty)
    printf "] %s%%${NC}" "$percent"
}

echo
echo "Starting Uninstall..."
echo

# ===== STEP 1 =====

progress 10

systemctl stop docker 2>/dev/null
systemctl stop containerd 2>/dev/null

sleep 1

# ===== STEP 2 =====

progress 25

systemctl disable docker 2>/dev/null
systemctl disable containerd 2>/dev/null

sleep 1

# ===== STEP 3 =====

progress 45

apt remove -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin

sleep 1

# ===== COMPLETE MODE =====

if [ "$OPTION" = "2" ]; then

    progress 65

    rm -rf /var/lib/docker
    rm -rf /var/lib/containerd

    sleep 1

    progress 80

    rm -f /etc/apt/sources.list.d/docker.list
    rm -f /etc/apt/keyrings/docker.gpg

fi

# ===== CLEANUP =====

progress 95

apt autoremove -y
apt autoclean -y

sleep 1

progress 100

echo
echo
echo "Verification:"
echo

if command -v docker >/dev/null 2>&1; then
    echo -e "${RED}Docker binary still exists.${NC}"
else
    echo -e "${GREEN}Docker successfully removed.${NC}"
fi

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

echo "--------------------------------------"
echo "GitHub:"
echo "https://github.com/alfannite"
echo
echo "Documentation:"
echo "https://github.com/alfannite/homelab-docs"
echo "--------------------------------------"
