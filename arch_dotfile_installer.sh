#!/bin/bash

#====================================================================
# ARCH LINUX DOTFILE KURULUM SCRIPTI
# GitHub: https://github.com/koesan/Arch_Dotfile.git
# Otomatik Hyprland + Dotfile Kurulumu
#====================================================================

# Renkler ve formatlar
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Log fonksiyonu
log() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[HATA]${NC} $1"
}

success() {
    echo -e "${GREEN}[BAŞARILI]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[UYARI]${NC} $1"
}

info() {
    echo -e "${BLUE}[BİLGİ]${NC} $1"
}

# Banner
show_banner() {
    clear
    echo -e "${PURPLE}
╔══════════════════════════════════════════════════════════════╗
║               ARCH LINUX DOTFILE KURULUM SCRIPTI            ║
║                    Otomatik Kurulum v2.0                    ║
║              GitHub: koesan/Arch_Dotfile                    ║
╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Sistem kontrol fonksiyonları
check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        error "Bu script yalnızca Arch Linux ve türevleri için tasarlanmıştır!"
        exit 1
    fi
    success "Arch Linux tespit edildi"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "Bu scripti root kullanıcısı olarak çalıştırmayın!"
        exit 1
    fi
    success "Normal kullanıcı kontrolü tamam"
}

check_internet() {
    if ! ping -c 1 google.com &> /dev/null; then
        error "İnternet bağlantısı bulunamadı!"
        exit 1
    fi
    success "İnternet bağlantısı aktif"
}

check_disk_space() {
    available_space=$(df / | awk 'NR==2 {print $4}')
    required_space=5000000  # 5GB in KB
    
    if [[ $available_space -lt $required_space ]]; then
        error "Yetersiz disk alanı! En az 5GB boş alan gerekli."
        exit 1
    fi
    success "Yeterli disk alanı var ($(($available_space/1024/1024))GB mevcut)"
}

# Paket çakışma kontrolleri
check_conflicts() {
    info "Paket çakışmaları kontrol ediliyor..."
    
    # Timeshift vs cachyos-snapper-support çakışmasını kontrol et
    if pacman -Q cachyos-snapper-support &> /dev/null; then
        warning "cachyos-snapper-support tespit edildi - timeshift kurulmayacak (çakışma önlendi)"
        SKIP_TIMESHIFT=true
    else
        SKIP_TIMESHIFT=false
    fi
    
    # PulseAudio vs PipeWire çakışmasını kontrol et
    if pacman -Q pulseaudio &> /dev/null; then
        warning "PulseAudio tespit edildi - PipeWire kurulumu için kaldırılması gerekebilir"
        read -p "PulseAudio'yu kaldırıp PipeWire kurmak istiyor musunuz? (y/N): " remove_pulse
        if [[ $remove_pulse == "y" || $remove_pulse == "Y" ]]; then
            REMOVE_PULSEAUDIO=true
        else
            REMOVE_PULSEAUDIO=false
        fi
    else
        REMOVE_PULSEAUDIO=false
    fi
}

# Paket listelerini tanımla
declare -a PACMAN_PACKAGES=(
    # Temel araçlar
    "git" "base-devel" "curl" "wget"
    
    # Hyprland masaüstü ortamı
    "hyprland" "hyprpaper" "grim" "slurp" "hyprpolkitagent" 
    "xdg-desktop-portal-hyprland"
    
    # Ses sistemi (PipeWire)
    "pipewire" "pipewire-audio" "pipewire-pulse" "wireplumber"
    
    # Waybar ve sistem araçları
    "waybar" "otf-font-awesome" "ttf-arimo-nerd" "noto-fonts" 
    "xsensors" "blueman" "networkmanager" "btop"
    
    # Dosya yöneticisi ve uygulama başlatıcı
    "wofi" "nemo" "cinnamon-translations" "file-roller" "nemo-fileroller"
    
    # Terminal ve kabuk
    "alacritty" "zsh"
    
    # Python
    "python-pip" "python" "python-virtualenv"
    
    # Sistem araçları
    "nwg-look" "htop" "neofetch" "tree" "unzip" "zip" "xorg-xhost"
    
    # Flatpak
    "flatpak"
    
    # Docker
    "docker"
    
    # LibreOffice
    "libreoffice-fresh" "libreoffice-fresh-tr"
    
    # VS Code
    "code"
)

declare -a AUR_PACKAGES=(
    "wlogout"           # Çıkış menüsü
    "ttf-ms-fonts"      # Microsoft fontları
    "brave-bin"         # Brave browser
)

# Yay kurulum fonksiyonu
install_yay() {
    if command -v yay &> /dev/null; then
        success "Yay zaten kurulu"
        return 0
    fi
    
    log "Yay (AUR helper) kuruluyor..."
    
    # Geçici dizin oluştur
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Yay'ı indir ve kur
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    
    # Temizlik
    cd /
    rm -rf "$temp_dir"
    
    if command -v yay &> /dev/null; then
        success "Yay başarıyla kuruldu"
    else
        error "Yay kurulumu başarısız!"
        exit 1
    fi
}

