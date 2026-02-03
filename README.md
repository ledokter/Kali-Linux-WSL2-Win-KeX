# 🐉 Kali Linux WSL2 + Win-KeX Installation Guide

[![Platform](https://img.shields.io/badge/Platform-Windows%2011%2F10-blue.svg)](https://www.microsoft.com/windows)
[![WSL](https://img.shields.io/badge/WSL-2.0-green.svg)](https://docs.microsoft.com/windows/wsl/)
[![Kali](https://img.shields.io/badge/Kali-Linux-557C94.svg)](https://www.kali.org/)

Guide complet d'installation et de configuration de **Win-KeX** pour exécuter Kali Linux avec une interface graphique complète sous WSL2.

Win-KeX permet d'utiliser Kali Linux en mode **bureau complet** ou **application par application** directement depuis Windows.

![Kali Linux KeX](https://www.kali.org/docs/wsl/win-kex/win-kex-esm.png)

## 🎯 Fonctionnalités

### Modes d'Affichage

- **Enhanced Session Mode (ESM)** 🖥️
  - Bureau Kali complet via RDP
  - Support audio intégré
  - Meilleure intégration Windows
  - **Recommandé pour usage quotidien**

- **Window Mode** 🪟
  - Session VNC dans une fenêtre dédiée
  - Léger et rapide
  - Compatible tous les systèmes

- **Seamless Mode** 🔄
  - Applications Kali mélangées au bureau Windows
  - Transparence totale
  - Nécessite VcXsrv

### Avantages

- ✅ Bureau Linux complet sous Windows
- ✅ Support GPU (si compatible WSL2)
- ✅ Audio fonctionnel via PulseAudio
- ✅ Copier-coller entre Windows et Kali
- ✅ Accès au système de fichiers Windows
- ✅ Outils de pentest préinstallés

## 📋 Prérequis

### Système

- **Windows 11** ou **Windows 10** (version 2004+, build 19041+)
- **WSL2** activé
- **4 Go de RAM** minimum (8 Go recommandé)
- **20 Go d'espace disque** libre

### Vérifier WSL2

```powershell
wsl --version

🚀 Installation Automatique
Étape 1 : Installation Côté Windows
Ouvrez PowerShell en tant qu'Administrateur et exécutez :

powershell
# Télécharger et exécuter le script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ledokter/kali-wsl2-kex/main/install-windows.ps1" -OutFile "install-windows.ps1"
Set-ExecutionPolicy Bypass -Scope Process -Force
.\install-windows.ps1
Ce script installe :

Kali Linux pour WSL2 (si absent)

Chocolatey (gestionnaire de paquets)

VcXsrv X Server

Configuration du pare-feu Windows

Raccourci bureau pour lancer Kali

Étape 2 : Installation Côté Kali Linux
Ouvrez un terminal Kali (via wsl -d kali-linux) et exécutez :

bash
# Télécharger le script
wget https://raw.githubusercontent.com/ledokter/kali-wsl2-kex/main/install-kali.sh

# Rendre exécutable
chmod +x install-kali.sh

# Exécuter l'installation
./install-kali.sh
Ce script installe :

Win-KeX (XFCE, TigerVNC, XRDP)

Outils graphiques (Firefox, Terminal, etc.)

Configuration PulseAudio pour le son

Fix des sockets X11

💻 Utilisation
Lancer Kali avec Win-KeX
Méthode 1 : Mode Enhanced Session (Recommandé)
bash
# Depuis Kali WSL
kex --esm --ip -s
powershell
# Depuis PowerShell/CMD Windows
wsl -d kali-linux kex --esm --ip -s
Options :

--esm : Enhanced Session Mode (RDP)

--ip : Workaround pour Windows ARM (recommandé partout)

-s ou --sound : Activer le son

Méthode 2 : Mode Fenêtre VNC
bash
kex --win
Méthode 3 : Mode Seamless (Applications intégrées)
bash
kex --sl
⚠️ Prérequis : VcXsrv doit être lancé

Arrêter une Session
bash
kex --stop
Changer le Mot de Passe
bash
# Mot de passe ESM (utilisateur normal)
kex --esm --passwd

# Mot de passe ESM (root)
sudo kex --esm --passwd
Lancer en Mode Root
bash
sudo kex --esm --ip -s
🎮 Lanceur Graphique Windows
Utilisez le lanceur PowerShell pour un accès rapide :

powershell
.\kex-launcher.ps1
Menu :

text
╔════════════════════════════════════════════════════════════════╗
║         🐉 KALI LINUX WIN-KEX LAUNCHER                        ║
╚════════════════════════════════════════════════════════════════╝

   Enhanced Session Mode (ESM) - Mode RDP[1]
   Window Mode - Mode Fenêtre VNC[2]
   Seamless Mode - Mode Transparent[3]
   ESM Mode Root - Session Administrateur[4]
   Arrêter la session Win-KeX[5]
   Terminal Kali (sans GUI)[6]
  [Q] Quitter
⚙️ Configuration Avancée
Démarrage Automatique de VcXsrv
Créez un raccourci dans :

text
C:\Users\VotreNom\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
Cible :

text
"C:\Program Files\VcXsrv\vcxsrv.exe" :0 -ac -terminate -lesspointer -multiwindow -clipboard -wgl
Configuration Réseau WSL2
Éditez C:\Users\VotreNom\.wslconfig :

text
[wsl2]
memory=8GB
processors=4
swap=2GB
localhostForwarding=true
Redémarrez WSL :

powershell
wsl --shutdown
Variables d'Environnement Kali
Ajoutez dans ~/.bashrc :

bash
# Display pour X11
export DISPLAY=$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0.0

# PulseAudio pour le son
export PULSE_SERVER=tcp:$(grep nameserver /etc/resolv.conf | awk '{print $2}')

# Langue
export LANG=en_US.UTF-8
🐛 Dépannage
Problème : "Cannot connect to RDP"
Solution :

bash
# Arrêter toutes les sessions
kex --stop

# Redémarrer WSL
powershell
wsl --shutdown
wsl -d kali-linux
Problème : Écran noir après connexion ESM
Solution :

bash
# Fix des sockets X11
sudo rm -rf /tmp/.X11-unix
sudo mkdir -p /tmp/.X11-unix
sudo chmod 1777 /tmp/.X11-unix

# Relancer
kex --esm --ip -s
Problème : Pas de son
Solution :

bash
# Vérifier PulseAudio
pulseaudio --check
pulseaudio --start

# Tester
paplay /usr/share/sounds/alsa/Front_Center.wav
Problème : VcXsrv bloqué par le pare-feu
Solution Windows (PowerShell Admin) :

powershell
New-NetFirewallRule -DisplayName "VcXsrv" -Direction Inbound -Program "C:\Program Files\VcXsrv\vcxsrv.exe" -Action Allow
Problème : Session lente / Lag
Solutions :

Réduire la résolution dans RDP

Désactiver les effets visuels XFCE

Augmenter la RAM WSL2 (.wslconfig)

Problème : "kex: command not found"
Solution :

bash
# Réinstaller Win-KeX
sudo apt update
sudo apt install --reinstall kali-win-kex
📚 Commandes de Référence
Gestion des Sessions
bash
# Démarrer ESM avec son
kex --esm --ip -s

# Démarrer mode fenêtre
kex --win

# Démarrer mode seamless
kex --sl

# Mode root ESM
sudo kex --esm --ip -s

# Arrêter toutes les sessions
kex --stop

# Tuer les processus
kex --kill

# Voir le statut
kex --status
Gestion WSL2 (Windows)
powershell
# Lister les distributions
wsl --list --verbose

# Démarrer Kali
wsl -d kali-linux

# Arrêter Kali
wsl --terminate kali-linux

# Redémarrer WSL2
wsl --shutdown

# Exporter Kali
wsl --export kali-linux C:\kali-backup.tar

# Importer Kali
wsl --import kali-linux C:\WSL\kali C:\kali-backup.tar
🔐 Sécurité
Bonnes Pratiques
✅ Changez le mot de passe par défaut

✅ Activez le pare-feu dans Kali : sudo ufw enable

✅ Mettez à jour régulièrement : sudo apt update && sudo apt upgrade

✅ N'exposez pas Win-KeX sur le réseau externe

✅ Utilisez des mots de passe forts pour RDP/VNC

Mise à Jour de Kali
bash
# Mise à jour complète
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y

# Mise à jour Win-KeX
sudo apt install --reinstall kali-win-kex
📖 Ressources
Documentation Officielle
Win-KeX Documentation

Kali Linux WSL

Microsoft WSL Docs

Modes Win-KeX
Enhanced Session Mode

Window Mode

Seamless Mode

Communauté
Kali Forums

Offensive Security Discord

/r/Kalilinux

🤝 Contribution
Les contributions sont bienvenues !

Fork ce dépôt

Créez une branche : git checkout -b feature/amelioration

Committez : git commit -m "Amélioration X"

Push : git push origin feature/amelioration

Ouvrez une Pull Request

📝 Changelog
v1.0 (2026-02-03)
🎉 Version initiale

✨ Scripts d'installation automatisés

✨ Lanceur graphique PowerShell

✨ Documentation complète

✨ Support ESM, Window, et Seamless modes

⚖️ Licence
MIT License - Voir LICENSE

🙏 Crédits
Kali Linux Team - kali.org

Offensive Security - Développeurs Win-KeX

ledokter - Scripts et documentation

⭐ Si ce guide vous aide, donnez une étoile au projet !
