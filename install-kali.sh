#!/bin/bash

###############################################################################
# Script d'installation Win-KeX pour Kali Linux WSL2
# Installe Win-KeX avec support GUI complet (VNC, RDP, X11)
###############################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header "INSTALLATION WIN-KEX POUR KALI LINUX WSL2"

# Vérifier si on est sous WSL2
if ! grep -qi microsoft /proc/version; then
    print_error "Ce script doit être exécuté dans WSL2"
    exit 1
fi

print_success "Environnement WSL2 détecté"

# Mise à jour du système
print_header "Mise à jour du système"
sudo apt update
sudo apt upgrade -y

# Installation de Win-KeX
print_header "Installation de Win-KeX"
echo -e "${YELLOW}Cela inclut : XFCE Desktop, TigerVNC, XRDP, et les scripts kex${NC}"
sudo apt install -y kali-win-kex

print_success "Win-KeX installé avec succès"

# Fix X11 socket (problème connu WSL2)
print_header "Configuration des sockets X11"
sudo rm -rf /tmp/.X11-unix
sudo mkdir -p /tmp/.X11-unix
sudo chmod 1777 /tmp/.X11-unix

print_success "Sockets X11 configurés"

# Installation d'outils supplémentaires
print_header "Installation d'outils supplémentaires"
sudo apt install -y \
    dbus-x11 \
    xfce4-terminal \
    firefox-esr \
    pulseaudio \
    pavucontrol

print_success "Outils supplémentaires installés"

# Configuration du son
print_header "Configuration PulseAudio"
if ! grep -q "exit 0" ~/.bashrc; then
    echo "" >> ~/.bashrc
fi

cat >> ~/.bashrc << 'EOF'

# Configuration PulseAudio pour WSL2
export PULSE_SERVER=tcp:$(grep nameserver /etc/resolv.conf | awk '{print $2}')
EOF

source ~/.bashrc

print_success "PulseAudio configuré"

# Configuration des locales
print_header "Configuration des locales"
sudo apt install -y locales
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

# Message de fin
print_header "INSTALLATION TERMINÉE"
echo ""
print_success "Win-KeX est maintenant installé !"
echo ""
echo -e "${BLUE}Commandes disponibles :${NC}"
echo ""
echo -e "  ${GREEN}kex --esm --ip -s${NC}          # Mode Enhanced Session (Recommandé)"
echo -e "  ${GREEN}kex --win${NC}                  # Mode fenêtre VNC"
echo -e "  ${GREEN}kex --sl${NC}                   # Mode Seamless (nécessite VcXsrv)"
echo -e "  ${GREEN}kex --stop${NC}                 # Arrêter la session"
echo ""
echo -e "${YELLOW}Note : Lors du premier lancement, vous devrez définir un mot de passe RDP/VNC${NC}"
echo ""
echo -e "${BLUE}Documentation complète : https://www.kali.org/docs/wsl/win-kex/${NC}"
echo ""
