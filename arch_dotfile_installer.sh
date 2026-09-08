#!/usr/bin/env bash
#
#=============================================================================
#  ARCH LINUX DOTFILE KURULUM SCRIPTI
#  https://github.com/koesan/Arch_Dotfile
#
#  Hyprland masaüstünü, gerekli tüm paketleri ve yapılandırmaları tek komutla
#  kurar. Temiz bir Arch kurulumunda da, hâlihazırda kullanılan bir sistemde de
#  çalışacak şekilde yazılmıştır.
#
#  Kullanım:
#      ./arch_dotfile_installer.sh              tam kurulum
#      ./arch_dotfile_installer.sh --dry-run    hiçbir şey yapmadan ne olacağını göster
#      ./arch_dotfile_installer.sh --check      kurulum sonrası doğrulama
#      ./arch_dotfile_installer.sh --minimal    isteğe bağlı paketleri atla
#      ./arch_dotfile_installer.sh --no-aur     AUR paketlerini atla
#      ./arch_dotfile_installer.sh --help       yardım
#
#  TASARIM İLKELERİ
#  · Yeniden çalıştırılabilir: ikinci kez çalıştırmak zarar vermez.
#  · Taşınabilir: hiçbir ekran adı, GPU veya sensör yolu varsayılmaz;
#    makineye özel değerler kurulum sırasında TESPİT EDİLİR.
#  · Yıkıcı değil: mevcut yapılandırmalar üzerine yazmadan önce yedeklenir.
#  · Kısmi başarısızlığa dayanıklı: bir paket kurulamazsa kurulum durmaz,
#    sonunda özet olarak bildirilir.
#=============================================================================

set -uo pipefail

#-----------------------------------------------------------------------------
# Sabitler
#-----------------------------------------------------------------------------

readonly SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
readonly REPO_DIR="$(dirname "$SCRIPT_PATH")"
readonly REPO_URL="https://github.com/koesan/Arch_Dotfile.git"

readonly STAMP="$(date +%Y%m%d-%H%M%S)"
readonly BACKUP_DIR="$HOME/.config/arch-dotfile-backup/$STAMP"
readonly LOG_FILE="$HOME/.cache/arch-dotfile-install-$STAMP.log"

# Renkler — terminal desteklemiyorsa (boru, dosya) boş bırakılır.
if [[ -t 1 ]]; then
    RED=$'\033[0;31m';  GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
    BLUE=$'\033[0;34m'; PURPLE=$'\033[0;35m'; CYAN=$'\033[0;36m'
    BOLD=$'\033[1m';    NC=$'\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; PURPLE=''; CYAN=''; BOLD=''; NC=''
fi
readonly RED GREEN YELLOW BLUE PURPLE CYAN BOLD NC

#-----------------------------------------------------------------------------
# Seçenekler
#-----------------------------------------------------------------------------

DRY_RUN=false
CHECK_ONLY=false
MINIMAL=false
USE_AUR=true
ASSUME_YES=false

#-----------------------------------------------------------------------------
# Durum toplayıcılar — sondaki özet bunlardan üretilir.
#-----------------------------------------------------------------------------

declare -a FAILED_ITEMS=()
declare -a WARNED_ITEMS=()
declare -a NOTES=()

#-----------------------------------------------------------------------------
# Günlükleme
#-----------------------------------------------------------------------------

log()     { printf '%s[%s]%s %s\n'   "$CYAN"   "$(date '+%H:%M:%S')" "$NC" "$*"; }
info()    { printf '%s[BİLGİ]%s %s\n'    "$BLUE"   "$NC" "$*"; }
success() { printf '%s[TAMAM]%s %s\n'    "$GREEN"  "$NC" "$*"; }
warning() { printf '%s[UYARI]%s %s\n'    "$YELLOW" "$NC" "$*"; WARNED_ITEMS+=("$*"); }
error()   { printf '%s[HATA]%s %s\n'     "$RED"    "$NC" "$*" >&2; FAILED_ITEMS+=("$*"); }
fatal()   { printf '%s[DURDU]%s %s\n'    "$RED"    "$NC" "$*" >&2; exit 1; }
step()    { printf '\n%s%s▸ %s%s\n' "$BOLD" "$PURPLE" "$*" "$NC"; }
note()    { NOTES+=("$*"); }

# --dry-run altında komutu çalıştırmak yerine yazdırır.
run() {
    if $DRY_RUN; then
        printf '%s  [kuru] %s%s\n' "$YELLOW" "$*" "$NC"
        return 0
    fi
    "$@"
}

show_banner() {
    printf '%s' "$PURPLE"
    cat <<'BANNER'
╔══════════════════════════════════════════════════════════════╗
║             ARCH LINUX DOTFILE KURULUM SCRIPTI               ║
║                Hyprland masaüstü · v3.0                      ║
║              github.com/koesan/Arch_Dotfile                  ║
╚══════════════════════════════════════════════════════════════╝
BANNER
    printf '%s\n' "$NC"
}

usage() {
    cat <<'USAGE'
Kullanım: arch_dotfile_installer.sh [SEÇENEK]...

  --dry-run     Hiçbir değişiklik yapmadan yapılacakları listeler.
  --check       Yalnızca doğrulama yapar (kurulum sonrası kontrol).
  --minimal     İsteğe bağlı paketleri atlar (LibreOffice, Docker, VS Code,
                Brave, Flatpak, MS fontları).
  --no-aur      AUR paketlerini ve yay kurulumunu atlar. Catppuccin GTK teması
                ve imleçleri yerine depodaki yedek tema kullanılır.
  -y, --yes     Onay sorularını sormaz (tam otomatik kurulum).
  -h, --help    Bu yardımı gösterir.
USAGE
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)   DRY_RUN=true ;;
            --check)     CHECK_ONLY=true ;;
            --minimal)   MINIMAL=true ;;
            --no-aur)    USE_AUR=false ;;
            -y|--yes)    ASSUME_YES=true ;;
            -h|--help)   usage; exit 0 ;;
            *)           printf 'Bilinmeyen seçenek: %s\n\n' "$1" >&2; usage; exit 1 ;;
        esac
        shift
    done
}

confirm() {
    local prompt="$1"
    $ASSUME_YES && return 0
    $DRY_RUN && return 0
    local reply
    # Prompt ve girdi doğrudan terminale gider; çıktı tee'ye yönlendirilmiş
    # olsa bile soru görünür ve yanıt okunur.
    printf '%s (e/H): ' "$prompt" > /dev/tty
    read -r reply < /dev/tty
    [[ "$reply" =~ ^([eE]|[yY]|[eE][vV][eE][tT])$ ]]
}

#=============================================================================
#  PAKET LİSTELERİ
#=============================================================================
#
#  Listeler amaca göre gruplandı. Her satırın neden orada olduğu yazılı;
#  bir paketi çıkarmadan önce hangi yapılandırmanın ona dayandığını görün.

# --- Çekirdek: bunlar olmadan masaüstü açılmaz veya temel işlevler eksilir ---
declare -a PKG_CORE=(
    # Derleme ve indirme araçları (yay ve AUR paketleri için gerekli)
    base-devel git curl wget unzip zip

    # Hyprland ve ekosistemi
    hyprland                      # pencere yöneticisi (Lua yapılandırma desteği)
    hyprpaper                     # duvar kağıdı        → hypr/hyprpaper.conf
    hyprlock                      # ekran kilidi        → hypr/hyprlock.conf
    hypridle                      # boşta kalma yönetimi→ hypr/hypridle.conf
    hyprcursor                    # vektör imleç desteği
    hyprpolkitagent               # yetkilendirme penceresi (sudo isteyen GUI)
    hyprland-qt-support           # → hypr/application-style.conf

    # Masaüstü portalları: ekran paylaşımı, dosya seçici, tema aktarımı
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    xdg-user-dirs                 # ~/Resimler vb. (ekran görüntüsü hedefi)
    xdg-user-dirs-gtk

    # Panel, bildirim, başlatıcı
    waybar                        # → waybar/config, waybar/style.css
    mako                          # → mako/config   (SUPER+N ile temizlenir)
    rofi                          # → rofi/config.rasi (SUPER+R)
    rofi-emoji                    # SUPER+PERIOD emoji seçici
    wofi                          # yedek başlatıcı → wofi/config

    # Terminal, dosya yöneticisi
    alacritty                     # → alacritty/alacritty.toml
    nemo nemo-fileroller file-roller cinnamon-translations
    gvfs gvfs-mtp                 # nemo: çöp kutusu, USB/telefon bağlama
    ffmpegthumbnailer             # nemo: video küçük resimleri

    # Ses (PipeWire)
    pipewire pipewire-audio pipewire-pulse pipewire-alsa wireplumber
    pavucontrol                   # waybar ses simgesine tıklayınca açılır

    # Ağ
    networkmanager network-manager-applet

    # Bluetooth
    bluez bluez-utils blueman     # waybar bluetooth modülü buna dayanır

    # Donanım tuşları (hypr/lua/binds.lua)
    brightnessctl                 # parlaklık — hypridle de kullanır
    playerctl                     # medya tuşları
    upower power-profiles-daemon  # pil durumu ve güç profilleri

    # Ekran görüntüsü ve pano (hypr/lua/binds.lua)
    grim slurp swappy
    wl-clipboard cliphist jq      # jq: aktif pencere görüntüsü için

    # X11 uyumluluğu
    xorg-xwayland xorg-xhost

    # Qt tema desteği (hypr/lua/env.lua → QT_QPA_PLATFORMTHEME=qt6ct)
    qt5-wayland qt6-wayland qt5ct qt6ct

    # Yazı tipleri — yapılandırmalar bu ailelere ad ile başvuruyor
    ttf-jetbrains-mono-nerd       # waybar, rofi, mako, hyprlock, alacritty
    ttf-nerd-fonts-symbols        # eksik simgeler için yedek
    otf-font-awesome
    noto-fonts noto-fonts-emoji

    # GTK tema altyapısı
    adwaita-icon-theme            # her zaman var olan yedek simge/imleç teması
    gnome-themes-extra            # Adwaita-dark
    nwg-look                      # GTK temasını arayüzden değiştirmek için
    librsvg                       # GTK'nın SVG okuması → wlogout simgeleri

    # Kabuk ve sistem araçları
    zsh
    btop htop fastfetch tree      # not: neofetch Arch depolarından kaldırıldı
    python python-pip python-virtualenv
    man-db                        # `man 5 waybar-battery` vb.
    polkit
)

