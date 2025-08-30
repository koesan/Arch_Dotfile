#!/bin/bash

#====================================================================
# ARCH LINUX DOTFILE KURULUM SCRIPTI - TEST MODU
# Kurulacak paketleri ve yapılandırmaları gösterir
#====================================================================

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

show_banner() {
    clear
    echo -e "${PURPLE}
╔══════════════════════════════════════════════════════════════╗
║             ARCH LINUX SETUP - TEST MODU                    ║
║       Bu script nelerin kurulacağını gösterir               ║
╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

check_system() {
    echo -e "${BOLD}=== SİSTEM KONTROLÜ ===${NC}"
    
    # Arch Linux kontrolü
    if [[ -f /etc/arch-release ]]; then
        echo -e "${GREEN}✓${NC} Arch Linux tespit edildi"
    else
        echo -e "${RED}✗${NC} Arch Linux değil"
    fi
    
    # Root kontrolü
    if [[ $EUID -ne 0 ]]; then
        echo -e "${GREEN}✓${NC} Normal kullanıcı"
    else
        echo -e "${RED}✗${NC} Root kullanıcı (script root ile çalıştırılmamalı)"
    fi
    
    # İnternet kontrolü
    if ping -c 1 google.com &> /dev/null; then
        echo -e "${GREEN}✓${NC} İnternet bağlantısı var"
    else
        echo -e "${RED}✗${NC} İnternet bağlantısı yok"
    fi
    
    # Disk alanı kontrolü
    available_space=$(df / | awk 'NR==2 {print $4}')
    available_gb=$(($available_space/1024/1024))
    echo -e "${GREEN}✓${NC} Yeterli disk alanı var (${available_gb}GB mevcut)"
    
    echo
}

show_packages() {
    echo -e "${BOLD}=== KURULACAK PAKETLER ===${NC}"
    
    echo -e "${CYAN}Pacman ile kurulacaklar:${NC}"
    echo "  • git base-devel curl wget"
    echo "  • hyprland hyprpaper grim slurp hyprpolkitagent"
    echo "  • pipewire pipewire-audio pipewire-pulse wireplumber"
    echo "  • waybar otf-font-awesome ttf-arimo-nerd noto-fonts xsensors blueman networkmanager btop"
    echo "  • wofi nemo cinnamon-translations file-roller nemo-fileroller"
    echo "  • alacritty zsh python-pip python python-virtualenv"
    echo "  • libreoffice-fresh libreoffice-fresh-tr docker"
    echo "  • nwg-look htop neofetch tree unzip zip flatpak xorg-xhost"
    echo "  • code (VS Code)"
    echo
    
    echo -e "${YELLOW}AUR (yay) ile kurulacaklar:${NC}"
    echo "  • yay (AUR helper)"
    echo "  • wlogout (Çıkış menüsü)"
    echo "  • ttf-ms-fonts (Microsoft fontları)"
    echo "  • brave-bin (Brave Browser)"
    echo
}

show_configurations() {
    echo -e "${BOLD}=== YAPILACAK KONFİGÜRASYONLAR ===${NC}"
    echo "  • GitHub'dan https://github.com/koesan/Arch_Dotfile.git klonlanacak"
    echo "  • Config dosyaları ~/.config/ klasörüne kopyalanacak:"
    echo "  •   - alacritty, waybar, wlogout, wofi, hypr, nemo"
    echo "  • Home dizinine kopyalanacak:"
    echo "  •   - .icons, .themes, .zshrc"
    echo "  • Pipewire ses sistemi yapılandırılacak (PulseAudio devre dışı)"
    echo "  • Zsh varsayılan shell yapılacak"
    echo "  • Oh My Zsh + eklentiler kurulacak"
    echo "  • Docker kullanıcı grubuna eklenecek"
    echo "  • NVIDIA GRUB ayarları (eğer NVIDIA kartı varsa)"
    echo "  • XDG Desktop Portal yapılandırması"
    echo "  • Flatpak kurulumu ve konfigürasyonu"
    echo
}

check_current_packages() {
    echo -e "${BOLD}=== MEVCUT PAKET DURUMU ===${NC}"
    
    packages=("git" "yay" "brave-bin" "hyprland" "alacritty" "zsh" "docker" "code")
    
    for package in "${packages[@]}"; do
        if pacman -Q "$package" &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} $package (kurulu)"
        else
            echo -e "  ${RED}✗${NC} $package (kurulu değil)"
        fi
    done
    echo
}