# Sudo şifresini al ve cache'le
get_sudo_access() {
    log "Kurulum için yönetici yetkisi gerekli"
    warning "Sudo şifresi sadece bir kere istenecek ve 30 dakika boyunca geçerli olacak"
    
    # Sudo timeout'u artır
    sudo -v
    if [[ $? -ne 0 ]]; then
        error "Yönetici yetkisi alınamadı!"
        exit 1
    fi
    
    # Sudo timeout'u artır (30 dakika)
    sudo bash -c 'echo "Defaults timestamp_timeout=30" >> /etc/sudoers.d/temp_installer'
    
    success "Yönetici yetkisi alındı (30 dakika geçerli)"
}

# Sistem güncelleme
update_system() {
    log "Sistem güncelleniyor..."
    
    sudo pacman -Syu --noconfirm
    
    if [[ $? -eq 0 ]]; then
        success "Sistem güncelleme tamamlandı"
    else
        error "Sistem güncelleme başarısız!"
        exit 1
    fi
}

# PulseAudio kaldırma
remove_pulseaudio() {
    if [[ $REMOVE_PULSEAUDIO == true ]]; then
        log "PulseAudio kaldırılıyor..."
        sudo pacman -Rns pulseaudio --noconfirm
        success "PulseAudio kaldırıldı"
    fi
}

# Pacman paketlerini kur
install_pacman_packages() {
    log "Pacman paketleri kuruluyor..."
    
    # Paketleri tek tek kontrol et ve kur
    for package in "${PACMAN_PACKAGES[@]}"; do
        if pacman -Q "$package" &> /dev/null; then
            info "$package zaten kurulu"
        else
            log "$package kuruluyor..."
            sudo pacman -S "$package" --noconfirm
            
            if [[ $? -eq 0 ]]; then
                success "$package kuruldu"
            else
                warning "$package kurulumu başarısız - devam ediliyor"
            fi
        fi
    done
}

# AUR paketlerini kur
install_aur_packages() {
    log "AUR paketleri kuruluyor..."
    
    for package in "${AUR_PACKAGES[@]}"; do
        if pacman -Q "$package" &> /dev/null; then
            info "$package zaten kurulu"
        else
            log "$package (AUR) kuruluyor..."
            yay -S "$package" --noconfirm
            
            if [[ $? -eq 0 ]]; then
                success "$package kuruldu"
            else
                warning "$package kurulumu başarısız - devam ediliyor"
            fi
        fi
    done
}

# Dotfiles'ı indir ve kur
setup_dotfiles() {
    log "Dotfiles indiriliyor ve kuruluyor..."
    
    # Hedef dizin
    DOTFILE_DIR="$HOME/Arch_Dotfile"
    
    # Eğer dizin varsa güncelle, yoksa klonla
    if [[ -d "$DOTFILE_DIR" ]]; then
        warning "Dotfiles dizini mevcut, güncelleniyor..."
        cd "$DOTFILE_DIR"
        git pull
    else
        log "Dotfiles klonlanıyor..."
        git clone https://github.com/koesan/Arch_Dotfile.git "$DOTFILE_DIR"
        cd "$DOTFILE_DIR"
    fi
    
    # Config dosyalarını kopyala
    log "Config dosyaları yerleştiriliyor..."
    
    # .config dizinini oluştur
    mkdir -p "$HOME/.config"
    
    # Config klasörlerini kopyala
    config_dirs=("alacritty" "waybar" "wlogout" "wofi" "hypr" "nemo")
    for dir in "${config_dirs[@]}"; do
        if [[ -d "configs/$dir" ]]; then
            log "$dir config dosyaları kopyalanıyor..."
            cp -r "configs/$dir" "$HOME/.config/"
            success "$dir config dosyaları yerleştirildi"
        else
            warning "$dir config klasörü bulunamadı"
        fi
    done
    
    # Home dizinine kopyalanacak dosyalar
    home_items=(".icons" ".themes" ".zshrc")
    for item in "${home_items[@]}"; do
        if [[ -e "configs/$item" ]]; then
            log "$item home dizinine kopyalanıyor..."
            cp -r "configs/$item" "$HOME/"
            success "$item yerleştirildi"
        else
            warning "$item bulunamadı"
        fi
    done
}