# --- İsteğe bağlı: --minimal ile atlanır ------------------------------------
declare -a PKG_OPTIONAL=(
    xsensors
    flatpak
    docker
    libreoffice-fresh libreoffice-fresh-tr
    code
)

# --- AUR --------------------------------------------------------------------
declare -a AUR_CORE=(
    wlogout                       # oturum menüsü → wlogout/  (SUPER+ESCAPE)
)

# Tema paketleri: kurulamazsa depodaki yedek temalara düşülür.
declare -a AUR_THEME=(
    catppuccin-gtk-theme-mocha    # GTK teması — masaüstünün geri kalanıyla aynı palet
    catppuccin-cursors-mocha      # imleç teması
)

declare -a AUR_OPTIONAL=(
    brave-bin                     # SUPER+B
    ttf-ms-fonts                  # Office belgeleri için
)

#=============================================================================
#  ÖN KONTROLLER
#=============================================================================

check_arch() {
    [[ -f /etc/arch-release ]] || fatal "Bu script yalnızca Arch Linux ve türevleri içindir."
    success "Arch Linux tespit edildi"
}

check_not_root() {
    [[ $EUID -ne 0 ]] || fatal "Bu scripti root olarak çalıştırmayın; gerektiğinde sudo kullanılacak."
    command -v sudo >/dev/null || fatal "sudo kurulu değil. Önce kurun: pacman -S sudo"
    success "Kullanıcı: $USER"
}

check_internet() {
    # ping bazı ağlarda (ICMP kapalı) yanıltıcı olur; HTTPS ile deniyoruz.
    local host
    for host in https://archlinux.org https://github.com https://aur.archlinux.org; do
        if curl -fsS --max-time 8 -o /dev/null "$host" 2>/dev/null; then
            success "İnternet bağlantısı aktif ($host)"
            return 0
        fi
    done
    fatal "İnternet bağlantısı kurulamadı. Kurulum paket indirmeyi gerektirir."
}

check_disk_space() {
    local avail_kb required_kb=8000000   # 8 GB
    avail_kb=$(df --output=avail / | tail -n1)
    if (( avail_kb < required_kb )); then
        fatal "Yetersiz disk alanı: $((avail_kb/1024/1024)) GB boş, en az 8 GB gerekli."
    fi
    success "Disk alanı yeterli ($((avail_kb/1024/1024)) GB boş)"
}

check_pacman_free() {
    if [[ -f /var/lib/pacman/db.lck ]]; then
        fatal "pacman kilitli (/var/lib/pacman/db.lck). Başka bir paket işlemi sürüyor olabilir."
    fi
}

check_repo() {
    if [[ ! -d "$REPO_DIR/configs" ]]; then
        warning "configs/ dizini bulunamadı, depo klonlanıyor..."
        local target="$HOME/Arch_Dotfile"
        run git clone --depth 1 "$REPO_URL" "$target" || fatal "Depo klonlanamadı."
        fatal "Depo $target dizinine indirildi. Scripti oradan çalıştırın: $target/arch_dotfile_installer.sh"
    fi
    success "Dotfile deposu: $REPO_DIR"
}

# Hyprland'in Lua yapılandırma biçimini desteklediğini doğrular.
check_hyprland_lua_support() {
    # Paket henüz kurulmamış olabilir; kurulumdan SONRA çağrılıyor.
    if [[ -f /usr/share/hypr/stubs/hl.meta.lua ]]; then
        success "Hyprland Lua yapılandırma desteği var"
        return 0
    fi
    warning "Bu Hyprland sürümü Lua yapılandırmayı desteklemiyor gibi görünüyor."
    note "Depo hypr/hyprland.lua kullanır. Hyprland'i güncelleyin: sudo pacman -Syu hyprland"
    return 1
}

#=============================================================================
#  SUDO
#=============================================================================
#
#  Eski sürüm /etc/sudoers.d/temp_installer dosyasına doğrudan yazıyordu.
#  Oradaki bir yazım hatası sudo'yu tamamen kullanılamaz hale getirebilir.
#  Bunun yerine arka planda sudo oturumunu tazeleyen bir döngü kullanılıyor —
#  sistem dosyalarına hiç dokunulmaz.

SUDO_KEEPALIVE_PID=""

start_sudo_keepalive() {
    $DRY_RUN && return 0
    log "Kurulum için yönetici yetkisi gerekiyor (şifre bir kez sorulacak)"
    sudo -v || fatal "Yönetici yetkisi alınamadı."

    while true; do
        sudo -n true 2>/dev/null
        sleep 50
        kill -0 "$$" 2>/dev/null || exit
    done &
    SUDO_KEEPALIVE_PID=$!
    success "Yönetici yetkisi alındı (kurulum boyunca canlı tutulacak)"
}

