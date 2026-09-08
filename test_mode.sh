#!/usr/bin/env bash
#
#=============================================================================
#  TEST MODU  —  uyumluluk sarmalayıcısı
#  Arch_Dotfile · https://github.com/koesan/Arch_Dotfile
#
#  Bu betik artık kendi paket listesini TUTMUYOR; kurulum betiğini kuru
#  çalıştırma kipinde çağırıyor.
#
#  NEDEN: eski test_mode.sh, paket listesini ve yapılacak işleri elle
#  kopyalanmış metin olarak içeriyordu. Kurulum betiği değiştikçe bu liste
#  geride kaldı ve gerçekte olmayan şeyleri vaat eder hale geldi — örneğin
#  "NVIDIA GRUB ayarları" ve "PulseAudio devre dışı bırakılacak" satırları
#  kurulum betiğinde hiçbir zaman karşılığı olmayan adımlardı, "neofetch"
#  ise Arch depolarından kaldırılmıştı.
#
#  Tek kaynak ilkesi: ne kurulacağını yalnızca arch_dotfile_installer.sh
#  bilir. Bu sarmalayıcı da ona sorar; böylece iki liste bir daha ayrışamaz.
#=============================================================================

set -uo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
INSTALLER="$SCRIPT_DIR/arch_dotfile_installer.sh"

if [[ ! -x "$INSTALLER" ]]; then
    printf 'Kurulum betiği bulunamadı veya çalıştırılabilir değil: %s\n' "$INSTALLER" >&2
    printf 'Düzeltmek için: chmod +x "%s"\n' "$INSTALLER" >&2
    exit 1
fi

cat <<'INFO'
╔══════════════════════════════════════════════════════════════╗
║                  ARCH DOTFILE — TEST MODU                    ║
║        Hiçbir değişiklik yapılmaz; yalnızca gösterir.        ║
╚══════════════════════════════════════════════════════════════╝

Aşağıdaki çıktı, kurulum betiğinin gerçekten çalıştıracağı komutların
tamamıdır. Doğrudan da çağırabilirsiniz:

    ./arch_dotfile_installer.sh --dry-run

Kurulumdan SONRA sistemin durumunu doğrulamak için:

    ./arch_dotfile_installer.sh --check

INFO

"$INSTALLER" --dry-run "$@"

printf '\n'
read -r -p "Şimdi gerçek kurulumu başlatmak ister misiniz? (e/H): " reply
if [[ "$reply" =~ ^([eE]|[yY]|[eE][vV][eE][tT])$ ]]; then
    exec "$INSTALLER"
fi

printf 'Test modu tamamlandı. Kurulum için: %s\n' "$INSTALLER"