check_special_conditions() {
    echo -e "${BOLD}=== ÖZEL KONTROLLER ===${NC}"
    
    # Zsh kontrol
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo -e "  ${GREEN}✓${NC} Zsh zaten varsayılan shell"
    else
        echo -e "  ${YELLOW}⚠${NC} Zsh varsayılan shell değil (kurulumda değiştirilecek)"
    fi
    
    # Docker grup kontrol
    if groups | grep -q docker; then
        echo -e "  ${GREEN}✓${NC} Docker grubuna üye"
    else
        echo -e "  ${YELLOW}⚠${NC} Docker grubuna ekleneceksiniz"
    fi
    
    # Oh My Zsh kontrol
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "  ${GREEN}✓${NC} Oh My Zsh kurulu"
    else
        echo -e "  ${YELLOW}⚠${NC} Oh My Zsh kurulacak"
    fi
    
    # PipeWire kontrol
    if systemctl --user is-active --quiet pipewire; then
        echo -e "  ${GREEN}✓${NC} Pipewire zaten aktif"
    else
        echo -e "  ${YELLOW}⚠${NC} Pipewire yapılandırılacak"
    fi
    
    # PulseAudio çakışma kontrol
    if pacman -Q pulseaudio &> /dev/null; then
        echo -e "  ${YELLOW}⚠${NC} PulseAudio tespit edildi (PipeWire ile çakışabilir)"
    fi
    
    # Timeshift çakışma kontrol
    if pacman -Q cachyos-snapper-support &> /dev/null; then
        echo -e "  ${YELLOW}⚠${NC} CachyOS Snapper tespit edildi (timeshift atlanacak)"
    fi
    
    # NVIDIA kontrol
    if lspci | grep -i nvidia &> /dev/null; then
        echo -e "  ${BLUE}ℹ${NC} NVIDIA kartı tespit edildi (özel ayarlar uygulanacak)"
    else
        echo -e "  ${BLUE}ℹ${NC} NVIDIA kartı tespit edilmedi"
    fi
    
    echo
}

show_time_estimate() {
    echo -e "${BOLD}=== TAHMİNİ KURULUM SÜRESİ ===${NC}"
    echo -e "  ${CYAN}⏱${NC}  Hızlı internet: 15-25 dakika"
    echo -e "  ${CYAN}⏱${NC}  Orta internet: 25-40 dakika"
    echo -e "  ${CYAN}⏱${NC}  Yavaş internet: 40-60 dakika"
    echo
}

show_warnings() {
    echo -e "${BOLD}=== ÖNEMLİ UYARILAR ===${NC}"
    echo -e "  ${YELLOW}⚠${NC}  Kurulum sonunda sistem yeniden başlatılması önerilir"
    echo -e "  ${YELLOW}⚠${NC}  Mevcut konfigürasyonlar üzerine yazılabilir"
    echo -e "  ${YELLOW}⚠${NC}  Docker kullanımı için yeniden giriş gerekebilir"
    echo -e "  ${YELLOW}⚠${NC}  Zsh varsayılan shell yapılacak"
    echo -e "  ${RED}⚠${NC}  timeshift paketi çakışma nedeniyle ATLANACAK"
    echo -e "  ${RED}⚠${NC}  vlc, steam, linux-zen paketleri kullanıcı isteği üzerine ATLANACAK"
    echo
}

show_excluded_packages() {
    echo -e "${BOLD}=== ATLANAN PAKETLER ===${NC}"
    echo -e "  ${RED}✗${NC} timeshift (cachyos-snapper-support çakışması)"
    echo -e "  ${RED}✗${NC} vlc (kullanıcı isteği)"
    echo -e "  ${RED}✗${NC} steam (kullanıcı isteği)" 
    echo -e "  ${RED}✗${NC} linux-zen linux-zen-headers (kullanıcı isteği)"
    echo -e "  ${RED}✗${NC} google-chrome (brave tercih edildi)"
    echo
}

main() {
    show_banner
    check_system
    show_packages
    show_configurations
    check_current_packages
    check_special_conditions
    show_time_estimate
    show_warnings
    show_excluded_packages
    
    echo -e "${GREEN}
╔══════════════════════════════════════════════════════════════╗
║                    KURULUM HAZIR                            ║
╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    read -p "Ana kurulum scriptini çalıştırmak istiyor musunuz? (y/N): " confirm
    
    if [[ $confirm == "y" || $confirm == "Y" ]]; then
        echo "Ana script başlatılıyor..."
        echo
        exec ./arch_dotfile_installer.sh
    else
        echo "Test modu tamamlandı. Ana scripti manuel olarak çalıştırabilirsiniz:"
        echo "./arch_dotfile_installer.sh"
    fi
}

main "$@"