stop_sudo_keepalive() {
    [[ -n "$SUDO_KEEPALIVE_PID" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
    SUDO_KEEPALIVE_PID=""
}

cleanup_on_exit() {
    stop_sudo_keepalive
}
trap cleanup_on_exit EXIT INT TERM

#=============================================================================
#  PAKET KURULUMU
#=============================================================================

pkg_installed() { pacman -Qq "$1" &>/dev/null; }

# Depodan KALDIRILMIŞ ama sistemde duran paketleri listeler.
#
# Arch zaman zaman paketleri depodan çıkarır (ör. multilib küçültmeleri,
# glusterfs desteğinin düşürülmesi). Bu paketler sistemde "yetim" kalır ve
# `pacman -Syu` sırasında ya çakışma ya da karşılanamayan sürüm bağımlılığı
# üretir. Kullanıcının hangi paketlerin sorun çıkardığını tahmin etmesi
# gerekmesin diye burada tespit edip yazıyoruz.
# Not: paket başına `pacman -Si` çağırmak ~1500 paketlik bir sistemde
# dakikalarca sürer. Kurulu paket listesi ile senkronize depo listesinin
# farkını almak aynı sonucu anında verir.
list_dropped_packages() {
    comm -23 <(pacman -Qq | sort) <(pacman -Slq | sort -u)
}

# "qemu-common-11.1.1-1" → "qemu-common"
#
# pacman hata iletilerinde paket adını sürümle birlikte yazar ve ad da tire
# içerebildiği için ("qemu-block-gluster") adı sürümden ayırmanın güvenilir
# tek yolu, sondan tire tire kırpıp gerçekten var olan bir paket adına
# rastlayana kadar denemektir.
strip_pkg_version() {
    local token="$1"
    while [[ "$token" == *-* ]]; do
        if pacman -Qq "$token" &>/dev/null || pacman -Si "$token" &>/dev/null; then
            printf '%s\n' "$token"
            return 0
        fi
        token="${token%-*}"
    done
    printf '%s\n' "$token"
}

# pacman çıktısından çakışmaya/bağımlılık kırılmasına ADI GEÇEN paketleri çıkarır.
extract_blocking_packages() {
    local log="$1"
    {
        # ":: X and Y are in conflict"
        grep -oE '^:: [^ ]+ and [^ ]+ are in conflict' "$log" 2>/dev/null \
            | sed -E 's/^:: ([^ ]+) and ([^ ]+) .*/\1\n\2/'
        # "... breaks dependency 'a=b' required by W"
        grep -oE "breaks dependency '[^']+' required by [^ ]+" "$log" 2>/dev/null \
            | sed -E "s/.* required by //"
        # "... requires W" (karşılanamayan bağımlılık)
        grep -oE '^:: [^ ]+: requires [^ ]+' "$log" 2>/dev/null \
            | sed -E 's/^:: ([^:]+):.*/\1/'
    } | sort -u
}

# Depodan kaldırılmış bir paketten başlayarak, onu isteyen ve KENDİSİ DE
# depodan kaldırılmış olan tüm paketleri toplar.
#
# Neden gerekli: lib32-audit tek başına kaldırılamaz, çünkü lib32-pam onu
# ister; lib32-pam da kaldırılamaz, çünkü lib32-libcap onu ister. Zincirin
# tamamı depodan düşmüşse hepsini TEK işlemde kaldırmak gerekir — o zaman
# bağımlılık denetimini atlamaya (-Rdd) da gerek kalmaz.
collect_dead_chain() {
    local -a queue=("$1") chain=()
    local pkg dep
    while (( ${#queue[@]} > 0 )); do
        pkg="${queue[0]}"; queue=("${queue[@]:1}")
        [[ " ${chain[*]} " == *" $pkg "* ]] && continue
        pacman -Qq "$pkg" &>/dev/null || continue     # kurulu değil
        pacman -Si "$pkg" &>/dev/null && continue     # depoda VAR → zincire girmez
        chain+=("$pkg")
        while read -r dep; do
            [[ -n "$dep" && "$dep" != "$pkg" ]] && queue+=("$dep")
        done < <(pactree -r -u -d1 "$pkg" 2>/dev/null | grep -vx "$pkg")
    done
    printf '%s\n' "${chain[@]}"
}

# Zincirin dışından, zincire bağımlı olan KURULU paketleri bulur.
external_requesters() {
    local -a chain=("$@")
    local pkg dep
    for pkg in "${chain[@]}"; do
        while read -r dep; do
            [[ -z "$dep" || "$dep" == "$pkg" ]] && continue
            [[ " ${chain[*]} " == *" $dep "* ]] && continue
            printf '%s\n' "$dep"
        done < <(pactree -r -u -d1 "$pkg" 2>/dev/null | grep -vx "$pkg")
    done | sort -u
}

# Bir paketin DEPODAKİ (güncellenecek) sürümü hâlâ verilen bağımlılığı istiyor mu?
repo_version_still_needs() {
    local pkg="$1" dep="$2"
    # Süreç ikamesi: boru hattının sonunda grep -q erken kapanınca pipefail
    # yanlış sonuç veriyordu (bkz. fc-list notu).
    grep -qE "(^|[[:space:]])${dep}([=<>][^[:space:]]*)?([[:space:]]|$)" \
        < <(pacman -Si "$pkg" 2>/dev/null | sed -n '/^Depends On/,/^Optional Deps/p')
}

diagnose_upgrade_failure() {
    local log="$1"
    printf '\n%s%s── Teşhis ──%s\n' "$BOLD" "$CYAN" "$NC"

    local -a blocking=()
    mapfile -t blocking < <(extract_blocking_packages "$log")

    if (( ${#blocking[@]} == 0 )); then
        echo "Hatanın sorumlusu otomatik olarak belirlenemedi. Elle inceleyin:"
        echo "    sudo pacman -Syu"
        echo
        echo "Depoda karşılığı olmayan paketler (AUR paketleri de burada görünür):"
        printf '  %s\n' $(list_dropped_packages)
        printf '%s\n' "$NC"
        return
    fi

    # Sorumlu YALNIZCA depodan kaldırılmış paketler olabilir. Çakışmanın
    # diğer tarafı (ör. qemu-common) depoda duran sağlam pakettir; onu
    # silmeyi önermek sistemi bozar.
    local -a culprits=()
    local raw name
    for raw in "${blocking[@]}"; do
        name=$(strip_pkg_version "$raw")
        pacman -Qq "$name" &>/dev/null || continue
        pacman -Si "$name" &>/dev/null && continue
        [[ " ${culprits[*]} " == *" $name "* ]] || culprits+=("$name")
    done

    if (( ${#culprits[@]} == 0 )); then
        echo "Engelleyen paketlerin hepsi depoda mevcut; sorun kaldırılmış bir"
        echo "paketten kaynaklanmıyor. Çıktıyı elle inceleyin:"
        echo "    sudo pacman -Syu"
        printf '%s\n' "$NC"
        return
    fi

    local -a chain=() ext=()
    local c
    for c in "${culprits[@]}"; do
        while read -r name; do
            [[ -n "$name" && " ${chain[*]} " != *" $name "* ]] && chain+=("$name")
        done < <(collect_dead_chain "$c")
    done

    echo "Sorumlu: depodan KALDIRILMIŞ olduğu hâlde sistemde duran paketler."
    echo
    printf '  %s%s%s\n' "$BOLD" "${chain[*]}" "$NC"
    echo

    mapfile -t ext < <(external_requesters "${chain[@]}")

    if (( ${#ext[@]} == 0 )); then
        echo "Bu zinciri zincir dışından isteyen hiçbir paket yok — tamamen ölü."
        printf '\n    %ssudo pacman -R %s%s\n' "$BOLD" "${chain[*]}" "$NC"
    else
        # Dışarıdan isteyen var. Kritik soru: o paketin GÜNCEL sürümü hâlâ
        # istiyor mu? İstemiyorsa güncelleme zaten bağı koparacak, bu yüzden
        # -Rdd ile kaldırmak güvenlidir.
        local e blocker=false
        echo "Zinciri dışarıdan isteyenler:"
        for e in "${ext[@]}"; do
            local needed=""
            for c in "${chain[@]}"; do
                repo_version_still_needs "$e" "$c" && needed+="$c "
            done
            if [[ -n "$needed" ]]; then
                printf '  %s%-24s%s GÜNCEL sürümü hâlâ istiyor: %s\n' "$RED" "$e" "$NC" "$needed"
                blocker=true
            else
                printf '  %s%-24s%s güncel sürümü artık istemiyor (güncelleme bağı koparacak)\n' "$GREEN" "$e" "$NC"
            fi
        done
        echo
        if $blocker; then
            echo "Kırmızı ile işaretlenenler bu paketlere gerçekten ihtiyaç duyuyor."
            echo "Otomatik bir çözüm önerilemez; çıktıyı elle inceleyin."
        else
            echo "Hiçbiri güncel sürümünde bu paketlere ihtiyaç duymuyor, kaldırmak güvenli:"
            printf '\n    %ssudo pacman -Rdd %s%s\n' "$BOLD" "${chain[*]}" "$NC"
        fi
    fi

    echo
    echo "Sonra:  sudo pacman -Syu    ve bu betiği tekrar çalıştırın."
    printf '%s\n' "$NC"
}

update_system() {
    step "Sistem güncelleniyor"

    if $DRY_RUN; then
        printf '%s  [kuru] sudo pacman -Syu --noconfirm%s\n' "$YELLOW" "$NC"
        success "Sistem güncel"
        return 0
    fi

    # Çıktıyı hem ekrana ver hem sakla: hata olursa sorumlu paketi ondan buluyoruz.
    local log; log=$(mktemp)
    sudo pacman -Syu --noconfirm 2>&1 | tee "$log"
    local rc=${PIPESTATUS[0]}

    if (( rc != 0 )); then
        error "Sistem güncellemesi başarısız."
        warning "Kısmi güncelleme (partial upgrade) sistemi bozabileceği için burada duruluyor."
        diagnose_upgrade_failure "$log"
        rm -f "$log"
        fatal "Sorunu giderdikten sonra bu betiği tekrar çalıştırın."
    fi
    rm -f "$log"
    success "Sistem güncel"
}

# Paketleri önce toplu kurar (hızlı), başarısız olursa tek tek dener; böylece
# tek bir sorunlu paket tüm listeyi engellemez.
install_pacman_group() {
    local label="$1"; shift
    local -a wanted=("$@")
    local -a todo=()
    local p

    for p in "${wanted[@]}"; do
        pkg_installed "$p" || todo+=("$p")
    done

    if (( ${#todo[@]} == 0 )); then
        info "$label: hepsi zaten kurulu (${#wanted[@]} paket)"
        return 0
    fi

    log "$label: ${#todo[@]} paket kurulacak"
    if run sudo pacman -S --needed --noconfirm "${todo[@]}"; then
        success "$label kuruldu"
        return 0
    fi

    warning "$label toplu kurulumda hata; paketler tek tek deneniyor"
    for p in "${todo[@]}"; do
        if run sudo pacman -S --needed --noconfirm "$p"; then
            success "  $p"
        else
            error "  $p kurulamadı"
        fi
    done
}

install_yay() {
    if command -v yay &>/dev/null; then
        success "yay zaten kurulu"
        return 0
    fi
    step "yay (AUR yardımcısı) kuruluyor"

    local tmp
    tmp=$(mktemp -d)
    if run git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin" \
       && run bash -c "cd '$tmp/yay-bin' && makepkg -si --noconfirm"; then
        rm -rf "$tmp"
        command -v yay &>/dev/null && { success "yay kuruldu"; return 0; }
    fi
    rm -rf "$tmp"
    error "yay kurulamadı — AUR paketleri atlanacak"
    USE_AUR=false
    return 1
}

install_aur_group() {
    local label="$1"; shift
    local -a wanted=("$@")
    local p rc=0

    $USE_AUR || { info "$label atlandı (--no-aur)"; return 1; }
    command -v yay &>/dev/null || { warning "$label atlandı (yay yok)"; return 1; }

    for p in "${wanted[@]}"; do
        if pkg_installed "$p"; then
            info "$p zaten kurulu"
            continue
        fi
        log "$p (AUR) kuruluyor..."
        if run yay -S --needed --noconfirm --answerdiff=None --answeredit=None "$p"; then
            success "$p kuruldu"
        else
            error "$p (AUR) kurulamadı"
            rc=1
        fi
    done
    return $rc
}

#=============================================================================
#  SERVİSLER
#=============================================================================

enable_service() {
    local svc="$1" desc="$2"
    if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
        info "$desc zaten etkin ($svc)"
        return 0
    fi
    # `systemctl list-unit-files X` birim yoksa da 0 döner (yalnızca başlık
    # basar); bu yüzden çıktıda birim adını arıyoruz.
    # Boru yerine süreç ikamesi: `... | grep -q` altında soldaki komut SIGPIPE
    # alıp pipefail'i tetikleyebiliyor (bkz. fc-list notu).
    if ! grep -q . < <(systemctl list-unit-files --no-legend "$svc" 2>/dev/null); then
        warning "$svc bulunamadı — $desc atlandı"
        return 1
    fi
    if run sudo systemctl enable --now "$svc"; then
        success "$desc etkinleştirildi ($svc)"
    else
        error "$svc etkinleştirilemedi"
    fi
}

setup_services() {
    step "Sistem servisleri"

    # ESKİ SÜRÜMDEKİ EN CİDDİ EKSİK: networkmanager kuruluyordu ama servis hiç
    # etkinleştirilmiyordu — yeniden başlatınca sistem ağsız açılıyordu.
    enable_service NetworkManager.service "Ağ yönetimi"
    enable_service bluetooth.service       "Bluetooth"

    # PipeWire kullanıcı servisleri: socket etkinleştirmesi zaten varsayılan,
    # yalnızca çalıştıklarını doğruluyoruz.
    if ! $DRY_RUN; then
        systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null \
            && success "Ses servisleri (PipeWire) etkin" \
            || warning "PipeWire kullanıcı servisleri şu an başlatılamadı (oturum açıldığında başlar)"
    fi
}

setup_display_manager() {
    step "Oturum yöneticisi"

    # Zaten etkin bir DM varsa dokunma — kullanıcının kurulumunu değiştirmeyiz.
    local dm
    for dm in sddm gdm lightdm lxdm greetd ly; do
        if systemctl is-enabled --quiet "${dm}.service" 2>/dev/null; then
            success "$dm zaten etkin — değiştirilmedi"
            note "Giriş ekranında oturum türü olarak 'Hyprland' seçin."
            return 0
        fi
    done

    info "Etkin bir oturum yöneticisi yok."
    info "SDDM kurulursa açılışta grafik giriş ekranı gelir ve Hyprland'i listeden seçebilirsiniz."
    if confirm "SDDM kurulup etkinleştirilsin mi?"; then
        install_pacman_group "SDDM" sddm
        enable_service sddm.service "Grafik giriş ekranı"
    else
        info "SDDM atlandı."
        note "Hyprland'i TTY'den elle başlatmak için: Hyprland"
    fi
}

#=============================================================================
#  YAPILANDIRMA DOSYALARI
#=============================================================================

backup_path() {
    local src="$1"
    [[ -e "$src" ]] || return 0
    local rel="${src#"$HOME"/}"
    local dest="$BACKUP_DIR/$rel"
    run mkdir -p "$(dirname "$dest")"
    run cp -a "$src" "$dest" && info "  yedeklendi: ~/${rel}"
}

# Kaynak dizini hedefe TAM olarak kopyalar.
#
# Eski sürümde `cp -r configs/hypr ~/.config/` kullanılıyordu. Hedef zaten
# varsa bu komut içeriği ~/.config/hypr/hypr/ altına kopyalar — ikinci
# çalıştırmada yapılandırma bozuluyordu. Burada hedef önce yedeklenip
# siliniyor, sonra tam kopya yazılıyor.
deploy_dir() {
    local src="$1" dest="$2"
    [[ -d "$src" ]] || { warning "kaynak yok: $src"; return 1; }
    backup_path "$dest"
    run rm -rf "$dest"
    run mkdir -p "$(dirname "$dest")"
    run cp -a "$src" "$dest" || { error "kopyalanamadı: $dest"; return 1; }
    success "  ${dest/#$HOME/\~}"
}

# Kaynağı hedefin ÜZERİNE birleştirir (hedefteki fazlalıklar silinmez).
#
# ~/.icons ve ~/.themes için deploy_dir kullanılamaz: o dizinlerde kullanıcının
# ya da paket yöneticisinin koyduğu başka temalar olabilir ve rm -rf onları
# silerdi. Burada yalnızca deponun getirdiği dosyalar yazılır.
merge_dir() {
    local src="$1" dest="$2"
    [[ -d "$src" ]] || { warning "kaynak yok: $src"; return 1; }
    run mkdir -p "$dest"
    local item
    for item in "$src"/* "$src"/.[!.]*; do
        [[ -e "$item" ]] || continue
        backup_path "$dest/$(basename "$item")"
    done
    run cp -a "$src/." "$dest/" || { error "birleştirilemedi: $dest"; return 1; }
    success "  ${dest/#$HOME/\~}  (birleştirildi)"
}

deploy_file() {
    local src="$1" dest="$2"
    [[ -f "$src" ]] || { warning "kaynak yok: $src"; return 1; }
    backup_path "$dest"
    run mkdir -p "$(dirname "$dest")"
    run cp -a "$src" "$dest" || { error "kopyalanamadı: $dest"; return 1; }
    success "  ${dest/#$HOME/\~}"
}

setup_dotfiles() {
    step "Yapılandırma dosyaları yerleştiriliyor"
    info "Mevcut dosyalar şuraya yedekleniyor: ${BACKUP_DIR/#$HOME/\~}"

    # Makineye özel Hyprland ayarları korunur: local.lua depoda yoktur ve
    # güncellemede KAYBOLMAMALIDIR.
    local local_lua="$HOME/.config/hypr/lua/local.lua"
    local saved_local=""
    if [[ -f "$local_lua" ]]; then
        saved_local=$(mktemp)
        cp -a "$local_lua" "$saved_local"
        info "hypr/lua/local.lua korunuyor (makineye özel ayarlarınız)"
    fi

    # Kendi duvar kağıdınızı koyduysanız depodakiyle ezilmesin.
    local wall="$HOME/.config/hypr/wallpaper/wallpaper.jpg"
    local saved_wall=""
    if [[ -f "$wall" ]] && ! cmp -s "$wall" "$REPO_DIR/configs/hypr/wallpaper/wallpaper.jpg"; then
        saved_wall=$(mktemp)
        cp -a "$wall" "$saved_wall"
        info "Kendi duvar kağıdınız korunuyor"
    fi

    # Not: "nemo" bu listede YOK. Nemo ayarları dosya değil dconf anahtarıdır
    # ve setup_nemo tarafından `dconf load` ile uygulanır. Eski sürüm
    # configs/nemo/ dizinini ~/.config/nemo üzerine kopyalıyordu; bu hem dconf
    # dökümünü oraya çöp olarak bırakıyor hem de cp -r iç içe kopyalama hatası
    # yüzünden ~/.config/nemo/nemo/ dizinini oluşturuyordu.
    local d
    for d in alacritty waybar wlogout wofi hypr mako rofi; do
        deploy_dir "$REPO_DIR/configs/$d" "$HOME/.config/$d"
    done

    if [[ -n "$saved_local" ]]; then
        run mkdir -p "$(dirname "$local_lua")"
        run cp -a "$saved_local" "$local_lua"
        rm -f "$saved_local"
        success "  ~/.config/hypr/lua/local.lua geri yüklendi"
    fi

    if [[ -n "$saved_wall" ]]; then
        run mkdir -p "$(dirname "$wall")"
        run cp -a "$saved_wall" "$wall"
        rm -f "$saved_wall"
        success "  duvar kağıdınız geri yüklendi"
    fi

    # Yardımcı betikler. ~/.local/bin FHS'te kullanıcıya ait ikili dizinidir ve
    # systemd/zsh varsayılan PATH'inde bulunur. Waybar betiği zaten tam yolla
    # ($HOME/.local/bin/caffeine) çağırdığı için PATH'e bağımlı değildir.
    deploy_file "$REPO_DIR/configs/bin/caffeine" "$HOME/.local/bin/caffeine"
    run chmod +x "$HOME/.local/bin/caffeine"

    # Ev dizinine gidenler — BİRLEŞTİRİLİR, silinmez: bu dizinlerde başka
    # kaynaklardan gelmiş temalar olabilir (nwg-look, AUR paketleri).
    merge_dir "$REPO_DIR/configs/.icons"  "$HOME/.icons"
    merge_dir "$REPO_DIR/configs/.themes" "$HOME/.themes"
    # .zshrc setup_zsh içinde yerleştirilir (Oh My Zsh onu ezmesin diye).
}

#=============================================================================
#  MAKİNEYE ÖZEL AYARLAR
#
#  Depodaki hiçbir dosya donanım varsaymaz. Donanıma bağlı değerler burada,
#  kurulum anında tespit edilip yapılandırmalara yazılır.
#=============================================================================

# hyprpaper ve hyprlock, ~ genişletmesi konusunda güvenilir değil.
# Mutlak yol yazarak belirsizliği ortadan kaldırıyoruz.
setup_paths() {
    step "Dosya yolları makineye göre ayarlanıyor"
    local wall="$HOME/.config/hypr/wallpaper/wallpaper.jpg"

    if [[ ! -f "$wall" ]] && ! $DRY_RUN; then
        warning "Duvar kağıdı bulunamadı: $wall"
        note "Duvar kağıdı için: cp resminiz.jpg ~/.config/hypr/wallpaper/wallpaper.jpg"
    fi

    local f
    for f in "$HOME/.config/hypr/hyprpaper.conf" "$HOME/.config/hypr/hyprlock.conf"; do
        [[ -f "$f" ]] || continue
        run sed -i "s|~/.config/hypr/wallpaper/wallpaper.jpg|$wall|g" "$f"
        run sed -i "s|\$HOME/.config/hypr/wallpaper/wallpaper.jpg|$wall|g" "$f"
    done
    success "Duvar kağıdı yolu mutlaklaştırıldı"
}

# CPU sıcaklık sensörünü bulup waybar'a yazar.
#
# hwmonN numaraları her açılışta değişebilir; bu yüzden numara değil, sensör
# ADI (k10temp / coretemp / zenpower) üzerinden kararlı yol bulunuyor.
# Bulunamazsa hiçbir şey yazılmaz — waybar o durumda thermal_zone0'a düşer ve
# modül yine çalışır.
setup_waybar_sensor() {
    step "CPU sıcaklık sensörü aranıyor"
    local cfg="$HOME/.config/waybar/config"
    [[ -f "$cfg" ]] || { warning "waybar/config yok, atlandı"; return 1; }

    local hw name path=""
    for hw in /sys/class/hwmon/hwmon*; do
        [[ -r "$hw/name" ]] || continue
        name=$(<"$hw/name")
        case "$name" in
            k10temp|zenpower|coretemp)
                # Paket sıcaklığını veren girdiyi seç.
                if [[ -r "$hw/temp1_input" ]]; then
                    path=$(readlink -f "$hw/temp1_input")
                    log "  sensör bulundu: $name → $path"
                    break
                fi
                ;;
        esac
    done

    if [[ -z "$path" ]]; then
        info "Bilinen CPU sensörü bulunamadı; waybar thermal_zone0 kullanacak"
        return 0
    fi

    if $DRY_RUN; then
        printf '%s  [kuru] waybar/config → hwmon-path: %s%s\n' "$YELLOW" "$path" "$NC"
        return 0
    fi

    # Önce varsa eski satırı temizle, sonra "temperature": { bloğunun hemen
    # ardına ekle. Böylece script tekrar çalıştırıldığında satır çoğalmaz.
    sed -i '/^        "hwmon-path":/d' "$cfg"
    sed -i "s|^    \"temperature\": {|    \"temperature\": {\n        \"hwmon-path\": \"$path\",|" "$cfg"
    success "waybar sıcaklık sensörü ayarlandı"
}

#=============================================================================
#  TEMA — tek palet: Catppuccin Mocha
#
#  Waybar, rofi, mako, wlogout, hyprlock, alacritty ve Hyprland zaten aynı
#  paleti kullanıyor. Eksik olan GTK/Qt/imleç tarafıydı: eski kurulumda GTK
#  teması Andromeda, simgeler Dracula, imleç ise hiç kurulmamış olan Qogir'di.
#
#  Buradaki mantık: önce Catppuccin karşılıklarını kurmayı dene, kurulamazsa
#  depoda gömülü olan (ve internet gerektirmeyen) yedeklere düş. Hangi ad
#  gerçekten kuruluysa o yazılır — var olmayan bir tema adı asla yazılmaz.
#=============================================================================

GTK_THEME_NAME=""
ICON_THEME_NAME=""
CURSOR_THEME_NAME=""
CURSOR_SIZE=24

theme_dir_exists() {
    [[ -d "/usr/share/themes/$1" || -d "$HOME/.themes/$1" ]]
}

icon_dir_exists() {
    [[ -d "/usr/share/icons/$1" || -d "$HOME/.icons/$1" ]]
}

detect_themes() {
    step "Tema adları tespit ediliyor"

    # --- GTK teması ---------------------------------------------------------
    local cand
    # Catppuccin paketi sürüme göre farklı dizin adları kullanıyor; sabit ad
    # varsaymak yerine gerçekten var olanı buluyoruz.
    for cand in /usr/share/themes/catppuccin-mocha-*-standard+default \
                /usr/share/themes/catppuccin-mocha-*-standard* \
                /usr/share/themes/[Cc]atppuccin-[Mm]ocha*; do
        if [[ -d "$cand" ]]; then
            GTK_THEME_NAME="$(basename "$cand")"
            break
        fi
    done
    if [[ -z "$GTK_THEME_NAME" ]]; then
        for cand in Andromeda-gtk Adwaita-dark Adwaita; do
            theme_dir_exists "$cand" && { GTK_THEME_NAME="$cand"; break; }
        done
    fi

    # --- Simge teması -------------------------------------------------------
    for cand in dracula-icons-main Papirus-Dark Adwaita hicolor; do
        icon_dir_exists "$cand" && { ICON_THEME_NAME="$cand"; break; }
    done

    # --- İmleç teması -------------------------------------------------------
    for cand in /usr/share/icons/catppuccin-mocha-*-cursors "$HOME/.icons"/catppuccin-mocha-*-cursors; do
        if [[ -d "$cand" ]]; then
            CURSOR_THEME_NAME="$(basename "$cand")"
            break
        fi
    done
    if [[ -z "$CURSOR_THEME_NAME" ]]; then
        for cand in Adwaita default; do
            [[ -d "/usr/share/icons/$cand/cursors" ]] && { CURSOR_THEME_NAME="$cand"; break; }
        done
    fi
    [[ -n "$CURSOR_THEME_NAME" ]] || CURSOR_THEME_NAME="Adwaita"

    success "GTK teması : ${GTK_THEME_NAME:-<yok>}"
    success "Simgeler   : ${ICON_THEME_NAME:-<yok>}"
    success "İmleç      : $CURSOR_THEME_NAME"

    [[ "$GTK_THEME_NAME" == *[Cc]atppuccin* ]] \
        || note "GTK teması Catppuccin değil (${GTK_THEME_NAME:-yok}). Catppuccin için: yay -S catppuccin-gtk-theme-mocha"
}

setup_gtk() {
    step "GTK görünümü yazılıyor"
    [[ -n "$GTK_THEME_NAME" ]] || { warning "GTK teması bulunamadı, atlandı"; return 1; }

    local font="Noto Sans 10"

    # GTK3 — settings.ini
    run mkdir -p "$HOME/.config/gtk-3.0"
    if ! $DRY_RUN; then
        cat > "$HOME/.config/gtk-3.0/settings.ini" <<EOF
# Arch_Dotfile tarafından yazıldı — nwg-look ile değiştirebilirsiniz.
[Settings]
gtk-theme-name=$GTK_THEME_NAME
gtk-icon-theme-name=$ICON_THEME_NAME
gtk-cursor-theme-name=$CURSOR_THEME_NAME
gtk-cursor-theme-size=$CURSOR_SIZE
gtk-font-name=$font
gtk-application-prefer-dark-theme=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
EOF
    fi

    # GTK4 — settings.ini + tema dosyalarının bağlanması
    run mkdir -p "$HOME/.config/gtk-4.0"
    if ! $DRY_RUN; then
        cat > "$HOME/.config/gtk-4.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=$GTK_THEME_NAME
gtk-icon-theme-name=$ICON_THEME_NAME
gtk-cursor-theme-name=$CURSOR_THEME_NAME
gtk-cursor-theme-size=$CURSOR_SIZE
gtk-font-name=$font
gtk-application-prefer-dark-theme=1
EOF
    fi

    # GTK4 kendi CSS'ini tema dizininden okumaz; libadwaita uygulamaları için
    # temanın gtk-4.0 varlıkları ~/.config/gtk-4.0 altına bağlanmalı.
    local theme_root=""
    [[ -d "/usr/share/themes/$GTK_THEME_NAME/gtk-4.0" ]] && theme_root="/usr/share/themes/$GTK_THEME_NAME"
    [[ -d "$HOME/.themes/$GTK_THEME_NAME/gtk-4.0"     ]] && theme_root="$HOME/.themes/$GTK_THEME_NAME"
    if [[ -n "$theme_root" ]] && ! $DRY_RUN; then
        local asset
        for asset in gtk.css gtk-dark.css assets; do
            [[ -e "$theme_root/gtk-4.0/$asset" ]] || continue
            rm -rf "$HOME/.config/gtk-4.0/$asset"
            ln -sfn "$theme_root/gtk-4.0/$asset" "$HOME/.config/gtk-4.0/$asset"
        done
        info "GTK4 tema varlıkları bağlandı"
    fi

    # gsettings — GTK4, Flatpak ve portal bu değerleri okur.
    # Oturum içinde çalıştırıldığında anında etkili olur; dışında dconf'a yazılır.
    if ! $DRY_RUN && command -v gsettings >/dev/null; then
        local i='org.gnome.desktop.interface'
        gsettings set $i gtk-theme       "$GTK_THEME_NAME"    2>/dev/null
        gsettings set $i icon-theme      "$ICON_THEME_NAME"   2>/dev/null
        gsettings set $i cursor-theme    "$CURSOR_THEME_NAME" 2>/dev/null
        gsettings set $i cursor-size     "$CURSOR_SIZE"       2>/dev/null
        gsettings set $i font-name       "$font"              2>/dev/null
        gsettings set $i color-scheme    'prefer-dark'        2>/dev/null
    fi

    success "GTK3 + GTK4 + gsettings yazıldı"
}

setup_cursor() {
    step "İmleç teması ayarlanıyor"

    # ~/.icons/default/index.theme — XCursor ve XWayland buradan çözer.
    # Depodaki dosya iki adayı listeliyor; burada gerçekten kurulu olanı
    # tek başına yazıyoruz ki eksik temaya düşme ihtimali kalmasın.
    run mkdir -p "$HOME/.icons/default"
    if ! $DRY_RUN; then
        cat > "$HOME/.icons/default/index.theme" <<EOF
# Arch_Dotfile kurulumu tarafından yazıldı ($STAMP)
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=$CURSOR_THEME_NAME
EOF
    fi

    # XWayland ve bazı araçlar bu env değişkenlerini okur; oturum genelinde
    # geçerli olması için ~/.config/uwsm ya da profile yerine Hyprland'in
    # kendi ortamına yazıyoruz.
    run mkdir -p "$HOME/.config/hypr/lua"
    local envfile="$HOME/.config/hypr/lua/cursor.lua"
    if ! $DRY_RUN; then
        cat > "$envfile" <<EOF
-- Arch_Dotfile kurulumu tarafından üretildi ($STAMP)
-- Bu dosya elle düzenlenmemeli; kurulum betiği her çalıştığında yeniden yazılır.
-- İmleç temasını değiştirmek için nwg-look kullanın, sonra betiği tekrar çalıştırın.
hl.env("XCURSOR_THEME", "$CURSOR_THEME_NAME")
hl.env("XCURSOR_SIZE", "$CURSOR_SIZE")
hl.env("HYPRCURSOR_THEME", "$CURSOR_THEME_NAME")
hl.env("HYPRCURSOR_SIZE", "$CURSOR_SIZE")
EOF
    fi

    success "İmleç: $CURSOR_THEME_NAME (${CURSOR_SIZE}px)"
}

# Qt uygulamaları da aynı koyu palete uysun.
setup_qt() {
    step "Qt görünümü yazılıyor"
    local d c
    for d in qt5ct qt6ct; do
        run mkdir -p "$HOME/.config/$d/colors"
        c="$HOME/.config/$d/colors/catppuccin-mocha.conf"
        if ! $DRY_RUN; then
            # Qt renk şeması: 21 renk, Qt'nin ColorRole sırasında.
            cat > "$c" <<'EOF'
[ColorScheme]
active_colors=#ffcdd6f4, #ff313244, #ff45475a, #ff313244, #ff11111b, #ff1e1e2e, #ffcdd6f4, #ffffffff, #ffcdd6f4, #ff1e1e2e, #ff1e1e2e, #ff11111b, #ff89b4fa, #ff11111b, #ff89b4fa, #ffcba6f7, #ff181825, #ff000000, #ff313244, #ffcdd6f4, #ff6c7086
disabled_colors=#ff6c7086, #ff313244, #ff45475a, #ff313244, #ff11111b, #ff1e1e2e, #ff6c7086, #ffffffff, #ff6c7086, #ff181825, #ff181825, #ff11111b, #ff45475a, #ff6c7086, #ff6c7086, #ff6c7086, #ff181825, #ff000000, #ff313244, #ff6c7086, #ff6c7086
inactive_colors=#ffcdd6f4, #ff313244, #ff45475a, #ff313244, #ff11111b, #ff1e1e2e, #ffcdd6f4, #ffffffff, #ffcdd6f4, #ff1e1e2e, #ff1e1e2e, #ff11111b, #ff45475a, #ffcdd6f4, #ff89b4fa, #ffcba6f7, #ff181825, #ff000000, #ff313244, #ffcdd6f4, #ff6c7086
EOF
            cat > "$HOME/.config/$d/$d.conf" <<EOF
# Arch_Dotfile kurulumu tarafından yazıldı ($STAMP)
[Appearance]
color_scheme_path=$c
custom_palette=true
icon_theme=$ICON_THEME_NAME
standard_dialogs=default
style=Fusion

# Not: [Fonts] bölümü bilinçli olarak yazılmıyor. qt5ct/qt6ct yazı tiplerini
# Qt'nin ikili "@Variant(...)" biçiminde saklar; bunu elle üretmek kırılgandır
# ve bozuk bir değer uygulamaları açılışta çökertebilir. Yazı tipi ayarını
# qt6ct arayüzünden yapın.

[Interface]
cursor_flash_time=1000
menus_have_icons=true
show_shortcuts_in_context_menus=true
EOF
        fi
    done
    success "qt5ct + qt6ct yapılandırıldı (Catppuccin Mocha, Fusion)"
}

# mako ve rofi simge yollarını gerçekten kurulu simge temasına göre düzeltir.
setup_icon_paths() {
    step "Simge yolları ayarlanıyor"

    if $DRY_RUN; then
        printf '%s  [kuru] mako icon-path ve rofi icon-theme → %s%s\n' "$YELLOW" "$ICON_THEME_NAME" "$NC"
        return 0
    fi

    local mako="$HOME/.config/mako/config"
    if [[ -f "$mako" ]]; then
        local paths="$HOME/.icons/$ICON_THEME_NAME:/usr/share/icons/$ICON_THEME_NAME:/usr/share/icons/Adwaita:/usr/share/icons/hicolor"
        sed -i "s|^icon-path=.*|icon-path=$paths|" "$mako"
        success "  mako icon-path"
    fi

    local rofi="$HOME/.config/rofi/config.rasi"
    if [[ -f "$rofi" ]]; then
        sed -i "s|^\(\s*icon-theme:\s*\).*|\1\"$ICON_THEME_NAME\";|" "$rofi"
        success "  rofi icon-theme"
    fi
}

#=============================================================================
#  KABUK / UYGULAMALAR
#=============================================================================

setup_zsh() {
    step "Zsh ve Oh My Zsh"

    # SIRA ÖNEMLİ. Eski sürümde önce .zshrc kopyalanıyor, sonra Oh My Zsh
    # kuruluyordu; kurulum betiği .zshrc'yi kendi şablonuyla DEĞİŞTİRDİĞİ için
    # depodaki .zshrc (eklentiler, PATH) her kurulumda kayboluyordu.
    # Doğru sıra: önce Oh My Zsh, sonra bizim .zshrc.

    if $DRY_RUN; then
        printf '%s  [kuru] Oh My Zsh + eklentiler%s\n' "$YELLOW" "$NC"
    elif [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log "Oh My Zsh kuruluyor..."
        # KEEP_ZSHRC=yes: kurulum betiği mevcut .zshrc'yi kendi şablonuyla
        # DEĞİŞTİRMESİN. CHSH=no: kabuk değişimini biz kontrol ediyoruz.
        if RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
           sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
            success "Oh My Zsh kuruldu"
        else
            error "Oh My Zsh kurulamadı"
        fi
    else
        info "Oh My Zsh zaten kurulu"
    fi

    local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local plug url
    for plug in zsh-autosuggestions zsh-syntax-highlighting; do
        url="https://github.com/zsh-users/$plug.git"
        if [[ -d "$custom/plugins/$plug" ]]; then
            info "$plug zaten kurulu"
        else
            run git clone --depth 1 "$url" "$custom/plugins/$plug" \
                && success "$plug kuruldu" \
                || error "$plug kurulamadı"
        fi
    done

    # Şimdi .zshrc'yi yerleştir — Oh My Zsh artık üzerine yazamaz.
    deploy_file "$REPO_DIR/configs/.zshrc" "$HOME/.zshrc"

    # Varsayılan kabuk.
    # `chsh` sudo'suz çalıştırıldığında PAM parola sorar; `-y` ile başlatılan
    # otomatik bir kurulum orada sessizce beklerdi. sudo yetkisi kurulum
    # boyunca zaten canlı tutulduğu için `sudo chsh -s ... "$USER"` hiçbir şey
    # sormadan tamamlanır.
    local zsh_bin; zsh_bin=$(command -v zsh)
    if [[ -z "$zsh_bin" ]]; then
        warning "zsh bulunamadı, varsayılan kabuk değiştirilmedi"
    elif [[ "$(getent passwd "$USER" | cut -d: -f7)" != *zsh ]]; then
        if run sudo chsh -s "$zsh_bin" "$USER"; then
            success "Varsayılan kabuk zsh yapıldı"
            note "Zsh'in etkili olması için oturumu kapatıp açın."
        else
            warning "Varsayılan kabuk değiştirilemedi. Elle: chsh -s \$(which zsh)"
        fi
    else
        info "Varsayılan kabuk zaten zsh"
    fi
}

setup_portals() {
    step "XDG masaüstü portalları"
    run mkdir -p "$HOME/.config/xdg-desktop-portal"
    if ! $DRY_RUN; then
        # Ekran paylaşımı hyprland portalından, dosya seçici GTK'dan gelsin.
        cat > "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf" <<'EOF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.FileChooser=gtk
org.freedesktop.impl.portal.Settings=gtk
EOF
    fi
    success "Portal tercihleri yazıldı"
}

setup_docker() {
    $MINIMAL && { info "Docker atlandı (--minimal)"; return 0; }
    pkg_installed docker || { info "Docker kurulu değil, atlandı"; return 0; }
    step "Docker"
    enable_service docker.service "Docker"
    if [[ " $(id -nG "$USER" 2>/dev/null) " == *" docker "* ]]; then
        info "Kullanıcı zaten docker grubunda"
    else
        run sudo usermod -aG docker "$USER" \
            && { success "Kullanıcı docker grubuna eklendi"; note "Docker'ı sudo'suz kullanmak için oturumu kapatıp açın."; } \
            || error "docker grubuna eklenemedi"
    fi
}

setup_flatpak() {
    $MINIMAL && { info "Flatpak atlandı (--minimal)"; return 0; }
    command -v flatpak >/dev/null || { info "Flatpak kurulu değil, atlandı"; return 0; }
    step "Flatpak"
    run sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo \
        && success "Flathub deposu eklendi" || warning "Flathub eklenemedi"

    if flatpak info com.github.marktext.marktext &>/dev/null; then
        info "MarkText zaten kurulu"
    else
        run sudo flatpak install -y --noninteractive flathub com.github.marktext.marktext \
            && success "MarkText kuruldu" || warning "MarkText kurulamadı"
    fi
}

setup_python() {
    step "Python"
    # Not: bu ayar pip'in sistem site-packages'ına yazmasına izin verir.
    # Sistem Python'ını bozma riski taşır; sanal ortam (python-virtualenv)
    # tercih edilmelidir. Depo bu davranışı bilinçli olarak koruyor.
    run python3 -m pip config set global.break-system-packages true >/dev/null \
        && success "pip yapılandırıldı" || warning "pip yapılandırılamadı"
    note "Python paketleri için sanal ortam önerilir: python -m venv .venv"
}

setup_nemo() {
    local conf="$REPO_DIR/configs/nemo/nemo-dconf.conf"
    [[ -f "$conf" ]] || return 0
    command -v dconf >/dev/null || { warning "dconf yok, nemo ayarları atlandı"; return 1; }
    step "Nemo ayarları"
    if $DRY_RUN; then
        printf '%s  [kuru] dconf load /org/nemo/ < %s%s\n' "$YELLOW" "$conf" "$NC"
        return 0
    fi
    dconf load /org/nemo/ < "$conf" && success "Nemo ayarları uygulandı" \
        || warning "Nemo ayarları uygulanamadı"
}

setup_user_dirs() {
    step "Kullanıcı dizinleri"
    command -v xdg-user-dirs-update >/dev/null || { warning "xdg-user-dirs yok"; return 1; }
    run xdg-user-dirs-update
    local pics
    pics=$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Resimler")
    run mkdir -p "$pics"
    success "Ekran görüntüsü dizini: ${pics/#$HOME/\~}"
}

setup_xhost() {
    # Root olarak açılan grafik uygulamaların XWayland'e erişebilmesi için.
    # Satır zaten varsa TEKRAR EKLENMEZ — eski sürüm her çalıştırmada
    # ~/.profile dosyasına aynı satırı yeniden ekliyordu.
    local line='command -v xhost >/dev/null && xhost +SI:localuser:root >/dev/null 2>&1'
    local profile="$HOME/.profile"
    if [[ -f "$profile" ]] && grep -qF 'SI:localuser:root' "$profile"; then
        info "xhost satırı ~/.profile içinde zaten var"
        return 0
    fi
    $DRY_RUN && { printf '%s  [kuru] ~/.profile += xhost%s\n' "$YELLOW" "$NC"; return 0; }
    printf '\n# Arch_Dotfile: root GUI uygulamaları için XWayland erişimi\n%s\n' "$line" >> "$profile"
    success "xhost satırı ~/.profile dosyasına eklendi"
}

#=============================================================================
#  DOĞRULAMA
#=============================================================================

check_cmd() {
    local cmd="$1" desc="$2"
    if command -v "$cmd" &>/dev/null; then
        printf '  %s✓%s %-22s %s\n' "$GREEN" "$NC" "$cmd" "$desc"
        return 0
    fi
    printf '  %s✗%s %-22s %s\n' "$RED" "$NC" "$cmd" "$desc"
    return 1
}

check_file() {
    local f="$1" desc="$2"
    if [[ -e "$f" ]]; then
        printf '  %s✓%s %-42s %s\n' "$GREEN" "$NC" "${f/#$HOME/\~}" "$desc"
        return 0
    fi
    printf '  %s✗%s %-42s %s\n' "$RED" "$NC" "${f/#$HOME/\~}" "$desc"
    return 1
}

run_checks() {
    local fails=0

    step "Komutlar"
    for pair in \
        "Hyprland:pencere yöneticisi" "waybar:panel" "mako:bildirimler" \
        "rofi:uygulama başlatıcı" "wlogout:oturum menüsü" "hyprlock:ekran kilidi" \
        "hypridle:boşta kalma" "hyprpaper:duvar kağıdı" "alacritty:terminal" \
        "nemo:dosya yöneticisi" "grim:ekran görüntüsü" "slurp:bölge seçimi" \
        "swappy:görüntü düzenleme" "wl-copy:pano" "cliphist:pano geçmişi" \
        "jq:pencere görüntüsü" "brightnessctl:parlaklık" "playerctl:medya tuşları" \
        "wpctl:ses kontrolü" "pavucontrol:ses ayarları" "blueman-manager:bluetooth" \
        "nwg-look:GTK tema aracı" "zsh:kabuk" "btop:sistem izleyici" \
        "xdg-user-dir:kullanıcı dizinleri"
    do
        check_cmd "${pair%%:*}" "${pair#*:}" || ((fails++))
    done

    step "Yapılandırma dosyaları"
    for pair in \
        "$HOME/.config/hypr/hyprland.lua:Hyprland (Lua)" \
        "$HOME/.config/hypr/lua/binds.lua:kısayollar" \
        "$HOME/.config/hypr/hyprlock.conf:kilit ekranı" \
        "$HOME/.config/hypr/hypridle.conf:boşta kalma" \
        "$HOME/.config/hypr/hyprpaper.conf:duvar kağıdı" \
        "$HOME/.config/waybar/config:panel" \
        "$HOME/.config/waybar/style.css:panel stili" \
        "$HOME/.config/mako/config:bildirimler" \
        "$HOME/.config/rofi/config.rasi:başlatıcı" \
        "$HOME/.config/rofi/theme.rasi:başlatıcı teması" \
        "$HOME/.config/wlogout/layout:oturum menüsü" \
        "$HOME/.config/wlogout/style.css:oturum menüsü stili" \
        "$HOME/.config/alacritty/alacritty.toml:terminal" \
        "$HOME/.config/gtk-3.0/settings.ini:GTK3 teması" \
        "$HOME/.config/gtk-4.0/settings.ini:GTK4 teması" \
        "$HOME/.icons/default/index.theme:imleç teması" \
        "$HOME/.local/bin/caffeine:kahve (uyku engelleme) düğmesi" \
        "$HOME/.zshrc:zsh yapılandırması"
    do
        check_file "${pair%%:*}" "${pair#*:}" || ((fails++))
    done

    step "Duvar kağıdı ve yazı tipleri"
    check_file "$HOME/.config/hypr/wallpaper/wallpaper.jpg" "duvar kağıdı" || ((fails++))
    # DİKKAT — `fc-list | grep -q` YAZMAYIN. grep ilk eşleşmede kapanır,
    # fc-list SIGPIPE alır ve `set -o pipefail` yüzünden boru hattı 141 döner:
    # font KURULU olduğu halde koşul yanlış çalışır. (Bu satır eskiden öyleydi
    # ve kurulum sonunda hep "JetBrainsMono Nerd Font YOK" yazıyordu.)
    # Süreç ikamesinde ise koşulun sonucu yalnızca grep'in çıkış kodudur.
    if grep -qi "JetBrainsMono Nerd" < <(fc-list 2>/dev/null); then
        printf '  %s✓%s JetBrainsMono Nerd Font kurulu\n' "$GREEN" "$NC"
    else
        printf '  %s✗%s JetBrainsMono Nerd Font YOK — simgeler kutu görünür\n' "$RED" "$NC"
        ((fails++))
    fi

    step "Servisler"
    local svc
    for svc in NetworkManager.service bluetooth.service; do
        if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
            printf '  %s✓%s %s\n' "$GREEN" "$NC" "$svc"
        else
            printf '  %s✗%s %s etkin değil\n' "$RED" "$NC" "$svc"
            ((fails++))
        fi
    done

    step "Hyprland yapılandırması"
    if [[ -f "$HOME/.config/hypr/hyprland.conf" ]]; then
        printf '  %s!%s ~/.config/hypr/hyprland.conf hâlâ duruyor.\n' "$YELLOW" "$NC"
        printf '    Hyprland hyprland.lua varken onu kullanır; bu dosya artık okunmuyor.\n'
        printf '    Karışıklığı önlemek için silebilirsiniz.\n'
    fi
    check_hyprland_lua_support || ((fails++))

    echo
    if (( fails == 0 )); then
        printf '%s%sTüm kontroller başarılı.%s\n' "$BOLD" "$GREEN" "$NC"
    else
        printf '%s%s%d kontrol başarısız.%s Eksikleri gidermek için scripti tekrar çalıştırın.\n' \
            "$BOLD" "$RED" "$fails" "$NC"
    fi
    return $(( fails > 0 ))
}

#=============================================================================
#  ÖZET
#=============================================================================

show_summary() {
    echo
    printf '%s' "$GREEN"
    cat <<'EOF'
╔══════════════════════════════════════════════════════════════╗
║                     KURULUM TAMAMLANDI                       ║
╚══════════════════════════════════════════════════════════════╝
EOF
    printf '%s\n' "$NC"

    if (( ${#FAILED_ITEMS[@]} > 0 )); then
        printf '%s%sBaşarısız olanlar (%d):%s\n' "$BOLD" "$RED" "${#FAILED_ITEMS[@]}" "$NC"
        printf '  • %s\n' "${FAILED_ITEMS[@]}"
        echo
    fi

    if (( ${#WARNED_ITEMS[@]} > 0 )); then
        printf '%s%sUyarılar (%d):%s\n' "$BOLD" "$YELLOW" "${#WARNED_ITEMS[@]}" "$NC"
        printf '  • %s\n' "${WARNED_ITEMS[@]}"
        echo
    fi

    printf '%s%sŞimdi ne yapmalı:%s\n' "$BOLD" "$CYAN" "$NC"
    cat <<EOF
  1. Sistemi yeniden başlatın:            reboot
  2. Giriş ekranında oturum türü olarak   Hyprland  seçin.
  3. Kurulumu doğrulamak için:            $SCRIPT_PATH --check

$(printf '%s%sTemel kısayollar:%s\n' "$BOLD" "$CYAN" "$NC")
  SUPER + RETURN     terminal              SUPER + R          uygulama başlatıcı
  SUPER + E          dosya yöneticisi      SUPER + TAB        açık pencereler
  SUPER + Q          pencereyi kapat       SUPER + ESCAPE     oturum menüsü
  SUPER + L          ekranı kilitle        SUPER + C          pano geçmişi
  PRINT              ekran görüntüsü       SUPER + 1..0       workspace

$(printf '%s%sDosya konumları:%s\n' "$BOLD" "$CYAN" "$NC")
  Yapılandırmalar    ~/.config/
  Yedekler           ${BACKUP_DIR/#$HOME/\~}
  Kurulum günlüğü    ${LOG_FILE/#$HOME/\~}
  Makineye özel      ~/.config/hypr/lua/local.lua   (örnek: local.lua.example)
EOF

    if (( ${#NOTES[@]} > 0 )); then
        echo
        printf '%s%sNotlar:%s\n' "$BOLD" "$CYAN" "$NC"
        printf '  • %s\n' "${NOTES[@]}"
    fi
    echo
}

#=============================================================================
#  ANA AKIŞ
#=============================================================================

main() {
    parse_args "$@"
    show_banner

    if $CHECK_ONLY; then
        run_checks
        exit $?
    fi

    mkdir -p "$(dirname "$LOG_FILE")"
    $DRY_RUN || exec > >(tee -a "$LOG_FILE") 2>&1

    $DRY_RUN && printf '%s%sKURU ÇALIŞTIRMA — hiçbir değişiklik yapılmayacak.%s\n\n' "$BOLD" "$YELLOW" "$NC"

    step "Ön kontroller"
    check_arch
    check_not_root
    check_internet
    check_disk_space
    check_pacman_free
    check_repo

    echo
    # Not: bu bir uyarı MESAJI, bir hata değil — özet listesine girmemesi için
    # warning() yerine doğrudan yazdırılıyor.
    printf '%s[DİKKAT]%s Bu script sisteminize paket kuracak ve ~/.config altındaki dosyaları değiştirecek.\n' "$YELLOW" "$NC"
    info "Değiştirilen her dosya önce şuraya yedeklenir: ${BACKUP_DIR/#$HOME/\~}"
    if ! confirm "Devam edilsin mi?"; then
        fatal "Kurulum iptal edildi."
    fi

    start_sudo_keepalive

    update_system

    step "Çekirdek paketler"
    install_pacman_group "Çekirdek" "${PKG_CORE[@]}"

    if $MINIMAL; then
        info "İsteğe bağlı paketler atlandı (--minimal)"
    else
        step "İsteğe bağlı paketler"
        install_pacman_group "İsteğe bağlı" "${PKG_OPTIONAL[@]}"
    fi

    if $USE_AUR; then
        install_yay
        step "AUR paketleri"
        install_aur_group "AUR (gerekli)" "${AUR_CORE[@]}"
        install_aur_group "AUR (tema)"    "${AUR_THEME[@]}"
        $MINIMAL || install_aur_group "AUR (isteğe bağlı)" "${AUR_OPTIONAL[@]}"
    else
        info "AUR atlandı (--no-aur)"
        note "wlogout AUR'dadır; SUPER+ESCAPE oturum menüsü çalışmayacak."
    fi

    check_hyprland_lua_support

    setup_services
    setup_dotfiles
    setup_paths
    setup_waybar_sensor
    detect_themes
    setup_gtk
    setup_cursor
    setup_qt
    setup_icon_paths
    setup_portals
    setup_zsh
    setup_user_dirs
    setup_xhost
    setup_python
    setup_nemo
    setup_docker
    setup_flatpak
    setup_display_manager

    stop_sudo_keepalive

    step "Doğrulama"
    run_checks || true

    show_summary
}

main "$@"