# Zsh yapılandırması
setup_zsh() {
    log "Zsh yapılandırılıyor..."
    
    # Varsayılan shell'i değiştir
    current_shell=$(echo $SHELL)
    if [[ "$current_shell" != *"zsh"* ]]; then
        log "Varsayılan shell zsh olarak ayarlanıyor..."
        chsh -s $(which zsh)
        success "Varsayılan shell zsh yapıldı (yeniden giriş gerekli)"
    fi
    
    # Oh My Zsh kur
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log "Oh My Zsh kuruluyor..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        
        # Eklentileri kur
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
        
        success "Oh My Zsh ve eklentiler kuruldu"
    else
        info "Oh My Zsh zaten kurulu"
    fi
}

# Docker yapılandırması
setup_docker() {
    log "Docker yapılandırılıyor..."
    
    # Docker servisini başlat
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Kullanıcıyı docker grubuna ekle
    sudo usermod -aG docker $USER
    
    success "Docker yapılandırıldı (yeniden giriş gerekli)"
}

# Flatpak yapılandırması
setup_flatpak() {
    log "Flatpak yapılandırılıyor..."
    
    # Flathub deposunu ekle
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # MarkText kurulumu
    log "MarkText (Markdown editörü) kuruluyor..."
    flatpak install flathub com.github.marktext.marktext -y
    
    if [[ $? -eq 0 ]]; then
        success "MarkText kuruldu"
    else
        warning "MarkText kurulumu başarısız - devam ediliyor"
    fi
    
    success "Flatpak yapılandırıldı"
}

# Hyprland yapılandırması
setup_hyprland() {
    log "Hyprland yapılandırılıyor..."
    
    # XDG Portal yapılandırması
    mkdir -p "$HOME/.config/xdg-desktop-portal"
    
    cat > "$HOME/.config/xdg-desktop-portal/portals.conf" << 'EOF'
[preferred]
default=hyprland;gtk
EOF
    
    cat > "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf" << 'EOF'
[preferred]
default=hyprland;gtk
EOF
    
    # PipeWire servislerini yeniden başlat
    systemctl --user daemon-reexec 2>/dev/null || true
    systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null || true
    
    # XDG Desktop Portal'ı yeniden başlat
    systemctl --user restart xdg-desktop-portal 2>/dev/null || true
    
    # Xhost yapılandırması
    echo "xhost +SI:localuser:root" >> "$HOME/.profile"
    
    success "Hyprland yapılandırıldı"
}

# Python yapılandırması
setup_python() {
    log "Python yapılandırılıyor..."
    
    # Pip sistem paketleri sorunu çözümü
    python3 -m pip config set global.break-system-packages true
    
    success "Python yapılandırıldı"
}

# Nemo yapılandırması
setup_nemo() {
    if [[ -f "$HOME/Arch_Dotfile/configs/nemo/nemo-dconf.conf" ]]; then
        log "Nemo ayarları uygulanıyor..."
        dconf load /org/nemo/ < "$HOME/Arch_Dotfile/configs/nemo/nemo-dconf.conf"
        success "Nemo ayarları uygulandı"
    fi
}

# Temizlik fonksiyonu
cleanup() {
    log "Temizlik yapılıyor..."
    
    # Geçici sudo kuralını kaldır
    sudo rm -f /etc/sudoers.d/temp_installer
    
    # Pacman cache temizliği
    sudo pacman -Sc --noconfirm
    
    success "Temizlik tamamlandı"
}

# Kurulum özeti
show_summary() {
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗"
    echo -e "║                     KURULUM TAMAMLANDI!                     ║"
    echo -e "╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${YELLOW}ÖNEMLİ NOTLAR:${NC}"
    echo -e "• ${BLUE}Sistemi yeniden başlatmanız önerilir${NC}"
    echo -e "• ${BLUE}Zsh ve Docker için yeniden giriş gerekli${NC}"
    echo -e "• ${BLUE}Hyprland masaüstü ortamını seçerek giriş yapın${NC}"
    echo -e "• ${BLUE}Config dosyaları ~/.config/ dizininde${NC}"
    echo
    echo -e "${CYAN}Kurulum tamamlandı! Arch Linux dotfiles sisteminizde hazır.${NC}"
    echo
}

# Ana kurulum fonksiyonu
main() {
    show_banner
    
    log "Arch Linux Dotfile kurulumu başlatılıyor..."
    
    # Sistem kontrolleri
    check_arch
    check_root
    check_internet
    check_disk_space
    check_conflicts
    
    # Onay al
    echo
    warning "Bu script sisteminizde değişiklikler yapacak."
    read -p "Devam etmek istiyor musunuz? (y/N): " confirm
    if [[ $confirm != "y" && $confirm != "Y" ]]; then
        error "Kurulum iptal edildi."
        exit 1
    fi
    
    # Kurulum adımları
    get_sudo_access
    update_system
    remove_pulseaudio
    install_yay
    install_pacman_packages
    install_aur_packages
    setup_dotfiles
    setup_zsh
    setup_docker
    setup_flatpak
    setup_hyprland
    setup_python
    setup_nemo
    cleanup
    
    show_summary
}

# Script'i çalıştır
main "$@"
