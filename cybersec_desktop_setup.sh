#!/bin/bash

# Cybersecurity Ubuntu Desktop Setup Script
# Run with: sudo ./cybersec_desktop_setup.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}This script must be run as root${NC}" >&2
    exit 1
fi

# Update system first
echo -e "${YELLOW}[*] Updating system packages...${NC}"
apt update && apt upgrade -y
apt install -y software-properties-common

# Install basic utilities
echo -e "${YELLOW}[*] Installing basic utilities...${NC}"
apt install -y \
    build-essential \
    git \
    curl \
    wget \
    terminator \
    tmux \
    zsh \
    vim \
    net-tools \
    htop \
    tree \
    unzip \
    jq \
    python3-pip \
    python3-venv \
    openvpn

# System hardening
echo -e "${YELLOW}[*] Applying basic system hardening...${NC}"

# Firewall setup
apt install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw enable

# Install security tools
apt install -y \
    fail2ban \
    rkhunter \
    chkrootkit \
    lynis \
    tcpdump \
    nmap \
    wireshark \
    john \
    hydra \
    netcat \
    socat \
    iptables \
    nftables \
    auditd

# Configure auditd
echo -e "${YELLOW}[*] Configuring auditd...${NC}"
auditctl -e 1
systemctl enable auditd

# Install reverse engineering tools
echo -e "${YELLOW}[*] Installing reverse engineering tools...${NC}"
apt install -y \
    gdb \
    gdb-multiarch \
    strace \
    ltrace \
    radare2 \
    binwalk \
    foremost \
    hexedit \
    bless

# Install web security tools
echo -e "${YELLOW}[*] Installing web security tools...${NC}"
apt install -y \
    burpsuite \
    zaproxy \
    sqlmap \
    nikto \
    wpscan \
    dirb \
    gobuster

# Install forensics tools
echo -e "${YELLOW}[*] Installing forensics tools...${NC}"
apt install -y \
    autopsy \
    sleuthkit \
    volatility \
    bulk-extractor \
    scalpel \
    testdisk \
    foremost

# Add Kali Linux tools (selective)
echo -e "${YELLOW}[*] Adding Kali Linux repositories (selective tools)...${NC}"
apt install -y gnupg
echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" > /etc/apt/sources.list.d/kali.list
wget -q -O - https://archive.kali.org/archive-key.asc | apt-key add
apt update

# Install selected Kali tools
apt install -y \
    metasploit-framework \
    exploitdb \
    seclists \
    wordlists \
    responder \
    bloodhound \
    crackmapexec \
    impacket-scripts

# Install Python security tools
echo -e "${YELLOW}[*] Installing Python security tools...${NC}"
pip3 install \
    pwntools \
    scapy \
    impacket \
    requests \
    bs4 \
    lxml \
    pycryptodome \
    flask \
    pyftpdlib \
    ropper \
    angr

# Install virtualization tools
echo -e "${YELLOW}[*] Installing virtualization tools...${NC}"
apt install -y \
    virtualbox \
    virtualbox-ext-pack \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virt-manager

# Install Docker for containerized labs
echo -e "${YELLOW}[*] Installing Docker...${NC}"
apt install -y docker.io docker-compose
systemctl enable docker
usermod -aG docker $SUDO_USER

# Download useful security tools
echo -e "${YELLOW}[*] Downloading additional security tools...${NC}"
mkdir -p /opt/security-tools

# Ghidra
wget -qO /tmp/ghidra.zip https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.3.1_build/ghidra_10.3.1_PUBLIC_20230614.zip
unzip /tmp/ghidra.zip -d /opt
ln -s /opt/ghidra_*/ghidraRun /usr/local/bin/ghidra

# Cutter (Radare2 GUI)
wget -qO /tmp/cutter.AppImage https://github.com/rizinorg/cutter/releases/download/v2.1.2/Cutter-v2.1.2-x64.Linux.AppImage
mv /tmp/cutter.AppImage /opt/security-tools/
chmod +x /opt/security-tools/cutter.AppImage

# Create desktop shortcuts
echo -e "${YELLOW}[*] Creating desktop shortcuts...${NC}"
cat > /home/$SUDO_USER/Desktop/Terminal.desktop <<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Terminal
Comment=System terminal
Exec=terminator
Icon=utilities-terminal
Terminal=false
Categories=System;Utility;
EOL

chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/Desktop/Terminal.desktop

# Configure zsh as default shell
echo -e "${YELLOW}[*] Configuring ZSH...${NC}"
chsh -s $(which zsh) $SUDO_USER
sudo -u $SUDO_USER sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Add useful aliases
echo -e "${YELLOW}[*] Adding useful aliases...${NC}"
cat >> /home/$SUDO_USER/.zshrc <<EOL

# Security aliases
alias scan='sudo nmap -sV -T4'
alias http-serve='python3 -m http.server 8000'
alias vuln-scan='sudo lynis audit system'
alias myip='curl ifconfig.me'
alias ports='sudo netstat -tulnp'
alias update-sec='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
EOL

# Final cleanup
echo -e "${YELLOW}[*] Cleaning up...${NC}"
apt autoremove -y

echo -e "${GREEN}[+] Cybersecurity Ubuntu Desktop setup complete!${NC}"
echo -e "${YELLOW}[!] Please reboot your system for all changes to take effect.${NC}"